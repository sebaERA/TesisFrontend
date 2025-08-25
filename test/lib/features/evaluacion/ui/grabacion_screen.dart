import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../pacientes/models/paciente.dart';
import '../../utils/noise_watcher.dart'; // <-- tu clase NoiseWatcher

enum RecordPhase { idle, checkingNoise, preCountdown, recording, uploading, done }

class GrabacionRealScreen extends StatefulWidget {
  final Paciente paciente;
  const GrabacionRealScreen({required this.paciente, super.key});

  @override
  State<GrabacionRealScreen> createState() => _GrabacionRealScreenState();
}

class _GrabacionRealScreenState extends State<GrabacionRealScreen> {
  // Flujo/UI
  RecordPhase _phase = RecordPhase.idle;
  String? _mensaje;
  String? _resultadoServidor;

  // Grabación
  final _recorder = AudioRecorder();
  String? _currentFilePath;

  // Countdowns
  Timer? _preTimer;
  Timer? _recTimer;
  int _preSecondsLeft = 0; // 3 -> 0
  int _recSecondsLeft = 0; // 60 -> 0

  // Ruido (NoiseWatcher)
  late final NoiseWatcher _noise;

  // Config
  static const int kPreCountdown = 3;
  static const int kRecordDuration = 60;

  @override
  void initState() {
    super.initState();
    // Configura tus umbrales/duraciones tal como definiste en NoiseWatcher
    _noise = NoiseWatcher(
      noisyThresholdDb: 52.0,
      quietThresholdDb: 47.0,
      noisyMinDuration: const Duration(seconds: 2),
      quietMinDuration: const Duration(seconds: 1),
      window: const Duration(milliseconds: 1500),
    );
    // Arranca el watcher apenas entra la pantalla
    _noise.start().catchError((e) {
      setState(() => _mensaje = 'No se pudo iniciar el medidor de ruido: $e');
    });
  }

  @override
  void dispose() {
    _preTimer?.cancel();
    _recTimer?.cancel();
    _noise.stop();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _onTapIniciarFlujo() async {
    if (_phase != RecordPhase.idle) return;

    setState(() {
      _mensaje = null;
      _resultadoServidor = null;
      _phase = RecordPhase.checkingNoise;
    });

    final okRuido = await _waitForQuietWithUI();
    if (!mounted) return;

    if (!okRuido) {
      // Si quieres, deja un botón Reintentar. Por ahora, volvemos a idle con mensaje.
      setState(() {
        _phase = RecordPhase.idle;
        _mensaje = 'Ambiente ruidoso. Intenta en un entorno más silencioso.';
      });
      return;
    }

    // 2) Cuenta regresiva 3s
    setState(() {
      _phase = RecordPhase.preCountdown;
      _preSecondsLeft = kPreCountdown;
      _mensaje = 'Iniciando en...';
    });

    _preTimer?.cancel();
    _preTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) return;
      setState(() => _preSecondsLeft--);
      if (_preSecondsLeft <= 0) {
        t.cancel();
        await _iniciarGrabacion();
      }
    });
  }

  /// Espera hasta que NoiseWatcher reporte estado "silencioso".
  /// Devuelve true si se logra, false si se agota el tiempo (10s).
  Future<bool> _waitForQuietWithUI() async {
    // Si ya está silencioso, listo
    if (_noise.isNoisy.value == false) return true;

    // Escucha cambios de isNoisy hasta 10 s
    final completer = Completer<bool>();
    late void Function() listener;

    // Seguridad de timeout por si nunca baja el ruido
    final timeout = Timer(const Duration(seconds: 10), () {
      _noise.isNoisy.removeListener(listener);
      if (!completer.isCompleted) completer.complete(false);
    });

    listener = () {
      // Cuando NoiseWatcher pase a false (ya cumplió histéresis y duración quieta), seguimos
      if (_noise.isNoisy.value == false) {
        timeout.cancel();
        _noise.isNoisy.removeListener(listener);
        if (!completer.isCompleted) completer.complete(true);
      } else {
        // sigue ruidoso; mantenemos UI mostrando “Comprobando…”
      }
      // Actualiza UI con dB en vivo si quieres:
      if (mounted && _phase == RecordPhase.checkingNoise) {
        setState(() {}); // para refrescar dB promedio mostrado
      }
    };

    _noise.isNoisy.addListener(listener);

    // Mensaje inicial
    setState(() => _mensaje = 'Comprobando ruido externo…');

    // También actualiza dB mientras esperamos
    return completer.future;
  }

  Future<void> _iniciarGrabacion() async {
    try {
      final tmp = await getTemporaryDirectory();
      final filePath =
          '${tmp.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      _currentFilePath = filePath;

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: filePath,
      );

      setState(() {
        _phase = RecordPhase.recording;
        _mensaje = 'Grabando…';
        _recSecondsLeft = kRecordDuration;
      });

      _recTimer?.cancel();
      _recTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
        if (!mounted) return;
        setState(() => _recSecondsLeft--);
        if (_recSecondsLeft <= 0) {
          t.cancel();
          await _detenerGrabacionYSubir();
        }
      });
    } catch (e) {
      setState(() {
        _phase = RecordPhase.idle;
        _mensaje = 'Error al iniciar grabación: $e';
      });
    }
  }

  Future<void> _detenerGrabacionYSubir() async {
    _recTimer?.cancel();

    setState(() {
      _phase = RecordPhase.uploading;
      _mensaje = 'Subiendo audio…';
    });

    String? path;
    try {
      final isRecording = await _recorder.isRecording();
      if (isRecording) {
        path = await _recorder.stop();
      } else {
        path = _currentFilePath;
      }

      if (path == null || !File(path).existsSync()) {
        setState(() {
          _phase = RecordPhase.idle;
          _mensaje = 'No se encontró el archivo grabado.';
        });
        return;
      }

      final uri = Uri.parse(
        'https://backendtesis-1044129606293.southamerica-west1.run.app/api/evaluar-audio',
      );

      final req = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'file',
            path,
            contentType: MediaType('audio', 'wav'),
          ),
        )
        ..fields['idpacientes'] = widget.paciente.id.toString()
        ..fields['idtiporesultado'] = '1';

      final client = http.Client();
      http.StreamedResponse streamed;
      try {
        streamed = await client.send(req).timeout(const Duration(seconds: 40));
      } on TimeoutException {
        setState(() {
          _phase = RecordPhase.idle;
          _mensaje = 'Timeout al subir el audio (40s).';
        });
        return;
      } on SocketException catch (e) {
        setState(() {
          _phase = RecordPhase.idle;
          _mensaje = 'Error de red: $e';
        });
        return;
      } finally {
        client.close();
      }

      final respStr = await streamed.stream.bytesToString();
      if (!mounted) return;

      setState(() {
        _resultadoServidor =
            (streamed.statusCode == 200) ? respStr : 'Error ${streamed.statusCode}: $respStr';
        _mensaje = (streamed.statusCode == 200)
            ? 'Audio subido y evaluado.'
            : 'Fallo en evaluación.';
        _phase = RecordPhase.done;
      });
    } catch (e) {
      setState(() {
        _phase = RecordPhase.idle;
        _mensaje = 'Error al detener/subir: $e';
      });
    } finally {
      // Limpieza del temporal
      final toDelete = path ?? _currentFilePath;
      if (toDelete != null) {
        try {
          final f = File(toDelete);
          if (f.existsSync()) {
            await f.delete();
          }
        } catch (_) {}
      }
      _currentFilePath = null;
    }
  }

  String _formatMMSS(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  @override
  Widget build(BuildContext context) {
    final isIdle = _phase == RecordPhase.idle;
    final isChecking = _phase == RecordPhase.checkingNoise;
    final isPre = _phase == RecordPhase.preCountdown;
    final isRec = _phase == RecordPhase.recording;
    final isUp = _phase == RecordPhase.uploading;
    final isDone = _phase == RecordPhase.done;

    return Scaffold(
      appBar: AppBar(title: const Text('Grabación Real')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Paciente: ${widget.paciente.nombre}'),
              const SizedBox(height: 12),

              // Indicador de ruido (opcional mostrar siempre)
              ValueListenableBuilder<double?>(
                valueListenable: _noise.meanDb,
                builder: (_, m, __) => Text(
                  'Ruido ambiente: ${m?.toStringAsFixed(1) ?? "--"} dB',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<bool>(
                valueListenable: _noise.isNoisy,
                builder: (_, noisy, __) => noisy
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.15),
                          border: Border.all(color: Colors.orange),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isChecking
                              ? 'Comprobando ruido externo…'
                              : 'Ambiente ruidoso: espera a que baje (< ${_noise.quietThresholdDb.toStringAsFixed(0)} dB)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              const SizedBox(height: 16),

              if (isPre) ...[
                Text(_mensaje ?? 'Iniciando…', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('${_preSecondsLeft}s',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
              ],

              if (isRec) ...[
                const Text('Grabando…', style: TextStyle(color: Colors.red, fontSize: 18)),
                const SizedBox(height: 8),
                Text(_formatMMSS(_recSecondsLeft),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              ],

              if (isUp) ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(_mensaje ?? 'Subiendo…'),
              ],

              if ((isIdle || isDone) && _mensaje != null) ...[
                const SizedBox(height: 8),
                Text(_mensaje!),
              ],

              if (isDone && _resultadoServidor != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(_resultadoServidor!, textAlign: TextAlign.left),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              if (isIdle)
                ValueListenableBuilder<bool>(
                  valueListenable: _noise.isNoisy,
                  builder: (_, noisy, __) => ElevatedButton.icon(
                    icon: const Icon(Icons.mic),
                    label: const Text('Iniciar grabación'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: noisy ? Colors.grey : Colors.green,
                    ),
                    onPressed: noisy ? null : _onTapIniciarFlujo,
                  ),
                ),

              if (isRec)
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  label: const Text('Detener ahora'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    _recTimer?.cancel();
                    await _detenerGrabacionYSubir();
                  },
                ),

              const SizedBox(height: 12),

              if (!isUp)
                OutlinedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

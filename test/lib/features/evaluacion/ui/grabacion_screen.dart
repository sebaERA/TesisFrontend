import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test/features/pacientes/models/paciente.dart';
import '../models/resultado.dart';
import '../../../service/canary_speech_service.dart';
import '../../../service/audio_recorder_service.dart';

class GrabacionRealScreen extends StatefulWidget {
  final Paciente paciente;
  const GrabacionRealScreen({super.key, required this.paciente});

  @override
  State<GrabacionRealScreen> createState() => _GrabacionRealScreenState();
}

class _GrabacionRealScreenState extends State<GrabacionRealScreen> {
  final AudioRecorderService _recorder = AudioRecorderService();
  late CanarySpeechService _canary;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String? _analysisResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _canary = CanarySpeechService('TU_API_KEY_AQUÍ');
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // Verifica consentimiento
    if (!widget.paciente.consentimiento) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe registrar el consentimiento primero'),
        ),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/${widget.paciente.id}_${DateTime.now().millisecondsSinceEpoch}.wav';

    if (await _recorder.tienePermiso()) {
      await _recorder.iniciarGrabacion(path);
      setState(() => _isRecording = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de micrófono denegado')),
      );
    }
  }

  Future<void> _stopAndAnalyze() async {
    await _recorder.detenerGrabacion();
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _analysisResult = null;
      _error = null;
    });

    try {
      // Obtén la ruta que usamos arriba
      final dir = await getTemporaryDirectory();
      final latestFile = Directory(dir.path)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.wav'))
          .reduce(
            (a, b) =>
                a.lastModifiedSync().isAfter(b.lastModifiedSync()) ? a : b,
          );

      final json = await _canary.analyzeAudio(latestFile);
      setState(() => _analysisResult = json.toString());
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grabación Real')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Paciente: ${widget.paciente.nombre}'),
            const SizedBox(height: 20),
            if (_isRecording)
              const Text('Grabando…', style: TextStyle(color: Colors.red))
            else if (_isAnalyzing)
              const Text('Analizando…', style: TextStyle(color: Colors.blue))
            else if (_analysisResult != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text('Resultado: $_analysisResult'),
                ),
              )
            else if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'rec',
                  backgroundColor: _isRecording ? Colors.red : Colors.green,
                  child: Icon(_isRecording ? Icons.stop : Icons.mic),
                  onPressed: _isRecording ? _stopAndAnalyze : _startRecording,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

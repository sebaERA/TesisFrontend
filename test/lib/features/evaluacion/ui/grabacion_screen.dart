import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:io';

import '../../pacientes/models/paciente.dart';

class GrabacionRealScreen extends StatefulWidget {
  final Paciente paciente;
  const GrabacionRealScreen({required this.paciente, super.key});

  @override
  State<GrabacionRealScreen> createState() => _GrabacionRealScreenState();
}

class _GrabacionRealScreenState extends State<GrabacionRealScreen> {
  bool _grabando = false;
  bool _subiendo = false;
  String? _mensaje;

  final _recorder = AudioRecorder(); // Instancia única
  String? _audioPath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<bool> _pedirPermisos() async {
    final status = await Permission.microphone.status;
    if (!status.isGranted) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    return true;
  }

  Future<void> _iniciarGrabacion() async {
    final tienePermiso = await _pedirPermisos();
    if (!tienePermiso) {
      setState(() {
        _mensaje = 'Permiso de micrófono denegado';
      });
      return;
    }

    if (await _recorder.isRecording()) {
      setState(() {
        _mensaje = "Ya hay una grabación activa.";
      });
      return;
    }

    setState(() {
      _grabando = true;
      _mensaje = null;
    });

    try {
      Directory tempDir = await getTemporaryDirectory();
      _audioPath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      print("Grabando en: $_audioPath");

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 16000,
          sampleRate: 16000,
        ),
        path: _audioPath!,
      );

      setState(() {
        _mensaje = "Grabando...";
      });
    } catch (e) {
      print('Error al iniciar grabación: $e');
      setState(() {
        _mensaje = "Error al iniciar grabación: $e";
        _grabando = false;
      });
    }
  }

  Future<void> _detenerGrabacionYSubir() async {
    setState(() {
      _grabando = false;
      _subiendo = true;
      _mensaje = 'Subiendo audio...';
    });

    try {
      print('Intentando detener grabación...');
      if (!await _recorder.isRecording()) {
        setState(() {
          _mensaje = 'No hay grabación activa';
          _subiendo = false;
        });
        return;
      }

      final path = await _recorder.stop();
      print("Grabación detenida. Path del archivo: $path");

      if (path == null || !File(path).existsSync()) {
        print("El archivo no existe en la ruta especificada");
        setState(() {
          _mensaje = "Error: No se encontró el archivo grabado";
          _subiendo = false;
        });
        return;
      }

      File file = File(path);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.100.95:8000/api/evaluar-audio'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('audio', 'wav'),
        ),
      );
      request.fields['idpacientes'] = widget.paciente.id;
      request.fields['idtiporesultado'] = '1';

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      setState(() {
        _subiendo = false;
        if (response.statusCode == 200) {
          _mensaje = 'Audio subido y evaluado correctamente';
        } else {
          _mensaje = 'Error al subir audio: $respStr';
        }
      });

      // Regresa automáticamente después de 2 segundos
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      print('Error al detener/subir: $e');
      setState(() {
        _subiendo = false;
        _mensaje = 'Error al detener/subir: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Grabación Real')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Paciente: ${widget.paciente.nombre}'),
            SizedBox(height: 32),
            if (_grabando)
              Text(
                'Grabando...',
                style: TextStyle(color: Colors.red, fontSize: 20),
              ),
            if (_subiendo)
              Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text(_mensaje ?? 'Subiendo...'),
                ],
              ),
            if (!_grabando && !_subiendo)
              ElevatedButton.icon(
                icon: Icon(Icons.mic),
                label: Text('Iniciar grabación'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _iniciarGrabacion,
              ),
            if (_grabando)
              ElevatedButton.icon(
                icon: Icon(Icons.stop),
                label: Text('Detener y subir'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _detenerGrabacionYSubir,
              ),
            if (_mensaje != null && !_subiendo)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _mensaje!,
                  style: TextStyle(color: Colors.blue),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

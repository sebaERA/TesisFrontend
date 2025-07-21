import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../pacientes/models/paciente.dart';

class GrabacionMinimaScreen extends StatefulWidget {
  final Paciente paciente;
  const GrabacionMinimaScreen({required this.paciente, super.key});

  @override
  State<GrabacionMinimaScreen> createState() => _GrabacionMinimaScreenState();
}

class _GrabacionMinimaScreenState extends State<GrabacionMinimaScreen> {
  bool _grabando = false;
  String? _mensaje;
  final _recorder = AudioRecorder(); // Instancia única del recorder
  String? _currentPath;

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    print('Intentando iniciar grabación...');

    // Verificar si ya está grabando
    if (await _recorder.isRecording()) {
      print('Ya está grabando');
      return;
    }

    if (await Permission.microphone.request().isGranted) {
      print('Permiso de micrófono concedido');

      try {
        Directory tempDir = await getTemporaryDirectory();
        _currentPath =
            '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

        print('Intentando grabar en: $_currentPath');

        await _recorder.start(
          RecordConfig(
            encoder:
                AudioEncoder.wav, // Cambiado a WAV para mejor compatibilidad
            bitRate: 16000,
            sampleRate: 16000,
          ),
          path: _currentPath!,
        );

        print('Grabación iniciada correctamente');
        setState(() {
          _grabando = true;
          _mensaje = "Grabando...";
        });
      } catch (e) {
        print('Error al iniciar grabación: $e');
        setState(() {
          _mensaje = "Error al iniciar grabación: $e";
        });
      }
    } else {
      print('Permiso de micrófono denegado');
      setState(() {
        _mensaje = "Sin permiso de micrófono";
      });
    }
  }

  Future<void> _detener() async {
    print('Intentando detener grabación...');
    if (!await _recorder.isRecording()) {
      print('No hay grabación activa');
      return;
    }

    try {
      final path = await _recorder.stop();
      print("Grabación detenida. Path del archivo: $path");

      // Verificar si el archivo existe
      if (path != null && File(path).existsSync()) {
        print("Archivo verificado en: $path");
        setState(() {
          _grabando = false;
          _mensaje = "Grabado en: $path";
        });
      } else {
        print("El archivo no existe en la ruta especificada");
        setState(() {
          _grabando = false;
          _mensaje = "Error: No se encontró el archivo grabado";
        });
      }
    } catch (e) {
      print('Error al detener grabación: $e');
      setState(() {
        _mensaje = "Error al detener: $e";
        _grabando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Grabación')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_mensaje ?? "Paciente: ${widget.paciente.nombre}"),
            SizedBox(height: 32),
            !_grabando
                ? ElevatedButton(onPressed: _iniciar, child: Text('Iniciar'))
                : ElevatedButton(onPressed: _detener, child: Text('Detener')),
          ],
        ),
      ),
    );
  }
}

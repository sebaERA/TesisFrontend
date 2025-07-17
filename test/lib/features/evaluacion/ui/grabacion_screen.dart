import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
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

  String? _audioPath;

  Future<void> _iniciarGrabacion() async {
    setState(() {
      _grabando = true;
      _mensaje = null;
    });

    final record = AudioRecorder();
    if (await record.hasPermission()) {
      Directory tempDir = await getTemporaryDirectory();
      String path =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      await record.start(
        RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 16000,
        ),
        path: path,
      );

      _audioPath = path;
    } else {
      setState(() {
        _mensaje = 'No se concedió permiso de micrófono';
      });
    }
  }

  Future<void> _detenerGrabacionYSubir() async {
    setState(() {
      _grabando = false;
      _subiendo = true;
      _mensaje = 'Subiendo audio...';
    });

    final record = AudioRecorder();
    final path = await record.stop();
    if (path == null) {
      setState(() {
        _mensaje = 'No se generó archivo de audio';
        _subiendo = false;
      });
      return;
    }

    try {
      File file = File(path);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.0.2.2:8000/api/evaluar-audio'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('audio', 'wav'),
        ),
      );
      request.fields['idpacientes'] = widget.paciente.id;
      request.fields['idtiporesultado'] = '1'; // Ajusta según tu lógica

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
      setState(() {
        _subiendo = false;
        _mensaje = 'Error al subir audio: $e';
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

import 'package:record/record.dart';

class AudioRecorderService {
  final AudioRecorder _record = AudioRecorder();

  Future<bool> tienePermiso() async {
    return await _record.hasPermission();
  }

  Future<void> iniciarGrabacion(String path) async {
    await _record.start(
      RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
      ),
      path: path,
    );
  }

  Future<void> detenerGrabacion() async {
    await _record.stop();
  }

  Future<bool> estaGrabando() async {
    return await _record.isRecording();
  }

  // Método adicional para limpiar recursos
  void dispose() {
    _record.dispose();
  }
}

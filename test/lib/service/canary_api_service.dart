import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CanaryApiService {
  static const String backendUrl =
      'http://TU_BACKEND:8000/api/evaluar-audio'; // Cambia IP

  Future<String> enviarAudio({
    required File audioFile,
    required int pacienteId,
    required int tipoResultadoId,
  }) async {
    final uri = Uri.parse(backendUrl);
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['idPaciente'] = pacienteId.toString()
          ..fields['idTipoResultado'] = tipoResultadoId.toString()
          ..files.add(
            await http.MultipartFile.fromPath('file', audioFile.path),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);
      return data['resultado'];
    } else {
      throw Exception('Error al enviar audio: ${response.statusCode}');
    }
  }
}

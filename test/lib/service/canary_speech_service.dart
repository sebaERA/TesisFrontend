import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CanarySpeechService {
  final String _apiKey;
  final Uri _endpoint = Uri.parse(
    'https://api.canaryspeech.com/v1/voice-analysis',
  );

  CanarySpeechService(this._apiKey);

  /// Envía el audio y devuelve el JSON decodificado
  Future<Map<String, dynamic>> analyzeAudio(File audioFile) async {
    final request =
        http.MultipartRequest('POST', _endpoint)
          ..headers['Authorization'] = 'Bearer $_apiKey'
          ..files.add(
            await http.MultipartFile.fromPath('file', audioFile.path),
          );

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Canary Speech error: ${response.statusCode}');
    }
    final body = await response.stream.bytesToString();
    return json.decode(body) as Map<String, dynamic>;
  }
}

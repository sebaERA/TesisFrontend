import 'dart:io';
import 'package:http/http.dart' as http;

class GCSUploadService {
  /// Solicita al backend una URL firmada para subir el archivo
  static Future<String> solicitarUrlFirmada(String nombreArchivo) async {
    final response = await http.post(
      Uri.parse('https://backendtesis-1044129606293.southamerica-west1.run.app/api/generar-url-audio'),
      headers: {'Content-Type': 'application/json'},
      body: '{"nombre_archivo": "$nombreArchivo"}',
    );

    if (response.statusCode == 200) {
      final url = Uri.parse(RegExp(r'"upload_url"\s*:\s*"([^"]+)"').firstMatch(response.body)!.group(1)!);
      return url.toString();
    } else {
      throw Exception('Error al solicitar URL firmada: ${response.body}');
    }
  }

  /// Sube el archivo WAV al bucket usando la URL firmada
  static Future<void> subirArchivoAUrlFirmada(String pathLocal, String urlFirmada) async {
    final audioBytes = await File(pathLocal).readAsBytes();

    final response = await http.put(
      Uri.parse(urlFirmada),
      headers: {'Content-Type': 'audio/wav'},
      body: audioBytes,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al subir archivo: ${response.statusCode}');
    }
  }
}
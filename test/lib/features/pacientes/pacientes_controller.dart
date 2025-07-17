import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pacientes/models/paciente.dart';
import '../evaluacion/models/resultado.dart';

class PacientesController {
  final _base = 'http://127.0.0.1:8000/pacientes';

  Future<List<Paciente>> obtenerPacientes() async {
    final r = await http.get(Uri.parse(_base));
    final list = json.decode(r.body) as List;
    return list.map((j) => Paciente.fromJson(j)).toList();
  }

  // Ya NO es necesario este método:
  // Future<Paciente> obtenerPaciente(String id) async { ... }

  Future<void> registrarConsentimiento(String id, bool consent) async {
    final r = await http.put(
      Uri.parse('http://127.0.0.1:8000/pacientes/$id/consentimiento'),
      headers: {'Content-Type': 'application/json'},
      body: consent.toString(), // Envía "true" o "false"
    );
    if (r.statusCode != 200) throw Exception('falló consentimiento');
  }

  Future<List<Resultado>> obtenerHistorial(String pacienteId) async {
    final url = 'http://127.0.0.1:8000/resultados/$pacienteId';
    final r = await http.get(Uri.parse(url));
    if (r.statusCode != 200) throw Exception('Error backend: ${r.statusCode}');
    final list = json.decode(r.body) as List;
    return list.map((j) => Resultado.fromJson(j)).toList();
  }

  Future<Paciente> obtenerPaciente(String id) async {
    final r = await http.get(Uri.parse('http://127.0.0.1:8000/pacientes/$id'));
    if (r.statusCode != 200) throw Exception('Error al obtener paciente');
    return Paciente.fromJson(json.decode(r.body));
  }
}

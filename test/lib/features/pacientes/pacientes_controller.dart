import 'dart:convert';
import 'package:http/http.dart' as http;
import '../pacientes/models/paciente.dart';
import '../evaluacion/models/resultado.dart';

class PacientesController {
  final _base = 'http://10.0.2.2:3000/pacientes'; // usar tu IP / dominio

  Future<List<Paciente>> obtenerPacientes() async {
    final r = await http.get(Uri.parse(_base));
    final list = json.decode(r.body) as List;
    return list.map((j) => Paciente.fromJson(j)).toList();
  }

  Future<Paciente> obtenerPaciente(String id) async {
    final r = await http.get(Uri.parse('$_base/$id'));
    return Paciente.fromJson(json.decode(r.body));
  }

  Future<void> registrarConsentimiento(String id, bool consent) async {
    final r = await http.patch(
      Uri.parse('$_base/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'consentimiento': consent}),
    );
    if (r.statusCode != 200) throw Exception('falló patch');
  }

  Future<List<Resultado>> obtenerHistorial(String id) async {
    final r = await http.get(Uri.parse('$_base/$id/historial'));
    final list = json.decode(r.body) as List;
    return list.map((j) => Resultado.fromJson(j)).toList();
  }
}

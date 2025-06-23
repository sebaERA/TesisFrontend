import 'models/paciente.dart';

class PacientesController {
  //simulacion de datos temrporales
  final List<Paciente> _pacientes = [
    Paciente(
      {},
      id: '1',
      nombre: '',
      edad: 0,
      sexo: '',
      cantidadEstadosEmocionales: 10,
      diagnosticoPrevio: false,
      usaMedicacion: false,
      adherencia: '',
      consentiemiento: false,
    ),
    Paciente(
      {},
      id: '2',
      nombre: '',
      edad: 0,
      sexo: '',
      cantidadEstadosEmocionales: 100,
      diagnosticoPrevio: false,
      usaMedicacion: false,
      adherencia: '',
      consentiemiento: false,
    ),
    Paciente(
      {},
      id: '3',
      nombre: '',
      edad: 0,
      sexo: '',
      cantidadEstadosEmocionales: 1000,
      diagnosticoPrevio: false,
      usaMedicacion: false,
      adherencia: '',
      consentiemiento: false,
    ),
  ];
  List<Paciente> obtenerPacientes() => _pacientes;

  Paciente obtenerPacientePorId(String id) =>
      _pacientes.firstWhere((p) => p.id == id);

  void registrarConsentimiento(String pacienteId) {
    final paciente = _pacientes.firstWhere((p) => p.id == pacienteId);
    paciente.consentiemiento = true;
  }
}

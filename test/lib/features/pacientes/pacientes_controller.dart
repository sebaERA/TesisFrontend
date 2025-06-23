import 'models/paciente.dart';

class PacientesController {
  //simulacion de datos temrporales
  final List<Paciente> _pacietes = [
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
    ),
  ];
  List<Paciente> obtenerPacientes() {
    return _pacietes;
  }
}

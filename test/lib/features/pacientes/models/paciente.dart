class Paciente {
  final String id;
  final String nombre;
  final int edad;
  final String sexo;
  final bool diagnosticoPrevio;
  final bool usaMedicacion;
  final String adherencia;
  final int cantidadEstadosEmocionales;

  Paciente(
    Map map, {
    required this.id,
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.diagnosticoPrevio,
    required this.usaMedicacion,
    required this.adherencia,
    required this.cantidadEstadosEmocionales,
  });
}

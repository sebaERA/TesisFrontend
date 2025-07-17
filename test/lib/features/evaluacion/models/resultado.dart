class Resultado {
  final int id; // Nuevo
  final DateTime fecha;
  final String texto;
  final String validacion;
  Resultado({
    required this.id,
    required this.fecha,
    required this.texto,
    required this.validacion,
  });
  factory Resultado.fromJson(Map<String, dynamic> j) => Resultado(
    id: j['idresultado'],
    fecha: DateTime.parse(j['fecha']),
    texto: j['resultado'], // <-- cambio aquí
    validacion: j['estado_validacion'],
  );
}

class Resultado {
  final DateTime fecha;
  final String texto;
  final String validacion;
  Resultado({
    required this.fecha,
    required this.texto,
    required this.validacion,
  });
  factory Resultado.fromJson(Map<String, dynamic> j) => Resultado(
    fecha: DateTime.parse(j['fecha']),
    texto: j['resultado_text'],
    validacion: j['estado_validacion'],
  );
}

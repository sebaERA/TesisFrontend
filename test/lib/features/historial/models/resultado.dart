class ResultadoEvaluacion {
  final String id;
  final String fecha;
  final String resultado;
  String estado; // se puede editar desde la app

  ResultadoEvaluacion({
    required this.id,
    required this.fecha,
    required this.resultado,
    required this.estado,
  });

  // Para convertir desde JSON (cuando conectes backend)
  factory ResultadoEvaluacion.fromJson(Map<String, dynamic> json) {
    return ResultadoEvaluacion(
      id: json['id'],
      fecha: json['fecha'],
      resultado: json['resultado'],
      estado: json['estado'],
    );
  }

  // Para enviar a backend (cuando se modifique el estado)
  Map<String, dynamic> toJson() => {
    'id': id,
    'fecha': fecha,
    'resultado': resultado,
    'estado': estado,
  };
}

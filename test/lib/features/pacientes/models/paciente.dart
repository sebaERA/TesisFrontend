class Paciente {
  final String id;
  final String nombre;
  final int edad;
  final String sexo;
  bool consentimiento;
  Paciente({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.sexo,
    required this.consentimiento,
  });
  factory Paciente.fromJson(Map<String, dynamic> j) => Paciente(
    id: j['idpacientes'].toString(),
    nombre: j['nombre'],
    edad: j['edad'],
    sexo: j['sexo'],
    consentimiento: j['consentimiento'],
  );
}

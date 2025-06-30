import 'package:flutter/material.dart';
import 'package:test/features/pacientes/pacientes_controller.dart';
import 'package:test/features/pacientes/ui/detalle_paciente_screen.dart';
import '../models/paciente.dart';
import 'consentimiento_screen.dart';

class PacientesScreen extends StatefulWidget {
  @override
  createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  late Future<List<Paciente>> _fut;
  @override
  void initState() {
    super.initState();
    _fut = PacientesController().obtenerPacientes();
  }

  @override
  Widget build(_) => Scaffold(
    appBar: AppBar(title: Text('Pacientes')),
    body: FutureBuilder<List<Paciente>>(
      future: _fut,
      builder: (c, s) {
        if (s.connectionState != ConnectionState.done)
          return Center(child: CircularProgressIndicator());
        if (s.hasError) return Center(child: Text('Error'));
        final list = s.data!;
        return ListView.builder(
          itemCount: list.length,
          itemBuilder: (_, i) {
            final p = list[i];
            return ListTile(
              title: Text(p.nombre),
              subtitle: Text('${p.edad} años • ${p.sexo}'),
              trailing: Icon(
                p.consentimiento ? Icons.check : Icons.close,
                color: p.consentimiento ? Colors.green : Colors.red,
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetallePacienteScreen(paciente: p),
                    ),
                  ).then(
                    (_) => setState(
                      () => _fut = PacientesController().obtenerPacientes(),
                    ),
                  ),
            );
          },
        );
      },
    ),
  );
}

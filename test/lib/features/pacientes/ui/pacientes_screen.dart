import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../../pacientes/pacientes_controller.dart';
import 'detalle_paciente_screen.dart';

class PacientesScreen extends StatelessWidget {
  const PacientesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PacientesController controller = PacientesController();
    final List<Paciente> pacientes = controller.obtenerPacientes();

    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Pacientes')),
      body: ListView.builder(
        itemCount: pacientes.length,
        itemBuilder: (context, index) {
          final paciente = pacientes[index];
          return Card(
            child: ListTile(
              title: Text(paciente.nombre),
              subtitle: Text(
                'id: ${paciente.id} Edad: ${paciente.edad} | Sexo: ${paciente.sexo}',
              ),
              trailing: Text(
                '${paciente.cantidadEstadosEmocionales} registros',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetallePacienteScreen(paciente: paciente),
                  ),
                );
                // Futuro: Navegar a ficha del paciente
              },
            ),
          );
        },
      ),
    );
  }
}

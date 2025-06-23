import 'package:flutter/material.dart';
import 'package:test/features/evaluacion/ui/grabacion_screen.dart';
import 'package:test/features/historial/ui/historial_detallado_screen.dart';
import 'package:test/features/pacientes/ui/consentimiento_screen.dart';
import '../models/paciente.dart';

class DetallePacienteScreen extends StatelessWidget {
  final Paciente paciente;

  const DetallePacienteScreen({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Paciente'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuración próximamente')),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(
                'assets/images/avatar.png',
              ), // Usa tu propia imagen
            ),
            const SizedBox(height: 16),
            Text(
              paciente.nombre,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text('${paciente.edad} años • ${paciente.sexo}'),
            const SizedBox(height: 16),
            Text(
              'Diagnóstico Previo Validado: ${paciente.diagnosticoPrevio ? "Sí" : "No"}',
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Medicamentos:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '• Usa medicamentos: ${paciente.usaMedicacion ? "Sí" : "No"}',
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('• Adherencia: ${paciente.adherencia}'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Historial de Evaluaciones Emocionales',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child:
                  Placeholder(), // Puedes reemplazar con un gráfico real más adelante
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Iniciar grabación próximamente'),
                  ),
                );
              },
              child: const Text('Iniciar Grabación de Voz'),
            ),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ver consentimiento próximamente'),
                  ),
                );
              },
              child: const Text('Ver Consentimiento'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrabacionScreen(paciente: paciente),
                  ),
                );
              },
              child: const Text('Iniciar Grabación de Voz'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConsentimientoScreen(paciente: paciente),
                  ),
                );
              },
              child: const Text('Ver Consentimiento'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => HistorialDetalladoScreen(paciente: paciente),
                  ),
                );
              },
              child: const Text('Gestionar Historial Emocional'),
            ),
          ],
        ),
      ),
    );
  }
}

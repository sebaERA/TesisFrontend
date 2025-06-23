import 'package:flutter/material.dart';
import '../../pacientes/models/paciente.dart';
import '../models/resultado.dart';
import '../historial_controller.dart';
import 'detalle_resultado_screen.dart';

class HistorialDetalladoScreen extends StatelessWidget {
  final Paciente paciente;

  const HistorialDetalladoScreen({super.key, required this.paciente});

  @override
  Widget build(BuildContext context) {
    final historial = HistorialController.obtenerHistorialPorPaciente(
      paciente.id,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Historial Emocional')),
      body: ListView.builder(
        itemCount: historial.length,
        itemBuilder: (context, index) {
          final resultado = historial[index];
          return ListTile(
            title: Text(resultado.resultado),
            subtitle: Text('Fecha: ${resultado.fecha}'),
            trailing: Text(resultado.estado.toUpperCase()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetalleResultadoScreen(resultado: resultado),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

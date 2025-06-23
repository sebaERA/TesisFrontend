import 'package:flutter/material.dart';
import '../models/resultado.dart';
import '../historial_controller.dart';

class DetalleResultadoScreen extends StatefulWidget {
  final ResultadoEvaluacion resultado;

  const DetalleResultadoScreen({super.key, required this.resultado});

  @override
  State<DetalleResultadoScreen> createState() => _DetalleResultadoScreenState();
}

class _DetalleResultadoScreenState extends State<DetalleResultadoScreen> {
  late String estadoActual;

  @override
  void initState() {
    super.initState();
    estadoActual = widget.resultado.estado;
  }

  void actualizarEstado(String nuevoEstado) {
    setState(() {
      estadoActual = nuevoEstado;
      HistorialController.actualizarEstado(widget.resultado, nuevoEstado);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Estado actualizado a "$nuevoEstado"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('Fecha: ${widget.resultado.fecha}'),
            const SizedBox(height: 10),
            Text('Resultado: ${widget.resultado.resultado}'),
            const SizedBox(height: 20),
            const Text('Validación del diagnóstico:'),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: estadoActual,
              items: const [
                DropdownMenuItem(value: 'aprobado', child: Text('Aprobado')),
                DropdownMenuItem(value: 'rechazado', child: Text('Rechazado')),
                DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
              ],
              onChanged: (value) {
                if (value != null) {
                  actualizarEstado(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

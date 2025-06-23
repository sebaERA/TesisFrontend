import 'package:flutter/material.dart';
import '../../pacientes/models/paciente.dart';

class GrabacionScreen extends StatefulWidget {
  final Paciente paciente;

  const GrabacionScreen({super.key, required this.paciente});

  @override
  State<GrabacionScreen> createState() => _GrabacionScreenState();
}

class _GrabacionScreenState extends State<GrabacionScreen> {
  bool estaGrabando = false;
  bool resultadoObtenido = false;
  String resultado = '';
  bool mostrarAprobacion = false;
  String veredicto = '';

  void iniciarGrabacion() {
    setState(() {
      estaGrabando = true;
      resultadoObtenido = false;
    });

    // Simula grabación y análisis
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        estaGrabando = false;
        resultadoObtenido = true;
        resultado = 'Depresión leve detectada'; // Mock
        mostrarAprobacion = true; // Supongamos que el operador es especialista
      });
    });
  }

  void aprobarResultado(String valor) {
    setState(() {
      veredicto = valor;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Resultado $valor registrado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grabación de Voz')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Paciente: ${widget.paciente.nombre}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            estaGrabando
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                  onPressed: iniciarGrabacion,
                  icon: const Icon(Icons.mic),
                  label: const Text('Iniciar Grabación'),
                ),
            const SizedBox(height: 30),
            if (resultadoObtenido) ...[
              const Text('Resultado del análisis:'),
              Text(
                resultado,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (mostrarAprobacion) ...[
              const Text('¿Aprueba este resultado?'),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => aprobarResultado('aprobado'),
                    child: const Text('Sí'),
                  ),
                  const SizedBox(width: 20),
                  OutlinedButton(
                    onPressed: () => aprobarResultado('rechazado'),
                    child: const Text('No'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

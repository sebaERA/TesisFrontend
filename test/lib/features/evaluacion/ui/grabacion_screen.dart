import 'package:flutter/material.dart';
import '../../pacientes/models/paciente.dart';
import '../../pacientes/ui/consentimiento_screen.dart';

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

  Future<void> iniciarGrabacion() async {
    if (!widget.paciente.consentiemiento) {
      final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConsentimientoScreen(paciente: widget.paciente),
        ),
      );

      if (resultado != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se puede grabar sin consentimiento.'),
          ),
        );
        return;
      }
    }

    setState(() {
      estaGrabando = true;
      resultadoObtenido = false;
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        estaGrabando = false;
        resultadoObtenido = true;
        resultado = 'Depresión leve detectada'; // Simulado
        mostrarAprobacion = true;
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

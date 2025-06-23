import 'package:flutter/material.dart';
import '../models/paciente.dart';

class ConsentimientoScreen extends StatefulWidget {
  final Paciente paciente;

  const ConsentimientoScreen({super.key, required this.paciente});

  @override
  State<ConsentimientoScreen> createState() => _ConsentimientoScreenState();
}

class _ConsentimientoScreenState extends State<ConsentimientoScreen> {
  bool consentimientoOtorgado = false;

  void otorgarConsentimiento() {
    setState(() {
      consentimientoOtorgado = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consentimiento registrado correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consentimiento Informado')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Consentimiento Informado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Este consentimiento permite registrar y analizar la voz del paciente para detectar síntomas de depresión. No se almacenará información personal identificable y los resultados se mantendrán confidenciales.',
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 20),
            CheckboxListTile(
              value: consentimientoOtorgado,
              onChanged: (value) {
                if (value == true) otorgarConsentimiento();
              },
              title: const Text(
                'Confirmo que el paciente ha otorgado el consentimiento.',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  consentimientoOtorgado
                      ? () {
                        widget.paciente.consentiemiento = true;
                        Navigator.pop(context, true); // ← devuelve true
                      }
                      : null,
              child: const Text('Aceptar'),
            ),
          ],
        ),
      ),
    );
  }
}

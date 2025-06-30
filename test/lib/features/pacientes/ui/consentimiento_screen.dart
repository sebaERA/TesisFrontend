import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../pacientes_controller.dart';

class ConsentimientoScreen extends StatefulWidget {
  final Paciente paciente;
  const ConsentimientoScreen({required this.paciente});
  @override
  createState() => _ConsentimientoScreenState();
}

class _ConsentimientoScreenState extends State<ConsentimientoScreen> {
  bool _busy = false, _agreed = false;
  @override
  Widget build(_) => Scaffold(
    appBar: AppBar(title: Text('Consentimiento')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consentimiento Informado',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Se solicita permiso para grabar y analizar la voz...',
            textAlign: TextAlign.justify,
          ),
          SizedBox(height: 24),
          if (!widget.paciente.consentimiento) ...[
            CheckboxListTile(
              title: Text('Otorgar consentimiento'),
              value: _agreed,
              onChanged: (v) => setState(() => _agreed = v!),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed:
                  _agreed && !_busy
                      ? () async {
                        setState(() => _busy = true);
                        await PacientesController().registrarConsentimiento(
                          widget.paciente.id,
                          true,
                        );
                        Navigator.pop(context, true);
                      }
                      : null,
              child:
                  _busy
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Aceptar'),
            ),
          ] else
            Center(
              child: Text(
                'Ya otorgó consentimiento',
                style: TextStyle(color: Colors.grey),
              ),
            ),
        ],
      ),
    ),
  );
}

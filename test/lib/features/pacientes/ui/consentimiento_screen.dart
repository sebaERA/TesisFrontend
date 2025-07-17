import 'package:flutter/material.dart';
import '../models/paciente.dart';
import '../pacientes_controller.dart';

class ConsentimientoScreen extends StatefulWidget {
  final Paciente paciente;
  const ConsentimientoScreen({required this.paciente, super.key});

  @override
  State<ConsentimientoScreen> createState() => _ConsentimientoScreenState();
}

class _ConsentimientoScreenState extends State<ConsentimientoScreen> {
  bool _consent = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _consent = widget.paciente.consentimiento;
  }

  Future<void> _guardar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await PacientesController().registrarConsentimiento(
        widget.paciente.id,
        _consent,
      );
      if (!mounted) return;
      Navigator.pop(context, true); // Retorna true para refrescar
    } catch (e) {
      setState(() {
        _error = 'Error al guardar consentimiento';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Consentimiento')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consentimiento Informado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Se solicita permiso para grabar y analizar la voz...'),
            SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: _consent,
                  onChanged: (v) {
                    setState(() => _consent = v!);
                  },
                ),
                Text(
                  _consent
                      ? 'Consentimiento otorgado'
                      : 'Consentimiento NO otorgado',
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: Colors.red)),
              SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: _loading ? null : _guardar,
              child:
                  _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

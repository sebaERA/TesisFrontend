// lib/features/pacientes/ui/detalle_paciente_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:test/features/evaluacion/models/resultado.dart';
import 'package:test/features/pacientes/pacientes_controller.dart';
import '../../evaluacion/ui/grabacion_screen.dart';
import '../../pacientes/ui/consentimiento_screen.dart';
import '../../historial/ui/historial_detallado_screen.dart';
import '../models/paciente.dart';

import 'package:fl_chart/fl_chart.dart';

class DetallePacienteScreen extends StatefulWidget {
  final Paciente paciente;
  const DetallePacienteScreen({required this.paciente});
  @override
  createState() => _DetallePacienteScreenState();
}

class _DetallePacienteScreenState extends State<DetallePacienteScreen> {
  late Paciente _p;
  List<Resultado> _hist = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _p = widget.paciente;
    _loadData();
  }

  Future<void> _loadData() async {
    final fresh = await PacientesController().obtenerPaciente(_p.id);
    final hist = await PacientesController().obtenerHistorial(_p.id);
    setState(() => _p = fresh);
    setState(() => _hist = hist);
    setState(() => _loading = false);
  }

  @override
  Widget build(_) => Scaffold(
    appBar: AppBar(title: Text(_p.nombre)),
    body:
        _loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/avatar.png'),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _p.nombre,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('${_p.edad} • ${_p.sexo}'),
                        ],
                      ),
                      Spacer(),
                      Icon(
                        _p.consentimiento ? Icons.check_circle : Icons.help,
                        color: _p.consentimiento ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Depresión en el tiempo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 200, child: _buildChart()),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        GrabacionRealScreen(paciente: _p),
                              ),
                            ).then((_) => _loadData()),
                        child: Text('Iniciar'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ConsentimientoScreen(paciente: _p),
                              ),
                            ).then((granted) {
                              if (granted == true) _loadData();
                            }),
                        child: Text('Consentimiento'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
  );

  Widget _buildChart() {
    if (_hist.isEmpty) return Center(child: Text('Sin datos'));
    final spots = List.generate(_hist.length, (i) {
      return FlSpot(i.toDouble(), i.toDouble()); // mock: usa tu lógica
    });
    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(show: false),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}

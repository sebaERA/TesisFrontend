import 'package:flutter/material.dart';
import 'package:test/features/pacientes/models/paciente.dart';
import 'package:test/features/pacientes/pacientes_controller.dart';
import 'package:test/features/evaluacion/models/resultado.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../evaluacion/ui/grabacion_screen.dart';
import '../../pacientes/ui/consentimiento_screen.dart';

class DetallePacienteScreen extends StatefulWidget {
  final Paciente paciente;
  const DetallePacienteScreen({required this.paciente, super.key});

  @override
  State<DetallePacienteScreen> createState() => _DetallePacienteScreenState();
}

class _DetallePacienteScreenState extends State<DetallePacienteScreen> {
  late Future<List<Resultado>> _historialFut;

  // Estado para filtros
  DateTime? _desde, _hasta;
  String? _filtroResultado;

  @override
  void initState() {
    super.initState();
    _historialFut = PacientesController().obtenerHistorial(widget.paciente.id);
  }

  void _refresh() {
    setState(() {
      _historialFut = PacientesController().obtenerHistorial(
        widget.paciente.id,
      );
    });
  }

  // Helper para nombres de meses
  String _nombreMes(int mes) {
    const nombres = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return nombres[mes];
  }

  // Helper para etiqueta de score
  String scoreLabel(double score) {
    if (score >= 3) return "Alto";
    if (score >= 2) return "Medio";
    return "Bajo";
  }

  // Extrae el score del texto
  double _getDepressionScore(Resultado r) {
    final match = RegExp(
      r'Depression_Mapped_Overall:\s*(\d+)',
    ).firstMatch(r.texto);
    if (match != null) return double.parse(match.group(1)!);
    return 0.0;
  }

  // Filtrado por fecha y resultado
  List<Resultado> _filtrarResultados(List<Resultado> base) {
    return base.where((r) {
      bool ok = true;
      if (_desde != null)
        ok &= r.fecha.isAfter(_desde!.subtract(Duration(days: 1)));
      if (_hasta != null)
        ok &= r.fecha.isBefore(_hasta!.add(Duration(days: 1)));
      if (_filtroResultado != null && _filtroResultado!.isNotEmpty) {
        ok &= r.texto.toLowerCase().contains(_filtroResultado!.toLowerCase());
      }
      return ok;
    }).toList();
  }

  // Cálculo del número de semana del mes
  int _semanaDelMes(DateTime fecha) {
    final primerDiaMes = DateTime(fecha.year, fecha.month, 1);
    return ((fecha.day + primerDiaMes.weekday - 2) / 7).floor() + 1;
  }

  // Título dinámico para el gráfico según el rango
  String? _tituloGrafico() {
    if (_desde == null || _hasta == null) return null;

    final inicio = _desde!;
    final fin = _hasta!;
    final diff = fin.difference(inicio);

    if (diff.inDays > 30) {
      // Mensual
      return 'Mes: ${_nombreMes(inicio.month)} ${inicio.year}';
    }
    if (diff.inDays > 7) {
      // Semanal
      final week1 = _semanaDelMes(inicio);
      final week2 = _semanaDelMes(fin);
      if (week1 == week2) {
        return 'Semana $week1 de ${_nombreMes(inicio.month)} ${inicio.year}';
      }
      return 'Semanas $week1–$week2 de ${_nombreMes(inicio.month)} ${inicio.year}';
    }
    // Diario
    return 'Días de ${_nombreMes(inicio.month)} ${inicio.year}';
  }

  // El gráfico adaptativo
  Widget _buildChart(List<Resultado> hist) {
    final filtrado = _filtrarResultados(hist);
    if (filtrado.isEmpty) return Center(child: Text('Sin datos'));

    // Detecta rango de fechas:
    Duration? rango;
    if (_desde != null && _hasta != null) {
      rango = _hasta!.difference(_desde!);
    }

    // Mapear scores a double para el gráfico
    final spots = List.generate(filtrado.length, (i) {
      return FlSpot(i.toDouble(), _getDepressionScore(filtrado[i]));
    });

    // Eje Y: Mostrar etiquetas bajo/medio/alto
    SideTitles leftTitles = SideTitles(
      showTitles: true,
      interval: 1,
      getTitlesWidget: (value, meta) {
        return Text(scoreLabel(value), style: TextStyle(fontSize: 10));
      },
    );

    // Eje X: días/semanas/meses (sin los flotantes arriba)
    SideTitles bottomTitles = SideTitles(
      showTitles: true,
      interval: 1,
      getTitlesWidget: (value, meta) {
        int idx = value.round();
        if (idx < 0 || idx >= filtrado.length) return Text('');
        final fecha = filtrado[idx].fecha;

        // Si rango > 30 días → mes
        if (rango != null && rango.inDays > 30) {
          return Text(_nombreMes(fecha.month), style: TextStyle(fontSize: 10));
        }
        // Si rango > 7 días → semana
        if (rango != null && rango.inDays > 7) {
          int semana = ((fecha.difference(_desde!).inDays) / 7).floor() + 1;
          return Text('Semana $semana', style: TextStyle(fontSize: 10));
        }
        // Si rango <= 7 días → día
        return Text('Día ${idx + 1}', style: TextStyle(fontSize: 10));
      },
    );

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: bottomTitles),
          leftTitles: AxisTitles(sideTitles: leftTitles),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.paciente.nombre)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con avatar y datos principales
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
                      widget.paciente.nombre,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('${widget.paciente.edad} • ${widget.paciente.sexo}'),
                  ],
                ),
                Spacer(),
                Icon(
                  widget.paciente.consentimiento
                      ? Icons.check_circle
                      : Icons.help,
                  color:
                      widget.paciente.consentimiento
                          ? Colors.green
                          : Colors.orange,
                ),
              ],
            ),
            SizedBox(height: 24),
            // UI para filtros
            Row(
              children: [
                Text("Desde:"),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _desde ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _desde = picked);
                  },
                  child: Text(
                    _desde != null
                        ? _desde!.toLocal().toString().split(' ')[0]
                        : 'Todas',
                  ),
                ),
                SizedBox(width: 10),
                Text("Hasta:"),
                TextButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _hasta ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _hasta = picked);
                  },
                  child: Text(
                    _hasta != null
                        ? _hasta!.toLocal().toString().split(' ')[0]
                        : 'Todas',
                  ),
                ),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filtroResultado,
                  hint: Text("Resultado"),
                  items: [
                    DropdownMenuItem(value: "", child: Text("Todos")),
                    DropdownMenuItem(value: "media", child: Text("Media")),
                    DropdownMenuItem(value: "alta", child: Text("Alta")),
                    DropdownMenuItem(value: "baja", child: Text("Baja")),
                  ],
                  onChanged: (v) => setState(() => _filtroResultado = v),
                ),
              ],
            ),
            SizedBox(height: 10),
            if (_tituloGrafico() != null) ...[
              Text(
                _tituloGrafico()!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 6),
            ],
            Text(
              'Depresión en el tiempo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Resultado>>(
                future: _historialFut,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done)
                    return Center(child: CircularProgressIndicator());
                  if (snap.hasError)
                    return Center(child: Text('Error al cargar historial'));
                  return _buildChart(snap.data!);
                },
              ),
            ),
            SizedBox(height: 24),
            // Listado de resultados filtrados
            Text(
              'Historial de resultados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Resultado>>(
                future: _historialFut,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done)
                    return Center(child: CircularProgressIndicator());
                  if (snap.hasError)
                    return Center(child: Text('Error al cargar historial'));
                  final hist = _filtrarResultados(snap.data!);
                  if (hist.isEmpty) return Center(child: Text('Sin datos'));
                  return ListView.builder(
                    itemCount: hist.length,
                    itemBuilder: (context, i) {
                      final r = hist[i];
                      return ListTile(
                        title: Text('Score: ${_getDepressionScore(r)}'),
                        subtitle: Text(
                          '${r.fecha.toLocal().toString().split(".")[0]}\n${r.texto.substring(0, r.texto.length > 40 ? 40 : r.texto.length)}...',
                        ),
                        trailing: Text(r.validacion),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Trae el paciente actualizado del backend
                    try {
                      final pacienteActualizado = await PacientesController()
                          .obtenerPaciente(widget.paciente.id);
                      if (!pacienteActualizado.consentimiento) {
                        // Si no tiene consentimiento, muestra mensaje
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Primero debes otorgar el consentimiento',
                            ),
                          ),
                        );
                        return;
                      }
                      // Si tiene consentimiento, abre la grabación
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GrabacionRealScreen(
                                paciente: pacienteActualizado,
                              ),
                        ),
                      ).then((_) => _refresh());
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'No se pudo verificar el consentimiento',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Iniciar'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ConsentimientoScreen(
                                paciente: widget.paciente,
                              ),
                        ),
                      ).then((granted) {
                        if (granted == true) _refresh();
                      }),
                  child: Text('Consentimiento'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

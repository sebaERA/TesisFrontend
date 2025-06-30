import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmocionesDashboard extends StatelessWidget {
  /// Recibe la lista de resultados (o timestamps / valores decibel) de tu paciente
  final List<double> valores;

  const EmocionesDashboard({super.key, required this.valores});

  @override
  Widget build(BuildContext context) {
    if (valores.isEmpty) {
      return Center(child: Text("Sin datos para mostrar"));
    }

    final spots = List.generate(
      valores.length,
      (i) => FlSpot(i.toDouble(), valores[i]),
    );

    return LineChart(
      LineChartData(
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

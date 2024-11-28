import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_service.dart';


class BarChartWidget extends StatelessWidget {
  final List<ClienteMaisComprou> clientesMaisCompraram;

  const BarChartWidget({Key? key, required this.clientesMaisCompraram}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: clientesMaisCompraram.isEmpty
          ? const Center(child: Text("Sem dados para exibir no gráfico."))
          : BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: clientesMaisCompraram.map((c) => c.totalCompras).reduce((a, b) => a > b ? a : b) * 1.2,
          barGroups: clientesMaisCompraram.asMap().entries.map((entry) {
            final index = entry.key;
            final cliente = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: cliente.totalCompras,
                  color: Colors.blue,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= clientesMaisCompraram.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      clientesMaisCompraram[value.toInt()].razaoCliente,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

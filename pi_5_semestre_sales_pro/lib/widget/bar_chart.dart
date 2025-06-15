import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_service.dart';

class BarChartWidget extends StatelessWidget {
  final List<ClienteMaisComprou> clientesMaisCompraram;

  const BarChartWidget({super.key, required this.clientesMaisCompraram, required topRegioes});

  @override
  Widget build(BuildContext context) {
    if (clientesMaisCompraram.isEmpty) {
      return const Center(child: Text("Sem dados para exibir no gráfico.", style: TextStyle(color: Colors.white)));
    }

    final maxY = clientesMaisCompraram
        .map((c) => c.totalCompras)
        .reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 350,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: maxY * 1.2,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.black87,
              tooltipPadding: const EdgeInsets.all(8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final cliente = clientesMaisCompraram[group.x.toInt()].razaoCliente;
                final valor = clientesMaisCompraram[group.x.toInt()].totalCompras.toStringAsFixed(2);
                return BarTooltipItem(
                  '$cliente\nCompras: R\$ $valor',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          barGroups: clientesMaisCompraram.asMap().entries.map((entry) {
            final index = entry.key;
            final cliente = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  fromY: 0,
                  toY: cliente.totalCompras,
                  color: Colors.blueAccent,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                interval: (maxY / 4).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$ ${value.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= clientesMaisCompraram.length) {
                    return const SizedBox.shrink();
                  }

                  final nome = clientesMaisCompraram[index].razaoCliente;
                  final nomeCurto = nome.length > 10 ? '${nome.substring(0, 10)}…' : nome;

                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        nomeCurto,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}

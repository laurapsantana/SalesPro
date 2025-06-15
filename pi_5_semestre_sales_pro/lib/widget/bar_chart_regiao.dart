import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../screen/home_dashboard_page.dart';

class BarChartWidgetRegiao extends StatelessWidget {
  final List<RegiaoVenda> cidade;

  const BarChartWidgetRegiao({super.key, required this.cidade});

  @override
  Widget build(BuildContext context) {
    if (cidade.isEmpty) {
      return const Center(child: Text("Sem dados", style: TextStyle(color: Colors.white)));
    }

    final maxY = cidade.map((e) => e.totalVendas).reduce((a, b) => a > b ? a : b);
    final interval = (maxY / 4).ceilToDouble(); // para espaçar bem os valores no eixo Y

    return BarChart(
      BarChartData(
        maxY: maxY * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${cidade[groupIndex].nomeCidade}\n'
                    'R\$ ${cidade[groupIndex].totalVendas.toStringAsFixed(2)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: interval,
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
                final index = value.toInt();
                if (index < 0 || index >= cidade.length) return const SizedBox.shrink();
                final nome = cidade[index].nomeCidade;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      nome.length > 10 ? '${nome.substring(0, 10)}…' : nome,
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
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(cidade.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: cidade[index].totalVendas,
                width: 16,
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [Colors.deepOrangeAccent, Colors.orange],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}

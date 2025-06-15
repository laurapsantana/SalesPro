import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';

class RecomendacoesBarChart extends StatelessWidget {
  final List<ProdutoRecomendado> recomendacoes;

  const RecomendacoesBarChart({super.key, required this.recomendacoes});

  Color _corPorProbabilidade(double prob) {
    if (prob >= 70) return Colors.green;
    if (prob >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final double maxY = recomendacoes.map((e) => e.probabilidade).reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= recomendacoes.length) return const SizedBox.shrink();
                  return Text(
                    recomendacoes[index].descricaoProduto.length > 6
                        ? recomendacoes[index].descricaoProduto.substring(0, 6)
                        : recomendacoes[index].descricaoProduto,
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(recomendacoes.length, (index) {
            final item = recomendacoes[index];
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.probabilidade,
                  color: _corPorProbabilidade(item.probabilidade),
                  width: 18,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

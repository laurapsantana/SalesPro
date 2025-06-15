import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VendasPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> topCities; // Cidades
  final List<double> values; // Valores de vendas

  const VendasPieChart({super.key, required this.topCities, required this.values});

  @override
  State<VendasPieChart> createState() => _VendasPieChartState();
}

class _VendasPieChartState extends State<VendasPieChart> {
  final List<Color> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.cyan,
  ];

  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    double total = widget.values.fold(0.0, (a, b) => a + b);
    final topData = widget.topCities.length > 5 ? widget.topCities.sublist(0, 5) : widget.topCities;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gráfico de Pizza
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions || response == null || response.touchedSection == null) {
                      touchedIndex = null;
                      return;
                    }
                    touchedIndex = response.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: List.generate(topData.length, (index) {
                final value = widget.values[index];
                final percentage = total == 0 ? 0 : (value / total) * 100;
                final isTouched = index == touchedIndex;

                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: value,
                  title: '${percentage.toStringAsFixed(1)}%',
                  radius: isTouched ? 60 : 50,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Legenda Lateral (cores + nome das cidades)
        Expanded(
          flex: 2,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: topData.length,
            itemBuilder: (context, index) {
              final cidadeNome = topData[index]['cidade'] ?? 'Cidade desconhecida';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      color: colors[index % colors.length],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cidadeNome,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

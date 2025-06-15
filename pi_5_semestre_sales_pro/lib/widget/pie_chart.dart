import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> topProducts;
  final List<double> values;

  const PieChartWidget({
    super.key,
    required this.topProducts,
    required this.values,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
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

  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double radius = screenWidth * 0.15;
    double fontSize = screenWidth * 0.035;

    double total = widget.values.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gráfico de Pizza
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 1,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        setState(() => touchedIndex = -1);
                        return;
                      }
                      setState(() => touchedIndex = response.touchedSection!.touchedSectionIndex);
                    },
                  ),
                  sections: _buildSections(radius, fontSize),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Legenda ao lado
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.topProducts.length, (index) {
                final produto = widget.topProducts[index];
                final cor = colors[index % colors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: cor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          produto['descricao_produto'],
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }


  List<PieChartSectionData> _buildSections(double radius, double fontSize) {
    double total = widget.values.fold(0.0, (a, b) => a + b);

    return List.generate(widget.topProducts.length, (i) {
      if (i >= widget.values.length ||
          i >= widget.topProducts.length ||
          total == 0) {
        return PieChartSectionData();
      }

      final value = widget.values[i];
      final percent = _formatPercent(value, total);

      return PieChartSectionData(
        color: colors[i % colors.length],
        value: value,
        title: percent,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: touchedIndex == i ? radius + 10 : radius,
      );
    });
  }

  String _formatPercent(double value, double total) {
    if (total == 0) return '0%';
    return '${((value / total) * 100).toStringAsFixed(1)}%';
  }
}

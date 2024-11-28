import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> topProducts;
  final List<double> values;

  PieChartWidget({required this.topProducts, required this.values});

  @override
  _PieChartWidgetState createState() => _PieChartWidgetState();
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

  double radius = 80.0;
  double fontSize = 14.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: showingSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> sections = [];

    for (int i = 0; i < widget.topProducts.length; i++) {
      // Certifique-se de que o índice não ultrapasse o número de dados
      if (i >= widget.values.length) break;

      sections.add(PieChartSectionData(
        color: colors[i % colors.length],  // Cor para cada seção
        value: widget.values[i], // O valor que será exibido na seção
        title: '${widget.values[i].toStringAsFixed(1)}%', // Exibe o valor com uma casa decimal
        radius: radius, // Raio do gráfico
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Cor do título
        ),
        badgeWidget: _buildBadgeWidget(i),
      ));
    }

    return sections;
  }

  // Método para construir o badge de cada seção, exibindo o nome do produto
  Widget _buildBadgeWidget(int i) {
    // Verifica se há dados para exibir o nome do produto
    String produtoNome = widget.topProducts[i]['descricao_produto'] ?? 'Produto desconhecido';
    return Container(
      padding: EdgeInsets.all(4),
      color: Colors.white.withOpacity(0.6),
      child: Text(
        produtoNome,
        style: TextStyle(color: Colors.black),
      ),
    );
  }
}

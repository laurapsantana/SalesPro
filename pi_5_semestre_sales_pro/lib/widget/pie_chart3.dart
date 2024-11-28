import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class VendasPieChart extends StatefulWidget {
  final List<Map<String, dynamic>> topCities; // Cidades
  final List<double> values; // Valores de vendas

  VendasPieChart({required this.topCities, required this.values});

  @override
  _VendasPieChartState createState() => _VendasPieChartState();
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

  double radius = 50.0;  // Tamanho das fatias
  double fontSize = 12.0; // Tamanho da fonte para as porcentagens

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Gráfico de Pizza
          PieChart(
            PieChartData(
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40, // Espaço no centro do gráfico
              sections: showingSections(),
            ),
          ),
          const SizedBox(height: 16),

          // Legenda com o nome das cidades
          Column(
            children: widget.topCities.asMap().entries.map((entry) {
              int index = entry.key;
              String cidadeNome = widget.topCities[index]['cidade'] ?? 'Cidade desconhecida';
              return Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    color: colors[index % colors.length], // Cor da cidade
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cidadeNome,
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Lista com as cidades que mais venderam
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.topCities.length,
              itemBuilder: (context, index) {
                String cidadeNome = widget.topCities[index]['cidade'] ?? 'Cidade desconhecida';
                double vendas = widget.values[index];
                return ListTile(
                  title: Text(cidadeNome),
                  trailing: Text('${vendas.toStringAsFixed(1)}%'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Função para gerar as fatias do gráfico
  List<PieChartSectionData> showingSections() {
    List<PieChartSectionData> sections = [];

    for (int i = 0; i < widget.topCities.length; i++) {
      // Certifique-se de que o índice não ultrapasse o número de dados
      if (i >= widget.values.length) break;

      sections.add(PieChartSectionData(
        color: colors[i % colors.length], // Cor para cada seção
        value: widget.values[i], // O valor das vendas que será exibido na seção
        title: '${widget.values[i].toStringAsFixed(1)}%', // Exibe o valor com uma casa decimal
        radius: radius, // Raio do gráfico
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Cor do título
        ),
      ));
    }

    return sections;
  }
}

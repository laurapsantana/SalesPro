
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BarChartSample2 extends StatefulWidget {
  final List<dynamic> data;

  BarChartSample2({Key? key, required this.data}) : super(key: key);

  final Color leftBarColor = const Color(0xff53fdd7);

  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final double width = 7;
  late List<BarChartGroupData> rawBarGroups;

  @override
  void didUpdateWidget(BarChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _prepareChartData();
    }
  }

  @override
  void initState() {
    super.initState();
    _prepareChartData();
  }

  void _prepareChartData() {
    rawBarGroups = widget.data.asMap().entries.map((entry) {
      int index = entry.key;
      var product = entry.value;
      double yValue = product['total_vendas']?.toDouble() ?? 0; // Total de vendas do produto

      return makeGroupData(index, yValue); // Uma barra para cada produto
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Produtos mais Vendidos',
                style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 38),
              Expanded(
                child: BarChart(
                  BarChartData(
                    maxY: widget.data.isNotEmpty
                        ? widget.data.map((p) => p['total_vendas']).reduce((a, b) => a > b ? a : b) * 1.1
                        : 10,
                    barGroups: rawBarGroups,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            int index = value.toInt();
                            if (index < widget.data.length) {
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: Text(
                                  widget.data[index]['descricao_produto'].toString().substring(0, 6), // Limite a 6 caracteres
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          },
                          reservedSize: 42,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            return Text('${value.toInt()}', style: TextStyle(color: Colors.black));
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(toY: y, color: widget.leftBarColor, width: width),
      ],
    );
  }
}

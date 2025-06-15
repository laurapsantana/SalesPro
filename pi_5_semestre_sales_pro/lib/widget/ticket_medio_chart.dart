import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_service.dart';

class TicketMedioChart extends StatefulWidget {
  final List<TicketMedio> data;

  const TicketMedioChart({Key? key, required this.data}) : super(key: key);

  @override
  State<TicketMedioChart> createState() => _TicketMedioChartState();
}

class _TicketMedioChartState extends State<TicketMedioChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final topData = widget.data.length > 5 ? widget.data.sublist(0, 5) : widget.data;

    final maxTicketMedio = topData.map((e) => e.ticketMedio).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Top 5 Clientes por Ticket Médio',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxTicketMedio * 1.3, // margem maior no topo para não cortar barras
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final cliente = topData[group.x.toInt()].cliente;
                    final ticket = topData[group.x.toInt()].ticketMedio.toStringAsFixed(2);
                    return BarTooltipItem(
                      '$cliente\n',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Ticket Médio: R\$ $ticket',
                          style: const TextStyle(
                            color: Colors.amberAccent,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                touchCallback: (event, response) {
                  setState(() {
                    if (!event.isInterestedForInteractions || response == null || response.spot == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = response.spot!.touchedBarGroupIndex;
                  });
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= topData.length) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SizedBox(
                          width: 60,
                          child: Text(
                            topData[index].cliente,
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // espaço maior para os títulos do eixo Y
                    interval: maxTicketMedio / 5, // divide eixo em 5 partes (ajuste se quiser)
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(show: true),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(topData.length, (index) {
                final ticket = topData[index].ticketMedio;
                final isTouched = index == touchedIndex;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: ticket,
                      gradient: LinearGradient(
                        colors: isTouched
                            ? [Colors.orangeAccent, Colors.deepOrange]
                            : [Colors.lightBlueAccent, Colors.blue],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      width: isTouched ? 22 : 18,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

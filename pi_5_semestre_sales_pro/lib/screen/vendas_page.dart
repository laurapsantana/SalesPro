import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../widget/pie_chart3.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});

  @override
  State<VendasPage> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  List<Map<String, dynamic>> chartData = [];
  List<Map<String, dynamic>> allCitiesData = [];
  int touchedIndex = -1;
  bool isLoading = true;
  String errorMessage = "";
  String selectedMonth = '01';
  String filtroCidade = "";

  final List<String> months = ['01', '02', '03', '04', '05', '06', '07', '08', '09'];

  @override
  void initState() {
    super.initState();
    fetchCidadesMaisVenderam(selectedMonth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Text("Painel de Vendas",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo[800],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : RefreshIndicator(
        onRefresh: () => fetchCidadesMaisVenderam(selectedMonth),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMonthSelectorCard(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'Distribuição de Vendas',
                child: _buildPieChart(),
              ),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'Gráfico Comparativo',
                child: _buildBarChart(),
              ),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 8),
              _buildCityListCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchCidadesMaisVenderam(String mes) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      ApiService apiService = ApiService();
      var response = await apiService.fetchCidadesMaisVenderam(int.parse(mes));
      setState(() {
        chartData = response.take(4).toList();
        allCitiesData = response.take(15).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erro ao carregar dados: $e";
      });
    }
  }

  String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  double _calculateTotalVendas() {
    return allCitiesData.fold(0.0, (sum, item) => sum + double.parse(item['valor_total'].toString()));
  }

  String _cidadeComMaiorVenda() {
    if (allCitiesData.isEmpty) return '-';
    return allCitiesData.reduce((a, b) => double.parse(a['valor_total'].toString()) > double.parse(b['valor_total'].toString()) ? a : b)['cidade'];
  }

  Widget _buildMonthSelectorCard() {
    return Card(
      color: Colors.indigo[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<String>(
          value: selectedMonth,
          dropdownColor: Colors.indigo[700],
          decoration: const InputDecoration(
            labelText: 'Selecione o mês',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
          ),
          items: months.map((month) {
            return DropdownMenuItem(
              value: month,
              child: Text(month, style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMonth = value;
              });
              fetchCidadesMaisVenderam(selectedMonth);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
            child: _summaryCard('Total Vendido', formatCurrency(_calculateTotalVendas()), LucideIcons.dollarSign)),
        const SizedBox(width: 16),
        Expanded(
            child: _summaryCard('Top Cidade', _cidadeComMaiorVenda(), LucideIcons.mapPin)),
      ],
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.indigo[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard({required String title, required Widget child}) {
    return Card(
      color: Colors.indigo[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.indigo[700],
        hintText: 'Buscar cidade...',
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.search, color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
      onChanged: (value) {
        setState(() {
          filtroCidade = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildPieChart() {
    if (chartData.isEmpty) {
      return const Center(
        child: Text('Nenhum dado para o gráfico', style: TextStyle(color: Colors.white70)),
      );
    }

    final List<double> values = chartData.map((c) => double.tryParse(c['valor_total'].toString()) ?? 0.0).toList();

    return VendasPieChart(
      topCities: chartData,
      values: values,
    );
  }


  Widget _buildBarChart() {
    final topData = allCitiesData.length > 5 ? allCitiesData.sublist(0, 5) : allCitiesData;

    if (topData.isEmpty) {
      return const Center(
        child: Text('Nenhum dado para o gráfico', style: TextStyle(color: Colors.white70)),
      );
    }

    final maxY = topData
        .map((e) => double.tryParse(e['valor_total'].toString()) ?? 0.0)
        .fold(0.0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY * 1.3,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cidade = topData[group.x.toInt()]['cidade'];
              final valor = double.tryParse(topData[group.x.toInt()]['valor_total'].toString()) ?? 0.0;
              return BarTooltipItem(
                '$cidade\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Total Vendido: ${formatCurrency(valor)}',
                    style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w400),
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
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
                if (index < 0 || index >= topData.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      topData[index]['cidade'],
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(topData.length, (index) {
          final cidade = topData[index];
          final valor = double.tryParse(cidade['valor_total'].toString()) ?? 0.0;
          final isTouched = index == touchedIndex;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: valor,
                width: isTouched ? 22 : 18,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: isTouched
                      ? [Colors.orangeAccent, Colors.deepOrange]
                      : [Colors.lightBlueAccent, Colors.blue],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }


  Widget _buildCityListCard() {
    final cidadesFiltradas = allCitiesData.where((cidade) =>
        cidade['cidade'].toString().toLowerCase().contains(filtroCidade)).toList();

    return Card(
      color: Colors.indigo[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Cidades',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Column(
              children: cidadesFiltradas.map((cidade) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cidade['cidade'],
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                      Text(formatCurrency(double.parse(cidade['valor_total'].toString())),
                          style: const TextStyle(color: Colors.white, fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.yellow,
  ];
}

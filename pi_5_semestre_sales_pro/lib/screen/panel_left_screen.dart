import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';
import 'package:pi_5_semestre_sales_pro/widget/pie_chart.dart';

class PanelLeftScreen extends StatefulWidget {
  const PanelLeftScreen({super.key});

  @override
  State<PanelLeftScreen> createState() => _PanelLeftScreenState();
}

class _PanelLeftScreenState extends State<PanelLeftScreen> {
  String selectedMonth = '01';
  List<Map<String, dynamic>> produtos = [];
  bool isLoading = true;
  String errorMessage = "";
  int touchedIndex = -1;

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    fetchProdutos(selectedMonth);
  }

  Future<void> fetchProdutos(String mes) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      ApiService apiService = ApiService();
      List fetchedProdutos = await apiService.fetchProdutosMaisVendidosPorMes(int.parse(mes));

      setState(() {
        produtos = fetchedProdutos.map((item) {
          return {
            'descricao_produto': item['descricao_produto'] ?? 'Sem descrição',
            'total_vendido': double.tryParse(item['total_vendas'].toString()) ?? 0.0,
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erro ao carregar os produtos: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Text(
          'Painel de Produtos',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
        onRefresh: () => fetchProdutos(selectedMonth),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildMonthSelectorCard(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _summaryCard(
                      'Total Vendido',
                      'R\$ ${_totalVendas()}',
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _summaryCard(
                      'Top Produto',
                      _produtoMaisVendido(),
                      Icons.star,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ✅ Construindo a lista de valores antes do gráfico de pizza
              Builder(
                builder: (context) {
                  final top5Produtos = produtos.take(5).toList();
                  final List<double> values = top5Produtos
                      .map((p) => p['total_vendido'] as double)
                      .toList();

                  return _buildChartCard(
                    title: 'Distribuição de Vendas',
                    child: PieChartWidget(
                      topProducts: top5Produtos,
                      values: values,
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              _buildChartCard(
                title: 'Comparativo de Vendas',
                child: _buildStyledBarChart(),
              ),
              const SizedBox(height: 16),
              _buildTopProductsGrid(),
            ],
          ),
        ),
      ),
    );
  }

  String _totalVendas() =>
      produtos.fold(0.0, (sum, p) => sum + p['total_vendido']).toStringAsFixed(2);

  String _produtoMaisVendido() {
    if (produtos.isEmpty) return 'Nenhum';
    return produtos.reduce((a, b) => a['total_vendido'] > b['total_vendido'] ? a : b)[
    'descricao_produto'];
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
          items: List.generate(9, (index) {
            final month = (index + 1).toString().padLeft(2, '0');
            return DropdownMenuItem(
              value: month,
              child: Text(month, style: const TextStyle(color: Colors.white)),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedMonth = value;
              });
              fetchProdutos(selectedMonth);
            }
          },
        ),
      ),
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
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledBarChart() {
    final topData = produtos.length > 5 ? produtos.sublist(0, 5) : produtos;
    final maxY = topData.map((e) => e['total_vendido'] as double).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY * 1.3,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.black87,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final produto = topData[group.x.toInt()];
              return BarTooltipItem(
                  '${produto['descricao_produto']}\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
              TextSpan(
              text: 'Total Vendido: R\$ ${produto['total_vendido'].toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w400),
              )
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
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 || index >= topData.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: 60,
                    child: Text(
                      topData[index]['descricao_produto'],
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
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
          final produto = topData[index];
          final isTouched = index == touchedIndex;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: produto['total_vendido'],
                width: isTouched ? 22 : 18,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: isTouched ? [Colors.orangeAccent, Colors.deepOrange] : [Colors.lightBlueAccent, Colors.blue],
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

  Widget _buildTopProductsGrid() {
    final topProdutos = produtos.take(6).toList();

    return Card(
      color: Colors.indigo[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Produtos',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: topProdutos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2, // Deixa os cards mais altos
              ),
              itemBuilder: (context, index) {
                final produto = topProdutos[index];
                return Container(
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Center(
                    child: Text(
                      produto['descricao_produto'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: null, // <- Mostra o nome completo com múltiplas linhas
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

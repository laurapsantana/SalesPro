import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pi_5_semestre_sales_pro/resource/app_colors.dart';
import '../resource/app_padding.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';

class PanelLeftScreen extends StatefulWidget {
  const PanelLeftScreen({super.key});

  @override
  State<PanelLeftScreen> createState() => _PanelLeftScreenState();
}

class _PanelLeftScreenState extends State<PanelLeftScreen> {
  String selectedMonth = '01'; // Mês selecionado
  List<Map<String, dynamic>> produtos = []; // Lista de produtos
  Map<int, String> touchedProduct = {}; // Produto tocado no gráfico

  final List<String> months = ['01', '02', '03', '04', '05', '06', '07', '08', '09'];

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    fetchProdutos(selectedMonth);
  }

  // Função para buscar os produtos mais vendidos
  Future<void> fetchProdutos(String mes) async {
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
      });

      print('Produtos carregados: $produtos');
    } catch (e) {
      print("Erro ao carregar os produtos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: const Text(
          'Painel de Produtos',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Menu Dropdown para selecionar o mês
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedMonth,
                dropdownColor: Colors.indigo[800],
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedMonth = newValue;
                    });
                    fetchProdutos(selectedMonth); // Buscar os dados do novo mês
                  }
                },
                items: months.map<DropdownMenuItem<String>>((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text('Mês: $month'),
                  );
                }).toList(),
              ),
            ),

            // Gráfico de Pizza
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: produtos.isNotEmpty
                  ? Row(
                children: [
                  // Gráfico de Pizza
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 250,
                      child: PieChartSample(
                        produtos: produtos,
                        onTouch: (FlTouchEvent event, PieTouchResponse? response) {
                          if (response != null && response.touchedSection != null) {
                            setState(() {
                              final touchedIndex =
                                  response.touchedSection!.touchedSectionIndex;
                              if (touchedIndex >= 0 && touchedIndex < produtos.length) {
                                touchedProduct = {
                                  touchedIndex: produtos[touchedIndex]['descricao_produto'],
                                };
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ),

                  // Legenda
                  Expanded(
                    flex: 1,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: produtos.take(4).length,
                      itemBuilder: (context, index) {
                        final produto = produtos[index];
                        return Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colors[index % colors.length],
                              ),
                            ),
                            Expanded(
                              child: Text(
                                produto['descricao_produto'] ?? 'Sem descrição',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              )
                  : const CircularProgressIndicator(),
            ),

            // Exibição do nome do produto tocado
            if (touchedProduct.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Produto: ${touchedProduct.values.first}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),

            // Lista com os produtos mais vendidos
            if (produtos.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8.0),
                itemCount: produtos.length,
                itemBuilder: (context, index) {
                  final produto = produtos[index];
                  return ListTile(
                    title: Text(
                      produto['descricao_produto'] ?? 'Sem descrição',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Total Vendas: ${produto['total_vendido']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  );
                },
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Nenhum produto encontrado.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PieChartSample extends StatelessWidget {
  final List<Map<String, dynamic>> produtos;
  final Function(FlTouchEvent, PieTouchResponse?) onTouch;

   PieChartSample({
    super.key,
    required this.produtos,
    required this.onTouch,
  });

  final List<Color> colors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 70,
        sections: showingSections(),
        borderData: FlBorderData(show: false),
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, PieTouchResponse? response) {
            onTouch(event, response);
          },
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    final double totalVendas = produtos.fold(
      0.0,
          (sum, item) => sum + item['total_vendido'],
    );

    return produtos.take(4).map((produto) {
      final double totalVendido = produto['total_vendido'];
      final double porcentagem = (totalVendido / totalVendas) * 100;

      return PieChartSectionData(
        value: totalVendido,
        color: colors[produtos.indexOf(produto) % colors.length],
        title: '${porcentagem.toStringAsFixed(1)}%',
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();
  }
}

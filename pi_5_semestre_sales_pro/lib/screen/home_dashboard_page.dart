import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widget/bar_chart_regiao.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});

  @override
  State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  late final ApiService apiService;
  bool isLoading = true;
  String? errorMessage;
  int mesSelecionado = DateTime.now().month;

  List<ClienteMaisComprou> topClientes = [];
  List<ProdutoMaisVendido> topProdutos = [];
  List<RegiaoVenda> topRegioes = [];

  final formatador = NumberFormat.simpleCurrency(locale: 'pt_BR');

  @override
  void initState() {
    super.initState();
    apiService = ApiService();
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final clientes = await carregarClientes();
      final produtos = await carregarProdutos();
      final regioes = await carregarRegioes();

      setState(() {
        topClientes = clientes;
        topProdutos = produtos;
        topRegioes = regioes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao carregar dados: $e";
        isLoading = false;
      });
    }
  }

  Future<List<ClienteMaisComprou>> carregarClientes() => apiService.fetchClientesMaisCompraram(mesSelecionado);

  Future<List<ProdutoMaisVendido>> carregarProdutos() async {
    final response = await apiService.fetchProdutosMaisVendidosMes(mesSelecionado);
    return response.map((json) => ProdutoMaisVendido.fromJson(json)).toList();
  }


  Future<List<RegiaoVenda>> carregarRegioes() async {
    final response = await apiService.fetchCidadesMaisVenderam(mesSelecionado);
    return response.map((json) => RegiaoVenda.fromJson(json)).toList();
  }

  Widget _buildMesDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<int>(
        dropdownColor: Colors.indigo[800],
        value: mesSelecionado,
        iconEnabledColor: Colors.white,
        underline: const SizedBox(),
        items: List.generate(9, (index) {
          final mes = index + 1;
          return DropdownMenuItem(
            value: mes,
            child: Text('Mês $mes', style: const TextStyle(color: Colors.white)),
          );
        }),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              mesSelecionado = value;
            });
            carregarDados();
          }
        },
      ),
    );
  }

  Widget _buildSection(String title, Widget content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, semanticLabel: title),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              )
            ],
          ),
          const SizedBox(height: 8),
          content.animate().fade(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
        ],
      ),
    );
  }

  Widget _buildTopList<T>({required List<T> items, required Widget Function(T) builder}) {
    return Column(
      children: items.take(3).map((item) {
        return Card(
          color: Colors.indigo[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: builder(item),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClientesBarChart() {
    final topData = topClientes.length > 3 ? topClientes.sublist(0, 3) : topClientes;
    final maxY = topData.map((e) => e.totalCompras).fold(0.0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY * 1.3,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cliente = topData[group.x.toInt()];
              return BarTooltipItem(
                '${cliente.razaoCliente}\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: 'Total Comprado: ${formatador.format(cliente.totalCompras)}',
                    style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w400),
                  ),
                ],
              );
            },
          ),
        ),
        barGroups: List.generate(topData.length, (index) {
          final cliente = topData[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: cliente.totalCompras,
                width: 18,
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Colors.lightBlueAccent, Colors.blue],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$ ${value.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
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
                      topData[index].razaoCliente,
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
      ),
    );
  }

  Widget _buildProdutosPieChart() {
    final topData = topProdutos.take(3).toList();
    final total = topData.fold(0.0, (sum, item) => sum + item.totalVendido);
    final colors = [Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 4,
              centerSpaceRadius: 40,
              sections: List.generate(topData.length, (index) {
                final produto = topData[index];
                final percent = total == 0 ? 0 : (produto.totalVendido / total) * 100;
                return PieChartSectionData(
                  color: colors[index % colors.length],
                  value: produto.totalVendido,
                  title: '${percent.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                );
              }),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(topData.length, (index) {
              final produto = topData[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, color: colors[index % colors.length]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        produto.descricaoProduto,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Principal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.indigo[800],
        centerTitle: true,
      ),
      backgroundColor: Colors.indigo[900],
      floatingActionButton: FloatingActionButton(
        onPressed: carregarDados,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection("Selecione um Mês", _buildMesDropdown(), LucideIcons.calendarDays),
            _buildSection(
              "Clientes que mais compraram",
              Column(
                children: [
                  Card(
                    color: Colors.indigo[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.5),
                      child: SizedBox(
                        height: 330,
                        child: _buildClientesBarChart(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTopList(
                    items: topClientes,
                    builder: (cliente) => ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: Text(cliente.razaoCliente, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Total Comprado: ${formatador.format(cliente.totalCompras)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              LucideIcons.users,
            ),
            _buildSection(
              "Produtos mais vendidos",
              Column(
                children: [
                  Card(
                    color: Colors.indigo[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 300,
                        child: _buildProdutosPieChart(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTopList(
                    items: topProdutos,
                    builder: (produto) => ListTile(
                      leading: const Icon(Icons.shopping_bag, color: Colors.white),
                      title: Text(produto.descricaoProduto, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Quantidade Vendida: ${produto.totalVendido.toStringAsFixed(0)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              LucideIcons.package,
            ),
            _buildSection(
              "Cidades que mais venderam",
              Column(
                children: [
                  Card(
                    color: Colors.indigo[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SizedBox(
                        height: 300,
                        child: BarChartWidgetRegiao(cidade: topRegioes.take(3).toList()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildTopList(
                    items: topRegioes,
                    builder: (regiao) => ListTile(
                      leading: const Icon(Icons.location_city, color: Colors.white),
                      title: Text(regiao.nomeCidade, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        "Total Vendas: ${formatador.format(regiao.totalVendas)}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ],
              ),
              LucideIcons.mapPin,
            ),
          ],
        ),
      ),
    );
  }
}

class RegiaoVenda {
  final String nomeCidade;
  final double totalVendas;

  RegiaoVenda({required this.nomeCidade, required this.totalVendas});

  factory RegiaoVenda.fromJson(Map<String, dynamic> json) {
    return RegiaoVenda(
      nomeCidade: json['cidade']?.toString() ?? 'Desconhecida',
      totalVendas: double.tryParse(json['valor_total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

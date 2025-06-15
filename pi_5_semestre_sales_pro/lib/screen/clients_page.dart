import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ApiService _apiService = ApiService();
  List<ClienteMaisComprou> clientesMaisCompraram = [];
  int? mesSelecionado;
  bool isLoading = false;
  String errorMessage = "";
  String filtroNome = "";
  final formatador = NumberFormat.simpleCurrency(locale: 'pt_BR');
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    mesSelecionado = DateTime.now().month;
    _fetchClientesMaisCompraram();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Text("Painel de Clientes",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.indigo[800],
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
        child: Text(errorMessage, style: const TextStyle(color: Colors.red)),
      )
          : RefreshIndicator(
        onRefresh: _fetchClientesMaisCompraram,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDropdown(),
              const SizedBox(height: 16),
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'Top 5 Clientes por Total de Compras',
                child: _buildStyledBarChart(),
              ),
              const SizedBox(height: 16),
              _buildSearchField(),
              const SizedBox(height: 8),
              _buildClientListCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: "Buscar cliente...",
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        filled: true,
        fillColor: Colors.indigo[700],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() => filtroNome = value.toLowerCase());
      },
    );
  }

  Widget _buildClientListCard() {
    final clientesFiltrados = clientesMaisCompraram.where((c) => c.razaoCliente.toLowerCase().contains(filtroNome)).toList();

    return Card(
      color: Colors.indigo[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Top Clientes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...clientesFiltrados.map((cliente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(cliente.razaoCliente, style: const TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  Text(formatador.format(cliente.totalCompras), style: const TextStyle(color: Colors.white, fontSize: 14)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Card(
      color: Colors.indigo[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Selecione o mês',
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(),
          ),
          value: mesSelecionado,
          dropdownColor: Colors.indigo[700],
          items: List.generate(9, (index) {
            int mes = index + 1;
            return DropdownMenuItem(
              value: mes,
              child: Text("Mês $mes", style: const TextStyle(color: Colors.white)),
            );
          }),
          onChanged: (value) {
            setState(() {
              mesSelecionado = value;
              _fetchClientesMaisCompraram();
            });
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalComprado = clientesMaisCompraram.fold(0.0, (sum, c) => sum + c.totalCompras);
    final topCliente = clientesMaisCompraram.isNotEmpty ? clientesMaisCompraram.first.razaoCliente : '-';

    return Row(
      children: [
        Expanded(child: _summaryCard('Total Comprado', formatador.format(totalComprado), LucideIcons.dollarSign)),
        const SizedBox(width: 16),
        Expanded(child: _summaryCard('Top Cliente', topCliente, LucideIcons.user)),
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
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
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
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: child),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledBarChart() {
    final topData = clientesMaisCompraram.length > 5 ? clientesMaisCompraram.sublist(0, 5) : clientesMaisCompraram;
    final maxY = topData.map((e) => e.totalCompras).fold(0.0, (a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
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
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                children: [
                  TextSpan(
                    text: 'Total Comprado: ${formatador.format(cliente.totalCompras)}',
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
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  'R\$ ${value.toStringAsFixed(0)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
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
          final cliente = topData[index];
          final isTouched = index == touchedIndex;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: cliente.totalCompras,
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

  Future<void> _fetchClientesMaisCompraram() async {
    if (mesSelecionado == null) return;

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final data = await _apiService.fetchClientesMaisCompraram(mesSelecionado!);
      data.sort((a, b) => b.totalCompras.compareTo(a.totalCompras));
      setState(() {
        clientesMaisCompraram = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erro ao carregar os dados: \$e";
      });
    }
  }
}

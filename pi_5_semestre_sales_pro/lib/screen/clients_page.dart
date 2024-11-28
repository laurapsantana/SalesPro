import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../api/api_service.dart';

class ClientesPage extends StatefulWidget {
  @override
  _ClientesPageState createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ApiService _apiService = ApiService();
  List<ClienteMaisComprou> clientesMaisCompraram = [];
  int? mesSelecionado;
  bool isLoading = false;
  String errorMessage = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: const Text(
          'Painel de Clientes',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchClientesMaisCompraram,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(),
              const SizedBox(height: 16),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
                  : _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  // Constrói o Dropdown para seleção do mês
  Widget _buildDropdown() {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Selecione um mês",
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.indigo[700],
      ),
      dropdownColor: Colors.indigo[900],
      value: mesSelecionado,
      onChanged: (int? value) {
        setState(() {
          mesSelecionado = value;
        });
        _fetchClientesMaisCompraram();
      },
      items: List.generate(
        9,
            (index) => DropdownMenuItem(
          value: index + 1,
          child: Text("Mês ${index + 1}", style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  // Constrói o conteúdo principal: gráfico e lista de clientes
  Widget _buildContent() {
    if (clientesMaisCompraram.isEmpty) {
      return const Center(child: Text("Nenhum dado encontrado para este mês.", style: TextStyle(color: Colors.white)));
    }

    return Column(
      children: [
        _buildBarChart(),
        const SizedBox(height: 16),
        _buildClientList(),
      ],
    );
  }

  // Constrói o gráfico de barras
  Widget _buildBarChart() {
    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: clientesMaisCompraram.map((c) => c.totalCompras).reduce((a, b) => a > b ? a : b) * 1.2,
          barGroups: clientesMaisCompraram.asMap().entries.map((entry) {
            final index = entry.key;
            final cliente = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: cliente.totalCompras,
                  color: Colors.blue,
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() < 0 || value.toInt() >= clientesMaisCompraram.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      clientesMaisCompraram[value.toInt()].razaoCliente,
                      style: const TextStyle(color: Colors.black, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Constrói a lista de clientes
  Widget _buildClientList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: clientesMaisCompraram.length,
      itemBuilder: (context, index) {
        final cliente = clientesMaisCompraram[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Text(cliente.razaoCliente[0], style: const TextStyle(color: Colors.white)),
          ),
          title: Text(cliente.razaoCliente, style: const TextStyle(color: Colors.white)),
          subtitle: Text(
            "Compras: ${cliente.totalCompras.toStringAsFixed(2)}",
            style: const TextStyle(color: Colors.white70),
          ),
        );
      },
    );
  }

  /// Busca os clientes que mais compraram
  Future<void> _fetchClientesMaisCompraram() async {
    if (mesSelecionado == null) return;

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    try {
      final data = await _apiService.fetchClientesMaisCompraram(mesSelecionado!);
      setState(() {
        clientesMaisCompraram = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Erro ao carregar os dados: $e";
      });
    }
  }
}

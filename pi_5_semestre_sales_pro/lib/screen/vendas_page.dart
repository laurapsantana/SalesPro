import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';

class VendasPage extends StatefulWidget {
  const VendasPage({super.key});

  @override
  State<StatefulWidget> createState() => _VendasPageState();
}

class _VendasPageState extends State<VendasPage> {
  List<Map<String, dynamic>> chartData = []; // Dados para o gráfico
  List<Map<String, dynamic>> allCitiesData = []; // Dados completos para a lista
  int touchedIndex = -1; // Índice da seção tocada no gráfico
  bool isLoading = true; // Indicador de carregamento
  String selectedMonth = '01'; // Mês selecionado (inicial)
  final List<String> months = ['01', '02', '03', '04', '05', '06', '07', '08', '09']; // Meses disponíveis

  @override
  void initState() {
    super.initState();
    fetchCidadesMaisVenderam(selectedMonth); // Carregar dados ao iniciar
  }

  // Função para buscar os dados das cidades que mais venderam
  Future<void> fetchCidadesMaisVenderam(String mes) async {
    setState(() {
      isLoading = true;
    });

    try {
      ApiService apiService = ApiService();
      var response = await apiService.fetchCidadesMaisVenderam(int.parse(mes)); // Chamada da API
      setState(() {
        chartData = response.take(4).toList(); // Filtra as 4 maiores vendas para o gráfico
        allCitiesData = response.take(15).toList(); // Armazena todos os dados para a lista
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar(e);
    }
  }

  // Função para mostrar erros ao usuário
  void _showErrorSnackBar(dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar dados: $error')),
    );
  }

  // Função para formatar o valor como moeda
  String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(value);
  }

  // Função para calcular o percentual de cada cidade no gráfico
  double _calculatePercentage(double valorTotal, double totalVendas) {
    return (valorTotal / totalVendas) * 100;
  }

  // Função para calcular o total de vendas
  double _calculateTotalVendas() {
    return chartData.fold(0.0, (sum, item) => sum + double.parse(item['valor_total'].toString()));
  }

  // Função para gerar as seções do gráfico de pizza
  List<PieChartSectionData> showingSections() {
    double totalVendas = _calculateTotalVendas();

    return List.generate(chartData.length, (i) {
      double valorTotal = double.tryParse(chartData[i]['valor_total'].toString()) ?? 0.0;
      double percentage = _calculatePercentage(valorTotal, totalVendas);
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 60.0 : 50.0;
      final fontSize = isTouched ? 25.0 : 16.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return PieChartSectionData(
        color: colorList[i % colorList.length],
        value: percentage,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Cor branca para o texto do gráfico
          shadows: shadows,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        title: const Text(
          'Painel de Vendas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildMonthDropdown(),
              const SizedBox(height: 20),
              isLoading ? _buildLoadingIndicator() : _buildChartAndList(),
            ],
          ),
        ),
      ),
    );
  }

  // Método para construir o dropdown de seleção de mês
  Widget _buildMonthDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.indigo[800],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: DropdownButton<String>(
          value: selectedMonth,
          dropdownColor: Colors.indigo[800],
          style: const TextStyle(color: Colors.white),
          items: months.map((month) {
            return DropdownMenuItem<String>(
              value: month,
              child: Text('Mês $month', style: TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: (newMonth) {
            setState(() {
              selectedMonth = newMonth!;
              fetchCidadesMaisVenderam(selectedMonth);
            });
          },
        ),
      ),
    );
  }

  // Método para exibir o indicador de carregamento
  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator());
  }

  // Método para exibir o gráfico e a lista de cidades
  Widget _buildChartAndList() {
    return chartData.isEmpty
        ? const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text(
        "Sem dados para mostrar",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    )
        : Column(
      children: [
        _buildPieChart(),
        const SizedBox(height: 20),
        _buildCityList(),
      ],
    );
  }

  // Método para construir o gráfico de pizza
  Widget _buildPieChart() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: AspectRatio(
        aspectRatio: 1.3,
        child: Row(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    sections: showingSections(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            _buildCityLegend(),
          ],
        ),
      ),
    );
  }

  // Método para construir a legenda das cidades
  // Método para construir a legenda das cidades (somente nome)
  Widget _buildCityLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: chartData.map((cityData) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                color: colorList[chartData.indexOf(cityData) % colorList.length],
              ),
              const SizedBox(width: 8),
              Text(
                cityData['cidade'], // Apenas o nome da cidade
                style: const TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Método para construir a lista de cidades com as vendas mais altas
  Widget _buildCityList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: allCitiesData.map((cityData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cityData['cidade'],
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
                Text(
                  formatCurrency(double.parse(cityData['valor_total'].toString())),
                  style: const TextStyle(color: Colors.white, fontSize: 16.0),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Definindo as cores para as seções do gráfico
  final List<Color> colorList = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.yellow,
  ];
}

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../api/api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketMedioProdutoPage extends StatefulWidget {
  const TicketMedioProdutoPage({super.key});

  @override
  State<TicketMedioProdutoPage> createState() => _TicketMedioProdutoPageState();
}

class _TicketMedioProdutoPageState extends State<TicketMedioProdutoPage> {
  final ApiService _apiService = ApiService();

  late Future<List<TicketMedioProduto>> futureData;
  List<TicketMedioProduto> todosProdutos = [];
  List<TicketMedioProduto> produtosFiltrados = [];
  double ticketMinimo = 0.0;
  int itensPorPagina = 10;
  int paginaAtual = 0;
  String busca = '';
  String criterioOrdenacao = 'ticket';
  int touchedIndex = -1;
  int itensSelecionadosParaExportacao = 30; // padrão: 30 produtos

  bool _gerandoPdf = false;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  void carregarDados() {
    futureData = _apiService.fetchTicketMedioPorProduto();
    futureData.then((dados) {
      setState(() {
        todosProdutos = dados;
        produtosFiltrados = dados;
        aplicarOrdenacao();
      });
    });
  }

  void filtrarProdutos() {
    setState(() {
      produtosFiltrados = todosProdutos.where((p) {
        final nome = p.descricaoProduto.toLowerCase();
        return nome.contains(busca.toLowerCase()) && p.ticketMedio >= ticketMinimo;
      }).toList();
      aplicarOrdenacao();
      paginaAtual = 0;
    });
  }

  void aplicarOrdenacao() {
    if (criterioOrdenacao == 'ticket') {
      produtosFiltrados.sort((a, b) => b.ticketMedio.compareTo(a.ticketMedio));
    } else if (criterioOrdenacao == 'quantidade') {
      produtosFiltrados.sort((a, b) => b.qtdVendas.compareTo(a.qtdVendas));
    } else if (criterioOrdenacao == 'total') {
      produtosFiltrados.sort((a, b) => b.totalVendido.compareTo(a.totalVendido));
    }
  }

  List<TicketMedioProduto> obterPaginaAtual() {
    final inicio = paginaAtual * itensPorPagina;
    final fim = inicio + itensPorPagina;
    return produtosFiltrados.sublist(
      inicio,
      fim > produtosFiltrados.length ? produtosFiltrados.length : fim,
    );
  }

  void proximaPagina() {
    if ((paginaAtual + 1) * itensPorPagina < produtosFiltrados.length) {
      setState(() => paginaAtual++);
    }
  }

  void paginaAnterior() {
    if (paginaAtual > 0) {
      setState(() => paginaAtual--);
    }
  }

  Future<void> exportarPdf() async {
    setState(() {
      _gerandoPdf = true;
    });

    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

    final produtosParaExportar = produtosFiltrados.take(itensSelecionadosParaExportacao).toList();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text("Ticket Médio por Produto",
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text("Exportando os primeiros $itensSelecionadosParaExportacao produtos."),
          pw.SizedBox(height: 10),
          pw.Table.fromTextArray(
            headers: ["Produto", "Ticket Médio", "Qtd", "Total"],
            data: produtosParaExportar.map((p) => [
              p.descricaoProduto,
              "R\$ ${p.ticketMedio.toStringAsFixed(2)}",
              p.qtdVendas.toString(),
              "R\$ ${p.totalVendido.toStringAsFixed(2)}"
            ]).toList(),
          )
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());

    setState(() {
      _gerandoPdf = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
        title: const Text(
          "Ticket Médio por Produto",
          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
        ),
        actions: [
          DropdownButton<int>(
            value: itensSelecionadosParaExportacao,
            dropdownColor: Colors.indigo[900],
            style: const TextStyle(color: Colors.white),
            underline: const SizedBox(),
            iconEnabledColor: Colors.white,
            items: [10, 20, 30, 50, 100].map((valor) {
              return DropdownMenuItem(
                value: valor,
                child: Text('Exportar $valor'),
              );
            }).toList(),
            onChanged: (valor) {
              if (valor != null) {
                setState(() {
                  itensSelecionadosParaExportacao = valor;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _gerandoPdf ? null : () => exportarPdf(),
            tooltip: 'Exportar para PDF',
          ),
          if (_gerandoPdf)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
            )
        ],
      ),
      body: FutureBuilder<List<TicketMedioProduto>>(
        future: futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 12),
                  Text("Carregando produtos...", style: TextStyle(color: Colors.white))
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    "Erro ao carregar dados",
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => carregarDados()),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Tentar novamente", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  )
                ],
              ),
            );
          } else {
            // Dados carregados com sucesso - mostrar filtro sempre
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Campo busca SEMPRE visível
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Buscar produto...",
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white70),
                        filled: true,
                        fillColor: Colors.indigo[800],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) {
                        busca = value;
                        filtrarProdutos();
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Ordenar por:", style: TextStyle(color: Colors.white)),
                        DropdownButton<String>(
                          value: criterioOrdenacao,
                          dropdownColor: Colors.indigo[800],
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                          style: const TextStyle(color: Colors.white),
                          underline: Container(height: 1, color: Colors.white24),
                          onChanged: (String? novo) {
                            if (novo != null) {
                              setState(() {
                                criterioOrdenacao = novo;
                                aplicarOrdenacao();
                              });
                            }
                          },
                          items: const [
                            DropdownMenuItem(value: 'ticket', child: Text('Ticket Médio')),
                            DropdownMenuItem(value: 'quantidade', child: Text('Quantidade')),
                            DropdownMenuItem(value: 'total', child: Text('Total Vendido')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Agora verifica se a lista filtrada está vazia, mostrar mensagem, senão mostra gráfico e lista
                    if (produtosFiltrados.isEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 80, color: Colors.white54),
                            SizedBox(height: 12),
                            Text(
                              "Nenhum produto encontrado com o nome digitado.",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Tente ajustar a busca ou verifique se digitou corretamente.",
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text("Top Produtos por Ticket Médio",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 600),
                        child: SizedBox(
                          key: ValueKey(produtosFiltrados),
                          height: 250,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: produtosFiltrados
                                  .map((e) => e.ticketMedio)
                                  .reduce((a, b) => a > b ? a : b) *
                                  1.2,
                              barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor:(_) => Colors.black87,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  tooltipRoundedRadius: 8,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final produto = produtosFiltrados[group.x.toInt()];
                                    return BarTooltipItem(
                                      '${produto.descricaoProduto}\n'
                                          'Ticket Médio: R\$ ${produto.ticketMedio.toStringAsFixed(2)}',
                                      const TextStyle(color: Colors.white, fontSize: 12),
                                    );
                                  },
                                ),
                                touchCallback: (event, response) {
                                  if (event is FlTapUpEvent &&
                                      response != null &&
                                      response.spot != null) {
                                    final index = response.spot!.touchedBarGroupIndex;
                                    setState(() {
                                      touchedIndex = index;
                                    });
                                  }
                                },
                              ),
                              barGroups: produtosFiltrados
                                  .take(5)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                final i = entry.key;
                                final produto = entry.value;
                                final isTouched = i == touchedIndex;
                                return BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: produto.ticketMedio,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                      gradient: LinearGradient(
                                        colors: isTouched
                                            ? [Colors.orangeAccent, Colors.deepOrange]
                                            : [Colors.lightBlueAccent, Colors.blue],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index < 0 || index >= produtosFiltrados.length) {
                                        return const SizedBox.shrink();
                                      }

                                      String nome = produtosFiltrados[index].descricaoProduto;
                                      if (nome.length > 10) {
                                        nome = nome.substring(0, 10) + '...';
                                      }

                                      return Text(
                                        nome,
                                        style: const TextStyle(fontSize: 10, color: Colors.white),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    interval: produtosFiltrados
                                        .map((e) => e.ticketMedio)
                                        .reduce((a, b) => a > b ? a : b) /
                                        5,
                                    getTitlesWidget: (value, meta) {
                                      return Text('R\$${value.toStringAsFixed(0)}',
                                          style: const TextStyle(color: Colors.white, fontSize: 10));
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: FlGridData(show: true, drawVerticalLine: false),
                              borderData: FlBorderData(show: false),
                            ),
                          ),

                        ),
                      ),
                      const SizedBox(height: 20),

                      // Lista paginada
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: obterPaginaAtual().length,
                        itemBuilder: (context, index) {
                          final produto = obterPaginaAtual()[index];
                          return Card(
                            color: Colors.indigo[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text(produto.descricaoProduto,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                'Qtd: ${produto.qtdVendas} | Total: R\$${produto.totalVendido.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Text(
                                'R\$${produto.ticketMedio.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.lightGreenAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: paginaAtual > 0 ? paginaAnterior : null,
                            icon: const Icon(Icons.arrow_back_ios),
                            label: const Text('Anterior'),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Página ${paginaAtual + 1} de ${((produtosFiltrados.length - 1) / itensPorPagina + 1).toInt()}',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed:
                            (paginaAtual + 1) * itensPorPagina < produtosFiltrados.length ? proximaPagina : null,
                            icon: const Icon(Icons.arrow_forward_ios),
                            label: const Text('Próximo'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

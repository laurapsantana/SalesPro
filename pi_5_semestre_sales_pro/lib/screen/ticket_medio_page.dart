import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../widget/ticket_medio_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class TicketMedioPage extends StatefulWidget {
  const TicketMedioPage({super.key});

  @override
  State<TicketMedioPage> createState() => _TicketMedioPageState();
}

class _TicketMedioPageState extends State<TicketMedioPage> {
  final ApiService _apiService = ApiService();

  late Future<List<TicketMedio>> _ticketMedioFuture;
  List<TicketMedio> _todosClientes = [];
  List<TicketMedio> _clientesFiltrados = [];
  String _busca = '';
  String _criterioOrdenacao = 'ticket';

  bool _gerandoPdf = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    _ticketMedioFuture = _apiService.fetchTicketMedio();
    _ticketMedioFuture.then((dados) {
      setState(() {
        _todosClientes = dados;
        _clientesFiltrados = List.from(dados);
        _aplicarFiltroOrdenacaoSemSetState();
      });
    });
  }

  void _aplicarFiltroOrdenacaoSemSetState() {
    List<TicketMedio> filtrados = _todosClientes.where((c) =>
        c.cliente.toLowerCase().contains(_busca.toLowerCase())
    ).toList();

    if (_criterioOrdenacao == 'ticket') {
      filtrados.sort((a, b) => b.ticketMedio.compareTo(a.ticketMedio));
    } else if (_criterioOrdenacao == 'total') {
      filtrados.sort((a, b) => b.totalGasto.compareTo(a.totalGasto));
    } else if (_criterioOrdenacao == 'vendas') {
      filtrados.sort((a, b) => b.totalVendas.compareTo(a.totalVendas));
    }

    setState(() {
      _clientesFiltrados = filtrados;
    });
  }

  void _atualizarFiltroOrdenacao({String? busca, String? criterio}) {
    if (busca != null) _busca = busca;
    if (criterio != null) _criterioOrdenacao = criterio;
    _aplicarFiltroOrdenacaoSemSetState();
  }

  Future<void> _exportarParaPdf(List<TicketMedio> data) async {
    setState(() {
      _gerandoPdf = true;
    });

    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.simpleCurrency(locale: 'pt_BR');

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(level: 0, child: pw.Text("Relatório de Ticket Médio", style: const pw.TextStyle(fontSize: 24))),
          pw.Paragraph(text: "Data de geração: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}"),
          pw.Table.fromTextArray(
            headers: ["Cliente", "Total de Vendas", "Total Gasto", "Ticket Médio"],
            data: data.map((t) => [
              t.cliente,
              t.totalVendas.toString(),
              currencyFormatter.format(t.totalGasto),
              currencyFormatter.format(t.ticketMedio),
            ]).toList(),
          )
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());

    setState(() {
      _gerandoPdf = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.white),
            SizedBox(width: 8),
            Text('Ticket Médio por Cliente', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.indigo[900],
        centerTitle: true,
        elevation: 0,
        actions: [
          if (_clientesFiltrados.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              onPressed: _gerandoPdf ? null : () => _exportarParaPdf(_clientesFiltrados),
              tooltip: 'Exportar para PDF',
            ),
          if (_gerandoPdf)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))),
            )
        ],
      ),
      body: FutureBuilder<List<TicketMedio>>(
        future: _ticketMedioFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 12),
                  Text("Carregando dados...", style: TextStyle(fontSize: 16, color: Colors.white)),
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
                  const Text('Erro ao carregar dados', style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(snapshot.error.toString(), style: const TextStyle(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _carregarDados,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Tentar novamente", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.indigo[800],
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Buscar cliente...",
                              hintStyle: const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.search, color: Colors.white70),
                              filled: true,
                              fillColor: Colors.indigo[700],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) => _atualizarFiltroOrdenacao(busca: value),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.indigo[700],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            value: _criterioOrdenacao,
                            dropdownColor: Colors.indigo[800],
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                            style: const TextStyle(color: Colors.white),
                            underline: Container(height: 0),
                            onChanged: (String? novo) {
                              if (novo != null) _atualizarFiltroOrdenacao(criterio: novo);
                            },
                            items: const [
                              DropdownMenuItem(value: 'ticket', child: Text('Ticket Médio')),
                              DropdownMenuItem(value: 'total', child: Text('Total Gasto')),
                              DropdownMenuItem(value: 'vendas', child: Text('Total de Vendas')),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_clientesFiltrados.isEmpty) ...[
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
          ]else ...[
                  //const Text('Gráfico de Ticket Médio', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    child: TicketMedioChart(key: ValueKey(_clientesFiltrados), data: _clientesFiltrados),
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _clientesFiltrados.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _clientesFiltrados[index];
                      return Card(
                        color: Colors.indigo[800],
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo[700],
                            child: Text(item.cliente.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(item.cliente, style: const TextStyle(color: Colors.white)),
                          subtitle: Text("Ticket médio: R\$ ${item.ticketMedio.toStringAsFixed(2)}",
                              style: const TextStyle(color: Colors.white70)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Vendas: ${item.totalVendas}", style: const TextStyle(color: Colors.white)),
                              Text("Total: R\$ ${item.totalGasto.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}

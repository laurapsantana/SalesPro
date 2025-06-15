import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';
import 'package:pi_5_semestre_sales_pro/widget/recomendacoes_bar_chart.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class RecomendacoesPage extends StatefulWidget {
  final int idCliente;

  const RecomendacoesPage({super.key, required this.idCliente});

  @override
  State<RecomendacoesPage> createState() => _RecomendacoesPageState();
}

class _RecomendacoesPageState extends State<RecomendacoesPage> {
  List<ProdutoRecomendado> recomendacoes = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    carregarRecomendacoes();
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Future<void> carregarRecomendacoes() async {
    try {
      final dados = await ApiService().fetchRecomendacoesCliente(widget.idCliente);
      setState(() {
        recomendacoes = dados;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> exportarParaPdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (pw.Context context) => [
          pw.Header(
              level: 0,
              child: pw.Text("Recomendações de Produtos",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.Table.fromTextArray(
            headers: ["Produto", "Probabilidade", "Nível"],
            data: recomendacoes.map((r) {
              final double prob = r.probabilidade;
              String nivel = prob >= 70 ? "Alta" : (prob >= 40 ? "Média" : "Baixa");
              return [
                r.descricaoProduto,
                "${prob.toStringAsFixed(2)}%",
                nivel
              ];
            }).toList(),
          )
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[900],
      appBar: AppBar(
        title: const Text("Recomendações de Produtos"),
        backgroundColor: Colors.indigo[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.red,),
            onPressed: exportarParaPdf,
            tooltip: 'Exportar PDF',
          ),
        ],
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
          : recomendacoes.isEmpty
          ? const Center(
        child: Text(
          "Nenhuma recomendação encontrada.",
          style: TextStyle(color: Colors.white),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RecomendacoesBarChart(recomendacoes: recomendacoes),
            const SizedBox(height: 20),
            const Text(
              "Produtos Recomendados",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: recomendacoes.length,
                itemBuilder: (context, index) {
                  final item = recomendacoes[index];
                  final double prob = item.probabilidade;
                  String indicador;
                  Color corTexto;

                  if (prob >= 70) {
                    indicador = "🔥 Alta";
                    corTexto = Colors.green;
                  } else if (prob >= 40) {
                    indicador = "⚠️ Média";
                    corTexto = Colors.orange;
                  } else {
                    indicador = "❄️ Baixa";
                    corTexto = Colors.red;
                  }

                  return ListTile(
                    title: Text(
                      item.descricaoProduto,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Probabilidade: ${item.probabilidade.toStringAsFixed(2)}%",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Text(
                      indicador,
                      style: TextStyle(fontWeight: FontWeight.bold, color: corTexto),
                    ),
                    onTap: () async {
                      try {
                        final produto = await ApiService()
                            .fetchDetalhesProduto(item.codigoProduto);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.indigo[900],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            title: Row(
                              children: [
                                const Icon(Icons.shopping_bag, color: Colors.white),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    produto.descricao,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Divider(color: Colors.white30),
                                _buildDetailRow("Código:", produto.codigoProduto),
                                const SizedBox(height: 8),
                                _buildDetailRow("Categoria:", produto.categoria),
                                const SizedBox(height: 8),
                                _buildDetailRow(
                                    "Preço:", "R\$ ${produto.preco.toStringAsFixed(2)}"),
                              ],
                            ),
                            actions: [
                              TextButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close, color: Colors.white),
                                label: const Text("Fechar", style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      } catch (e) {
                        print('Erro ao exibir detalhes: $e');
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

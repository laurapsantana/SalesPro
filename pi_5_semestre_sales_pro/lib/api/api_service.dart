import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:3000/produtos"; // URL do servidor da API

  Future<double> fetchReceitaLiquida() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/receita-liquida"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['receitaLiquida'] as num).toDouble(); // Retorna apenas um valor numérico
      } else {
        throw Exception("Erro ao buscar receita líquida: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro de rede: $e");
    }
  }

  Future<List<dynamic>> fetchProdutosMaisVendidos() async {
    final response = await http.get(Uri.parse("$baseUrl/produtos-mais-vendidos"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erro ao buscar produtos mais vendidos");
    }
  }

  Future<List<VendaMensal>> fetchVendaMensal() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/venda-mensal"));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => VendaMensal.fromJson(json)).toList();
      } else {
        throw Exception("Erro ao buscar vendas mensais: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erro de rede: $e");
    }
  }

  // Método para buscar produtos mais vendidos na semana
  Future<List<Produto>> fetchProdutosMaisVendidosSemana() async {
    final response = await http.get(Uri.parse("$baseUrl/mais-vendidos/semana"));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Produto.fromJson(json)).toList();
    } else {
      throw Exception("Erro ao buscar produtos mais vendidos na semana: ${response.statusCode}");
    }
  }

  // Método para buscar produtos mais vendidos no mês
  Future<List<dynamic>> fetchTopProdutosMes(String mes) async {
    final response = await http.get(Uri.parse("$baseUrl/produtos-mais-vendidos-mes/$mes"));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erro ao buscar produtos mais vendidos para o mês selecionado");
    }
  }
}

// Modelo de Produto
class Produto {
  final int id;
  final String nome;
  final double preco;

  Produto({required this.id, required this.nome, required this.preco});

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      id: json['id'],
      nome: json['nome'],
      preco: (json['preco'] as num).toDouble(),
    );
  }
}

// Modelo de VendaMensal
class VendaMensal {
  final int mes;
  final double total;

  VendaMensal({required this.mes, required this.total});

  factory VendaMensal.fromJson(Map<String, dynamic> json) {
    return VendaMensal(
      mes: (json['mes'] as num).toInt(),
      total: (json['total'] as num).toDouble(),
    );
  }
}

// Modelo de ProdutoMaisVendido
class ProdutoMaisVendido {
  final String codigoProduto;
  final String descricaoProduto;
  final int totalVendas;

  ProdutoMaisVendido({
    required this.codigoProduto,
    required this.descricaoProduto,
    required this.totalVendas,
  });

  factory ProdutoMaisVendido.fromJson(Map<String, dynamic> json) {
    return ProdutoMaisVendido(
      codigoProduto: json['codigo_produto'],
      descricaoProduto: json['descricao_produto'],
      totalVendas: json['total_vendas'],
    );
  }
}

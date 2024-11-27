import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://10.0.2.2:3000/"; // Para emulador Android

  Future<List<VendaMensal>> fetchVendasMensais(int mesSelecionado) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/venda-mensal/$mesSelecionado'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => VendaMensal.fromJson(data)).toList();
    } else {
      throw Exception('Falha ao carregar dados de vendas mensais');
    }
  }

  // Função para buscar dados de vendas da API
  Future<void> fetchSalesData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/analise/vendas'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
    } else {
      throw Exception('Falha ao carregar os dados');
    }
  }

  // Função para buscar as vendas por cidade
  Future<List<VendasPorCidade>> fetchVendasPorCidade() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/desempenho-por-cidade'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => VendasPorCidade.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar vendas por cidade');
    }
  }

  Future<List<Map<String, dynamic>>> fetchDadosPizza() async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2/dados-pizza'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        return data.map((item) {
          return {
            'label': item['label'],
            'value': item['value'],
          };
        }).toList();
      } else {
        throw Exception('Erro ao buscar os dados de pizza. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao conectar-se à API: $e');
    }
  }

  Future<List<String>> fetchCidades() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/vendas/por-cidade'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        final maisVenderam = List<Map<String, dynamic>>.from(data['cidadesQueMaisVenderam']);
        final menosVenderam = List<Map<String, dynamic>>.from(data['cidadesQueMenosVenderam']);

        // Concatena as cidades de mais e menos vendas, eliminando duplicadas
        final todasCidades = [
          ...maisVenderam.map((c) => c['cidade'] ?? 'Desconhecida'), // Adiciona valor padrão caso seja nulo
          ...menosVenderam.map((c) => c['cidade'] ?? 'Desconhecida') // Adiciona valor padrão caso seja nulo
        ].toSet().toList(); // Remove duplicados com toSet()

        return List<String>.from(todasCidades);
      } else {
        throw Exception('Formato inesperado na resposta da API');
      }
    } else {
      throw Exception('Erro ao buscar cidades');
    }
  }

  Future<List<ClienteMaisComprou>> fetchClientesMaisCompraram(int mes) async {
    final url = 'http://10.0.2.2:3000/clientes-frequentes/$mes';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => ClienteMaisComprou.fromJson(json)).toList();
      } else {
        print('Erro ao buscar clientes: ${response.statusCode}');
        throw Exception('Erro ao buscar clientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchProdutosMaisVendidosMes(int mes) async {
    try {
      final url = Uri.parse("http://10.0.2.2:3000/produtos-mais-vendidos?mes=$mes"); // Usando IP correto
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return data;
        } else {
          throw Exception("Nenhum dado encontrado para o mês $mes.");
        }
      } else {
        throw Exception("Erro ao buscar dados: ${response.reasonPhrase} (Código: ${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Erro ao conectar à API: $e");
    }
  }

  Future<List<dynamic>> fetchProdutosMaisVendidosPorMes(int mes) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/produtos-mais-vendidos-mes/$mes'));

    print('Status Code: ${response.statusCode}');
    print('Resposta da API: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List.from(data); // Converte a resposta em uma lista
    } else {
      throw Exception('Erro ao buscar produtos mais vendidos por mês: ${response.body}');
    }
  }

  // Função para buscar dados do gráfico de pizza
  Future<List<double>> fetchPieChartDataByMonth(String month) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/piechart-data/$month'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<double>.from(data['values']); // Supondo {"values": [40, 30, 15, 15]}
      } else {
        throw Exception('Erro ao carregar dados do gráfico: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar dados do gráfico: $e');
      throw Exception('Erro ao carregar dados do gráfico');
    }
  }

  // Função para buscar os top produtos no mês
  Future<List<Map<String, dynamic>>> fetchTopProductsByMonth(String month) async {
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:3000/top-products/$month'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Erro ao carregar dados dos produtos mais vendidos');
      }
    } catch (e) {
      print('Erro ao buscar dados dos produtos: $e');
      throw Exception('Erro ao carregar dados dos produtos mais vendidos');
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
  final String descricaoProduto;
  final int totalVendido;

  ProdutoMaisVendido({
    required this.descricaoProduto,
    required this.totalVendido,
  });

  factory ProdutoMaisVendido.fromJson(Map<String, dynamic> json) {
    return ProdutoMaisVendido(
      descricaoProduto: json['descricao_produto'] ?? '', // Garantir que nunca seja null
      totalVendido: (json['total_vendido'] ?? 0) is int
          ? json['total_vendido']
          : (json['total_vendido'] as num?)?.toInt() ?? 0, // Garantir que o valor seja um int
    );
  }
}

class ClienteMaisComprou {
  final int idCliente;
  final String razaoCliente;
  final double totalCompras;

  ClienteMaisComprou({
    required this.idCliente,
    required this.razaoCliente,
    required this.totalCompras,
  });

  factory ClienteMaisComprou.fromJson(Map<String, dynamic> json) {
    return ClienteMaisComprou(
      idCliente: json['id_cliente'] as int,
      razaoCliente: json['razao_cliente'] as String,
      totalCompras: _parseTotalCompras(json['total_compras']),
    );
  }

  // Função para tratar a conversão do total_compras
  static double _parseTotalCompras(dynamic value) {
    if (value is String) {
      return double.tryParse(value) ?? 0.0; // Tenta converter a string para double, se não, retorna 0.0
    } else if (value is num) {
      return value.toDouble(); // Se já for num (int ou double), converte para double
    } else {
      return 0.0; // Caso o valor seja nulo ou de outro tipo inesperado
    }
  }
}

class CidadeVendas {
  final String cidade;
  final String uf;
  final String total_vendas;

  CidadeVendas({
    required this.cidade,
    required this.uf,
    required this.total_vendas,
  });

  factory CidadeVendas.fromJson(Map<String, dynamic> json) {
    return CidadeVendas(
      cidade: json['cidade'],
      uf: json['uf'],
      total_vendas: json['total_vendas'],
    );
  }
}

class VendasPorCidade {
  final String cidade;
  final double totalVendas;

  VendasPorCidade({required this.cidade, required this.totalVendas});

  factory VendasPorCidade.fromJson(Map<String, dynamic> json) {
    return VendasPorCidade(
      cidade: json['cidade'],
      totalVendas: double.parse(json['total_vendas']),
    );
  }
}







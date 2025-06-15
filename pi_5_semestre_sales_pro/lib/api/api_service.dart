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

  // Método para obter as cidades que mais venderam
  Future<List<Map<String, dynamic>>> fetchCidadesMaisVenderam(int mes) async {
    final url = 'http://10.0.2.2:3000/cidades-mais-venderam-mes/$mes'; // URL correta com o parâmetro mes
    print('Fazendo requisição para: $url'); // Verifique a URL no console

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('Erro ao buscar cidades: ${response.statusCode}');
        throw Exception('Falha ao carregar cidades: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro na requisição: $e');
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

  Future<List<TicketMedio>> fetchTicketMedio() async {
    final response = await http.get(
      Uri.parse('${baseUrl}analises/ticket-medio'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TicketMedio.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar dados de ticket médio');
    }
  }

  Future<List<TicketMedioProduto>> fetchTicketMedioPorProduto() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/analises/ticket-medio-produto'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TicketMedioProduto.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar ticket médio por produto');
    }
  }

  Future<List<ProdutoRecomendado>> fetchRecomendacoes(int idCliente) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/recomendacoes/$idCliente'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProdutoRecomendado.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar recomendações de produtos');
    }
  }

  Future<List<ProdutoRecomendado>> fetchRecomendacoesCliente(int idCliente) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/analises/recomendacoes-cliente/$idCliente'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProdutoRecomendado.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar recomendações: ${response.statusCode}');
    }
  }

  Future<ProdutoDetalhado> fetchDetalhesProduto(String codigo) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/produtos/$codigo'));

    if (response.statusCode == 200) {
      return ProdutoDetalhado.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erro ao buscar detalhes do produto');
    }
  }

  Future<List<CidadeVenda>> fetchTopCidades() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:3000/desempenho-por-cidade'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CidadeVenda.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao buscar regiões com mais vendas');
    }
  }

  Future<Map<String, dynamic>?> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': senha}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Login bem-sucedido: $data');
        return data; // Aqui você pode retornar o token ou dados do usuário
      } else {
        print('Falha no login: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro na requisição: $e');
      return null;
    }
  }
}

class TicketMedioProduto {
  final String codigoProduto;
  final String descricaoProduto;
  final int qtdVendas;
  final double totalVendido;
  final double ticketMedio;

  TicketMedioProduto({
    required this.codigoProduto,
    required this.descricaoProduto,
    required this.qtdVendas,
    required this.totalVendido,
    required this.ticketMedio,
  });

  factory TicketMedioProduto.fromJson(Map<String, dynamic> json) {
    return TicketMedioProduto(
      codigoProduto: json['codigo_produto'].toString(),
      descricaoProduto: json['descricao_produto'],
      qtdVendas: json['qtd_vendas'],
      totalVendido: (json['total_vendido'] as num).toDouble(),
      ticketMedio: (json['ticket_medio'] as num).toDouble(),
    );
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
  final double totalVendido;

  ProdutoMaisVendido({
    required this.descricaoProduto,
    required this.totalVendido,
  });

  factory ProdutoMaisVendido.fromJson(Map<String, dynamic> json) {
    return ProdutoMaisVendido(
      descricaoProduto: json['descricao_produto'] ?? '',
      totalVendido: double.tryParse(json['total_vendido'].toString()) ?? 0.0,
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

class TicketMedio {
  final String cliente;
  final int totalVendas;
  final double totalGasto;
  final double ticketMedio;

  TicketMedio({
    required this.cliente,
    required this.totalVendas,
    required this.totalGasto,
    required this.ticketMedio,
  });

  factory TicketMedio.fromJson(Map<String, dynamic> json) {
    return TicketMedio(
      cliente: json['cliente'],
      totalVendas: json['total_vendas'],
      totalGasto: json['total_gasto'].toDouble(),
      ticketMedio: json['ticket_medio'].toDouble(),
    );
  }
}

class ProdutoRecomendado {
  final String codigoProduto;
  final String descricaoProduto;
  final int vezesComprado;
  final double probabilidade;

  ProdutoRecomendado({
    required this.codigoProduto,
    required this.descricaoProduto,
    required this.vezesComprado,
    required this.probabilidade,
  });

  factory ProdutoRecomendado.fromJson(Map<String, dynamic> json) {
    return ProdutoRecomendado(
      codigoProduto: json['codigo_produto'] ?? '',
      descricaoProduto: json['descricao_produto'] ?? '',
      vezesComprado: int.tryParse(json['vezes_comprado'].toString()) ?? 0,
      probabilidade: double.tryParse(json['probabilidade'].toString()) ?? 0.0,
    );
  }
}

class ProdutoDetalhado {
  final String codigoProduto;
  final String descricao;
  final String categoria;
  final double preco;

  ProdutoDetalhado({
    required this.codigoProduto,
    required this.descricao,
    required this.categoria,
    required this.preco,
  });

  factory ProdutoDetalhado.fromJson(Map<String, dynamic> json) {
    return ProdutoDetalhado(
      codigoProduto: json['codigo_produto'].toString(),
      descricao: json['descricao_produto'] ?? '',
      categoria: json['categoria'] ?? 'Não informada',
      preco: (json['preco'] ?? 0).toDouble(),
    );
  }
}

class CidadeVenda {
  final String nomeCidade;
  final double totalVendas;

  CidadeVenda({required this.nomeCidade, required this.totalVendas});

  factory CidadeVenda.fromJson(Map<String, dynamic> json) {
    return CidadeVenda(
      nomeCidade: json['cidade'] ?? 'Desconhecida',
      totalVendas: double.tryParse(json['total_vendas'].toString()) ?? 0.0,
    );
  }
}












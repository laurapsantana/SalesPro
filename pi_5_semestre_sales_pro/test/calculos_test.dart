import 'package:flutter_test/flutter_test.dart';


void main() {
  group('calcularTotalVendas', () {
    test('deve retornar o total correto com produtos válidos', () {
      final produtos = [
        {'descricao_produto': 'Produto A', 'total_vendido': 150.5},
        {'descricao_produto': 'Produto B', 'total_vendido': 200.0},
        {'descricao_produto': 'Produto C', 'total_vendido': 149.5},
      ];

      final resultado = calcularTotalVendas(produtos);

      expect(resultado, '500.00');
    });

    test('deve retornar 0.00 com lista vazia', () {
      final resultado = calcularTotalVendas([]);
      expect(resultado, '0.00');
    });

    test('deve ignorar produtos com valores nulos', () {
      final produtos = [
        {'descricao_produto': 'Produto A', 'total_vendido': null},
        {'descricao_produto': 'Produto B'}, // sem total_vendido
      ];

      final resultado = calcularTotalVendas(produtos);
      expect(resultado, '0.00');
    });
  });
}

calcularTotalVendas(List list) {
}

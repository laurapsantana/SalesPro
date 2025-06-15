import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';

import 'api_service_produtos_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  group('ApiService - fetchProdutosMaisVendidosPorMes', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    test('retorna lista de produtos mockada para um mês específico', () async {
      // Arrange
      const mes = 5;
      final produtosMock = [
        {
          'descricao_produto': 'Produto A',
          'total_vendas': 500.0,
        },
        {
          'descricao_produto': 'Produto B',
          'total_vendas': 300.0,
        },
      ];

      when(mockApiService.fetchProdutosMaisVendidosPorMes(mes))
          .thenAnswer((_) async => produtosMock);

      // Act
      final resultado = await mockApiService.fetchProdutosMaisVendidosPorMes(mes);

      // Assert
      expect(resultado, isA<List<Map<String, dynamic>>>());
      expect(resultado.length, 2);
      expect(resultado[0]['descricao_produto'], 'Produto A');
      expect(resultado[1]['total_vendas'], 300.0);
    });
  });
}

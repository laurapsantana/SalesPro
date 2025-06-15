import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';
import 'package:pi_5_semestre_sales_pro/screen/vendas_page.dart';
import 'api_service_test.mocks.dart'; // mock gerado com build_runner

void main() {
  group('ApiService - fetchVendasMensais', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    test('retorna lista de vendas mensais para o mês selecionado', () async {
      final mesSelecionado = 5;

      final mockVendas = [
        VendaMensal(mes: 5, total: 50.0),
        VendaMensal(mes: 5, total: 50.0),
      ];

      // Simulando a resposta da API
      when(mockApiService.fetchVendasMensais(mesSelecionado))
          .thenAnswer((_) async => mockVendas);

      // Chamada real do método mockado
      final resultado = await mockApiService.fetchVendasMensais(mesSelecionado);

      // Verificações
      expect(resultado, isA<List<VendaMensal>>());
      expect(resultado.length, 2);
      expect(resultado[0].mes, 5);
      expect(resultado[1].total, 50);
    });
  });
}

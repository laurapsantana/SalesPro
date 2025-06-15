import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';
import 'package:pi_5_semestre_sales_pro/screen/clients_page.dart';

import 'api_service_test.mocks.dart'; // este é o gerado pelo build_runner

@GenerateMocks([ApiService])
void main() {
  group('ApiService - fetchClientesMaisCompraram', () {
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
    });

    test('deve retornar uma lista de ClienteMaisComprou mockada', () async {
      // Arrange
      final mes = 5;

      final mockClientes = [
        ClienteMaisComprou(idCliente: 1, totalCompras: 1000.0, razaoCliente: 'Cliente A'),
        ClienteMaisComprou(idCliente: 2, totalCompras: 800.0, razaoCliente: 'Cliente B'),

      ];

      when(mockApiService.fetchClientesMaisCompraram(mes))
          .thenAnswer((_) async => mockClientes);

      // Act
      final result = await mockApiService.fetchClientesMaisCompraram(mes);

      // Assert
      expect(result, isA<List<ClienteMaisComprou>>());
      expect(result.length, 2);
      expect(result[0].idCliente, 1);
      expect(result[1].totalCompras, 800.0);
    });
  });
}

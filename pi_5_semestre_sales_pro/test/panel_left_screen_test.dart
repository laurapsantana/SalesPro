import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';


import 'panel_left_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  testWidgets('deve exibir total vendido e top produto com dados mockados', (WidgetTester tester) async {
    final mockApi = MockApiService();

    when(mockApi.fetchProdutosMaisVendidosPorMes(1)).thenAnswer((_) async => [
      {'descricao_produto': 'Produto A', 'total_vendas': 500.0},
      {'descricao_produto': 'Produto B', 'total_vendas': 300.0},
    ]);

    await tester.pumpWidget(MaterialApp(
      //home: PanelLeftScreen(apiService: mockApi),
    ));

    await tester.pumpAndSettle(); // espera o carregamento

    expect(find.text('R\$ 800.00'), findsOneWidget); // total vendido
    expect(find.text('Produto A'), findsWidgets);     // top produto
    expect(find.text('Top Produtos'), findsOneWidget);
  });
}

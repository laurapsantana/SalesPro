import 'package:flutter/material.dart';
import 'package:pi_5_semestre_sales_pro/screen/clients_page.dart';
import 'package:pi_5_semestre_sales_pro/screen/home_dashboard_page.dart';
import 'package:pi_5_semestre_sales_pro/screen/login_screen.dart';
import 'package:pi_5_semestre_sales_pro/screen/panel_left_screen.dart';
import 'package:pi_5_semestre_sales_pro/screen/ticket_medio_produto_page.dart';
import 'package:pi_5_semestre_sales_pro/screen/vendas_page.dart';
import 'resource/app_colors.dart';
import 'package:pi_5_semestre_sales_pro/screen/ticket_medio_page.dart';
import '../services/auth_service.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Painel do Administrador',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.purpleDark,
        primarySwatch: Colors.blue,
        canvasColor: AppColors.purpleLight,
      ),
      home: LoginPage(authService: authService),
      routes: {
        '/inicio': (context) => const HomeDashboardPage(),
        '/produtos': (context) => const PanelLeftScreen(),
        '/clientes': (context) => const ClientesPage(),
        '/vendas': (context) => const VendasPage(),
        '/ticket-medio': (context) => const TicketMedioPage(),
        '/ticket-medio-produto': (context) => const TicketMedioProdutoPage(),
      },
    );
  }
}

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:pi_5_semestre_sales_pro/resource/app_colors.dart';
import 'package:pi_5_semestre_sales_pro/screen/drawer_screen.dart';
import 'package:pi_5_semestre_sales_pro/screen/clients_page.dart';
import 'package:pi_5_semestre_sales_pro/screen/home_dashboard_page.dart';
import 'package:pi_5_semestre_sales_pro/widget/custom_app_bar.dart';
import 'package:pi_5_semestre_sales_pro/widget/responsive_layout.dart';
import 'screen/panel_left_screen.dart';
import 'screen/vendas_page.dart';
import 'screen/ticket_medio_page.dart';
import 'screen/ticket_medio_produto_page.dart';


class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  int currentIndex = 1;

  final List<Widget> _icons = const [
    Icon(Icons.add, size: 30),
    Icon(Icons.list, size: 30),
    Icon(Icons.compare_arrows, size: 30),
    Icon(Icons.show_chart, size: 30),
    Icon(Icons.bar_chart, size: 30),
    Icon(Icons.add_chart_outlined, size: 30)
  ];

  final List<Widget> _pages = [
    const HomeDashboardPage(),
    const PanelLeftScreen(),
    const ClientesPage(),
    const VendasPage(),
    const TicketMedioPage(),
    const TicketMedioProdutoPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size(double.infinity, 100),
          child: (ResponsiveLayout.isTinyLimit(context) ||
              ResponsiveLayout.isTinyHeightLimit(context))
              ? Container()
              : const CustomAppBar(),
        ),
        body: ResponsiveLayout(
          tiny: Container(),
          phone: _pages[currentIndex],
          tablet: const Row(
            children: [
              Expanded(child: HomeDashboardPage()),
              Expanded(child: PanelLeftScreen()),
              Expanded(child: ClientesPage()),
              Expanded(child: VendasPage()),
              Expanded(child: TicketMedioPage()),
              Expanded(child: TicketMedioProdutoPage())
            ],
          ),
          largeTablet: const Row(
            children: [
              Expanded(child: HomeDashboardPage()),
              Expanded(child: PanelLeftScreen()),
              Expanded(child: ClientesPage()),
              Expanded(child: VendasPage()),
              Expanded(child: TicketMedioPage()),
              Expanded(child: TicketMedioProdutoPage())
            ],
          ),
          computer: const Row(
            children: [
              Expanded(child: DrawerScreen()),
              Expanded(child: HomeDashboardPage()),
              Expanded(child: PanelLeftScreen()),
              Expanded(child: ClientesPage()),
              Expanded(child: VendasPage()),
              Expanded(child: TicketMedioPage()),
              Expanded(child: TicketMedioProdutoPage())
            ],
          ),
        ),
        drawer: const DrawerScreen(),
        bottomNavigationBar: ResponsiveLayout.isPhoneLimit(context)
            ? CurvedNavigationBar(
          backgroundColor: AppColors.purpleDark,
          color: Colors.white24,
          index: currentIndex,
          items: _icons,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        )
            : const SizedBox(),
      ),
    );
  }
}

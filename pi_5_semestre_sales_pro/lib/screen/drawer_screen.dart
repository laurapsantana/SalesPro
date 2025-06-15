import 'package:flutter/material.dart';
import 'package:pi_5_semestre_sales_pro/resource/app_colors.dart';
import 'package:pi_5_semestre_sales_pro/screen/home_dashboard_page.dart';
import 'package:pi_5_semestre_sales_pro/screen/panel_left_screen.dart';
import 'package:pi_5_semestre_sales_pro/screen/ticket_medio_page.dart';
import 'package:pi_5_semestre_sales_pro/screen/ticket_medio_produto_page.dart';
import '../resource/app_padding.dart';
import '../services/auth_service.dart';
import '../widget/responsive_layout.dart';
import 'login_screen.dart';

class ButtonsInfo {
  final String title;
  final IconData icon;

  ButtonsInfo({required this.title, required this.icon});
}

final List<ButtonsInfo> _buttonInfo = [
  ButtonsInfo(title: "Home", icon: Icons.home),
  ButtonsInfo(title: "Produtos", icon: Icons.personal_video_rounded),
  ButtonsInfo(title: "Vendas", icon: Icons.sell),
  ButtonsInfo(title: "Clientes", icon: Icons.people_alt),
  ButtonsInfo(title: "Ticket Médio por Cliente", icon: Icons.add_chart_rounded),
  ButtonsInfo(title: "Ticket Médio por Produto", icon: Icons.production_quantity_limits_rounded),
  ButtonsInfo(title: "Sair", icon: Icons.logout),
];

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  int _currentIndex = 0;

  List<Widget> _buildMenuItems() {
    return List.generate(
      _buttonInfo.length,
          (index) => Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: index == _currentIndex
                ? BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [
                AppColors.red.withOpacity(0.9),
                AppColors.orange.withOpacity(0.9),
              ]),
              boxShadow: [
                BoxShadow(
                  color: AppColors.red.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            )
                : BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.05),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: AppColors.orange.withOpacity(0.2),
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.pop(context);

                final selected = _buttonInfo[index].title.toLowerCase();

                switch (selected) {
                  case "home":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeDashboardPage(),
                      ),
                    );
                    break;
                  case "produtos":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PanelLeftScreen(),
                      ),
                    );
                    break;
                  case "ticket médio por cliente":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TicketMedioPage(),
                      ),
                    );
                    break;
                  case "ticket médio por produto":
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TicketMedioProdutoPage(),
                      ),
                    );
                    break;
                  case "sair":
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginPage(authService: AuthService()),
                      ),
                          (Route<dynamic> route) => false,
                    );
                    break;
                  default:
                    Navigator.pushNamed(context, '/$selected');
                }

                setState(() {
                  _currentIndex = index;
                });
              },
              child: ListTile(
                title: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: TextStyle(
                    color: index == _currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.9),
                    fontWeight:
                    index == _currentIndex ? FontWeight.bold : FontWeight.w400,
                    shadows: index != _currentIndex
                        ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      )
                    ]
                        : [],
                  ),
                  child: Text(_buttonInfo[index].title),
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(AppPadding.P10),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      _buttonInfo[index].icon,
                      key: ValueKey<int>(_currentIndex == index ? 1 : 0),
                      color: index == _currentIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.9),
                    ),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const Divider(color: Colors.white24, thickness: 0.2),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1C1C3A),
              Color(0xFF2D2D4A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.P10),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Olá! Administrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: !ResponsiveLayout.isComputer(context)
                      ? IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.orange),
                  )
                      : null,
                ),
                ..._buildMenuItems(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

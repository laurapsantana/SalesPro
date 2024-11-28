import 'package:flutter/material.dart';
import 'package:pi_5_semestre_sales_pro/resource/app_colors.dart';
import '../resource/app_padding.dart';
import '../widget/responsive_layout.dart';

class ButtonsInfo {
  final String title;
  final IconData icon;

  ButtonsInfo({required this.title, required this.icon});
}

final List<ButtonsInfo> _buttonInfo = [
  ButtonsInfo(title: "Inicio", icon: Icons.home),
  ButtonsInfo(title: "Vendas", icon: Icons.sell),
  ButtonsInfo(title: "Usuarios", icon: Icons.supervised_user_circle_rounded),
  ButtonsInfo(title: "logout", icon: Icons.logout),
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
            )
                : null,
            child: ListTile(
              title: Text(
                _buttonInfo[index].title,
                style: const TextStyle(color: Colors.white),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(AppPadding.P10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _buttonInfo[index].icon,
                    key: ValueKey<int>(_currentIndex == index ? 1 : 0),
                    color: Colors.white,
                  ),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/${_buttonInfo[index].title.toLowerCase()}');
                setState(() {
                  _currentIndex = index;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Divider(color: Colors.white, thickness: 0.1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.P10),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Menu Administrador',
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
    );
  }
}

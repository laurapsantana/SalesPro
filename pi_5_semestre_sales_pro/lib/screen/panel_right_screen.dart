import 'package:flutter/material.dart';
import '../resource/app_colors.dart';
import '../resource/app_padding.dart';
import '../widget/charts.dart';
import 'package:pi_5_semestre_sales_pro/api/api_service.dart';

class Product {
  String name;
  bool enable;
  Product({this.enable = true, required this.name});
}

class PanelRightScreen extends StatefulWidget {
  const PanelRightScreen({super.key});

  @override
  State<PanelRightScreen> createState() => _PanelRightScreenState();
}

class _PanelRightScreenState extends State<PanelRightScreen> {
  final List<Product> _products = [
    Product(name: "Taça de Vinho Tinto"),
    Product(name: "Taça de Chopp 500 ML"),
    Product(name: "Copo de Requeijão"),
    Product(name: "Caneca"),
    Product(name: "Copo"),
    Product(name: "Taça Champagne"),
    Product(name: "Xícara"),
    Product(name: "Xícara de Café"),
    Product(name: "Xícara de Chá"),
    Product(name: "Xícara Francesa"),
    Product(name: "Copo Stanley"),
    Product(name: "Taça de Chopp 700 ML"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppPadding.P10 / 2,
                top: AppPadding.P10 / 2,
                right: AppPadding.P10 / 2),
            child: Card(
              color: AppColors.purpleLight,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),

            ),
          ),
          const LineChartSample1(),
          Padding(
            padding: const EdgeInsets.only(
                left: AppPadding.P10 / 2,
                top: AppPadding.P10 / 2,
                right: AppPadding.P10 / 2,
                bottom: AppPadding.P10),
            child: Card(
              color: AppColors.purpleLight,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  ...List.generate(
                    _products.length,
                        (index) => SwitchListTile.adaptive(
                      title: Text(
                        _products[index].name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _products[index].enable,
                      onChanged: (newValue) {
                        setState(() {
                          _products[index].enable = newValue;
                        });
                        // Exibir Snackbar ou lógica adicional
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "${_products[index].name} está ${newValue ? 'habilitado' : 'desabilitado'}",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

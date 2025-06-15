import 'package:flutter/material.dart';

class MonthSelectorWidget extends StatelessWidget {
  final int? selectedMonth;
  final ValueChanged<int> onChanged;

  const MonthSelectorWidget({
    Key? key,
    required this.selectedMonth,
    required this.onChanged,
  }) : super(key: key);

  final List<int> months = const [1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      decoration: InputDecoration(
        labelText: "Selecione um mês",
        labelStyle: const TextStyle(color: Colors.white),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.indigo[900],
      ),
      dropdownColor: Colors.indigo[900],
      value: selectedMonth,
      onChanged: (int? value) {
        if (value != null) {
          onChanged(value);
        }
      },
      items: months
          .map((month) => DropdownMenuItem<int>(
        value: month,
        child: Text(
          "Mês $month",
          style: const TextStyle(color: Colors.white),
        ),
      ))
          .toList(),
    );
  }
}

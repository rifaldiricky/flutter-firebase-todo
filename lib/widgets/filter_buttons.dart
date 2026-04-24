import 'package:flutter/material.dart';

class FilterButtons extends StatelessWidget {
  final String filter;
  final Function(String) onChange;

  const FilterButtons({
    super.key,
    required this.filter,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(String text, String value) {
      return Padding(
        padding: EdgeInsets.all(5),

        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: filter == value ? Colors.blue : Colors.grey,
          ),
          onPressed: () => onChange(value),
          child: Text(text),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        button("Semua", "all"),
        button("Aktif", "active"),
        button("Selesai", "done"),
      ],
    );
  }
}

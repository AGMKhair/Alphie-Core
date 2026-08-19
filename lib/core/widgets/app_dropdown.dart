import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: labelText,
      ),
    );
  }
}

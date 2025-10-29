import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({super.key, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}

// lib/screens/dashboard/schedule/ItemDialog/fields/title_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TitleField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const TitleField({
    super.key,
    required this.controller,
    this.label = 'Title / Subject',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3F),
        prefixIcon: const Icon(Icons.menu_book, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

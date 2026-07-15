// lib/screens/dashboard/schedule/ItemDialog/fields/details_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailsField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const DetailsField({
    super.key,
    required this.controller,
    this.label = 'Details (optional)',
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3F),
        prefixIcon: const Icon(Icons.note, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

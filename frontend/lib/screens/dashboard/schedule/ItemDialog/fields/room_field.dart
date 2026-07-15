// lib/screens/dashboard/schedule/ItemDialog/fields/room_field.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const RoomField({
    super.key,
    required this.controller,
    this.label = 'Room',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3F),
        prefixIcon: const Icon(Icons.meeting_room, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

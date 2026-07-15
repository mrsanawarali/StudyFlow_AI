// lib/screens/dashboard/schedule/ItemDialog/fields/day_dropdown.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DayDropdown extends StatelessWidget {
  final String? selectedDay;
  final ValueChanged<String?> onChanged;

  const DayDropdown({
    super.key,
    required this.selectedDay,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedDay,
      dropdownColor: const Color(0xFF1B2660),
      decoration: InputDecoration(
        labelText: 'Day',
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1F3F),
        prefixIcon: const Icon(Icons.calendar_today, color: Colors.white70),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
          .map((d) => DropdownMenuItem(
        value: d,
        child: Text(d, style: GoogleFonts.poppins(color: Colors.white)),
      ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

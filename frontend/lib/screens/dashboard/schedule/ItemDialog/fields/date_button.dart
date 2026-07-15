// lib/screens/dashboard/schedule/ItemDialog/fields/date_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onPressed;
  final Color accentColor;

  const DateButton({
    super.key,
    required this.label,
    required this.date,
    required this.onPressed,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.calendar_today, color: Colors.white70),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          date == null ? label : "${date!.toLocal().toString().split(' ')[0]}",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: accentColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
    );
  }
}

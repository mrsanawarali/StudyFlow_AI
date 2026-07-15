// lib/screens/dashboard/schedule/ItemDialog/fields/time_button.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TimeButton extends StatelessWidget {
  final String label;
  final TimeOfDay? time;
  final VoidCallback onPressed;
  final Color accentColor;

  const TimeButton({
    super.key,
    required this.label,
    required this.time,
    required this.onPressed,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.access_time, color: Colors.white70),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          time == null ? label : time!.format(context),
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

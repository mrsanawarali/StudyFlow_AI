import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SemesterCard extends StatelessWidget {
  final String title;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;
  final Color color;
  final Color textColor;
  final bool shadow;

  const SemesterCard({
    super.key,
    required this.title,
    this.onDelete,
    this.onEdit,
    this.onTap,
    this.color = Colors.white,
    this.textColor = Colors.black87,
    this.shadow = false,
  });

  // Helper method for consistent circular icon style
  Widget buildCircularIcon(IconData icon, Color iconColor, VoidCallback onPressed) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 16, color: iconColor),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        splashRadius: 20,
        tooltip: icon == Icons.edit ? 'Edit' : 'Delete',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth =
    MediaQuery.of(context).size.width > 600 ? 200 : double.infinity;
    const double cardHeight = 100;

    return GestureDetector(
      onTap: onTap, //  now entire card responds to tap
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: shadow ? 6 : 2,
        shadowColor: Colors.black45,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              // Centered title
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              // Action icons
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null) ...[
                      buildCircularIcon(Icons.edit, const Color(0xFF1B2660), onEdit!),
                      const SizedBox(width: 8),
                    ],
                    if (onDelete != null)
                      buildCircularIcon(Icons.delete, Colors.red, onDelete!),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

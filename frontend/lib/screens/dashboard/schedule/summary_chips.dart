import 'package:flutter/material.dart';

class SummaryChips extends StatelessWidget {
  final String type;
  final VoidCallback onDelete;

  const SummaryChips({
    super.key,
    required this.type,
    required this.onDelete,
  });

  Color getTypeColor() {
    switch (type) {
      case 'Classes':
        return Colors.blueAccent;
      case 'Quizzes':
        return Colors.orangeAccent;
      case 'Assignments':
        return Colors.purpleAccent;
      case 'Others':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = getTypeColor();

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// Optional: extension to slightly darken colors
extension ColorBrightness on Color {
  Color darken([double amount = .1]) {
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

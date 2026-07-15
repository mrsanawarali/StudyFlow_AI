import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// Four-cell statistics row for the Semester Detail header.
class SemesterStatRow extends StatelessWidget {
  const SemesterStatRow({
    super.key,
    required this.subjects,
    required this.notes,
    required this.assignments,
    required this.quizzes,
  });

  final int subjects;
  final int notes;
  final int assignments;
  final int quizzes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _Cell(
            value: '$subjects',
            label: 'Subjects',
            icon: Icons.layers_outlined,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Cell(
            value: '$notes',
            label: 'Notes',
            icon: Icons.description_outlined,
            color: const Color(0xFF50E3C2),
          ),
          const SizedBox(width: AppSpacing.sm),
          _Cell(
            value: '$assignments',
            label: 'Tasks',
            icon: Icons.assignment_outlined,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          _Cell(
            value: '$quizzes',
            label: 'Quizzes',
            icon: Icons.quiz_outlined,
            color: const Color(0xFFAB47BC),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

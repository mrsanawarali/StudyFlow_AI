import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// Four-cell stat bar for the Subject Detail header.
class SubjectStatBar extends StatelessWidget {
  const SubjectStatBar({
    super.key,
    required this.notes,
    required this.assignments,
    required this.quizzes,
    required this.attendance,
  });

  final int notes;
  final int assignments;
  final int quizzes;
  final double attendance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          _StatCell(
              icon: Icons.description_outlined,
              value: '$notes',
              label: 'Notes',
              color: AppColors.secondary),
          const SizedBox(width: AppSpacing.xs),
          _StatCell(
              icon: Icons.assignment_outlined,
              value: '$assignments',
              label: 'Tasks',
              color: AppColors.warning),
          const SizedBox(width: AppSpacing.xs),
          _StatCell(
              icon: Icons.quiz_outlined,
              value: '$quizzes',
              label: 'Quizzes',
              color: const Color(0xFFAB47BC)),
          const SizedBox(width: AppSpacing.xs),
          _StatCell(
              icon: Icons.people_outline_rounded,
              value: '${attendance.round()}%',
              label: 'Attend.',
              color: AppColors.success),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.titleSmall.copyWith(
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

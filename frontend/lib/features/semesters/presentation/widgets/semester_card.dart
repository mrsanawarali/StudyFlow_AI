import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';

/// Premium semester card used in the Semester List screen.
class SemesterCard extends StatelessWidget {
  const SemesterCard({
    super.key,
    required this.semester,
    required this.onTap,
  });

  final MockSemester semester;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool completed = semester.progress >= 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(
            color: semester.isActive
                ? semester.color.withValues(alpha: 0.40)
                : AppColors.outlineVariant,
            width: semester.isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: semester.color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Coloured header strip ──────────────────────────────────
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: semester.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name row + status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              semester.name,
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              semester.academicYear,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${semester.startDate} – ${semester.endDate}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatusBadge(
                        isActive: semester.isActive,
                        completed: completed,
                        color: semester.color,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.layers_outlined,
                        value: '${semester.subjects.length}',
                        label: 'Subjects',
                        color: semester.color,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatPill(
                        icon: Icons.description_outlined,
                        value: '${semester.totalNotes}',
                        label: 'Notes',
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StatPill(
                        icon: Icons.assignment_outlined,
                        value: '${semester.totalAssignments}',
                        label: 'Assign',
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Progress bar + GPA
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${(semester.progress * 100).round()}%',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: semester.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            ClipRRect(
                              borderRadius: AppRadius.roundedFull,
                              child: LinearProgressIndicator(
                                value: semester.progress,
                                backgroundColor:
                                    semester.color.withValues(alpha: 0.12),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                        semester.color),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (semester.gpa > 0) ...[
                        const SizedBox(width: AppSpacing.lg),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              semester.gpa.toStringAsFixed(2),
                              style: AppTypography.titleLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'GPA',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Open button
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.tonal(
                      onPressed: onTap,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            semester.color.withValues(alpha: 0.12),
                        foregroundColor: semester.color,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedLg,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Open',
                            style: AppTypography.labelMedium.copyWith(
                              color: semester.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Icon(Icons.arrow_forward_rounded,
                              size: 14, color: semester.color),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Small internal widgets ────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.isActive,
    required this.completed,
    required this.color,
  });
  final bool isActive;
  final bool completed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String label =
        isActive ? 'Active' : (completed ? 'Completed' : 'Upcoming');
    final Color bg = isActive
        ? AppColors.success.withValues(alpha: 0.12)
        : completed
            ? AppColors.secondary.withValues(alpha: 0.10)
            : AppColors.warning.withValues(alpha: 0.10);
    final Color fg = isActive
        ? AppColors.success
        : completed
            ? AppColors.secondary
            : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
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
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedMd,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '$value $label',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurface,
                  fontSize: 10,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

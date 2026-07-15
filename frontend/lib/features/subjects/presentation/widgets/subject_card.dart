import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';

/// Premium subject card shown in the Subject List screen.
class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    required this.detail,
    required this.onTap,
  });

  final MockSemesterSubject subject;
  final MockSubjectDetail detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: subject.color.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Colour strip
            Container(
              height: 5,
              decoration: BoxDecoration(
                color: subject.color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Code badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: subject.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedMd,
                        ),
                        child: Text(
                          subject.code,
                          style: AppTypography.labelSmall.copyWith(
                            color: subject.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Credit hours
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: AppRadius.roundedMd,
                        ),
                        child: Text(
                          '${subject.creditHours} cr',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Grade or progress %
                      if (subject.grade != null)
                        _GradeBadge(grade: subject.grade!)
                      else
                        Text(
                          '${(subject.progress * 100).round()}%',
                          style: AppTypography.titleSmall.copyWith(
                            color: subject.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Subject name
                  Text(
                    subject.name,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Professor
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 13, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          subject.professor,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Progress bar
                  ClipRRect(
                    borderRadius: AppRadius.roundedFull,
                    child: LinearProgressIndicator(
                      value: subject.progress,
                      backgroundColor:
                          subject.color.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          subject.color),
                      minHeight: 5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Stats row (wraps automatically)
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      _MiniStat(
                        icon: Icons.description_outlined,
                        value: '${subject.notesCount}',
                        label: 'Notes',
                        color: AppColors.secondary,
                      ),
                      _MiniStat(
                        icon: Icons.assignment_outlined,
                        value: '${detail.assignments.length}',
                        label: 'Tasks',
                        color: AppColors.warning,
                      ),
                      _MiniStat(
                        icon: Icons.quiz_outlined,
                        value: '${detail.quizzes.length}',
                        label: 'Quizzes',
                        color: const Color(0xFFAB47BC),
                      ),
                      _MiniStat(
                        icon: Icons.people_outline_rounded,
                        value: '${detail.attendancePercent.round()}%',
                        label: 'Attend.',
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Open button — full width right-aligned
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: subject.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.roundedLg,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Open',
                              style: AppTypography.labelSmall.copyWith(
                                color: subject.color,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.arrow_forward_rounded,
                                size: 12, color: subject.color),
                          ],
                        ),
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

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.grade});
  final String grade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedFull,
      ),
      child: Text(
        grade,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 2),
        Text(
          '$value $label',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

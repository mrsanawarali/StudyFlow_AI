import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';

/// Study progress card: goal hours vs studied hours + topic list.
class SubjectProgressCard extends StatelessWidget {
  const SubjectProgressCard({
    super.key,
    required this.detail,
    required this.subjectColor,
  });

  final MockSubjectDetail detail;
  final Color subjectColor;

  @override
  Widget build(BuildContext context) {
    final frac = (detail.studiedHours / detail.studyGoalHours).clamp(0.0, 1.0);
    final pct = (frac * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Study Progress',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${detail.studiedHours}h / ${detail.studyGoalHours}h',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.roundedFull,
                    child: LinearProgressIndicator(
                      value: frac,
                      backgroundColor:
                          subjectColor.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          subjectColor),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '$pct%',
                  style: AppTypography.labelMedium.copyWith(
                    color: subjectColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Recent topics
            Text(
              'Recent Topics',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: detail.recentTopics.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: subjectColor.withValues(alpha: 0.08),
                    borderRadius: AppRadius.roundedFull,
                    border: Border.all(
                      color: subjectColor.withValues(alpha: 0.20),
                    ),
                  ),
                  child: Text(
                    t,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onSurface,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

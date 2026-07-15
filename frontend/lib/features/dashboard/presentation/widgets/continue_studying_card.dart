import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

/// "Continue studying" hero card showing the most-in-progress subject.
class ContinueStudyingCard extends StatelessWidget {
  const ContinueStudyingCard({super.key, required this.subject});

  final MockSubject subject;

  @override
  Widget build(BuildContext context) {
    final int pct = (subject.progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
            ],
          ),
          borderRadius: AppRadius.roundedXl,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: label + percentage chip
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.onPrimary.withValues(alpha: 0.15),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    'Continue studying',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '$pct%',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Subject name + code
            Text(
              subject.name,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${subject.code} · ${subject.professor}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.70),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.roundedFull,
              child: LinearProgressIndicator(
                value: subject.progress,
                backgroundColor:
                    AppColors.onPrimary.withValues(alpha: 0.20),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.tertiary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Continue button
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor:
                      AppColors.onPrimary.withValues(alpha: 0.18),
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedLg,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continue',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

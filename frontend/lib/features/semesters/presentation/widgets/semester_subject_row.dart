import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';

/// A subject row card inside a Semester Detail screen.
class SemesterSubjectRow extends StatelessWidget {
  const SemesterSubjectRow({
    super.key,
    required this.subject,
    this.onTap,
  });

  final MockSemesterSubject subject;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: subject.color.withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedLg,
            ),
            child: Center(
              child: Text(
                subject.code.split('-').last,
                style: AppTypography.labelSmall.copyWith(
                  color: subject.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          title: Text(
            subject.name,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.professor,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: AppRadius.roundedFull,
                child: LinearProgressIndicator(
                  value: subject.progress,
                  backgroundColor:
                      subject.color.withValues(alpha: 0.12),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(subject.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (subject.grade != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    subject.grade!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  '${(subject.progress * 100).round()}%',
                  style: AppTypography.labelSmall.copyWith(
                    color: subject.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${subject.notesCount} notes',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

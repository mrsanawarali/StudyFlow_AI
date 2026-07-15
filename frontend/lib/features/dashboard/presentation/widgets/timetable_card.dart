import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

/// Horizontal scrollable list of today's timetable entries.
class TimetableSection extends StatelessWidget {
  const TimetableSection({super.key, required this.entries});

  final List<MockTimetableEntry> entries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: entries.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => _TimetableChip(entry: entries[i]),
      ),
    );
  }
}

class _TimetableChip extends StatelessWidget {
  const _TimetableChip({required this.entry});

  final MockTimetableEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      decoration: BoxDecoration(
        color: entry.isNext
            ? entry.color.withValues(alpha: 0.12)
            : AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(
          color: entry.isNext ? entry.color : AppColors.outlineVariant,
          width: entry.isNext ? 1.5 : 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,   // size to content, no stretch
        children: [
          // Dot + "Next" label row
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: entry.color,
                  shape: BoxShape.circle,
                ),
              ),
              if (entry.isNext) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Next',
                  style: AppTypography.labelSmall.copyWith(
                    color: entry.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),

          // Subject name
          Text(
            entry.subject,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),

          // Time
          Text(
            '${entry.startTime} – ${entry.endTime}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),

          // Room
          Text(
            entry.room,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

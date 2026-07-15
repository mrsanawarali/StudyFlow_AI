import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

/// Timetable tab — shows today's schedule in a full-page timeline.
class TimetableTab extends StatelessWidget {
  const TimetableTab({super.key});

  static const List<String> _days = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  @override
  Widget build(BuildContext context) {
    final todayIdx = DateTime.now().weekday - 1; // 0 = Monday

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Timetable',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: AppColors.secondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Day selector
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              itemCount: 7,
              itemBuilder: (ctx, i) {
                final isSelected = i == todayIdx;
                return GestureDetector(
                  onTap: () {},
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    margin: const EdgeInsets.only(right: AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: AppRadius.roundedLg,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outlineVariant,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _days[i],
                          style: AppTypography.labelSmall.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${i + 1}',
                          style: AppTypography.titleSmall.copyWith(
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Classes list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: MockDashboardData.todayTimetable.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (ctx, i) {
                final e = MockDashboardData.todayTimetable[i];
                return Container(
                  decoration: BoxDecoration(
                    color: e.isNext
                        ? e.color.withValues(alpha: 0.08)
                        : AppColors.surface,
                    borderRadius: AppRadius.roundedXl,
                    border: Border.all(
                      color: e.isNext ? e.color : AppColors.outlineVariant,
                      width: e.isNext ? 1.5 : 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: e.color.withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(Icons.class_outlined,
                          color: e.color, size: 22),
                    ),
                    title: Text(e.subject,
                        style: AppTypography.titleSmall.copyWith(
                            color: AppColors.onSurface)),
                    subtitle: Text(
                      '${e.startTime} – ${e.endTime}  ·  ${e.room}',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant),
                    ),
                    trailing: e.isNext
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 3),
                            decoration: BoxDecoration(
                              color: e.color.withValues(alpha: 0.15),
                              borderRadius: AppRadius.roundedFull,
                            ),
                            child: Text('Next',
                                style: AppTypography.labelSmall.copyWith(
                                    color: e.color,
                                    fontWeight: FontWeight.w700)),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

/// Single deadline / assignment row card.
class DeadlineCard extends StatelessWidget {
  const DeadlineCard({super.key, required this.assignment});

  final MockAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final daysLeft = assignment.dueDate
        .difference(DateTime.now())
        .inDays;

    final Color priorityColor = switch (assignment.priority) {
      AssignmentPriority.high => AppColors.error,
      AssignmentPriority.medium => AppColors.warning,
      AssignmentPriority.low => AppColors.success,
    };

    final String priorityLabel = switch (assignment.priority) {
      AssignmentPriority.high => 'High',
      AssignmentPriority.medium => 'Medium',
      AssignmentPriority.low => 'Low',
    };

    final String dueText = daysLeft == 0
        ? 'Due today'
        : daysLeft == 1
            ? 'Due tomorrow'
            : 'Due in $daysLeft days';

    return Container(
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedMd,
          ),
          child: Icon(
            Icons.assignment_outlined,
            color: priorityColor,
            size: 20,
          ),
        ),
        title: Text(
          assignment.title,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          assignment.subject,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedFull,
              ),
              child: Text(
                priorityLabel,
                style: AppTypography.labelSmall.copyWith(
                  color: priorityColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              dueText,
              style: AppTypography.labelSmall.copyWith(
                color: daysLeft <= 1
                    ? AppColors.error
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

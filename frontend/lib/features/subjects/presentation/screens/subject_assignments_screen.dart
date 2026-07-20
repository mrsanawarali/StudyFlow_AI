import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';

/// Phase 2E — Subject Assignments placeholder screen.
class SubjectAssignmentsScreen extends StatelessWidget {
  const SubjectAssignmentsScreen({super.key, required this.subjectId});
  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final detail = MockSubjectData.getById(subjectId);
    final assignments = detail.assignments;
    final pending = assignments.where((a) => !a.isSubmitted).length;
    final submitted = assignments.where((a) => a.isSubmitted).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assignments',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.onSurface)),
            Text(detail.name,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.warning),
            onPressed: () {},
          ),
        ],
      ),
      body: assignments.isEmpty
          ? _EmptyAssignments()
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Summary chips
                Row(
                  children: [
                    _SummaryChip(
                      label: '$pending Pending',
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _SummaryChip(
                      label: '$submitted Submitted',
                      color: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ...assignments.map((a) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: GestureDetector(
                        onTap: () => context.push(
                          RoutePaths.assignmentDetailPath(a.id),
                        ),
                        child: _AssignmentCard(assignment: a),
                      ),
                    )),
              ],
            ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: AppRadius.roundedFull,
        border:
            Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(label,
          style: AppTypography.labelMedium
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment});
  final MockSubjectAssignment assignment;

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        assignment.dueDate.difference(DateTime.now()).inDays;
    final priorityColor = switch (assignment.priority) {
      'high' => AppColors.error,
      'medium' => AppColors.warning,
      _ => AppColors.success,
    };

    return Container(
      decoration: BoxDecoration(
        color: assignment.isSubmitted
            ? AppColors.success.withValues(alpha: 0.04)
            : AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(
          color: assignment.isSubmitted
              ? AppColors.success.withValues(alpha: 0.30)
              : AppColors.outlineVariant,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (assignment.isSubmitted
                      ? AppColors.success
                      : priorityColor)
                  .withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedMd,
            ),
            child: Icon(
              assignment.isSubmitted
                  ? Icons.check_circle_outline_rounded
                  : Icons.assignment_outlined,
              color: assignment.isSubmitted
                  ? AppColors.success
                  : priorityColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assignment.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.onSurface,
                    decoration: assignment.isSubmitted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.10),
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(
                        assignment.priority.toUpperCase(),
                        style: AppTypography.labelSmall.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${assignment.totalMarks} marks',
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (assignment.isSubmitted && assignment.marks != null)
                Text(
                  '${assignment.marks}/${assignment.totalMarks}',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                Text(
                  daysLeft < 0
                      ? 'Overdue'
                      : daysLeft == 0
                          ? 'Today'
                          : '$daysLeft days',
                  style: AppTypography.labelSmall.copyWith(
                    color: daysLeft <= 0
                        ? AppColors.error
                        : AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyAssignments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.10),
                borderRadius: AppRadius.roundedXl,
              ),
              child: const Icon(Icons.assignment_outlined,
                  color: AppColors.warning, size: 36),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('No assignments yet',
                style: AppTypography.titleMedium
                    .copyWith(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.xs),
            Text('Add your first assignment to track deadlines.',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/assignments/data/mock_assignments_data.dart';

/// Phase 2G — Global Assignments List Screen.
///
/// Shows all assignments across all subjects with filter tabs
/// (All / Pending / Submitted / Graded).
class AssignmentsListScreen extends StatefulWidget {
  const AssignmentsListScreen({super.key});

  @override
  State<AssignmentsListScreen> createState() =>
      _AssignmentsListScreenState();
}

class _AssignmentsListScreenState extends State<AssignmentsListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl =
      TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<MockAssignment> _tabData(int idx) {
    return switch (idx) {
      1 => MockAssignmentsData.pending,
      2 => MockAssignmentsData.submitted,
      3 => MockAssignmentsData.graded,
      _ => MockAssignmentsData.all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text('Assignments',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.onSurface)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.secondary),
                onPressed: () {},
              ),
            ],
            bottom: TabBar(
              controller: _tabCtrl,
              onTap: (_) => setState(() {}),
              labelStyle: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w700),
              unselectedLabelStyle: AppTypography.labelMedium,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.onSurfaceVariant,
              indicatorColor: AppColors.primary,
              indicatorWeight: 2,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Submitted'),
                Tab(text: 'Graded'),
              ],
            ),
          ),
        ],
        body: AnimatedBuilder(
          animation: _tabCtrl,
          builder: (context, _) {
            final items = _tabData(_tabCtrl.index);
            return _AssignmentListBody(
              assignments: items,
              onTap: (a) =>
                  context.push(RoutePaths.assignmentDetailPath(a.id)),
            );
          },
        ),
      ),
    );
  }
}

// ── List body ─────────────────────────────────────────────────────────────────

class _AssignmentListBody extends StatelessWidget {
  const _AssignmentListBody(
      {required this.assignments, required this.onTap});
  final List<MockAssignment> assignments;
  final ValueChanged<MockAssignment> onTap;

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedXl,
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: AppColors.warning, size: 32),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('No assignments here',
                  style: AppTypography.titleSmall
                      .copyWith(color: AppColors.onSurface)),
              const SizedBox(height: AppSpacing.xs),
              Text('Assignments will appear here when added.',
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    // Group by subject
    final Map<String, List<MockAssignment>> grouped = {};
    for (final a in assignments) {
      grouped.putIfAbsent(a.subject, () => []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      children: [
        // Summary row
        _SummaryRow(assignments: assignments),
        const SizedBox(height: AppSpacing.lg),

        // Grouped by subject
        for (final entry in grouped.entries) ...[
          _SubjectGroupHeader(
              subject: entry.key,
              color: entry.value.first.subjectColor),
          const SizedBox(height: AppSpacing.xs),
          ...entry.value.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AssignmentTile(
                    assignment: a, onTap: () => onTap(a)),
              )),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.assignments});
  final List<MockAssignment> assignments;

  @override
  Widget build(BuildContext context) {
    final pending =
        assignments.where((a) => a.status == AssignmentStatus.pending).length;
    final graded =
        assignments.where((a) => a.status == AssignmentStatus.graded).length;
    final overdue = assignments
        .where((a) =>
            a.status == AssignmentStatus.pending &&
            a.dueDate.isBefore(DateTime.now()))
        .length;

    return Row(
      children: [
        _SummaryChip(
            value: '${assignments.length}',
            label: 'Total',
            color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
            value: '$pending', label: 'Pending', color: AppColors.warning),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
            value: '$graded', label: 'Graded', color: AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        _SummaryChip(
            value: '$overdue', label: 'Overdue', color: AppColors.error),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip(
      {required this.value, required this.label, required this.color});
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
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: AppTypography.titleMedium.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Subject group header ──────────────────────────────────────────────────────

class _SubjectGroupHeader extends StatelessWidget {
  const _SubjectGroupHeader(
      {required this.subject, required this.color});
  final String subject;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.sm),
        Text(subject,
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurface, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ── Reusable assignment tile ──────────────────────────────────────────────────

class AssignmentTile extends StatelessWidget {
  const AssignmentTile(
      {super.key, required this.assignment, required this.onTap});

  final MockAssignment assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        assignment.dueDate.difference(DateTime.now()).inDays;

    final priorityColor = switch (assignment.priority) {
      AssignmentPriority.high => AppColors.error,
      AssignmentPriority.medium => AppColors.warning,
      AssignmentPriority.low => AppColors.success,
    };

    final priorityLabel = switch (assignment.priority) {
      AssignmentPriority.high => 'High',
      AssignmentPriority.medium => 'Medium',
      AssignmentPriority.low => 'Low',
    };

    final bool isSubmitted =
        assignment.status == AssignmentStatus.submitted ||
            assignment.status == AssignmentStatus.graded;

    final dueText = isSubmitted
        ? assignment.status == AssignmentStatus.graded
            ? '${assignment.obtainedMarks}/${assignment.totalMarks} marks'
            : 'Submitted'
        : daysLeft < 0
            ? 'Overdue by ${-daysLeft}d'
            : daysLeft == 0
                ? 'Due today'
                : 'Due in ${daysLeft}d';

    final dueColor = isSubmitted
        ? AppColors.success
        : daysLeft < 0
            ? AppColors.error
            : daysLeft <= 1
                ? AppColors.warning
                : AppColors.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSubmitted
              ? AppColors.success.withValues(alpha: 0.03)
              : AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(
            color: isSubmitted
                ? AppColors.success.withValues(alpha: 0.25)
                : AppColors.outlineVariant,
          ),
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
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isSubmitted ? AppColors.success : priorityColor)
                  .withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedLg,
            ),
            child: Icon(
              isSubmitted
                  ? Icons.check_circle_outline_rounded
                  : Icons.assignment_outlined,
              color: isSubmitted ? AppColors.success : priorityColor,
              size: 22,
            ),
          ),
          title: Text(
            assignment.title,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.onSurface,
              decoration:
                  isSubmitted ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${assignment.totalMarks} marks',
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.10),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text(priorityLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 9,
                    )),
              ),
              const SizedBox(height: 3),
              Text(dueText,
                  style: AppTypography.labelSmall.copyWith(
                      color: dueColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}

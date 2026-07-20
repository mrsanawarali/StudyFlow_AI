import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/assignments/data/mock_assignments_data.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';

/// Phase 2G — Assignment Detail Screen.
class AssignmentDetailScreen extends StatelessWidget {
  const AssignmentDetailScreen({super.key, required this.assignmentId});
  final String assignmentId;

  MockAssignment? get _assignment =>
      MockAssignmentsData.getById(assignmentId);

  String _fmtDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    final a = _assignment;

    if (a == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Assignment not found')),
      );
    }

    final daysLeft = a.dueDate.difference(DateTime.now()).inDays;
    final bool isSubmitted = a.status == AssignmentStatus.submitted ||
        a.status == AssignmentStatus.graded;

    final priorityColor = switch (a.priority) {
      AssignmentPriority.high => AppColors.error,
      AssignmentPriority.medium => AppColors.warning,
      AssignmentPriority.low => AppColors.success,
    };

    final statusColor = switch (a.status) {
      AssignmentStatus.pending => AppColors.warning,
      AssignmentStatus.submitted => AppColors.info,
      AssignmentStatus.graded => AppColors.success,
      AssignmentStatus.overdue => AppColors.error,
    };

    final statusLabel = switch (a.status) {
      AssignmentStatus.pending => 'Pending',
      AssignmentStatus.submitted => 'Submitted',
      AssignmentStatus.graded => 'Graded',
      AssignmentStatus.overdue => 'Overdue',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ───────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: a.subjectColor,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert_rounded),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      a.subjectColor,
                      a.subjectColor.withValues(alpha: 0.70),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xxl + AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Subject badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(a.subject,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(a.title,
                        style: AppTypography.headlineSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        )),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Due ${_fmtDate(a.dueDate)}  ·  ${a.totalMarks} marks',
                      style: AppTypography.bodySmall
                          .copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // ── Status + meta row ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      // Status chip
                      _Chip(label: statusLabel, color: statusColor),
                      const SizedBox(width: AppSpacing.sm),
                      // Priority chip
                      _Chip(
                        label: switch (a.priority) {
                          AssignmentPriority.high => 'High Priority',
                          AssignmentPriority.medium => 'Medium Priority',
                          AssignmentPriority.low => 'Low Priority',
                        },
                        color: priorityColor,
                      ),
                      const Spacer(),
                      // Due countdown
                      if (!isSubmitted)
                        Text(
                          daysLeft < 0
                              ? 'Overdue by ${-daysLeft}d'
                              : daysLeft == 0
                                  ? 'Due today!'
                                  : 'Due in ${daysLeft}d',
                          style: AppTypography.labelMedium.copyWith(
                            color: daysLeft <= 0
                                ? AppColors.error
                                : daysLeft <= 2
                                    ? AppColors.warning
                                    : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Marks card (if graded) ────────────────────────────────
                if (a.status == AssignmentStatus.graded &&
                    a.obtainedMarks != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            AppColors.success.withValues(alpha: 0.06),
                        borderRadius: AppRadius.roundedXl,
                        border: Border.all(
                            color: AppColors.success
                                .withValues(alpha: 0.30)),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                              size: 28),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Marks Obtained',
                                  style: AppTypography.labelMedium
                                      .copyWith(
                                          color: AppColors
                                              .onSurfaceVariant)),
                              Text(
                                '${a.obtainedMarks} / ${a.totalMarks}',
                                style: AppTypography.headlineSmall
                                    .copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Percentage circle
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.success
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${((a.obtainedMarks! / a.totalMarks) * 100).round()}%',
                                style:
                                    AppTypography.labelMedium.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (a.status == AssignmentStatus.graded)
                  const SizedBox(height: AppSpacing.lg),

                // ── Description ───────────────────────────────────────────
                SectionHeader(title: 'Description'),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.roundedXl,
                      border:
                          Border.all(color: AppColors.outlineVariant),
                    ),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      a.description,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.onSurface,
                        height: 1.7,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Marking rubric ────────────────────────────────────────
                SectionHeader(title: 'Marking Rubric'),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.roundedXl,
                      border:
                          Border.all(color: AppColors.outlineVariant),
                    ),
                    child: Column(
                      children: List.generate(a.rubric.length, (i) {
                        final isLast = i == a.rubric.length - 1;
                        return Column(
                          children: [
                            ListTile(
                              dense: true,
                              leading: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: a.subjectColor
                                      .withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: AppTypography.labelSmall
                                          .copyWith(
                                        color: a.subjectColor,
                                        fontWeight: FontWeight.w700,
                                      )),
                                ),
                              ),
                              title: Text(a.rubric[i],
                                  style: AppTypography.bodySmall
                                      .copyWith(
                                          color: AppColors.onSurface)),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 2),
                            ),
                            if (!isLast)
                              const Divider(
                                  height: 1,
                                  color: AppColors.outlineVariant,
                                  indent: AppSpacing.lg),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Attachments ───────────────────────────────────────────
                if (a.attachments.isNotEmpty) ...[
                  SectionHeader(title: 'Attachments'),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Column(
                      children: a.attachments.map((name) {
                        final isPdf = name.endsWith('.pdf');
                        final isDoc = name.endsWith('.docx');
                        return Container(
                          margin: const EdgeInsets.only(
                              bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.roundedLg,
                            border: Border.all(
                                color: AppColors.outlineVariant),
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: (isPdf
                                        ? AppColors.error
                                        : isDoc
                                            ? AppColors.info
                                            : AppColors.secondary)
                                    .withValues(alpha: 0.12),
                                borderRadius: AppRadius.roundedMd,
                              ),
                              child: Icon(
                                isPdf
                                    ? Icons.picture_as_pdf_outlined
                                    : Icons.insert_drive_file_outlined,
                                color: isPdf
                                    ? AppColors.error
                                    : isDoc
                                        ? AppColors.info
                                        : AppColors.secondary,
                                size: 18,
                              ),
                            ),
                            title: Text(name,
                                style: AppTypography.titleSmall
                                    .copyWith(
                                        color: AppColors.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            trailing: const Icon(
                                Icons.download_outlined,
                                color: AppColors.onSurfaceVariant,
                                size: 18),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // ── Submission notes ──────────────────────────────────────
                if (a.submissionNotes.isNotEmpty) ...[
                  SectionHeader(title: 'Feedback'),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.05),
                        borderRadius: AppRadius.roundedXl,
                        border: Border.all(
                            color:
                                AppColors.success.withValues(alpha: 0.25)),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                              Icons.comment_outlined,
                              color: AppColors.success,
                              size: 18),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              a.submissionNotes,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.onSurface,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                // ── Submit button (pending only) ──────────────────────────
                if (a.status == AssignmentStatus.pending)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.upload_outlined, size: 18),
                        label: Text('Submit Assignment',
                            style: AppTypography.labelLarge.copyWith(
                                color: AppColors.onPrimary)),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.roundedLg),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small chip widget ─────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedFull,
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(label,
          style: AppTypography.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';
import '../widgets/subject_progress_card.dart';
import '../widgets/subject_stat_bar.dart';

/// Phase 2E — Subject Detail Screen.
class SubjectDetailScreen extends StatelessWidget {
  const SubjectDetailScreen({super.key, required this.subjectId});
  final String subjectId;

  MockSubjectDetail get _detail => MockSubjectData.getById(subjectId);

  MockSemesterSubject? _semSubject(MockSubjectDetail d) {
    for (final sem in MockSemesterData.semesters) {
      for (final s in sem.subjects) {
        if (s.id == d.id) return s;
      }
    }
    return null;
  }

  String _semesterName(String semId) {
    try {
      return MockSemesterData.semesters
          .firstWhere((s) => s.id == semId)
          .name;
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = _detail;
    final semSubject = _semSubject(detail);
    final color = semSubject?.color ?? detail.color;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: color,
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
                      color,
                      color.withValues(alpha: 0.70),
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
                    // Code + credit hours badges
                    Row(
                      children: [
                        _HeroBadge(
                            label: detail.code, color: color),
                        const SizedBox(width: AppSpacing.xs),
                        _HeroBadge(
                          label: '${detail.creditHours} credit hrs',
                          color: color,
                        ),
                        const Spacer(),
                        if (semSubject?.grade != null)
                          _HeroBadge(
                            label: 'Grade: ${semSubject!.grade}',
                            color: AppColors.success,
                            textColor: AppColors.success,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Subject name
                    Text(
                      detail.name,
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    // Instructor + semester
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          detail.professor,
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.school_outlined,
                            size: 13, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          _semesterName(detail.semesterId),
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              title: Text(
                detail.name,
                style: AppTypography.titleSmall
                    .copyWith(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Stats bar
                SubjectStatBar(
                  notes: detail.notes.length,
                  assignments: detail.assignments.length,
                  quizzes: detail.quizzes.length,
                  attendance: detail.attendancePercent,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick actions
                SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: AppSpacing.md),
                _QuickActions(
                  subjectColor: color,
                  subjectId: subjectId,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Study progress + topics
                SectionHeader(title: 'Study Progress'),
                const SizedBox(height: AppSpacing.md),
                SubjectProgressCard(
                  detail: detail,
                  subjectColor: color,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Recent notes
                SectionHeader(
                  title: 'Recent Notes',
                  onSeeAll: () => context.push(
                    RoutePaths.subjectNotesPath(subjectId),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (detail.notes.isEmpty)
                  const _EmptyInline(
                    icon: Icons.description_outlined,
                    message: 'No notes yet. Add your first note.',
                  )
                else
                  ...detail.notes
                      .take(3)
                      .map((n) => _NoteRow(note: n, color: color)),
                const SizedBox(height: AppSpacing.xl),

                // Upcoming assignments
                SectionHeader(
                  title: 'Assignments',
                  onSeeAll: () => context.push(
                    RoutePaths.subjectAssignmentsPath(subjectId),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (detail.assignments.isEmpty)
                  const _EmptyInline(
                    icon: Icons.assignment_outlined,
                    message: 'No assignments yet.',
                  )
                else
                  ...detail.assignments
                      .take(3)
                      .map((a) => _AssignmentRow(
                          assignment: a, color: color)),
                const SizedBox(height: AppSpacing.xl),

                // Recent quizzes
                SectionHeader(
                  title: 'Quizzes',
                  onSeeAll: () => context.push(
                    RoutePaths.subjectQuizzesPath(subjectId),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (detail.quizzes.isEmpty)
                  const _EmptyInline(
                    icon: Icons.quiz_outlined,
                    message: 'No quizzes yet.',
                  )
                else
                  ...detail.quizzes
                      .take(3)
                      .map((q) =>
                          _QuizRow(quiz: q, color: color)),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions(
      {required this.subjectColor, required this.subjectId});
  final Color subjectColor;
  final String subjectId;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(
        icon: Icons.description_outlined,
        label: 'Notes',
        color: AppColors.secondary,
        onTap: () =>
            context.push(RoutePaths.subjectNotesPath(subjectId)),
      ),
      _QA(
        icon: Icons.assignment_outlined,
        label: 'Assignments',
        color: AppColors.warning,
        onTap: () => context
            .push(RoutePaths.subjectAssignmentsPath(subjectId)),
      ),
      _QA(
        icon: Icons.quiz_outlined,
        label: 'Quizzes',
        color: const Color(0xFFAB47BC),
        onTap: () =>
            context.push(RoutePaths.subjectQuizzesPath(subjectId)),
      ),
      _QA(
        icon: Icons.auto_awesome_outlined,
        label: 'Study AI',
        color: subjectColor,
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: actions
            .map(
              (a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs),
                  child: GestureDetector(
                    onTap: a.onTap,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color:
                                a.color.withValues(alpha: 0.12),
                            borderRadius: AppRadius.roundedXl,
                            border: Border.all(
                              color: a.color
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(a.icon,
                              color: a.color, size: 22),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          a.label,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.onSurface,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _QA {
  const _QA({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

// ── Note row ──────────────────────────────────────────────────────────────────

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.note, required this.color});
  final MockSubjectNote note;
  final Color color;

  String _fmt(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
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
            color: color.withValues(alpha: 0.10),
            borderRadius: AppRadius.roundedMd,
          ),
          child: Icon(Icons.description_outlined, color: color, size: 18),
        ),
        title: Text(
          note.title,
          style: AppTypography.titleSmall
              .copyWith(color: AppColors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          note.preview,
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(
              note.isFavorite
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color:
                  note.isFavorite ? AppColors.secondary : AppColors.outline,
              size: 16,
            ),
            Text(
              _fmt(note.updatedAt),
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Assignment row ────────────────────────────────────────────────────────────

class _AssignmentRow extends StatelessWidget {
  const _AssignmentRow(
      {required this.assignment, required this.color});
  final MockSubjectAssignment assignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final daysLeft =
        assignment.dueDate.difference(DateTime.now()).inDays;
    final priorityColor = switch (assignment.priority) {
      'high' => AppColors.error,
      'medium' => AppColors.warning,
      _ => AppColors.success,
    };
    final dueText = assignment.isSubmitted
        ? 'Submitted · ${assignment.marks}/${assignment.totalMarks}'
        : daysLeft == 0
            ? 'Due today'
            : daysLeft < 0
                ? 'Overdue'
                : 'Due in $daysLeft days';

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (assignment.isSubmitted
                    ? AppColors.success
                    : priorityColor)
                .withValues(alpha: 0.10),
            borderRadius: AppRadius.roundedMd,
          ),
          child: Icon(
            assignment.isSubmitted
                ? Icons.check_circle_outline_rounded
                : Icons.assignment_outlined,
            color: assignment.isSubmitted
                ? AppColors.success
                : priorityColor,
            size: 18,
          ),
        ),
        title: Text(
          assignment.title,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.onSurface,
            decoration: assignment.isSubmitted
                ? TextDecoration.lineThrough
                : null,
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
              child: Text(
                assignment.priority.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: priorityColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 9,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              dueText,
              style: AppTypography.labelSmall.copyWith(
                color: assignment.isSubmitted
                    ? AppColors.success
                    : (daysLeft <= 0
                        ? AppColors.error
                        : AppColors.onSurfaceVariant),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quiz row ──────────────────────────────────────────────────────────────────

class _QuizRow extends StatelessWidget {
  const _QuizRow({required this.quiz, required this.color});
  final MockSubjectQuiz quiz;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scoreColor = quiz.score == null
        ? AppColors.onSurfaceVariant
        : quiz.score! >= quiz.totalScore * 0.8
            ? AppColors.success
            : quiz.score! >= quiz.totalScore * 0.5
                ? AppColors.warning
                : AppColors.error;

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
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
            color: color.withValues(alpha: 0.10),
            borderRadius: AppRadius.roundedMd,
          ),
          child: Icon(Icons.quiz_outlined, color: color, size: 18),
        ),
        title: Text(
          quiz.title,
          style: AppTypography.titleSmall
              .copyWith(color: AppColors.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          quiz.isDone
              ? 'Completed'
              : 'Upcoming · ${quiz.date.day}/${quiz.date.month}/${quiz.date.year}',
          style: AppTypography.bodySmall
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
        trailing: quiz.isDone && quiz.score != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text(
                  '${quiz.score}/${quiz.totalScore}',
                  style: AppTypography.labelMedium.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.10),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text(
                  'Upcoming',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Empty inline ──────────────────────────────────────────────────────────────

class _EmptyInline extends StatelessWidget {
  const _EmptyInline({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.outline, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.bodySmall
                .copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ── Hero badge ────────────────────────────────────────────────────────────────

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.label,
    required this.color,
    this.textColor,
  });
  final String label;
  final Color color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: AppRadius.roundedFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

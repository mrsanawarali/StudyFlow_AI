import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/presentation/widgets/deadline_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/recent_note_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';
import '../widgets/semester_empty_state.dart';
import '../widgets/semester_stat_row.dart';
import '../widgets/semester_subject_row.dart';

/// Phase 2D — Semester Detail Screen.
///
/// Shows full details of a single semester: header, stats, subjects,
/// assignments, recent notes, and quick actions.
class SemesterDetailScreen extends StatelessWidget {
  const SemesterDetailScreen({super.key, required this.semesterId});

  final String semesterId;

  MockSemester _findSemester() {
    return MockSemesterData.semesters.firstWhere(
      (s) => s.id == semesterId,
      orElse: () => MockSemesterData.semesters.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semester = _findSemester();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible hero app bar ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: semester.color,
            foregroundColor: AppColors.onPrimary,
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
              // No title here — avoids double text during scroll transition
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      semester.color,
                      semester.color.withValues(alpha: 0.75),
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
                    _StatusChip(
                      isActive: semester.isActive,
                      completed: semester.progress >= 1.0,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      semester.name,
                      style: AppTypography.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 12, color: Colors.white70),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${semester.startDate} – ${semester.endDate}  ·  ${semester.academicYear}',
                          style: AppTypography.bodySmall.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
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
                // Progress bar
                _ProgressHeader(semester: semester),
                const SizedBox(height: AppSpacing.lg),

                // Stats
                SemesterStatRow(
                  subjects: semester.subjects.length,
                  notes: semester.totalNotes,
                  assignments: semester.totalAssignments,
                  quizzes: semester.totalQuizzes,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Quick actions
                SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: AppSpacing.md),
                _QuickActions(semesterColor: semester.color),
                const SizedBox(height: AppSpacing.xl),

                // Subjects
                SectionHeader(
                  title: 'Subjects',
                  onSeeAll: semester.subjects.isNotEmpty
                      ? () => context.push(
                            RoutePaths.subjectListPath(semesterId),
                          )
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                if (semester.subjects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: SemesterEmptyState(
                      icon: Icons.layers_outlined,
                      title: 'No subjects added',
                      subtitle:
                          'Add subjects to organise your notes and assignments.',
                      actionLabel: 'Add Subject',
                    ),
                  )
                else
                  ...semester.subjects.map(
                    (s) => SemesterSubjectRow(
                      subject: s,
                      onTap: () => context.push(
                        RoutePaths.subjectDetailPath(s.id),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),

                // Upcoming Deadlines
                SectionHeader(
                    title: 'Upcoming Deadlines', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.sm),
                ...MockSemesterData.semesterDeadlines
                    .take(3)
                    .map((a) => DeadlineCard(assignment: a)),
                const SizedBox(height: AppSpacing.xl),

                // Recent Notes
                SectionHeader(
                    title: 'Recent Notes', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    itemCount:
                        MockSemesterData.semesterRecentNotes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (ctx, i) => RecentNoteCard(
                      note:
                          MockSemesterData.semesterRecentNotes[i],
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

// ── Progress header bar ───────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.semester});
  final MockSemester semester;

  @override
  Widget build(BuildContext context) {
    final pct = (semester.progress * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedXl,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Semester Progress',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '$pct%',
                      style: AppTypography.titleSmall.copyWith(
                        color: semester.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (semester.gpa > 0) ...[
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'GPA ${semester.gpa.toStringAsFixed(2)}',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: AppRadius.roundedFull,
              child: LinearProgressIndicator(
                value: semester.progress,
                backgroundColor:
                    semester.color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(semester.color),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.semesterColor});
  final Color semesterColor;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(icon: Icons.note_add_outlined, label: 'Add Note',
          color: AppColors.secondary),
      _QA(icon: Icons.assignment_outlined, label: 'Add Task',
          color: AppColors.warning),
      _QA(icon: Icons.quiz_outlined, label: 'Add Quiz',
          color: const Color(0xFFAB47BC)),
      _QA(icon: Icons.layers_outlined, label: 'Add Subject',
          color: semesterColor),
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
                    onTap: () {},
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: a.color.withValues(alpha: 0.12),
                            borderRadius: AppRadius.roundedXl,
                            border: Border.all(
                              color: a.color.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Icon(a.icon, color: a.color, size: 22),
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
  const _QA(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;
}

// ── Status chip in hero ───────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive, required this.completed});
  final bool isActive;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final String label = isActive
        ? 'Active Semester'
        : completed
            ? 'Completed'
            : 'Upcoming';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.20),
        borderRadius: AppRadius.roundedFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

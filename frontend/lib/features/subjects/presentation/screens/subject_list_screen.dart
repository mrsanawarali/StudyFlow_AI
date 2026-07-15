import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';
import 'package:untitled/features/semesters/presentation/widgets/semester_empty_state.dart';
import 'package:untitled/features/subjects/data/mock_subject_data.dart';
import '../widgets/subject_card.dart';

/// Phase 2E — Subject List Screen.
///
/// Shows all subjects for the given semester.
class SubjectListScreen extends StatefulWidget {
  const SubjectListScreen({super.key, required this.semesterId});
  final String semesterId;

  @override
  State<SubjectListScreen> createState() => _SubjectListScreenState();
}

class _SubjectListScreenState extends State<SubjectListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  )..forward();

  MockSemester get _semester => MockSemesterData.semesters.firstWhere(
        (s) => s.id == widget.semesterId,
        orElse: () => MockSemesterData.semesters.first,
      );

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semester = _semester;
    final subjects = semester.subjects;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsible app bar with semester colour ──────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: semester.color,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded),
                onPressed: () {},
                tooltip: 'Add subject',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              titlePadding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    semester.name,
                    style: AppTypography.titleMedium
                        .copyWith(color: Colors.white),
                  ),
                  Text(
                    '${subjects.length} subjects',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      semester.color,
                      semester.color.withValues(alpha: 0.70),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Overview strip ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fade,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _OverviewStrip(semester: semester),
              ),
            ),
          ),

          // ── Subject cards ─────────────────────────────────────────────
          subjects.isEmpty
              ? const SliverFillRemaining(
                  child: SemesterEmptyState(
                    icon: Icons.layers_outlined,
                    title: 'No subjects yet',
                    subtitle:
                        'Add subjects to start organising your notes and assignments.',
                    actionLabel: 'Add Subject',
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final s = subjects[i];
                        final detail = MockSubjectData.getById(s.id);
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.md),
                          child: SubjectCard(
                            subject: s,
                            detail: detail,
                            onTap: () => context.push(
                              RoutePaths.subjectDetailPath(s.id),
                            ),
                          ),
                        );
                      },
                      childCount: subjects.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// ── Overview strip ────────────────────────────────────────────────────────────

class _OverviewStrip extends StatelessWidget {
  const _OverviewStrip({required this.semester});
  final MockSemester semester;

  @override
  Widget build(BuildContext context) {
    final completed =
        semester.subjects.where((s) => s.progress >= 1.0).length;
    final inProgress =
        semester.subjects.where((s) => s.progress > 0 && s.progress < 1.0).length;
    final avgProgress = semester.subjects.isEmpty
        ? 0.0
        : semester.subjects.fold(0.0, (a, s) => a + s.progress) /
            semester.subjects.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Cell(value: '${semester.subjects.length}', label: 'Total'),
          _Cell(value: '$inProgress', label: 'In Progress'),
          _Cell(value: '$completed', label: 'Done'),
          _Cell(
              value: '${(avgProgress * 100).round()}%',
              label: 'Avg Progress'),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

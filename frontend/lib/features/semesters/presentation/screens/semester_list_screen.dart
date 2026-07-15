import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/semesters/data/mock_semester_data.dart';
import '../widgets/semester_card.dart';
import '../widgets/semester_empty_state.dart';

/// Phase 2D — Semester List Screen.
///
/// Displays all semesters as premium cards.
/// Mock data only — no backend calls.
class SemesterListScreen extends StatefulWidget {
  const SemesterListScreen({super.key});

  @override
  State<SemesterListScreen> createState() => _SemesterListScreenState();
}

class _SemesterListScreenState extends State<SemesterListScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final semesters = MockSemesterData.semesters;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: AppColors.outlineVariant,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.onSurface),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Semesters',
              style: AppTypography.titleLarge
                  .copyWith(color: AppColors.onSurface),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded,
                    color: AppColors.secondary),
                onPressed: () {},
                tooltip: 'Add semester',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeController,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Summary banner ─────────────────────────────────
                    _SummaryBanner(semesters: semesters),
                    const SizedBox(height: AppSpacing.xl),

                    // ── Section label ──────────────────────────────────
                    Row(
                      children: [
                        Text(
                          'All Semesters',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${semesters.length} total',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ),

          // ── Semester cards ─────────────────────────────────────────────
          semesters.isEmpty
              ? const SliverFillRemaining(
                  child: SemesterEmptyState(
                    icon: Icons.school_outlined,
                    title: 'No semesters yet',
                    subtitle:
                        'Add your first semester to start organizing your studies.',
                    actionLabel: 'Add Semester',
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final s = semesters[i];
                        return Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.md),
                          child: SemesterCard(
                            semester: s,
                            onTap: () => context.push(
                              RoutePaths.semesterDetailPath(s.id),
                            ),
                          ),
                        );
                      },
                      childCount: semesters.length,
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

// ── Summary banner ────────────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.semesters});
  final List<MockSemester> semesters;

  @override
  Widget build(BuildContext context) {
    final completedCount = semesters.where((s) => !s.isActive).length;
    final activeCount = semesters.where((s) => s.isActive).length;
    final avgGpa = semesters
            .where((s) => s.gpa > 0)
            .fold(0.0, (sum, s) => sum + s.gpa) /
        (semesters.where((s) => s.gpa > 0).length.clamp(1, 999));

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
        borderRadius: AppRadius.roundedXl,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _BannerCell(
              value: '${semesters.length}',
              label: 'Total',
              icon: Icons.school_outlined,
            ),
          ),
          _BannerDivider(),
          Expanded(
            child: _BannerCell(
              value: '$activeCount',
              label: 'Active',
              icon: Icons.play_circle_outline_rounded,
            ),
          ),
          _BannerDivider(),
          Expanded(
            child: _BannerCell(
              value: '$completedCount',
              label: 'Done',
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
          _BannerDivider(),
          Expanded(
            child: _BannerCell(
              value: avgGpa.toStringAsFixed(2),
              label: 'Avg GPA',
              icon: Icons.stars_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerCell extends StatelessWidget {
  const _BannerCell(
      {required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.onPrimary.withValues(alpha: 0.75),
            size: 16),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }
}

class _BannerDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.onPrimary.withValues(alpha: 0.20),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}

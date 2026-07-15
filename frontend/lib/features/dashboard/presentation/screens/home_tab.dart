import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';
import 'package:untitled/features/dashboard/presentation/widgets/activity_timeline.dart';
import 'package:untitled/features/dashboard/presentation/widgets/ai_assistant_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/continue_studying_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/deadline_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/quick_actions_grid.dart';
import 'package:untitled/features/dashboard/presentation/widgets/recent_note_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/section_header.dart';
import 'package:untitled/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/timetable_card.dart';
import 'package:untitled/features/dashboard/presentation/widgets/weekly_progress_chart.dart';

/// Phase 2C — Premium Home Tab.
///
/// All data comes from [MockDashboardData]. No backend calls.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = MockDashboardData.user;
    final activeSubject = MockDashboardData.subjects.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: AppColors.outlineVariant,
            titleSpacing: AppSpacing.lg,
            title: Row(
              children: [
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                    ),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Center(
                    child: Text(
                      user.avatarInitials,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, ${user.name.split(' ').first} 👋',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user.semester,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Notification bell
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: AppColors.onSurface),
                      onPressed: () {},
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // ── Search bar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.roundedFull,
                        border:
                            Border.all(color: AppColors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: AppColors.onSurfaceVariant,
                              size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Search notes, subjects, assignments...',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Overview stats ─────────────────────────────────────
                SectionHeader(title: 'Overview', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.25,
                    children: const [
                      StatCard(
                        label: 'Subjects',
                        value: '5',
                        icon: Icons.layers_outlined,
                        color: AppColors.secondary,
                      ),
                      StatCard(
                        label: 'Notes',
                        value: '63',
                        icon: Icons.description_outlined,
                        color: Color(0xFF50E3C2),
                      ),
                      StatCard(
                        label: 'Assignments',
                        value: '12',
                        icon: Icons.assignment_outlined,
                        color: Color(0xFFFFA726),
                      ),
                      StatCard(
                        label: 'Quizzes',
                        value: '8',
                        icon: Icons.quiz_outlined,
                        color: Color(0xFFAB47BC),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Continue studying ──────────────────────────────────
                SectionHeader(
                    title: 'Continue Studying', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                ContinueStudyingCard(subject: activeSubject),
                const SizedBox(height: AppSpacing.xl),

                // ── Quick actions ──────────────────────────────────────
                SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: AppSpacing.md),
                const QuickActionsGrid(),
                const SizedBox(height: AppSpacing.xl),

                // ── Today's timetable ──────────────────────────────────
                SectionHeader(
                    title: "Today's Timetable", onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                TimetableSection(
                    entries: MockDashboardData.todayTimetable),
                const SizedBox(height: AppSpacing.xl),

                // ── Upcoming deadlines ─────────────────────────────────
                SectionHeader(
                    title: 'Upcoming Deadlines', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.sm),
                ...MockDashboardData.upcomingAssignments
                    .take(3)
                    .map((a) => DeadlineCard(assignment: a)),
                const SizedBox(height: AppSpacing.xl),

                // ── Recent notes ───────────────────────────────────────
                SectionHeader(title: 'Recent Notes', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 210,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    itemCount: MockDashboardData.recentNotes.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (ctx, i) => RecentNoteCard(
                        note: MockDashboardData.recentNotes[i]),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── AI Assistant ───────────────────────────────────────
                SectionHeader(title: 'AI Study Assistant'),
                const SizedBox(height: AppSpacing.md),
                const AIAssistantCard(),
                const SizedBox(height: AppSpacing.xl),

                // ── Weekly progress ────────────────────────────────────
                SectionHeader(title: 'Weekly Progress'),
                const SizedBox(height: AppSpacing.md),
                const WeeklyProgressChart(),
                const SizedBox(height: AppSpacing.xl),

                // ── Recent activity ────────────────────────────────────
                SectionHeader(
                    title: 'Recent Activity', onSeeAll: () {}),
                const SizedBox(height: AppSpacing.md),
                ActivityTimeline(
                    entries: MockDashboardData.recentActivity),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

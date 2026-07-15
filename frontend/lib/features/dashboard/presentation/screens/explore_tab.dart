import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import '../widgets/explore_widgets.dart';
import 'coming_soon_screen.dart';

/// Categorized Explore module hub (Phase 2F refactor).
///
/// Five categories: Academic · Tasks · Smart Tools · Collaboration · Utilities.
/// Implemented modules navigate to their real screens.
/// Unimplemented modules open [ComingSoonScreen].
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            titleSpacing: AppSpacing.lg,
            title: Text(
              'Explore',
              style: AppTypography.titleLarge
                  .copyWith(color: AppColors.onSurface),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded,
                    color: AppColors.onSurface),
                onPressed: () {},
              ),
            ],
          ),

          // ── Body ───────────────────────────────────────────────────────
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.sm),

              // ── 1. Academic ──────────────────────────────────────────
              AnimatedExploreSection(
                delay: const Duration(milliseconds: 0),
                child: _Category(
                  emoji: '📚',
                  title: 'Academic',
                  description: 'Manage all your academic content.',
                  color: AppColors.secondary,
                  modules: [
                    _Module(
                      icon: Icons.school_outlined,
                      title: 'Semesters',
                      subtitle: 'Browse and manage semesters',
                      color: AppColors.secondary,
                      onTap: () =>
                          context.push(RoutePaths.semesterList),
                    ),
                    _Module(
                      icon: Icons.layers_outlined,
                      title: 'Subjects',
                      subtitle: 'View subjects by semester',
                      color: const Color(0xFF50E3C2),
                      onTap: () =>
                          context.push(RoutePaths.semesterList),
                    ),
                    _Module(
                      icon: Icons.description_outlined,
                      title: 'Notes',
                      subtitle: 'All your study notes',
                      color: const Color(0xFFFFA726),
                      onTap: () =>
                          context.push(RoutePaths.notesList),
                    ),
                  ],
                ),
              ),

              // ── 2. Tasks ─────────────────────────────────────────────
              AnimatedExploreSection(
                delay: const Duration(milliseconds: 80),
                child: _Category(
                  emoji: '📝',
                  title: 'Tasks',
                  description: 'Track your academic work.',
                  color: AppColors.warning,
                  modules: [
                    _Module(
                      icon: Icons.assignment_outlined,
                      title: 'Assignments',
                      subtitle: 'Pending & submitted tasks',
                      color: AppColors.warning,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Assignments',
                        icon: Icons.assignment_outlined,
                        color: AppColors.warning,
                        description:
                            'A dedicated assignments hub is coming soon. You can view assignments per subject today.',
                      ),
                    ),
                    _Module(
                      icon: Icons.quiz_outlined,
                      title: 'Quizzes',
                      subtitle: 'Practice quizzes & scores',
                      color: const Color(0xFFAB47BC),
                      onTap: () => _comingSoon(
                        context,
                        title: 'Quizzes',
                        icon: Icons.quiz_outlined,
                        color: const Color(0xFFAB47BC),
                        description:
                            'A full quiz browser is coming soon. You can view quizzes per subject today.',
                      ),
                    ),
                  ],
                ),
              ),

              // ── 3. Smart Tools ───────────────────────────────────────
              AnimatedExploreSection(
                delay: const Duration(milliseconds: 160),
                child: _Category(
                  emoji: '🤖',
                  title: 'Smart Tools',
                  description: 'AI-powered learning tools.',
                  color: AppColors.tertiary,
                  modules: [
                    _Module(
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI Assistant',
                      subtitle: 'Ask AI anything about your studies',
                      color: AppColors.tertiary,
                      onTap: () => _comingSoon(
                        context,
                        title: 'AI Assistant',
                        icon: Icons.auto_awesome_outlined,
                        color: AppColors.tertiary,
                        description:
                            'The full AI Study Assistant will launch in Phase 3. Summarize, quiz, and explain with one tap.',
                      ),
                    ),
                    _Module(
                      icon: Icons.picture_as_pdf_outlined,
                      title: 'PDF Library',
                      subtitle: 'Store and annotate PDFs',
                      color: AppColors.error,
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'PDF Library',
                        icon: Icons.picture_as_pdf_outlined,
                        color: AppColors.error,
                      ),
                    ),
                    _Module(
                      icon: Icons.calendar_today_outlined,
                      title: 'Study Planner',
                      subtitle: 'AI-generated study schedules',
                      color: AppColors.info,
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Study Planner',
                        icon: Icons.calendar_today_outlined,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. Collaboration ─────────────────────────────────────
              AnimatedExploreSection(
                delay: const Duration(milliseconds: 240),
                child: _Category(
                  emoji: '🤝',
                  title: 'Collaboration',
                  description: 'Learn together.',
                  color: AppColors.success,
                  modules: [
                    _Module(
                      icon: Icons.share_outlined,
                      title: 'Shared Notes',
                      subtitle: 'Notes shared by your peers',
                      color: AppColors.success,
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Shared Notes',
                        icon: Icons.share_outlined,
                        color: AppColors.success,
                        description:
                            'Share and discover notes from your class. Coming in Phase 3.',
                      ),
                    ),
                    _Module(
                      icon: Icons.group_outlined,
                      title: 'Study Groups',
                      subtitle: 'Collaborate with classmates',
                      color: const Color(0xFF26C6DA),
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Study Groups',
                        icon: Icons.group_outlined,
                        color: const Color(0xFF26C6DA),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 5. Utilities ─────────────────────────────────────────
              AnimatedExploreSection(
                delay: const Duration(milliseconds: 320),
                child: _Category(
                  emoji: '⭐',
                  title: 'Utilities',
                  description: 'Helpful student tools.',
                  color: const Color(0xFFFFA726),
                  modules: [
                    _Module(
                      icon: Icons.how_to_reg_outlined,
                      title: 'Attendance',
                      subtitle: 'Track your class attendance',
                      color: const Color(0xFFFFA726),
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Attendance',
                        icon: Icons.how_to_reg_outlined,
                        color: const Color(0xFFFFA726),
                      ),
                    ),
                    _Module(
                      icon: Icons.folder_outlined,
                      title: 'Resources',
                      subtitle: 'Lecture slides, past papers',
                      color: const Color(0xFFAB47BC),
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Resources',
                        icon: Icons.folder_outlined,
                        color: const Color(0xFFAB47BC),
                      ),
                    ),
                    _Module(
                      icon: Icons.style_outlined,
                      title: 'Flashcards',
                      subtitle: 'Spaced repetition study cards',
                      color: AppColors.secondary,
                      isComingSoon: true,
                      onTap: () => _comingSoon(
                        context,
                        title: 'Flashcards',
                        icon: Icons.style_outlined,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
            ]),
          ),
        ],
      ),
    );
  }

  void _comingSoon(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    String? description,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(
          title: title,
          icon: icon,
          color: color,
          description: description,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal data classes (file-private)
// ─────────────────────────────────────────────────────────────────────────────

class _Module {
  const _Module({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isComingSoon = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isComingSoon;
}

class _Category extends StatelessWidget {
  const _Category({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    required this.modules,
  });

  final String emoji;
  final String title;
  final String description;
  final Color color;
  final List<_Module> modules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        ExploreSectionHeader(
          icon: emoji,
          title: title,
          description: description,
          color: color,
        ),

        // Module tiles inside a card
        ExploreCategoryCard(
          children: List.generate(modules.length, (i) {
            final m = modules[i];
            return ExploreModuleTile(
              icon: m.icon,
              title: m.title,
              subtitle: m.subtitle,
              color: m.color,
              onTap: m.onTap,
              isComingSoon: m.isComingSoon,
              isLast: i == modules.length - 1,
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/profile/data/mock_profile_data.dart';

/// Phase 2L — Premium Profile Tab.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockProfileData.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 1,
            titleSpacing: AppSpacing.lg,
            title: Text('Profile',
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.onSurface)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: AppColors.onSurface),
                onPressed: () => context.push(RoutePaths.settings),
                tooltip: 'Settings',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  // Avatar + info card
                  _ProfileHeroCard(user: user),
                  const SizedBox(height: AppSpacing.lg),

                  // Stats row
                  _StatsRow(),
                  const SizedBox(height: AppSpacing.lg),

                  // Achievements
                  _AchievementsSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Quick links
                  _QuickLinksSection(),
                  const SizedBox(height: AppSpacing.lg),

                  // Sign out
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go(RoutePaths.login),
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      label: Text('Sign Out',
                          style: AppTypography.labelLarge
                              .copyWith(color: AppColors.error)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.error),
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.roundedLg),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Hero Card ─────────────────────────────────────────────────────────
class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.user});
  final MockProfileUser user;

  @override
  Widget build(BuildContext context) {
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
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.onPrimary.withValues(alpha: 0.40),
                      width: 2),
                ),
                child: Center(
                  child: Text(user.avatarInitials,
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: AppTypography.titleLarge.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        )),
                    Text(user.email,
                        style: AppTypography.bodySmall.copyWith(
                            color: AppColors.onPrimary
                                .withValues(alpha: 0.75)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.onPrimary.withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedFull,
                      ),
                      child: Text(user.semester,
                          style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onPrimary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: AppColors.onPrimary),
                onPressed: () =>
                    context.push(RoutePaths.editProfile),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Bio
          if (user.bio.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.10),
                borderRadius: AppRadius.roundedLg,
              ),
              child: Text(user.bio,
                  style: AppTypography.bodySmall.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.80),
                      height: 1.5)),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          // University info chips
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _InfoChip(Icons.school_outlined, user.university),
              _InfoChip(Icons.code_rounded, user.department),
              _InfoChip(Icons.badge_outlined, user.studentId),
              _InfoChip(Icons.calendar_today_outlined,
                  'Joined ${user.joinedDate}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 11,
              color: AppColors.onPrimary.withValues(alpha: 0.75)),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                  fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBubble('${MockProfileData.totalNotes}', 'Notes',
            AppColors.secondary),
        const SizedBox(width: AppSpacing.sm),
        _StatBubble('${MockProfileData.totalQuizzes}', 'Quizzes',
            const Color(0xFFAB47BC)),
        const SizedBox(width: AppSpacing.sm),
        _StatBubble('${MockProfileData.studyDays}', 'Study Days',
            const Color(0xFFFFA726)),
        const SizedBox(width: AppSpacing.sm),
        _StatBubble(MockProfileData.cgpa.toStringAsFixed(2), 'CGPA',
            AppColors.success),
      ],
    );
  }
}

class _StatBubble extends StatelessWidget {
  const _StatBubble(this.value, this.label, this.color);
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Column(
          children: [
            Text(value,
                style: AppTypography.titleLarge.copyWith(
                    color: color, fontWeight: FontWeight.w700)),
            Text(label,
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ── Achievements ──────────────────────────────────────────────────────────────
class _AchievementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Achievements',
                style: AppTypography.titleMedium.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700)),
            Text(
                '${MockProfileData.achievements.where((a) => a.earned).length}/${MockProfileData.achievements.length}',
                style: AppTypography.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: MockProfileData.achievements.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
          ),
          itemBuilder: (ctx, i) {
            final a = MockProfileData.achievements[i];
            return Container(
              decoration: BoxDecoration(
                color: a.earned
                    ? a.color.withValues(alpha: 0.08)
                    : AppColors.surfaceVariant,
                borderRadius: AppRadius.roundedXl,
                border: Border.all(
                  color: a.earned
                      ? a.color.withValues(alpha: 0.30)
                      : AppColors.outlineVariant,
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon,
                      color: a.earned
                          ? a.color
                          : AppColors.outline,
                      size: 28),
                  const SizedBox(height: AppSpacing.xs),
                  Text(a.title,
                      style: AppTypography.labelSmall.copyWith(
                        color: a.earned
                            ? AppColors.onSurface
                            : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  if (!a.earned)
                    Text('Locked',
                        style: AppTypography.labelSmall.copyWith(
                            color: AppColors.outline, fontSize: 9)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Quick Links ───────────────────────────────────────────────────────────────
class _QuickLinksSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final links = [
      (Icons.school_outlined, 'My Semesters', AppColors.secondary,
          () => context.push(RoutePaths.semesterList)),
      (Icons.description_outlined, 'My Notes', const Color(0xFFFFA726),
          () => context.push(RoutePaths.notesList)),
      (Icons.assignment_outlined, 'Assignments', AppColors.error,
          () => context.push(RoutePaths.assignmentsList)),
      (Icons.calculate_outlined, 'Grade Calculator', AppColors.success,
          () {}),
      (Icons.auto_awesome_outlined, 'AI Assistant',
          AppColors.tertiary,
          () => context.push(RoutePaths.aiAssistant)),
      (Icons.settings_outlined, 'Settings',
          AppColors.onSurfaceVariant,
          () => context.push(RoutePaths.settings)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: List.generate(links.length, (i) {
          final (icon, label, color, onTap) = links[i];
          final isLast = i == links.length - 1;
          return Column(
            children: [
              ListTile(
                onTap: onTap,
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                title: Text(label,
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.onSurface)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant, size: 18),
                minLeadingWidth: 36,
              ),
              if (!isLast)
                const Divider(height: 1,
                    color: AppColors.outlineVariant,
                    indent: AppSpacing.lg),
            ],
          );
        }),
      ),
    );
  }
}

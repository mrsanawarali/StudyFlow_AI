import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/dashboard/data/mock_dashboard_data.dart';

/// Profile tab — student info + settings rows.
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockDashboardData.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Profile',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            // ── Avatar + name ────────────────────────────────────────
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: AppRadius.roundedXl,
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.onPrimary.withValues(alpha: 0.40),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.avatarInitials,
                        style: AppTypography.headlineSmall.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.name,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    user.university,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withValues(alpha: 0.15),
                      borderRadius: AppRadius.roundedFull,
                    ),
                    child: Text(
                      user.semester,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Stats row ────────────────────────────────────────────
            Row(
              children: [
                _StatBubble(
                    value: '${MockDashboardData.totalSubjects}',
                    label: 'Subjects'),
                const SizedBox(width: AppSpacing.sm),
                _StatBubble(
                    value: '${MockDashboardData.totalNotes}',
                    label: 'Notes'),
                const SizedBox(width: AppSpacing.sm),
                _StatBubble(
                    value: '${MockDashboardData.totalAssignments}',
                    label: 'Assignments'),
                const SizedBox(width: AppSpacing.sm),
                _StatBubble(
                    value: '${MockDashboardData.totalQuizzes}',
                    label: 'Quizzes'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── Settings rows ────────────────────────────────────────
            _Section(title: 'Account', children: [
              _SettingRow(
                  icon: Icons.person_outline_rounded,
                  label: 'Edit Profile',
                  onTap: () {}),
              _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () {}),
              _SettingRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Privacy & Security',
                  onTap: () {}),
            ]),
            const SizedBox(height: AppSpacing.md),

            _Section(title: 'App', children: [
              _SettingRow(
                  icon: Icons.palette_outlined,
                  label: 'Appearance',
                  onTap: () {}),
              _SettingRow(
                  icon: Icons.language_outlined,
                  label: 'Language',
                  trailing: 'English',
                  onTap: () {}),
              _SettingRow(
                  icon: Icons.storage_outlined,
                  label: 'Storage & Sync',
                  onTap: () {}),
            ]),
            const SizedBox(height: AppSpacing.md),

            _Section(title: 'Support', children: [
              _SettingRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Help & Feedback',
                  onTap: () {}),
              _SettingRow(
                  icon: Icons.info_outline_rounded,
                  label: 'About StudyFlow AI',
                  onTap: () {}),
            ]),
            const SizedBox(height: AppSpacing.lg),

            // ── Sign out ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.go(RoutePaths.login),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.error),
                label: Text(
                  'Sign out',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.error,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
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
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _StatBubble extends StatelessWidget {
  const _StatBubble({required this.value, required this.label});
  final String value;
  final String label;

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
                style: AppTypography.titleLarge
                    .copyWith(color: AppColors.primary)),
            Text(label,
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(title,
              style: AppTypography.labelMedium.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.onSurfaceVariant, size: 20),
      title: Text(label,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurface)),
      trailing: trailing != null
          ? Text(trailing!,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.onSurfaceVariant))
          : const Icon(Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant, size: 18),
      minLeadingWidth: 20,
      dense: true,
    );
  }
}

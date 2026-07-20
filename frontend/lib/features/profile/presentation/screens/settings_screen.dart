import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// Phase 2L — Settings Screen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Settings',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Account section
          _SettingsSection(title: 'Account', children: [
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              label: 'Edit Profile',
              color: AppColors.secondary,
              onTap: () => context.push(RoutePaths.editProfile),
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.email_outlined,
              label: 'Email',
              subtitle: 'sanawar.ali@comsats.edu.pk',
              color: AppColors.secondary,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.lock_outline_rounded,
              label: 'Change Password',
              color: AppColors.secondary,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Notifications section
          _SettingsSection(title: 'Notifications', children: [
            _SettingsTile(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              color: const Color(0xFFFFA726),
              onTap: () =>
                  context.push(RoutePaths.settingsNotifications),
              trailing: const _ChevronTrailing(),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Appearance section
          _SettingsSection(title: 'Appearance', children: [
            _SettingsTile(
              icon: Icons.palette_outlined,
              label: 'Theme',
              subtitle: 'Light',
              color: const Color(0xFFAB47BC),
              onTap: () =>
                  context.push(RoutePaths.settingsAppearance),
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.text_fields_rounded,
              label: 'Font Size',
              subtitle: 'Medium',
              color: const Color(0xFFAB47BC),
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Privacy & Security section
          _SettingsSection(title: 'Privacy & Security', children: [
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Settings',
              color: AppColors.error,
              onTap: () =>
                  context.push(RoutePaths.settingsPrivacy),
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.security_outlined,
              label: 'Security',
              color: AppColors.error,
              onTap: () =>
                  context.push(RoutePaths.settingsSecurity),
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.fingerprint_rounded,
              label: 'Biometric Login',
              color: AppColors.error,
              onTap: () {},
              trailing: _SwitchTrailing(
                value: false,
                onChanged: (_) {},
              ),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Storage section
          _SettingsSection(title: 'Storage & Data', children: [
            _SettingsTile(
              icon: Icons.storage_outlined,
              label: 'Offline Storage',
              subtitle: '234 MB used',
              color: AppColors.success,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.sync_outlined,
              label: 'Sync Settings',
              color: AppColors.success,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.delete_outline_rounded,
              label: 'Clear Cache',
              color: AppColors.success,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Help & Support section
          _SettingsSection(title: 'Help & Support', children: [
            _SettingsTile(
              icon: Icons.help_outline_rounded,
              label: 'Help Centre',
              color: AppColors.info,
              onTap: () =>
                  context.push(RoutePaths.settingsHelp),
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.bug_report_outlined,
              label: 'Report a Bug',
              color: AppColors.info,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.star_outline_rounded,
              label: 'Rate the App',
              color: AppColors.info,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
          ]),
          const SizedBox(height: AppSpacing.md),

          // About section
          _SettingsSection(title: 'About', children: [
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              label: 'About StudyFlow AI',
              color: AppColors.onSurfaceVariant,
              onTap: () => context.push(RoutePaths.settingsAbout),
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.description_outlined,
              label: 'Terms of Service',
              color: AppColors.onSurfaceVariant,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              color: AppColors.onSurfaceVariant,
              onTap: () {},
              trailing: const _ChevronTrailing(),
            ),
            _SettingsTile(
              icon: Icons.new_releases_outlined,
              label: 'Version',
              subtitle: '1.0.0 (Phase 2L)',
              color: AppColors.onSurfaceVariant,
              onTap: () {},
            ),
          ]),
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
    );
  }
}

// ── Reusable settings widgets ─────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection(
      {required this.title, required this.children});
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
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
          subtitle: subtitle != null
              ? Text(subtitle!,
                  style: AppTypography.bodySmall
                      .copyWith(color: AppColors.onSurfaceVariant))
              : null,
          trailing: trailing,
          minLeadingWidth: 36,
          dense: subtitle != null,
        ),
      ],
    );
  }
}

class _ChevronTrailing extends StatelessWidget {
  const _ChevronTrailing();

  @override
  Widget build(BuildContext context) => const Icon(
      Icons.chevron_right_rounded,
      color: AppColors.onSurfaceVariant,
      size: 18);
}

class _SwitchTrailing extends StatefulWidget {
  const _SwitchTrailing(
      {required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  State<_SwitchTrailing> createState() => _SwitchTrailingState();
}

class _SwitchTrailingState extends State<_SwitchTrailing> {
  late bool _val = widget.value;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _val,
      activeColor: AppColors.primary,
      onChanged: (v) {
        setState(() => _val = v);
        widget.onChanged(v);
      },
    );
  }
}

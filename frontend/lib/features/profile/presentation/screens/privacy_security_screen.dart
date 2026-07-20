import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState
    extends State<PrivacySettingsScreen> {
  bool _shareAnalytics = false;
  bool _personalizedAI = true;
  bool _publicProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Privacy',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _shareAnalytics,
                  onChanged: (v) =>
                      setState(() => _shareAnalytics = v),
                  title: Text('Share Analytics',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text(
                      'Help improve StudyFlow AI with usage data',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                SwitchListTile(
                  value: _personalizedAI,
                  onChanged: (v) =>
                      setState(() => _personalizedAI = v),
                  title: Text('Personalised AI',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text(
                      'Allow AI to learn from your study patterns',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                SwitchListTile(
                  value: _publicProfile,
                  onChanged: (v) =>
                      setState(() => _publicProfile = v),
                  title: Text('Public Profile',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text(
                      'Allow others to see your profile and notes',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 18),
                  ),
                  title: Text('Delete Account',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.error)),
                  subtitle: Text('Permanently delete your account',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.onSurfaceVariant, size: 18),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends State<SecuritySettingsScreen> {
  bool _twoFactor = false;
  bool _loginAlerts = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Security',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _twoFactor,
                  onChanged: (v) =>
                      setState(() => _twoFactor = v),
                  title: Text('Two-Factor Authentication',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text(
                      'Add an extra layer of security',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                SwitchListTile(
                  value: _loginAlerts,
                  onChanged: (v) =>
                      setState(() => _loginAlerts = v),
                  title: Text('Login Alerts',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text(
                      'Get notified of new sign-ins',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                ListTile(
                  onTap: () {},
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.secondary
                          .withValues(alpha: 0.12),
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Icon(Icons.lock_outline_rounded,
                        color: AppColors.secondary, size: 18),
                  ),
                  title: Text('Change Password',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.onSurfaceVariant, size: 18),
                  dense: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

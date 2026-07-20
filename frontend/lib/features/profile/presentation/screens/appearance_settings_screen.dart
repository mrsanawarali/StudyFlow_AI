import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_radius.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends State<AppearanceSettingsScreen> {
  String _theme = 'light';
  String _fontSize = 'medium';
  bool _compactMode = false;
  bool _showAnimations = true;

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
        title: Text('Appearance',
            style: AppTypography.titleLarge
                .copyWith(color: AppColors.onSurface)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Theme
          _SectionLabel('Theme'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ThemeOption(
                label: 'Light',
                icon: Icons.light_mode_rounded,
                selected: _theme == 'light',
                onTap: () => setState(() => _theme = 'light'),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                label: 'Dark',
                icon: Icons.dark_mode_rounded,
                selected: _theme == 'dark',
                onTap: () => setState(() => _theme = 'dark'),
                comingSoon: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ThemeOption(
                label: 'System',
                icon: Icons.auto_awesome_outlined,
                selected: _theme == 'system',
                onTap: () => setState(() => _theme = 'system'),
                comingSoon: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Font size
          _SectionLabel('Font Size'),
          const SizedBox(height: AppSpacing.sm),
          Container(
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
                  children: ['Small', 'Medium', 'Large'].map((s) {
                    final isSelected = _fontSize == s.toLowerCase();
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _fontSize = s.toLowerCase()),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: AppRadius.roundedLg,
                        ),
                        child: Text(s,
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w700 : FontWeight.w400,
                            )),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Preview text in ${_fontSize} size',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: switch (_fontSize) {
                        'small' => 12.0,
                        'large' => 18.0,
                        _ => 14.0,
                      },
                      color: AppColors.onSurface,
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Other options
          _SectionLabel('Display'),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedXl,
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  value: _compactMode,
                  onChanged: (v) => setState(() => _compactMode = v),
                  title: Text('Compact Mode',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text('Reduces spacing for more content',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
                  dense: true,
                ),
                SwitchListTile(
                  value: _showAnimations,
                  onChanged: (v) =>
                      setState(() => _showAnimations = v),
                  title: Text('Animations',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.onSurface)),
                  subtitle: Text('Smooth transitions and effects',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurfaceVariant)),
                  activeColor: AppColors.primary,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: AppSpacing.xs),
        child: Text(label,
            style: AppTypography.labelMedium.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w700)),
      );
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: comingSoon ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.10)
                : AppColors.surface,
            borderRadius: AppRadius.roundedXl,
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md),
          child: Column(
            children: [
              Icon(icon,
                  color: selected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 24),
              const SizedBox(height: AppSpacing.xs),
              Text(label,
                  style: AppTypography.labelSmall.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.onSurface,
                    fontWeight: selected
                        ? FontWeight.w700 : FontWeight.w400,
                  )),
              if (comingSoon)
                Text('Soon',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondary, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }
}

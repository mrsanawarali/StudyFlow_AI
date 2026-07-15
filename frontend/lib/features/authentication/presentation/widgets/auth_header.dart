import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// Reusable top header for all authentication screens.
///
/// Shows the StudyFlow AI logo mark, app name, and an optional
/// [subtitle] describing the current screen.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.subtitle,
  });

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Logo mark ────────────────────────────────────────────────────
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.auto_stories_rounded,
                color: AppColors.onPrimary, size: 32),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── App name ─────────────────────────────────────────────────────
        Text(
          'StudyFlow AI',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // ── Screen subtitle ───────────────────────────────────────────────
        Text(
          subtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

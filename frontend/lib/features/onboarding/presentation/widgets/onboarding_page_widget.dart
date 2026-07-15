import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// A single page in the onboarding flow.
///
/// Renders an illustration (pre-wrapped in a [FadeTransition] by the host),
/// a headline [title], and a supporting [description] — all centred on the
/// screen with consistent design-token spacing.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.illustrationWidget,
    required this.title,
    required this.description,
  });

  /// The illustration widget, already wrapped in a [FadeTransition] by the
  /// hosting [OnboardingScreen].
  final Widget illustrationWidget;

  /// Headline text displayed below the illustration.
  final String title;

  /// Supporting body text displayed below the title.
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: AppSpacing.xxxl * 3, // 192 dp
            width: double.infinity,
            child: illustrationWidget,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

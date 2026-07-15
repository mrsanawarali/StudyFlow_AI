import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_spacing.dart';
import '../../config/theme/app_typography.dart';
import 'buttons/secondary_button.dart';

/// Error state widget for StudyFlow AI.
/// Displayed when a data fetch or operation fails.
///
/// Usage:
/// ```dart
/// ErrorState(
///   message: 'Failed to load notes',
///   onRetry: () => _reload(),
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingPage,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SecondaryButton(
                text: retryLabel,
                onPressed: onRetry,
                width: 200,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

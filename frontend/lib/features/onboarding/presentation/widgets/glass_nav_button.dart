import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// A frosted-glass pill button used for the "Back" and "Skip" actions
/// in the onboarding top bar.
///
/// Stateless — tap handling is delegated via [onPressed].
class GlassNavButton extends StatelessWidget {
  const GlassNavButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional leading icon (e.g., Icons.arrow_back_ios_new_rounded).
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: onPressed != null ? 0.08 : 0.04),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 14,
                    color: AppColors.onPrimary.withValues(
                        alpha: onPressed != null ? 0.85 : 0.40),
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.onPrimary.withValues(
                        alpha: onPressed != null ? 0.85 : 0.40),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

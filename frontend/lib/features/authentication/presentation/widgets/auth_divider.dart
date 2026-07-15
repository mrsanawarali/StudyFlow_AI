import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';

/// "or continue with" divider row used between primary and social buttons.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, this.label = 'or continue with'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.outlineVariant,
            thickness: 1,
            endIndent: AppSpacing.sm,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.outlineVariant,
            thickness: 1,
            indent: AppSpacing.sm,
          ),
        ),
      ],
    );
  }
}

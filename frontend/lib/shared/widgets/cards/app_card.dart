import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';
import '../../../config/theme/app_shadows.dart';
import '../../../config/theme/app_spacing.dart';

/// Base card widget for StudyFlow AI.
/// Uses design tokens for radius, shadow, and padding.
///
/// Usage:
/// ```dart
/// AppCard(
///   onTap: () => openDetail(),
///   child: Text('Card content'),
/// )
/// ```
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.color,
    this.elevated = false,
  });

  final Widget child;

  /// Optional tap handler. Shows ink splash when provided.
  final VoidCallback? onTap;

  /// Optional long-press handler.
  final VoidCallback? onLongPress;

  /// Card content padding. Defaults to [AppSpacing.paddingCard].
  final EdgeInsetsGeometry? padding;

  /// Card background colour. Defaults to [AppColors.surface].
  final Color? color;

  /// When [true], applies [AppShadows.md]; otherwise [AppShadows.sm].
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: elevated ? AppShadows.md : AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: padding ?? AppSpacing.paddingCard,
            child: child,
          ),
        ),
      ),
    );
  }
}

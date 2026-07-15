import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';
import '../../../config/theme/app_radius.dart';

/// Customisable icon-only button for StudyFlow AI.
///
/// Usage:
/// ```dart
/// IconButtonCustom(
///   icon: Icons.delete_outline,
///   onPressed: () => _delete(),
///   color: AppColors.error,
/// )
/// ```
class IconButtonCustom extends StatelessWidget {
  const IconButtonCustom({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 24,
    this.tooltip,
    this.circular = true,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  /// Icon and splash colour. Defaults to [AppColors.primary].
  final Color? color;

  /// Icon size in dp. Defaults to 24.
  final double size;

  /// Optional accessibility tooltip.
  final String? tooltip;

  /// When [true] (default), the button uses a circular shape.
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;

    Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: size, color: effectiveColor),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shape: circular
            ? const CircleBorder()
            : RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
      ),
    );

    return button;
  }
}

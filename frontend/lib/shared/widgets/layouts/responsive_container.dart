import 'package:flutter/material.dart';
import '../../../config/theme/app_spacing.dart';

/// Width-constrained container for tablet/desktop layouts.
/// Centres content and applies responsive horizontal padding.
///
/// Usage:
/// ```dart
/// ResponsiveContainer(
///   child: LoginForm(),
/// )
/// ```
class ResponsiveContainer extends StatelessWidget {
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 480,
    this.padding,
  });

  final Widget child;

  /// Maximum content width in dp. Defaults to 480 (form-page width).
  final double maxWidth;

  /// Optional override padding. Defaults to horizontal [AppSpacing.md].
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ??
              const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}

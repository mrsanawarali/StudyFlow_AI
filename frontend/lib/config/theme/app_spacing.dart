import 'package:flutter/material.dart';

/// 8dp base-grid spacing system for StudyFlow AI.
/// Use these constants everywhere — no hardcoded numeric padding values.
///
/// Usage:
/// ```dart
/// Padding(padding: EdgeInsets.all(AppSpacing.md))
/// ```
class AppSpacing {
  AppSpacing._();

  // ── Scale ─────────────────────────────────────────────────────────────────
  static const double none = 0;

  /// 4dp — icon-to-text gaps, tight lists.
  static const double xs = 4.0;

  /// 8dp — list item internal spacing, small gaps.
  static const double sm = 8.0;

  /// 16dp — default padding (cards, buttons, most layouts).
  static const double md = 16.0;

  /// 24dp — screen edges, section spacing.
  static const double lg = 24.0;

  /// 32dp — large section breaks.
  static const double xl = 32.0;

  /// 48dp — hero areas, onboarding spacing.
  static const double xxl = 48.0;

  /// 64dp — very large structural spacing.
  static const double xxxl = 64.0;

  // ── Common EdgeInsets presets ─────────────────────────────────────────────

  /// Uniform [md] padding on all sides.
  static const EdgeInsets paddingAll = EdgeInsets.all(md);

  /// Symmetric horizontal [md] padding.
  static const EdgeInsets paddingHorizontal =
      EdgeInsets.symmetric(horizontal: md);

  /// Symmetric vertical [md] padding.
  static const EdgeInsets paddingVertical =
      EdgeInsets.symmetric(vertical: md);

  /// Screen-level padding using [lg] on all sides.
  static const EdgeInsets paddingPage = EdgeInsets.all(lg);

  /// Card content padding using [md] on all sides.
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
}

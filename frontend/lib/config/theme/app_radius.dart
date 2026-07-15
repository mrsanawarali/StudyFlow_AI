import 'package:flutter/material.dart';

/// Border radius constants for StudyFlow AI.
/// Use these everywhere — no hardcoded BorderRadius.circular() values.
///
/// Usage:
/// ```dart
/// Container(decoration: BoxDecoration(borderRadius: AppRadius.roundedMd))
/// ```
class AppRadius {
  AppRadius._();

  // ── Scale ─────────────────────────────────────────────────────────────────
  static const double none = 0;

  /// 4dp — subtle rounding for chips and small elements.
  static const double sm = 4.0;

  /// 8dp — default for cards, buttons, input fields.
  static const double md = 8.0;

  /// 12dp — prominent elements, larger cards.
  static const double lg = 12.0;

  /// 16dp — bottom sheets, dialogs, modals.
  static const double xl = 16.0;

  /// 999dp — fully circular (pill buttons, avatar images, FAB).
  static const double full = 999.0;

  // ── BorderRadius getters ──────────────────────────────────────────────────

  static BorderRadius get roundedSm => BorderRadius.circular(sm);
  static BorderRadius get roundedMd => BorderRadius.circular(md);
  static BorderRadius get roundedLg => BorderRadius.circular(lg);
  static BorderRadius get roundedXl => BorderRadius.circular(xl);
  static BorderRadius get roundedFull => BorderRadius.circular(full);

  /// Top corners only, using [lg] — for bottom sheets and modals.
  static BorderRadius get topOnlyLg =>
      const BorderRadius.vertical(top: Radius.circular(lg));

  /// Bottom corners only, using [lg].
  static BorderRadius get bottomOnlyLg =>
      const BorderRadius.vertical(bottom: Radius.circular(lg));
}

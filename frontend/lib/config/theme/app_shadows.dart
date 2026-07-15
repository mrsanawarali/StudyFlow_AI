import 'package:flutter/material.dart';

/// Elevation-based shadow definitions for StudyFlow AI.
/// Use these instead of hardcoded BoxShadow values.
///
/// Usage:
/// ```dart
/// Container(decoration: BoxDecoration(boxShadow: AppShadows.md))
/// ```
class AppShadows {
  AppShadows._();

  /// Elevation 1 — subtle shadow for bottom nav, cards at rest.
  static List<BoxShadow> get sm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  /// Elevation 2 — moderate shadow for raised cards and buttons.
  static List<BoxShadow> get md => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  /// Elevation 3 — high shadow for dialogs, bottom sheets.
  static List<BoxShadow> get lg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  /// Elevation 4 — floating shadow for FAB, modal sheets.
  static List<BoxShadow> get xl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.16),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// No shadow — used when elevation is removed explicitly.
  static List<BoxShadow> get none => const [];
}

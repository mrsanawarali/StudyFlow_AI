import 'package:flutter/material.dart';

/// Material 3 color palette for StudyFlow AI.
/// All widgets MUST use these constants — no hardcoded Color literals.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF0A0F2C);
  static const Color primaryLight = Color(0xFF1A2F4C);
  static const Color primaryDark = Color(0xFF000510);

  static const Color secondary = Color(0xFF4A90E2);
  static const Color secondaryLight = Color(0xFF7AB8FF);
  static const Color secondaryDark = Color(0xFF2868B2);

  static const Color tertiary = Color(0xFF50E3C2);
  static const Color tertiaryLight = Color(0xFF80FFD4);
  static const Color tertiaryDark = Color(0xFF20B392);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);

  // ── Surface (Light theme) ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F5);
  static const Color surfaceContainerHigh = Color(0xFFE8EAED);

  // ── On-colors ─────────────────────────────────────────────────────────────
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFF003328);
  static const Color onBackground = Color(0xFF1A1C1E);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF44474A);
  static const Color onError = Color(0xFFFFFFFF);

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFFBABEC4);
  static const Color outlineVariant = Color(0xFFDDE1E6);

  // ── Dark theme (deferred — placeholders for future implementation) ─────────
  // static const Color darkBackground = Color(0xFF121212);
  // static const Color darkSurface = Color(0xFF1E1E1E);
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 typography scale for StudyFlow AI.
/// Uses Poppins via [GoogleFonts]. All sizes in SP.
///
/// Usage:
/// ```dart
/// Text('Hello', style: AppTypography.headlineMedium)
/// ```
class AppTypography {
  AppTypography._();

  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle get displayLarge =>
      GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.w400);

  static TextStyle get displayMedium =>
      GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.w400);

  static TextStyle get displaySmall =>
      GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w400);

  // ── Headline ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge =>
      GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w600);

  /// Screen titles / page headers.
  static TextStyle get headlineMedium =>
      GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600);

  /// Section titles.
  static TextStyle get headlineSmall =>
      GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600);

  // ── Title ─────────────────────────────────────────────────────────────────
  /// Card titles, dialog titles.
  static TextStyle get titleLarge =>
      GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600);

  static TextStyle get titleMedium =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get titleSmall =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);

  // ── Body ──────────────────────────────────────────────────────────────────
  /// Primary body text.
  static TextStyle get bodyLarge =>
      GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400);

  /// Default body text.
  static TextStyle get bodyMedium =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400);

  static TextStyle get bodySmall =>
      GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400);

  // ── Label ─────────────────────────────────────────────────────────────────
  /// Button labels.
  static TextStyle get labelLarge =>
      GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500);

  /// Chip labels.
  static TextStyle get labelMedium =>
      GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500);

  /// Captions, helper text.
  static TextStyle get labelSmall =>
      GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500);
}

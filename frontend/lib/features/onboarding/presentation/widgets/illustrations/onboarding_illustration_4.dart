import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';

/// Onboarding illustration for page 4 — "Stay Productive" motif.
///
/// Renders a calendar grid in [AppColors.secondary] with three
/// horizontal checklist rows and animated tick marks in [AppColors.tertiary].
/// All coordinates are expressed as fractions of [size] so the illustration
/// scales correctly at any resolution.
class OnboardingIllustration4 extends StatelessWidget {
  const OnboardingIllustration4({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.xxxl * 3, // 192 dp
      width: double.infinity,
      child: CustomPaint(painter: _StayProductivePainter()),
    );
  }
}

class _StayProductivePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Shared paint objects ──────────────────────────────────────────────
    final Paint secondaryFill = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final Paint secondaryStroke = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008
      ..strokeCap = StrokeCap.round;

    final Paint secondaryLightFill = Paint()
      ..color = AppColors.secondaryLight.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final Paint tertiaryFill = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final Paint tertiaryStroke = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.009
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint outlinePaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.004;

    final Paint surfaceVariantFill = Paint()
      ..color = AppColors.surfaceVariant
      ..style = PaintingStyle.fill;

    // ── Calendar card bounds ──────────────────────────────────────────────
    // The card is centred horizontally and occupies most of the canvas.
    final double cardLeft = w * 0.06;
    final double cardRight = w * 0.94;
    final double cardTop = h * 0.04;
    final double cardBottom = h * 0.96;
    final double cardWidth = cardRight - cardLeft;
    final double cardHeight = cardBottom - cardTop;
    final double radius = w * 0.04;

    // Drop shadow (soft)
    final Paint shadowPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(cardLeft + w * 0.01, cardTop + h * 0.02,
            cardRight + w * 0.01, cardBottom + h * 0.02),
        Radius.circular(radius),
      ),
      shadowPaint,
    );

    // Card background
    final Paint cardBg = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    final RRect cardRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cardLeft, cardTop, cardRight, cardBottom),
      Radius.circular(radius),
    );
    canvas.drawRRect(cardRRect, cardBg);
    canvas.drawRRect(cardRRect, outlinePaint);

    // ── Calendar header ───────────────────────────────────────────────────
    final double headerBottom = cardTop + cardHeight * 0.20;
    final RRect headerRRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(cardLeft, cardTop, cardRight, headerBottom),
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
    canvas.drawRRect(headerRRect, secondaryFill);

    // Month label area (three small rounded rectangles — decorative text stand-in)
    final double labelY = cardTop + cardHeight * 0.07;
    for (int i = 0; i < 3; i++) {
      final double lx = cardLeft + cardWidth * (0.12 + i * 0.10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(lx, labelY, cardWidth * 0.07, h * 0.025),
          const Radius.circular(3),
        ),
        Paint()
          ..color = AppColors.onPrimary.withOpacity(0.7)
          ..style = PaintingStyle.fill,
      );
    }

    // Two chevron arrows (prev/next month) in the header
    _drawChevron(canvas, Offset(cardLeft + cardWidth * 0.08, cardTop + cardHeight * 0.10),
        w * 0.018, false, AppColors.onPrimary.withOpacity(0.9));
    _drawChevron(canvas, Offset(cardRight - cardWidth * 0.08, cardTop + cardHeight * 0.10),
        w * 0.018, true, AppColors.onPrimary.withOpacity(0.9));

    // Ring/clip tabs at top of calendar (two small rectangles protruding above header)
    for (final double ringX in [cardLeft + cardWidth * 0.28, cardLeft + cardWidth * 0.72]) {
      final Paint ringPaint = Paint()
        ..color = AppColors.secondaryDark
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(ringX - w * 0.025, cardTop - h * 0.02, w * 0.05, h * 0.035),
          Radius.circular(w * 0.012),
        ),
        ringPaint,
      );
    }

    // ── Weekday labels (Sun–Sat) ─────────────────────────────────────────
    final double labelRowY = headerBottom + cardHeight * 0.005;
    final double labelRowH = cardHeight * 0.085;
    canvas.drawRect(
      Rect.fromLTWH(cardLeft, labelRowY, cardWidth, labelRowH),
      surfaceVariantFill,
    );

    const int cols = 7;
    final double colW = cardWidth / cols;
    for (int c = 0; c < cols; c++) {
      final double cx = cardLeft + colW * c + colW * 0.5;
      final double cy = labelRowY + labelRowH * 0.5;
      // Small rounded rect as day-letter stand-in
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: colW * 0.45, height: labelRowH * 0.38),
          const Radius.circular(3),
        ),
        Paint()
          ..color = (c == 0 || c == 6)
              ? AppColors.secondary.withOpacity(0.45)
              : AppColors.onSurfaceVariant.withOpacity(0.35)
          ..style = PaintingStyle.fill,
      );
    }

    // ── Calendar grid (5 rows × 7 cols) ──────────────────────────────────
    final double gridTop = labelRowY + labelRowH;
    final double gridBottom = cardTop + cardHeight * 0.62;
    final double gridH = gridBottom - gridTop;
    const int rows = 5;
    final double rowH = gridH / rows;

    // Horizontal grid lines
    for (int r = 0; r <= rows; r++) {
      final double y = gridTop + rowH * r;
      canvas.drawLine(
        Offset(cardLeft, y),
        Offset(cardRight, y),
        outlinePaint,
      );
    }
    // Vertical grid lines
    for (int c = 0; c <= cols; c++) {
      final double x = cardLeft + colW * c;
      canvas.drawLine(
        Offset(x, gridTop),
        Offset(x, gridBottom),
        outlinePaint,
      );
    }

    // Day number circles/cells — draw a selection of them
    // Start offset: skip first 3 cells (month starts on Wed)
    const int startOffset = 3;
    const int daysInMonth = 31;
    // Highlight today: day 15 (0-indexed slot 15+3-1 = 17)
    const int todayDay = 15;

    for (int d = 1; d <= daysInMonth; d++) {
      final int slot = startOffset + d - 1;
      final int r = slot ~/ cols;
      final int c = slot % cols;
      if (r >= rows) break;
      final double cx = cardLeft + colW * c + colW * 0.5;
      final double cy = gridTop + rowH * r + rowH * 0.5;

      if (d == todayDay) {
        // Today: filled circle in secondary
        canvas.drawCircle(Offset(cx, cy), math.min(colW, rowH) * 0.32, secondaryFill);
        // White dot label
        canvas.drawCircle(
          Offset(cx, cy),
          math.min(colW, rowH) * 0.14,
          Paint()
            ..color = AppColors.onPrimary
            ..style = PaintingStyle.fill,
        );
      } else {
        // Regular day dot
        final Color dotColor = (c == 0 || c == 6)
            ? AppColors.secondary.withOpacity(0.3)
            : AppColors.onSurface.withOpacity(0.18);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(cx, cy),
                width: colW * 0.4,
                height: rowH * 0.32),
            const Radius.circular(2),
          ),
          Paint()
            ..color = dotColor
            ..style = PaintingStyle.fill,
        );
      }
    }

    // Small event dots on a few days (decorative)
    for (final int eventDay in [3, 8, 21, 26]) {
      final int slot = startOffset + eventDay - 1;
      final int r = slot ~/ cols;
      final int c = slot % cols;
      if (r >= rows) continue;
      final double cx = cardLeft + colW * c + colW * 0.5;
      final double cy = gridTop + rowH * r + rowH * 0.82;
      canvas.drawCircle(
        Offset(cx, cy),
        math.min(colW, rowH) * 0.09,
        tertiaryFill,
      );
    }

    // ── Checklist section ─────────────────────────────────────────────────
    // Three rows below the calendar grid inside the card
    final double checklistTop = gridBottom + cardHeight * 0.025;
    final double checklistRowH = (cardBottom - checklistTop - cardHeight * 0.035) / 3;

    for (int row = 0; row < 3; row++) {
      final double ry = checklistTop + row * checklistRowH;
      final double rowCentreY = ry + checklistRowH * 0.5;

      // Row background (alternating)
      if (row.isEven) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cardLeft + w * 0.03, ry + checklistRowH * 0.08,
                cardWidth - w * 0.06, checklistRowH * 0.84),
            const Radius.circular(6),
          ),
          secondaryLightFill,
        );
      }

      // Checkbox border
      final double cbSize = checklistRowH * 0.46;
      final double cbX = cardLeft + cardWidth * 0.07;
      final double cbY = rowCentreY - cbSize * 0.5;
      final RRect cbRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cbX, cbY, cbSize, cbSize),
        Radius.circular(cbSize * 0.22),
      );

      if (row < 2) {
        // Checked rows (0 and 1): filled tertiary box + tick
        canvas.drawRRect(cbRRect, tertiaryFill);
        _drawTick(canvas, Offset(cbX + cbSize * 0.5, cbY + cbSize * 0.5), cbSize * 0.32,
            AppColors.onTertiary);
      } else {
        // Unchecked row (2): outline only
        canvas.drawRRect(cbRRect, secondaryStroke);
      }

      // Task text stand-in (two rounded rects of different widths)
      final double textX = cbX + cbSize + cardWidth * 0.04;
      final double textMaxW = cardWidth * 0.55;
      final double lineH = checklistRowH * 0.16;

      // Primary line
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(textX, rowCentreY - lineH * 1.3,
              textMaxW * (row == 2 ? 0.75 : 1.0), lineH),
          const Radius.circular(3),
        ),
        Paint()
          ..color = (row < 2)
              ? AppColors.onSurfaceVariant.withOpacity(0.35)
              : AppColors.onSurface.withOpacity(0.55)
          ..style = PaintingStyle.fill,
      );
      // Secondary line (shorter)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(textX, rowCentreY + lineH * 0.15, textMaxW * 0.5, lineH * 0.8),
          const Radius.circular(3),
        ),
        Paint()
          ..color = AppColors.outlineVariant.withOpacity(0.6)
          ..style = PaintingStyle.fill,
      );

      // Priority tag on the right
      final Paint tagPaint = Paint()
        ..color = row == 0
            ? AppColors.tertiary.withOpacity(0.25)
            : row == 1
                ? AppColors.secondary.withOpacity(0.20)
                : AppColors.warning.withOpacity(0.20)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cardRight - cardWidth * 0.20,
              rowCentreY - checklistRowH * 0.18, cardWidth * 0.14,
              checklistRowH * 0.36),
          const Radius.circular(4),
        ),
        tagPaint,
      );
    }

    // ── Divider between grid and checklist ────────────────────────────────
    canvas.drawLine(
      Offset(cardLeft + w * 0.04, checklistTop),
      Offset(cardRight - w * 0.04, checklistTop),
      Paint()
        ..color = AppColors.outlineVariant
        ..strokeWidth = w * 0.003,
    );

    // ── Floating accent badge (top-right outside card) ────────────────────
    // A small rounded card showing "3 tasks" in tertiary
    final double badgeX = cardRight - cardWidth * 0.30;
    final double badgeY = cardTop - h * 0.005;
    final double badgeW = cardWidth * 0.26;
    final double badgeH = h * 0.095;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeX, badgeY - badgeH, badgeW, badgeH),
        Radius.circular(w * 0.025),
      ),
      Paint()
        ..color = AppColors.tertiary.withOpacity(0.18)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(badgeX, badgeY - badgeH, badgeW, badgeH),
        Radius.circular(w * 0.025),
      ),
      Paint()
        ..color = AppColors.tertiary.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.004,
    );
    // Three mini dots inside badge (stand-in for "3 tasks" text)
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(badgeX + badgeW * (0.25 + i * 0.25), badgeY - badgeH * 0.5),
        w * 0.012,
        tertiaryFill,
      );
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Draws a tick (✓) mark centred at [centre] with arm length [size].
  void _drawTick(Canvas canvas, Offset centre, double size, Color color) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.55
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path()
      ..moveTo(centre.dx - size, centre.dy)
      ..lineTo(centre.dx - size * 0.2, centre.dy + size * 0.8)
      ..lineTo(centre.dx + size, centre.dy - size * 0.8);
    canvas.drawPath(path, p);
  }

  /// Draws a simple chevron arrow centred at [centre].
  /// [pointRight] = true → '›', false → '‹'.
  void _drawChevron(Canvas canvas, Offset centre, double size, bool pointRight,
      Color color) {
    final Paint p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double dx = size * 0.5;
    final double dy = size * 0.65;
    final Path path = pointRight
        ? (Path()
          ..moveTo(centre.dx - dx, centre.dy - dy)
          ..lineTo(centre.dx + dx, centre.dy)
          ..lineTo(centre.dx - dx, centre.dy + dy))
        : (Path()
          ..moveTo(centre.dx + dx, centre.dy - dy)
          ..lineTo(centre.dx - dx, centre.dy)
          ..lineTo(centre.dx + dx, centre.dy + dy));
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_StayProductivePainter old) => false;
}

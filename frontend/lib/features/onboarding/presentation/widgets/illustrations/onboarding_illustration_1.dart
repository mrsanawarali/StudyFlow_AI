import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';

/// Onboarding illustration for page 1 — "Study Smarter" motif.
///
/// Renders three stacked books in [AppColors.secondary] with spines in
/// [AppColors.secondaryDark], plus floating dog-eared document cards and
/// sparkle accents in [AppColors.tertiary]. All coordinates are expressed as
/// fractions of [Size] so the widget scales to any host constraint.
class OnboardingIllustration1 extends StatelessWidget {
  const OnboardingIllustration1({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.xxxl * 3,
      width: double.infinity,
      child: CustomPaint(painter: _StudySmarterPainter()),
    );
  }
}

class _StudySmarterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Shared paints ──────────────────────────────────────────────────────
    final coverDarkPaint = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.fill;

    final coverMidPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final coverLightPaint = Paint()
      ..color = AppColors.secondaryLight
      ..style = PaintingStyle.fill;

    final spinePaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.secondaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.004
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final pageLinePaint = Paint()
      ..color = AppColors.onPrimary.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.0025
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    final accentFillPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final accentLightPaint = Paint()
      ..color = AppColors.tertiaryLight
      ..style = PaintingStyle.fill;

    final accentStrokePaint = Paint()
      ..color = AppColors.tertiaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.003
      ..strokeCap = StrokeCap.round;

    // ── Book stack — bottom to top ─────────────────────────────────────────
    // Books are drawn as perspective-skewed parallelograms giving a 3-D feel.
    // Coordinates: (left, top, right, bottom) as fractions of (w, h).
    // spineW  = width of left spine strip (fraction of w).
    // skew    = horizontal offset applied to top edge (fraction of w); gives
    //           the illusion of the book being viewed slightly from above.

    // Book 3 — bottom, widest, darkest
    _drawBook(
      canvas: canvas,
      w: w,
      h: h,
      left: 0.15,
      top: 0.62,
      right: 0.85,
      bottom: 0.80,
      spineW: 0.058,
      skew: 0.014,
      coverPaint: coverDarkPaint,
      spinePaint: spinePaint,
      strokePaint: strokePaint,
      pageLinePaint: pageLinePaint,
      lineCount: 3,
      shadowPaint: shadowPaint,
    );

    // Book 2 — middle
    _drawBook(
      canvas: canvas,
      w: w,
      h: h,
      left: 0.19,
      top: 0.43,
      right: 0.81,
      bottom: 0.64,
      spineW: 0.053,
      skew: 0.010,
      coverPaint: coverMidPaint,
      spinePaint: spinePaint,
      strokePaint: strokePaint,
      pageLinePaint: pageLinePaint,
      lineCount: 3,
      shadowPaint: shadowPaint,
    );

    // Book 1 — top, narrowest, lightest
    _drawBook(
      canvas: canvas,
      w: w,
      h: h,
      left: 0.22,
      top: 0.25,
      right: 0.78,
      bottom: 0.45,
      spineW: 0.048,
      skew: 0.008,
      coverPaint: coverLightPaint,
      spinePaint: spinePaint,
      strokePaint: strokePaint,
      pageLinePaint: pageLinePaint,
      lineCount: 3,
      shadowPaint: shadowPaint,
    );

    // ── Floating document accents ──────────────────────────────────────────

    // Doc 1 — upper-right, clockwise tilt
    canvas.save();
    canvas.translate(w * 0.80, h * 0.11);
    canvas.rotate(0.28);
    _drawDocument(
      canvas: canvas,
      w: w,
      h: h,
      docW: 0.17,
      docH: 0.22,
      cornerFrac: 0.012,
      fillPaint: accentFillPaint,
      strokePaint: accentStrokePaint,
      lineCount: 3,
    );
    canvas.restore();

    // Doc 2 — upper-left, counter-clockwise tilt
    canvas.save();
    canvas.translate(w * 0.14, h * 0.14);
    canvas.rotate(-0.22);
    _drawDocument(
      canvas: canvas,
      w: w,
      h: h,
      docW: 0.13,
      docH: 0.18,
      cornerFrac: 0.010,
      fillPaint: accentLightPaint,
      strokePaint: accentStrokePaint,
      lineCount: 2,
    );
    canvas.restore();

    // Doc 3 — small, lower-right
    canvas.save();
    canvas.translate(w * 0.85, h * 0.60);
    canvas.rotate(0.18);
    _drawDocument(
      canvas: canvas,
      w: w,
      h: h,
      docW: 0.10,
      docH: 0.13,
      cornerFrac: 0.008,
      fillPaint: accentFillPaint,
      strokePaint: accentStrokePaint,
      lineCount: 2,
    );
    canvas.restore();

    // ── Sparkle accents ────────────────────────────────────────────────────
    _drawSparkle(canvas, Offset(w * 0.67, h * 0.08), w * 0.020, accentFillPaint);
    _drawSparkle(canvas, Offset(w * 0.21, h * 0.06), w * 0.013, accentLightPaint);
    _drawSparkle(canvas, Offset(w * 0.90, h * 0.36), w * 0.011, accentFillPaint);
    _drawSparkle(canvas, Offset(w * 0.09, h * 0.43), w * 0.009, accentLightPaint);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Draws a single book as a perspective-skewed parallelogram.
  ///
  /// The spine is a dark strip on the left; the cover fills the rest.
  /// [skew] shifts the top edge rightward to simulate viewing from above.
  void _drawBook({
    required Canvas canvas,
    required double w,
    required double h,
    required double left,
    required double top,
    required double right,
    required double bottom,
    required double spineW,
    required double skew,
    required Paint coverPaint,
    required Paint spinePaint,
    required Paint strokePaint,
    required Paint pageLinePaint,
    required int lineCount,
    required Paint shadowPaint,
  }) {
    final l = w * left;
    final t = h * top;
    final r = w * right;
    final b = h * bottom;
    final sw = w * spineW;
    final sk = w * skew;
    final bookH = b - t;

    // Drop shadow below book
    final shadowPath = Path()
      ..moveTo(l + sw - sk * 0.4, b + h * 0.010)
      ..lineTo(r - sk * 0.4, b + h * 0.010)
      ..lineTo(r - sk * 0.6, b + h * 0.018)
      ..lineTo(l + sw - sk * 0.6, b + h * 0.018)
      ..close();
    canvas.drawPath(shadowPath, shadowPaint);

    // Cover body
    final coverPath = Path()
      ..moveTo(l + sw + sk, t)
      ..lineTo(r + sk, t)
      ..lineTo(r - sk, b)
      ..lineTo(l + sw - sk, b)
      ..close();
    canvas.drawPath(coverPath, coverPaint);
    canvas.drawPath(coverPath, strokePaint);

    // Spine strip (left)
    final spinePath = Path()
      ..moveTo(l + sk * 0.6, t + bookH * 0.03)
      ..lineTo(l + sw + sk, t)
      ..lineTo(l + sw - sk, b)
      ..lineTo(l - sk * 0.6, b - bookH * 0.03)
      ..close();
    canvas.drawPath(spinePath, spinePaint);
    canvas.drawPath(spinePath, strokePaint);

    // Page-edge micro-lines (right side — simulates layered pages)
    for (int i = 1; i <= 3; i++) {
      final frac = i / 4.0;
      final py = t + bookH * frac;
      canvas.drawLine(
        Offset(r - sk + i * w * 0.0015, py),
        Offset(r - sk + i * w * 0.006, py),
        pageLinePaint,
      );
    }

    // Cover text-row hints
    final coverL = l + sw + sk + w * 0.030;
    final coverR = r + sk - w * 0.040;
    final rowSpacing = bookH / (lineCount + 1.5);
    for (int i = 1; i <= lineCount; i++) {
      final ly = t + rowSpacing * (i + 0.3);
      // Alternating widths make it look like real text
      final rowR = i.isEven ? coverL + (coverR - coverL) * 0.62 : coverR;
      canvas.drawLine(Offset(coverL, ly), Offset(rowR, ly), pageLinePaint);
    }
  }

  /// Draws a floating dog-eared document card centred at the current canvas
  /// origin (use [canvas.save]/[canvas.translate] before calling).
  void _drawDocument({
    required Canvas canvas,
    required double w,
    required double h,
    required double docW,
    required double docH,
    required double cornerFrac,
    required Paint fillPaint,
    required Paint strokePaint,
    required int lineCount,
  }) {
    final dw = w * docW;
    final dh = h * docH;
    final cr = w * cornerFrac;
    final fold = dw * 0.20; // dog-ear fold size

    // Card body (rounded, except top-right corner which becomes the fold)
    final cardPath = Path()
      ..moveTo(-dw / 2 + cr, -dh / 2)
      ..lineTo(dw / 2 - fold, -dh / 2)   // top edge up to fold
      ..lineTo(dw / 2, -dh / 2 + fold)   // diagonal fold cut
      ..lineTo(dw / 2, dh / 2 - cr)
      ..quadraticBezierTo(dw / 2, dh / 2, dw / 2 - cr, dh / 2)
      ..lineTo(-dw / 2 + cr, dh / 2)
      ..quadraticBezierTo(-dw / 2, dh / 2, -dw / 2, dh / 2 - cr)
      ..lineTo(-dw / 2, -dh / 2 + cr)
      ..quadraticBezierTo(-dw / 2, -dh / 2, -dw / 2 + cr, -dh / 2)
      ..close();
    canvas.drawPath(cardPath, fillPaint);
    canvas.drawPath(cardPath, strokePaint);

    // Fold triangle
    final foldPath = Path()
      ..moveTo(dw / 2 - fold, -dh / 2)
      ..lineTo(dw / 2, -dh / 2 + fold)
      ..lineTo(dw / 2 - fold, -dh / 2 + fold)
      ..close();
    canvas.drawPath(foldPath, strokePaint);

    // Line hints inside card
    final lx1 = -dw / 2 + dw * 0.14;
    final lineSpacing = (dh * 0.55) / (lineCount + 0.5);
    for (int i = 1; i <= lineCount; i++) {
      final ly = -dh / 2 + dh * 0.30 + lineSpacing * i;
      final lx2 = i.isEven
          ? dw / 2 - dw * 0.28
          : dw / 2 - dw * 0.12;
      final lp = Paint()
        ..color = strokePaint.color.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = dh * 0.045
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(lx1, ly), Offset(lx2, ly), lp);
    }
  }

  /// Draws a 4-pointed sparkle star centred at [centre].
  void _drawSparkle(Canvas canvas, Offset centre, double radius, Paint paint) {
    const arms = 4;
    const innerRatio = 0.32;
    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final angle = (i * math.pi / arms) - math.pi / 2;
      final r = i.isEven ? radius : radius * innerRatio;
      final x = centre.dx + r * math.cos(angle);
      final y = centre.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_StudySmarterPainter old) => false;
}

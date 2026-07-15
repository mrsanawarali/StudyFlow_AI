import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';

/// Onboarding illustration for page 2 — "Offline First" motif.
///
/// Renders a large cloud outline with a shield overlay (both in
/// [AppColors.secondary]) and circular sync arrows with accent fills
/// (in [AppColors.tertiary]).  All coordinates are expressed as fractions
/// of the canvas [Size] so the painting scales correctly at any resolution.
class OnboardingIllustration2 extends StatelessWidget {
  const OnboardingIllustration2({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.xxxl * 3, // 192 dp
      width: double.infinity,
      child: CustomPaint(painter: _OfflineFirstPainter()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OfflineFirstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Background soft glow ─────────────────────────────────────────────────
    _drawBackgroundGlow(canvas, w, h);

    // ── Cloud shape ──────────────────────────────────────────────────────────
    _drawCloud(canvas, w, h);

    // ── Shield overlay ───────────────────────────────────────────────────────
    _drawShield(canvas, w, h);

    // ── Sync / circular arrows ───────────────────────────────────────────────
    _drawSyncArrows(canvas, w, h);

    // ── Floating accent dots ─────────────────────────────────────────────────
    _drawAccentDots(canvas, w, h);

    // ── Wi-Fi-off bars (disconnected state indicator) ────────────────────────
    _drawOfflineBars(canvas, w, h);
  }

  // ── Background glow ────────────────────────────────────────────────────────

  void _drawBackgroundGlow(Canvas canvas, double w, double h) {
    final Paint glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondary.withOpacity(0.10),
          AppColors.secondary.withOpacity(0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(w * 0.50, h * 0.48),
          radius: w * 0.44,
        ),
      );
    canvas.drawCircle(Offset(w * 0.50, h * 0.48), w * 0.44, glowPaint);
  }

  // ── Cloud ──────────────────────────────────────────────────────────────────

  void _drawCloud(Canvas canvas, double w, double h) {
    // Cloud fill (very light tint of secondary)
    final Paint fillPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Cloud outline
    final Paint strokePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path cloudPath = _buildCloudPath(w, h);

    canvas.drawPath(cloudPath, fillPaint);
    canvas.drawPath(cloudPath, strokePaint);

    // Inner cloud highlight stroke (slightly smaller, very faint)
    final Paint highlightPaint = Paint()
      ..color = AppColors.secondaryLight.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.005
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.save();
    canvas.translate(0, h * 0.012);
    canvas.drawPath(_buildCloudPath(w, h), highlightPaint);
    canvas.restore();
  }

  Path _buildCloudPath(double w, double h) {
    // Centre the cloud in the upper-centre area of the canvas.
    //
    // Key anchor fractions (all relative to w/h):
    //  Main body bottom centre: (0.50, 0.60)
    //  Left tail:               (0.18, 0.60)
    //  Right tail:              (0.82, 0.60)
    //  Cloud top peak:          (0.50, 0.14)

    final double cx = w * 0.50;
    final double baseY = h * 0.60;

    // Bumps (centre-x, centre-y, radius) as fractions
    final List<_Circle> bumps = [
      _Circle(cx, h * 0.36, w * 0.135), // large central top bump
      _Circle(w * 0.35, h * 0.43, w * 0.100), // left-of-centre bump
      _Circle(w * 0.65, h * 0.43, w * 0.100), // right-of-centre bump
      _Circle(w * 0.23, h * 0.52, w * 0.080), // far-left bump
      _Circle(w * 0.77, h * 0.52, w * 0.080), // far-right bump
    ];

    // Build cloud outline using arc segments
    final Path path = Path();

    // Flat bottom-left corner
    path.moveTo(w * 0.18, baseY);

    // Bottom straight edge
    path.lineTo(w * 0.82, baseY);

    // Right side up to far-right bump
    path.arcToPoint(
      Offset(bumps[4].cx + bumps[4].r, bumps[4].cy),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );

    // Far-right bump arc (upper half)
    path.arcToPoint(
      Offset(bumps[4].cx - bumps[4].r, bumps[4].cy),
      radius: Radius.circular(bumps[4].r),
      clockwise: false,
    );

    // Bridge to right-of-centre bump
    path.arcToPoint(
      Offset(bumps[2].cx + bumps[2].r, bumps[2].cy),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );

    // Right-of-centre bump arc
    path.arcToPoint(
      Offset(bumps[2].cx - bumps[2].r, bumps[2].cy),
      radius: Radius.circular(bumps[2].r),
      clockwise: false,
    );

    // Bridge to central top bump
    path.arcToPoint(
      Offset(bumps[0].cx + bumps[0].r, bumps[0].cy),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );

    // Central top bump arc
    path.arcToPoint(
      Offset(bumps[0].cx - bumps[0].r, bumps[0].cy),
      radius: Radius.circular(bumps[0].r),
      clockwise: false,
    );

    // Bridge to left-of-centre bump
    path.arcToPoint(
      Offset(bumps[1].cx - bumps[1].r, bumps[1].cy),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );

    // Left-of-centre bump arc
    path.arcToPoint(
      Offset(bumps[1].cx + bumps[1].r, bumps[1].cy),
      radius: Radius.circular(bumps[1].r),
      clockwise: true,
    );

    // Bridge to far-left bump
    path.arcToPoint(
      Offset(bumps[3].cx - bumps[3].r, bumps[3].cy),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );

    // Far-left bump arc
    path.arcToPoint(
      Offset(bumps[3].cx + bumps[3].r, bumps[3].cy),
      radius: Radius.circular(bumps[3].r),
      clockwise: true,
    );

    // Down to bottom-left corner
    path.arcToPoint(
      Offset(w * 0.18, baseY),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );

    path.close();
    return path;
  }

  // ── Shield ─────────────────────────────────────────────────────────────────

  void _drawShield(Canvas canvas, double w, double h) {
    // Shield centred in the lower half of the cloud body.
    final double sx = w * 0.50; // centre x
    final double sy = h * 0.50; // centre y
    final double sw = w * 0.20; // half-width
    final double sh = h * 0.26; // half-height

    final Path shieldPath = Path();
    shieldPath.moveTo(sx, sy - sh); // top centre
    shieldPath.lineTo(sx + sw, sy - sh * 0.70); // top-right shoulder
    shieldPath.lineTo(sx + sw, sy + sh * 0.10); // right mid
    // Bottom tip curve
    shieldPath.quadraticBezierTo(
      sx + sw * 0.50, sy + sh,
      sx, sy + sh,
    );
    shieldPath.quadraticBezierTo(
      sx - sw * 0.50, sy + sh,
      sx - sw, sy + sh * 0.10,
    );
    shieldPath.lineTo(sx - sw, sy - sh * 0.70); // left mid
    shieldPath.close();

    // Shield fill — subtle secondary tint
    final Paint shieldFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary.withOpacity(0.22),
          AppColors.secondary.withOpacity(0.10),
        ],
      ).createShader(
        Rect.fromLTWH(sx - sw, sy - sh, sw * 2, sh * 2),
      )
      ..style = PaintingStyle.fill;

    // Shield stroke
    final Paint shieldStroke = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.011
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(shieldPath, shieldFill);
    canvas.drawPath(shieldPath, shieldStroke);

    // Checkmark inside shield (tertiary colour)
    _drawShieldCheck(canvas, sx, sy, sw, sh);
  }

  void _drawShieldCheck(
    Canvas canvas,
    double sx,
    double sy,
    double sw,
    double sh,
  ) {
    final Paint checkPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw * 0.22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path checkPath = Path();
    // Tick: down-left then up-right
    checkPath.moveTo(sx - sw * 0.38, sy + sh * 0.08);
    checkPath.lineTo(sx - sw * 0.08, sy + sh * 0.36);
    checkPath.lineTo(sx + sw * 0.42, sy - sh * 0.22);

    canvas.drawPath(checkPath, checkPaint);
  }

  // ── Sync arrows ────────────────────────────────────────────────────────────

  void _drawSyncArrows(Canvas canvas, double w, double h) {
    // Two opposing arc-arrows forming a circular sync symbol.
    // Positioned below and to the right of the cloud, slightly overlapping.
    final double cx = w * 0.72;
    final double cy = h * 0.74;
    final double r = w * 0.095;

    final Paint arcPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.014
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint = Paint()
      ..color = AppColors.tertiary.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Background circle fill
    canvas.drawCircle(Offset(cx, cy), r * 1.30, fillPaint);

    // Top arc (clockwise, from ~200° to ~340°)
    final Rect arcRect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(arcRect, _deg(200), _deg(140), false, arcPaint);

    // Bottom arc (clockwise, from ~20° to ~160°)
    canvas.drawArc(arcRect, _deg(20), _deg(140), false, arcPaint);

    // Arrowhead on top arc (at ~340°)
    _drawArrowhead(canvas, cx, cy, r, _deg(340), arcPaint);

    // Arrowhead on bottom arc (at ~160°)
    _drawArrowhead(canvas, cx, cy, r, _deg(160), arcPaint);

    // Second smaller sync symbol top-left for depth
    final double cx2 = w * 0.28;
    final double cy2 = h * 0.76;
    final double r2 = w * 0.060;

    final Paint arcPaint2 = Paint()
      ..color = AppColors.tertiary.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.010
      ..strokeCap = StrokeCap.round;

    final Paint fillPaint2 = Paint()
      ..color = AppColors.tertiary.withOpacity(0.10)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(cx2, cy2), r2 * 1.30, fillPaint2);

    final Rect arcRect2 =
        Rect.fromCircle(center: Offset(cx2, cy2), radius: r2);
    canvas.drawArc(arcRect2, _deg(200), _deg(140), false, arcPaint2);
    canvas.drawArc(arcRect2, _deg(20), _deg(140), false, arcPaint2);
    _drawArrowhead(canvas, cx2, cy2, r2, _deg(340), arcPaint2);
    _drawArrowhead(canvas, cx2, cy2, r2, _deg(160), arcPaint2);
  }

  void _drawArrowhead(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double angleRad,
    Paint paint,
  ) {
    // Point on the arc circle at angleRad
    final double px = cx + r * math.cos(angleRad);
    final double py = cy + r * math.sin(angleRad);

    // Tangent direction (perpendicular to radius, clockwise)
    final double tx = -math.sin(angleRad);
    final double ty = math.cos(angleRad);

    final double as = r * 0.38; // arrowhead size
    final Path arrow = Path();
    arrow.moveTo(px, py);
    arrow.lineTo(
      px - as * (tx * 0.7 + (-ty) * 0.5),
      py - as * (ty * 0.7 + tx * 0.5),
    );
    arrow.moveTo(px, py);
    arrow.lineTo(
      px - as * (tx * 0.7 - (-ty) * 0.5),
      py - as * (ty * 0.7 - tx * 0.5),
    );

    final Paint arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(arrow, arrowPaint);
  }

  // ── Accent dots ────────────────────────────────────────────────────────────

  void _drawAccentDots(Canvas canvas, double w, double h) {
    final List<_DotSpec> dots = [
      _DotSpec(w * 0.10, h * 0.22, w * 0.018, AppColors.tertiary, 0.70),
      _DotSpec(w * 0.88, h * 0.28, w * 0.014, AppColors.tertiary, 0.50),
      _DotSpec(w * 0.15, h * 0.75, w * 0.012, AppColors.secondary, 0.40),
      _DotSpec(w * 0.85, h * 0.68, w * 0.016, AppColors.secondary, 0.35),
      _DotSpec(w * 0.50, h * 0.88, w * 0.013, AppColors.tertiary, 0.55),
      _DotSpec(w * 0.06, h * 0.48, w * 0.010, AppColors.tertiary, 0.45),
      _DotSpec(w * 0.94, h * 0.50, w * 0.010, AppColors.secondary, 0.45),
    ];

    for (final dot in dots) {
      final Paint p = Paint()
        ..color = dot.color.withOpacity(dot.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dot.x, dot.y), dot.r, p);
    }
  }

  // ── Offline bars (signal bars crossed out) ────────────────────────────────

  void _drawOfflineBars(Canvas canvas, double w, double h) {
    // Small "no signal / offline" icon below the cloud on the left side.
    final double bx = w * 0.18;
    final double by = h * 0.73;
    final double bw = w * 0.028; // bar width
    final double gap = w * 0.018; // gap between bars
    final List<double> heights = [h * 0.030, h * 0.050, h * 0.072];

    for (int i = 0; i < 3; i++) {
      final double barX = bx + i * (bw + gap);
      final double barH = heights[i];
      final double barTop = by - barH;

      final Paint barPaint = Paint()
        ..color = AppColors.secondary.withOpacity(0.30 + i * 0.15)
        ..style = PaintingStyle.fill;
      final RRect bar = RRect.fromRectAndRadius(
        Rect.fromLTWH(barX, barTop, bw, barH),
        Radius.circular(bw * 0.30),
      );
      canvas.drawRRect(bar, barPaint);
    }

    // Cross-out line through bars (indicating offline)
    final Paint crossPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.010
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(bx - w * 0.005, by + h * 0.012),
      Offset(bx + 3 * bw + 2 * gap + w * 0.005, by - heights[2] - h * 0.012),
      crossPaint,
    );

    // Cloud-upload arrow above bars (tertiary, indicating sync will happen)
    final double arrowX = bx + (3 * bw + 2 * gap) / 2;
    final double arrowBaseY = by - heights[2] - h * 0.055;
    final Paint upArrowPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.010
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path upArrow = Path()
      ..moveTo(arrowX, arrowBaseY - h * 0.040)
      ..lineTo(arrowX, arrowBaseY)
      ..moveTo(arrowX - w * 0.018, arrowBaseY - h * 0.022)
      ..lineTo(arrowX, arrowBaseY - h * 0.040)
      ..lineTo(arrowX + w * 0.018, arrowBaseY - h * 0.022);

    canvas.drawPath(upArrow, upArrowPaint);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Convert degrees to radians.
  static double _deg(double degrees) => degrees * math.pi / 180.0;

  @override
  bool shouldRepaint(_OfflineFirstPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Small data classes used only by the painter
// ─────────────────────────────────────────────────────────────────────────────

class _Circle {
  const _Circle(this.cx, this.cy, this.r);
  final double cx;
  final double cy;
  final double r;
}

class _DotSpec {
  const _DotSpec(this.x, this.y, this.r, this.color, this.opacity);
  final double x;
  final double y;
  final double r;
  final Color color;
  final double opacity;
}

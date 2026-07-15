import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../config/theme/app_spacing.dart';

/// Onboarding page 3 — "AI Study Assistant" illustration.
///
/// Renders a hexagonal circuit grid (AppColors.secondary) overlaid with a
/// central lightning-bolt spark and radiating energy rays (AppColors.tertiary).
/// All coordinates are expressed as fractions of [Size] so the widget scales
/// correctly at any render size.
class OnboardingIllustration3 extends StatelessWidget {
  const OnboardingIllustration3({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.xxxl * 3, // 192 dp
      width: double.infinity,
      child: CustomPaint(painter: _AIAssistantPainter()),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _AIAssistantPainter extends CustomPainter {
  @override
  bool shouldRepaint(_AIAssistantPainter old) => false;

  @override
  void paint(Canvas canvas, Size size) {
    _drawHexGrid(canvas, size);
    _drawCircuitConnectors(canvas, size);
    _drawRays(canvas, size);
    _drawGlowHalo(canvas, size);
    _drawLightningBolt(canvas, size);
    _drawSparkParticles(canvas, size);
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Returns the 6 vertices of a regular hexagon centred at [cx, cy] with the
  /// given [radius]. The first vertex is at the top (flat-top orientation).
  List<Offset> _hexVertices(double cx, double cy, double radius) {
    return List.generate(6, (i) {
      final angle = math.pi / 180 * (60 * i - 30);
      return Offset(cx + radius * math.cos(angle),
          cy + radius * math.sin(angle));
    });
  }

  /// Draws a single hollow hexagon.
  void _drawHex(Canvas canvas, Paint paint, double cx, double cy,
      double radius) {
    final pts = _hexVertices(cx, cy, radius);
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < 6; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  // ── Layer 1 — Hexagonal circuit grid ──────────────────────────────────────

  void _drawHexGrid(Canvas canvas, Size size) {
    // Outline-only hexagons scattered in a grid pattern.
    final outlinePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.004;

    // Filled (dimmer) background hexagons for depth.
    final fillPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Hex geometry: for a flat-top hex grid the horizontal spacing is
    //   colWidth  = sqrt(3) * r
    //   rowHeight = 1.5 * r
    // and every odd column is offset by rowHeight/2 vertically.
    final double r = size.width * 0.072; // hex radius as fraction of width
    final double colW = math.sqrt(3) * r;
    final double rowH = 1.5 * r;

    // How many columns/rows to fill the canvas plus bleed.
    final int cols = (size.width / colW).ceil() + 2;
    final int rows = (size.height / rowH).ceil() + 2;

    for (int col = -1; col < cols; col++) {
      for (int row = -1; row < rows; row++) {
        final double cx = col * colW + (row.isOdd ? colW * 0.5 : 0);
        final double cy = row * rowH;
        canvas.drawPath(
          Path()
            ..moveTo(_hexVertices(cx, cy, r)[0].dx,
                _hexVertices(cx, cy, r)[0].dy)
            ..let((p) {
              final v = _hexVertices(cx, cy, r);
              for (int i = 1; i < 6; i++) {
                p.lineTo(v[i].dx, v[i].dy);
              }
              p.close();
              return p;
            }),
          fillPaint,
        );
        _drawHex(canvas, outlinePaint, cx, cy, r);
      }
    }

    // Brighter "active" hexagons near the centre to simulate a node cluster.
    final brightPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.006;

    final brightFillPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    const List<List<double>> highlights = [
      [0.30, 0.30],
      [0.50, 0.20],
      [0.70, 0.30],
      [0.25, 0.55],
      [0.75, 0.55],
      [0.50, 0.72],
    ];

    for (final h in highlights) {
      final cx = size.width * h[0];
      final cy = size.height * h[1];
      _drawHex(canvas, brightFillPaint, cx, cy, r * 1.1);
      _drawHex(canvas, brightPaint, cx, cy, r * 1.1);
    }
  }

  // ── Layer 2 — Circuit-board connector lines ────────────────────────────────

  void _drawCircuitConnectors(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.40)
      ..strokeWidth = size.width * 0.004
      ..strokeCap = StrokeCap.round;

    // Node positions (fractions of size) that simulate circuit pads.
    final nodes = [
      Offset(0.30 * size.width, 0.30 * size.height),
      Offset(0.50 * size.width, 0.20 * size.height),
      Offset(0.70 * size.width, 0.30 * size.height),
      Offset(0.25 * size.width, 0.55 * size.height),
      Offset(0.75 * size.width, 0.55 * size.height),
      Offset(0.50 * size.width, 0.72 * size.height),
      Offset(0.50 * size.width, 0.50 * size.height), // centre
    ];

    // Connections: index pairs
    const edges = [
      [0, 1], [1, 2], [0, 6], [2, 6],
      [3, 6], [4, 6], [5, 6], [1, 6],
      [0, 3], [2, 4], [3, 5], [4, 5],
    ];

    for (final e in edges) {
      canvas.drawLine(nodes[e[0]], nodes[e[1]], paint);
    }

    // Circuit node dots.
    final dotPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < nodes.length - 1; i++) {
      canvas.drawCircle(nodes[i], size.width * 0.012, dotPaint);
    }
  }

  // ── Layer 3 — Radiating energy rays ───────────────────────────────────────

  void _drawRays(Canvas canvas, Size size) {
    final cx = size.width * 0.50;
    final cy = size.height * 0.50;

    final paint = Paint()
      ..strokeCap = StrokeCap.round;

    // 8 rays at 45° intervals; each tapers from thick-near to thin-far.
    const rayCount = 8;
    const innerR = 0.14; // fraction of width
    const outerR = 0.38; // fraction of width

    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i - math.pi / 2;
      final startX = cx + size.width * innerR * math.cos(angle);
      final startY = cy + size.width * innerR * math.sin(angle);
      final endX = cx + size.width * outerR * math.cos(angle);
      final endY = cy + size.width * outerR * math.sin(angle);

      // Gradient-like effect using two overlapping lines.
      paint
        ..color = AppColors.tertiary.withValues(alpha: 0.50)
        ..strokeWidth = size.width * 0.010;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      paint
        ..color = AppColors.tertiary.withValues(alpha: 0.20)
        ..strokeWidth = size.width * 0.022;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // 4 shorter inter-cardinal rays for a richer starburst.
    const innerR2 = 0.10;
    const outerR2 = 0.22;
    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * math.pi / rayCount) * i - math.pi / 2 + math.pi / 8;
      final startX = cx + size.width * innerR2 * math.cos(angle);
      final startY = cy + size.width * innerR2 * math.sin(angle);
      final endX = cx + size.width * outerR2 * math.cos(angle);
      final endY = cy + size.width * outerR2 * math.sin(angle);

      paint
        ..color = AppColors.tertiary.withValues(alpha: 0.30)
        ..strokeWidth = size.width * 0.006;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  // ── Layer 4 — Soft glow halo behind the bolt ──────────────────────────────

  void _drawGlowHalo(Canvas canvas, Size size) {
    final cx = size.width * 0.50;
    final cy = size.height * 0.50;

    final glowPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);

    canvas.drawCircle(
        Offset(cx, cy), size.width * 0.18, glowPaint);

    // Tighter bright core.
    final corePaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(cx, cy), size.width * 0.08, corePaint);
  }

  // ── Layer 5 — Lightning-bolt spark ────────────────────────────────────────

  void _drawLightningBolt(Canvas canvas, Size size) {
    // The bolt is centred at (0.50, 0.50) with coordinates as fractions.
    // Shape: classic double-angled zigzag going top→bottom.
    final double cx = size.width * 0.50;
    final double cy = size.height * 0.50;

    // Scale the bolt to be visually prominent but not overwhelming.
    final double bw = size.width * 0.12; // bolt bounding-box half-width
    final double bh = size.height * 0.38; // bolt bounding-box half-height

    // Upper half: top-right → midpoint-left
    final top = Offset(cx + bw * 0.40, cy - bh);
    final midLeft = Offset(cx - bw * 0.10, cy - bh * 0.05);
    final midRight = Offset(cx + bw * 0.20, cy + bh * 0.05);
    final bottom = Offset(cx - bw * 0.40, cy + bh);

    // The "fin" points that give the bolt its tapered side silhouette.
    final topInner = Offset(cx + bw * 0.05, cy - bh);
    final midLeftInner = Offset(cx + bw * 0.10, cy - bh * 0.05);
    final midRightInner = Offset(cx + bw * 0.55, cy + bh * 0.05);
    final bottomInner = Offset(cx - bw * 0.05, cy + bh);

    final boltPath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(midLeft.dx, midLeft.dy)
      ..lineTo(midRight.dx, midRight.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(bottomInner.dx, bottomInner.dy)
      ..lineTo(midRightInner.dx, midRightInner.dy)
      ..lineTo(midLeftInner.dx, midLeftInner.dy)
      ..lineTo(topInner.dx, topInner.dy)
      ..close();

    // Fill.
    canvas.drawPath(
      boltPath,
      Paint()
        ..color = AppColors.tertiary
        ..style = PaintingStyle.fill,
    );

    // Inner highlight for depth.
    final highlight = Path()
      ..moveTo(topInner.dx, topInner.dy)
      ..lineTo(midLeftInner.dx, midLeftInner.dy)
      ..lineTo(cx + bw * 0.22, cy - bh * 0.02)
      ..lineTo(cx + bw * 0.05, cy - bh + size.height * 0.02)
      ..close();

    canvas.drawPath(
      highlight,
      Paint()
        ..color = AppColors.tertiaryLight.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    // Crisp outline.
    canvas.drawPath(
      boltPath,
      Paint()
        ..color = AppColors.tertiaryDark.withValues(alpha: 0.40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.005
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── Layer 6 — Spark / particle accents ────────────────────────────────────

  void _drawSparkParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Small circles scattered around the bolt to simulate energy sparks.
    const sparks = [
      [0.34, 0.26, 0.018, 0.90],
      [0.66, 0.26, 0.014, 0.75],
      [0.28, 0.50, 0.016, 0.80],
      [0.72, 0.50, 0.012, 0.70],
      [0.38, 0.76, 0.018, 0.85],
      [0.62, 0.76, 0.015, 0.75],
      [0.50, 0.15, 0.010, 0.65],
      [0.50, 0.85, 0.010, 0.60],
      [0.20, 0.38, 0.008, 0.50],
      [0.80, 0.38, 0.008, 0.50],
      [0.20, 0.65, 0.008, 0.50],
      [0.80, 0.65, 0.008, 0.50],
    ];

    for (final s in sparks) {
      paint.color = AppColors.tertiary.withValues(alpha: s[3]);
      canvas.drawCircle(
        Offset(size.width * s[0], size.height * s[1]),
        size.width * s[2],
        paint,
      );
    }

    // Tiny four-pointed star shapes at key positions.
    _drawStar(canvas, size, 0.68, 0.22, 0.022);
    _drawStar(canvas, size, 0.32, 0.78, 0.022);
    _drawStar(canvas, size, 0.78, 0.60, 0.016);
  }

  void _drawStar(Canvas canvas, Size size, double fx, double fy,
      double radiusFrac) {
    final cx = size.width * fx;
    final cy = size.height * fy;
    final r = size.width * radiusFrac;
    final r2 = r * 0.38;

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = math.pi / 4 * i - math.pi / 2;
      final radius = i.isEven ? r : r2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.tertiary.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill,
    );
  }
}

// ── Extension helper used to chain [Path] construction inline ─────────────
extension _PathLet<T> on T {
  R let<R>(R Function(T) block) => block(this);
}

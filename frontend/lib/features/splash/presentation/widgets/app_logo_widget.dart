import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';

/// A 80×80 dp branded logo for StudyFlow AI rendered entirely via [CustomPaint].
///
/// Displays a stylised open book with a spark/lightning-bolt accent above
/// the centre. No raster assets or external packages are used.
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  static const double _size = 80.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(painter: _AppLogoPainter()),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Background circle ──────────────────────────────────────────────────
    final Paint bgPaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

    // ── Left page of open book ─────────────────────────────────────────────
    // Spine is at horizontal centre; left page fans left with a slight curve.
    final Paint leftPagePaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final Path leftPage = Path()
      ..moveTo(w * 0.50, h * 0.40) // top of spine
      ..cubicTo(
        w * 0.42, h * 0.37, // control 1 — near spine, slightly up
        w * 0.20, h * 0.38, // control 2 — far left, still near top
        w * 0.18, h * 0.42, // far-left top corner
      )
      ..lineTo(w * 0.18, h * 0.72) // far-left bottom corner
      ..cubicTo(
        w * 0.20, h * 0.68, // control 1 — bottom left
        w * 0.42, h * 0.67, // control 2 — near spine bottom
        w * 0.50, h * 0.70, // bottom of spine
      )
      ..close();

    canvas.drawPath(leftPage, leftPagePaint);

    // Left page lines (horizontal rules suggesting text)
    final Paint leftLinePaint = Paint()
      ..color = AppColors.onPrimary.withValues(alpha: 0.35)
      ..strokeWidth = h * 0.022
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final double y = h * (0.50 + i * 0.065);
      canvas.drawLine(
        Offset(w * 0.24, y),
        Offset(w * 0.46, y),
        leftLinePaint,
      );
    }

    // ── Right page of open book ────────────────────────────────────────────
    final Paint rightPagePaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final Path rightPage = Path()
      ..moveTo(w * 0.50, h * 0.40) // top of spine
      ..cubicTo(
        w * 0.58, h * 0.37, // control 1 — near spine, slightly up
        w * 0.80, h * 0.38, // control 2 — far right, near top
        w * 0.82, h * 0.42, // far-right top corner
      )
      ..lineTo(w * 0.82, h * 0.72) // far-right bottom corner
      ..cubicTo(
        w * 0.80, h * 0.68, // control 1 — bottom right
        w * 0.58, h * 0.67, // control 2 — near spine bottom
        w * 0.50, h * 0.70, // bottom of spine
      )
      ..close();

    canvas.drawPath(rightPage, rightPagePaint);

    // Right page lines
    final Paint rightLinePaint = Paint()
      ..color = AppColors.onTertiary.withValues(alpha: 0.35)
      ..strokeWidth = h * 0.022
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final double y = h * (0.50 + i * 0.065);
      canvas.drawLine(
        Offset(w * 0.54, y),
        Offset(w * 0.76, y),
        rightLinePaint,
      );
    }

    // ── Spine shadow line ──────────────────────────────────────────────────
    final Paint spinePaint = Paint()
      ..color = AppColors.primaryDark.withValues(alpha: 0.20)
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(w * 0.50, h * 0.40),
      Offset(w * 0.50, h * 0.70),
      spinePaint,
    );

    // ── Lightning-bolt / spark accent (above book centre) ─────────────────
    // Classic two-triangle chevron bolt, scaled as fraction of size.
    final Paint boltPaint = Paint()
      ..color = AppColors.tertiary
      ..style = PaintingStyle.fill;

    final Path bolt = Path()
      // Upper part: top-right → tip → inner junction
      ..moveTo(w * 0.555, h * 0.16) // top-right
      ..lineTo(w * 0.460, h * 0.30) // midpoint tip (right side)
      ..lineTo(w * 0.520, h * 0.30) // inner overlap
      // Lower part: continues to bottom, sweeps back up
      ..lineTo(w * 0.445, h * 0.44) // bottom point
      ..lineTo(w * 0.540, h * 0.30) // inner overlap (left)
      ..lineTo(w * 0.480, h * 0.30) // midpoint tip (left side)
      ..lineTo(w * 0.575, h * 0.16) // back to top-left
      ..close();

    // Slight halo glow behind the bolt
    final Paint boltGlowPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

    canvas.drawPath(bolt, boltGlowPaint);
    canvas.drawPath(bolt, boltPaint);

    // Small star/sparkle dots flanking the bolt
    final Paint sparklePaint = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.38, h * 0.22), w * 0.025, sparklePaint);
    canvas.drawCircle(Offset(w * 0.62, h * 0.20), w * 0.018, sparklePaint);
    canvas.drawCircle(Offset(w * 0.65, h * 0.30), w * 0.013, sparklePaint);
  }

  @override
  bool shouldRepaint(_AppLogoPainter old) => false;
}

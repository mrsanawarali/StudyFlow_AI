import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Premium animated 3-D sync scene for onboarding page 2 — "Offline First".
///
/// Composition:
///   • Central cloud storage card with lock/shield icon — main float
///   • Mobile device card — floats with phase 0.25
///   • Laptop card — floats with phase 0.55
///   • Tablet card — floats with phase 0.75
///   • Sync arrows between cloud and devices — animate rotation
///   • Download progress indicator — animated bar
///   • Sparkle and glow accents
///
/// Replaces the old static [CustomPaint] with a fully animated [StatefulWidget].
/// Drop-in replacement — same class name, same constructor.
class OnboardingIllustration2 extends StatefulWidget {
  const OnboardingIllustration2({super.key});

  @override
  State<OnboardingIllustration2> createState() =>
      _OnboardingIllustration2State();
}

class _OnboardingIllustration2State extends State<OnboardingIllustration2>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _syncCtrl;  // sync arrows rotation
  late final AnimationController _dlCtrl;    // download bar progress
  late final AnimationController _sparkleCtrl;
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _syncCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();

    _dlCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _syncCtrl.dispose();
    _dlCtrl.dispose();
    _sparkleCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: SizedBox(
        height: AppSpacing.xxxl * 3, // 192 dp
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_floatCtrl, _syncCtrl, _dlCtrl, _sparkleCtrl]),
          builder: (context, _) {
            return CustomPaint(
              painter: _OfflineSyncScenePainter(
                floatT: _floatCtrl.value,
                syncT: _syncCtrl.value,
                dlT: _dlCtrl.value,
                sparkleT: _sparkleCtrl.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _OfflineSyncScenePainter extends CustomPainter {
  const _OfflineSyncScenePainter({
    required this.floatT,
    required this.syncT,
    required this.dlT,
    required this.sparkleT,
  });

  final double floatT;
  final double syncT;
  final double dlT;
  final double sparkleT;

  double _floatY(double phase, {double amplitude = 5.5}) {
    final p = (floatT + phase) % 1.0;
    return amplitude * math.sin(p * math.pi);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ── Background ambient glows ──────────────────────────────────────────
    _glow(canvas, Offset(w * 0.5, h * 0.40), w * 0.30,
        AppColors.secondary.withValues(alpha: 0.10));
    _glow(canvas, Offset(w * 0.82, h * 0.68), w * 0.16,
        AppColors.tertiary.withValues(alpha: 0.09));
    _glow(canvas, Offset(w * 0.18, h * 0.65), w * 0.14,
        AppColors.secondaryLight.withValues(alpha: 0.07));

    // ── Sync orbit ring (subtle dashed circle) ───────────────────────────
    _drawOrbitRing(canvas, w, h);

    // ── Animated sync arrows around cloud ────────────────────────────────
    _drawSyncArrows(canvas, w, h);

    // ── Laptop — bottom-left (phase 0.55) ────────────────────────────────
    final laptopFloat = _floatY(0.55, amplitude: 6.0);
    canvas.save();
    canvas.translate(w * 0.14, h * 0.56 + laptopFloat);
    canvas.rotate(-0.16);
    _drawLaptop(canvas, w, h);
    canvas.restore();

    // ── Tablet — bottom-right (phase 0.75) ───────────────────────────────
    final tabletFloat = _floatY(0.75, amplitude: 5.0);
    canvas.save();
    canvas.translate(w * 0.86, h * 0.52 + tabletFloat);
    canvas.rotate(0.18);
    _drawTablet(canvas, w, h);
    canvas.restore();

    // ── Mobile — left-centre (phase 0.25) ────────────────────────────────
    final mobileFloat = _floatY(0.25, amplitude: 7.0);
    canvas.save();
    canvas.translate(w * 0.16, h * 0.26 + mobileFloat);
    canvas.rotate(-0.12);
    _drawMobile(canvas, w, h);
    canvas.restore();

    // ── Central cloud storage card (phase 0.0) ───────────────────────────
    final cloudFloat = _floatY(0.0, amplitude: 4.5);
    canvas.save();
    canvas.translate(w * 0.50, h * 0.35 + cloudFloat);
    _drawCloudCard(canvas, w, h);
    canvas.restore();

    // ── Download indicator — bottom-centre ───────────────────────────────
    _drawDownloadBar(canvas, w, h);

    // ── Sparkles ──────────────────────────────────────────────────────────
    final sr = 0.011 + sparkleT * 0.005;
    _sparkle(canvas, Offset(w * 0.62, h * 0.05),
        w * sr, AppColors.tertiary.withValues(alpha: 0.85));
    _sparkle(canvas, Offset(w * 0.24, h * 0.08),
        w * sr * 0.70, AppColors.secondaryLight.withValues(alpha: 0.75));
    _sparkle(canvas, Offset(w * 0.91, h * 0.34),
        w * sr * 0.65, AppColors.tertiary.withValues(alpha: 0.70));
    _sparkle(canvas, Offset(w * 0.06, h * 0.45),
        w * sr * 0.55, AppColors.secondaryLight.withValues(alpha: 0.60));
  }

  // ── Central cloud card ───────────────────────────────────────────────────

  void _drawCloudCard(Canvas canvas, double w, double h) {
    final cw = w * 0.38;
    final ch = h * 0.42;

    // Glass card
    _glassRect(canvas, cw, ch, 14,
        AppColors.secondary.withValues(alpha: 0.20),
        AppColors.secondaryLight.withValues(alpha: 0.28));

    // Cloud icon (simplified 3-bump silhouette)
    final cloudPaint = Paint()
      ..color = AppColors.secondaryLight.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final cloudGlow = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final cloudPath = _cloudPath(0, -ch * 0.14, cw * 0.55, ch * 0.22);
    canvas.drawPath(cloudPath, cloudGlow);
    canvas.drawPath(cloudPath, cloudPaint);

    // Shield below cloud
    _drawShieldIcon(canvas, 0, ch * 0.12, cw * 0.18, ch * 0.22);

    // Label "Secure Sync"
    final tp = TextPainter(
      text: TextSpan(
        text: 'Secure Sync',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.80),
          fontSize: w * 0.030,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, ch * 0.32));
  }

  Path _cloudPath(double cx, double cy, double cloudW, double cloudH) {
    final path = Path();
    final l = cx - cloudW / 2;
    final r = cx + cloudW / 2;
    final b = cy + cloudH * 0.40;
    final midY = cy;

    path.moveTo(l + cloudW * 0.10, b);
    path.lineTo(r - cloudW * 0.10, b);
    path.arcToPoint(Offset(r, midY),
        radius: Radius.circular(cloudH * 0.22), clockwise: false);
    path.arcToPoint(Offset(cx + cloudW * 0.15, midY - cloudH * 0.18),
        radius: Radius.circular(cloudH * 0.20), clockwise: false);
    path.arcToPoint(Offset(cx - cloudW * 0.15, midY - cloudH * 0.18),
        radius: Radius.circular(cloudH * 0.26), clockwise: false);
    path.arcToPoint(Offset(l, midY),
        radius: Radius.circular(cloudH * 0.20), clockwise: false);
    path.arcToPoint(Offset(l + cloudW * 0.10, b),
        radius: Radius.circular(cloudH * 0.22), clockwise: false);
    path.close();
    return path;
  }

  void _drawShieldIcon(
      Canvas canvas, double cx, double cy, double sw, double sh) {
    final paint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.90)
      ..style = PaintingStyle.fill;
    final glowPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.30)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final path = Path()
      ..moveTo(cx, cy - sh)
      ..lineTo(cx + sw, cy - sh * 0.65)
      ..lineTo(cx + sw, cy + sh * 0.10)
      ..quadraticBezierTo(cx + sw * 0.50, cy + sh, cx, cy + sh)
      ..quadraticBezierTo(cx - sw * 0.50, cy + sh, cx - sw, cy + sh * 0.10)
      ..lineTo(cx - sw, cy - sh * 0.65)
      ..close();

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);

    // Tick
    final tickPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw * 0.22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final tickPath = Path()
      ..moveTo(cx - sw * 0.38, cy + sh * 0.05)
      ..lineTo(cx - sw * 0.08, cy + sh * 0.32)
      ..lineTo(cx + sw * 0.42, cy - sh * 0.25);
    canvas.drawPath(tickPath, tickPaint);
  }

  // ── Mobile device ─────────────────────────────────────────────────────────

  void _drawMobile(Canvas canvas, double w, double h) {
    final dw = w * 0.14;
    final dh = h * 0.30;
    final cr = dw * 0.18;

    _glassRect(canvas, dw, dh, cr,
        AppColors.secondary.withValues(alpha: 0.18),
        AppColors.secondaryLight.withValues(alpha: 0.25));

    // Screen content — coloured bars
    _contentBars(canvas, dw * 0.60, dh * 0.48, 3,
        AppColors.secondaryLight.withValues(alpha: 0.60), dh * 0.045);

    // Home bar
    final homeBar = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(0, dh * 0.40), width: dw * 0.38, height: dh * 0.025),
        const Radius.circular(3),
      ),
      homeBar,
    );
  }

  // ── Laptop ────────────────────────────────────────────────────────────────

  void _drawLaptop(Canvas canvas, double w, double h) {
    final lw = w * 0.26;
    final lh = h * 0.20;

    // Screen
    _glassRect(canvas, lw, lh, 6,
        AppColors.secondary.withValues(alpha: 0.18),
        AppColors.secondaryLight.withValues(alpha: 0.25));

    // Screen content
    _contentBars(canvas, lw * 0.68, lh * 0.30, 2,
        AppColors.tertiary.withValues(alpha: 0.65), lh * 0.065);

    // Keyboard base
    final basePaint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.30)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(0, lh / 2 + lh * 0.14),
            width: lw * 1.15,
            height: lh * 0.14),
        const Radius.circular(4),
      ),
      basePaint,
    );
  }

  // ── Tablet ────────────────────────────────────────────────────────────────

  void _drawTablet(Canvas canvas, double w, double h) {
    final tw = w * 0.19;
    final th = h * 0.28;

    _glassRect(canvas, tw, th, 8,
        AppColors.tertiary.withValues(alpha: 0.16),
        AppColors.tertiaryLight.withValues(alpha: 0.28));

    // Content
    _contentBars(canvas, tw * 0.62, th * 0.40, 3,
        AppColors.tertiaryLight.withValues(alpha: 0.65), th * 0.05);

    // Camera dot
    canvas.drawCircle(
      Offset(0, -th * 0.44),
      tw * 0.06,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );
  }

  // ── Orbit ring ────────────────────────────────────────────────────────────

  void _drawOrbitRing(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = AppColors.secondary.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(w * 0.50, h * 0.50),
          width: w * 0.72,
          height: h * 0.64),
      paint,
    );
  }

  // ── Animated sync arrows ──────────────────────────────────────────────────

  void _drawSyncArrows(Canvas canvas, double w, double h) {
    final cx = w * 0.50;
    final cy = h * 0.36;
    final r = w * 0.20;
    final angle = syncT * 2 * math.pi;

    final arcPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(angle);

    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    // Top arc
    canvas.drawArc(rect, _deg(200), _deg(130), false, arcPaint);
    // Bottom arc
    canvas.drawArc(rect, _deg(20), _deg(130), false, arcPaint);
    // Arrowheads
    _arrowhead(canvas, r, _deg(330), arcPaint);
    _arrowhead(canvas, r, _deg(150), arcPaint);

    canvas.restore();
  }

  void _arrowhead(Canvas canvas, double r, double angle, Paint paint) {
    final px = r * math.cos(angle);
    final py = r * math.sin(angle);
    final tx = -math.sin(angle);
    final ty = math.cos(angle);
    final as = r * 0.20;

    final path = Path()
      ..moveTo(px, py)
      ..lineTo(px - as * (tx * 0.7 + (-ty) * 0.5),
          py - as * (ty * 0.7 + tx * 0.5))
      ..moveTo(px, py)
      ..lineTo(px - as * (tx * 0.7 - (-ty) * 0.5),
          py - as * (ty * 0.7 - tx * 0.5));

    canvas.drawPath(path, paint);
  }

  // ── Download bar ─────────────────────────────────────────────────────────

  void _drawDownloadBar(Canvas canvas, double w, double h) {
    final bx = w * 0.50;
    final by = h * 0.88;
    final bw = w * 0.38;
    final bh = h * 0.030;
    final cr = bh / 2;

    // Track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(bx, by), width: bw, height: bh),
          Radius.circular(cr)),
      trackPaint,
    );

    // Animated fill
    final fillW = bw * (0.25 + dlT * 0.65);
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.secondary, AppColors.tertiary],
      ).createShader(Rect.fromCenter(
          center: Offset(bx - bw / 2 + fillW / 2, by),
          width: fillW,
          height: bh))
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bx - bw / 2, by - bh / 2, fillW, bh),
        Radius.circular(cr),
      ),
      fillPaint,
    );

    // Download icon above bar
    final iconPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.009
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final iconPath = Path()
      ..moveTo(bx, by - bh * 3.5)
      ..lineTo(bx, by - bh * 1.6)
      ..moveTo(bx - w * 0.016, by - bh * 2.2)
      ..lineTo(bx, by - bh * 1.6)
      ..lineTo(bx + w * 0.016, by - bh * 2.2);
    canvas.drawPath(iconPath, iconPaint);
  }

  // ── Glass rect helper ─────────────────────────────────────────────────────

  void _glassRect(Canvas canvas, double cw, double ch, double cr,
      Color fill, Color border) {
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
        Radius.circular(cr));
    canvas.drawRRect(rr, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawRRect(
        rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.0)
            ],
          ).createShader(Rect.fromCenter(
              center: Offset.zero, width: cw, height: ch)));
    canvas.drawRRect(
        rr,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
  }

  // ── Content bars helper ───────────────────────────────────────────────────

  void _contentBars(Canvas canvas, double maxW, double startY, int count,
      Color color, double barH) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (int i = 0; i < count; i++) {
      final bw = maxW * (i == count - 1 ? 0.60 : 1.0);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(0, startY + i * barH * 2.0),
              width: bw,
              height: barH),
          Radius.circular(barH / 2),
        ),
        paint,
      );
    }
  }

  // ── Glow ─────────────────────────────────────────────────────────────────

  void _glow(Canvas canvas, Offset center, double r, Color color) {
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  // ── Sparkle ───────────────────────────────────────────────────────────────

  void _sparkle(Canvas canvas, Offset c, double r, Color color) {
    const arms = 4;
    const inner = 0.32;
    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final a = (i * math.pi / arms) - math.pi / 2;
      final rad = i.isEven ? r : r * inner;
      final x = c.dx + rad * math.cos(a);
      final y = c.dy + rad * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(
        c, r * 1.6,
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  static double _deg(double d) => d * math.pi / 180.0;

  @override
  bool shouldRepaint(_OfflineSyncScenePainter old) =>
      old.floatT != floatT ||
      old.syncT != syncT ||
      old.dlT != dlT ||
      old.sparkleT != sparkleT;
}

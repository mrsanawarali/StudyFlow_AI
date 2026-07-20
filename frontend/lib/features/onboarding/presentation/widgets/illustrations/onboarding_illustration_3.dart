import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────

/// Premium animated futuristic AI workspace for onboarding page 3.
///
/// Composition:
///   • Central AI brain/core — pulsing glow ring + rotating orbit lines
///   • Floating chat bubble cards (2) — phase-offset float
///   • Smart document card — floats independently
///   • Quiz card — floats independently
///   • Flashcard — floats independently
///   • Summary doc card — floats independently
///   • Connected glowing network lines from core to cards
///   • Magic spark particles — ambient pulse
///   • Soft background glow circles
///
/// Drop-in replacement — same class name and constructor.
class OnboardingIllustration3 extends StatefulWidget {
  const OnboardingIllustration3({super.key});

  @override
  State<OnboardingIllustration3> createState() =>
      _OnboardingIllustration3State();
}

class _OnboardingIllustration3State extends State<OnboardingIllustration3>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;   // 3.2s, reverse=true
  late final AnimationController _orbitCtrl;   // 6s, continuous rotation
  late final AnimationController _pulseCtrl;   // 1.8s, reverse=true
  late final AnimationController _sparkCtrl;   // 2.0s, reverse=true
  late final AnimationController _enterCtrl;
  late final Animation<double> _enterFade;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
    _orbitCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat();
    _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _sparkCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _enterCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));
    _enterFade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _orbitCtrl.dispose();
    _pulseCtrl.dispose();
    _sparkCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _enterFade,
      child: SizedBox(
        height: AppSpacing.xxxl * 3,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: Listenable.merge(
              [_floatCtrl, _orbitCtrl, _pulseCtrl, _sparkCtrl]),
          builder: (context, _) => CustomPaint(
            painter: _AIWorkspacePainter(
              floatT: _floatCtrl.value,
              orbitT: _orbitCtrl.value,
              pulseT: _pulseCtrl.value,
              sparkT: _sparkCtrl.value,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _AIWorkspacePainter extends CustomPainter {
  const _AIWorkspacePainter({
    required this.floatT,
    required this.orbitT,
    required this.pulseT,
    required this.sparkT,
  });

  final double floatT;   // 0–1 reverse
  final double orbitT;   // 0–1 continuous
  final double pulseT;   // 0–1 reverse
  final double sparkT;   // 0–1 reverse

  // Sine-based float offset for any phase
  double _fy(double phase, {double amp = 5.5}) =>
      amp * math.sin(((floatT + phase) % 1.0) * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.50;
    final cy = h * 0.44;

    // Background ambient glows
    _glow(canvas, Offset(cx, cy), w * 0.28,
        AppColors.tertiary.withValues(alpha: 0.10));
    _glow(canvas, Offset(w * 0.18, h * 0.25), w * 0.16,
        AppColors.secondary.withValues(alpha: 0.09));
    _glow(canvas, Offset(w * 0.84, h * 0.68), w * 0.14,
        AppColors.secondaryLight.withValues(alpha: 0.07));

    // Network lines (drawn before cards so cards sit on top)
    _drawNetworkLines(canvas, w, h, cx, cy);

    // Floating cards (phase-offset)
    // Chat bubble 1 — top-left
    canvas.save();
    canvas.translate(w * 0.12, h * 0.16 + _fy(0.20));
    canvas.rotate(-0.14);
    _drawChatBubble(canvas, w, h, isUser: true);
    canvas.restore();

    // Chat bubble 2 — top-right
    canvas.save();
    canvas.translate(w * 0.88, h * 0.20 + _fy(0.65));
    canvas.rotate(0.16);
    _drawChatBubble(canvas, w, h, isUser: false);
    canvas.restore();

    // Smart document — bottom-left
    canvas.save();
    canvas.translate(w * 0.14, h * 0.70 + _fy(0.45));
    canvas.rotate(-0.18);
    _drawDocCard(canvas, w, h, color: AppColors.secondary);
    canvas.restore();

    // Quiz card — bottom-right
    canvas.save();
    canvas.translate(w * 0.86, h * 0.62 + _fy(0.80));
    canvas.rotate(0.20);
    _drawQuizCard(canvas, w, h);
    canvas.restore();

    // Flashcard — mid-left
    canvas.save();
    canvas.translate(w * 0.10, h * 0.48 + _fy(0.35));
    canvas.rotate(-0.10);
    _drawFlashcard(canvas, w, h);
    canvas.restore();

    // Summary doc — mid-right
    canvas.save();
    canvas.translate(w * 0.90, h * 0.40 + _fy(0.55));
    canvas.rotate(0.12);
    _drawDocCard(canvas, w, h, color: AppColors.tertiary);
    canvas.restore();

    // AI brain core (drawn last so it's on top)
    _drawAICore(canvas, w, h, cx, cy);

    // Spark particles
    final sr = 0.010 + sparkT * 0.006;
    _sparkle(canvas, Offset(w * 0.55, h * 0.07),
        w * sr, AppColors.tertiary.withValues(alpha: 0.85));
    _sparkle(canvas, Offset(w * 0.28, h * 0.06),
        w * sr * 0.70, AppColors.secondaryLight.withValues(alpha: 0.75));
    _sparkle(canvas, Offset(w * 0.88, h * 0.32),
        w * sr * 0.65, AppColors.tertiary.withValues(alpha: 0.70));
    _sparkle(canvas, Offset(w * 0.07, h * 0.58),
        w * sr * 0.55, AppColors.secondaryLight.withValues(alpha: 0.60));
    _sparkle(canvas, Offset(w * 0.48, h * 0.94),
        w * sr * 0.50, AppColors.tertiary.withValues(alpha: 0.55));
  }

  // ── AI brain core ─────────────────────────────────────────────────────────

  void _drawAICore(Canvas canvas, double w, double h, double cx, double cy) {
    final coreR = w * 0.115;
    final pulseR = coreR * (1.0 + pulseT * 0.22);
    final orbitAngle = orbitT * 2 * math.pi;

    // Outer pulse ring
    canvas.drawCircle(Offset(cx, cy), pulseR * 1.35,
        Paint()
          ..color = AppColors.tertiary.withValues(alpha: 0.12 + pulseT * 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Rotating orbit ring
    final orbitPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.008;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(orbitAngle);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: coreR * 1.28),
        0, math.pi * 1.4, false, orbitPaint);
    canvas.rotate(math.pi);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: coreR * 1.28),
        0, math.pi * 0.9, false,
        orbitPaint..color = AppColors.secondary.withValues(alpha: 0.40));
    canvas.restore();

    // Core glow fill
    canvas.drawCircle(Offset(cx, cy), coreR,
        Paint()
          ..shader = RadialGradient(colors: [
            AppColors.tertiary.withValues(alpha: 0.55),
            AppColors.secondary.withValues(alpha: 0.30),
            AppColors.primary.withValues(alpha: 0.80),
          ], stops: const [0.0, 0.55, 1.0])
              .createShader(Rect.fromCircle(
                  center: Offset(cx, cy), radius: coreR)));

    // Core border
    canvas.drawCircle(Offset(cx, cy), coreR,
        Paint()
          ..color = AppColors.tertiary.withValues(alpha: 0.70)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.006);

    // AI brain neural dots inside core
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = w * 0.005
      ..style = PaintingStyle.stroke;
    final nodes = [
      Offset(cx, cy - coreR * 0.40),
      Offset(cx - coreR * 0.35, cy + coreR * 0.20),
      Offset(cx + coreR * 0.35, cy + coreR * 0.20),
      Offset(cx - coreR * 0.20, cy - coreR * 0.10),
      Offset(cx + coreR * 0.20, cy - coreR * 0.10),
    ];
    const edges = [[0,3],[0,4],[3,1],[4,2],[3,4],[1,2]];
    for (final e in edges) {
      canvas.drawLine(nodes[e[0]], nodes[e[1]], linePaint);
    }
    for (final n in nodes) {
      canvas.drawCircle(n, w * 0.012, dotPaint);
    }

    // "AI" text label
    final tp = TextPainter(
      text: TextSpan(
        text: 'AI',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.95),
          fontSize: coreR * 0.55,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas,
        Offset(cx - tp.width / 2, cy + coreR * 0.52));
  }

  // ── Network lines ─────────────────────────────────────────────────────────

  void _drawNetworkLines(
      Canvas canvas, double w, double h, double cx, double cy) {
    final paint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.22)
      ..strokeWidth = w * 0.006
      ..strokeCap = StrokeCap.round;

    // Lines from core centre to card anchor points
    final anchors = [
      Offset(w * 0.12, h * 0.16),  // chat bubble 1
      Offset(w * 0.88, h * 0.20),  // chat bubble 2
      Offset(w * 0.14, h * 0.70),  // smart doc
      Offset(w * 0.86, h * 0.62),  // quiz card
      Offset(w * 0.10, h * 0.48),  // flashcard
      Offset(w * 0.90, h * 0.40),  // summary doc
    ];
    for (final a in anchors) {
      canvas.drawLine(Offset(cx, cy), a, paint);
      // Small dot at card end
      canvas.drawCircle(a, w * 0.010,
          Paint()
            ..color = AppColors.tertiary.withValues(alpha: 0.45)
            ..style = PaintingStyle.fill);
    }
  }

  // ── Chat bubble ───────────────────────────────────────────────────────────

  void _drawChatBubble(Canvas canvas, double w, double h,
      {required bool isUser}) {
    final bw = w * 0.22;
    final bh = h * 0.14;
    final color = isUser
        ? AppColors.secondary.withValues(alpha: 0.22)
        : AppColors.tertiary.withValues(alpha: 0.18);
    final border = isUser
        ? AppColors.secondaryLight.withValues(alpha: 0.35)
        : AppColors.tertiaryLight.withValues(alpha: 0.35);

    _glassRect(canvas, bw, bh, 10, color, border);

    // Text lines
    final lp = Paint()
      ..color = Colors.white.withValues(alpha: isUser ? 0.55 : 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = bh * 0.10
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 2; i++) {
      final ly = -bh * 0.10 + i * bh * 0.28;
      final lx2 = i == 1 ? bw * 0.20 : bw * 0.38;
      canvas.drawLine(Offset(-bw * 0.38, ly), Offset(lx2, ly), lp);
    }

    // Tail triangle at bottom
    final tailColor = isUser
        ? AppColors.secondaryLight.withValues(alpha: 0.30)
        : AppColors.tertiaryLight.withValues(alpha: 0.28);
    final tail = Path()
      ..moveTo(-bw * 0.15, bh / 2)
      ..lineTo(bw * 0.05, bh / 2)
      ..lineTo(-bw * 0.05, bh / 2 + bh * 0.22)
      ..close();
    canvas.drawPath(tail, Paint()..color = tailColor..style = PaintingStyle.fill);
  }

  // ── Document card ─────────────────────────────────────────────────────────

  void _drawDocCard(Canvas canvas, double w, double h, {required Color color}) {
    final cw = w * 0.18;
    final ch = h * 0.22;
    final fold = cw * 0.22;
    final cr = cw * 0.08;
    final fill = color.withValues(alpha: 0.18);
    final border = color.withValues(alpha: 0.38);

    final path = Path()
      ..moveTo(-cw / 2 + cr, -ch / 2)
      ..lineTo(cw / 2 - fold, -ch / 2)
      ..lineTo(cw / 2, -ch / 2 + fold)
      ..lineTo(cw / 2, ch / 2 - cr)
      ..quadraticBezierTo(cw / 2, ch / 2, cw / 2 - cr, ch / 2)
      ..lineTo(-cw / 2 + cr, ch / 2)
      ..quadraticBezierTo(-cw / 2, ch / 2, -cw / 2, ch / 2 - cr)
      ..lineTo(-cw / 2, -ch / 2 + cr)
      ..quadraticBezierTo(-cw / 2, -ch / 2, -cw / 2 + cr, -ch / 2)
      ..close();
    canvas.drawPath(path, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawPath(path,
        Paint()..color = border..style = PaintingStyle.stroke..strokeWidth = 0.9);

    final foldPath = Path()
      ..moveTo(cw / 2 - fold, -ch / 2)
      ..lineTo(cw / 2, -ch / 2 + fold)
      ..lineTo(cw / 2 - fold, -ch / 2 + fold)
      ..close();
    canvas.drawPath(foldPath,
        Paint()..color = border..style = PaintingStyle.stroke..strokeWidth = 0.8);

    final lp = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ch * 0.032
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final ly = -ch * 0.12 + i * ch * 0.175;
      final lx2 = i == 3 ? cw * 0.18 : cw * 0.36;
      canvas.drawLine(Offset(-cw * 0.36, ly), Offset(lx2, ly), lp);
    }
  }

  // ── Quiz card ─────────────────────────────────────────────────────────────

  void _drawQuizCard(Canvas canvas, double w, double h) {
    final cw = w * 0.20;
    final ch = h * 0.20;
    _glassRect(canvas, cw, ch, 10,
        AppColors.tertiary.withValues(alpha: 0.16),
        AppColors.tertiaryLight.withValues(alpha: 0.32));

    // "Q?" label
    final tp = TextPainter(
      text: TextSpan(
        text: 'Q?',
        style: TextStyle(
          color: AppColors.tertiary.withValues(alpha: 0.90),
          fontSize: cw * 0.40,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(-tp.width / 2, -ch * 0.30));

    // Option dots
    final dp = Paint()..color = Colors.white.withValues(alpha: 0.40)..style = PaintingStyle.fill;
    final ap = Paint()..color = AppColors.tertiary..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      final ox = i < 2 ? -cw * 0.18 : cw * 0.08;
      final oy = ch * 0.08 + (i % 2) * ch * 0.18;
      canvas.drawCircle(Offset(ox, oy), cw * 0.055, i == 1 ? ap : dp);
    }
  }

  // ── Flashcard ─────────────────────────────────────────────────────────────

  void _drawFlashcard(Canvas canvas, double w, double h) {
    final cw = w * 0.18;
    final ch = h * 0.13;
    _glassRect(canvas, cw, ch, 8,
        AppColors.secondary.withValues(alpha: 0.20),
        AppColors.secondaryLight.withValues(alpha: 0.32));

    final starPaint = Paint()
      ..color = AppColors.tertiary.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    _star(canvas, Offset(-cw * 0.20, 0), cw * 0.12, starPaint);

    final lp = Paint()
      ..color = Colors.white.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = ch * 0.09
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(cw * 0.02, -ch * 0.15),
        Offset(cw * 0.38, -ch * 0.15), lp);
    canvas.drawLine(
        Offset(cw * 0.02, ch * 0.10), Offset(cw * 0.28, ch * 0.10), lp);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _glassRect(Canvas canvas, double cw, double ch, double cr,
      Color fill, Color border) {
    final rr = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: cw, height: ch),
        Radius.circular(cr));
    canvas.drawRRect(rr, Paint()..color = fill..style = PaintingStyle.fill);
    canvas.drawRRect(rr,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft, end: Alignment.center,
            colors: [
              Colors.white.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.0)
            ],
          ).createShader(
              Rect.fromCenter(center: Offset.zero, width: cw, height: ch)));
    canvas.drawRRect(rr,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9);
  }

  void _glow(Canvas canvas, Offset c, double r, Color color) =>
      canvas.drawCircle(c, r,
          Paint()
            ..shader = RadialGradient(
                colors: [color, color.withValues(alpha: 0.0)])
                .createShader(Rect.fromCircle(center: c, radius: r)));

  void _sparkle(Canvas canvas, Offset c, double r, Color color) {
    const arms = 4;
    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final a = (i * math.pi / arms) - math.pi / 2;
      final rad = i.isEven ? r : r * 0.32;
      final x = c.dx + rad * math.cos(a);
      final y = c.dy + rad * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    canvas.drawCircle(c, r * 1.6,
        Paint()
          ..color = color.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    const arms = 4;
    final path = Path();
    for (int i = 0; i < arms * 2; i++) {
      final a = (i * math.pi / arms) - math.pi / 2;
      final rad = i.isEven ? r : r * 0.38;
      final x = c.dx + rad * math.cos(a);
      final y = c.dy + rad * math.sin(a);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_AIWorkspacePainter old) =>
      old.floatT != floatT || old.orbitT != orbitT ||
      old.pulseT != pulseT || old.sparkT != sparkT;
}

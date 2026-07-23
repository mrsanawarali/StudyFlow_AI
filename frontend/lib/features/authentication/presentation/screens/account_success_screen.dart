// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';
import 'package:untitled/features/splash/presentation/widgets/particle_layer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Account Created Success Screen — premium redesign.
// Business logic, routing and all state are UNCHANGED.
// Only the visual / animation layer is replaced.
// ─────────────────────────────────────────────────────────────────────────────

/// Phase 2B — Account Created Success Screen (premium redesign).
///
/// Shown after email verification. Celebrates the new account
/// and routes the user to the login screen.
class AccountSuccessScreen extends StatefulWidget {
  const AccountSuccessScreen({super.key});

  @override
  State<AccountSuccessScreen> createState() =>
      _AccountSuccessScreenState();
}

class _AccountSuccessScreenState extends State<AccountSuccessScreen>
    with TickerProviderStateMixin {
  // ── Entrance stagger ──────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _logoFade,  _logoScale,  _logoSlide;
  late final Animation<double> _headFade,  _headSlide;
  late final Animation<double> _heroFade,  _heroScale;
  late final Animation<double> _cardFade,  _cardSlide,  _cardScale;
  late final Animation<double> _footFade,  _footSlide;

  // ── Sequential feature items (6 items, staggered) ─────────────────────────
  late final List<Animation<double>> _featureFades;
  late final List<Animation<double>> _featureSlides;

  // ── Background ────────────────────────────────────────────────────────────
  late final AnimationController _particleCtrl;
  late final AnimationController _orbCtrl;

  // ── Logo glow ─────────────────────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Logo float ────────────────────────────────────────────────────────────
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // ── Success check ring ────────────────────────────────────────────────────
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;   // arc sweep 0 → 1
  late final Animation<double> _checkAnim;  // check scale in

  // ── Success glow pulse ────────────────────────────────────────────────────
  late final AnimationController _successGlowCtrl;
  late final Animation<double> _successGlowAnim;

  // ── Celebration sparkles rotation ─────────────────────────────────────────
  late final AnimationController _sparkleCtrl;

  // ── Floating celebration particles ────────────────────────────────────────
  late final AnimationController _confettiCtrl;

  static const _kFeatureCount = 6;

  @override
  void initState() {
    super.initState();

    // ── Entrance (1 600 ms total) ──────────────────────────────────────────
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600));

    _logoFade  = _iv(0.00, 0.25);
    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.38, curve: Curves.elasticOut)));
    _logoSlide = Tween<double>(begin: -18.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.30, curve: Curves.easeOut)));

    _headFade  = _iv(0.16, 0.42);
    _headSlide = Tween<double>(begin: 14.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.16, 0.42, curve: Curves.easeOut)));

    _heroFade  = _iv(0.26, 0.54);
    _heroScale = Tween<double>(begin: 0.60, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.26, 0.60, curve: Curves.elasticOut)));

    _cardFade  = _iv(0.46, 0.74);
    _cardSlide = Tween<double>(begin: 26.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.46, 0.74, curve: Curves.easeOut)));
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.46, 0.76, curve: Curves.easeOut)));

    _footFade  = _iv(0.72, 1.00);
    _footSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.72, 1.00, curve: Curves.easeOut)));

    // Feature items: stagger each 0.06 apart starting at 0.52
    _featureFades  = List.generate(_kFeatureCount, (i) {
      final s = 0.52 + i * 0.055;
      final e = (s + 0.12).clamp(0.0, 1.0);
      return _iv(s, e);
    });
    _featureSlides = List.generate(_kFeatureCount, (i) {
      final s = 0.52 + i * 0.055;
      final e = (s + 0.12).clamp(0.0, 1.0);
      return Tween<double>(begin: 14.0, end: 0.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));
    });

    // ── Background ────────────────────────────────────────────────────────
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat();

    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 9000))
      ..repeat(reverse: true);

    // ── Logo glow (2.4 s) ─────────────────────────────────────────────────
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Logo float (3 s) ──────────────────────────────────────────────────
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // ── Success ring draw (900 ms, starts with hero) ───────────────────────
    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _ringAnim = CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut);
    _checkAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ringCtrl,
            curve: const Interval(0.45, 1.0, curve: Curves.elasticOut)));

    // ── Success glow pulse (2 s loop) ─────────────────────────────────────
    _successGlowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _successGlowAnim = Tween<double>(begin: 0.30, end: 0.65).animate(
        CurvedAnimation(parent: _successGlowCtrl, curve: Curves.easeInOut));

    // ── Sparkle ring rotation (5 s) ───────────────────────────────────────
    _sparkleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 5000))
      ..repeat();

    // ── Confetti (6 s loop) ───────────────────────────────────────────────
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _enterCtrl.forward();
        // Ring starts drawing when hero fades in
        Future.delayed(const Duration(milliseconds: 420), () {
          if (mounted) _ringCtrl.forward();
        });
      }
    });
  }

  Animation<double> _iv(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  @override
  void dispose() {
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    _orbCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _ringCtrl.dispose();
    _successGlowCtrl.dispose();
    _sparkleCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0A0F2C), Color(0xFF1A0A3C)],
                ),
              ),
            ),
          ),

          // Ambient orbs
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _orbCtrl,
                builder: (_, __) =>
                    _AsAmbientOrbs(progress: _orbCtrl.value),
              ),
            ),
          ),

          // Particles
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleLayer(controller: _particleCtrl),
            ),
          ),

          // Celebration confetti overlay (above particles)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _ConfettiPainter(
                      progress: _confettiCtrl.value),
                ),
              ),
            ),
          ),

          // Scrollable content
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _enterCtrl, _floatCtrl, _glowCtrl,
                _ringCtrl, _successGlowCtrl, _sparkleCtrl,
              ]),
              builder: (context, _) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    _buildLogo(),
                    const SizedBox(height: AppSpacing.md),
                    _buildHeading(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSuccessHero(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildFeatureCard(),
                    const SizedBox(height: AppSpacing.lg),
                    // Footer: welcome message + CTA
                    Opacity(
                      opacity: _footFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _footSlide.value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildWelcomeMessage(),
                            const SizedBox(height: AppSpacing.lg),
                            _AsGradientButton(
                              onPressed: () =>
                                  context.go(RoutePaths.login),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: Text(
                                'Transform Your Study Journey',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onPrimary
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Opacity(
      opacity: _logoFade.value,
      child: Transform.translate(
        offset: Offset(0, _logoSlide.value + _floatAnim.value),
        child: Transform.scale(
          scale: _logoScale.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary.withValues(
                          alpha: _glowAnim.value * 0.50),
                      AppColors.tertiary.withValues(
                          alpha: _glowAnim.value * 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Container(
                width: 86, height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(
                          alpha: _glowAnim.value * 0.42),
                      blurRadius: 28, spreadRadius: 4),
                    BoxShadow(
                      color: AppColors.tertiary.withValues(
                          alpha: _glowAnim.value * 0.18),
                      blurRadius: 42, spreadRadius: 6),
                  ],
                ),
              ),
              const SizedBox(
                width: 74, height: 74,
                child: FittedBox(
                    fit: BoxFit.contain, child: AppLogoWidget()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Heading ───────────────────────────────────────────────────────────────

  Widget _buildHeading() {
    return Opacity(
      opacity: _headFade.value,
      child: Transform.translate(
        offset: Offset(0, _headSlide.value),
        child: Column(
          children: [
            Text(
              'Welcome to StudyFlow AI',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Your academic journey starts today.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Success hero ──────────────────────────────────────────────────────────

  Widget _buildSuccessHero() {
    return Opacity(
      opacity: _heroFade.value,
      child: Transform.scale(
        scale: _heroScale.value,
        child: SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Far outer ambient glow
              Container(
                width: 180, height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.success.withValues(
                          alpha: _successGlowAnim.value * 0.18),
                      AppColors.tertiary.withValues(
                          alpha: _successGlowAnim.value * 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),

              // Rotating sparkle ring
              Transform.rotate(
                angle: _sparkleCtrl.value * 2 * math.pi,
                child: SizedBox(
                  width: 160, height: 160,
                  child: CustomPaint(
                    painter: _SuccessSparkleRing(
                        progress: _sparkleCtrl.value,
                        glowAlpha: _successGlowAnim.value),
                  ),
                ),
              ),

              // Animated arc ring
              SizedBox(
                width: 140, height: 140,
                child: CustomPaint(
                  painter: _SuccessRingPainter(
                    sweep: _ringAnim.value,
                    glowAlpha: _successGlowAnim.value,
                  ),
                ),
              ),

              // Inner filled circle
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success.withValues(alpha: 0.90),
                      AppColors.tertiary.withValues(alpha: 0.80),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(
                          alpha: _successGlowAnim.value * 0.55),
                      blurRadius: 28, spreadRadius: 4),
                    BoxShadow(
                      color: AppColors.tertiary.withValues(
                          alpha: _successGlowAnim.value * 0.30),
                      blurRadius: 40, spreadRadius: 6),
                  ],
                ),
              ),

              // Check mark scales in after ring draws
              Transform.scale(
                scale: _checkAnim.value,
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Feature card ──────────────────────────────────────────────────────────

  static const _features = [
    (Icons.psychology_outlined,      'AI Study Assistant',    AppColors.secondary),
    (Icons.calendar_month_outlined,  'Smart Timetable',       AppColors.tertiary),
    (Icons.notes_outlined,           'Notes Management',      AppColors.secondaryLight),
    (Icons.assignment_outlined,      'Assignment Tracker',    AppColors.tertiary),
    (Icons.calculate_outlined,       'GPA Calculator',        AppColors.secondary),
    (Icons.offline_bolt_outlined,    'Offline Ready',         AppColors.tertiaryLight),
  ];

  Widget _buildFeatureCard() {
    return Opacity(
      opacity: _cardFade.value,
      child: Transform.translate(
        offset: Offset(0, _cardSlide.value),
        child: Transform.scale(
          scale: _cardScale.value,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.13),
                      width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.10),
                      blurRadius: 30, spreadRadius: 2),
                  ],
                ),
                child: Column(
                  children: List.generate(_kFeatureCount, (i) {
                    final f = _features[i];
                    return Opacity(
                      opacity: _featureFades[i].value,
                      child: Transform.translate(
                        offset: Offset(0, _featureSlides[i].value),
                        child: Column(
                          children: [
                            _AsFeatureRow(
                              icon: f.$1,
                              label: f.$2,
                              color: f.$3,
                            ),
                            if (i < _kFeatureCount - 1)
                              Divider(
                                height: AppSpacing.md * 2,
                                color: Colors.white.withValues(alpha: 0.07),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Welcome message ───────────────────────────────────────────────────────

  Widget _buildWelcomeMessage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.09), width: 1.0),
          ),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.secondaryLight, AppColors.tertiary],
                ).createShader(bounds),
                child: Text(
                  'Welcome aboard!',
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Everything is ready to help you organize your academic life more efficiently.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.55),
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient orbs
// ─────────────────────────────────────────────────────────────────────────────

class _AsAmbientOrbs extends StatelessWidget {
  const _AsAmbientOrbs({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = Curves.easeInOut.transform(progress);
    return CustomPaint(size: size, painter: _AsOrbPainter(t: t));
  }
}

class _AsOrbPainter extends CustomPainter {
  const _AsOrbPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — success green tint, top-centre
    final o1x = size.width * (0.50 + 0.06 * t);
    final o1y = size.height * (0.08 + 0.03 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.success.withOpacity(0.12),
      AppColors.success.withOpacity(0.0),
    ]).createShader(Rect.fromCircle(
        center: Offset(o1x, o1y), radius: size.width * 0.40));
    canvas.drawCircle(Offset(o1x, o1y), size.width * 0.40, paint);

    // Orb 2 — teal, bottom-right
    final o2x = size.width * (0.80 - 0.05 * t);
    final o2y = size.height * (0.68 + 0.04 * (1 - t));
    paint.shader = RadialGradient(colors: [
      AppColors.tertiary.withOpacity(0.11),
      AppColors.tertiary.withOpacity(0.0),
    ]).createShader(Rect.fromCircle(
        center: Offset(o2x, o2y), radius: size.width * 0.32));
    canvas.drawCircle(Offset(o2x, o2y), size.width * 0.32, paint);

    // Orb 3 — secondary, bottom-left
    final o3x = size.width * (0.15 + 0.04 * t);
    final o3y = size.height * (0.75 - 0.03 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.secondaryLight.withOpacity(0.09),
      AppColors.secondaryLight.withOpacity(0.0),
    ]).createShader(Rect.fromCircle(
        center: Offset(o3x, o3y), radius: size.width * 0.28));
    canvas.drawCircle(Offset(o3x, o3y), size.width * 0.28, paint);
  }

  @override
  bool shouldRepaint(_AsOrbPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Celebration confetti painter — small rising coloured dots
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});
  final double progress;

  // Fixed seed data: [x fraction, cycleMs, phaseOffset, colorIdx, radius]
  static final _data = _buildData();
  static List<List<double>> _buildData() {
    final rng = math.Random(77);
    return List.generate(18, (_) => [
      rng.nextDouble(),           // x
      rng.nextDouble(),           // y start
      2500 + rng.nextDouble() * 3000, // cycle ms
      rng.nextDouble(),           // phase offset
      rng.nextInt(4).toDouble(),  // color index
      1.2 + rng.nextDouble() * 2.4, // radius
      rng.nextDouble() * 0.30 + 0.08, // opacity
    ]);
  }

  static const _colors = [
    Color(0xFF50E3C2), // tertiary
    Color(0xFF7AB8FF), // secondaryLight
    Color(0xFF4CAF50), // success green
    Color(0xFFFFB900), // gold sparkle
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final nowMs = DateTime.now().millisecondsSinceEpoch.toDouble();
    final paint = Paint()..style = PaintingStyle.fill;

    for (final d in _data) {
      final phase = ((nowMs / d[2]) + d[3]) % 1.0;
      final drift = 80 + 60 * d[1]; // total upward travel
      final px = d[0] * size.width;
      final py = d[1] * size.height - drift * phase;
      if (py < 0) continue;

      final opacity = d[6] * (1.0 - phase * 0.6);
      paint.color =
          _colors[d[4].toInt()].withOpacity(opacity.clamp(0.0, 1.0));
      paint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, d[5] * 0.6);
      canvas.drawCircle(Offset(px, py), d[5], paint);
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Success ring arc painter
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessRingPainter extends CustomPainter {
  const _SuccessRingPainter(
      {required this.sweep, required this.glowAlpha});
  final double sweep;
  final double glowAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2 - 4;

    // Track ring
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0,
    );

    if (sweep <= 0) return;

    // Glow arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep * 2 * math.pi,
      false,
      Paint()
        ..color = AppColors.success.withOpacity(
            (glowAlpha * 0.55).clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Crisp arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep * 2 * math.pi,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + sweep * 2 * math.pi,
          colors: const [AppColors.success, AppColors.tertiary],
        ).createShader(
            Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SuccessRingPainter old) =>
      old.sweep != sweep || old.glowAlpha != glowAlpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkle ring around the success circle
// ─────────────────────────────────────────────────────────────────────────────

class _SuccessSparkleRing extends CustomPainter {
  const _SuccessSparkleRing(
      {required this.progress, required this.glowAlpha});
  final double progress;
  final double glowAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.47;
    const n  = 10;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < n; i++) {
      final angle =
          (i / n) * 2 * math.pi + progress * 2 * math.pi;
      final dotR = (i % 2 == 0) ? 3.2 : 2.0;
      final rawAlpha =
          (i % 2 == 0 ? 0.60 : 0.35) * (glowAlpha - 0.25);
      final alpha = rawAlpha.clamp(0.0, 1.0);
      if (alpha <= 0) continue;

      final color = i % 3 == 0
          ? AppColors.tertiary.withOpacity(alpha)
          : (i % 3 == 1
              ? AppColors.success.withOpacity(alpha)
              : AppColors.secondaryLight.withOpacity(alpha));
      paint.color = color;
      paint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, dotR * 0.9);
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        dotR, paint);
    }
  }

  @override
  bool shouldRepaint(_SuccessSparkleRing old) =>
      old.progress != progress || old.glowAlpha != glowAlpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// Feature row inside the glass card
// ─────────────────────────────────────────────────────────────────────────────

class _AsFeatureRow extends StatelessWidget {
  const _AsFeatureRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, color: color, size: 17),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.85),
            ),
          ),
        ),
        Icon(
          Icons.check_circle_rounded,
          color: AppColors.tertiary.withValues(alpha: 0.80),
          size: 16,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary CTA button — identical to Login / Signup / Verify Email
// ─────────────────────────────────────────────────────────────────────────────

class _AsGradientButton extends StatefulWidget {
  const _AsGradientButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_AsGradientButton> createState() => _AsGradientButtonState();
}

class _AsGradientButtonState extends State<_AsGradientButton>
    with TickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 160),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.35, end: 0.65).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp:   (_) => _scaleCtrl.forward(),
        onTapCancel: () => _scaleCtrl.forward(),
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleCtrl, _glowAnim]),
          builder: (_, child) =>
              Transform.scale(scale: _scaleCtrl.value, child: child),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.secondary, AppColors.tertiary],
              ),
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary
                      .withValues(alpha: _glowAnim.value),
                  blurRadius: _hovered ? 28 : 18,
                  spreadRadius: _hovered ? 3 : 1,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.tertiary
                      .withValues(alpha: _glowAnim.value * 0.35),
                  blurRadius: 36,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPressed,
                borderRadius: BorderRadius.circular(27),
                splashColor: Colors.white.withValues(alpha: 0.22),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Exploring',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: AppColors.onPrimary, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

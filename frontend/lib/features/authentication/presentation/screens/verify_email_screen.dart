// ignore_for_file: deprecated_member_use
import 'dart:async';
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
// Verify Email Screen — premium redesign matching Login / Signup design system.
// Business logic, state, routing and _onContinue are ALL unchanged.
// Only the visual / animation layer is replaced.
// ─────────────────────────────────────────────────────────────────────────────

/// Phase 2B — Verify Email Screen (premium redesign).
///
/// Shown after sign-up. Prompts the user to check their inbox.
/// The "I've Verified" button simulates success and navigates to
/// [RoutePaths.accountSuccess].
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with TickerProviderStateMixin {
  // ── Business-logic state (unchanged) ──────────────────────────────────────
  bool _isChecking = false;

  // ── Resend countdown ──────────────────────────────────────────────────────
  int _resendSeconds = 30;
  Timer? _countdownTimer;

  // ── Entrance stagger ──────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _logoFade,  _logoScale,  _logoSlide;
  late final Animation<double> _headFade,  _headSlide;
  late final Animation<double> _heroFade,  _heroScale;
  late final Animation<double> _cardFade,  _cardSlide,  _cardScale;
  late final Animation<double> _btnFade,   _btnSlide;

  // ── Background ────────────────────────────────────────────────────────────
  late final AnimationController _particleCtrl;
  late final AnimationController _orbCtrl;

  // ── Logo glow pulse ───────────────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Logo float ────────────────────────────────────────────────────────────
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // ── Envelope pulse ────────────────────────────────────────────────────────
  late final AnimationController _envPulseCtrl;
  late final Animation<double> _envPulseAnim;

  // ── Envelope float ────────────────────────────────────────────────────────
  late final AnimationController _envFloatCtrl;
  late final Animation<double> _envFloatAnim;

  // ── Badge bounce ─────────────────────────────────────────────────────────
  late final AnimationController _badgeCtrl;
  late final Animation<double> _badgeAnim;

  // ── Sparkle rotation ─────────────────────────────────────────────────────
  late final AnimationController _sparkleCtrl;

  @override
  void initState() {
    super.initState();

    // ── Entrance (1 500 ms stagger) ────────────────────────────────────────
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500));

    _logoFade  = _iv(0.00, 0.28);
    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.40, curve: Curves.elasticOut)));
    _logoSlide = Tween<double>(begin: -20.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.32, curve: Curves.easeOut)));

    _headFade  = _iv(0.18, 0.45);
    _headSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.18, 0.45, curve: Curves.easeOut)));

    _heroFade  = _iv(0.30, 0.58);
    _heroScale = Tween<double>(begin: 0.78, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.30, 0.62, curve: Curves.elasticOut)));

    _cardFade  = _iv(0.48, 0.76);
    _cardSlide = Tween<double>(begin: 28.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.48, 0.76, curve: Curves.easeOut)));
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.48, 0.78, curve: Curves.easeOut)));

    _btnFade  = _iv(0.68, 1.00);
    _btnSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.68, 1.00, curve: Curves.easeOut)));

    // ── Background loops ───────────────────────────────────────────────────
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

    // ── Envelope pulse (1.8 s) ────────────────────────────────────────────
    _envPulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _envPulseAnim = Tween<double>(begin: 0.90, end: 1.08).animate(
        CurvedAnimation(parent: _envPulseCtrl, curve: Curves.easeInOut));

    // ── Envelope float (2.6 s, offset from logo float) ───────────────────
    _envFloatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2600))
      ..repeat(reverse: true);
    _envFloatAnim = Tween<double>(begin: -5.0, end: 7.0).animate(
        CurvedAnimation(parent: _envFloatCtrl, curve: Curves.easeInOut));

    // ── Badge bounce (2.2 s) ─────────────────────────────────────────────
    _badgeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);
    _badgeAnim = Tween<double>(begin: -4.0, end: 6.0).animate(
        CurvedAnimation(parent: _badgeCtrl, curve: Curves.easeInOut));

    // ── Sparkle rotation (4 s) ────────────────────────────────────────────
    _sparkleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000))
      ..repeat();

    // Start countdown timer
    _startCountdown();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  Animation<double> _iv(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendSeconds = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        if (_resendSeconds > 0) {
          _resendSeconds--;
        } else {
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    _orbCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _envPulseCtrl.dispose();
    _envFloatCtrl.dispose();
    _badgeCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  // ── Business logic (unchanged) ────────────────────────────────────────────
  Future<void> _onContinue() async {
    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isChecking = false);
    context.go(RoutePaths.accountSuccess);
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
                    _VeAmbientOrbs(progress: _orbCtrl.value),
              ),
            ),
          ),

          // Particles
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleLayer(controller: _particleCtrl),
            ),
          ),

          // Content
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _enterCtrl, _floatCtrl, _glowCtrl,
                _envPulseCtrl, _envFloatCtrl, _badgeCtrl, _sparkleCtrl,
              ]),
              builder: (context, _) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button
                    Opacity(
                      opacity: _logoFade.value,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _VeBackButton(
                            onTap: () => context.go(RoutePaths.login)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Logo
                    _buildLogo(),
                    const SizedBox(height: AppSpacing.md),

                    // Heading
                    _buildHeading(),
                    const SizedBox(height: AppSpacing.xl),

                    // Email illustration hero
                    _buildHero(),
                    const SizedBox(height: AppSpacing.xl),

                    // Glass info card
                    _buildCard(),
                    const SizedBox(height: AppSpacing.lg),

                    // Buttons + footer
                    Opacity(
                      opacity: _btnFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _btnSlide.value),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _VePrimaryButton(
                              isLoading: _isChecking,
                              onPressed: _onContinue,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _VeResendButton(
                              seconds: _resendSeconds,
                              onResend: () => _startCountdown(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _buildFooter(),
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary
                          .withValues(alpha: _glowAnim.value * 0.50),
                      AppColors.tertiary
                          .withValues(alpha: _glowAnim.value * 0.16),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary
                          .withValues(alpha: _glowAnim.value * 0.42),
                      blurRadius: 30, spreadRadius: 4),
                    BoxShadow(
                      color: AppColors.tertiary
                          .withValues(alpha: _glowAnim.value * 0.18),
                      blurRadius: 44, spreadRadius: 6),
                  ],
                ),
              ),
              const SizedBox(
                width: 76, height: 76,
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
              'Verify Your Email',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "We've sent a verification link to your email address.",
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

  // ── Email illustration hero ───────────────────────────────────────────────

  Widget _buildHero() {
    return Opacity(
      opacity: _heroFade.value,
      child: Transform.scale(
        scale: _heroScale.value,
        child: SizedBox(
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ambient glow ring
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary
                          .withValues(alpha: _envPulseAnim.value * 0.22 - 0.18),
                      AppColors.tertiary
                          .withValues(alpha: _envPulseAnim.value * 0.12 - 0.10),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),

              // Rotating sparkle ring
              Transform.rotate(
                angle: _sparkleCtrl.value * 2 * math.pi,
                child: SizedBox(
                  width: 148,
                  height: 148,
                  child: CustomPaint(
                    painter: _SparkleRingPainter(
                        progress: _sparkleCtrl.value,
                        glowAlpha: _envPulseAnim.value),
                  ),
                ),
              ),

              // Floating envelope
              Transform.translate(
                offset: Offset(0, _envFloatAnim.value),
                child: Transform.scale(
                  scale: _envPulseAnim.value,
                  child: Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.22),
                          AppColors.tertiary.withValues(alpha: 0.14),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withValues(
                              alpha: _envPulseAnim.value * 0.40),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: AppColors.tertiary.withValues(
                              alpha: _envPulseAnim.value * 0.20),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Center(
                          child: CustomPaint(
                            size: const Size(58, 44),
                            painter: _EnvelopePainter(
                              glowAlpha: _envPulseAnim.value),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating verification badge (top-right of envelope)
              Positioned(
                top: 12,
                right: 30,
                child: Transform.translate(
                  offset: Offset(0, _badgeAnim.value),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.tertiary, AppColors.secondary],
                      ),
                      border: Border.all(
                          color: const Color(0xFF0A0F2C), width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiary.withValues(alpha: 0.55),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF0A0F2C),
                      size: 16,
                    ),
                  ),
                ),
              ),

              // Small floating checkmarks
              Positioned(
                bottom: 18,
                left: 28,
                child: Transform.translate(
                  offset: Offset(0, -_badgeAnim.value * 0.6),
                  child: _MiniCheckmark(
                      alpha: _envPulseAnim.value * 0.7),
                ),
              ),
              Positioned(
                top: 22,
                left: 20,
                child: Transform.translate(
                  offset: Offset(_badgeAnim.value * 0.4, 0),
                  child: _MiniCheckmark(
                      size: 16, alpha: _envPulseAnim.value * 0.5),
                ),
              ),
              Positioned(
                bottom: 24,
                right: 22,
                child: Transform.translate(
                  offset: Offset(0, _badgeAnim.value * 0.5),
                  child: _MiniCheckmark(
                      size: 14, alpha: _envPulseAnim.value * 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Glass info card ───────────────────────────────────────────────────────

  Widget _buildCard() {
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sent-to row
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondary
                                .withValues(alpha: 0.15),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: AppColors.secondaryLight,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Verification sent to',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.onPrimary
                                      .withValues(alpha: 0.50),
                                ),
                              ),
                              Text(
                                'your email address',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.secondaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Divider(
                        color: Colors.white.withValues(alpha: 0.10),
                        height: 1),
                    const SizedBox(height: AppSpacing.md),

                    // Steps
                    _VeStepRow(
                      icon: Icons.inbox_outlined,
                      label: 'Open your email inbox',
                      color: AppColors.secondaryLight,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _VeStepRow(
                      icon: Icons.touch_app_outlined,
                      label: 'Tap the verification link',
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _VeStepRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: 'Return here to continue',
                      color: AppColors.secondaryLight,
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Divider(
                        color: Colors.white.withValues(alpha: 0.10),
                        height: 1),
                    const SizedBox(height: AppSpacing.sm),

                    // Security note
                    Row(
                      children: [
                        Icon(Icons.shield_outlined,
                            color: AppColors.tertiary.withValues(alpha: 0.75),
                            size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'The link expires in 24 hours for your security.',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.onPrimary
                                  .withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Footer help section ───────────────────────────────────────────────────

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          "Didn't receive the email?",
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.45),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _FooterTip(icon: Icons.folder_outlined,
            text: 'Check your Spam or Junk folder'),
        const SizedBox(height: 4),
        _FooterTip(icon: Icons.alternate_email_rounded,
            text: 'Make sure your email address is correct'),
        const SizedBox(height: 4),
        _FooterTip(icon: Icons.timer_outlined,
            text: 'Try resending after the countdown'),
        const SizedBox(height: AppSpacing.sm),
        _VeAnimatedLink(
          text: 'Back to Sign In',
          onTap: () => context.go(RoutePaths.login),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient orbs — same pattern as Login / Signup
// ─────────────────────────────────────────────────────────────────────────────

class _VeAmbientOrbs extends StatelessWidget {
  const _VeAmbientOrbs({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = Curves.easeInOut.transform(progress);
    return CustomPaint(size: size, painter: _VeOrbPainter(t: t));
  }
}

class _VeOrbPainter extends CustomPainter {
  const _VeOrbPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — blue, top-right
    final o1x = size.width * (0.70 + 0.07 * t);
    final o1y = size.height * (0.07 + 0.04 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.secondary.withOpacity(0.17),
      AppColors.secondary.withOpacity(0.0),
    ]).createShader(Rect.fromCircle(
        center: Offset(o1x, o1y), radius: size.width * 0.36));
    canvas.drawCircle(Offset(o1x, o1y), size.width * 0.36, paint);

    // Orb 2 — teal, bottom-left
    final o2x = size.width * (0.18 - 0.05 * t);
    final o2y = size.height * (0.72 + 0.04 * (1 - t));
    paint.shader = RadialGradient(colors: [
      AppColors.tertiary.withOpacity(0.13),
      AppColors.tertiary.withOpacity(0.0),
    ]).createShader(Rect.fromCircle(
        center: Offset(o2x, o2y), radius: size.width * 0.30));
    canvas.drawCircle(Offset(o2x, o2y), size.width * 0.30, paint);

    // Orb 3 — secondary light, mid-right
    final o3x = size.width * (0.82 + 0.04 * (1 - t));
    final o3y = size.height * (0.45 - 0.03 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.secondaryLight.withOpacity(0.09),
      AppColors.secondaryLight.withOpacity(0.0),
    ]).createShader(Rect.fromCircle(
        center: Offset(o3x, o3y), radius: size.width * 0.25));
    canvas.drawCircle(Offset(o3x, o3y), size.width * 0.25, paint);
  }

  @override
  bool shouldRepaint(_VeOrbPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sparkle ring painter — subtle rotating dots around the envelope
// ─────────────────────────────────────────────────────────────────────────────

class _SparkleRingPainter extends CustomPainter {
  const _SparkleRingPainter(
      {required this.progress, required this.glowAlpha});
  final double progress;
  final double glowAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.46;
    const dotCount = 8;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi +
          progress * 2 * math.pi;
      // Alternate dot sizes for a sparkle feel
      final dotR = (i % 2 == 0) ? 2.8 : 1.8;
      final alpha = (i % 2 == 0 ? 0.55 : 0.30) * (glowAlpha - 0.85);
      if (alpha <= 0) continue;
      final color = i % 3 == 0
          ? AppColors.tertiary.withOpacity(alpha.clamp(0.0, 1.0))
          : AppColors.secondaryLight.withOpacity(alpha.clamp(0.0, 1.0));
      paint.color = color;
      paint.maskFilter =
          MaskFilter.blur(BlurStyle.normal, dotR * 0.8);
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        dotR,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparkleRingPainter old) =>
      old.progress != progress || old.glowAlpha != glowAlpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// Envelope custom painter — crisp vector envelope with glow
// ─────────────────────────────────────────────────────────────────────────────

class _EnvelopePainter extends CustomPainter {
  const _EnvelopePainter({required this.glowAlpha});
  final double glowAlpha;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Glow shadow
    final glowPaint = Paint()
      ..color = AppColors.secondary.withOpacity(
          ((glowAlpha - 0.88) * 1.5).clamp(0.0, 0.45))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Envelope body
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.secondary.withOpacity(0.90),
          AppColors.secondaryLight.withOpacity(0.70),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final bodyPath = Path()
      ..moveTo(0, h * 0.20)
      ..lineTo(0, h)
      ..lineTo(w, h)
      ..lineTo(w, h * 0.20)
      ..close();

    // Draw glow first
    canvas.drawPath(bodyPath, glowPaint);
    canvas.drawPath(bodyPath, bodyPaint);

    // Envelope flap (top-pointing V)
    final flapPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondaryLight.withOpacity(0.95),
          AppColors.secondary.withOpacity(0.75),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 0.55))
      ..style = PaintingStyle.fill;

    final flapPath = Path()
      ..moveTo(0, h * 0.20)
      ..lineTo(w / 2, h * 0.56)
      ..lineTo(w, h * 0.20)
      ..close();
    canvas.drawPath(flapPath, flapPaint);

    // Diagonal fold lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // Bottom-left diagonal
    canvas.drawLine(Offset(0, h), Offset(w * 0.44, h * 0.60), linePaint);
    // Bottom-right diagonal
    canvas.drawLine(Offset(w, h), Offset(w * 0.56, h * 0.60), linePaint);

    // White highlight shimmer on flap
    final shimmerPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.15, h * 0.28),
        Offset(w * 0.50, h * 0.50),
        shimmerPaint);
  }

  @override
  bool shouldRepaint(_EnvelopePainter old) =>
      old.glowAlpha != glowAlpha;
}

// ─────────────────────────────────────────────────────────────────────────────
// Mini floating checkmark
// ─────────────────────────────────────────────────────────────────────────────

class _MiniCheckmark extends StatelessWidget {
  const _MiniCheckmark({this.size = 20, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    final a = alpha.clamp(0.0, 1.0);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.tertiary.withValues(alpha: a * 0.90),
            AppColors.secondary.withValues(alpha: a * 0.70),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.tertiary.withValues(alpha: a * 0.50),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        Icons.check_rounded,
        color: Colors.white.withValues(alpha: a),
        size: size * 0.55,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step row inside the glass card
// ─────────────────────────────────────────────────────────────────────────────

class _VeStepRow extends StatelessWidget {
  const _VeStepRow({
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
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.12),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.80),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Footer tip row
// ─────────────────────────────────────────────────────────────────────────────

class _FooterTip extends StatelessWidget {
  const _FooterTip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              size: 13,
              color: AppColors.onPrimary.withValues(alpha: 0.35)),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.40),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated back button (glass circle, same as Signup)
// ─────────────────────────────────────────────────────────────────────────────

class _VeBackButton extends StatefulWidget {
  const _VeBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_VeBackButton> createState() => _VeBackButtonState();
}

class _VeBackButtonState extends State<_VeBackButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: _hovered ? 0.12 : 0.07),
            border: Border.all(
              color: Colors.white.withValues(
                  alpha: _hovered ? 0.22 : 0.13),
              width: 1.0,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.18),
                      blurRadius: 12)
                  ]
                : [],
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.onPrimary,
            size: 18,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Primary CTA button — identical to Login / Signup premium style
// ─────────────────────────────────────────────────────────────────────────────

class _VePrimaryButton extends StatefulWidget {
  const _VePrimaryButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_VePrimaryButton> createState() => _VePrimaryButtonState();
}

class _VePrimaryButtonState extends State<_VePrimaryButton>
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
    final enabled = widget.onPressed != null && !widget.isLoading;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) { if (enabled) _scaleCtrl.reverse(); },
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
              gradient: enabled
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.secondary, AppColors.tertiary])
                  : null,
              color: enabled ? null : Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(27),
              boxShadow: enabled
                  ? [
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
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? widget.onPressed : null,
                borderRadius: BorderRadius.circular(27),
                splashColor: Colors.white.withValues(alpha: 0.22),
                highlightColor: Colors.white.withValues(alpha: 0.08),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: widget.isLoading
                        ? const SizedBox(
                            key: ValueKey('loader'),
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.onPrimary),
                            ),
                          )
                        : Row(
                            key: const ValueKey('label'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "I've Verified My Email",
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Resend email button — animated countdown, glass style, smooth re-enable
// ─────────────────────────────────────────────────────────────────────────────

class _VeResendButton extends StatefulWidget {
  const _VeResendButton({
    required this.seconds,
    required this.onResend,
  });

  final int seconds;
  final VoidCallback onResend;

  @override
  State<_VeResendButton> createState() => _VeResendButtonState();
}

class _VeResendButtonState extends State<_VeResendButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  late final AnimationController _enableCtrl;
  late final Animation<double> _enableAnim;

  @override
  void initState() {
    super.initState();
    _enableCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _enableAnim = CurvedAnimation(
        parent: _enableCtrl, curve: Curves.easeOut);
  }

  @override
  void didUpdateWidget(_VeResendButton old) {
    super.didUpdateWidget(old);
    // Animate in when countdown reaches zero
    if (old.seconds > 0 && widget.seconds == 0) {
      _enableCtrl.forward();
    }
    if (old.seconds == 0 && widget.seconds > 0) {
      _enableCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _enableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.seconds == 0;

    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) { if (enabled) setState(() => _hovered = true); },
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) { if (enabled) setState(() => _pressed = true); },
        onTapUp: (_) {
          setState(() => _pressed = false);
          if (enabled) widget.onResend();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: AnimatedBuilder(
            animation: _enableAnim,
            builder: (_, __) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(27),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(27),
                      color: Colors.white.withValues(
                          alpha: enabled
                              ? (_hovered ? 0.12 : 0.08)
                              : 0.04),
                      border: Border.all(
                        color: enabled
                            ? AppColors.secondary.withValues(
                                alpha: 0.35 + _enableAnim.value * 0.25)
                            : Colors.white.withValues(alpha: 0.10),
                        width: 1.2,
                      ),
                      boxShadow: enabled && _hovered
                          ? [
                              BoxShadow(
                                color: AppColors.secondary
                                    .withValues(alpha: 0.22),
                                blurRadius: 16,
                                spreadRadius: 0,
                              )
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: enabled ? widget.onResend : null,
                        borderRadius: BorderRadius.circular(27),
                        splashColor:
                            Colors.white.withValues(alpha: 0.12),
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: enabled
                                ? Row(
                                    key: const ValueKey('resend'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        color: AppColors.secondaryLight,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Resend Email',
                                        style: AppTypography.labelLarge
                                            .copyWith(
                                          color: AppColors.secondaryLight,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    key: ValueKey(widget.seconds),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: _CountdownRing(
                                            seconds: widget.seconds,
                                            total: 30),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Resend in ${widget.seconds}s',
                                        style: AppTypography.labelLarge
                                            .copyWith(
                                          color: AppColors.onPrimary
                                              .withValues(alpha: 0.40),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular countdown ring indicator
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownRing extends StatelessWidget {
  const _CountdownRing({required this.seconds, required this.total});
  final int seconds;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = seconds / total;
    return CustomPaint(
      painter: _CountdownRingPainter(progress: progress),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  const _CountdownRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = (size.width / 2) - 1.5;

    // Track
    canvas.drawCircle(
      Offset(cx, cy), r,
      Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Arc
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      progress * 2 * math.pi,
      false,
      Paint()
        ..color = AppColors.secondaryLight.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CountdownRingPainter old) =>
      old.progress != progress;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated link — same as Login / Signup
// ─────────────────────────────────────────────────────────────────────────────

class _VeAnimatedLink extends StatefulWidget {
  const _VeAnimatedLink({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  State<_VeAnimatedLink> createState() => _VeAnimatedLinkState();
}

class _VeAnimatedLinkState extends State<_VeAnimatedLink>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _ctrl.forward(),
      onExit:  (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Text(
              widget.text,
              style: AppTypography.labelSmall.copyWith(
                color: Color.lerp(
                  AppColors.onPrimary.withValues(alpha: 0.45),
                  AppColors.secondaryLight,
                  _anim.value,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
import '../widgets/auth_divider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Login Screen — premium animations & micro-interactions
// Business logic, controllers, routing and auth are ALL unchanged.
// Only the animation/UX layer is enhanced.
// ─────────────────────────────────────────────────────────────────────────────

/// Phase 2B — Premium Login Screen (animation-enhanced).
///
/// UI only. No Firebase calls. All controllers are local state.
/// Navigation uses GoRouter.
class FeatureLoginScreen extends StatefulWidget {
  const FeatureLoginScreen({super.key});

  @override
  State<FeatureLoginScreen> createState() => _FeatureLoginScreenState();
}

class _FeatureLoginScreenState extends State<FeatureLoginScreen>
    with TickerProviderStateMixin {
  // ── Business-logic state (unchanged) ──────────────────────────────────────
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading  = false;
  bool _rememberMe = false;

  // ── Entrance stagger ──────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  // logo
  late final Animation<double> _logoFade, _logoScale, _logoSlide;
  // heading
  late final Animation<double> _headFade, _headSlide;
  // card
  late final Animation<double> _cardFade, _cardSlide, _cardScale;
  // bottom section
  late final Animation<double> _bottomFade, _bottomSlide;

  // ── Particle background ───────────────────────────────────────────────────
  late final AnimationController _particleCtrl;

  // ── Logo ambient glow pulse ───────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Logo float ────────────────────────────────────────────────────────────
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  // ── Ambient orb drift ─────────────────────────────────────────────────────
  late final AnimationController _orbCtrl;

  @override
  void initState() {
    super.initState();

    // ── Entrance (1 400 ms, staggered) ─────────────────────────────────────
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    // Logo: fade + scale + slide – earliest
    _logoFade  = _interval(0.00, 0.30, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.40, curve: Curves.elasticOut)));
    _logoSlide = Tween<double>(begin: -22.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.35, curve: Curves.easeOut)));

    // Heading
    _headFade  = _interval(0.22, 0.50, curve: Curves.easeOut);
    _headSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.22, 0.50, curve: Curves.easeOut)));

    // Card
    _cardFade  = _interval(0.38, 0.70, curve: Curves.easeOut);
    _cardSlide = Tween<double>(begin: 24.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.38, 0.70, curve: Curves.easeOut)));
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.38, 0.72, curve: Curves.easeOut)));

    // Bottom
    _bottomFade  = _interval(0.60, 1.00, curve: Curves.easeOut);
    _bottomSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.60, 1.00, curve: Curves.easeOut)));

    // ── Particles (6 s loop) ───────────────────────────────────────────────
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat();

    // ── Ambient glow pulse (2.4 s) ─────────────────────────────────────────
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

    // ── Orb drift (8 s) ───────────────────────────────────────────────────
    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 8000))
      ..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  /// Helper: fade-in interval animation.
  Animation<double> _interval(double start, double end,
      {Curve curve = Curves.easeOut}) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(start, end, curve: curve)));

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  // ── Business logic (unchanged) ────────────────────────────────────────────
  Future<void> _onLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(RoutePaths.home);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: Stack(
        children: [
          // ── Deep gradient background ───────────────────────────────────
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

          // ── Ambient drifting orbs ──────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _orbCtrl,
                builder: (_, __) => _AmbientOrbs(progress: _orbCtrl.value),
              ),
            ),
          ),

          // ── Floating particles ─────────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleLayer(controller: _particleCtrl),
            ),
          ),

          // ── Main scrollable content ────────────────────────────────────
          SafeArea(
            child: AnimatedBuilder(
              animation: Listenable.merge(
                  [_enterCtrl, _floatCtrl, _glowCtrl]),
              builder: (context, _) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildLogo(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildHeading(),
                    const SizedBox(height: AppSpacing.xl),
                    _buildFormCard(),
                    const SizedBox(height: AppSpacing.lg),
                    // Bottom section — fade + slide
                    Opacity(
                      opacity: _bottomFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _bottomSlide.value),
                        child: Column(
                          children: [
                            const AuthDivider(),
                            const SizedBox(height: AppSpacing.md),
                            _AnimatedSocialButton(
                              label: 'Continue with Google',
                              iconWidget: _GoogleLogoIcon(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const _AnimatedSocialButton(
                              label: 'Continue with Apple',
                              iconWidget: Icon(Icons.apple_rounded,
                                  color: AppColors.onPrimary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const _AnimatedSocialButton(
                              label: 'Continue with Microsoft',
                              iconWidget: _MicrosoftLogoIcon(),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            _buildBottomLink(),
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

  // ── Logo section ──────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return Opacity(
      opacity: _logoFade.value,
      child: Transform.translate(
        offset: Offset(0, _logoSlide.value + _floatAnim.value),
        child: Transform.scale(
          scale: _logoScale.value,
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulsing glow halo
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.secondary.withValues(alpha: _glowAnim.value * 0.55),
                          AppColors.tertiary.withValues(alpha: _glowAnim.value * 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  // Inner tighter glow ring
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary
                              .withValues(alpha: _glowAnim.value * 0.45),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                        BoxShadow(
                          color: AppColors.tertiary
                              .withValues(alpha: _glowAnim.value * 0.20),
                          blurRadius: 48,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  // Logo itself — AppLogoWidget carries its own pulse/rotate
                  const SizedBox(
                    width: 80,
                    height: 80,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: AppLogoWidget(),
                    ),
                  ),
                ],
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
              'Welcome Back',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Continue your learning journey.',
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

  // ── Glassmorphism form card ───────────────────────────────────────────────

  Widget _buildFormCard() {
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
                      color: Colors.white.withValues(alpha: 0.13), width: 1.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.10),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Email field
                    _AnimatedTextField(
                      label: 'Email address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password field
                    _AnimatedTextField(
                      label: 'Password',
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Remember me + Forgot password
                    Row(
                      children: [
                        _DarkCheckbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          label: 'Remember me',
                        ),
                        const Spacer(),
                        _AnimatedLink(
                          text: 'Forgot Password?',
                          onTap: () =>
                              context.push(RoutePaths.forgotPassword),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // CTA button
                    _GradientLoginButton(
                      isLoading: _isLoading,
                      onPressed: _onLogin,
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

  // ── Bottom sign-up link ───────────────────────────────────────────────────

  Widget _buildBottomLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?  ",
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.60),
          ),
        ),
        _AnimatedLink(
          text: 'Create Account',
          onTap: () => context.push(RoutePaths.signup),
          isGradient: true,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient drifting orbs — very subtle background glow blobs
// ─────────────────────────────────────────────────────────────────────────────

class _AmbientOrbs extends StatelessWidget {
  const _AmbientOrbs({required this.progress});
  final double progress; // 0.0 → 1.0, reversed loop

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Ease the progress for smooth drift
    final t = Curves.easeInOut.transform(progress);

    return CustomPaint(
      size: size,
      painter: _OrbPainter(t: t),
    );
  }
}

class _OrbPainter extends CustomPainter {
  const _OrbPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — blue, top-centre, gentle horizontal drift
    final orb1x = size.width * (0.45 + 0.08 * t);
    final orb1y = size.height * (0.08 + 0.03 * t);
    paint.shader = RadialGradient(
      colors: [
        AppColors.secondary.withOpacity(0.18),
        AppColors.secondary.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
        center: Offset(orb1x, orb1y), radius: size.width * 0.38));
    canvas.drawCircle(Offset(orb1x, orb1y), size.width * 0.38, paint);

    // Orb 2 — teal, bottom-right, slow diagonal drift
    final orb2x = size.width * (0.72 + 0.06 * (1 - t));
    final orb2y = size.height * (0.68 + 0.04 * t);
    paint.shader = RadialGradient(
      colors: [
        AppColors.tertiary.withOpacity(0.12),
        AppColors.tertiary.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
        center: Offset(orb2x, orb2y), radius: size.width * 0.32));
    canvas.drawCircle(Offset(orb2x, orb2y), size.width * 0.32, paint);

    // Orb 3 — secondary, bottom-left, opposing drift
    final orb3x = size.width * (0.18 + 0.05 * t);
    final orb3y = size.height * (0.78 - 0.04 * t);
    paint.shader = RadialGradient(
      colors: [
        AppColors.secondaryLight.withOpacity(0.10),
        AppColors.secondaryLight.withOpacity(0.0),
      ],
    ).createShader(Rect.fromCircle(
        center: Offset(orb3x, orb3y), radius: size.width * 0.28));
    canvas.drawCircle(Offset(orb3x, orb3y), size.width * 0.28, paint);
  }

  @override
  bool shouldRepaint(_OrbPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated text field — border glow, icon color tween, shake scaffold
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedTextField extends StatefulWidget {
  const _AnimatedTextField({
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.textInputAction,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final IconData? prefixIcon;
  final TextInputAction? textInputAction;

  @override
  State<_AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<_AnimatedTextField>
    with SingleTickerProviderStateMixin {
  bool _obscure  = true;
  bool _focused  = false;

  // Shake controller for error animation scaffold
  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  /// Call this from a parent to trigger the error shake animation.
  void shake() {
    _shakeCtrl.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(_shakeAnim.value, 0),
        child: child,
      ),
      child: Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: _focused
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.28),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: AppColors.tertiary.withValues(alpha: 0.10),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.isPassword
                ? TextInputType.visiblePassword
                : widget.keyboardType,
            obscureText: widget.isPassword && _obscure,
            textInputAction: widget.textInputAction,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.onPrimary),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: _focused
                    ? AppColors.secondaryLight
                    : AppColors.onPrimary.withValues(alpha: 0.50),
              ),
              hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.28)),
              filled: true,
              fillColor: _focused
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.06),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.md),
              prefixIcon: widget.prefixIcon != null
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        widget.prefixIcon,
                        key: ValueKey(_focused),
                        color: _focused
                            ? AppColors.secondaryLight
                            : AppColors.onPrimary.withValues(alpha: 0.45),
                        size: 20,
                      ),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.onPrimary.withValues(alpha: 0.50),
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    )
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.18))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.secondary, width: 1.8)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dark checkbox (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _DarkCheckbox extends StatelessWidget {
  const _DarkCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.secondary,
              checkColor: AppColors.onPrimary,
              side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.35), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated link — smooth color/opacity transition, pointer cursor
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedLink extends StatefulWidget {
  const _AnimatedLink({
    required this.text,
    required this.onTap,
    this.isGradient = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool isGradient;

  @override
  State<_AnimatedLink> createState() => _AnimatedLinkState();
}

class _AnimatedLinkState extends State<_AnimatedLink>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onEnter() {
    setState(() => _hovered = true);
    _ctrl.forward();
  }

  void _onExit() {
    setState(() => _hovered = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
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
            animation: _fadeAnim,
            builder: (_, __) {
              final hoverExtra = _fadeAnim.value * 0.25;
              if (widget.isGradient) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color.lerp(AppColors.secondaryLight,
                          AppColors.tertiary, 0.0 + _fadeAnim.value * 0.3)!,
                      AppColors.tertiary,
                    ],
                  ).createShader(bounds),
                  child: Text(
                    widget.text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }
              return Text(
                widget.text,
                style: AppTypography.labelSmall.copyWith(
                  color: Color.lerp(
                    AppColors.secondaryLight,
                    AppColors.tertiary,
                    hoverExtra,
                  ),
                  fontWeight: FontWeight.w600,
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
// Gradient CTA button — glow pulse + scale press + ripple + loading
// ─────────────────────────────────────────────────────────────────────────────

class _GradientLoginButton extends StatefulWidget {
  const _GradientLoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_GradientLoginButton> createState() => _GradientLoginButtonState();
}

class _GradientLoginButtonState extends State<_GradientLoginButton>
    with TickerProviderStateMixin {
  // Press scale
  late final AnimationController _scaleCtrl;

  // Glow pulse
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // Hover
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
          builder: (_, child) => Transform.scale(
            scale: _scaleCtrl.value,
            child: child,
          ),
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
              color: enabled
                  ? null
                  : Colors.white.withValues(alpha: 0.12),
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
                            width: 22,
                            height: 22,
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
                                'Continue Learning',
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
// Animated social buttons — scale, hover elevation, ripple, pointer cursor
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedSocialButton extends StatefulWidget {
  const _AnimatedSocialButton({
    required this.label,
    required this.iconWidget,
  });

  final String label;
  final Widget iconWidget;

  @override
  State<_AnimatedSocialButton> createState() =>
      _AnimatedSocialButtonState();
}

class _AnimatedSocialButtonState extends State<_AnimatedSocialButton>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _pressed = false;

  late final AnimationController _elevCtrl;
  late final Animation<double> _elevAnim;

  @override
  void initState() {
    super.initState();
    _elevCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _elevAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _elevCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _elevCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        _elevCtrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _elevCtrl.reverse();
      },
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: _elevAnim,
            builder: (_, __) {
              final shadowOpacity = 0.08 + _elevAnim.value * 0.14;
              final blurRadius    = 8.0 + _elevAnim.value * 12.0;
              return ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                          alpha: 0.06 + _elevAnim.value * 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(
                            alpha: 0.13 + _elevAnim.value * 0.10),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary
                              .withValues(alpha: shadowOpacity),
                          blurRadius: blurRadius,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(14),
                        splashColor:
                            Colors.white.withValues(alpha: 0.12),
                        highlightColor:
                            Colors.white.withValues(alpha: 0.06),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 22,
                                height: 22,
                                child: widget.iconWidget),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              widget.label,
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.onPrimary
                                    .withValues(alpha: 0.85),
                              ),
                            ),
                          ],
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
// Icon painters (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _GoogleLogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width * 0.46;
    final colors = [
      const Color(0xFF4285F4),
      const Color(0xFF34A853),
      const Color(0xFFFBBC05),
      const Color(0xFFEA4335),
    ];
    double start = -90.0;
    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        start * math.pi / 180,
        90 * math.pi / 180,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.18
          ..strokeCap = StrokeCap.butt,
      );
      start += 90;
    }
  }

  @override
  bool shouldRepaint(_GooglePainter o) => false;
}

class _MicrosoftLogoIcon extends StatelessWidget {
  const _MicrosoftLogoIcon();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MsPainter());
}

class _MsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final half   = size.width * 0.46;
    final gap    = size.width * 0.08;
    final offset = (size.width - (half * 2 + gap)) / 2;
    final top    = (size.height - (half * 2 + gap)) / 2;
    final quads  = [
      [const Color(0xFFF25022), offset,              top],
      [const Color(0xFF7FBA00), offset + half + gap, top],
      [const Color(0xFF00A4EF), offset,              top + half + gap],
      [const Color(0xFFFFB900), offset + half + gap, top + half + gap],
    ];
    for (final q in quads) {
      canvas.drawRect(
        Rect.fromLTWH(q[1] as double, q[2] as double, half, half),
        Paint()..color = q[0] as Color,
      );
    }
  }

  @override
  bool shouldRepaint(_MsPainter o) => false;
}

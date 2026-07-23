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
// Signup Screen — premium redesign matching the Login screen design system.
// Business logic, controllers, navigation and all state are UNCHANGED.
// Only the visual / animation layer is replaced.
// ─────────────────────────────────────────────────────────────────────────────

/// Phase 2B — Premium Sign Up Screen (redesigned UI).
///
/// UI only. No Firebase / backend calls. GoRouter navigation.
class FeatureSignupScreen extends StatefulWidget {
  const FeatureSignupScreen({super.key});

  @override
  State<FeatureSignupScreen> createState() => _FeatureSignupScreenState();
}

class _FeatureSignupScreenState extends State<FeatureSignupScreen>
    with TickerProviderStateMixin {
  // ── Business-logic state (unchanged) ──────────────────────────────────────
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _isLoading    = false;
  bool _agreedToTerms = false;

  // ── Entrance stagger ──────────────────────────────────────────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _logoFade, _logoScale, _logoSlide;
  late final Animation<double> _headFade,  _headSlide;
  late final Animation<double> _cardFade,  _cardSlide, _cardScale;
  late final Animation<double> _bottomFade, _bottomSlide;

  // ── Background ────────────────────────────────────────────────────────────
  late final AnimationController _particleCtrl;
  late final AnimationController _orbCtrl;

  // ── Logo glow pulse ───────────────────────────────────────────────────────
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  // ── Logo float ────────────────────────────────────────────────────────────
  late final AnimationController _floatCtrl;
  late final Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    // ── Entrance (1 400 ms stagger) ────────────────────────────────────────
    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _logoFade  = _iv(0.00, 0.30);
    _logoScale = Tween<double>(begin: 0.70, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.42, curve: Curves.elasticOut)));
    _logoSlide = Tween<double>(begin: -22.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.00, 0.35, curve: Curves.easeOut)));

    _headFade  = _iv(0.20, 0.48);
    _headSlide = Tween<double>(begin: 16.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.20, 0.48, curve: Curves.easeOut)));

    _cardFade  = _iv(0.36, 0.70);
    _cardSlide = Tween<double>(begin: 26.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.36, 0.70, curve: Curves.easeOut)));
    _cardScale = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.36, 0.72, curve: Curves.easeOut)));

    _bottomFade  = _iv(0.60, 1.00);
    _bottomSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(parent: _enterCtrl,
            curve: const Interval(0.60, 1.00, curve: Curves.easeOut)));

    // ── Background loops ───────────────────────────────────────────────────
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 6000))
      ..repeat();

    _orbCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 8000))
      ..repeat(reverse: true);

    // ── Glow pulse (2.4 s) ─────────────────────────────────────────────────
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.25, end: 0.55).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    // ── Float (3 s) ────────────────────────────────────────────────────────
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -6.0, end: 6.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _enterCtrl.forward();
    });
  }

  /// Fade-in interval shorthand.
  Animation<double> _iv(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _enterCtrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    _orbCtrl.dispose();
    _glowCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  // ── Business logic (unchanged) ────────────────────────────────────────────
  Future<void> _onSignUp() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go(RoutePaths.verifyEmail);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C),
      body: Stack(
        children: [
          // ── Gradient background ───────────────────────────────────────
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

          // ── Ambient orbs ──────────────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _orbCtrl,
                builder: (_, __) =>
                    _SignupAmbientOrbs(progress: _orbCtrl.value),
              ),
            ),
          ),

          // ── Particles ─────────────────────────────────────────────────
          Positioned.fill(
            child: IgnorePointer(
              child: ParticleLayer(controller: _particleCtrl),
            ),
          ),

          // ── Scrollable content ────────────────────────────────────────
          SafeArea(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_enterCtrl, _floatCtrl, _glowCtrl]),
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
                        child: _BackButton(
                            onTap: () => context.pop()),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Logo
                    _buildLogo(),
                    const SizedBox(height: AppSpacing.md),

                    // Heading
                    _buildHeading(),
                    const SizedBox(height: AppSpacing.xl),

                    // Glass form card
                    _buildFormCard(),
                    const SizedBox(height: AppSpacing.lg),

                    // Bottom: divider + socials + sign-in link
                    Opacity(
                      opacity: _bottomFade.value,
                      child: Transform.translate(
                        offset: Offset(0, _bottomSlide.value),
                        child: Column(
                          children: [
                            const AuthDivider(),
                            const SizedBox(height: AppSpacing.md),
                            _SuAnimatedSocialButton(
                              label: 'Continue with Google',
                              iconWidget: _GoogleLogoIcon(),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const _SuAnimatedSocialButton(
                              label: 'Continue with Apple',
                              iconWidget: Icon(Icons.apple_rounded,
                                  color: AppColors.onPrimary, size: 20),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const _SuAnimatedSocialButton(
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
              // Outer pulsing radial glow halo
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondary
                          .withValues(alpha: _glowAnim.value * 0.55),
                      AppColors.tertiary
                          .withValues(alpha: _glowAnim.value * 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
              // Inner box-shadow ring
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
              // Logo
              const SizedBox(
                width: 80,
                height: 80,
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
              'Create Account',
              textAlign: TextAlign.center,
              style: AppTypography.headlineMedium.copyWith(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Start your smart learning journey.',
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

  // ── Glass form card ───────────────────────────────────────────────────────

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
                      color: Colors.white.withValues(alpha: 0.13),
                      width: 1.0),
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
                    // Full Name
                    _SuAnimatedTextField(
                      label: 'Full Name',
                      hint: 'Jane Smith',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Email
                    _SuAnimatedTextField(
                      label: 'Email address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    _SuAnimatedTextField(
                      label: 'Password',
                      hint: 'Min 8 characters',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Confirm Password
                    _SuAnimatedTextField(
                      label: 'Confirm Password',
                      hint: 'Repeat your password',
                      controller: _confirmController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline_rounded,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Terms & Privacy
                    _SuTermsCheckbox(
                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // CTA button
                    _SuGradientButton(
                      label: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _agreedToTerms ? _onSignUp : null,
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

  // ── Bottom link ───────────────────────────────────────────────────────────

  Widget _buildBottomLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account?  ',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.60),
          ),
        ),
        _SuAnimatedLink(
          text: 'Sign In',
          onTap: () => context.pop(),
          isGradient: true,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ambient orbs — identical layout logic to login, different seed positions
// ─────────────────────────────────────────────────────────────────────────────

class _SignupAmbientOrbs extends StatelessWidget {
  const _SignupAmbientOrbs({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final t = Curves.easeInOut.transform(progress);
    return CustomPaint(size: size, painter: _SignupOrbPainter(t: t));
  }
}

class _SignupOrbPainter extends CustomPainter {
  const _SignupOrbPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Orb 1 — blue, top-left drift
    final o1x = size.width * (0.20 + 0.06 * t);
    final o1y = size.height * (0.06 + 0.03 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.secondary.withOpacity(0.18),
      AppColors.secondary.withOpacity(0.0),
    ]).createShader(
        Rect.fromCircle(center: Offset(o1x, o1y), radius: size.width * 0.38));
    canvas.drawCircle(Offset(o1x, o1y), size.width * 0.38, paint);

    // Orb 2 — teal, bottom-right slow diagonal
    final o2x = size.width * (0.78 - 0.05 * t);
    final o2y = size.height * (0.70 + 0.04 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.tertiary.withOpacity(0.12),
      AppColors.tertiary.withOpacity(0.0),
    ]).createShader(
        Rect.fromCircle(center: Offset(o2x, o2y), radius: size.width * 0.32));
    canvas.drawCircle(Offset(o2x, o2y), size.width * 0.32, paint);

    // Orb 3 — secondary light, mid-left opposing
    final o3x = size.width * (0.12 + 0.04 * (1 - t));
    final o3y = size.height * (0.50 - 0.03 * t);
    paint.shader = RadialGradient(colors: [
      AppColors.secondaryLight.withOpacity(0.09),
      AppColors.secondaryLight.withOpacity(0.0),
    ]).createShader(
        Rect.fromCircle(center: Offset(o3x, o3y), radius: size.width * 0.26));
    canvas.drawCircle(Offset(o3x, o3y), size.width * 0.26, paint);
  }

  @override
  bool shouldRepaint(_SignupOrbPainter old) => old.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated back button
// ─────────────────────────────────────────────────────────────────────────────

class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton>
    with SingleTickerProviderStateMixin {
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
              color: Colors.white.withValues(alpha: _hovered ? 0.22 : 0.13),
              width: 1.0,
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.secondary.withValues(alpha: 0.18),
                      blurRadius: 12,
                    )
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
// Animated text field — border glow, icon tween, shake scaffold
// (Same logic as Login's _AnimatedTextField, prefixed _Su to avoid conflicts)
// ─────────────────────────────────────────────────────────────────────────────

class _SuAnimatedTextField extends StatefulWidget {
  const _SuAnimatedTextField({
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
  State<_SuAnimatedTextField> createState() => _SuAnimatedTextFieldState();
}

class _SuAnimatedTextFieldState extends State<_SuAnimatedTextField>
    with SingleTickerProviderStateMixin {
  bool _obscure = true;
  bool _focused = false;

  late final AnimationController _shakeCtrl;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0),  weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0),   weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void shake() => _shakeCtrl.forward(from: 0.0);

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
                  borderSide: const BorderSide(
                      color: AppColors.secondary, width: 1.8)),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Terms & Privacy checkbox — premium dark styling
// ─────────────────────────────────────────────────────────────────────────────

class _SuTermsCheckbox extends StatelessWidget {
  const _SuTermsCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.labelSmall.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.65)),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gradient CTA button — identical to Login's _GradientLoginButton
// ─────────────────────────────────────────────────────────────────────────────

class _SuGradientButton extends StatefulWidget {
  const _SuGradientButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  State<_SuGradientButton> createState() => _SuGradientButtonState();
}

class _SuGradientButtonState extends State<_SuGradientButton>
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
                                widget.label,
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
// Animated social buttons — identical behaviour to Login
// ─────────────────────────────────────────────────────────────────────────────

class _SuAnimatedSocialButton extends StatefulWidget {
  const _SuAnimatedSocialButton({
    required this.label,
    required this.iconWidget,
  });

  final String label;
  final Widget iconWidget;

  @override
  State<_SuAnimatedSocialButton> createState() =>
      _SuAnimatedSocialButtonState();
}

class _SuAnimatedSocialButtonState extends State<_SuAnimatedSocialButton>
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
        onTapUp:   (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_hovered ? 1.02 : 1.0),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          child: AnimatedBuilder(
            animation: _elevAnim,
            builder: (_, __) {
              final shadowOpacity = 0.08 + _elevAnim.value * 0.14;
              final blurRadius    = 8.0  + _elevAnim.value * 12.0;
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
// Animated link — smooth color transition, pointer cursor
// ─────────────────────────────────────────────────────────────────────────────

class _SuAnimatedLink extends StatefulWidget {
  const _SuAnimatedLink({
    required this.text,
    required this.onTap,
    this.isGradient = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool isGradient;

  @override
  State<_SuAnimatedLink> createState() => _SuAnimatedLinkState();
}

class _SuAnimatedLinkState extends State<_SuAnimatedLink>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
    _anim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
            builder: (_, __) {
              if (widget.isGradient) {
                return ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [
                      Color.lerp(AppColors.secondaryLight,
                          AppColors.tertiary, _anim.value * 0.3)!,
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
                    _anim.value * 0.25,
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
// Icon painters — Google & Microsoft logos (identical to Login)
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

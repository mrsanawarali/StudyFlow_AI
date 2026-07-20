import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';
import 'package:untitled/features/splash/presentation/widgets/loading_dots_widget.dart';
import 'package:untitled/features/splash/presentation/widgets/particle_layer.dart';

/// Premium cinematic splash screen for StudyFlow AI.
///
/// Layer order (bottom → top):
///   1. Dark navy-to-purple gradient background
///   2. Animated floating particle layer
///   3. Logo (centered, upper 35 % of screen)
///   4. Branding text block with glassmorphism accent
///   5. Three-dot glowing loading indicator
///
/// All entrance elements use a single [AnimationController] (_enterCtrl)
/// with a 1500 ms staggered fade-in sequence:
///   [0–500 ms]   Logo fades in
///   [500–900 ms] Title fades in
///   [900–1200 ms] Subtitle fades in
///   [1200–1500 ms] Loading dots fade in
///
/// Navigation fires after 2500 ms from [initState] via a cancellable [Timer].
/// No routing constants, router config, or other screens are modified.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Staggered entrance controller (1500 ms, runs once) ───────────────────
  late final AnimationController _enterCtrl;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _subtitleOpacity;
  late final Animation<double> _dotsOpacity;

  // ── Particle layer controller (loops at ~6 s per tick) ──────────────────
  late final AnimationController _particleCtrl;

  // ── Navigation timer ─────────────────────────────────────────────────────
  static const Duration _splashDelay = Duration(milliseconds: 2500);
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // ── Entrance animations ────────────────────────────────────────────────
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.000, 0.333, curve: Curves.easeOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.333, 0.600, curve: Curves.easeOut),
      ),
    );

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.600, 0.800, curve: Curves.easeOut),
      ),
    );

    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _enterCtrl,
        curve: const Interval(0.800, 1.000, curve: Curves.easeOut),
      ),
    );

    // ── Particle controller (loops, drives repaint) ────────────────────────
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    );

    // Start both on the same frame
    _enterCtrl.forward();
    _particleCtrl.repeat();

    // Navigation timer
    _navTimer = Timer(_splashDelay, _onTimerFired);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _enterCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  void _onTimerFired() {
    if (mounted) {
      context.go(RoutePaths.onboarding);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F2C), // fallback if gradient fails
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0F2C), // dark navy
              Color(0xFF1A0A3C), // deep purple
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Layer 2: Floating particles ──────────────────────────────
            Positioned.fill(
              child: ParticleLayer(controller: _particleCtrl),
            ),

            // ── Layer 3–5: Logo + branding + dots ────────────────────────
            SafeArea(
              child: _buildContent(screen),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Size screen) {
    return Column(
      children: [
        // Upper ~35 % → logo
        SizedBox(
          height: screen.height * 0.38,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FadeTransition(
              opacity: _logoOpacity,
              child: const AppLogoWidget(),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Middle: glassmorphism card with title + subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: _GlassmorphismCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                FadeTransition(
                  opacity: _titleOpacity,
                  child: Text(
                    'StudyFlow AI',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.onPrimary,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                FadeTransition(
                  opacity: _subtitleOpacity,
                  child: Text(
                    'Transform Your Study Journey',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.onPrimary.withValues(alpha: 0.80),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 40),

        // Bottom: three glowing dots
        FadeTransition(
          opacity: _dotsOpacity,
          child: const LoadingDotsWidget(),
        ),
      ],
    );
  }
}

// ── Glassmorphism accent container ────────────────────────────────────────────

/// A frosted-glass card: white 5 % fill, 15 % white border, 16 dp radius.
/// Uses [BackdropFilter] for the blur effect.
class _GlassmorphismCard extends StatelessWidget {
  const _GlassmorphismCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

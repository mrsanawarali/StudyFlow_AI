import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';

/// Branded animated splash screen for StudyFlow AI.
///
/// Plays a staggered entrance animation over 1300 ms, then navigates
/// to [RoutePaths.onboarding] after a 2500 ms delay. The navigation
/// timer is cancelled in [dispose] so it never fires on an unmounted widget.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _controller;

  /// Total duration of the staggered entrance sequence.
  static const Duration _animationDuration = Duration(milliseconds: 1300);

  late final Animation<double> _logoOpacity;    // Interval [0.00, 0.46]
  late final Animation<double> _logoScale;      // Interval [0.00, 0.46]
  late final Animation<double> _brandOpacity;   // Interval [0.46, 0.77]
  late final Animation<double> _taglineOpacity; // Interval [0.77, 1.00]

  // ── Timer ─────────────────────────────────────────────────────────────────
  /// Total time the splash is visible before navigation fires.
  static const Duration _splashDelay = Duration(milliseconds: 2500);
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    );

    // Logo fade: 0 % → 46 % of the animation timeline
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.46, curve: Curves.easeOut),
      ),
    );

    // Logo scale: 0 % → 46 % of the animation timeline (starts at 60 % size)
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.46, curve: Curves.easeOut),
      ),
    );

    // Brand name fade: 46 % → 77 % of the animation timeline
    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.46, 0.77, curve: Curves.easeOut),
      ),
    );

    // Tagline fade: 77 % → 100 % of the animation timeline
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.77, 1.00, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _navTimer = Timer(_splashDelay, _onTimerFired);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTimerFired() {
    if (mounted) {
      context.go(RoutePaths.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryLight],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo: fade + scale entrance
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: const AppLogoWidget(),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // App name: fade entrance
                FadeTransition(
                  opacity: _brandOpacity,
                  child: Text(
                    'StudyFlow AI',
                    style: AppTypography.headlineLarge
                        .copyWith(color: AppColors.onPrimary),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                // Tagline: fade entrance with 85 % opacity overlay
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Opacity(
                    opacity: 0.85,
                    child: Text(
                      'Transform Your Study Journey',
                      style: AppTypography.bodyLarge
                          .copyWith(color: AppColors.onPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

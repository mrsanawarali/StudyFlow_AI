import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';

/// Premium onboarding page 1 — "Study Smarter".
///
/// This widget handles its own staggered entrance animations for:
///   logo → illustration → title → subtitle → (CTA is owned by host screen)
///
/// It is intentionally scoped to page 1 only. Pages 2–4 continue using
/// the existing [OnboardingPageWidget].
class OnboardingPage1Widget extends StatefulWidget {
  const OnboardingPage1Widget({
    super.key,
    required this.illustrationWidget,
  });

  /// The illustration widget forwarded from the host screen (already wrapped
  /// in a [FadeTransition] by the host).
  final Widget illustrationWidget;

  @override
  State<OnboardingPage1Widget> createState() => _OnboardingPage1WidgetState();
}

class _OnboardingPage1WidgetState extends State<OnboardingPage1Widget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoSlide;
  late final Animation<double> _illuFade;
  late final Animation<double> _illuSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.00, 0.35, curve: Curves.easeOut)));
    _logoSlide = Tween<double>(begin: -16.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.00, 0.35, curve: Curves.easeOut)));

    _illuFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.20, 0.60, curve: Curves.easeOut)));
    _illuSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.20, 0.60, curve: Curves.easeOut)));

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.50, 0.78, curve: Curves.easeOut)));
    _titleSlide = Tween<double>(begin: 12.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.50, 0.78, curve: Curves.easeOut)));

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _ctrl, curve: const Interval(0.68, 1.00, curve: Curves.easeOut)));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Small logo ──────────────────────────────────────────────
              Opacity(
                opacity: _logoFade.value,
                child: Transform.translate(
                  offset: Offset(0, _logoSlide.value),
                  child: _SmallLogoChip(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Illustration ────────────────────────────────────────────
              Opacity(
                opacity: _illuFade.value,
                child: Transform.translate(
                  offset: Offset(0, _illuSlide.value),
                  child: SizedBox(
                    height: AppSpacing.xxxl * 3, // 192 dp — same as host
                    width: double.infinity,
                    child: widget.illustrationWidget,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Glassmorphism text card ──────────────────────────────────
              Opacity(
                opacity: _titleFade.value,
                child: Transform.translate(
                  offset: Offset(0, _titleSlide.value),
                  child: _GlassTextCard(
                    title: 'Study Smarter',
                    subtitle:
                        'Organize your semesters, subjects, notes and study\nmaterials in one intelligent workspace.',
                    subtitleOpacity: _subtitleFade.value,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small logo chip at top of page 1
// ─────────────────────────────────────────────────────────────────────────────

class _SmallLogoChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tiny logo mark — reuse AppLogoWidget but force small size
        SizedBox(
          width: 28,
          height: 28,
          child: FittedBox(
            fit: BoxFit.contain,
            child: const AppLogoWidget(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'StudyFlow AI',
          style: AppTypography.labelLarge.copyWith(
            color: AppColors.onPrimary.withValues(alpha: 0.90),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glassmorphism text card
// ─────────────────────────────────────────────────────────────────────────────

class _GlassTextCard extends StatelessWidget {
  const _GlassTextCard({
    required this.title,
    required this.subtitle,
    required this.subtitleOpacity,
  });

  final String title;
  final String subtitle;
  final double subtitleOpacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onPrimary,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Opacity(
                opacity: subtitleOpacity,
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.72),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

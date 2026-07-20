import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';

/// Premium onboarding page 2 — "Offline First".
///
/// Staggered entrance sequence (all driven by a single 1300 ms controller):
///   [0–30%]   small logo chip fades + slides in from top
///   [18–58%]  illustration fades + slides up
///   [48–76%]  title fades + slides up
///   [62–88%]  subtitle fades in
///   [75–100%] feature chips stagger in (three chips, 60 ms apart)
class OnboardingPage2Widget extends StatefulWidget {
  const OnboardingPage2Widget({
    super.key,
    required this.illustrationWidget,
  });

  final Widget illustrationWidget;

  @override
  State<OnboardingPage2Widget> createState() => _OnboardingPage2WidgetState();
}

class _OnboardingPage2WidgetState extends State<OnboardingPage2Widget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoSlide;
  late final Animation<double> _illuFade;
  late final Animation<double> _illuSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final List<Animation<double>> _chipFades;
  late final List<Animation<double>> _chipSlides;

  static const _chips = [
    ('✓', 'Offline Notes'),
    ('✓', 'Secure Sync'),
    ('✓', 'Fast Access'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _logoFade = _anim(0.00, 0.30);
    _logoSlide = _slide(0.00, 0.30, begin: -14.0);

    _illuFade = _anim(0.18, 0.58);
    _illuSlide = _slide(0.18, 0.58, begin: 18.0);

    _titleFade = _anim(0.48, 0.76);
    _titleSlide = _slide(0.48, 0.76, begin: 12.0);

    _subtitleFade = _anim(0.62, 0.88);

    // Three chips stagger 0.06 apart starting at 0.75
    _chipFades = List.generate(3, (i) => _anim(0.75 + i * 0.06, 1.00));
    _chipSlides = List.generate(
        3, (i) => _slide(0.75 + i * 0.06, 1.00, begin: 10.0));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  Animation<double> _anim(double start, double end) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

  Animation<double> _slide(double start, double end,
          {double begin = 12.0}) =>
      Tween<double>(begin: begin, end: 0.0).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

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
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // ── Small logo chip ─────────────────────────────────────────
              Opacity(
                opacity: _logoFade.value,
                child: Transform.translate(
                  offset: Offset(0, _logoSlide.value),
                  child: const _SmallLogoChip(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Illustration ────────────────────────────────────────────
              Opacity(
                opacity: _illuFade.value,
                child: Transform.translate(
                  offset: Offset(0, _illuSlide.value),
                  child: SizedBox(
                    height: AppSpacing.xxxl * 3,
                    width: double.infinity,
                    child: widget.illustrationWidget,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Glass text card ─────────────────────────────────────────
              Opacity(
                opacity: _titleFade.value,
                child: Transform.translate(
                  offset: Offset(0, _titleSlide.value),
                  child: _GlassTextCard(
                    subtitleOpacity: _subtitleFade.value,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Feature chips ────────────────────────────────────────────
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: List.generate(_chips.length, (i) {
                  return Opacity(
                    opacity: _chipFades[i].value,
                    child: Transform.translate(
                      offset: Offset(0, _chipSlides[i].value),
                      child: _FeatureChip(
                        icon: _chips[i].$1,
                        label: _chips[i].$2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small logo chip
// ─────────────────────────────────────────────────────────────────────────────

class _SmallLogoChip extends StatelessWidget {
  const _SmallLogoChip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
// Glass text card — title + subtitle
// ─────────────────────────────────────────────────────────────────────────────

class _GlassTextCard extends StatelessWidget {
  const _GlassTextCard({required this.subtitleOpacity});

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
                'Offline First',
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
                  'Access your notes, subjects and study materials anytime. '
                  'Your progress stays available even without an internet connection.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.72),
                    height: 1.55,
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

// ─────────────────────────────────────────────────────────────────────────────
// Glass feature chip
// ─────────────────────────────────────────────────────────────────────────────

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondaryLight.withValues(alpha: 0.30),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.18),
                blurRadius: 8,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                icon,
                style: TextStyle(
                  color: AppColors.tertiary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

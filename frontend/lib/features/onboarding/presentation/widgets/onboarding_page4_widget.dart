import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/splash/presentation/widgets/app_logo_widget.dart';

/// Premium onboarding page 4 — "Stay Organized. Achieve More."
///
/// Staggered entrance (1400 ms controller):
///   [0–28%]   logo chip
///   [16–55%]  illustration
///   [46–70%]  productivity badge
///   [56–80%]  title
///   [68–90%]  subtitle
///   [78–100%] four feature cards (staggered 5% apart)
class OnboardingPage4Widget extends StatefulWidget {
  const OnboardingPage4Widget({
    super.key,
    required this.illustrationWidget,
    required this.onContinue,
  });

  final Widget illustrationWidget;
  final VoidCallback? onContinue;

  @override
  State<OnboardingPage4Widget> createState() => _OnboardingPage4WidgetState();
}

class _OnboardingPage4WidgetState extends State<OnboardingPage4Widget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _logoFade, _logoSlide;
  late final Animation<double> _illuFade, _illuSlide;
  late final Animation<double> _badgeFade, _badgeScale;
  late final Animation<double> _titleFade, _titleSlide;
  late final Animation<double> _subtitleFade;
  late final List<Animation<double>> _cardFades, _cardSlides;

  static const _cards = [
    ('📅', 'Smart Timetable'),
    ('📈', 'Track Progress'),
    ('🎯', 'Achieve Goals'),
    ('🏆', 'Build Study Streaks'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _logoFade  = _a(0.00, 0.28);
    _logoSlide = _s(0.00, 0.28, b: -14.0);
    _illuFade  = _a(0.16, 0.55);
    _illuSlide = _s(0.16, 0.55, b: 18.0);
    _badgeFade  = _a(0.46, 0.70);
    _badgeScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.46, 0.70, curve: Curves.elasticOut)));
    _titleFade  = _a(0.56, 0.80);
    _titleSlide = _s(0.56, 0.80, b: 12.0);
    _subtitleFade = _a(0.68, 0.90);
    _cardFades  = List.generate(4, (i) => _a(0.78 + i * 0.05, 1.00));
    _cardSlides = List.generate(4, (i) => _s(0.78 + i * 0.05, 1.00, b: 10.0));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  Animation<double> _a(double s, double e) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _ctrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  Animation<double> _s(double s, double e, {double b = 12.0}) =>
      Tween<double>(begin: b, end: 0.0).animate(
          CurvedAnimation(parent: _ctrl,
              curve: Interval(s, e, curve: Curves.easeOut)));

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.sm),

            // Logo chip
            Opacity(opacity: _logoFade.value,
              child: Transform.translate(offset: Offset(0, _logoSlide.value),
                child: const _SmallLogoChip())),
            const SizedBox(height: AppSpacing.sm),

            // Illustration
            Opacity(opacity: _illuFade.value,
              child: Transform.translate(offset: Offset(0, _illuSlide.value),
                child: SizedBox(
                  height: AppSpacing.xxxl * 3,
                  width: double.infinity,
                  child: widget.illustrationWidget))),
            const SizedBox(height: AppSpacing.sm),

            // Productivity badge
            Opacity(opacity: _badgeFade.value,
              child: Transform.scale(scale: _badgeScale.value,
                child: const _ProductivityBadge())),
            const SizedBox(height: AppSpacing.sm),

            // Glass text card
            Opacity(opacity: _titleFade.value,
              child: Transform.translate(offset: Offset(0, _titleSlide.value),
                child: _GlassTextCard(subtitleOpacity: _subtitleFade.value))),
            const SizedBox(height: AppSpacing.md),

            // Feature cards — 2×2 grid
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: List.generate(_cards.length, (i) => Opacity(
                opacity: _cardFades[i].value,
                child: Transform.translate(
                  offset: Offset(0, _cardSlides[i].value),
                  child: _FeatureCard(
                      emoji: _cards[i].$1, label: _cards[i].$2),
                ),
              )),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ── Small logo chip ──────────────────────────────────────────────────────────

class _SmallLogoChip extends StatelessWidget {
  const _SmallLogoChip();
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(width: 28, height: 28,
        child: FittedBox(fit: BoxFit.contain, child: const AppLogoWidget())),
      const SizedBox(width: 8),
      Text('StudyFlow AI',
        style: AppTypography.labelLarge.copyWith(
          color: AppColors.onPrimary.withValues(alpha: 0.90),
          letterSpacing: 0.8)),
    ],
  );
}

// ── Productivity Boost badge ─────────────────────────────────────────────────

class _ProductivityBadge extends StatelessWidget {
  const _ProductivityBadge();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              AppColors.secondary.withValues(alpha: 0.25),
              AppColors.tertiary.withValues(alpha: 0.20),
            ]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.50), width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.28),
                  blurRadius: 12, spreadRadius: 1),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.tertiary, size: 13),
              const SizedBox(width: 5),
              Text('Productivity Boost',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.secondaryLight,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Glass text card ──────────────────────────────────────────────────────────

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
                color: Colors.white.withValues(alpha: 0.14), width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Stay Organized.\nAchieve More.',
                textAlign: TextAlign.center,
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.onPrimary,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w700,
                  height: 1.25)),
              const SizedBox(height: AppSpacing.sm),
              Opacity(opacity: subtitleOpacity,
                child: Text(
                  'Manage your study routine, monitor your academic progress, '
                  'complete tasks on time, and build consistent learning habits.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.72),
                    height: 1.55))),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Feature card ─────────────────────────────────────────────────────────────

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.emoji, required this.label});
  final String emoji;
  final String label;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 140,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.secondaryLight.withValues(alpha: 0.28),
                width: 1.0),
            boxShadow: [
              BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.18),
                  blurRadius: 10),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 7),
              Flexible(child: Text(label,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.onPrimary.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500))),
            ],
          ),
        ),
      ),
    );
  }
}

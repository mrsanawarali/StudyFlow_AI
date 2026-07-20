import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/features/onboarding/presentation/widgets/glass_nav_button.dart';
import 'package:untitled/features/onboarding/presentation/widgets/gradient_cta_button.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_1.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_2.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_3.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_4.dart';
import 'package:untitled/features/onboarding/presentation/widgets/onboarding_page1_widget.dart';
import 'package:untitled/features/onboarding/presentation/widgets/onboarding_page2_widget.dart';
import 'package:untitled/features/onboarding/presentation/widgets/onboarding_page3_widget.dart';
import 'package:untitled/features/onboarding/presentation/widgets/onboarding_page4_widget.dart';
import 'package:untitled/features/onboarding/presentation/widgets/founder_showcase_widget.dart';
import 'package:untitled/features/onboarding/presentation/widgets/premium_page_indicator.dart';
import 'package:untitled/features/splash/presentation/widgets/particle_layer.dart';
import 'package:untitled/shared/widgets/buttons/primary_button.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────

/// Compile-time descriptor for a single onboarding page.
/// No serialisation needed — data is static and never persisted.
class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;

  /// One of [OnboardingIllustration1]..[OnboardingIllustration4].
  final Widget illustration;
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // ── Page state ────────────────────────────────────────────────────────────
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isAnimating = false;

  // ── Illustration entrance animation (per-page) ────────────────────────────
  late final List<AnimationController> _illustrationControllers;
  static const Duration _illustrationFadeDuration = Duration(milliseconds: 400);

  // ── Particle layer controller (only active on page 1) ─────────────────────
  late final AnimationController _particleCtrl;

  // ── Page transition constants ─────────────────────────────────────────────
  static const Duration _pageAnimDuration = Duration(milliseconds: 350);
  static const Curve _pageAnimCurve = Curves.easeInOut;

  // ── Static page data ──────────────────────────────────────────────────────
  static final List<OnboardingPageData> _pages = [
    const OnboardingPageData(
      title: 'Study Smarter',
      description:
          'Organize your semesters, subjects, notes and study materials in one intelligent workspace.',
      illustration: OnboardingIllustration1(),
    ),
    const OnboardingPageData(
      title: 'Offline First',
      description: 'Work anywhere with secure offline storage and cloud sync.',
      illustration: OnboardingIllustration2(),
    ),
    const OnboardingPageData(
      title: 'AI Study Assistant',
      description: 'Generate notes, quizzes, summaries and flashcards with AI.',
      illustration: OnboardingIllustration3(),
    ),
    const OnboardingPageData(
      title: 'Stay Productive',
      description:
          'Manage assignments, quizzes, schedules and grades effortlessly.',
      illustration: OnboardingIllustration4(),
    ),
    // Page 5 — founder showcase (no illustration slot; handled specially)
    OnboardingPageData(
      title: 'Founder',
      description: '',
      illustration: Container(), // placeholder; page 5 renders its own full UI
    ),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);

    _illustrationControllers = List.generate(
      _pages.length,
      (_) => AnimationController(
        vsync: this,
        duration: _illustrationFadeDuration,
      ),
    );

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _illustrationControllers[0].forward();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    for (final c in _illustrationControllers) {
      c.dispose();
    }
    _particleCtrl.dispose();
    super.dispose();
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────

  void _onPageScroll() => setState(() {});

  Future<void> _nextPage() async {
    if (_isAnimating || _currentPage >= _pages.length - 1) return;
    setState(() => _isAnimating = true);
    await _pageController.animateToPage(
      _currentPage + 1,
      duration: _pageAnimDuration,
      curve: _pageAnimCurve,
    );
    if (!mounted) return;
    setState(() {
      _currentPage++;
      _isAnimating = false;
    });
    _onPageSettled(_currentPage);
  }

  Future<void> _prevPage() async {
    if (_isAnimating || _currentPage <= 0) return;
    setState(() => _isAnimating = true);
    await _pageController.animateToPage(
      _currentPage - 1,
      duration: _pageAnimDuration,
      curve: _pageAnimCurve,
    );
    if (!mounted) return;
    setState(() {
      _currentPage--;
      _isAnimating = false;
    });
    _onPageSettled(_currentPage);
  }

  void _onPageSettled(int index) {
    _illustrationControllers[index].reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _illustrationControllers[index].forward();
    });
  }

  void _navigateToLogin() => context.go(RoutePaths.login);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isPage1 = _currentPage == 0;
    final bool isPage2 = _currentPage == 1;
    final bool isPage3 = _currentPage == 2;
    final bool isPage4 = _currentPage == 3;
    final bool isPage5 = _currentPage == 4;
    final bool usePremiumCta = isPage1 || isPage2 || isPage3 || isPage4;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F2C),
        body: Stack(
          children: [
            // ── Gradient background (always) ─────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF0A0F2C),
                      Color(0xFF1A0A3C),
                    ],
                  ),
                ),
              ),
            ),

            // ── Particle layer (all pages) ───────────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: ParticleLayer(controller: _particleCtrl),
              ),
            ),

            // ── Main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // ── Top bar ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      children: [
                        if (_currentPage > 0)
                          GlassNavButton(
                            label: 'Back',
                            icon: Icons.arrow_back_ios_new_rounded,
                            onPressed: _isAnimating ? null : _prevPage,
                          )
                        else
                          // Invisible placeholder to keep Skip right-aligned
                          const SizedBox(width: 80),

                        const Spacer(),

                        if (_currentPage < 4)
                          GlassNavButton(
                            label: 'Skip',
                            onPressed: _navigateToLogin,
                          ),
                      ],
                    ),
                  ),

                  // ── PageView ───────────────────────────────────────────
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      itemBuilder: (ctx, i) {
                        final illuWidget = FadeTransition(
                          opacity: _illustrationControllers[i]
                              .drive(CurveTween(curve: Curves.easeIn)),
                          child: _pages[i].illustration,
                        );

                        // Page 1 gets the premium layout widget
                        if (i == 0) {
                          return OnboardingPage1Widget(
                            illustrationWidget: illuWidget,
                          );
                        }

                        // Page 2 gets the premium offline-first layout widget
                        if (i == 1) {
                          return OnboardingPage2Widget(
                            illustrationWidget: illuWidget,
                          );
                        }

                        // Page 3 gets the premium AI assistant layout widget
                        if (i == 2) {
                          return OnboardingPage3Widget(
                            illustrationWidget: illuWidget,
                          );
                        }

                        // Page 4 gets the premium productivity layout widget
                        if (i == 3) {
                          return OnboardingPage4Widget(
                            illustrationWidget: illuWidget,
                            onContinue: _nextPage,
                          );
                        }

                        // Page 5 — full-screen founder showcase
                        return FounderShowcaseWidget(
                          particleController: _particleCtrl,
                          onGetStarted: _navigateToLogin,
                        );
                      },
                    ),
                  ),

                  // ── Page indicator ─────────────────────────────────────
                  PremiumPageIndicator(
                    pageCount: _pages.length,
                    currentPage: _pageController.hasClients
                        ? (_pageController.page ?? 0.0)
                        : 0.0,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // ── CTA button (hidden on page 5 — has its own button) ──
                  if (!isPage5)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg),
                      child: usePremiumCta
                          ? GradientCtaButton(
                              text: isPage4 ? 'Continue' : 'Next',
                              onPressed: _isAnimating
                                  ? null
                                  : (isPage4 ? _nextPage : _nextPage),
                            )
                          : PrimaryButton(
                              text: _currentPage < 3 ? 'Next' : 'Get Started',
                              onPressed: _isAnimating
                                  ? null
                                  : (_currentPage < 3
                                      ? _nextPage
                                      : _navigateToLogin),
                            ),
                    ),

                  if (!isPage5) const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

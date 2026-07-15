import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:untitled/config/routing/route_paths.dart';
import 'package:untitled/config/theme/app_colors.dart';
import 'package:untitled/config/theme/app_spacing.dart';
import 'package:untitled/config/theme/app_typography.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_1.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_2.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_3.dart';
import 'package:untitled/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_4.dart';
import 'package:untitled/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:untitled/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:untitled/shared/widgets/buttons/primary_button.dart';
import 'package:untitled/shared/widgets/buttons/secondary_button.dart';

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

  // ── Page transition constants ─────────────────────────────────────────────
  static const Duration _pageAnimDuration = Duration(milliseconds: 350);
  static const Curve _pageAnimCurve = Curves.easeInOut;

  // ── Static page data ──────────────────────────────────────────────────────
  static final List<OnboardingPageData> _pages = [
    const OnboardingPageData(
      title: 'Study Smarter',
      description: 'Organize semesters, subjects and notes in one place.',
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
    // Play illustration entrance animation for the first page once the first
    // frame has been laid out.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) _illustrationControllers[0].forward();
      },
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    for (final c in _illustrationControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Callbacks ─────────────────────────────────────────────────────────────

  /// Drives [PageIndicator] with continuous fractional progress while the user
  /// swipes between pages.
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

  /// Resets then plays the illustration entrance animation for [index] on the
  /// next frame so the page has fully settled before the fade begins.
  void _onPageSettled(int index) {
    _illustrationControllers[index].reset();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) _illustrationControllers[index].forward();
      },
    );
  }

  void _navigateToLogin() => context.go(RoutePaths.login);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top bar ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (_currentPage > 0)
                      SecondaryButton(
                        text: 'Back',
                        width: 100,
                        onPressed: _isAnimating ? null : _prevPage,
                      ),
                    const Spacer(),
                    if (_currentPage < 3)
                      TextButton(
                        onPressed: _navigateToLogin,
                        child: Text(
                          'Skip',
                          style: AppTypography.labelLarge.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── PageView ────────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  itemBuilder: (ctx, i) => OnboardingPageWidget(
                    illustrationWidget: FadeTransition(
                      opacity: _illustrationControllers[i]
                          .drive(CurveTween(curve: Curves.easeIn)),
                      child: _pages[i].illustration,
                    ),
                    title: _pages[i].title,
                    description: _pages[i].description,
                  ),
                ),
              ),

              // ── Page indicator ───────────────────────────────────────────
              PageIndicator(
                pageCount: _pages.length,
                currentPage: _pageController.hasClients
                    ? (_pageController.page ?? 0.0)
                    : 0.0,
              ),

              const SizedBox(height: AppSpacing.md),

              // ── Primary action button ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: PrimaryButton(
                  text: _currentPage < 3 ? 'Next' : 'Get Started',
                  onPressed: _isAnimating
                      ? null
                      : (_currentPage < 3 ? _nextPage : _navigateToLogin),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

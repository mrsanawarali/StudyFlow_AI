# Implementation Plan: splash-onboarding-ui

## Overview

Implements a branded animated splash screen and a four-page onboarding flow as pure-presentation Clean Architecture feature modules. All visuals are rendered via `CustomPaint`; no image assets or new packages are introduced. The existing `GoRouter` receives one new route (`/onboarding`). The plan proceeds from leaf widgets inward to screens, ending with router wiring and a static-analysis verification pass.

---

## Tasks

- [ ] 1. Create illustration widgets (Wave 0 — no dependencies)

  - [x] 1.1 Create `onboarding_illustration_1.dart` — "Study Smarter" motif
    - File: `lib/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_1.dart`
    - Export `OnboardingIllustration1` as a `StatelessWidget` wrapping `CustomPaint` with `_StudySmarterPainter`.
    - `_StudySmarterPainter.paint()`: draw stacked book layers (pages, spines) using `AppColors.secondary`; floating document/page shapes as accent using `AppColors.tertiary`. Express all coordinates as fractions of `size` for scale-independence.
    - Widget `build()` returns `SizedBox(height: AppSpacing.xxxl * 3, width: double.infinity, child: CustomPaint(painter: _StudySmarterPainter()))`.
    - `shouldRepaint` returns `false`.
    - No imports from `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`.
    - _Requirements: 2.7, 7.5, 7.8_

  - [x] 1.2 Create `onboarding_illustration_2.dart` — "Offline First" motif
    - File: `lib/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_2.dart`
    - Export `OnboardingIllustration2` wrapping `_OfflineFirstPainter`.
    - `_OfflineFirstPainter.paint()`: draw a cloud outline with a shield overlay in `AppColors.secondary`; sync/circular arrows and accent fills in `AppColors.tertiary`.
    - Same `SizedBox` dimensions and fraction-based coordinate rules as 1.1.
    - `shouldRepaint` returns `false`.
    - _Requirements: 2.7, 7.5, 7.8_

  - [x] 1.3 Create `onboarding_illustration_3.dart` — "AI Study Assistant" motif
    - File: `lib/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_3.dart`
    - Export `OnboardingIllustration3` wrapping `_AIAssistantPainter`.
    - `_AIAssistantPainter.paint()`: draw a hexagonal circuit grid in `AppColors.secondary`; a lightning-bolt spark with radiating rays in `AppColors.tertiary`.
    - Same `SizedBox` dimensions and fraction-based coordinate rules as 1.1.
    - `shouldRepaint` returns `false`.
    - _Requirements: 2.7, 7.5, 7.8_

  - [x] 1.4 Create `onboarding_illustration_4.dart` — "Stay Productive" motif
    - File: `lib/features/onboarding/presentation/widgets/illustrations/onboarding_illustration_4.dart`
    - Export `OnboardingIllustration4` wrapping `_StayProductivePainter`.
    - `_StayProductivePainter.paint()`: draw a calendar grid in `AppColors.secondary`; three horizontal checklist rows with tick marks in `AppColors.tertiary`.
    - Same `SizedBox` dimensions and fraction-based coordinate rules as 1.1.
    - `shouldRepaint` returns `false`.
    - _Requirements: 2.7, 7.5, 7.8_

- [x] 2. Create reusable onboarding widgets (Wave 1 — depends on illustrations)

  - [x] 2.1 Create `onboarding_page_widget.dart`
    - File: `lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart`
    - Export `OnboardingPageWidget` as a `StatelessWidget` with required named parameters: `Widget illustrationWidget`, `String title`, `String description`.
    - `build()` returns a `Padding` with `EdgeInsets.symmetric(horizontal: AppSpacing.lg)` containing a `Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center)` with:
      - `SizedBox(height: AppSpacing.xxxl * 3, width: double.infinity, child: illustrationWidget)`
      - `SizedBox(height: AppSpacing.xxl)`
      - `Text(title, textAlign: TextAlign.center, style: AppTypography.headlineMedium.copyWith(color: AppColors.primary))`
      - `SizedBox(height: AppSpacing.md)`
      - `Text(description, textAlign: TextAlign.center, style: AppTypography.bodyLarge.copyWith(color: AppColors.onSurfaceVariant))`
    - No hardcoded `double` literals for spacing or color.
    - _Requirements: 2.2, 5.1, 5.2, 5.3, 7.3, 7.8_

  - [ ]* 2.2 Write property test for `OnboardingPageWidget` content rendering
    - File: `test/features/onboarding/onboarding_page_widget_test.dart`
    - **Property 4: OnboardingPageWidget renders all content for any valid page data**
    - For any non-empty `title` and `description` string, pump `OnboardingPageWidget` and assert: a `CustomPaint` descendant exists, a `Text` widget with `AppTypography.headlineMedium` color `AppColors.primary` contains `title`, and a `Text` widget with `AppTypography.bodyLarge` color `AppColors.onSurfaceVariant` contains `description`.
    - Use `flutter_test` only (no new packages).
    - Tag comment: `// Feature: splash-onboarding-ui, Property 4: OnboardingPageWidget renders all content for any valid page data`
    - **Validates: Requirements 2.2**

  - [x] 2.3 Create `page_indicator.dart`
    - File: `lib/features/onboarding/presentation/widgets/page_indicator.dart`
    - Export `PageIndicator` as a `StatelessWidget` with required named parameters: `int pageCount`, `double currentPage`.
    - Constants (defined at top of class): `_dotHeight = 8.0`, `_activeDotWidth = 24.0`, `_inactiveDotWidth = 8.0`, `_dotAnimDuration = Duration(milliseconds: 300)`.
    - `build()` returns `Row(mainAxisAlignment: MainAxisAlignment.center)` with `List.generate(pageCount, ...)` children.
    - Each child: `Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs), child: AnimatedContainer(duration: _dotAnimDuration, width: isActive ? _activeDotWidth : _inactiveDotWidth, height: _dotHeight, decoration: BoxDecoration(color: isActive ? AppColors.secondary.withValues(alpha: 1.0) : AppColors.outline.withValues(alpha: 0.4), borderRadius: AppRadius.roundedFull)))`.
    - `isActive` is `index == currentPage.round()`.
    - No hardcoded color literals or raw `double` padding values.
    - _Requirements: 3.8, 3.9, 4.3, 5.1, 5.3, 5.4, 7.4_

  - [ ]* 2.4 Write property tests for `PageIndicator` dot state
    - File: `test/features/onboarding/page_indicator_test.dart`
    - **Property 5: PageIndicator active dot state corresponds to rounded page value**
    - For each integer `currentPage` in `{0, 1, 2, 3}`, pump `PageIndicator(pageCount: 4, currentPage: currentPage.toDouble())` and assert exactly one `AnimatedContainer` has `width == 24.0` and three have `width == 8.0`.
    - **Property 1: Skip button visibility is the inverse of page 4**
    - **Property 2: Back button visibility is the inverse of page 1**
    - (Properties 1 & 2 will be re-exercised in task 4.2 against `OnboardingScreen`; stub the test file here so it exists as the designated test file per the design's testing strategy.)
    - Use `flutter_test` only.
    - Tag comment: `// Feature: splash-onboarding-ui, Property 5: PageIndicator active dot state corresponds to rounded page value`
    - **Validates: Requirements 3.8, 3.9**

- [x] 3. Create `AppLogoWidget` (Wave 2 — independent)

  - [x] 3.1 Create `app_logo_widget.dart`
    - File: `lib/features/splash/presentation/widgets/app_logo_widget.dart`
    - Export `AppLogoWidget` as a `StatelessWidget`. Private `_AppLogoPainter extends CustomPainter`.
    - `build()` returns `SizedBox(width: 80.0, height: 80.0, child: CustomPaint(painter: _AppLogoPainter()))`.
    - `_AppLogoPainter.paint()`: draw a stylised open book — left page fill in `AppColors.secondary`, right page fill in `AppColors.tertiary`; a spark/lightning-bolt accent above centre in `AppColors.tertiary`. All coordinates expressed as fractions of `size`.
    - `shouldRepaint` returns `false`.
    - No imports from `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`.
    - _Requirements: 1.5, 7.6, 7.7_

- [x] 4. Create feature screens (Wave 3 — depends on illustrations, widgets, logo)

  - [x] 4.1 Create `splash_screen.dart`
    - File: `lib/features/splash/presentation/screens/splash_screen.dart`
    - Export `SplashScreen extends StatefulWidget` / `_SplashScreenState with SingleTickerProviderStateMixin`.
    - Declare named duration constants: `static const Duration _animationDuration = Duration(milliseconds: 1300)` and `static const Duration _splashDelay = Duration(milliseconds: 2500)`.
    - `initState`: create `_controller` with duration `_animationDuration`; build four `CurvedAnimation`/`Tween` animations using `Interval` with `Curves.easeOut`:
      - `_logoOpacity`: `Interval(0.00, 0.46)` — `Tween<double>(begin: 0, end: 1)`
      - `_logoScale`: `Interval(0.00, 0.46)` — `Tween<double>(begin: 0.6, end: 1.0)`
      - `_brandOpacity`: `Interval(0.46, 0.77)` — `Tween<double>(begin: 0, end: 1)`
      - `_taglineOpacity`: `Interval(0.77, 1.00)` — `Tween<double>(begin: 0, end: 1)`
    - Start `_controller.forward()` in `initState`; schedule `_navTimer = Timer(_splashDelay, _onTimerFired)`.
    - `_onTimerFired`: call `context.go(RoutePaths.onboarding)`.
    - `dispose`: cancel `_navTimer`, dispose `_controller`.
    - `build()`: `Scaffold(backgroundColor: Colors.transparent, body: Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.primary, AppColors.primaryLight])), child: SafeArea(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [FadeTransition(opacity: _logoOpacity, child: ScaleTransition(scale: _logoScale, child: const AppLogoWidget())), SizedBox(height: AppSpacing.lg), FadeTransition(opacity: _brandOpacity, child: Text('StudyFlow AI', style: AppTypography.headlineLarge.copyWith(color: AppColors.onPrimary))), SizedBox(height: AppSpacing.xs), FadeTransition(opacity: _taglineOpacity, child: Opacity(opacity: 0.85, child: Text('Transform Your Study Journey', style: AppTypography.bodyLarge.copyWith(color: AppColors.onPrimary))))])))))`.
    - Import `dart:async` for `Timer`; import `package:go_router/go_router.dart`; import `AppLogoWidget`, `AppColors`, `AppTypography`, `AppSpacing`, `RoutePaths`.
    - No imports from `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`.
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 6.1, 6.2, 7.1, 7.7_

  - [x] 4.2 Create `onboarding_screen.dart`
    - File: `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
    - Export `OnboardingScreen extends StatefulWidget` / `_OnboardingScreenState with TickerProviderStateMixin`.
    - Declare `OnboardingPageData` value-class (title, description, illustration Widget) in the same file.
    - Declare `static final List<OnboardingPageData> _pages` with exactly four entries matching the design's static list (titles: "Study Smarter", "Offline First", "AI Study Assistant", "Stay Productive"; descriptions per Reqs 2.3–2.6; illustrations: `OnboardingIllustration1`…`4`).
    - State fields: `late final PageController _pageController`, `int _currentPage = 0`, `bool _isAnimating = false`, `late final List<AnimationController> _illustrationControllers`.
    - Animation constants: `static const Duration _illustrationFadeDuration = Duration(milliseconds: 400)`, `static const Duration _pageAnimDuration = Duration(milliseconds: 350)`, `static const Curve _pageAnimCurve = Curves.easeInOut`.
    - `initState`: initialise `_pageController`, call `_pageController.addListener(_onPageScroll)`, generate `_illustrationControllers` (one per page, duration `_illustrationFadeDuration`), use `WidgetsBinding.instance.addPostFrameCallback` to call `_illustrationControllers[0].forward()`.
    - `dispose`: `removeListener`, `dispose` page controller, dispose all illustration controllers.
    - `_onPageScroll`: `setState(() {})`.
    - `_nextPage` / `_prevPage`: guard with `_isAnimating`, set `_isAnimating = true`, call `animateToPage`, update `_currentPage`, clear `_isAnimating`, call `_onPageSettled`.
    - `_onPageSettled(index)`: reset then forward `_illustrationControllers[index]` via `addPostFrameCallback`.
    - `_navigateToLogin`: `context.go(RoutePaths.login)`.
    - `build()`: `PopScope(canPop: false, child: Scaffold(backgroundColor: AppColors.background, body: SafeArea(child: Column(children: [_buildTopBar(), Expanded(child: PageView.builder(...)), PageIndicator(...), SizedBox(height: AppSpacing.md), _buildBottomButtons(), SizedBox(height: AppSpacing.xl)]))))`.
    - Top bar: `Row` with conditional `SecondaryButton(text: 'Back', width: 100, onPressed: ...)` (hidden on page 0), `Spacer()`, conditional `TextButton` Skip (hidden on page 3) styled with `AppTypography.labelLarge.copyWith(color: AppColors.secondary)`.
    - Bottom buttons: full-width `PrimaryButton(text: _currentPage < 3 ? 'Next' : 'Get Started', onPressed: ...)`.
    - `PageIndicator` receives `currentPage: _pageController.hasClients ? (_pageController.page ?? 0.0) : 0.0`.
    - Each page in `PageView.builder`: `OnboardingPageWidget(illustrationWidget: FadeTransition(opacity: _illustrationControllers[index], child: _pages[index].illustration), title: ..., description: ...)`.
    - Import `SecondaryButton`, `PrimaryButton`, `PageIndicator`, `OnboardingPageWidget`, all four `OnboardingIllustration` widgets, `AppColors`, `AppTypography`, `AppSpacing`, `RoutePaths`, `go_router`.
    - No imports from `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`.
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8, 3.9, 3.10, 3.11, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.5, 6.4, 6.6, 7.2, 7.8_

  - [ ]* 4.3 Write property tests for `OnboardingScreen` navigation control visibility
    - File: `test/features/onboarding/onboarding_screen_test.dart`
    - **Property 1: Skip button visibility is the inverse of page 4**
    - For each `currentPage` in `{0, 1, 2}`: pump `OnboardingScreen` pumped to that page (or use `_OnboardingScreenState` directly exposed via a test helper) and assert Skip `TextButton` is in the widget tree. For `currentPage = 3`, assert it is absent.
    - **Property 2: Back button visibility is the inverse of page 1**
    - For `currentPage` in `{1, 2, 3}`: assert `SecondaryButton` with text 'Back' is present. For `currentPage = 0`, assert it is absent.
    - **Property 3: Primary action button label depends only on current page**
    - For `currentPage` in `{0, 1, 2}`: assert `PrimaryButton` text is 'Next'. For `currentPage = 3`: assert text is 'Get Started'.
    - Tag comment: `// Feature: splash-onboarding-ui, Property 1/2/3`
    - Use `flutter_test` only.
    - **Validates: Requirements 3.1, 3.2, 3.3**

- [x] 5. Checkpoint — static analysis before router wiring
  - Ensure all tasks 1.1–4.2 compile without errors. Run `flutter analyze lib/features/` mentally by reviewing all imports in newly created files for correctness. Ask the user if any questions arise before proceeding to router wiring.

- [x] 6. Wire router (Wave 4 — depends on screens)

  - [x] 6.1 Update `app_router.dart` to add `/onboarding` route
    - File: `lib/config/routing/app_router.dart` (**modify existing file only**).
    - Add import: `import '../../features/onboarding/presentation/screens/onboarding_screen.dart';`
    - Inside `createRouter()`, in the `routes` list, insert after the `splash` `GoRoute` and before the `login` `GoRoute`:
      ```dart
      GoRoute(
        path: RoutePaths.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ```
    - Do **not** remove or modify any existing `GoRoute` entries (`splash`, `login`, `signup`, `home`).
    - Do **not** change `initialLocation`, `debugLogDiagnostics`, or `errorBuilder`.
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 7.1_

- [x] 7. Run `flutter analyze` and fix all reported errors (Wave 5)

  - [x] 7.1 Analyze and fix all errors in new feature files
    - Run `flutter analyze lib/features/splash lib/features/onboarding lib/config/routing/app_router.dart` from the `frontend/` directory.
    - Fix every **error-level** diagnostic reported. Common issues to check:
      - Missing imports (verify each newly created file imports all referenced types).
      - `withValues(alpha:)` usage — confirm the Flutter/Dart SDK version supports it; fall back to `withOpacity()` if not.
      - Unused imports or variables (`_isAnimating` must be read, not just set).
      - `AnimationController` passed to `FadeTransition` must be of type `Animation<double>` — use `.drive(Tween(...))` or `CurvedAnimation` appropriately.
      - `PopScope` API: use `onPopInvokedWithResult` if `onPopInvoked` is deprecated in the project's Flutter SDK version.
      - Ensure `_illustrationControllers[index]` passed to `FadeTransition.opacity` is wrapped: `_illustrationControllers[index].drive(Tween<double>(begin: 0.0, end: 1.0))` or equivalent `Animation<double>`.
    - The analysis SHALL report zero error-level diagnostics after all fixes are applied.
    - _Requirements: 7.9_

- [x] 8. Final checkpoint
  - Ensure all tests pass and `flutter analyze` reports zero errors. Ask the user if any questions arise.

---

## Notes

- Tasks marked with `*` are optional and can be skipped for an MVP build.
- All new files live exclusively under `lib/features/splash/` or `lib/features/onboarding/` — nothing under `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/` is touched.
- Only one existing file is modified: `lib/config/routing/app_router.dart` (task 6.1).
- All design tokens come from `AppColors`, `AppTypography`, `AppSpacing`, and `AppRadius` — no hardcoded literals.
- `PrimaryButton` and `SecondaryButton` are imported from `lib/shared/widgets/buttons/`.
- `RoutePaths.onboarding = '/onboarding'` already exists in `route_paths.dart` — no changes needed there.
- The `fast_check` package referenced in the design's testing strategy is not in `pubspec.yaml`; property tests use parameterised widget tests with `flutter_test` instead, iterating over the finite domain `{0, 1, 2, 3}` inline.

---

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3", "1.4"] },
    { "id": 1, "tasks": ["2.1", "2.3", "3.1"] },
    { "id": 2, "tasks": ["2.2", "2.4", "4.1", "4.2"] },
    { "id": 3, "tasks": ["4.3", "6.1"] },
    { "id": 4, "tasks": ["7.1"] }
  ]
}
```

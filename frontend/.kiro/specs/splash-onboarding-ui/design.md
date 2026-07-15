# Design Document — splash-onboarding-ui

## Overview

Phase 2A adds a branded animated splash screen and a four-page onboarding flow to StudyFlow AI. Both features live entirely inside the `lib/features/` Clean Architecture modules and have no domain or data layers in this phase — they are pure presentation. All animations use Flutter's built-in `AnimationController` / `Tween` system; no external animation packages are added. All visuals — including the app logo and every per-page illustration — are rendered via `CustomPaint`, so no image assets are required.

The two features integrate into the existing `GoRouter` configuration by adding a single new route (`/onboarding`). The router's initial location remains `/` (splash), which uses `context.go()` to replace itself with `/onboarding`, and onboarding uses `context.go()` to replace itself with `/auth/login` — so neither screen appears in the back-stack after the user moves past it.

### Key design decisions

| Decision | Rationale |
|---|---|
| `Timer` inside `initState` for the 2500 ms splash delay | Simpler than a Future chain; cancels safely in `dispose`. |
| `_isAnimating` bool guard for button taps | Prevents double-navigation without needing a more complex state machine. |
| `PageController.addListener` → `setState` for indicator | Gives continuous fractional interpolation during swipe gestures, fulfilling Req 4.3. |
| `PopScope(canPop: false)` wrapping `OnboardingScreen` | Blocks the system back button per Req 6.6 without a custom `NavigatorObserver`. |
| Static `List<OnboardingPageData>` defined in `onboarding_screen.dart` | No domain layer needed; data is compile-time constant content. |
| `addPostFrameCallback` for illustration entrance animation | Guarantees the page has settled before the 400 ms fade starts, per Req 4.4. |

---

## Architecture

The feature follows the Feature-First variant of Clean Architecture. Only the **Presentation** layer is implemented in Phase 2A.

```
lib/
└── features/
    ├── splash/
    │   └── presentation/
    │       ├── screens/
    │       │   └── splash_screen.dart          ← SplashScreen (StatefulWidget)
    │       └── widgets/
    │           └── app_logo_widget.dart         ← AppLogoWidget (StatelessWidget)
    └── onboarding/
        └── presentation/
            ├── screens/
            │   └── onboarding_screen.dart       ← OnboardingScreen (StatefulWidget)
            └── widgets/
                ├── onboarding_page_widget.dart  ← OnboardingPageWidget (StatelessWidget)
                ├── page_indicator.dart          ← PageIndicator (StatelessWidget)
                └── illustrations/
                    ├── onboarding_illustration_1.dart
                    ├── onboarding_illustration_2.dart
                    ├── onboarding_illustration_3.dart
                    └── onboarding_illustration_4.dart
```

**No additions** to `lib/domain/`, `lib/data/`, `lib/repositories/`, or `lib/screens/` are made.

### Dependency graph (presentation layer only)

```
OnboardingScreen
  ├── OnboardingPageWidget (×4, inside PageView)
  │     ├── OnboardingIllustration1..4 (CustomPaint)
  │     └── Text (title, description)
  └── PageIndicator

SplashScreen
  └── AppLogoWidget (CustomPaint)
```

All widgets depend only on design-token files (`AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`) and the routing constants (`RoutePaths`). No Riverpod providers are introduced in Phase 2A.

---

## Components and Interfaces

### 1. `SplashScreen` — `lib/features/splash/presentation/screens/splash_screen.dart`

```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // ── Animation ──────────────────────────────────────────────────────────
  late final AnimationController _controller;

  // Total duration of the staggered entrance sequence
  static const Duration _animationDuration = Duration(milliseconds: 1300);

  // Intervals (normalised 0.0–1.0 over _animationDuration)
  late final Animation<double> _logoOpacity;   // [0.00, 0.46]
  late final Animation<double> _logoScale;     // [0.00, 0.46]
  late final Animation<double> _brandOpacity;  // [0.46, 0.77]
  late final Animation<double> _taglineOpacity;// [0.77, 1.00]

  // ── Timer ─────────────────────────────────────────────────────────────
  static const Duration _splashDelay = Duration(milliseconds: 2500);
  Timer? _navTimer;

  @override
  void initState() { ... }  // starts controller + schedules timer

  @override
  void dispose() { ... }    // cancels timer, disposes controller

  void _onTimerFired() => context.go(RoutePaths.onboarding);

  @override
  Widget build(BuildContext context) { ... }
}
```

**Widget tree:**

```
Scaffold(
  backgroundColor: transparent,
  body: Container(                         ← full-screen gradient
    decoration: BoxDecoration(
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
            FadeTransition(               ← _logoOpacity
              ScaleTransition(            ← _logoScale (0.6 → 1.0)
                AppLogoWidget(),          ← 80×80 dp CustomPaint
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            FadeTransition(               ← _brandOpacity
              Text('StudyFlow AI',
                style: AppTypography.headlineLarge
                  .copyWith(color: AppColors.onPrimary)),
            ),
            SizedBox(height: AppSpacing.xs),
            FadeTransition(               ← _taglineOpacity
              Opacity(opacity: 0.85,
                child: Text('Transform Your Study Journey',
                  style: AppTypography.bodyLarge
                    .copyWith(color: AppColors.onPrimary))),
            ),
          ],
        ),
      ),
    ),
  ),
)
```

**Animation intervals** (all driven by `_controller`, `CurvedAnimation` with `Curves.easeOut`):

| Element | Interval start | Interval end | Duration |
|---|---|---|---|
| Logo fade + scale | 0.00 | 0.46 | 600 ms |
| Brand text fade | 0.46 | 0.77 | 400 ms |
| Tagline fade | 0.77 | 1.00 | 300 ms |

`_logoScale` uses a `Tween<double>(begin: 0.6, end: 1.0)` so it starts at 60 % size.

---

### 2. `AppLogoWidget` — `lib/features/splash/presentation/widgets/app_logo_widget.dart`

```dart
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({super.key});

  static const double _size = 80.0; // 80×80 dp

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: CustomPaint(painter: _AppLogoPainter()),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draws a stylised open book with a spark/lightning bolt above it.
    // Left page uses AppColors.secondary; right page uses AppColors.tertiary.
    // The spark accent uses AppColors.tertiary.
    // All coordinates are expressed as fractions of `size` so the widget
    // scales correctly if the size constant is changed.
  }

  @override
  bool shouldRepaint(_AppLogoPainter old) => false;
}
```

The painter draws purely with `Canvas` paths using `Paint` objects initialised from `AppColors` constants — no images, no external packages.

---

### 3. `OnboardingScreen` — `lib/features/onboarding/presentation/screens/onboarding_screen.dart`

```dart
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  // ── Page state ─────────────────────────────────────────────────────────
  late final PageController _pageController;
  int _currentPage = 0;
  bool _isAnimating = false;

  // ── Illustration entrance animation (per-page) ──────────────────────
  late final List<AnimationController> _illustrationControllers;
  // One per page; only the controller for the settled page is played.
  static const Duration _illustrationFadeDuration = Duration(milliseconds: 400);

  // ── Page transition constants ────────────────────────────────────────
  static const Duration _pageAnimDuration = Duration(milliseconds: 350);
  static const Curve _pageAnimCurve = Curves.easeInOut;

  // ── Static page data ─────────────────────────────────────────────────
  static final List<OnboardingPageData> _pages = [ ... ]; // see Data Models

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPageScroll);
    _illustrationControllers = List.generate(
      _pages.length,
      (_) => AnimationController(vsync: this, duration: _illustrationFadeDuration),
    );
    // Play illustration for first page on first frame
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _illustrationControllers[0].forward(),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    for (final c in _illustrationControllers) { c.dispose(); }
    super.dispose();
  }

  void _onPageScroll() => setState(() {});   // drives PageIndicator

  Future<void> _nextPage() async {
    if (_isAnimating || _currentPage >= _pages.length - 1) return;
    setState(() => _isAnimating = true);
    await _pageController.animateToPage(
      _currentPage + 1,
      duration: _pageAnimDuration,
      curve: _pageAnimCurve,
    );
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
    setState(() {
      _currentPage--;
      _isAnimating = false;
    });
    _onPageSettled(_currentPage);
  }

  void _onPageSettled(int index) {
    _illustrationControllers[index].reset();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _illustrationControllers[index].forward(),
    );
  }

  void _navigateToLogin() => context.go(RoutePaths.login);

  @override
  Widget build(BuildContext context) { ... }
}
```

**Widget tree:**

```
PopScope(canPop: false,                          ← disables system back (Req 6.6)
  child: Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Column(
        children: [
          _TopBar(),                             ← Back + Spacer + Skip
          Expanded(
            child: PageView.builder(             ← PageController
              itemCount: 4,
              itemBuilder: (ctx, i) =>
                OnboardingPageWidget(
                  illustrationWidget:
                    FadeTransition(              ← _illustrationControllers[i]
                      child: _pages[i].illustration,
                    ),
                  title: _pages[i].title,
                  description: _pages[i].description,
                ),
            ),
          ),
          PageIndicator(
            pageCount: 4,
            currentPage: _pageController.hasClients
                ? (_pageController.page ?? 0.0) : 0.0,
          ),
          SizedBox(height: AppSpacing.md),
          _BottomButtons(),                      ← SecondaryButton (Back) + PrimaryButton (Next/Get Started)
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    ),
  ),
)
```

**Top bar sub-tree:**

```
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
  child: Row(
    children: [
      // Back button — hidden on page 0
      if (_currentPage > 0)
        SecondaryButton(
          text: 'Back', width: 100, onPressed: _isAnimating ? null : _prevPage),
      Spacer(),
      // Skip button — hidden on page 3
      if (_currentPage < 3)
        TextButton(
          onPressed: _navigateToLogin,
          child: Text('Skip',
            style: AppTypography.labelLarge
              .copyWith(color: AppColors.secondary))),
    ],
  ),
)
```

**Bottom buttons sub-tree:**

```
Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  child: _currentPage < 3
    ? PrimaryButton(
        text: 'Next',
        onPressed: _isAnimating ? null : _nextPage)
    : PrimaryButton(
        text: 'Get Started',
        onPressed: _isAnimating ? null : _navigateToLogin),
)
```

---

### 4. `OnboardingPageWidget` — `lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart`

```dart
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.illustrationWidget,  // pre-wrapped in FadeTransition by host
    required this.title,
    required this.description,
  });

  final Widget illustrationWidget;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: AppSpacing.xxxl * 3,   // 192 dp
            width: double.infinity,
            child: illustrationWidget,
          ),
          SizedBox(height: AppSpacing.xxl),
          Text(title,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium
              .copyWith(color: AppColors.primary)),
          SizedBox(height: AppSpacing.md),
          Text(description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge
              .copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
```

---

### 5. `PageIndicator` — `lib/features/onboarding/presentation/widgets/page_indicator.dart`

```dart
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,   // double from PageController.page
  });

  final int pageCount;
  final double currentPage;

  static const double _dotHeight = 8.0;          // AppSpacing.sm
  static const double _activeDotWidth = 24.0;
  static const double _inactiveDotWidth = 8.0;   // AppSpacing.sm
  static const Duration _dotAnimDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final bool isActive = index == currentPage.round();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: AnimatedContainer(
            duration: _dotAnimDuration,
            width: isActive ? _activeDotWidth : _inactiveDotWidth,
            height: _dotHeight,
            decoration: BoxDecoration(
              color: isActive
                ? AppColors.secondary.withValues(alpha: 1.0)
                : AppColors.outline.withValues(alpha: 0.4),
              borderRadius: AppRadius.roundedFull,
            ),
          ),
        );
      }),
    );
  }
}
```

> **Note on fractional interpolation (Req 4.3):** `currentPage` is the raw `double` from `PageController.page`. `isActive` uses `.round()` so that during a swipe the active dot switches at the midpoint, while the `AnimatedContainer` provides smooth width/colour transitions. This gives continuous visual feedback throughout the gesture.

---

### 6. Illustration widgets — `lib/features/onboarding/presentation/widgets/illustrations/`

Each file exports a single `StatelessWidget` that wraps a dedicated `CustomPainter`. The painters share **no** base class — each is fully independent as required by Req 2.7.

| File | Widget | Painter | Visual motif |
|---|---|---|---|
| `onboarding_illustration_1.dart` | `OnboardingIllustration1` | `_StudySmarterPainter` | Stacked book layers in `AppColors.secondary` with floating document shapes in `AppColors.tertiary` |
| `onboarding_illustration_2.dart` | `OnboardingIllustration2` | `_OfflineFirstPainter` | Cloud outline with shield overlay; sync arrows in `AppColors.secondary`; accent fill in `AppColors.tertiary` |
| `onboarding_illustration_3.dart` | `OnboardingIllustration3` | `_AIAssistantPainter` | Hexagonal circuit grid in `AppColors.secondary`; lightning-bolt spark in `AppColors.tertiary`; spark rays |
| `onboarding_illustration_4.dart` | `OnboardingIllustration4` | `_StayProductivePainter` | Calendar grid in `AppColors.secondary`; three checklist rows with tick marks in `AppColors.tertiary` |

Common pattern for each:

```dart
// onboarding_illustration_N.dart
class OnboardingIllustrationN extends StatelessWidget {
  const OnboardingIllustrationN({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.xxxl * 3,  // 192 dp (matches host constraint)
      width: double.infinity,
      child: CustomPaint(painter: _IllustrationNPainter()),
    );
  }
}

class _IllustrationNPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) { ... }

  @override
  bool shouldRepaint(_IllustrationNPainter old) => false;
}
```

All drawing uses `AppColors` constants. No raster assets, SVG files, or shared painter utilities.

---

### 7. Router update — `lib/config/routing/app_router.dart`

The existing `createRouter()` function receives one new `GoRoute` entry. All existing routes are preserved without modification.

```dart
GoRoute(
  path: RoutePaths.onboarding,
  name: 'onboarding',
  builder: (context, state) => const OnboardingScreen(),
),
```

`OnboardingScreen` wraps its entire body in `PopScope(canPop: false)` rather than the router setting `redirect`, because the no-back requirement is a UI behaviour of the screen itself rather than an authentication guard.

The splash screen navigates with `context.go(RoutePaths.onboarding)`, which **replaces** the history entry — splash is never on the back-stack when onboarding is shown. Onboarding navigates with `context.go(RoutePaths.login)` for the same reason.

---

## Data Models

```dart
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
  final Widget illustration;  // one of OnboardingIllustration1..4
}
```

Static list defined in `_OnboardingScreenState`:

```dart
static final List<OnboardingPageData> _pages = [
  OnboardingPageData(
    title: 'Study Smarter',
    description: 'Organize semesters, subjects and notes in one place.',
    illustration: const OnboardingIllustration1(),
  ),
  OnboardingPageData(
    title: 'Offline First',
    description: 'Work anywhere with secure offline storage and cloud sync.',
    illustration: const OnboardingIllustration2(),
  ),
  OnboardingPageData(
    title: 'AI Study Assistant',
    description: 'Generate notes, quizzes, summaries and flashcards with AI.',
    illustration: const OnboardingIllustration3(),
  ),
  OnboardingPageData(
    title: 'Stay Productive',
    description: 'Manage assignments, quizzes, schedules and grades effortlessly.',
    illustration: const OnboardingIllustration4(),
  ),
];
```

`_pages` is `static final` so Flutter never reconstructs it across hot-reloads.

---

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system — essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

The prework analysis identified several acceptance criteria that are universally quantified over inputs and are therefore suitable for property-based testing. Infrastructure, layout, and exact-match criteria are classified as smoke or example tests and covered in the Testing Strategy section below.

**Property reflection:** Properties 1 and 2 (Skip/Back visibility) are complementary but distinct — one covers Skip, one covers Back, each with its own visibility inversion rule. They cannot be merged without losing clarity. Properties 3 and 5 (button label and page indicator active state) are both functions of `currentPage` but test entirely different widgets. No redundancies identified; all five properties provide unique validation value.

---

### Property 1: Skip button visibility is the inverse of page 4

*For any* `currentPage` value in `{0, 1, 2}`, the Skip button SHALL be present and tappable in the widget tree. For `currentPage = 3`, the Skip button SHALL be absent from the widget tree.

**Validates: Requirements 3.1**

---

### Property 2: Back button visibility is the inverse of page 1

*For any* `currentPage` value in `{1, 2, 3}`, the Back button SHALL be present and tappable in the widget tree. For `currentPage = 0`, the Back button SHALL be absent from the widget tree.

**Validates: Requirements 3.2**

---

### Property 3: Primary action button label depends only on current page

*For any* `currentPage` value in `{0, 1, 2}`, the primary action button SHALL display the label "Next". For `currentPage = 3`, the primary action button SHALL display the label "Get Started".

**Validates: Requirements 3.3**

---

### Property 4: OnboardingPageWidget renders all content for any valid page data

*For any* non-empty `title` string and non-empty `description` string passed to `OnboardingPageWidget`, the rendered widget tree SHALL contain: a `CustomPaint` descendant (illustration), a `Text` widget with `AppTypography.headlineMedium` color `AppColors.primary` carrying the title, and a `Text` widget with `AppTypography.bodyLarge` color `AppColors.onSurfaceVariant` carrying the description.

**Validates: Requirements 2.2**

---

### Property 5: PageIndicator active dot state corresponds to rounded page value

*For any* integer `currentPage` in `{0, 1, 2, 3}`, the `PageIndicator` widget SHALL render exactly one `AnimatedContainer` with width 24 dp and color `AppColors.secondary` at opacity 1.0 (the dot at `currentPage`), and all remaining three dots SHALL have width 8 dp and color `AppColors.outline` at opacity 0.4.

**Validates: Requirements 3.8**

---

## Error Handling

Because Phase 2A is pure presentation with no network calls or I/O, the error surface is minimal:

| Scenario | Handling |
|---|---|
| `context.go()` called after widget is unmounted | The `_navTimer` is cancelled in `dispose()`, so the callback is never invoked if the widget is removed before 2500 ms. `_isAnimating` guard also prevents double-fire from button callbacks. |
| `PageController.page` is `null` before first layout | `PageIndicator` receives `_pageController.hasClients ? (_pageController.page ?? 0.0) : 0.0`, defaulting to page 0 until the controller attaches. |
| Illustration animation controller accessed after dispose | `_illustrationControllers` are disposed inside `_OnboardingScreenState.dispose()`. The `addPostFrameCallback` callback checks `mounted` before calling `.forward()`. |
| Rapid button taps | `_isAnimating` bool is set to `true` at the start of `_nextPage()` / `_prevPage()` and only cleared after `animateToPage` resolves. Any tap while `_isAnimating == true` returns early with no state mutation. |
| System back press on OnboardingScreen | `PopScope(canPop: false)` intercepts the gesture and returns `false` from `onPopInvokedWithResult`, keeping the user on the screen. |

No `try/catch` blocks are needed — all operations are synchronous widget state mutations or awaited `Future`s from the Flutter framework that do not throw under normal operation.

---

## Testing Strategy

### Property-based testing

The feature involves pure presentation logic where several behaviors are universally quantified over small finite input domains (page index 0–3, arbitrary strings). The `dart_test` + `test` package is used. Because all inputs are from finite sets or can be generated with simple string generators, PBT is applied using the **`fast_check`** (or equivalent Dart PBT library) with a minimum of **100 iterations per property**.

Each property test is tagged with:
`// Feature: splash-onboarding-ui, Property N: <property text>`

| Property | Test file | Generator |
|---|---|---|
| P1 — Skip visibility | `test/features/onboarding/page_indicator_test.dart` | `integer(0, 3)` for currentPage |
| P2 — Back visibility | `test/features/onboarding/page_indicator_test.dart` | `integer(0, 3)` |
| P3 — Button label | `test/features/onboarding/onboarding_screen_test.dart` | `integer(0, 3)` |
| P4 — PageWidget content | `test/features/onboarding/onboarding_page_widget_test.dart` | `string()` for title and description |
| P5 — Indicator active dot | `test/features/onboarding/page_indicator_test.dart` | `integer(0, 3)` |

### Unit / widget example tests

These cover specific behaviors identified as EXAMPLE or EDGE_CASE in the prework analysis:

| Test | Category | What it checks |
|---|---|---|
| Splash gradient background rendered | SMOKE | `Container` with `LinearGradient` present |
| "StudyFlow AI" text with correct style | EXAMPLE | `find.text('StudyFlow AI')`, style snapshot |
| Tagline text with 0.85 opacity wrapper | EXAMPLE | `find.text('Transform Your Study Journey')`, `Opacity` ancestor |
| `AppLogoWidget` is a `CustomPaint` | SMOKE | `find.byType(CustomPaint)` on splash |
| Timer fires navigation at 2500 ms | EXAMPLE | `fakeAsync`, advance 2500 ms, verify `context.go` called with `RoutePaths.onboarding` |
| Timer does not fire before 2500 ms (animation completes first) | EDGE_CASE | Advance to 1400 ms (animation done), verify no navigation; advance to 2500 ms, verify navigation |
| Onboarding page 1..4 correct titles and descriptions | EXAMPLE | 4 widget tests, each verifying exact strings |
| Illustration widgets have 192 dp height | EXAMPLE | `find.byType(CustomPaint)`, verify render box height |
| Next tap advances page when not animating | EXAMPLE | Tap Next on page 0, verify `PageController.page == 1` |
| Tap Next during animation is ignored | EXAMPLE | Set `_isAnimating = true`, tap Next, verify no second `animateToPage` call |
| Back tap retreats page when not animating | EXAMPLE | Navigate to page 1, tap Back, verify page 0 |
| Skip tap navigates to `/auth/login` | EXAMPLE | Tap Skip, verify `GoRouter` received `go('/auth/login')` |
| "Get Started" navigates to `/auth/login` | EXAMPLE | Navigate to page 3, tap Get Started, verify navigation |
| `AnimatedContainer` duration is 300 ms | EXAMPLE | Widget test inspecting `PageIndicator`'s `AnimatedContainer.duration` |
| Page transition duration/curve constants | EXAMPLE | Unit test on const values: `_pageAnimDuration == 350ms`, `_pageAnimCurve == Curves.easeInOut` |
| Illustration fade plays on page settle | EXAMPLE | `addPostFrameCallback` mock; verify controller `.forward()` called after page change |
| System back blocked on onboarding | EXAMPLE | `await tester.pageBack()`, verify still on `OnboardingScreen` |
| `/onboarding` route resolves to `OnboardingScreen` | SMOKE | Router unit test: `GoRouter.go('/onboarding')`, verify route builder returns `OnboardingScreen` |
| All pre-existing routes still resolve | SMOKE | Router unit test for `/`, `/auth/login`, `/auth/signup`, `/app/home` |
| `flutter analyze` produces zero errors | SMOKE | CI step: `flutter analyze lib/features/splash lib/features/onboarding` |

### Integration

No network calls, databases, or platform channels are involved in Phase 2A, so no integration tests are required at this stage.

### Design system compliance (static)

The no-hardcoded-literals requirement (Reqs 5.1–5.4) is enforced at code review time and by `flutter analyze` (custom lint rules, if `custom_lint` is already configured, or manual grep for `Color(0x`, `fontSize:`, `BorderRadius.circular(`). This is a SMOKE-level check, not a runtime test.

---

# Requirements Document

## Introduction

Phase 2A adds a premium animated splash screen and a multi-page onboarding flow to the StudyFlow AI Flutter mobile application. Both features are implemented inside the Clean Architecture feature modules (`lib/features/splash/` and `lib/features/onboarding/`), leaving all legacy screens under `lib/screens/` completely untouched. The splash screen presents the app brand on launch and auto-navigates to onboarding. The onboarding flow guides new users through four benefit-focused pages before routing them to the existing login screen. All UI is built exclusively with Flutter's built-in animation system, the app's Material 3 design tokens, and self-contained custom-painted illustration widgets — no new packages, no image assets, no backend calls.

---

## Glossary

- **Splash_Screen**: The full-screen entry widget rendered at route `/` that displays the app logo, brand name, and tagline with entrance animations before auto-navigating.
- **Onboarding_Screen**: The host widget rendered at route `/onboarding` that manages a `PageView` containing four `Onboarding_Page` widgets and the shared navigation controls.
- **Onboarding_Page**: A single page within the onboarding `PageView`, composed of an `Illustration_Widget`, a title, and a description.
- **Illustration_Widget**: A self-contained `CustomPaint`-based widget that renders a decorative geometric graphic without using external image assets.
- **Page_Indicator**: A row of animated dots that reflects the currently active onboarding page index.
- **Animation_Controller**: Flutter's built-in `AnimationController` used to drive all entrance, transition, and indicator animations.
- **AppColors**: The project-wide color constants in `lib/config/theme/app_colors.dart`.
- **AppTypography**: The Poppins-based text style constants in `lib/config/theme/app_typography.dart`.
- **AppSpacing**: The 8dp-grid spacing constants in `lib/config/theme/app_spacing.dart`.
- **AppRadius**: The border radius constants in `lib/config/theme/app_radius.dart`.
- **GoRouter**: The declarative routing package (`go_router ^14.0.0`) used for all screen navigation.
- **RoutePaths**: The type-safe route path constants in `lib/config/routing/route_paths.dart`.
- **Legacy_Screen**: Any screen file located under `lib/screens/` — these files MUST NOT be modified.

---

## Requirements

### Requirement 1: Animated Splash Screen

**User Story:** As a user launching StudyFlow AI, I want to see a polished branded splash screen so that the app feels premium and professional from the very first moment.

#### Acceptance Criteria

1. THE Splash_Screen SHALL occupy the full display area with no system-chrome gaps, rendering a vertically centered layout on a top-to-bottom gradient background transitioning from `AppColors.primary` to `AppColors.primaryLight`.
2. WHEN the Splash_Screen mounts, THE Animation_Controller SHALL play a sequential entrance animation using `Curves.easeOut`: the app logo fades in and scales from 0.6 to 1.0 over 600 ms, immediately followed by the brand text fading in over 400 ms, immediately followed by the tagline fading in over 300 ms.
3. THE Splash_Screen SHALL display the text "StudyFlow AI" styled with `AppTypography.headlineLarge` in `AppColors.onPrimary`.
4. THE Splash_Screen SHALL display the tagline "Transform Your Study Journey" styled with `AppTypography.bodyLarge` in `AppColors.onPrimary` with 0.85 opacity.
5. THE Splash_Screen SHALL display an app logo rendered as a custom-painted widget (no external image asset) using `AppColors.secondary` and `AppColors.tertiary` as accent colors.
6. WHEN 2500 ms has elapsed since mount, THE Splash_Screen SHALL call `context.go(RoutePaths.onboarding)` to navigate to the onboarding route, regardless of whether the entrance animation has completed.
7. IF the full entrance animation sequence completes before 2500 ms has elapsed, THEN THE Splash_Screen SHALL wait until 2500 ms has elapsed before navigating.
8. THE Splash_Screen SHALL use only `AppColors`, `AppTypography`, `AppSpacing`, and `AppRadius` constants — no hardcoded color literals, font sizes, numeric padding values, or animation duration literals (all durations defined as named constants).
9. THE Splash_Screen SHALL NOT modify any file under `lib/screens/`.

---

### Requirement 2: Onboarding Page Content

**User Story:** As a new user, I want to read about StudyFlow AI's key benefits across multiple onboarding pages so that I understand the app's value before signing up.

#### Acceptance Criteria

1. THE Onboarding_Screen SHALL contain exactly four Onboarding_Page instances, presented in this fixed order: "Study Smarter", "Offline First", "AI Study Assistant", "Stay Productive".
2. EACH Onboarding_Page SHALL display, from top to bottom: an Illustration_Widget, then a title rendered in `AppTypography.headlineMedium` using `AppColors.primary`, then a description rendered in `AppTypography.bodyLarge` using `AppColors.onSurfaceVariant`.
3. THE Onboarding_Page titled "Study Smarter" SHALL display the description "Organize semesters, subjects and notes in one place."
4. THE Onboarding_Page titled "Offline First" SHALL display the description "Work anywhere with secure offline storage and cloud sync."
5. THE Onboarding_Page titled "AI Study Assistant" SHALL display the description "Generate notes, quizzes, summaries and flashcards with AI."
6. THE Onboarding_Page titled "Stay Productive" SHALL display the description "Manage assignments, quizzes, schedules and grades effortlessly."
7. EACH Illustration_Widget SHALL be a self-contained `CustomPaint` widget with a fixed height of `AppSpacing.xxxl * 3` (192 dp) that fills the full available width, implemented as a dedicated `CustomPainter` subclass unique to its page — no external image files, no shared painter classes across pages.
8. THE Onboarding_Screen SHALL use only `AppColors`, `AppTypography`, `AppSpacing`, and `AppRadius` constants — no hardcoded color literals, font sizes, or numeric padding values.

---

### Requirement 3: Onboarding Navigation Controls

**User Story:** As a new user moving through onboarding, I want clear and accessible navigation controls so that I can progress forward, go back, or skip to the login screen at any time.

#### Acceptance Criteria

1. THE Onboarding_Screen SHALL display a Skip button positioned in the top-right corner that is visible on pages 1, 2, and 3, and hidden on page 4.
2. THE Onboarding_Screen SHALL display a Back button that is hidden on page 1 and visible on pages 2, 3, and 4.
3. THE Onboarding_Screen SHALL display a Next button on pages 1, 2, and 3, and a "Get Started" button on page 4.
4. WHEN a user taps the Next button on pages 1, 2, or 3 and no page animation is in progress, THE Onboarding_Screen SHALL animate to the next page over 300 ms using a slide transition; taps received while a page animation is in progress SHALL be ignored until the animation completes.
5. WHEN a user taps the Back button on pages 2, 3, or 4 and no page animation is in progress, THE Onboarding_Screen SHALL animate to the previous page over 300 ms using a slide transition; taps received while a page animation is in progress SHALL be ignored until the animation completes.
6. WHEN a user taps the Skip button, THE Onboarding_Screen SHALL navigate to `RoutePaths.login` using GoRouter.
7. WHEN a user taps the "Get Started" button on page 4, THE Onboarding_Screen SHALL navigate to `RoutePaths.login` using GoRouter.
8. THE Page_Indicator SHALL display four dots at the bottom of the screen, with the dot corresponding to the currently active page rendered in `AppColors.secondary` at full (1.0) opacity and all other dots rendered in `AppColors.outline` at 0.4 opacity.
9. WHEN the active page changes, THE Page_Indicator SHALL animate the active dot transition over 300 ms using an `AnimatedContainer`.
10. THE Skip button label SHALL use `AppTypography.labelLarge` styled in `AppColors.secondary`.
11. THE Back and Next / "Get Started" buttons SHALL use the existing `SecondaryButton` and `PrimaryButton` shared widgets respectively; no inline `ElevatedButton`, `OutlinedButton`, or `TextButton` widgets are permitted for these controls.

---

### Requirement 4: Page Transition Animation

**User Story:** As a user swiping through onboarding, I want smooth animated transitions between pages so that the experience feels fluid and premium.

#### Acceptance Criteria

1. THE Onboarding_Screen SHALL host all four Onboarding_Page instances inside a `PageView` driven by a `PageController`, with the controller exposed to sibling widgets (indicator, buttons) via a shared state mechanism.
2. WHEN a user swipes horizontally or programmatic navigation is invoked, THE PageView SHALL complete the page transition over 350 ms using `Curves.easeInOut`; if a new navigation event arrives mid-animation, the current animation SHALL complete before the new one begins.
3. THE Page_Indicator dots SHALL continuously interpolate their visual state in proportion to the `PageController.page` value, providing frame-by-frame feedback throughout a swipe gesture — not only at settled integer positions.
4. WHEN a new Onboarding_Page's `PageController.page` value settles at its integer index (offset reaches 1.0 from prior page), THE Illustration_Widget on that page SHALL play a fade-in entrance animation over 400 ms.
5. THE Onboarding_Screen SHALL support simultaneous programmatic navigation (button taps) and direct swipe gestures; a swipe gesture in progress SHALL NOT be interrupted by a button tap, and a programmatic animation in progress SHALL NOT be overridden by a new swipe until the current animation completes.

---

### Requirement 5: Design System Compliance

**User Story:** As a developer maintaining StudyFlow AI, I want all new screens to strictly use the established design tokens so that the codebase remains consistent and easy to theme.

#### Acceptance Criteria

1. THE Splash_Screen and Onboarding_Screen SHALL exclusively use color values from `AppColors` — no `Color(0x...)` literals are permitted outside of `AppColors` itself.
2. THE Splash_Screen and Onboarding_Screen SHALL exclusively use text styles from `AppTypography` — no inline `TextStyle(fontSize: ...)` declarations are permitted; `.copyWith(...)` chaining on an `AppTypography` style constant is permitted.
3. THE Splash_Screen and Onboarding_Screen SHALL exclusively use spacing values from `AppSpacing` — no raw `double` padding or margin literals are permitted.
4. THE Splash_Screen and Onboarding_Screen SHALL exclusively use border radius values from `AppRadius` — no raw `BorderRadius.circular(...)` calls with literal doubles are permitted outside of `AppRadius` itself.
5. THE Onboarding_Screen SHALL reuse the existing `PrimaryButton` shared widget for the Next and "Get Started" actions, and the existing `SecondaryButton` shared widget for the Back action; no inline button widgets are permitted for these controls. The Skip action SHALL use a `TextButton` or `GestureDetector` styled exclusively with `AppColors` and `AppTypography` tokens.
6. THE Splash_Screen and Onboarding_Screen SHALL use Poppins exclusively via `AppTypography` (which delegates to `GoogleFonts.poppins`) — no direct `GoogleFonts.poppins(...)` calls are permitted in screen or page files.

---

### Requirement 6: Navigation Flow Integration

**User Story:** As a user completing onboarding, I want the app to route me correctly to the login screen so that I can sign in and start using StudyFlow AI.

#### Acceptance Criteria

1. WHEN GoRouter initializes, THE Router SHALL render the Splash_Screen as the initial destination.
2. WHEN the Splash_Screen completes its display sequence (2500 ms timer fires), THE Router SHALL transition to the Onboarding_Screen without leaving the Splash_Screen in the navigation back-stack.
3. WHEN the user completes or skips onboarding, THE Router SHALL navigate to the login destination and render the login UI identically to how it renders when accessed directly — no structural or behavioral difference caused by arriving from onboarding.
4. WHEN the Onboarding route is requested, THE Router SHALL render the Onboarding_Screen.
5. THE Router SHALL continue to resolve all previously registered routes (splash, login, signup, home) without removal or behavioral change.
6. IF the user presses the system back button while on the Onboarding_Screen, THEN THE Router SHALL remain on the Onboarding_Screen (back navigation to the splash is disabled).

---

### Requirement 7: Code Architecture Constraints

**User Story:** As a developer on this project, I want the new feature code to follow the established Clean Architecture layout so that the codebase stays organized and maintainable.

#### Acceptance Criteria

1. THE Splash_Screen widget file SHALL be located at `lib/features/splash/presentation/screens/splash_screen.dart`.
2. THE Onboarding_Screen widget file SHALL be located at `lib/features/onboarding/presentation/screens/onboarding_screen.dart`.
3. THE Onboarding_Page widget SHALL be located at `lib/features/onboarding/presentation/widgets/onboarding_page_widget.dart`.
4. THE Page_Indicator widget SHALL be located at `lib/features/onboarding/presentation/widgets/page_indicator.dart`.
5. EACH Illustration_Widget for the four onboarding pages SHALL be located in `lib/features/onboarding/presentation/widgets/illustrations/` and named `onboarding_illustration_1.dart` through `onboarding_illustration_4.dart` corresponding to pages 1–4.
6. THE app logo custom-paint widget used on the Splash_Screen SHALL be located at `lib/features/splash/presentation/widgets/app_logo_widget.dart`.
7. THE Splash_Screen and all splash-feature widgets SHALL NOT import from `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`.
8. THE Onboarding_Screen and all onboarding-feature widgets SHALL NOT import from `lib/screens/`, `lib/notesApiServices/`, `lib/clippers/`, or `lib/dialogs/`.
9. WHEN `flutter analyze` is run on the `frontend/` directory after all new files are added, THE analysis SHALL report zero error-level diagnostics.

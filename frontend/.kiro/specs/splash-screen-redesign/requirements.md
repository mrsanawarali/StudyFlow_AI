# Requirements Document

## Introduction

This document defines the requirements for redesigning the StudyFlow AI splash screen
(`lib/features/splash/presentation/screens/splash_screen.dart` and its companion
widgets/`lib/features/splash/presentation/widgets/`). The redesign is a **UI-only** change;
all navigation logic, routing, and app initialisation remain untouched. The goal is to replace
the current single-animation entrance with a premium, dark-themed, multi-layered animated
experience that elevates brand perception while the app loads.

Scope is strictly limited to:
- `lib/features/splash/presentation/screens/splash_screen.dart`
- `lib/features/splash/presentation/widgets/app_logo_widget.dart`
- New widget files created under `lib/features/splash/presentation/widgets/`

No changes shall be made to onboarding, login, routing, or any other screen.

---

## Glossary

- **Splash_Screen**: The `SplashScreen` StatefulWidget rendered at app start before routing
  to the next destination.
- **Logo_Widget**: The `AppLogoWidget` (and any animated wrapper) that renders the
  StudyFlow AI brand mark.
- **Particle_Layer**: A `CustomPaint`-based full-screen overlay that renders floating light
  dots to simulate a particle field.
- **Loading_Indicator**: A row of three animated glowing dots displayed below the subtitle.
- **Animation_Controller**: A Flutter `AnimationController` managing a named animation
  sequence.
- **AppColors**: The existing `AppColors` class in
  `lib/config/theme/app_colors.dart` — the single source of truth for all color values.
- **AppTypography**: The existing `AppTypography` class in
  `lib/config/theme/app_typography.dart` — the single source of truth for all text styles.
- **Glow_Effect**: A `BoxDecoration` or `MaskFilter.blur` that produces a soft luminous halo
  around a widget.
- **Pulse_Animation**: A looping scale oscillation (`0.95 → 1.05 → 0.95`) applied to the
  Logo_Widget.
- **Float_Animation**: A looping vertical translation (`-8 px → +8 px → -8 px`) applied to
  the Logo_Widget.
- **Rotating_Light**: A looping conic or gradient overlay on the logo background circle that
  rotates 360 ° continuously.
- **Staggered_Entrance**: A sequence where logo, title, subtitle, and Loading_Indicator each
  fade in at successive time intervals within a single Animation_Controller pass.
- **Glassmorphism_Accent**: A frosted-glass container (`BackdropFilter` + semi-transparent
  fill + subtle border) used sparingly as a depth accent behind the branding text.

---

## Requirements

### Requirement 1: Premium Dark Gradient Background

**User Story:** As a user launching StudyFlow AI, I want to see a rich, dark background with
subtle depth, so that the app feels premium from the very first frame.

#### Acceptance Criteria

1. THE Splash_Screen SHALL fill the entire viewport with a two-stop linear gradient: the
   top stop is a very dark navy (`#0A0F2C`) and the bottom stop is a deep purple
   (`#1A0A3C`), spanning 100 % of screen height and width with no gaps or clipping.
2. WHEN the Splash_Screen is rendered, THE gradient layer SHALL be the lowest layer in the
   widget tree so that every other visual element (particles, logo, text, indicator) is
   composited above it.
3. THE Splash_Screen SHALL NOT display any solid flat-colour background at any point during
   its lifecycle; if the gradient fails to render, the fallback colour SHALL be `#0A0F2C`
   (the darkest gradient stop) so no light or default-white background bleeds through.

---

### Requirement 2: Animated Floating Particle Layer

**User Story:** As a user, I want to see subtle floating light particles in the background, so
that the screen conveys a sense of depth and motion without feeling cluttered.

#### Acceptance Criteria

1. THE Particle_Layer SHALL render between 12 and 20 small circular light dots distributed
   pseudo-randomly across the screen using a `CustomPainter`.
2. EACH particle dot SHALL have a diameter between 2 dp and 6 dp and an opacity between
   0.10 and 0.35, using `AppColors.secondaryLight` as the base colour.
3. WHEN the Splash_Screen enters the viewport, THE Particle_Layer SHALL begin a looping
   vertical drift animation where each dot moves upward by 20–40 dp over 4–8 seconds; WHEN
   a dot reaches its upward travel limit, it SHALL instantly reappear at its original
   Y-coordinate (wrap-around) so the drift appears continuous. Each dot SHALL begin its
   drift at a pseudo-random phase offset (0–100 % of its cycle duration) so dots do not
   all move in lockstep.
4. THE Particle_Layer SHALL be placed in the widget stack below the logo, title, subtitle,
   and Loading_Indicator layers so that no particle dot is drawn over those foreground
   elements; the Particle_Layer's z-order SHALL be above only the gradient background layer.
5. WHEN the Splash_Screen enters the viewport, THE Particle_Layer drift animation SHALL
   start concurrently with the Staggered_Entrance sequence (i.e., both begin on the same
   frame in `initState`).
6. IF the animation controller for the Particle_Layer is disposed, THEN THE Particle_Layer
   SHALL stop all animations immediately without throwing an exception.

---

### Requirement 3: Animated Logo with Glow, Pulse, and Float

**User Story:** As a user, I want to see the StudyFlow AI logo animate with a glowing,
pulsing, floating motion, so that the brand mark feels alive and premium.

#### Acceptance Criteria

1. THE Logo_Widget SHALL be centered horizontally and positioned in the upper-centre region
   of the screen such that its vertical centre sits between 32 % and 38 % from the top of
   the safe area (±3 % tolerance).
2. THE Logo_Widget SHALL be rendered with a visible soft glow halo behind the logo graphic:
   a radial glow at 30–50 % opacity in the app's secondary brand colour, producing a
   luminous halo effect.
3. WHEN the Splash_Screen becomes visible and all Animation_Controllers are successfully
   initialised, THE Logo_Widget SHALL begin a looping Pulse_Animation that scales between
   0.95 and 1.05 over 1800 ms using a smooth ease-in-out curve, repeating indefinitely.
4. IF any Animation_Controller fails to initialise, THEN THE Splash_Screen SHALL render in
   its fully-visible static state (scale 1.0, vertical offset 0 dp, rotation 0°) so the
   user can see the splash and navigation can proceed normally.
5. WHEN the Splash_Screen becomes visible, THE Logo_Widget SHALL begin a looping
   Float_Animation that translates the widget vertically between -8 dp and +8 dp over
   3000 ms using a smooth ease-in-out curve, repeating indefinitely.
6. WHEN the Splash_Screen becomes visible, THE Logo_Widget background circle SHALL display
   a Rotating_Light overlay that completes one full 360 ° rotation every 6000 ms, looping
   indefinitely.
7. THE Logo_Widget SHALL support a future Rive or Lottie asset swap: when a replacement
   child asset is provided, the animated glow, pulse, float, and rotating-light effects SHALL
   continue to apply to that child without modification to the animation logic.
8. IF the device reports reduced-motion accessibility preference, THEN THE Logo_Widget
   SHALL display in its fully-visible static state (scale 1.0, vertical offset 0 dp,
   rotation 0°) with no looping animations.

---

### Requirement 4: Staggered Entrance Animations

**User Story:** As a user, I want each element to fade into view one after another, so that
the screen feels polished and intentional rather than appearing all at once.

#### Acceptance Criteria

1. WHEN `initState` completes, THE Splash_Screen SHALL immediately forward a single
   Animation_Controller with a total duration of 1500 ms to drive the Staggered_Entrance
   sequence.
2. WHEN the Animation_Controller reaches 500 ms, THE Logo_Widget SHALL have reached
   opacity 1.0, having faded from opacity 0.0 at 0 ms using an ease-out curve.
3. WHEN the Animation_Controller reaches 900 ms, THE title text "StudyFlow AI" SHALL have
   reached opacity 1.0, having faded from opacity 0.0 at 500 ms using an ease-out curve.
4. WHEN the Animation_Controller reaches 1200 ms, THE subtitle "Transform Your Study
   Journey" SHALL have reached opacity 1.0, having faded from opacity 0.0 at 900 ms using
   an ease-out curve.
5. WHEN the Animation_Controller reaches 1500 ms, THE Loading_Indicator SHALL have reached
   opacity 1.0, having faded from opacity 0.0 at 1200 ms using an ease-out curve.
6. WHEN the Staggered_Entrance Animation_Controller completes (reaches 1500 ms), THE
   Splash_Screen SHALL be fully visible at opacity 1.0 and SHALL remain fully visible until
   the navigation timer fires; THE Splash_Screen SHALL NOT begin any fade-out or opacity
   reduction before the navigation timer fires.
7. THE Staggered_Entrance Animation_Controller SHALL be disposed in the widget's `dispose`
   method.

---

### Requirement 5: Premium Branding Typography

**User Story:** As a user, I want to see the app name and tagline in high-contrast, premium
typography, so that the brand identity is immediately clear.

#### Acceptance Criteria

1. THE Splash_Screen SHALL display the title "StudyFlow AI" using the largest headline text
   style available in the app's typography system, in a high-contrast colour against the
   dark background, with letter spacing of 1.2.
2. THE Splash_Screen SHALL display the subtitle "Transform Your Study Journey" using the
   standard body large text style, in the same high-contrast colour at 80 % opacity, with
   letter spacing of 0.5.
3. THE title and subtitle SHALL be horizontally centred on screen.
4. THE branding text block (title + subtitle) SHALL be vertically centred within the lower
   half of the screen content area, with a minimum gap of 8 dp between the title and the
   subtitle.
5. THE Splash_Screen SHALL NOT display any additional text, labels, version numbers,
   or helper messages.
6. WHERE a Glassmorphism_Accent is applied behind the branding text block, THE accent
   container SHALL use a white fill at 5 % opacity, a 1 dp border at 15 % white opacity,
   and a border radius of 16 dp.

---

### Requirement 6: Three-Dot Animated Loading Indicator

**User Story:** As a user, I want to see a subtle animated loading indicator, so that I know
the app is initialising rather than frozen.

#### Acceptance Criteria

1. WHEN the Loading_Indicator is visible, THE Loading_Indicator SHALL render exactly three
   circular dots arranged horizontally with 10 dp spacing between them.
2. EACH dot SHALL have a diameter of 8 dp and use the app's secondary brand colour as its
   fill colour.
3. EACH dot SHALL animate its opacity in a looping sequence: fade from 1.0 to 0.3 and back
   to 1.0 over 900 ms, with each successive dot delayed by 300 ms relative to the previous
   dot (a "wave" effect), repeating indefinitely.
4. EACH dot SHALL display a soft glow effect with a visible luminous halo of radius 6 dp
   in the secondary brand colour so the dots appear to glow.
5. THE Loading_Indicator SHALL NOT use a Material circular spinner widget or any platform
   spinner.
6. WHEN the Loading_Indicator is dismissed (its widget is removed from the tree), ALL dot
   animation controllers SHALL be disposed without throwing an exception.

---

### Requirement 7: Navigation Preservation

**User Story:** As a developer, I want the splash screen redesign to leave all navigation
logic untouched, so that existing routing continues to work correctly.

#### Acceptance Criteria

1. WHEN 2500 ms have elapsed since the Splash_Screen widget was initialised, THE
   Splash_Screen SHALL navigate the app to the onboarding route using the app's declarative
   routing system, identical to the pre-redesign navigation target and mechanism.
2. IF the Splash_Screen widget is disposed before the 2500 ms timer fires, THEN THE timer
   SHALL be cancelled and THE Splash_Screen SHALL NOT trigger any navigation call.
3. THE Splash_Screen SHALL NOT add, remove, or modify any named routes, router
   configuration, or route-path constants.
4. THE redesign SHALL NOT modify any routing configuration file, router provider, or
   route-path constant file.

---

### Requirement 8: Scope Constraint — Single Feature Directory Modification

**User Story:** As a developer, I want the redesign to be contained to the splash feature
directory only, so that no regressions are introduced in other screens.

#### Acceptance Criteria

1. THE redesign SHALL modify only existing files within
   `lib/features/splash/presentation/screens/` and
   `lib/features/splash/presentation/widgets/`; any new widget files created by the
   redesign SHALL also be placed exclusively within
   `lib/features/splash/presentation/widgets/`.
2. THE redesign SHALL NOT modify any file whose path does not begin with
   `lib/features/splash/presentation/`; this explicitly excludes `lib/main.dart`,
   routing configuration files, and all files under `lib/features/onboarding/`,
   `lib/features/auth/`, and `lib/features/dashboard/`.
3. THE redesign SHALL NOT add any new packages to `pubspec.yaml`; all visual effects
   (animations, particles, glow) SHALL be achieved using packages already listed in
   `pubspec.yaml` at the time the redesign begins.
4. THE redesign SHALL use only Flutter SDK animation and painting APIs
   (`AnimationController`, `CustomPainter`, `BackdropFilter`, blur-based painting) for
   animation and effect logic; standard Flutter layout and state widgets (e.g., `Stack`,
   `Column`, `StatefulWidget`) are unrestricted and may be used freely.

# StudyFlow AI — Theme System Guide

## Overview

StudyFlow AI uses a **Material 3 design token system**. All visual values (colors, typography, spacing, radius, shadows) are defined as constants and must be used everywhere — never hardcode `Color(0xFF...)`, `EdgeInsets.all(16)`, or `BorderRadius.circular(8)` directly in widgets.

The theme is configured via `AppTheme.lightTheme` and applied in `main.dart`.

---

## AppColors

**File:** `lib/config/theme/app_colors.dart`

### Brand Palette

| Constant | Hex | Usage |
|----------|-----|-------|
| `AppColors.primary` | `#0A0F2C` | App bar, primary buttons, key brand elements |
| `AppColors.primaryLight` | `#1A2F4C` | Hover states, lighter backgrounds |
| `AppColors.primaryDark` | `#000510` | Pressed states, deep contrast |
| `AppColors.secondary` | `#4A90E2` | FAB, secondary actions, links |
| `AppColors.secondaryLight` | `#7AB8FF` | Secondary button hover |
| `AppColors.tertiary` | `#50E3C2` | Accent highlights, tags |

### Semantic Colors

| Constant | Hex | Usage |
|----------|-----|-------|
| `AppColors.success` | `#4CAF50` | Success states, confirmations |
| `AppColors.warning` | `#FFA726` | Warnings, caution banners |
| `AppColors.error` | `#E53935` | Errors, destructive actions |
| `AppColors.info` | `#42A5F5` | Info banners, tooltips |

### Surface & Background

| Constant | Hex | Usage |
|----------|-----|-------|
| `AppColors.background` | `#F8F9FA` | Scaffold background |
| `AppColors.surface` | `#FFFFFF` | Cards, dialogs, sheets |
| `AppColors.surfaceVariant` | `#F1F3F5` | Input field fills, secondary surfaces |
| `AppColors.surfaceContainerHigh` | `#E8EAED` | Disabled input fills |

### On-Colors (Text/Icons on backgrounds)

| Constant | Usage |
|----------|-------|
| `AppColors.onPrimary` | Text/icons on primary background (`#FFFFFF`) |
| `AppColors.onBackground` | Body text on background (`#1A1C1E`) |
| `AppColors.onSurface` | Text on surface/cards (`#1A1C1E`) |
| `AppColors.onSurfaceVariant` | Placeholder/hint text (`#44474A`) |

### Usage Example

```dart
// ✅ Correct — use design tokens
Container(color: AppColors.surface)
Text('Hello', style: TextStyle(color: AppColors.onSurface))

// ❌ Wrong — never hardcode colors
Container(color: Color(0xFFFFFFFF))
Text('Hello', style: TextStyle(color: Color(0xFF1A1C1E)))
```

---

## AppTypography

**File:** `lib/config/theme/app_typography.dart`

Font: **Poppins** via `google_fonts`. All sizes in SP.

### Scale Reference

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| `AppTypography.displayLarge` | 57sp | w400 | Hero text, splash screens |
| `AppTypography.headlineLarge` | 32sp | w600 | Major page titles |
| `AppTypography.headlineMedium` | 28sp | w600 | Screen titles (AppBar) |
| `AppTypography.headlineSmall` | 24sp | w600 | Section headers |
| `AppTypography.titleLarge` | 22sp | w600 | Card titles, dialogs |
| `AppTypography.titleMedium` | 16sp | w500 | Sub-section labels |
| `AppTypography.bodyLarge` | 16sp | w400 | Primary body content |
| `AppTypography.bodyMedium` | 14sp | w400 | Default body text, inputs |
| `AppTypography.bodySmall` | 12sp | w400 | Captions, helper text |
| `AppTypography.labelLarge` | 14sp | w500 | Button labels |
| `AppTypography.labelSmall` | 11sp | w500 | Badges, tags |

### Usage Example

```dart
// Use the theme text styles in build context
Text(
  'My Notes',
  style: context.textTheme.headlineMedium,  // via BuildContextX extension
)

// Or reference directly
Text(
  'Add Note',
  style: AppTypography.labelLarge,
)

// Override specific properties with copyWith
Text(
  'Error',
  style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
)
```

---

## AppSpacing

**File:** `lib/config/theme/app_spacing.dart`

Based on an **8dp base grid**.

| Constant | Value | Use Case |
|----------|-------|----------|
| `AppSpacing.xs` | 4dp | Icon-to-text gaps, tight items |
| `AppSpacing.sm` | 8dp | List item internal spacing |
| `AppSpacing.md` | 16dp | Default padding (cards, buttons) |
| `AppSpacing.lg` | 24dp | Screen edges, section gaps |
| `AppSpacing.xl` | 32dp | Large section breaks |
| `AppSpacing.xxl` | 48dp | Hero areas, onboarding |

### Preset EdgeInsets

| Constant | Value |
|----------|-------|
| `AppSpacing.paddingAll` | `EdgeInsets.all(16)` |
| `AppSpacing.paddingHorizontal` | `EdgeInsets.symmetric(horizontal: 16)` |
| `AppSpacing.paddingPage` | `EdgeInsets.all(24)` |
| `AppSpacing.paddingCard` | `EdgeInsets.all(16)` |

### Usage Example

```dart
// ✅ Correct
Padding(padding: AppSpacing.paddingPage, child: ...)
SizedBox(height: AppSpacing.md)
EdgeInsets.symmetric(horizontal: AppSpacing.lg)

// ❌ Wrong
Padding(padding: EdgeInsets.all(24), child: ...)
SizedBox(height: 16)
```

---

## AppRadius

**File:** `lib/config/theme/app_radius.dart`

| Constant | Value | Use Case |
|----------|-------|----------|
| `AppRadius.sm` | 4dp | Chips, small tags |
| `AppRadius.md` | 8dp | Cards, buttons, inputs |
| `AppRadius.lg` | 12dp | Large cards, modals |
| `AppRadius.xl` | 16dp | Bottom sheets, dialogs |
| `AppRadius.full` | 999dp | Circular buttons, avatars, pills |

### BorderRadius Getters

| Getter | Equivalent |
|--------|-----------|
| `AppRadius.roundedMd` | `BorderRadius.circular(8)` |
| `AppRadius.roundedLg` | `BorderRadius.circular(12)` |
| `AppRadius.roundedFull` | `BorderRadius.circular(999)` |
| `AppRadius.topOnlyLg` | `BorderRadius.vertical(top: Radius.circular(12))` |

### Usage Example

```dart
// ✅ Correct
ClipRRect(borderRadius: AppRadius.roundedMd, child: ...)
Container(decoration: BoxDecoration(borderRadius: AppRadius.roundedXl))

// ❌ Wrong
ClipRRect(borderRadius: BorderRadius.circular(8), child: ...)
```

---

## AppShadows

**File:** `lib/config/theme/app_shadows.dart`

| Getter | Elevation | Use Case |
|--------|-----------|----------|
| `AppShadows.sm` | 1 | Cards at rest, bottom nav |
| `AppShadows.md` | 2 | Raised cards, pressed buttons |
| `AppShadows.lg` | 3 | Dialogs, bottom sheets |
| `AppShadows.xl` | 4 | FAB, modal overlays |
| `AppShadows.none` | 0 | Flat, no shadow |

### Usage Example

```dart
// ✅ Correct
Container(
  decoration: BoxDecoration(
    boxShadow: AppShadows.sm,
    borderRadius: AppRadius.roundedMd,
  ),
)
```

---

## AppTheme

**File:** `lib/config/theme/app_theme.dart`

Applied in `main.dart`:

```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  ...
)
```

`AppTheme.lightTheme` configures:
- `useMaterial3: true`
- Full `ColorScheme.light()` from `AppColors`
- Full `TextTheme` from `AppTypography`
- `AppBarTheme`, `CardTheme`, `ElevatedButtonTheme`, `OutlinedButtonTheme`
- `InputDecorationTheme`, `FABTheme`, `SnackBarTheme`, `BottomNavigationBarTheme`

### Accessing Theme in Widgets

```dart
// Via BuildContextX extension (preferred)
context.theme           // ThemeData
context.colorScheme     // ColorScheme
context.textTheme       // TextTheme

// Via Theme.of (standard)
Theme.of(context).colorScheme.primary
```

---

## Adding Dark Mode (Future)

When implementing dark mode:

1. Define dark color palette in `AppColors`:
   ```dart
   // static const darkBackground = Color(0xFF121212);
   ```

2. Create `AppTheme.darkTheme` using the dark colors:
   ```dart
   static ThemeData get darkTheme { ... }
   ```

3. Add a Riverpod `StateProvider<ThemeMode>` for user preference:
   ```dart
   final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);
   ```

4. Update `MaterialApp`:
   ```dart
   MaterialApp(
     theme: AppTheme.lightTheme,
     darkTheme: AppTheme.darkTheme,
     themeMode: ref.watch(themeModeProvider),
   )
   ```

5. Test all screens and widgets in dark mode before shipping.

---

## Design Token Checklist

Before submitting a PR, verify:

- [ ] No `Color(0xFF...)` literals in widget files
- [ ] No `EdgeInsets.all(n)` with bare numbers (use `AppSpacing`)
- [ ] No `BorderRadius.circular(n)` with bare numbers (use `AppRadius`)
- [ ] No hardcoded `TextStyle(fontSize: n)` — use `AppTypography`
- [ ] All new widgets import only from `config/theme/`

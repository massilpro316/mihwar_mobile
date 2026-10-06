---
name: material3-mobile-design
description: >
  Material Design 3 (M3) reference for native Flutter mobile app design.
  Use this skill whenever the user asks to design, build, or style any mobile screen,
  component, or app layout. Triggers on: "design a screen", "mobile UI", "build a component",
  "app layout", "style this", "Material Design", "M3", "follow design guidelines", or any
  mobile UI task. Always apply M3 color roles, typography scale, and spacing rules.
  Colors are accessed via context extensions (context.primary, context.onSurface…),
  typography via context extensions (context.bodyLarge…), spacing via AppSpacing constants.
---

# Material Design 3 — Flutter Mobile Design Reference

> Apply M3 rules on every screen. Use context extensions for colors and typography, AppSpacing for all sizing.  
> Units: **dp** for layout/spacing, **sp** for text (via ScreenUtil).

---

## 1. COLOR ROLES — When to Use Each

Colors are accessed via the `e_extension.dart` context extension: `context.primary`, `context.onSurface`, etc.
Never hardcode color values — always use the role that matches the semantic intent below.

### Primary
- **`context.primary`** — Key action buttons, FAB, active icons, selected nav indicator
- **`context.onPrimary`** — Text/icons drawn ON a primary-colored surface
- **`context.primaryContainer`** — Tonal buttons, selected chip background, active nav item background
- **`context.onPrimaryContainer`** — Text/icons inside a primaryContainer surface
- **`context.primaryFixed`** — Always-colored primary surface, identical in light and dark
- **`context.primaryFixedDim`** — Lower-emphasis variant of primaryFixed
- **`context.onPrimaryFixed`** — Text/icons ON primaryFixed or primaryFixedDim
- **`context.onPrimaryFixedVariant`** — Lower-emphasis text/icons ON primaryFixed or primaryFixedDim

### Secondary
- **`context.secondary`** — Secondary/supporting actions, complementary accents
- **`context.onSecondary`** — Text/icons drawn ON a secondary-colored surface
- **`context.secondaryContainer`** — Filter chips, tags, secondary selection backgrounds
- **`context.onSecondaryContainer`** — Text/icons inside a secondaryContainer surface
- **`context.secondaryFixed`** — Always-colored secondary surface, identical in light and dark
- **`context.secondaryFixedDim`** — Lower-emphasis variant of secondaryFixed
- **`context.onSecondaryFixed`** — Text/icons ON secondaryFixed or secondaryFixedDim
- **`context.onSecondaryFixedVariant`** — Lower-emphasis text/icons ON secondaryFixed or secondaryFixedDim

### Tertiary
- **`context.tertiary`** — Decorative highlights, third-priority accents only
- **`context.onTertiary`** — Text/icons drawn ON a tertiary-colored surface
- **`context.tertiaryContainer`** — Third-priority chip or badge backgrounds
- **`context.onTertiaryContainer`** — Text/icons inside a tertiaryContainer surface
- **`context.tertiaryFixed`** — Always-colored tertiary surface, identical in light and dark
- **`context.tertiaryFixedDim`** — Lower-emphasis variant of tertiaryFixed
- **`context.onTertiaryFixed`** — Text/icons ON tertiaryFixed or tertiaryFixedDim
- **`context.onTertiaryFixedVariant`** — Lower-emphasis text/icons ON tertiaryFixed or tertiaryFixedDim

### Surface
- **`context.surface`** — Default screen/page background
- **`context.surfaceDim`** — Dimmed overlay backgrounds, scrims
- **`context.surfaceBright`** — Modals, elevated bottom sheets
- **`context.surfaceContainerLowest`** — Sheets positioned beneath main content
- **`context.surfaceContainerLow`** — Cards at rest, low-elevation surfaces
- **`context.surfaceContainer`** — Default card containers, navigation rail background
- **`context.surfaceContainerHigh`** — Elevated cards, top app bar background
- **`context.surfaceContainerHighest`** — Chips, text fields, search bars

- **`context.onSurface`** — Primary body text, standard icons on any surface
- **`context.onSurfaceVariant`** — Secondary text, placeholder text, inactive icons, supporting labels
- **`context.surfaceTint`** — Tint blended into surface to express elevation — do not use as a standalone color

### Background
- **`context.background`** — App-level background (behind all surfaces)
- **`context.onBackground`** — Text placed directly on background

### Outline
- **`context.outline`** — Text field borders, dividers, focus rings, active strokes
- **`context.outlineVariant`** — Subtle dividers, card strokes, inactive tab underlines

### Error
- **`context.error`** — Error state icons, destructive action highlights
- **`context.onError`** — Text/icons drawn ON an error-colored surface
- **`context.errorContainer`** — Error banner/chip/snackbar backgrounds
- **`context.onErrorContainer`** — Text/icons inside an errorContainer surface

### Inverse & Utility
- **`context.inverseSurface`** — Snackbar background
- **`context.onInverseSurface`** — Text inside snackbars
- **`context.inversePrimary`** — Tonal buttons inside inverse surfaces
- **`context.scrim`** — Modal overlay — apply at 32% opacity
- **`context.shadow`** — Drop shadow color for elevated components

---

## 2. TYPOGRAPHY — M3 Type Scale

Accessed via `e_typography.dart` context extension: `context.bodyLarge`, `context.titleMedium`, etc.
All sizes scale automatically via ScreenUtil. Never use raw font sizes.

| Style | When to use |
|-------|------|--------|-------------|
| `context.displayLarge` | Splash / hero screens only |
| `context.displayMedium` | Large feature text |
| `context.displaySmall` | Section hero |
| `context.headlineLarge` | Screen titles |
| `context.headlineMedium` | Card titles, section headers |
| `context.headlineSmall` | Sub-section headers |
| `context.titleLarge` | App bar title, dialog title |
| `context.titleMedium` | List section headers, nav labels |
| `context.titleSmall` | Chip text, tab labels |
| `context.bodyLarge` | Primary body text, descriptions |
| `context.bodyMedium` | Secondary body, list item text |
| `context.bodySmall` | Captions, helper text, field labels |
| `context.labelLarge` | Button text, prominent labels |
| `context.labelMedium` | Badge text, chip labels |
| `context.labelSmall` | Overlines, very small badges |

---

## 3. SPACING — 4dp Grid

All spacing from `e_spacing.dart` — `AppSpacing.md`, `AppSpacing.screenMargin`, etc.
Every value is a multiple of 4dp. Never hardcode spacing values.

### Scale
| Constant | Value | When to use |
|----------|-------|-------------|
| `AppSpacing.xs` | 4dp | Icon-to-label gap, tight internal insets |
| `AppSpacing.sm` | 8dp | Default internal component padding, gap between cards |
| `AppSpacing.md12` | 12dp | Medium internal padding |
| `AppSpacing.md` | 16dp | Screen edge margin, card internal padding |
| `AppSpacing.md20` | 20dp | Medium component gap |
| `AppSpacing.lg` | 24dp | Section spacing, dialog padding |
| `AppSpacing.xl` | 32dp | Large section gap |
| `AppSpacing.xxl` | 48dp | Hero section spacing, large visual breathing room |

### Layout Rules
- **Screen horizontal margin**: always `AppSpacing.screenMargin` (16dp) each side
- **Card internal padding**: `AppSpacing.cardPadding` (16dp)
- **Gap between cards**: `AppSpacing.cardGap` (8dp)
- **Dialog padding**: `AppSpacing.dialogPadding` (24dp)
- **Section spacing**: `AppSpacing.sectionGap` (24dp)
- **Minimum touch target**: `AppSpacing.touchTarget` (48dp) for all interactive elements


### Gap Widgets (SizedBox shortcuts)
```dart
AppSpacing.gapXS   // vertical 4dp
AppSpacing.gapSM   // vertical 8dp
AppSpacing.gap12   // vertical 12dp
AppSpacing.gapMD   // vertical 16dp
AppSpacing.gapLG   // vertical 24dp
AppSpacing.gapXL   // vertical 32dp
AppSpacing.gapXXL  // vertical 48dp
AppSpacing.hGapSM  // horizontal 8dp
AppSpacing.hGapMD  // horizontal 16dp
AppSpacing.hGapLG  // horizontal 24dp
```

---

## 4. ELEVATION — Tonal System

M3 elevation uses surface tint (primary blended into surface), not heavy shadows.

| Level | Shadow | Surface tint | Used on |
|-------|--------|--------------|---------|
| 0 | 0dp | 0% | Background, flat cards |
| 1 | 1dp | 5% | Cards (default), navigation drawer |
| 2 | 3dp | 8% | FAB resting, chips |
| 3 | 6dp | 11% | FAB pressed, nav bar |
| 4 | 8dp | 12% | Snackbar |
| 5 | 12dp | 14% | App bar scrolled, modals |

---

## 5. ICONOGRAPHY

- Standard size: **24dp**
- Dense context: **20dp**
- Touch target: **`AppSpacing.touchTarget`** (48×48dp) for all icon buttons
- **Filled** icon → active / selected state
- **Outlined** icon → inactive / default state

---

## 6. INTERACTION STATES

Apply a semi-transparent overlay on the component's base color:

| State | Opacity | Color source |
|-------|---------|--------------|
| Pressed | 12% | `onSurface` or `on[Container]` |
| Focused | 12% | `onSurface` or `on[Container]` |
| Dragged | 16% | `onSurface` or `on[Container]` |
| Disabled content | 38% | `onSurface` |
| Disabled container | 12% | `onSurface` |

---

## 7. MOBILE DESIGN RULES

1. **Touch targets** — Every tappable element ≥ `AppSpacing.touchTarget` (48×48dp)
2. **Thumb reach** — Primary CTAs in the bottom 40% of the screen
3. **One-handed use** — FAB and main actions in the bottom-right
4. **Screen margins** — Always `AppSpacing.screenMargin` (16dp) each side — no exceptions
5. **Safe areas** — Never overlap status bar or gesture navigation insets
6. **Spacing discipline** — Minimum `AppSpacing.sm` (8dp) between any two elements
7. **Images** — 16:9 for banners, 1:1 for avatars; apply card's corner radius
8. **Dark theme** — Always verify both light and dark themes work with the same roles
9. **Text contrast** — `onSurface` on `surface` ≥ 14:1. `onPrimary` on `primary` ≥ 4.5:1

---

## 8. DESIGN CHECKLIST

- [ ] All colors use `context.*` role extensions — no hardcoded values
- [ ] All text uses `context.*` typography extensions — no raw sizes
- [ ] All spacing uses `AppSpacing.*` — no hardcoded numbers
- [ ] Touch targets ≥ 48×48dp (`AppSpacing.touchTarget`)
- [ ] Pressed / focused / disabled states covered
- [ ] Correct elevation level applied
- [ ] Corner radius from `AppSpacing.radius*`
- [ ] 16dp screen margins on every screen (`AppSpacing.screenMargin`)
- [ ] Both light and dark themes verified
- [ ] Icons: filled = active, outlined = inactive
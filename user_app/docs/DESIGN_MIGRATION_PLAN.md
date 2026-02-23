# Design Migration Plan: User-Web to User-App

## Executive Summary

This document outlines the migration of the AssignX user-web design system to the Flutter mobile app. The user-web features a premium "Coffee Bean & Cream" design language with glass morphism, mesh gradients, and sophisticated animations that we'll adapt for mobile.

---

## 1. Color System Migration

### Current User-Web Colors (Coffee Bean Theme)

| Token | Value (oklch) | Hex Equivalent | Usage |
|-------|---------------|----------------|-------|
| **brand-coffee-bean** | oklch(0.44 0.06 35) | `#765341` | Primary accent |
| **brand-graphite** | oklch(0.22 0.01 35) | `#34312D` | Tertiary |
| **pitch-black** | oklch(0.12 0.008 30) | `#14110F` | Dark backgrounds |
| **vanilla-cream** | oklch(0.9 0.03 90) | `#E4E1C7` | Light accent |
| **warm-white** | oklch(0.985 0.002 60) | `#FEFDFB` | Light surfaces |

### Current User-App Colors (To Be Updated)

| Token | Current Hex | New Hex | Change |
|-------|-------------|---------|--------|
| **Primary** | `#A9714B` | `#765341` | Update to coffee-bean |
| **Accent** | `#E8985E` | `#9D7B65` | Update to warm brown |
| **Background** | `#FEFDFB` | `#FEFDFB` | Keep (matches) |
| **Surface** | `#F9F7F4` | `#FAF9F7` | Slight adjustment |

### Status Colors (Unified)
- **Success**: `#259369` (Sage green - earthy)
- **Warning**: `#F59E0B` (Warm amber)
- **Error**: `#DC352F` (Warm red)
- **Info**: `#2B93BE` (Balanced blue)

---

## 2. Typography System

### Font Configuration
- **Primary Font**: Inter (already in use)
- **Display Font**: Sora (consider adding for headings)

### Text Scale (Flutter)
```dart
// Display
displayLarge: 57px, weight: 300 (light)
displayMedium: 45px, weight: 400
displaySmall: 36px, weight: 400

// Headlines
headlineLarge: 32px, weight: 600
headlineMedium: 28px, weight: 600
headlineSmall: 24px, weight: 600

// Titles
titleLarge: 22px, weight: 600
titleMedium: 16px, weight: 500
titleSmall: 14px, weight: 500

// Body
bodyLarge: 16px, weight: 400
bodyMedium: 14px, weight: 400
bodySmall: 12px, weight: 400

// Labels
labelLarge: 14px, weight: 500
labelMedium: 12px, weight: 500
labelSmall: 11px, weight: 500
```

---

## 3. Component Migration

### 3.1 Glass Morphism Components

**Glass Container (New Widget)**
```dart
class GlassContainer extends StatelessWidget {
  // Properties
  final Widget child;
  final double blur;           // 12-24px
  final double opacity;        // 0.1-0.2
  final BorderRadius radius;   // 12-20px
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  // Implementation uses BackdropFilter + Container
}
```

**Usage Contexts:**
- Action cards (hover lift effect)
- Navigation pill
- Dock navigation
- Modal overlays

### 3.2 Dock Navigation (New Component)

**Features to Implement:**
- Fixed bottom center positioning
- Glass morphism background
- Icon magnification on press (60px magnitude)
- Active indicator with colored background
- Tooltip on long press
- Settings + Profile icons at ends
- Separator divider

**Migration from AppBottomNavBar:**
- Replace current tab bar with dock-style
- Keep FAB center for add project
- Add icon animation on tap
- Implement glass effect background

### 3.3 Card Designs

**Action Card Glass:**
```dart
class ActionCardGlass extends StatelessWidget {
  // Glass background with:
  // - blur(20px) saturate(180%)
  // - Semi-transparent border
  // - Multi-layer shadows
  // - Hover/press lift effect (-2px translateY)
}
```

**Project Card Updates:**
- Status badge with colored dot
- Progress bar for in_progress
- Last updated with clock icon
- Owner avatar at bottom

**Marketplace Item Card:**
- Image with skeleton loading
- Title with 2-line clamp
- Price with currency formatting
- Author with avatar

### 3.4 Hero Sections

**Curved Dome Hero (Wallet/Connect):**
```dart
class CurvedDomeHero extends StatelessWidget {
  final double height;         // 280-520px
  final Color gradientStart;
  final Color gradientEnd;
  final Widget child;

  // Implementation uses ClipPath with curved bottom
}
```

### 3.5 Mesh Gradient Backgrounds

**Positions:**
- Bottom-right (Dashboard, Wallet)
- Top-right (Projects)
- Center (Marketplace)

**Implementation:**
```dart
class MeshGradientBackground extends StatelessWidget {
  final MeshPosition position;  // topRight, bottomRight, center
  final bool animated;          // 20s rotation animation

  // Multiple RadialGradient layers
}
```

---

## 4. Animation System

### Page Transitions
```dart
// Initial state
opacity: 0, scale: 0.985, translateY: 12

// Animate state (350ms)
opacity: 1, scale: 1, translateY: 0

// Exit state (200ms)
opacity: 0, scale: 0.99, translateY: -8
```

### Easing Curves
```dart
// Entry ease
Curves.easeOutCubic  // [0.25, 0.46, 0.45, 0.94]

// Scale ease (springy)
Curves.elasticOut    // [0.34, 1.56, 0.64, 1]

// Exit ease
Curves.easeInQuad    // [0.55, 0, 1, 0.45]
```

### Stagger Animations
- Delay increment: 50ms per item
- Max items: 8-10 before batch
- Use AnimationController + Interval

### Hover/Press Effects
```dart
// Press down
scale: 0.97
shadow: reduced

// Release (bounce)
scale: 1.02 -> 1.0
shadow: enhanced
```

---

## 5. Screen-by-Screen Migration

### 5.1 Dashboard (Home Screen)

**Current State:**
- Services grid
- Promo carousel
- Campus pulse section

**Target State:**
- Greeting with user name + subtitle
- "Needs Attention" section with project list
- Bento grid with action cards (2 columns)
- Mesh gradient background (bottom-right)

**Components Needed:**
- DashboardGreeting
- NeedsAttentionSection
- BentoGrid
- BentoCard (with height animation)

### 5.2 Projects Screen

**Current State:**
- Tab navigation (status filters)
- Project cards in list

**Target State:**
- Glass tab container
- Bento grid for featured projects
- Glass project cards
- Status badges with dots
- Progress indicators

**Components Needed:**
- GlassTabBar
- ProjectCardGlass
- StatusBadge (updated)

### 5.3 Marketplace (Connect Screen)

**Current State:**
- Masonry grid
- Tutor cards
- Filter pills

**Target State:**
- Curved dome hero (280px)
- Search bar (glass style)
- Filter pills (updated styling)
- Masonry grid with glass cards
- Banner cards for featured

**Components Needed:**
- MarketplaceHero (curved dome)
- GlassSearchBar
- GlassFilterPills
- MarketplaceCardGlass

### 5.4 Wallet Screen

**Current State:**
- Basic wallet info
- Transaction list

**Target State:**
- Tall curved dome hero (520px)
- Credit card design (dark gradient)
- Balance widgets (2x2 grid mobile, 4 cols tablet)
- Transaction items with hover effect
- Offer pills (horizontal scroll)

**Components Needed:**
- WalletDomeHero
- CreditCardWidget
- BalanceWidgetGrid
- TransactionItem
- OfferPillsRow

### 5.5 Settings Screen

**Current State:**
- Section-based list
- Toggle switches
- Navigation items

**Target State:**
- Glass section containers
- Improved spacing
- Search functionality
- Sticky section headers

**Components Needed:**
- GlassSettingsSection
- SettingsSearchBar
- StickyHeader wrapper

### 5.6 Navigation (Global)

**Current State:**
- Bottom nav bar with FAB

**Target State:**
- Dock navigation (glass)
- Icon magnification
- Active indicator animation
- Tooltips

**Components Needed:**
- DockNavigation
- DockItem
- DockTooltip
- DockSeparator

---

## 6. Implementation Phases

### Phase 1: Foundation (Priority: Critical)
1. ✅ Update color constants
2. ✅ Create GlassContainer widget
3. ✅ Create MeshGradientBackground widget
4. ✅ Update theme configuration

### Phase 2: Navigation (Priority: High)
1. ✅ Create DockNavigation component
2. ✅ Implement icon magnification
3. ✅ Add glass effect background
4. ✅ Replace bottom nav bar

### Phase 3: Screens (Priority: High)
1. ✅ Update Dashboard layout (bento grid)
2. ✅ Update Projects page (glass cards)
3. ✅ Update Marketplace (curved hero)
4. ✅ Update Wallet (dome hero)

### Phase 4: Polish (Priority: Medium)
1. ✅ Add page transition animations
2. ✅ Implement stagger animations
3. ✅ Add micro-interactions
4. ✅ Refine shadows and effects

### Phase 5: QA (Priority: High)
1. ✅ Test on multiple devices
2. ✅ Verify accessibility
3. ✅ Performance profiling
4. ✅ Fix any visual bugs

---

## 7. File Changes Summary

### New Files to Create
```
lib/shared/widgets/
├── glass_container.dart
├── mesh_gradient_background.dart
├── curved_dome_hero.dart
└── dock_navigation.dart

lib/core/constants/
└── design_tokens.dart (new)

lib/shared/animations/
├── page_transitions.dart
└── stagger_animation.dart
```

### Files to Update
```
lib/core/constants/colors.dart         # Update color values
lib/core/theme/app_theme.dart          # Update theme
lib/shared/widgets/app_bottom_nav.dart # Replace with dock
lib/features/home/screens/home_screen.dart
lib/features/projects/screens/my_projects_screen.dart
lib/features/marketplace/screens/marketplace_screen.dart
lib/features/wallet/screens/wallet_screen.dart
lib/features/settings/screens/settings_screen.dart
```

---

## 8. Design Tokens Reference

### Spacing
```dart
const double spacingXxs = 4;
const double spacingXs = 8;
const double spacingSm = 12;
const double spacingMd = 16;
const double spacingLg = 24;
const double spacingXl = 32;
const double spacingXxl = 48;
const double spacingXxxl = 64;
```

### Border Radius
```dart
const double radiusXs = 4;
const double radiusSm = 8;
const double radiusMd = 12;
const double radiusLg = 16;
const double radiusXl = 20;
const double radiusXxl = 24;
const double radiusFull = 999;
```

### Shadows (Light Theme)
```dart
// Elevation 1 (subtle)
BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 4,
  offset: Offset(0, 2),
)

// Elevation 2 (cards)
BoxShadow(
  color: Color(0x0F000000),
  blurRadius: 8,
  offset: Offset(0, 4),
)

// Elevation 3 (modals)
BoxShadow(
  color: Color(0x14000000),
  blurRadius: 16,
  offset: Offset(0, 8),
)
```

### Glass Effect
```dart
// Standard glass
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
)

// Container color
Color(0xFFFFFFFE).withOpacity(0.85)

// Border color
Color(0xFFFFFFFF).withOpacity(0.3)
```

---

## 9. Accessibility Considerations

### Touch Targets
- Minimum 48x48 logical pixels
- 8px spacing between targets

### Color Contrast
- Text: 4.5:1 minimum (WCAG AA)
- Large text: 3:1 minimum
- Icons: 3:1 minimum

### Screen Readers
- All interactive elements have labels
- Image descriptions provided
- Navigation announcements

### Motion
- Respect `disableAnimations` setting
- Provide `reduceMotion` alternative
- Keep animations under 200ms for critical UI

---

## 10. Performance Considerations

### GPU Acceleration
- Use `Transform` for animations (not layout)
- Avoid `saveLayer` in lists
- Use `RepaintBoundary` for complex widgets

### Image Loading
- Lazy load off-screen images
- Use appropriate image sizes
- Implement skeleton placeholders

### List Performance
- Use `ListView.builder` always
- Implement `AutomaticKeepAliveClientMixin` sparingly
- Consider `SliverList` for complex scrolling

---

## Appendix: Color Conversion Reference

### oklch to Hex Conversion
```
oklch(0.44 0.06 35)  → #765341 (coffee bean)
oklch(0.22 0.01 35)  → #34312D (graphite)
oklch(0.12 0.008 30) → #14110F (pitch black)
oklch(0.9 0.03 90)   → #E4E1C7 (vanilla cream)
oklch(0.985 0.002 60)→ #FEFDFB (warm white)
```

### Gradient Definitions
```dart
// Primary gradient
LinearGradient(
  colors: [Color(0xFF765341), Color(0xFF5A3F31)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Warm gradient
LinearGradient(
  colors: [Color(0xFF765341), Color(0xFFC4956C)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

*Document created: 2026-01-16*
*Version: 1.0*
*Author: Hive Mind Collective*

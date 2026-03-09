# Doer App Design Overhaul - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Redesign all 28 screens in the doer_app Flutter mobile app to match the premium, warm design quality of the user_app — featuring mesh gradients, glassmorphism, warm color palette, smooth animations, and polished typography.

**Architecture:** The redesign includes both a **layout architecture change** (sidebar drawer → floating bottom navbar with MainShell + IndexedStack) and a **visual overhaul**. Phase 0 replaces the sidebar with user_app's navigation pattern: MainShell wraps 5 tabs (Dashboard, Projects, Resources, Earnings, Profile) in an IndexedStack with a floating pill-shaped BottomNavBar. GoRouter is restructured so `/dashboard` loads MainShell. Then we replace the Navy Blue (#1E3A5F) theme with "Deep Teal" (#1A4B5F) + mesh gradients, glassmorphism, and smooth animations across all 28 screens.

**Tech Stack:** Flutter 3.41+, Dart 3.11+, Riverpod, GoRouter, Material 3

---

## Design System Analysis

### User App (reference - what we're matching)
- **Primary:** Coffee Bean (#765341) — warm, trustworthy
- **Background:** Warm white (#FEFDFB) with pastel mesh gradients (pink, peach, lavender) emanating from corners
- **Cards:** Glassmorphism with backdrop blur, 0.85 opacity, subtle white borders
- **Gradients:** Primary gradient (Pitch Black -> Dark Brown -> Warm Brown)
- **Navigation:** Dock-style bottom nav with rounded pill shape, frosted glass
- **Typography:** Inter font, large greeting headers ("Good Morning, Om"), generous whitespace
- **Animations:** Fade-scale for auth, slide-right for navigation, spring curves
- **Status colors:** Soft green (#259369), warm amber, coral red

### Doer App (current - what we're changing FROM)
- **Primary:** Navy Blue (#1E3A5F) — cold, corporate
- **Background:** Flat gray-blue (#F8FAFC)
- **Cards:** Standard elevation shadows, no blur
- **Navigation:** Sidebar drawer (hamburger menu) — needs full replacement
- **Layout:** Flat routes, no shell, each screen has its own Scaffold + drawer
- **Typography:** Inter font but smaller headers, tighter spacing

### Doer App (target - what we're changing TO)
- **Primary:** Deep Teal (#1A4B5F) — professional but warmer than pure navy
- **Accent:** Vivid Cyan (#06B6D4) — energetic, earning-focused
- **Background:** Warm off-white (#FAFBFC) with teal/cyan/mint mesh gradients from corners
- **Cards:** Glassmorphism matching user_app (backdrop blur 20, opacity 0.85, white borders)
- **Gradients:** Teal gradient (Dark Teal -> Teal -> Cyan) for hero sections
- **Navigation:** Floating pill-shaped bottom nav bar (dark #1A1A1A, borderRadius 30) — NO sidebar
- **Layout:** MainShell + IndexedStack (5 tabs) + SubtleGradientScaffold wrapper
- **Typography:** Inter font, large greeting headers, generous whitespace
- **Animations:** Matching user_app page transitions
- **Status colors:** Same as user_app for consistency

---

## Phase 0: Layout Architecture (Sidebar → Bottom Navbar)

> **Critical:** These tasks MUST be completed first. They replace the sidebar drawer pattern
> with a MainShell + floating BottomNavBar + IndexedStack architecture matching the user_app.

### Task 0A: Create Navigation Provider

**Files:**
- Modify: `doer_app/lib/providers/dashboard_provider.dart` (or create `doer_app/lib/providers/navigation_provider.dart`)

**Step 1: Add navigation index state provider**

```dart
/// Tracks which tab is active in the bottom nav bar.
/// 0: Dashboard, 1: Projects, 2: Resources, 3: Earnings, 4: Profile
final navigationIndexProvider = StateProvider<int>((ref) => 0);
```

**Step 2: Commit**

```bash
git add doer_app/lib/providers/
git commit -m "feat(doer): add navigation index provider for bottom nav"
```

---

### Task 0B: Create SubtleGradientScaffold (moved from Task 20)

**Files:**
- Create: `doer_app/lib/shared/widgets/subtle_gradient_scaffold.dart`
- Reference: `user_app/lib/shared/widgets/subtle_gradient_scaffold.dart`

**Step 1: Create gradient scaffold with GradientOrb system**

Port the user_app's SubtleGradientScaffold exactly, but with teal/cyan orb colors:
- `GradientOrb` class with `BlobPosition` enum (topLeft, topRight, bottomLeft, bottomRight, centerLeft, centerRight)
- Radial gradient blobs positioned at corners, ~200-300px radius, low opacity (0.15-0.25)
- `SubtleGradientScaffold.standard()` factory with default teal/cyan/mint orbs
- Support custom orb configurations per screen
- Background: AppColors.background (#FAFBFC)
- Orb colors: teal (#99F6E4), cyan (#A5F3FC), mint (#A7F3D0), lavender (#C7D2FE)

**Step 2: Verify renders**

Run: `cd doer_app && flutter analyze`

**Step 3: Commit**

```bash
git add doer_app/lib/shared/widgets/subtle_gradient_scaffold.dart
git commit -m "feat(doer): add gradient scaffold with corner orbs matching user_app"
```

---

### Task 0C: Create Floating BottomNavBar

**Files:**
- Create: `doer_app/lib/features/dashboard/widgets/bottom_nav_bar.dart`
- Reference: `user_app/lib/features/dashboard/widgets/bottom_nav_bar.dart`

**Step 1: Create floating pill-shaped bottom nav bar**

Match user_app's BottomNavBar exactly:
- Floating pill shape: height 60, borderRadius 30
- Dark background (#1A1A1A) — NOT frosted glass, matches user_app's dark dock
- Positioned: bottom 20, left 16, right 16
- Box shadows for floating effect (black 0.20 blur 16, black 0.10 blur 32)
- 5 items with Lucide icons:
  - 0: Dashboard (LucideIcons.layoutDashboard)
  - 1: Projects (LucideIcons.folderClosed / folder)
  - 2: Resources (LucideIcons.bookOpen)
  - 3: Earnings (LucideIcons.wallet)
  - 4: Profile (avatar circle, like user_app)
- Active: white icon, Inactive: #8A8A8A
- Profile item shows avatar circle with border (white active, gray inactive)
- Material InkWell with borderRadius 30 for tap feedback
- Accepts: `currentIndex`, `onTap`, `profileImageUrl`

**Step 2: Verify compiles**

Run: `cd doer_app && flutter analyze`

**Step 3: Commit**

```bash
git add doer_app/lib/features/dashboard/widgets/bottom_nav_bar.dart
git commit -m "feat(doer): add floating pill-shaped bottom nav bar matching user_app"
```

---

### Task 0D: Create MainShell with IndexedStack

**Files:**
- Create: `doer_app/lib/features/home/screens/main_shell.dart`
- Reference: `user_app/lib/features/home/screens/main_shell.dart`

**Step 1: Create MainShell widget**

```dart
class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    // Get avatar URL from doer profile provider

    return SubtleGradientScaffold.standard(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: const [
              DashboardScreen(),     // 0: Dashboard
              MyProjectsScreen(),    // 1: Projects
              ResourcesHubScreen(),  // 2: Resources
              PaymentHistoryScreen(),// 3: Earnings
              ProfileScreen(),       // 4: Profile
            ],
          ),
          BottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => ref.read(navigationIndexProvider.notifier).state = index,
            profileImageUrl: avatarUrl,
          ),
        ],
      ),
    );
  }
}
```

Key: IndexedStack preserves state of all tabs (no rebuild on switch).

**Step 2: Create directory structure**

```bash
mkdir -p doer_app/lib/features/home/screens
```

**Step 3: Verify compiles**

Run: `cd doer_app && flutter analyze`

**Step 4: Commit**

```bash
git add doer_app/lib/features/home/
git commit -m "feat(doer): add MainShell with IndexedStack and bottom nav"
```

---

### Task 0E: Restructure GoRouter with ShellRoute

**Files:**
- Modify: `doer_app/lib/core/router/app_router.dart`
- Modify: `doer_app/lib/core/router/route_names.dart`

**Step 1: Add `/home` route name**

In `route_names.dart`, add:
```dart
static const String home = '/home';
```

**Step 2: Wrap main tab routes in ShellRoute**

Replace the flat dashboard/projects/resources/profile GoRoutes with a ShellRoute:

```dart
// Main shell with bottom nav (replaces flat routes)
ShellRoute(
  builder: (context, state, child) => const MainShell(),
  routes: [
    GoRoute(
      path: RouteNames.dashboard,
      name: 'dashboard',
      builder: (context, state) => const SizedBox.shrink(), // MainShell handles via IndexedStack
    ),
  ],
),
```

**Important:** Since MainShell uses IndexedStack (not the child from ShellRoute), the ShellRoute child is ignored. The ShellRoute just ensures MainShell wraps these routes. Tab switching is handled by `navigationIndexProvider`, not by GoRouter navigation.

Alternative approach (simpler): Keep dashboard as a single route that shows MainShell:
```dart
GoRoute(
  path: RouteNames.dashboard,
  name: 'dashboard',
  builder: (context, state) => const MainShell(),
),
```

Then update redirect logic so activated users go to `/dashboard` which shows MainShell. Tab screens are managed internally by IndexedStack — no separate routes needed for Projects/Resources/Profile tabs.

Detail screens (project/:id, workspace, etc.) remain as separate top-level routes that push on top of MainShell.

**Step 3: Update redirect for activated users**

Change the redirect target from `RouteNames.dashboard` to `RouteNames.dashboard` (same, but now it loads MainShell).

**Step 4: Verify routing works**

Run: `cd doer_app && flutter analyze`

**Step 5: Commit**

```bash
git add doer_app/lib/core/router/
git commit -m "feat(doer): restructure router to use MainShell for tab navigation"
```

---

### Task 0F: Remove Sidebar Drawer & Update Screen References

**Files:**
- Delete: `doer_app/lib/features/dashboard/widgets/app_drawer.dart`
- Modify: `doer_app/lib/features/dashboard/screens/dashboard_screen.dart`
- Modify: `doer_app/lib/features/resources/screens/resources_hub_screen.dart`
- Modify: `doer_app/lib/features/profile/screens/profile_screen.dart`
- Modify: `doer_app/lib/features/dashboard/screens/statistics_screen.dart`
- Modify: `doer_app/lib/features/dashboard/widgets/app_header.dart`

**Step 1: Remove all `drawer:` and `AppDrawer()` references from Scaffolds**

In each screen file, remove:
- `import '...app_drawer.dart'`
- `drawer: const AppDrawer(),` from Scaffold
- Any hamburger menu icon in AppBar (replace with back button or remove)
- Any `Scaffold.of(context).openDrawer()` calls

**Step 2: Add bottom padding to scrollable content**

Each tab screen needs `SizedBox(height: 100)` at bottom of scroll content to avoid overlap with floating bottom nav bar.

**Step 3: Remove SubtleGradientScaffold/MeshGradient from individual tab screens**

Since MainShell already wraps everything in SubtleGradientScaffold, individual tab screens should NOT add their own gradient background. They should use transparent/no background Scaffold or just return their content widget.

**Step 4: Delete app_drawer.dart**

```bash
rm doer_app/lib/features/dashboard/widgets/app_drawer.dart
```

**Step 5: Verify compiles**

Run: `cd doer_app && flutter analyze`

**Step 6: Commit**

```bash
git add -A doer_app/lib/features/
git commit -m "feat(doer): remove sidebar drawer, update screens for bottom nav layout"
```

---

## Phase 1: Design Foundation (Core Theme & Shared Widgets)

### Task 1: Update Color Palette

**Files:**
- Modify: `doer_app/lib/core/constants/app_colors.dart`

**Step 1: Replace the entire color palette**

Update `AppColors` to the new warm-professional palette:

```dart
// PRIMARY COLORS - Deep Teal (warmer than navy)
static const Color primary = Color(0xFF1A4B5F);
static const Color primaryLight = Color(0xFF2A5B6F);
static const Color primaryDark = Color(0xFF0A3B4F);

// ACCENT COLORS - Vivid Cyan (energetic, earning-focused)
static const Color accent = Color(0xFF06B6D4);
static const Color accentLight = Color(0xFF22D3EE);
static const Color accentDark = Color(0xFF0891B2);

// BACKGROUND - Warmer off-whites
static const Color background = Color(0xFFFAFBFC);
static const Color surface = Color(0xFFFFFFFF);
static const Color surfaceVariant = Color(0xFFF1F5F9);

// GRADIENT COLORS - Teal to Cyan
static const Color gradientStart = Color(0xFF0A3B4F);
static const Color gradientMiddle = Color(0xFF1A4B5F);
static const Color gradientEnd = Color(0xFF06B6D4);

// MESH GRADIENT COLORS - Soft pastels for corner gradients
static const Color meshTeal = Color(0xFFCCFBF1);
static const Color meshCyan = Color(0xFFCFFAFE);
static const Color meshMint = Color(0xFFD1FAE5);
static const Color meshLavender = Color(0xFFE0E7FF);
static const Color meshPeach = Color(0xFFFFEDD5);
static const Color meshPink = Color(0xFFFFE4E6);
```

**Step 2: Run `flutter analyze` to ensure no compilation errors**

Run: `cd doer_app && flutter analyze`
Expected: No errors (warnings ok)

**Step 3: Commit**

```bash
git add doer_app/lib/core/constants/app_colors.dart
git commit -m "feat(doer): update color palette to warm-professional teal theme"
```

---

### Task 2: Update App Theme

**Files:**
- Modify: `doer_app/lib/core/theme/app_theme.dart`

**Step 1: Update Material 3 theme to use new palette**

Key changes:
- ColorScheme.fromSeed with new primary (#1A4B5F)
- AppBar: transparent with no elevation (content shows through mesh gradients)
- Cards: borderRadius 20, no elevation, white with 0.85 opacity
- Buttons: rounded pill shapes (borderRadius 14+), gradient fills
- Input fields: rounded borders with subtle teal accent
- Navigation bar: transparent for dock-style overlay
- Page transitions: fade-scale matching user_app

**Step 2: Verify theme compiles**

Run: `cd doer_app && flutter analyze`

**Step 3: Commit**

```bash
git add doer_app/lib/core/theme/app_theme.dart
git commit -m "feat(doer): update Material 3 theme for warm-professional design"
```

---

### Task 3: Upgrade MeshGradientBackground Widget

**Files:**
- Modify: `doer_app/lib/shared/widgets/mesh_gradient_background.dart`

**Step 1: Update mesh gradient to use new teal/cyan/mint pastel colors**

Match the user_app's mesh gradient approach:
- Soft radial gradients emanating from corners
- Support for `MeshPosition` (topRight, bottomRight, center, topLeft, bottomLeft)
- Animated opacity/position for subtle breathing effect
- Colors: meshTeal, meshCyan, meshMint, meshLavender

The mesh background should create the same "colored glow from corners" effect seen in the user_app's warm pink/purple corner glows, but using teal/cyan tones.

**Step 2: Verify renders correctly**

Run: `cd doer_app && flutter run -d <simulator_id>` and check splash screen

**Step 3: Commit**

```bash
git add doer_app/lib/shared/widgets/mesh_gradient_background.dart
git commit -m "feat(doer): upgrade mesh gradients with teal/cyan corner glows"
```

---

### Task 4: Upgrade GlassContainer Widget

**Files:**
- Modify: `doer_app/lib/shared/widgets/glass_container.dart`

**Step 1: Match user_app's GlassContainer exactly**

Key properties to match:
- Default blur: 20
- Default opacity: 0.85
- Border: 1px white at 0.3 opacity
- Border radius: 16 (AppSpacing.radiusLg)
- Support for: onTap with scale animation, gradient overlay, shadow
- Hover/press feedback with subtle scale (0.98) animation
- Support `isElevated` prop for raised glass effect

**Step 2: Verify glass effect renders**

**Step 3: Commit**

```bash
git add doer_app/lib/shared/widgets/glass_container.dart
git commit -m "feat(doer): upgrade glass container to match user_app quality"
```

---

### Task 5: Upgrade AppButton Widget

**Files:**
- Modify: `doer_app/lib/shared/widgets/app_button.dart`

**Step 1: Update button styles**

- Primary: Teal gradient fill (gradientStart -> gradientEnd), white text, pill shape (radius 14)
- Secondary: Glass container with teal border, teal text
- Tertiary: Text-only with teal color
- All buttons: press scale animation (0.97), loading state with shimmer
- Icon support with proper spacing
- Match the user_app's button proportions (height 52, padding 24h)

**Step 2: Commit**

```bash
git add doer_app/lib/shared/widgets/app_button.dart
git commit -m "feat(doer): upgrade buttons with gradient fills and press animations"
```

---

### Task 6: Upgrade AppCard Widget

**Files:**
- Modify: `doer_app/lib/shared/widgets/app_card.dart`

**Step 1: Replace elevation-based cards with glass cards**

- Default: GlassContainer wrapper with blur 15, opacity 0.9
- Elevated variant: blur 20, subtle shadow, scale-on-tap
- Stat card variant: with gradient accent strip at top
- Match the user_app's card proportions (padding 20, radius 20)

**Step 2: Commit**

```bash
git add doer_app/lib/shared/widgets/app_card.dart
git commit -m "feat(doer): upgrade cards to glassmorphism style"
```

---

### Task 7: (COMPLETED IN PHASE 0 — Task 0C)

> Bottom navigation bar was created in Phase 0, Task 0C. Skip this task.

---

### Task 8: Add Page Transitions

**Files:**
- Create: `doer_app/lib/shared/animations/page_transitions.dart`
- Modify: `doer_app/lib/core/router/app_router.dart`
- Reference: `user_app/lib/shared/animations/page_transitions.dart`

**Step 1: Create transition classes**

Match user_app transitions:
- `FadeScaleTransition`: For auth screens (login, register) - fade in + slight scale up
- `SlideRightTransition`: For navigation between main screens - slide from right
- `SlideUpTransition`: For modals and detail screens - slide from bottom
- Duration: 300ms with `Curves.easeOutCubic`

**Step 2: Apply transitions in GoRouter**

Update `app_router.dart` to use custom page builders for each route group:
- Auth routes: FadeScale
- Main tab routes: SlideRight
- Detail/modal routes: SlideUp

**Step 3: Commit**

```bash
git add doer_app/lib/shared/animations/page_transitions.dart doer_app/lib/core/router/app_router.dart
git commit -m "feat(doer): add smooth page transitions matching user_app"
```

---

## Phase 2: Screen-by-Screen Redesign

### Task 9: Splash Screen

**Files:**
- Modify: `doer_app/lib/features/splash/splash_screen.dart`

**Changes:**
- Full-screen mesh gradient background (teal/cyan from corners)
- Centered logo with scale-in animation (spring curve, 800ms)
- Subtle shimmer effect on brand name
- Smooth fade-out transition to next screen

**Commit:** `feat(doer): redesign splash with mesh gradient and animations`

---

### Task 10: Onboarding Screen

**Files:**
- Modify: `doer_app/lib/features/onboarding/screens/onboarding_screen.dart`
- Modify: `doer_app/lib/features/onboarding/screens/profile_setup_screen.dart`

**Changes:**
- Mesh gradient background per page (different MeshPosition per slide)
- Glass card containers for content
- Large illustrations with subtle parallax on swipe
- Pill-shaped page indicators with teal accent
- CTA buttons: gradient-filled primary buttons
- "Skip" as tertiary text button

**Commit:** `feat(doer): redesign onboarding with mesh gradients and glass cards`

---

### Task 11: Login & Register Screens

**Files:**
- Modify: `doer_app/lib/features/auth/screens/login_screen.dart`
- Modify: `doer_app/lib/features/auth/screens/register_screen.dart`

**Changes:**
- Full mesh gradient background (topRight position)
- Glass container for the form area
- Large brand header at top ("Welcome Back" / "Join as a Doer")
- Input fields: rounded borders, subtle teal focus color, glass background
- OTP input: individual digit boxes with teal accent
- Primary CTA: gradient-filled button, full width
- Social login buttons: glass containers with icons
- FadeScale page transition

**Commit:** `feat(doer): redesign auth screens with premium glass form styling`

---

### Task 12: Activation Flow (4 screens)

**Files:**
- Modify: `doer_app/lib/features/activation/screens/activation_gate_screen.dart`
- Modify: `doer_app/lib/features/activation/screens/training_screen.dart`
- Modify: `doer_app/lib/features/activation/screens/quiz_screen.dart`
- Modify: `doer_app/lib/features/activation/screens/bank_details_screen.dart`

**Changes:**
- Mesh gradient backgrounds with progress indicator at top
- Step indicator: horizontal dots with teal gradient fill for completed steps
- Glass cards for content sections
- Quiz: glass option cards with teal border on selection, scale animation
- Bank details: glass form with secure-feeling design (lock icon, shield badge)
- Consistent large headings with emoji accents (matching user_app style)

**Commit:** `feat(doer): redesign activation flow with step indicators and glass cards`

---

### Task 13: Dashboard Screen (main hub)

**Files:**
- Modify: `doer_app/lib/features/dashboard/screens/dashboard_screen.dart`

**Changes:**
This is the most important screen. Match user_app's home screen design.
**Note:** Dashboard is now a tab inside MainShell — do NOT add Scaffold/drawer/gradient background.
Return content widget directly (Column/ListView). MainShell handles gradient + nav bar.

- **No Scaffold** — return scrollable content directly (or Scaffold with transparent bg, no appBar)
- Large greeting: "Good Morning, **Om**" with emoji (matching user_app typography)
- Subtitle: "Welcome back to your workspace"
- Status pills: "Active 3", "Pending 0" in glass pills
- Quick action cards in grid (right side):
  - "Open Pool" — dark gradient card with arrow (like user_app's "New Project" card)
  - "Assigned Tasks" / "Earnings" — smaller glass stat cards with accent icons
- Performance section: glass cards with progress bars
- Task list section: glass cards with status badges, earnings amount, deadline
- **Bottom padding: SizedBox(height: 100)** to clear the floating nav bar

**Commit:** `feat(doer): redesign dashboard with mesh gradients, glass cards, dock nav`

---

### Task 14: My Projects Screen

**Files:**
- Modify: `doer_app/lib/features/projects/screens/my_projects_screen.dart`

**Changes:**
- Mesh gradient background
- Large header: "Good Morning, **Om**" with project count subtitle
- Quick action card: "Browse Open Pool" dark gradient card (top right)
- Stat cards: "Active Projects" / "Completed" in glass cards with accent icons
- Tab bar: pill-shaped active tab (teal filled), inactive glass
- Project cards: glass containers with:
  - Status badge (colored pill)
  - Project title (bold)
  - Project ID subtitle
  - Deadline with icon
  - Earnings amount with rupee icon
- Search bar: glass container with search icon

**Commit:** `feat(doer): redesign projects screen matching user_app layout`

---

### Task 15: Project Detail & Workspace Screens

**Files:**
- Modify: `doer_app/lib/features/workspace/screens/project_detail_screen.dart`
- Modify: `doer_app/lib/features/workspace/screens/workspace_screen.dart`
- Modify: `doer_app/lib/features/workspace/screens/submit_work_screen.dart`
- Modify: `doer_app/lib/features/workspace/screens/revision_screen.dart`
- Modify: `doer_app/lib/features/workspace/screens/chat_screen.dart`

**Changes:**
- Project detail: glass hero card at top with status, earnings, deadline
- Timeline: vertical line with glass milestone cards
- Workspace: glass container with file upload area, progress tracker
- Submit: glass form with file attachment, notes field, gradient submit button
- Revision: glass cards for revision notes, diff indicators
- Chat: glass message bubbles (sent: teal gradient, received: white glass)

**Commit:** `feat(doer): redesign workspace screens with glass cards and chat bubbles`

---

### Task 16: Resources Hub Screens

**Files:**
- Modify: `doer_app/lib/features/resources/screens/resources_hub_screen.dart`
- Modify: `doer_app/lib/features/resources/screens/training_center_screen.dart`
- Modify: `doer_app/lib/features/resources/screens/citation_builder_screen.dart`
- Modify: `doer_app/lib/features/resources/screens/format_templates_screen.dart`

**Changes:**
- Hub: mesh gradient, glass tool cards in bento grid layout
- Training: progress ring with teal gradient, glass module cards
- Citation builder: glass form with preview card
- Templates: glass grid cards with category badges

**Commit:** `feat(doer): redesign resources hub with bento grid and glass tools`

---

### Task 17: Statistics & Reviews Screens

**Files:**
- Modify: `doer_app/lib/features/dashboard/screens/statistics_screen.dart`
- Modify: `doer_app/lib/features/dashboard/screens/reviews_screen.dart`

**Changes:**
- Statistics: mesh gradient background, glass stat cards, chart cards with glass containers
- Reviews: glass review cards with star ratings (teal filled stars), avatar circles

**Commit:** `feat(doer): redesign statistics and reviews with glass data cards`

---

### Task 18: Profile & Settings Screens

**Files:**
- Modify: `doer_app/lib/features/profile/screens/profile_screen.dart`
- Modify: `doer_app/lib/features/profile/screens/edit_profile_screen.dart`
- Modify: `doer_app/lib/features/profile/screens/payment_history_screen.dart`
- Modify: `doer_app/lib/features/profile/screens/settings_screen.dart`
- Modify: `doer_app/lib/features/profile/screens/notifications_screen.dart`
- Modify: `doer_app/lib/features/support/screens/support_screen.dart`

**Changes:**
- Profile: glass hero card with avatar, name, badges, stats row
- Edit profile: glass form containers with avatar upload
- Payment history: glass transaction cards with amount, date, status
- Settings: glass section cards with toggle switches
- Notifications: glass notification cards with type icons
- Support: glass FAQ cards, contact glass card

**Commit:** `feat(doer): redesign profile and settings with glass containers`

---

## Phase 3: Polish & Consistency

### Task 19: Add Skeleton Loaders

**Files:**
- Create: `doer_app/lib/shared/widgets/skeleton_loader.dart`
- Reference: `user_app/lib/shared/widgets/skeleton_loader.dart`

**Changes:**
- Shimmer skeleton loaders for all list screens
- Glass container shape matching actual card shapes
- Teal shimmer gradient animation

**Commit:** `feat(doer): add skeleton loaders for loading states`

---

### Task 20: (COMPLETED IN PHASE 0 — Task 0B)

> SubtleGradientScaffold was created in Phase 0, Task 0B. Skip this task.

---

### Task 21: Final Consistency Pass

**Files:**
- All 28 screen files

**Changes:**
- Verify every screen uses SubtleGradientScaffold or MeshGradientBackground
- Verify all cards use GlassContainer
- Verify all buttons use updated AppButton
- Verify dock navigation appears on all main screens
- Verify page transitions work for all routes
- Test dark mode renders correctly
- Test on both iPhone and Android simulators

**Commit:** `feat(doer): final design consistency pass across all screens`

---

## Screen Count Summary

| Phase | Tasks | Description |
|-------|-------|-------------|
| Phase 0 | 6 tasks (0A–0F) | Layout architecture: sidebar → bottom navbar, MainShell, router |
| Phase 1 | 8 tasks (1–8) | Foundation: colors, theme, widgets, transitions (Task 7 done in Phase 0) |
| Phase 2 | 10 tasks (9–18) | All 28 screens redesigned |
| Phase 3 | 3 tasks (19–21) | Skeleton loaders, consistency pass (Task 20 done in Phase 0) |
| **Total** | **27 tasks** | 6 new layout tasks + 21 original (2 consolidated into Phase 0) |

## Key Design Tokens Reference

```
Primary:        #1A4B5F (Deep Teal)
Accent:         #06B6D4 (Vivid Cyan)
Background:     #FAFBFC (Warm Off-White)
Mesh Teal:      #CCFBF1
Mesh Cyan:      #CFFAFE
Mesh Mint:      #D1FAE5
Mesh Lavender:  #E0E7FF
Glass Blur:     20
Glass Opacity:  0.85
Border Radius:  16 (cards), 14 (buttons), 28 (dock nav)
Transition:     300ms easeOutCubic
Font:           Inter
```

# User App Auth Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign all auth screens in user_app to use warm flat design (no glass morphism), enforce .edu email for student signups, and align the mobile flow with the web.

**Architecture:** Replace glass morphism/mesh gradient backgrounds with solid warm white. Replace Lottie network URLs with local SVG/icon illustrations. Add college email validation in the signup screen when user type is student. All screens keep the same routing and auth logic — only the UI layer and the email validation gate change.

**Tech Stack:** Flutter, Riverpod, GoRouter, flutter_animate, flutter_svg, confetti

**Spec:** `docs/superpowers/specs/2026-03-24-user-app-auth-redesign-design.md`

---

## File Structure

| Action | File | Responsibility |
|--------|------|----------------|
| Create | `lib/core/utils/email_validators.dart` | Shared college email domain validation |
| Rewrite | `lib/features/onboarding/screens/onboarding_screen.dart` | Onboarding carousel — remove doodles/gradients/Lottie, clean layout |
| Rewrite | `lib/features/auth/screens/login_screen.dart` | Login — remove glass/mesh/Lottie, solid cards |
| Rewrite | `lib/features/auth/screens/user_type_screen.dart` | User type — remove glass/mesh, add .edu hint on student card |
| Rewrite | `lib/features/auth/screens/signin_screen.dart` | Signup — remove glass/mesh/Lottie, add .edu validation for students |
| Modify | `lib/features/onboarding/screens/profile_completion_screen.dart` | Replace GlassContainer/MeshGradientBackground with solid containers |
| Modify | `lib/features/onboarding/screens/role_selection_screen.dart` | Replace GlassContainer/MeshGradientBackground with solid containers |
| Modify | `lib/features/onboarding/screens/student_profile_screen.dart` | Replace GlassContainer/MeshGradientBackground with solid containers |
| Modify | `lib/features/onboarding/screens/professional_profile_screen.dart` | Replace GlassContainer/MeshGradientBackground with solid containers |
| Rewrite | `lib/features/onboarding/screens/signup_success_screen.dart` | Success screen — remove glass/mesh, clean layout |

---

### Task 1: Create Email Validator Utility

**Files:**
- Create: `lib/core/utils/email_validators.dart`

- [ ] **Step 1: Create the email validator file**

```dart
/// Shared email validation utilities.
class EmailValidators {
  EmailValidators._();

  static final _collegeEmailPatterns = [
    RegExp(r'\.edu$', caseSensitive: false),
    RegExp(r'\.ac\.in$', caseSensitive: false),
    RegExp(r'\.edu\.in$', caseSensitive: false),
    RegExp(r'\.ac\.uk$', caseSensitive: false),
    RegExp(r'\.edu\.au$', caseSensitive: false),
    RegExp(r'\.edu\.ca$', caseSensitive: false),
  ];

  /// Returns true if the email belongs to an educational institution.
  static bool isCollegeEmail(String email) {
    final parts = email.toLowerCase().split('@');
    if (parts.length != 2) return false;
    final domain = parts[1];
    return _collegeEmailPatterns.any((pattern) => pattern.hasMatch(domain));
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd /Volumes/Crucial\ X9/AssignX/user_app && flutter analyze lib/core/utils/email_validators.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add lib/core/utils/email_validators.dart
git commit -m "feat(user_app): add college email validator utility"
```

---

### Task 2: Redesign Onboarding Carousel

**Files:**
- Rewrite: `lib/features/onboarding/screens/onboarding_screen.dart`

The current screen uses Lottie network URLs, gradient backgrounds with animated color transitions, decorative doodle elements (rings, circles, squiggles, crosses, triangles via CustomPainter), and a curved bottom clipper. Replace all of this with a clean flat design.

- [ ] **Step 1: Rewrite onboarding_screen.dart**

Key changes from current implementation:
- Remove all `_Doodle*` widgets (`_DoodleRing`, `_DoodleCircle`, `_DoodleDots`, `_DoodleSquiggle`, `_DoodleCross`, `_DoodleTriangle` and their painters)
- Remove `_AnimatedGradientBackground` widget (the animated color-transitioning gradient)
- Remove `_CurvedBottomClipper` (the curved bottom edge clipper)
- Remove `_LottieAnimation` widget and all Lottie network URLs
- Remove the `lottie` import
- Keep: `PageController`, `_currentPage`, auto-scroll timer logic, `_completeOnboarding()`, `_nextPage()`, `SharedPreferences`, page dots, button logic
- Background: solid `AppColors.background` (`#FEFDFB`)
- Top section (~55% height): Solid warm brown container with `BorderRadius.vertical(bottom: Radius.circular(32))` — use `AppColors.primary` as background. Center a large `Icon` per slide (e.g. `Icons.school_rounded`, `Icons.assignment_rounded`, `Icons.rocket_launch_rounded`) at 80px, white color.
- Bottom section: Title (32px bold, `AppColors.textPrimary`), subtitle (14px, `AppColors.textSecondary`), dot indicators (active = `AppColors.primary` pill 24x8, inactive = `AppColors.border` circle 8x8), button, "Already have an account? Sign in" link.
- Keep `AnimatedContainer` for dot width transitions.
- Keep `flutter_animate` for title/subtitle entrance (fadeIn + slideY on page change).
- Slides 1-2: circular arrow button (64x64, `AppColors.primary`, white arrow). Slide 3: full-width "Get Started" pill button.

- [ ] **Step 2: Hot restart and verify on simulator**

Run: Press `R` in the flutter run terminal to hot restart.
Expected: Onboarding shows 3 slides with icons, clean white background, no gradients/doodles/Lottie. Auto-scroll works. "Get Started" navigates to login.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/screens/onboarding_screen.dart
git commit -m "feat(user_app): redesign onboarding carousel with flat design"
```

---

### Task 3: Redesign Login Screen

**Files:**
- Rewrite: `lib/features/auth/screens/login_screen.dart`

The current screen uses `_MeshGradientBackground` (3 radial gradient layers), `BackdropFilter` glass card (`_GlassCard`), `_LottieHero` with network URL and floating sin-wave animation, and a gradient button (`LinearGradient` on `DecoratedBox`). Replace all of this.

- [ ] **Step 1: Rewrite login_screen.dart**

Key changes from current implementation:
- Remove `_MeshGradientBackground` widget (the 3-layer radial gradient stack)
- Remove `_GlassCard` widget (the `ClipRRect` + `BackdropFilter` bottom card)
- Remove `_LottieHero` widget (the Lottie network animation with floating sin-wave `AnimatedBuilder`)
- Remove `_handleIndicator()` (the gray drag handle bar)
- Remove `_floatController` AnimationController (was for Lottie float)
- Remove `lottie` and `dart:math` imports
- Remove `TickerProviderStateMixin` (no longer needed — no AnimationControllers)
- Keep: all auth logic (`_onContinue`, `_onVerify`, `_onResend`, `_goBackToEmail`, `_clearOtp`), `_emailController`, `_otpControllers`, `_otpFocusNodes`, `_isLoading`, `_resendCooldown`, timer logic
- Background: solid `AppColors.background`
- Top area: AssignX logo centered (SvgPicture + text), then a centered `Icon(Icons.lock_open_rounded, size: 64, color: AppColors.primary)` with a tinted circle container (100x100, `AppColors.primary.withOpacity(0.1)`, circle shape)
- Bottom card: Replace `_GlassCard` with a plain `Container` — `decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, -2))])`. Wrap content in `SingleChildScrollView`. Add `EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 16)` padding.
- Button: Replace gradient `DecoratedBox` + `ElevatedButton` with a simple `SizedBox(width: double.infinity, height: 48, child: ElevatedButton(...))` using `backgroundColor: AppColors.primary`, `foregroundColor: Colors.white`, `borderRadius: 24`, `elevation: 0`.
- OTP fields: Keep same layout but use `fillColor: AppColors.surfaceVariant` instead of `AppColors.surfaceVariant` (already correct). Keep `borderRadius: 10`.
- Keep `AnimatedSwitcher` for email↔OTP transition.

- [ ] **Step 2: Hot restart and verify**

Run: Press `R` in flutter run terminal.
Expected: Login screen shows clean white background, icon illustration, solid bottom card with email field, no glass blur, no mesh gradient, no Lottie. OTP flow works. Navigation to signup works.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/screens/login_screen.dart
git commit -m "feat(user_app): redesign login screen with flat design"
```

---

### Task 4: Redesign User Type Screen

**Files:**
- Rewrite: `lib/features/auth/screens/user_type_screen.dart`

The current screen uses `_MeshGradientBackground` (3 radial gradient layers) and `_UserTypeCard` with `BackdropFilter` glass morphism, gradient backgrounds on selection (blue/purple/teal `LinearGradient`), and selection animation (scale to 0.97).

- [ ] **Step 1: Rewrite user_type_screen.dart**

Key changes from current implementation:
- Remove `_MeshGradientBackground` widget
- Remove `BackdropFilter` from `_UserTypeCard`
- Remove `TickerProviderStateMixin` and `_pulseController` AnimationController
- Remove `dart:ui` import (was for `ImageFilter.blur`)
- Keep: `_selectedType`, `_onTypeSelected()` with 400ms delay, navigation logic, `flutter_animate` entrance animations
- Background: solid `AppColors.background`
- Header: back button left, centered AssignX logo (SvgPicture + text), 48px spacer right for balance
- Title: "Who are you?" — `AppTextStyles.displayMedium` (28px bold). Subtitle: "Select your profile type to get started" — `AppTextStyles.bodyMedium`, `AppColors.textSecondary`
- Cards: Replace glass cards with solid `Container`:
  - Unselected: `color: Colors.white`, `border: Border.all(color: AppColors.border)`, `borderRadius: 16`, `boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))]`
  - Selected: `border: Border.all(color: AppColors.primary, width: 2)`, `color: AppColors.primary.withOpacity(0.04)`
  - Layout: Row — icon container (48x48, `AppColors.primary.withOpacity(0.1)`, `borderRadius: 12`, icon 24px `AppColors.primary`) | 16px gap | Column(title bold, subtitle secondary) | trailing widget
  - Trailing: unselected = `Icon(Icons.chevron_right, color: AppColors.textTertiary)`, selected = green checkmark circle (28x28, `AppColors.success.withOpacity(0.15)` bg, `AppColors.success` check icon)
  - **Student card extra line:** Below subtitle, add `SizedBox(height: 4)` then `Row(children: [Icon(Icons.info_outline, size: 12, color: AppColors.textTertiary), SizedBox(width: 4), Text('Requires college email (.edu, .ac.in, .ac.uk)', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11))])`
  - All 3 cards use same icon color (`AppColors.primary`) — no more per-card gradient colors (blue/purple/teal)
  - Icons: Student = `Icons.school_rounded`, Professional = `Icons.work_rounded`, Business = `Icons.business_center_rounded`
- Keep entrance animation: `fadeIn` + `slideX(begin: 0.05)` with staggered delays
- Bottom: "Already have an account? Log in" + lock security note (same as current, no changes)

- [ ] **Step 2: Hot restart and verify**

Run: Press `R` in flutter run terminal.
Expected: User type screen shows 3 clean white cards. Student card shows ".edu required" hint. Selection highlights with brown border. Navigation to signin works.

- [ ] **Step 3: Commit**

```bash
git add lib/features/auth/screens/user_type_screen.dart
git commit -m "feat(user_app): redesign user type screen, add .edu hint for students"
```

---

### Task 5: Redesign Signup Screen with .edu Enforcement

**Files:**
- Rewrite: `lib/features/auth/screens/signin_screen.dart`
- Uses: `lib/core/utils/email_validators.dart` (created in Task 1)

The current screen uses `_MeshGradientBackground`, `BackdropFilter` glass cards in `_EmailEntrySection` and `_OtpEntrySection`, and `_LottieHero` with network URL. It also does NOT validate student emails.

- [ ] **Step 1: Rewrite signin_screen.dart**

Key changes from current implementation:
- Remove `_MeshGradientBackground` widget
- Remove `BackdropFilter` from `_EmailEntrySection` and `_OtpEntrySection`
- Remove `_LottieHero` widget
- Remove `_floatController` AnimationController, `TickerProviderStateMixin`
- Remove `dart:math`, `dart:ui`, `lottie` imports
- Add import: `import '../../../core/utils/email_validators.dart';`
- Keep: all auth logic (`_submitEmail`, `_verifyOtp`, `_resendOtp`, `_goBackToEmail`), controllers, focus nodes, timer, `AnimatedSwitcher`, `LoadingOverlay`
- **Read user type from query parameter:** In `build()` or `initState()`, read `GoRouterState.of(context).uri.queryParameters['type']` and store as `_userType`.
- **Add validation in `_submitEmail()`:** Before calling `sendOTP()`, add:
  ```dart
  if (_userType == 'student' && !EmailValidators.isCollegeEmail(_email)) {
    setState(() => _errorMessage = 'Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)');
    return;
  }
  ```
- **Add info banner in `_EmailEntrySection`:** When `userType == 'student'`, show a warning container above the email field:
  ```dart
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: AppColors.warning),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Use your educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    ),
  ),
  const SizedBox(height: 12),
  ```
- Background: solid `AppColors.background`
- Top area: AssignX logo centered, then centered icon illustration (person-add icon, 56x56 tinted circle)
- Bottom cards: Replace glass `ClipRRect` + `BackdropFilter` containers with plain `Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [...]))`.
- Buttons: solid `AppColors.primary`, `borderRadius: 24`, no gradient.
- Pass `userType` as parameter to `_EmailEntrySection` widget.

- [ ] **Step 2: Hot restart and test student flow**

Run: Press `R` in flutter run terminal.
Test: Select Student on user type screen → verify info banner appears → enter non-.edu email → verify error message appears → enter .edu email → verify OTP is sent.

- [ ] **Step 3: Test professional flow**

Test: Select Professional on user type screen → verify NO info banner → enter any email → verify OTP is sent normally.

- [ ] **Step 4: Commit**

```bash
git add lib/features/auth/screens/signin_screen.dart
git commit -m "feat(user_app): redesign signup screen, enforce .edu email for students"
```

---

### Task 6: Restyle Profile Completion Screen

**Files:**
- Modify: `lib/features/onboarding/screens/profile_completion_screen.dart`

The current screen uses `MeshGradientBackground` and `GlassContainer`. Replace with solid containers.

- [ ] **Step 1: Replace glass/mesh with solid containers**

Key changes:
- Remove `MeshGradientBackground` wrapper — replace with plain `Container(color: AppColors.background)`
- Remove all `GlassContainer` wrappers — replace with `Container(padding: ..., decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))]))`
- Remove imports: `glass_container.dart`, `mesh_gradient_background.dart`
- Remove gradient `LinearGradient` on the person icon container — use solid `AppColors.primary` background instead, remove `boxShadow`
- Replace `GlassContainer(padding: const EdgeInsets.all(4), child: AppButton(...))` with just `AppButton(...)` directly
- Keep: all form logic, validation, controllers, `LoadingOverlay`, `AppTextField`, animations

- [ ] **Step 2: Hot restart and verify**

Run: Press `R` in flutter run terminal.
Expected: Profile completion screen shows solid white cards, no blur, no mesh gradient. Form works correctly.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/screens/profile_completion_screen.dart
git commit -m "refactor(user_app): restyle profile completion with flat design"
```

---

### Task 7: Restyle Role Selection Screen

**Files:**
- Modify: `lib/features/onboarding/screens/role_selection_screen.dart`

- [ ] **Step 1: Replace glass/mesh with solid containers**

Same pattern as Task 6:
- Remove `MeshGradientBackground` → `Container(color: AppColors.background)`
- Remove `GlassContainer` → solid white `Container` with border and subtle shadow
- Remove gradient icon containers → solid `AppColors.primary` backgrounds
- Remove imports: `glass_container.dart`, `mesh_gradient_background.dart`
- Keep: all role selection logic, `RoleOption` enum, auth provider calls, animations

- [ ] **Step 2: Hot restart and verify**

Expected: Role selection shows clean flat cards. Selection works. Navigation to student/professional profile works.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/screens/role_selection_screen.dart
git commit -m "refactor(user_app): restyle role selection with flat design"
```

---

### Task 8: Restyle Student Profile Screen

**Files:**
- Modify: `lib/features/onboarding/screens/student_profile_screen.dart`

- [ ] **Step 1: Replace glass/mesh with solid containers**

Same pattern:
- Remove `MeshGradientBackground` → `Container(color: AppColors.background)`
- Remove `GlassContainer` → solid white `Container` with border and shadow
- Remove gradient icon containers → solid backgrounds
- Remove imports: `glass_container.dart`, `mesh_gradient_background.dart`
- Keep: all form logic, PageView steps, university/course dropdowns, validation, `StepProgressBar`

- [ ] **Step 2: Hot restart and verify**

Expected: Student profile form shows clean flat design. Both steps work. Form submits correctly.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/screens/student_profile_screen.dart
git commit -m "refactor(user_app): restyle student profile with flat design"
```

---

### Task 9: Restyle Professional Profile Screen

**Files:**
- Modify: `lib/features/onboarding/screens/professional_profile_screen.dart`

- [ ] **Step 1: Replace glass/mesh with solid containers**

Same pattern as Tasks 6-8:
- Remove `MeshGradientBackground` → `Container(color: AppColors.background)`
- Remove `GlassContainer` → solid white containers
- Remove gradient icon containers → solid backgrounds
- Remove imports: `glass_container.dart`, `mesh_gradient_background.dart`
- Keep: all form logic, industry dropdown, validation

- [ ] **Step 2: Hot restart and verify**

Expected: Professional profile form shows clean flat design. Form submits correctly.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/screens/professional_profile_screen.dart
git commit -m "refactor(user_app): restyle professional profile with flat design"
```

---

### Task 10: Redesign Success Screen

**Files:**
- Rewrite: `lib/features/onboarding/screens/signup_success_screen.dart`

The current screen uses `MeshGradientBackground`, `GlassContainer`, gradient icon containers, and `ConfettiWidget`. Keep confetti, remove glass/mesh.

- [ ] **Step 1: Rewrite signup_success_screen.dart**

Key changes:
- Remove `MeshGradientBackground` → `Container(color: AppColors.background)`
- Remove all `GlassContainer` wrappers → solid white containers with border/shadow (or no container for the main content area)
- Remove gradient on success icon → solid `AppColors.success` circle (72x72), white checkmark
- Remove gradient on feature row icons → solid color circle (48x48), white icon
- Remove imports: `glass_container.dart`, `mesh_gradient_background.dart`
- Keep: `ConfettiController`, `ConfettiWidget`, `AppButton`, entrance animations, profile name display
- Replace `AppButton` wrapped in `GlassContainer` → just `SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: () => context.go(RouteNames.home), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)), elevation: 0), child: Text('Go to Dashboard')))`
- Keep all `flutter_animate` entrance animations (fadeIn, slideY, slideX, scale)

- [ ] **Step 2: Hot restart and verify**

Expected: Success screen shows clean layout with green checkmark, confetti, feature list, dashboard button. No glass blur or mesh gradient.

- [ ] **Step 3: Commit**

```bash
git add lib/features/onboarding/screens/signup_success_screen.dart
git commit -m "feat(user_app): redesign success screen with flat design"
```

---

### Task 11: Full Flow Smoke Test

- [ ] **Step 1: Test complete student signup flow**

1. Kill and restart the app: `flutter run --device-id=<simulator_id>`
2. Swipe through onboarding carousel → tap "Get Started"
3. On login, tap "Create one here" → goes to user type screen
4. Verify student card shows ".edu required" hint
5. Select "Student" → goes to signup screen
6. Verify amber info banner about educational email is visible
7. Enter `test@gmail.com` → tap "Create Account" → verify error about educational email
8. Enter `test@university.edu` → tap "Create Account" → verify OTP is sent (check `/private/tmp/api-server.log` for `[DEV-OTP]`)
9. Enter OTP → verify navigation to profile completion
10. Fill name → continue → verify success screen with confetti

- [ ] **Step 2: Test professional signup flow**

1. Navigate back to user type screen
2. Select "Professional" → verify NO info banner on signup screen
3. Enter any email (e.g. `test@gmail.com`) → verify OTP is sent without restriction
4. Complete the flow

- [ ] **Step 3: Test login flow**

1. Navigate to login screen
2. Enter an existing account email → verify OTP sent
3. Enter OTP → verify navigation to home

- [ ] **Step 4: Visual check all screens**

Verify no screen shows:
- Glass morphism blur effects
- Mesh gradient backgrounds
- Lottie loading spinners or broken fallback icons
- Gradient buttons

All screens should show:
- Solid warm white backgrounds
- Clean white cards with subtle shadows
- Solid brown primary buttons
- Consistent typography and spacing

- [ ] **Step 5: Final commit if any fixes needed**

```bash
git add -u
git commit -m "fix(user_app): polish auth screens after smoke test"
```

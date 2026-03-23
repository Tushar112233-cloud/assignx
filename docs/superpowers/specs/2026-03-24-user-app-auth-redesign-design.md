# User App Auth Redesign — Design Spec

**Date:** 2026-03-24
**Scope:** All auth screens in `user_app` (Flutter) — onboarding carousel, login, signup, user type selection, OTP verification, profile completion, success screen.

## Problem Statement

1. **Missing .edu enforcement for students:** The user type screen doesn't tell students they need an educational email. The web enforces this during signup; the mobile app does not.
2. **Auth flow mismatch with web:** Web blocks signup with non-.edu email for students. Mobile allows any email and only offers optional college verification post-signup.
3. **Design inconsistencies:** Glass morphism + mesh gradients + Lottie network URLs create visual noise, slow load times, and broken fallback states.

## Decisions

- **Enforce educational email for students** during signup (option A — matches web)
- **Full redesign of all auth screens** (option A — complete consistency pass)
- **Warm & branded flat design** (option B — keep Coffee Bean palette, drop glass morphism)

## Architecture & Flow

### Current Flow
```
Onboarding Carousel → Login (email → OTP)
                    → UserType → SignIn (email → OTP) → ProfileCompletion
```

### New Flow
```
Onboarding Carousel → Login (email → OTP)
                    → UserType (with .edu warning) → SignIn (enforces .edu for students, email → OTP) → ProfileCompletion → Success
```

The only structural change is adding the educational email validation gate in the signup screen when user type is `student`.

## Design System Changes

### Removing
- `BackdropFilter` / glass morphism cards
- Mesh gradient backgrounds (radial gradient stacks)
- Lottie network URLs (slow to load, broken fallback icons)
- Gradient buttons (`LinearGradient` on `DecoratedBox`)

### Replacing With
- **Backgrounds:** Solid warm white (`AppColors.background` / `#FEFDFB`)
- **Cards:** Solid white, `1px` border (`AppColors.border` / `#DDD7CD`), `BoxShadow(color: 0x0F000000, blurRadius: 8, offset: Offset(0, 2))`, `borderRadius: 16`
- **Buttons:** Solid `AppColors.primary` (`#765341`), `borderRadius: 24`, no gradient, `height: 48`
- **OTP fields:** Warm fill (`AppColors.surfaceVariant` / `#F1EEEA`), brown focus border, `borderRadius: 12`
- **Illustrations:** Local SVG assets (replace Lottie network URLs)
- **Loading overlay:** Simple `CircularProgressIndicator` with semi-transparent overlay (keep existing pattern but remove glass blur)

### Keeping
- Coffee Bean color palette (`AppColors`)
- Inter font family (`AppTextStyles`)
- `flutter_animate` for entrance animations and transitions
- `AnimatedSwitcher` for email → OTP state transitions
- Existing profile screens (role selection, student profile, professional profile) with style alignment only

## Screen Specifications

### 1. Onboarding Carousel

**File:** `onboarding_screen.dart`

- Full-screen warm white background (`AppColors.background`)
- Large local SVG illustration centered in top ~50% of screen
- Title: `AppTextStyles.displayMedium` (28px bold)
- Subtitle: `AppTextStyles.bodyMedium` (14px, `AppColors.textSecondary`)
- Dot indicators: active = `AppColors.primary`, pill-shaped (24px wide); inactive = `AppColors.border`, circle (8px)
- Bottom area:
  - Slides 1-2: "Next" button (outline style, full-width)
  - Slide 3: "Get Started" button (primary solid, full-width)
  - "Already have an account? Sign in" text link below button
- No decorative doodles or gradient overlays
- Auto-scroll every 4 seconds, stops on manual swipe

### 2. Login Screen

**File:** `login_screen.dart`

**Layout:**
- White background, no mesh gradient
- Top section: AssignX logo + name centered (24px from safe area top)
- Middle: Local SVG illustration (width: 60% of screen, max 240px)
- Bottom: Solid white card, `BorderRadius.vertical(top: Radius.circular(24))`, subtle top shadow

**Email State (bottom card content):**
- Handle indicator bar (36x4, grey-300, centered)
- "Welcome Back" — 24px bold
- "Enter your email to sign in" — 14px secondary
- Email `TextField`: warm fill, email icon prefix, brown focus border, 12px radius
- "Continue" button: solid primary, full-width, 48px height, 24px radius
- "Don't have an account? Create one here" link
- Lock icon + "Secure passwordless login" footer (11px, tertiary)

**OTP State (swapped via AnimatedSwitcher):**
- Back button (left-aligned, icon + "Back" text)
- "Enter Verification Code" — 22px bold
- "We sent a 6-digit code to {email}" — 13px secondary, email in bold
- 6 OTP fields: 48x56, warm fill, 12px radius, auto-advance, auto-submit on 6th digit, backspace navigation
- "Verify" button: solid primary, full-width
- "Didn't get a code? Resend" / "Resend in {n}s" — 12px

### 3. User Type Screen

**File:** `user_type_screen.dart`

**Layout:**
- White background
- Header: back button (left) + centered AssignX logo
- "Who are you?" — 28px bold
- "Select your profile type to get started" — 14px secondary

**Cards (3, stacked with 16px gap):**
- Solid white background, 1px border (`AppColors.border`), 16px radius
- Padding: 20px
- Layout: Row — icon container (48x48, `primary.withOpacity(0.1)`, 12px radius) | 16px gap | text column | chevron icon
- Card content:
  - **Student:** school icon, "Student", "I'm a college or university student", **new warning line:** "Requires college email (.edu, .ac.in, .ac.uk)" in `AppColors.textTertiary` with small info icon
  - **Professional:** work icon, "Professional", "I'm a working professional"
  - **Business:** business icon, "Business", "I'm a business owner or entrepreneur"
- **Selected state:** border = `AppColors.primary` (2px), background tint = `AppColors.primary.withOpacity(0.04)`, checkmark replaces chevron
- **Unselected state:** border = `AppColors.border` (1px), white background, chevron arrow right
- Entrance animation: `fadeIn` + `slideX(begin: 0.05)` with staggered delays (200ms, 300ms, 400ms)

**Bottom:** "Already have an account? Log in" + lock icon security note

### 4. Sign In (Signup) Screen

**File:** `signin_screen.dart`

Same layout structure as login screen (illustration top, card bottom).

**Email State:**
- Person-add icon in tinted circle
- "Create Account" — 24px bold
- "Enter your email to get started" — 14px secondary
- **Student type info banner** (shown when `?type=student`):
  - Container: `AppColors.warning.withOpacity(0.08)` background, `AppColors.warning.withOpacity(0.3)` border, 12px radius, 12px padding
  - Row: info icon (amber) + "Use your educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)" in 12px `AppColors.textSecondary`
- Email `TextField` (same styling as login)
- **Validation (student type only):** Before sending OTP, check email domain against patterns:
  ```dart
  static final _collegePatterns = [
    RegExp(r'\.edu$', caseSensitive: false),
    RegExp(r'\.ac\.in$', caseSensitive: false),
    RegExp(r'\.edu\.in$', caseSensitive: false),
    RegExp(r'\.ac\.uk$', caseSensitive: false),
    RegExp(r'\.edu\.au$', caseSensitive: false),
    RegExp(r'\.edu\.ca$', caseSensitive: false),
  ];
  ```
  - If validation fails: show inline error "Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)"
  - If validation passes or type is not student: proceed to send OTP
- "Create Account" button: solid primary
- "Already have an account? Log in" link
- Security note footer

**OTP State:** Same as login OTP state.

**Post-verification routing:** Same as current — check `onboardingCompleted`, route to profile completion or home.

### 5. Role Selection, Student Profile, Professional Profile Screens

**Files:** `role_selection_screen.dart`, `student_profile_screen.dart`, `professional_profile_screen.dart`

**Style alignment only** — replace any glass morphism containers with solid cards matching the new card style. Replace mesh gradient backgrounds with solid `AppColors.background`. Keep all form logic, fields, and validation unchanged.

### 6. Success Screen

**File:** `signup_success_screen.dart`

- Clean white background (`AppColors.background`)
- Large green checkmark: `Container` with `AppColors.success` background, white check icon, circle shape, 72x72
- "Welcome, {name}!" — 28px bold
- "Your account is ready" — 14px secondary
- 3 feature preview items: icon (in tinted circle) + text, stacked vertically with 12px gap
- "Go to Dashboard" button: solid primary, full-width
- Confetti: keep `flutter_animate` based particle effect (not Lottie)
- Entrance animations: staggered fadeIn + slideY for each element

## College Email Validation

**Validation function** (add to a shared utility, e.g., `lib/core/utils/email_validators.dart`):

```dart
class EmailValidators {
  static final _collegeEmailPatterns = [
    RegExp(r'\.edu$', caseSensitive: false),
    RegExp(r'\.ac\.in$', caseSensitive: false),
    RegExp(r'\.edu\.in$', caseSensitive: false),
    RegExp(r'\.ac\.uk$', caseSensitive: false),
    RegExp(r'\.edu\.au$', caseSensitive: false),
    RegExp(r'\.edu\.ca$', caseSensitive: false),
  ];

  static bool isCollegeEmail(String email) {
    final domain = email.toLowerCase().split('@').last;
    return _collegeEmailPatterns.any((pattern) => pattern.hasMatch(domain));
  }
}
```

**Usage in signin_screen.dart:**
- Read user type from query parameter: `GoRouterState.of(context).uri.queryParameters['type']`
- In `_submitEmail()`, before calling `sendOTP()`:
  ```dart
  if (_userType == 'student' && !EmailValidators.isCollegeEmail(_email)) {
    setState(() => _errorMessage = 'Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)');
    return;
  }
  ```

## Files Modified

| File | Change |
|------|--------|
| `lib/features/onboarding/screens/onboarding_screen.dart` | Redesign — remove doodles/gradients, clean layout |
| `lib/features/auth/screens/login_screen.dart` | Redesign — remove glass/mesh/Lottie, solid cards |
| `lib/features/auth/screens/user_type_screen.dart` | Redesign + add .edu requirement text on student card |
| `lib/features/auth/screens/signin_screen.dart` | Redesign + add .edu validation for student type |
| `lib/features/auth/screens/college_verification_screen.dart` | Style alignment only |
| `lib/features/onboarding/screens/role_selection_screen.dart` | Style alignment — replace glass/mesh |
| `lib/features/onboarding/screens/student_profile_screen.dart` | Style alignment — replace glass/mesh |
| `lib/features/onboarding/screens/professional_profile_screen.dart` | Style alignment — replace glass/mesh |
| `lib/features/onboarding/screens/profile_completion_screen.dart` | Style alignment — replace glass/mesh |
| `lib/features/onboarding/screens/signup_success_screen.dart` | Redesign — clean layout, local icons |
| `lib/core/utils/email_validators.dart` | **New file** — shared college email validation |

## Files NOT Modified

- `lib/core/constants/app_colors.dart` — palette is correct as-is
- `lib/core/constants/app_text_styles.dart` — typography is correct as-is
- `lib/providers/auth_provider.dart` — auth logic unchanged
- `lib/core/router/` — routing unchanged
- Any non-auth screens

## Testing Criteria

1. Student selects "Student" → sees .edu requirement on card
2. Student enters non-.edu email on signup → blocked with clear error message
3. Student enters valid .edu email → OTP sent, verification works
4. Professional/Business → no email restriction, normal flow
5. Login flow → unchanged, any email works (accounts already exist)
6. All screens render without network dependency (no Lottie URLs)
7. Animations are smooth, no BackdropFilter jank on older devices

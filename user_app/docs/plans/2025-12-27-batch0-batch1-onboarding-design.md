# Batch 0 & Batch 1: Project Setup & Onboarding Design

> **Date:** 2025-12-27
> **Scope:** Project configuration + 11 onboarding features
> **Auth Method:** Google OAuth only

---

## User Journey

```
Splash (2s) → Onboarding (3 slides) → Google Sign-in
    → Role Selection → Profile Completion → Success → Home
```

---

## Architecture

### Pattern
- **Feature-first** folder structure
- **Repository pattern** for data abstraction
- **Riverpod** with AsyncNotifier for state
- **go_router** with auth redirect guards

### Folder Structure
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── config/
│   │   └── supabase_config.dart
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_text_styles.dart
│   │   └── app_spacing.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── extensions.dart
│       └── validators.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   └── profile_model.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── user_repository.dart
│   └── datasources/
│       └── supabase_datasource.dart
├── providers/
│   ├── auth_provider.dart
│   └── user_provider.dart
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   ├── screens/
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── role_selection_screen.dart
│   │   │   ├── student_profile_screen.dart
│   │   │   ├── professional_profile_screen.dart
│   │   │   └── signup_success_screen.dart
│   │   └── widgets/
│   │       ├── onboarding_page.dart
│   │       ├── role_card.dart
│   │       └── step_progress_bar.dart
│   └── auth/
│       ├── screens/
│       │   └── login_screen.dart
│       └── widgets/
│           └── google_sign_in_button.dart
└── shared/
    └── widgets/
        ├── app_button.dart
        ├── app_text_field.dart
        ├── app_dropdown.dart
        ├── loading_overlay.dart
        └── support_fab.dart
```

---

## Screens

### 1. Splash Screen
- Centered text logo "AssignX"
- Tagline: "Your Task, Our Expertise"
- Fade-in + scale animation (500ms)
- 2-second display
- Auth state check → route accordingly

### 2. Onboarding Carousel
| Slide | Icon | Title | Subtitle |
|-------|------|-------|----------|
| 1 | lightbulb_outline | Expert Help | Get professional help for your projects |
| 2 | category_outlined | Versatile | Academic, Professional, Creative |
| 3 | verified_outlined | Trusted | Quality assured, deadline guaranteed |

- Skip button (top-right)
- Next / Get Started button
- Dot indicators
- Swipe gesture

### 3. Login Screen (Google Sign-in)
- App logo centered
- "Continue with Google" button
- Terms acceptance checkbox (required)
- Support FAB

### 4. Role Selection Screen
| Role | Icon | Description |
|------|------|-------------|
| Student | school_outlined | Currently pursuing education |
| Job Seeker | work_outline | Looking for opportunities |
| Business/Creator | rocket_launch_outlined | Building something amazing |

- Premium card design
- Selection animation (scale + border)
- Continue button

### 5. Student Profile Screen (2 steps)
**Step 1:**
- Full Name (required)
- Date of Birth (date picker)

**Step 2:**
- University (searchable dropdown from Supabase)
- Course (filtered dropdown)
- Semester/Year (dropdown)
- Student ID (optional)

### 6. Professional Profile Screen (1 step)
- Industry (dropdown)
- Job Title (optional)
- Company (optional)

### 7. Success Screen
- Confetti animation
- Checkmark with scale animation
- "Welcome, [Name]!"
- "Your account is ready"
- "Go to Dashboard" button

---

## Shared Widgets

| Widget | Description |
|--------|-------------|
| AppButton | Primary/secondary with loading state |
| AppTextField | Styled input with validation |
| AppDropdown | Searchable dropdown |
| StepProgressBar | Linear step indicator |
| LoadingOverlay | Full-screen loading |
| SupportFAB | Floating support button |
| RoleCard | Selectable role card |
| OnboardingPage | Single carousel slide |

---

## State Management

### Auth Provider
```dart
enum AuthStatus {
  initial,
  unauthenticated,
  authenticated,
  profileIncomplete,
  complete,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final UserProfile? profile;
}
```

### Router Redirects
| State | Redirect To |
|-------|-------------|
| unauthenticated | /onboarding |
| authenticated (no profile) | /role-selection |
| profileIncomplete | /profile-completion |
| complete | /home |

---

## Supabase Integration

### Tables Used
- `auth.users` - Google OAuth
- `profiles` - name, dob, role, avatar_url
- `users` - university_id, course_id, semester, student_id
- `universities` - id, name
- `courses` - id, name, university_id

### Config
- URL: Environment variable
- Anon Key: Environment variable
- Google OAuth: Configured in Supabase dashboard

---

## Theme

### Colors
| Name | Hex | Usage |
|------|-----|-------|
| Primary | #2563EB | Buttons, links |
| Accent | #3B82F6 | Highlights |
| Background | #F8FAFC | Screen background |
| Surface | #FFFFFF | Cards |
| Error | #EF4444 | Validation errors |
| Success | #22C55E | Success states |

### Typography
- Font: Inter (system fallback)
- Headings: Bold, sizes 24-32
- Body: Regular, size 16
- Caption: Regular, size 14

---

## Dependencies

```yaml
# State Management
flutter_riverpod: ^2.4.9
riverpod_annotation: ^2.3.3

# Backend
supabase_flutter: ^2.3.0

# Navigation
go_router: ^13.0.0

# UI
flutter_animate: ^4.3.0
smooth_page_indicator: ^1.1.0
confetti: ^0.7.0

# Storage
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0

# Utils
intl: ^0.19.0
```

---

## Implementation Order

1. **Batch 0:** pubspec.yaml, folder structure, theme, Supabase config, router shell
2. **Splash Screen**
3. **Onboarding Carousel**
4. **Login Screen + Google Auth**
5. **Role Selection**
6. **Profile Completion (Student + Professional)**
7. **Success Screen**
8. **Auth state integration + redirects**

---

*Design validated: 2025-12-27*

# DOER App - Architecture Documentation

**Version:** 1.0.0
**Last Updated:** December 27, 2024
**Status:** Production Ready

---

## Table of Contents

1. [Overview](#1-overview)
2. [Technology Stack](#2-technology-stack)
3. [Directory Structure](#3-directory-structure)
4. [Architecture Layers](#4-architecture-layers)
5. [State Management](#5-state-management)
6. [Navigation](#6-navigation)
7. [Feature Modules](#7-feature-modules)
8. [Data Flow](#8-data-flow)
9. [Design Patterns](#9-design-patterns)
10. [Future Improvements](#10-future-improvements)

---

## 1. Overview

### 1.1 Application Purpose

DOER is a mobile application for freelance academic writers that enables them to:
- Browse and accept writing projects
- Submit completed work
- Track earnings and payments
- Access training resources and tools
- Manage their professional profile

### 1.2 Architecture Style

The application follows a **Feature-First Architecture** with **Riverpod** for state management. This approach:
- Groups code by feature/domain rather than type
- Promotes modularity and scalability
- Enables team parallelization
- Simplifies navigation and maintenance

### 1.3 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         Presentation                             │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                      Features (UI)                           │ │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌────────┐ │ │
│  │  │  Auth   │ │Dashboard│ │Workspace│ │Resources│ │Profile │ │ │
│  │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └───┬────┘ │ │
│  └───────┼──────────┼──────────┼──────────┼─────────────┼──────┘ │
└──────────┼──────────┼──────────┼──────────┼─────────────┼────────┘
           │          │          │          │             │
┌──────────▼──────────▼──────────▼──────────▼─────────────▼────────┐
│                      State Management                             │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                    Riverpod Providers                        │ │
│  │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌───────────┐ │ │
│  │  │authProvider│ │dashProvider│ │workProvider│ │profProvider│ │ │
│  │  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘ └─────┬─────┘ │ │
│  └────────┼──────────────┼──────────────┼──────────────┼───────┘ │
└───────────┼──────────────┼──────────────┼──────────────┼─────────┘
            │              │              │              │
┌───────────▼──────────────▼──────────────▼──────────────▼─────────┐
│                         Data Layer                                │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                      Services                                │ │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐ │ │
│  │  │SupabaseService │  │  StorageService │  │ NotifyService  │ │ │
│  │  └───────┬────────┘  └────────────────┘  └────────────────┘ │ │
│  └──────────┼───────────────────────────────────────────────────┘ │
└─────────────┼────────────────────────────────────────────────────┘
              │
┌─────────────▼────────────────────────────────────────────────────┐
│                        External Services                          │
│  ┌────────────────┐                                              │
│  │    Supabase    │                                              │
│  │  (Auth + DB)   │                                              │
│  └────────────────┘                                              │
└──────────────────────────────────────────────────────────────────┘
```

---

## 2. Technology Stack

### 2.1 Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.x | Cross-platform UI framework |
| Dart | 3.x | Programming language |
| Riverpod | 2.5.1 | State management |
| go_router | 14.6.2 | Declarative routing |
| Supabase | 2.8.2 | Backend-as-a-Service |

### 2.2 Additional Packages

| Package | Purpose |
|---------|---------|
| flutter_svg | SVG rendering |
| google_fonts | Custom typography |
| intl | Internationalization |

### 2.3 Development Tools

| Tool | Purpose |
|------|---------|
| VS Code | Primary IDE |
| Flutter DevTools | Debugging & profiling |
| Supabase CLI | Database management |

---

## 3. Directory Structure

### 3.1 Current Structure

```
lib/
├── main.dart                    # Application entry point
│
├── core/                        # Core application infrastructure
│   ├── constants/               # App-wide constants
│   │   ├── app_colors.dart      # Color palette
│   │   ├── app_spacing.dart     # Spacing & sizing
│   │   └── app_text_styles.dart # Typography
│   │
│   ├── router/                  # Navigation configuration
│   │   ├── app_router.dart      # Route definitions
│   │   └── route_names.dart     # Route name constants
│   │
│   ├── services/                # External service integrations
│   │   └── supabase_service.dart
│   │
│   └── theme/                   # Theme configuration
│       └── app_theme.dart
│
├── features/                    # Feature modules
│   ├── activation/              # User activation flow
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── auth/                    # Authentication
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/
│   │
│   ├── dashboard/               # Main dashboard
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── statistics_screen.dart
│   │   │   └── reviews_screen.dart
│   │   └── widgets/
│   │       ├── app_header.dart
│   │       ├── bottom_nav.dart
│   │       └── project_card.dart
│   │
│   ├── onboarding/              # Onboarding flow
│   │   └── screens/
│   │
│   ├── profile/                 # User profile
│   │   ├── screens/
│   │   │   ├── profile_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   ├── payment_history_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   └── notifications_screen.dart
│   │   └── widgets/
│   │
│   ├── resources/               # Resources & tools
│   │   ├── screens/
│   │   │   ├── resources_hub_screen.dart
│   │   │   ├── training_center_screen.dart
│   │   │   ├── ai_checker_screen.dart
│   │   │   └── citation_builder_screen.dart
│   │   └── widgets/
│   │
│   ├── splash/                  # Splash screen
│   │   └── splash_screen.dart
│   │
│   └── workspace/               # Project workspace
│       ├── screens/
│       │   ├── workspace_screen.dart
│       │   ├── project_detail_screen.dart
│       │   ├── submit_work_screen.dart
│       │   ├── revision_screen.dart
│       │   └── chat_screen.dart
│       └── widgets/
│
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── dashboard_provider.dart
│   ├── workspace_provider.dart
│   ├── resources_provider.dart
│   └── profile_provider.dart
│
└── shared/                      # Shared components
    ├── widgets/
    │   ├── app_button.dart
    │   ├── app_text_field.dart
    │   └── loading_indicator.dart
    └── utils/
        └── validators.dart
```

### 3.2 Recommended Structure (Future)

```
lib/
├── main.dart
│
├── core/                        # Core infrastructure (unchanged)
│
├── data/                        # NEW: Data layer
│   ├── models/                  # Domain models
│   │   ├── user_profile.dart
│   │   ├── project.dart
│   │   └── ...
│   ├── repositories/            # Repository interfaces
│   │   ├── auth_repository.dart
│   │   ├── profile_repository.dart
│   │   └── ...
│   ├── sources/                 # Data sources
│   │   ├── remote/              # API implementations
│   │   └── local/               # Local cache
│   └── mock/                    # Mock data for testing
│
├── features/                    # Features (unchanged structure)
│
├── providers/                   # State management (simplified)
│
└── shared/                      # Shared components (unchanged)
```

---

## 4. Architecture Layers

### 4.1 Presentation Layer

**Location:** `lib/features/`

**Responsibility:**
- UI components (screens, widgets)
- User interaction handling
- UI state (animations, form state)

**Guidelines:**
- Screens should be thin - delegate logic to providers
- Use `ConsumerWidget` for reactive UI
- Extract reusable widgets to `widgets/` subfolder
- Keep build methods under 100 lines

### 4.2 State Management Layer

**Location:** `lib/providers/`

**Responsibility:**
- Application state
- Business logic
- Data transformation
- Side effects (API calls)

**Current Pattern:**
```dart
// NotifierProvider pattern
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    _loadInitialData();
    return ProfileState.initial();
  }

  Future<void> updateProfile({...}) async {
    state = state.copyWith(isSaving: true);
    try {
      // Logic here
      state = state.copyWith(profile: updated, isSaving: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isSaving: false);
    }
  }
}
```

### 4.3 Data Layer (Future)

**Location:** `lib/data/` (to be implemented)

**Responsibility:**
- Data fetching and caching
- API abstraction
- Data serialization

**Recommended Pattern:**
```dart
// Repository interface
abstract class ProfileRepository {
  Future<UserProfile> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
}

// Supabase implementation
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  @override
  Future<UserProfile> getProfile(String userId) async {
    final response = await _client.from('profiles').select().eq('id', userId).single();
    return UserProfile.fromJson(response);
  }
}
```

### 4.4 Services Layer

**Location:** `lib/core/services/`

**Responsibility:**
- External service integration
- Platform-specific functionality
- Third-party SDK wrappers

---

## 5. State Management

### 5.1 Provider Types Used

| Provider Type | Use Case | Example |
|---------------|----------|---------|
| `NotifierProvider` | Complex state with methods | `profileProvider` |
| `Provider` | Simple computed values | `appRouterProvider` |
| `FutureProvider` | One-time async data | (not yet used) |
| `StreamProvider` | Real-time data | (not yet used) |

### 5.2 State Class Pattern

```dart
class ProfileState {
  final UserProfile? profile;
  final List<PaymentTransaction> paymentHistory;
  final bool isLoading;
  final bool isSaving;
  final String? error;

  const ProfileState({
    this.profile,
    this.paymentHistory = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
  });

  // Factory for initial state
  factory ProfileState.initial() => const ProfileState(isLoading: true);

  // Immutable copy method
  ProfileState copyWith({...}) => ProfileState(...);

  // Convenience getters
  bool get hasProfile => profile != null;
  int get unreadNotificationCount => ...;
}
```

### 5.3 Provider Communication

```dart
// Reading other providers in a notifier
class DashboardNotifier extends Notifier<DashboardState> {
  @override
  DashboardState build() {
    // Watch auth state
    final authState = ref.watch(authProvider);
    if (!authState.isAuthenticated) {
      return DashboardState.empty();
    }
    _loadDashboard(authState.user!.id);
    return DashboardState.loading();
  }
}
```

---

## 6. Navigation

### 6.1 Router Configuration

**Location:** `lib/core/router/app_router.dart`

**Pattern:** Declarative routing with go_router

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // ... more routes
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});
```

### 6.2 Navigation Patterns

```dart
// Push navigation
context.push('/profile/edit');

// Go (replace stack)
context.go('/dashboard');

// Pop
context.pop();

// With parameters
context.push('/project/${project.id}');
```

### 6.3 Route Guard (Future)

```dart
// Redirect based on auth state
redirect: (context, state) {
  final isLoggedIn = ref.read(authProvider).isAuthenticated;
  final isLoggingIn = state.matchedLocation == '/login';

  if (!isLoggedIn && !isLoggingIn) return '/login';
  if (isLoggedIn && isLoggingIn) return '/dashboard';
  return null;
},
```

---

## 7. Feature Modules

### 7.1 Module Structure

Each feature follows this structure:

```
feature_name/
├── screens/              # Full-page UI components
│   ├── main_screen.dart
│   └── detail_screen.dart
├── widgets/              # Feature-specific widgets
│   ├── custom_card.dart
│   └── feature_header.dart
└── (models/)            # Feature-specific models (optional)
```

### 7.2 Feature Inventory

| Feature | Screens | Provider | Status |
|---------|---------|----------|--------|
| Splash | 1 | - | Complete |
| Onboarding | 2 | - | Complete |
| Auth | 2 | `authProvider` | Complete |
| Activation | 4 | `authProvider` | Complete |
| Dashboard | 3 | `dashboardProvider` | Complete |
| Workspace | 5 | `workspaceProvider` | Complete |
| Resources | 4 | `resourcesProvider` | Complete |
| Profile | 5 | `profileProvider` | Complete |

---

## 8. Data Flow

### 8.1 Unidirectional Data Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│    User     │────▶│   Widget    │────▶│  Provider   │
│  Interaction│     │  (ref.read) │     │  (Notifier) │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
                                        ┌─────────────┐
                                        │   Service   │
                                        │  (Supabase) │
                                        └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Widget    │◀────│   Widget    │◀────│    State    │
│  (rebuild)  │     │ (ref.watch) │     │  (updated)  │
└─────────────┘     └─────────────┘     └─────────────┘
```

### 8.2 State Update Flow

1. User interacts with UI (button tap, form submit)
2. Widget calls `ref.read(provider.notifier).method()`
3. Notifier updates state via `state = state.copyWith(...)`
4. Widgets watching state rebuild automatically
5. UI reflects new state

### 8.3 Async Data Flow

```dart
// In notifier
Future<void> loadProfile() async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final profile = await _fetchProfile();
    state = state.copyWith(profile: profile, isLoading: false);
  } catch (e) {
    state = state.copyWith(error: e.toString(), isLoading: false);
  }
}

// In widget
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(profileProvider);

  if (state.isLoading) return LoadingIndicator();
  if (state.error != null) return ErrorWidget(state.error!);
  return ProfileContent(state.profile!);
}
```

---

## 9. Design Patterns

### 9.1 Patterns Used

| Pattern | Usage | Location |
|---------|-------|----------|
| Provider | Dependency injection & state | `lib/providers/` |
| Repository | Data abstraction (planned) | `lib/data/repositories/` |
| Factory | Object creation | Model `fromJson` methods |
| Builder | Complex widget construction | Dialog builders |
| Observer | State change notification | Riverpod watch/listen |

### 9.2 Widget Patterns

**ConsumerWidget for Reactive UI:**
```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).profile;
    return ProfileView(profile: profile);
  }
}
```

**ConsumerStatefulWidget for Local + Global State:**
```dart
class EditProfileScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 9.3 Model Patterns

**Immutable Models with copyWith:**
```dart
class UserProfile {
  final String id;
  final String name;
  final String email;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
  });

  UserProfile copyWith({
    String? name,
    String? email,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
  };
}
```

---

## 10. Future Improvements

### 10.1 Short-term (Next Sprint)

1. **Add Repository Layer**
   - Create repository interfaces
   - Implement Supabase repositories
   - Create mock repositories for testing

2. **Extract Mock Data**
   - Move mock data to `lib/data/mock/`
   - Create environment toggle for mock/real data

3. **Add Unit Tests**
   - Test providers with mock repositories
   - Test model serialization
   - Test utility functions

### 10.2 Medium-term (Next Quarter)

1. **Add Offline Support**
   - Implement local database (Hive/Drift)
   - Add sync mechanism
   - Handle offline states in UI

2. **Performance Optimization**
   - Add image caching
   - Implement list pagination
   - Profile and optimize rebuilds

3. **Error Handling Enhancement**
   - Add centralized error handling
   - Implement crash reporting
   - Add user-friendly error messages

### 10.3 Long-term (Future)

1. **Feature Flags**
   - Remote configuration
   - A/B testing support
   - Gradual rollouts

2. **Analytics Integration**
   - User behavior tracking
   - Performance monitoring
   - Conversion tracking

3. **Internationalization**
   - Multi-language support
   - RTL layout support
   - Localized content

---

## Appendix

### A. Coding Standards

See `CLAUDE.md` for detailed coding standards and guidelines.

### B. Related Documents

- [Codebase Analysis](./CODEBASE_ANALYSIS.md)
- [Technical Debt](./TECHNICAL_DEBT.md)
- [API Documentation](./API.md) (future)

### C. Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2024-12 | Use Riverpod over Provider | Better testing, compile-time safety |
| 2024-12 | Use go_router over Navigator 2.0 | Simpler API, declarative |
| 2024-12 | Feature-first over layer-first | Better scalability, team parallelization |
| 2024-12 | Supabase over Firebase | PostgreSQL, better pricing, open-source |

---

*Document maintained by Development Team*
*Last reviewed: December 27, 2024*

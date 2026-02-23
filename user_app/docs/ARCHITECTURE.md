# Architecture Documentation

This document describes the technical architecture of the AssignX User App.

## Overview

The AssignX User App is a Flutter mobile application that follows a layered architecture pattern with clear separation of concerns. It uses Riverpod for state management and Supabase as the backend-as-a-service.

```
┌─────────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │   Screens    │  │   Widgets    │  │   UI Components  │  │
│  └──────┬───────┘  └──────┬───────┘  └────────┬─────────┘  │
└─────────┼─────────────────┼────────────────────┼────────────┘
          │                 │                    │
          ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                     STATE MANAGEMENT                         │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                  Riverpod Providers                   │  │
│  │  • StateNotifierProvider (complex state)             │  │
│  │  • FutureProvider (async data)                       │  │
│  │  • Provider (dependencies)                           │  │
│  └──────────────────────────┬───────────────────────────┘  │
└─────────────────────────────┼───────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DATA LAYER                              │
│  ┌──────────────────┐        ┌──────────────────────────┐  │
│  │   Repositories   │◄──────►│   Data Models            │  │
│  │   (Data Access)  │        │   (Entities)             │  │
│  └────────┬─────────┘        └──────────────────────────┘  │
└───────────┼─────────────────────────────────────────────────┘
            │
            ▼
┌─────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                         │
│  ┌─────────────┐  ┌─────────────┐  ┌────────────────────┐  │
│  │  Supabase   │  │   Storage   │  │   External APIs    │  │
│  │  (DB/Auth)  │  │  (Files)    │  │   (Payment, etc)   │  │
│  └─────────────┘  └─────────────┘  └────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## Directory Structure

```
lib/
├── core/                     # Core framework utilities
│   ├── config/              # Configuration files
│   │   ├── app_config.dart  # App-wide configuration
│   │   └── supabase_config.dart  # Supabase credentials
│   ├── constants/           # Design tokens and constants
│   │   ├── app_colors.dart  # Color palette
│   │   ├── app_spacing.dart # Spacing values
│   │   └── app_text_styles.dart # Typography
│   ├── router/              # Navigation setup
│   │   └── app_router.dart  # go_router configuration
│   └── utils/               # Utility functions
│       └── extensions.dart  # Dart extensions
│
├── data/                     # Data layer
│   ├── models/              # Data models (entities)
│   │   ├── user_model.dart  # Barrel file for user models
│   │   ├── project_model.dart # Barrel file for project models
│   │   └── ...              # Individual model files
│   └── repositories/        # Data access layer
│       ├── auth_repository.dart
│       ├── profile_repository.dart
│       ├── project_repository.dart
│       ├── home_repository.dart
│       └── marketplace_repository.dart
│
├── features/                 # Feature modules
│   ├── auth/                # Authentication
│   ├── home/                # Home screen
│   ├── onboarding/          # User onboarding
│   ├── profile/             # User profile
│   ├── projects/            # Project management
│   ├── add_project/         # Project creation
│   ├── marketplace/         # Campus marketplace
│   └── splash/              # App loading
│
├── providers/               # Riverpod providers
│   ├── auth_provider.dart
│   ├── profile_provider.dart
│   ├── project_provider.dart
│   └── home_provider.dart
│
└── shared/                  # Shared components
    └── widgets/             # Reusable widgets
        └── support_fab.dart
```

---

## Layer Responsibilities

### Presentation Layer

**Location:** `lib/features/*/screens/` and `lib/features/*/widgets/`

- Displays UI to the user
- Handles user interactions
- Observes state changes from providers
- Triggers actions through providers

**Guidelines:**
- Screens should be stateless when possible (use ConsumerWidget)
- Complex UI logic should be in separate widget classes
- Use `ref.watch()` for reactive data
- Use `ref.read()` for one-time actions

### State Management Layer

**Location:** `lib/providers/`

Riverpod providers manage application state:

| Provider Type | Use Case |
|---------------|----------|
| `Provider` | Simple dependencies, repository instances |
| `FutureProvider` | One-time async data fetching |
| `StateNotifierProvider` | Complex state with mutations |
| `StreamProvider` | Real-time data streams |

**Example:**
```dart
// Repository provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

// Data provider with auto-refresh
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getProjects();
});

// Mutable state provider
final projectNotifierProvider =
    StateNotifierProvider<ProjectNotifier, ProjectState>((ref) {
  return ProjectNotifier(ref);
});
```

### Data Layer

**Location:** `lib/data/`

**Models (`lib/data/models/`):**
- Immutable data classes representing entities
- JSON serialization/deserialization
- Database column mapping (snake_case to camelCase)
- Computed properties and validation

**Repositories (`lib/data/repositories/`):**
- Abstract data access behind clean interfaces
- Handle Supabase queries and mutations
- Error handling and logging
- Data transformation

---

## Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        AUTH FLOW                                 │
└─────────────────────────────────────────────────────────────────┘

1. App Launch
   │
   ▼
┌──────────────────┐     No Session     ┌──────────────────┐
│   Splash Screen  │ ───────────────────►│   Login Screen   │
└────────┬─────────┘                     └────────┬─────────┘
         │                                        │
         │ Has Session                            │ Google Sign-In
         ▼                                        ▼
┌──────────────────┐                     ┌──────────────────┐
│ Check Onboarding │                     │   Auth Success   │
└────────┬─────────┘                     └────────┬─────────┘
         │                                        │
         │                                        ▼
         │                               ┌──────────────────┐
         │                               │  Create Profile  │
         │                               └────────┬─────────┘
         │                                        │
         ▼                                        ▼
   ┌───────────────────────────────────────────────────┐
   │              ONBOARDING CHECK                      │
   │  ┌─────────────────┐    ┌────────────────────┐   │
   │  │ Complete = true │    │ Complete = false   │   │
   │  │ → Home Screen   │    │ → Onboarding Flow  │   │
   │  └─────────────────┘    └────────────────────┘   │
   └───────────────────────────────────────────────────┘
```

**Implementation Details:**

1. **Google OAuth with PKCE:** Secure authorization code flow
2. **Session Persistence:** Supabase handles token storage
3. **Auto Refresh:** JWT tokens refresh automatically
4. **Deep Linking:** OAuth callback via custom URL scheme

---

## Navigation

The app uses `go_router` for declarative navigation with:

- **Named Routes:** Type-safe route definitions
- **Auth Guards:** Redirect unauthenticated users
- **Deep Linking:** Support for external links
- **Shell Routes:** Bottom navigation persistence

**Route Structure:**
```
/                           → Splash (redirect)
/login                      → Login screen
/onboarding                 → Onboarding flow
  /onboarding/role          → Role selection
  /onboarding/basic-info    → Basic information
  /onboarding/academic      → Academic/professional info
  /onboarding/verify        → Verification

/home                       → Main app shell
  /home                     → Home tab
  /projects                 → Projects tab
  /marketplace              → Marketplace tab
  /profile                  → Profile tab

/project/:id                → Project detail
/add-project                → Project creation
  /add-project/details      → Step 1: Basic details
  /add-project/requirements → Step 2: Requirements
  /add-project/files        → Step 3: Upload files
  /add-project/review       → Step 4: Review & submit
```

---

## Data Flow

### Read Operations

```
┌─────────┐      watch()      ┌──────────┐     query()     ┌──────────┐
│ Widget  │ ─────────────────►│ Provider │ ────────────────►│Repository│
└─────────┘                   └──────────┘                  └──────────┘
     │                             │                             │
     │                             │                             │
     │         AsyncValue          │         List<Model>         │
     │◄────────────────────────────│◄────────────────────────────│
```

### Write Operations

```
┌─────────┐      read()       ┌──────────┐     mutate()    ┌──────────┐
│ Widget  │ ─────────────────►│ Provider │ ────────────────►│Repository│
└─────────┘                   └──────────┘                  └──────────┘
     │                             │                             │
     │                             │  invalidate()               │  Success
     │                             │◄────────────────────────────│
     │         Rebuild             │                             │
     │◄────────────────────────────│                             │
```

---

## Error Handling

### Repository Layer

```dart
try {
  final result = await _supabase.from('table').select();
  return Model.fromJson(result);
} on PostgrestException catch (e) {
  _logger.e('Database error: ${e.message}');
  rethrow;
} on AuthException catch (e) {
  _logger.e('Auth error: ${e.message}');
  rethrow;
} catch (e) {
  _logger.e('Unexpected error: $e');
  rethrow;
}
```

### Provider Layer

```dart
AsyncValue.guard(() async {
  return await repository.fetchData();
});
```

### UI Layer

```dart
dataAsync.when(
  data: (data) => DataWidget(data: data),
  loading: () => const LoadingIndicator(),
  error: (error, stack) => ErrorWidget(
    message: error.toString(),
    onRetry: () => ref.refresh(dataProvider),
  ),
);
```

---

## State Management Patterns

### AsyncValue Pattern

Use `AsyncValue` for handling loading, error, and data states:

```dart
final projectAsync = ref.watch(projectsProvider);

return projectAsync.when(
  data: (projects) => ProjectList(projects: projects),
  loading: () => const ProjectListSkeleton(),
  error: (e, _) => ErrorState(
    message: 'Failed to load projects',
    onRetry: () => ref.invalidate(projectsProvider),
  ),
);
```

### Optimistic Updates

For better UX, update UI immediately and revert on failure:

```dart
Future<void> updateProject(Project project) async {
  // 1. Store previous state
  final previous = state;

  // 2. Optimistically update
  state = state.copyWith(project: project);

  try {
    // 3. Persist to backend
    await repository.updateProject(project);
  } catch (e) {
    // 4. Revert on failure
    state = previous;
    rethrow;
  }
}
```

---

## Database Schema

### Core Tables

| Table | Description |
|-------|-------------|
| `profiles` | User profile data |
| `students` | Student-specific data |
| `professionals` | Professional-specific data |
| `projects` | Assignment requests |
| `project_deliverables` | Delivered files |
| `project_timeline` | Status history |
| `wallets` | User wallet balances |
| `wallet_transactions` | Transaction history |
| `marketplace_listings` | Marketplace items |

### Relationships

```
profiles (1) ─────► (1) wallets
    │
    ├───► (1) students
    │
    └───► (1) professionals

profiles (1) ─────► (N) projects
                         │
                         ├───► (N) project_deliverables
                         │
                         └───► (N) project_timeline

profiles (1) ─────► (N) marketplace_listings
```

---

## Configuration

### Environment Variables

Pass configuration at build time via `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=xxx \
  --dart-define=SUPPORT_PHONE=+919876543210
```

### AppConfig

Centralized configuration in `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const String supportPhone = String.fromEnvironment(
    'SUPPORT_PHONE',
    defaultValue: '+919876543210',
  );
}
```

---

## Performance Considerations

### Widget Optimization

- Use `const` constructors where possible
- Split large widgets into smaller components
- Use `Consumer` for scoped rebuilds
- Implement `Equatable` for models used in widgets

### Data Fetching

- Use pagination for large lists
- Implement pull-to-refresh
- Cache frequently accessed data
- Use `keepAlive` for expensive providers

### Memory Management

- Dispose controllers and subscriptions
- Use `autoDispose` for providers
- Avoid storing large objects in state
- Clear caches on logout

---

## Security

### Authentication

- OAuth 2.0 with PKCE flow
- JWT tokens with automatic refresh
- Secure token storage via Supabase SDK

### Data Protection

- HTTPS for all API calls
- No sensitive data in logs
- Environment variables for secrets
- Input validation before API calls

### Best Practices

- Never commit API keys to version control
- Use `--dart-define` for environment configuration
- Validate user input on client and server
- Implement rate limiting awareness

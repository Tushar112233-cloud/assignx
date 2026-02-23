# Architecture Documentation

This document describes the overall architecture and design patterns used in the Superviser App.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Architecture Layers](#architecture-layers)
- [State Management](#state-management)
- [Dependency Injection](#dependency-injection)
- [Navigation](#navigation)
- [Error Handling](#error-handling)
- [Security](#security)
- [Testing](#testing)

---

## Overview

The Superviser App follows **Clean Architecture** principles with a feature-first folder structure. Key technologies:

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform UI framework |
| Dart | Programming language |
| Riverpod | State management & DI |
| GoRouter | Declarative routing |
| Supabase | Backend-as-a-Service |

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Presentation Layer                          │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │
│  │     Screens     │  │     Widgets     │  │     Providers       │  │
│  │  (UI Pages)     │  │  (Components)   │  │  (State + Logic)    │  │
│  └────────┬────────┘  └────────┬────────┘  └──────────┬──────────┘  │
│           │                    │                      │              │
└───────────┼────────────────────┼──────────────────────┼──────────────┘
            │                    │                      │
            └────────────────────┼──────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                           Domain Layer                               │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │
│  │    Entities     │  │   Use Cases     │  │   Value Objects     │  │
│  │  (Data Models)  │  │  (Optional)     │  │   (Enums, Types)    │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                            Data Layer                                │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │
│  │  Repositories   │  │  Data Models    │  │  Data Sources       │  │
│  │ (Abstractions)  │  │ (JSON Mapping)  │  │  (Supabase)         │  │
│  └─────────────────┘  └─────────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                 │
                                 ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         External Services                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐   │
│  │   Supabase   │  │   Google     │  │   Local Storage          │   │
│  │  (Database)  │  │  (OAuth)     │  │  (SharedPrefs/Secure)    │   │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App widget and configuration
│
├── core/                     # Shared core functionality
│   ├── config/               # Configuration files
│   │   ├── constants.dart    # App constants
│   │   └── env.dart          # Environment variables
│   │
│   ├── network/              # Network layer
│   │   ├── supabase_client.dart  # Supabase initialization
│   │   └── api_exceptions.dart   # Exception types
│   │
│   ├── router/               # Navigation
│   │   ├── app_router.dart   # Router configuration
│   │   └── routes.dart       # Route constants
│   │
│   ├── theme/                # Styling
│   │   ├── app_theme.dart    # Theme definitions
│   │   ├── app_colors.dart   # Color palette
│   │   └── theme_provider.dart  # Theme state
│   │
│   ├── services/             # App services
│   │   ├── snackbar_service.dart
│   │   ├── error_handler.dart
│   │   └── connectivity_service.dart
│   │
│   └── utils/                # Utilities
│       └── validators.dart   # Form validators
│
├── features/                 # Feature modules
│   ├── auth/                 # Authentication feature
│   │   ├── data/
│   │   │   ├── models/       # User, Session models
│   │   │   └── repositories/ # AuthRepository
│   │   └── presentation/
│   │       ├── providers/    # AuthProvider
│   │       ├── screens/      # Login, Register, etc.
│   │       └── widgets/      # Auth-specific widgets
│   │
│   ├── dashboard/            # Dashboard feature
│   ├── projects/             # Projects feature
│   ├── chat/                 # Chat feature
│   ├── profile/              # Profile feature
│   ├── earnings/             # Earnings feature
│   ├── resources/            # Resources feature
│   ├── support/              # Support feature
│   ├── notifications/        # Notifications feature
│   ├── users/                # Users management
│   ├── doers/                # Doers management
│   ├── onboarding/           # Onboarding feature
│   ├── registration/         # Registration wizard
│   └── activation/           # Doer activation
│
└── shared/                   # Shared widgets
    └── widgets/
        ├── feedback/         # Loading, error states
        └── accessibility/    # A11y wrappers
```

---

## Architecture Layers

### Presentation Layer

**Responsibilities:**
- Display UI to users
- Handle user interactions
- Manage local UI state
- Connect to providers

**Components:**
- **Screens** - Full page widgets (StatelessWidget/ConsumerWidget)
- **Widgets** - Reusable UI components
- **Providers** - State management with Riverpod

### Domain Layer

**Responsibilities:**
- Define business entities
- Contain business logic (optional use cases)
- Define data contracts

**Components:**
- **Entities** - Business objects (UserModel, ProjectModel)
- **Value Objects** - Enums, types (ProjectStatus, BadgeSize)

### Data Layer

**Responsibilities:**
- Data fetching and caching
- API communication
- Data transformation

**Components:**
- **Repositories** - Data access abstraction
- **Models** - JSON serialization/deserialization
- **Data Sources** - External service connections

---

## State Management

### Riverpod Architecture

```dart
// 1. Provider Definition
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.read(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});

// 2. State Class (Immutable)
class DashboardState {
  final bool isLoading;
  final List<RequestModel> newRequests;
  final List<RequestModel> paidRequests;
  final String? error;
  final String selectedSubject;

  const DashboardState({
    this.isLoading = false,
    this.newRequests = const [],
    this.paidRequests = const [],
    this.error,
    this.selectedSubject = 'All',
  });

  DashboardState copyWith({...}) => DashboardState(...);
}

// 3. Notifier Class (Business Logic)
class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._repository) : super(const DashboardState()) {
    loadData();
  }

  final DashboardRepository _repository;

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRequests = await _repository.getNewRequests();
      final paidRequests = await _repository.getPaidRequests();
      state = state.copyWith(
        isLoading: false,
        newRequests: newRequests,
        paidRequests: paidRequests,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 4. UI Consumption
class DashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardProvider);

    // React to state changes
    return Scaffold(
      body: state.isLoading
          ? const LoadingSkeleton()
          : RequestList(requests: state.newRequests),
    );
  }
}
```

### Provider Types Used

| Provider Type | Use Case |
|--------------|----------|
| `Provider` | Static dependencies (repositories, services) |
| `StateNotifierProvider` | Complex state with actions |
| `StreamProvider` | Realtime streams (auth, chat) |
| `FutureProvider` | One-time async data |

---

## Dependency Injection

Riverpod handles DI through provider composition:

```dart
// Repository provider
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return DashboardRepository(client);
});

// State provider depends on repository
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  final repository = ref.read(dashboardRepositoryProvider);
  return DashboardNotifier(repository);
});
```

### Provider Graph

```
supabaseClientProvider
        │
        ├──► authRepositoryProvider ──► authProvider
        │
        ├──► dashboardRepositoryProvider ──► dashboardProvider
        │
        ├──► projectRepositoryProvider ──► projectsProvider
        │
        └──► chatRepositoryProvider ──► chatProvider
```

---

## Navigation

### GoRouter Configuration

```dart
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    redirect: (context, state) => _authRedirect(authState, state),
    routes: [
      // Public routes
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),

      // Protected shell route
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          // ... more routes
        ],
      ),
    ],
  );
});
```

### Route Guards

```dart
String? _authRedirect(AuthState authState, GoRouterState routerState) {
  final isLoggedIn = authState.isAuthenticated;
  final isPublicRoute = publicRoutes.contains(routerState.matchedLocation);

  // Not logged in, accessing protected route
  if (!isLoggedIn && !isPublicRoute) {
    return RoutePaths.login;
  }

  // Logged in, accessing auth routes
  if (isLoggedIn && isPublicRoute) {
    return RoutePaths.dashboard;
  }

  return null; // No redirect
}
```

---

## Error Handling

### Exception Hierarchy

```dart
abstract class ApiException implements Exception {
  String get message;
}

class AppAuthException extends ApiException {
  final String message;
  AppAuthException(this.message);
}

class ServerException extends ApiException {
  final String message;
  final int? statusCode;

  ServerException(this.message, {this.statusCode});

  factory ServerException.fromPostgrest(PostgrestException e) {
    return ServerException(e.message, statusCode: int.tryParse(e.code ?? ''));
  }
}

class NetworkException extends ApiException {
  final String message = 'No internet connection';
}
```

### Error Handling Flow

```
Repository throws ApiException
        │
        ▼
Provider catches and updates state.error
        │
        ▼
UI displays error banner/dialog
        │
        ▼
User action (retry/dismiss)
```

---

## Security

### Authentication Flow

```
1. User enters credentials
        │
        ▼
2. AuthRepository.signInWithEmail()
        │
        ▼
3. Supabase validates and returns session
        │
        ▼
4. Session stored securely (Supabase handles)
        │
        ▼
5. AuthProvider updates state
        │
        ▼
6. Router redirects to dashboard
```

### Session Persistence

```dart
Future<Session?> recoverSession() async {
  final session = _client.auth.currentSession;

  if (session != null && session.isExpired) {
    // Automatically refresh token
    final response = await _client.auth.refreshSession();
    return response.session;
  }

  return session;
}
```

### Security Best Practices

1. **Row Level Security (RLS)** - All database tables have RLS policies
2. **PKCE Flow** - OAuth uses PKCE for mobile security
3. **Secure Storage** - Sensitive data uses flutter_secure_storage
4. **No Hardcoded Secrets** - All secrets via --dart-define
5. **Input Validation** - All forms validate before submission

---

## Testing

### Test Structure

```
test/
├── features/
│   ├── auth/
│   │   └── providers/
│   │       └── auth_provider_test.dart
│   └── dashboard/
│       └── providers/
│           └── dashboard_provider_test.dart
├── shared/
│   └── widgets/
└── core/
```

### Testing Patterns

**Provider Tests:**
```dart
void main() {
  group('DashboardProvider', () {
    late MockDashboardRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockDashboardRepository();
      container = ProviderContainer(overrides: [
        dashboardRepositoryProvider.overrideWithValue(mockRepository),
      ]);
    });

    test('loads new requests on init', () async {
      when(() => mockRepository.getNewRequests())
          .thenAnswer((_) async => [mockRequest]);

      final state = container.read(dashboardProvider);

      expect(state.newRequests, hasLength(1));
    });
  });
}
```

**Widget Tests:**
```dart
testWidgets('RequestCard displays title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RequestCard(
        request: mockRequest,
        onTap: () {},
        onAction: () {},
        actionLabel: 'Quote',
      ),
    ),
  );

  expect(find.text(mockRequest.title), findsOneWidget);
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/dashboard/providers/dashboard_provider_test.dart
```

---

## Performance Considerations

### Memoization

```dart
// Computed properties are memoized
List<RequestModel> get filteredNewRequests {
  if (selectedSubject == 'All') return newRequests;
  return newRequests.where((r) => r.subject == selectedSubject).toList();
}
```

### Lazy Loading

```dart
// Providers are created lazily
final heavyProvider = Provider((ref) {
  // Only created when first accessed
  return ExpensiveComputation();
});
```

### Widget Optimization

```dart
// Use const constructors
const RequestCard({super.key, required this.request});

// Split large widgets
class LargeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HeaderSection(),  // Separate widget
        ContentSection(), // Separate widget
        FooterSection(),  // Separate widget
      ],
    );
  }
}
```

---

## Best Practices Summary

1. **Feature-First Organization** - Group by feature, not layer
2. **Immutable State** - Use copyWith for state updates
3. **Single Source of Truth** - State lives in providers
4. **Dependency Injection** - Use Riverpod for all dependencies
5. **Error Boundaries** - Handle errors at provider level
6. **Separation of Concerns** - UI knows nothing about data sources
7. **Testability** - All business logic in testable providers
8. **Documentation** - Dartdoc comments on all public APIs

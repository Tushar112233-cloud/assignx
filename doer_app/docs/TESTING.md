# DOER App - Testing Guide

**Last Updated:** December 27, 2024
**Current Coverage:** 0%
**Target Coverage:** 70%+

---

## Overview

This document provides guidelines for testing the DOER Flutter application. It covers unit tests, widget tests, and integration tests with examples and best practices.

---

## 1. Testing Strategy

### 1.1 Test Pyramid

```
                    ┌─────────────┐
                    │ Integration │  ← Fewer, slower, high confidence
                    │    Tests    │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │   Widget    │  ← Medium count, medium speed
                    │    Tests    │
                    └──────┬──────┘
                           │
              ┌────────────┴────────────┐
              │       Unit Tests        │  ← Many, fast, focused
              └─────────────────────────┘
```

### 1.2 Coverage Targets

| Layer | Target Coverage | Priority |
|-------|-----------------|----------|
| Providers (Business Logic) | 80% | High |
| Models | 90% | High |
| Utilities | 90% | High |
| Widgets | 60% | Medium |
| Screens | 40% | Medium |
| Integration | Critical flows | High |

---

## 2. Project Setup

### 2.1 Directory Structure

```
test/
├── unit/
│   ├── providers/
│   │   ├── auth_provider_test.dart
│   │   ├── profile_provider_test.dart
│   │   ├── dashboard_provider_test.dart
│   │   ├── workspace_provider_test.dart
│   │   └── resources_provider_test.dart
│   ├── models/
│   │   ├── user_profile_test.dart
│   │   ├── project_test.dart
│   │   └── payment_transaction_test.dart
│   └── utils/
│       ├── validators_test.dart
│       ├── formatters_test.dart
│       └── masking_utils_test.dart
├── widget/
│   ├── shared/
│   │   ├── app_button_test.dart
│   │   ├── app_text_field_test.dart
│   │   └── loading_indicator_test.dart
│   └── features/
│       ├── auth/
│       │   └── login_screen_test.dart
│       ├── dashboard/
│       │   └── project_card_test.dart
│       └── profile/
│           └── profile_header_test.dart
├── integration/
│   ├── auth_flow_test.dart
│   ├── project_workflow_test.dart
│   └── payment_flow_test.dart
├── mocks/
│   ├── mock_providers.dart
│   ├── mock_repositories.dart
│   └── mock_services.dart
├── fixtures/
│   ├── user_fixtures.dart
│   ├── project_fixtures.dart
│   └── json/
│       ├── user_response.json
│       └── projects_response.json
└── test_utils/
    ├── pump_app.dart
    └── golden_test_utils.dart
```

### 2.2 Dependencies

```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mocktail: ^1.0.1          # Modern mocking library
  bloc_test: ^9.1.5          # For testing state changes (works with Riverpod too)
  integration_test:
    sdk: flutter
  golden_toolkit: ^0.15.0    # For golden/snapshot tests
```

### 2.3 Test Configuration

```dart
// test/test_utils/pump_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    List<Override>? overrides,
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: overrides ?? [],
        child: MaterialApp(
          home: widget,
        ),
      ),
    );
  }
}
```

---

## 3. Unit Tests

### 3.1 Model Tests

```dart
// test/unit/models/user_profile_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:doer_app/providers/profile_provider.dart';

void main() {
  group('UserProfile', () {
    test('creates from JSON correctly', () {
      final json = {
        'id': 'user_123',
        'email': 'test@example.com',
        'full_name': 'John Doe',
        'rating': 4.5,
        'completed_projects': 10,
        'total_earnings': 50000,
        'joined_at': '2024-01-01T00:00:00.000Z',
        'is_verified': true,
        'is_available': true,
        'skills': ['Research', 'Writing'],
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.id, equals('user_123'));
      expect(profile.email, equals('test@example.com'));
      expect(profile.fullName, equals('John Doe'));
      expect(profile.rating, equals(4.5));
      expect(profile.completedProjects, equals(10));
      expect(profile.skills, contains('Research'));
    });

    test('converts to JSON correctly', () {
      final profile = UserProfile(
        id: 'user_123',
        email: 'test@example.com',
        fullName: 'John Doe',
        rating: 4.5,
        completedProjects: 10,
        totalEarnings: 50000,
        joinedAt: DateTime(2024, 1, 1),
        isVerified: true,
        isAvailable: true,
        skills: ['Research'],
      );

      final json = profile.toJson();

      expect(json['id'], equals('user_123'));
      expect(json['full_name'], equals('John Doe'));
      expect(json['skills'], contains('Research'));
    });

    test('copyWith creates new instance with updated values', () {
      final original = UserProfile(
        id: 'user_123',
        email: 'test@example.com',
        fullName: 'John Doe',
        rating: 4.5,
        completedProjects: 10,
        totalEarnings: 50000,
        joinedAt: DateTime(2024, 1, 1),
        isVerified: true,
        isAvailable: true,
        skills: [],
      );

      final updated = original.copyWith(fullName: 'Jane Doe');

      expect(updated.fullName, equals('Jane Doe'));
      expect(updated.email, equals(original.email)); // Unchanged
      expect(updated.id, equals(original.id)); // Unchanged
    });

    test('handles null optional fields', () {
      final json = {
        'id': 'user_123',
        'email': 'test@example.com',
        'full_name': 'John Doe',
        'rating': 4.5,
        'completed_projects': 10,
        'total_earnings': 50000,
        'joined_at': '2024-01-01T00:00:00.000Z',
        'is_verified': true,
        'is_available': true,
        'skills': [],
        // Optional fields omitted
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.avatarUrl, isNull);
      expect(profile.phone, isNull);
      expect(profile.bio, isNull);
    });
  });
}
```

### 3.2 Provider Tests

```dart
// test/unit/providers/profile_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:doer_app/providers/profile_provider.dart';

// Mock repository (when implemented)
class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  group('ProfileNotifier', () {
    late ProviderContainer container;
    late MockProfileRepository mockRepository;

    setUp(() {
      mockRepository = MockProfileRepository();
      container = ProviderContainer(
        overrides: [
          // Override repository provider when implemented
          // profileRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has loading true', () {
      final state = container.read(profileProvider);
      expect(state.isLoading, isTrue);
    });

    test('updateProfile updates state correctly', () async {
      final notifier = container.read(profileProvider.notifier);

      await notifier.updateProfile(
        fullName: 'Updated Name',
        phone: '9876543210',
        bio: 'New bio',
        education: 'PhD',
        skills: ['Writing', 'Research'],
      );

      final state = container.read(profileProvider);
      expect(state.profile?.fullName, equals('Updated Name'));
      expect(state.profile?.phone, equals('9876543210'));
      expect(state.isSaving, isFalse);
    });

    test('markNotificationRead updates notification state', () {
      final notifier = container.read(profileProvider.notifier);

      // Get initial unread count
      final initialState = container.read(profileProvider);
      final initialUnread = initialState.unreadNotificationCount;

      // Mark first notification as read
      final firstNotification = initialState.notifications.first;
      notifier.markNotificationRead(firstNotification.id);

      // Check updated state
      final updatedState = container.read(profileProvider);
      expect(updatedState.unreadNotificationCount, lessThan(initialUnread));
    });

    test('updateAvailability toggles availability', () async {
      final notifier = container.read(profileProvider.notifier);

      final initialState = container.read(profileProvider);
      final wasAvailable = initialState.profile?.isAvailable ?? true;

      await notifier.updateAvailability(!wasAvailable);

      final updatedState = container.read(profileProvider);
      expect(updatedState.profile?.isAvailable, equals(!wasAvailable));
    });
  });
}
```

### 3.3 Utility Tests

```dart
// test/unit/utils/validators_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:doer_app/shared/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateName', () {
      test('returns error for empty name', () {
        expect(Validators.validateName(''), isNotNull);
        expect(Validators.validateName(null), isNotNull);
      });

      test('returns error for name too short', () {
        expect(Validators.validateName('A'), isNotNull);
      });

      test('returns error for name too long', () {
        expect(Validators.validateName('A' * 101), isNotNull);
      });

      test('returns error for invalid characters', () {
        expect(Validators.validateName('John123'), isNotNull);
        expect(Validators.validateName('John@Doe'), isNotNull);
      });

      test('returns null for valid name', () {
        expect(Validators.validateName('John Doe'), isNull);
        expect(Validators.validateName('Mary-Jane'), isNull);
        expect(Validators.validateName('Dr. Smith'), isNull);
      });
    });

    group('validateEmail', () {
      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.validateEmail('notanemail'), isNotNull);
        expect(Validators.validateEmail('missing@domain'), isNotNull);
        expect(Validators.validateEmail('@nodomain.com'), isNotNull);
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name@domain.co.in'), isNull);
      });
    });

    group('validatePhone', () {
      test('returns null for empty (optional field)', () {
        expect(Validators.validatePhone(''), isNull);
        expect(Validators.validatePhone(null), isNull);
      });

      test('returns error for invalid phone', () {
        expect(Validators.validatePhone('12345'), isNotNull);
        expect(Validators.validatePhone('abcdefghij'), isNotNull);
      });

      test('returns null for valid Indian phone', () {
        expect(Validators.validatePhone('9876543210'), isNull);
        expect(Validators.validatePhone('+919876543210'), isNull);
      });
    });

    group('validateAccountNumber', () {
      test('returns error for empty account number', () {
        expect(Validators.validateAccountNumber(''), isNotNull);
      });

      test('returns error for invalid length', () {
        expect(Validators.validateAccountNumber('12345678'), isNotNull);
        expect(Validators.validateAccountNumber('1234567890123456789'), isNotNull);
      });

      test('returns null for valid account number', () {
        expect(Validators.validateAccountNumber('123456789012'), isNull);
      });
    });

    group('validateIFSC', () {
      test('returns error for empty IFSC', () {
        expect(Validators.validateIFSC(''), isNotNull);
      });

      test('returns error for invalid format', () {
        expect(Validators.validateIFSC('ABC'), isNotNull);
        expect(Validators.validateIFSC('HDFC1234567'), isNotNull);
      });

      test('returns null for valid IFSC', () {
        expect(Validators.validateIFSC('HDFC0001234'), isNull);
        expect(Validators.validateIFSC('SBIN0012345'), isNull);
      });
    });
  });
}
```

```dart
// test/unit/utils/formatters_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:doer_app/shared/utils/formatters.dart';

void main() {
  group('DateFormatter', () {
    test('formats as "Just now" for recent times', () {
      final now = DateTime.now();
      expect(DateFormatter.timeAgo(now), equals('Just now'));
    });

    test('formats minutes ago correctly', () {
      final thirtyMinsAgo = DateTime.now().subtract(const Duration(minutes: 30));
      expect(DateFormatter.timeAgo(thirtyMinsAgo), equals('30m ago'));
    });

    test('formats hours ago correctly', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      expect(DateFormatter.timeAgo(twoHoursAgo), equals('2h ago'));
    });

    test('formats days ago correctly', () {
      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      expect(DateFormatter.timeAgo(threeDaysAgo), equals('3d ago'));
    });

    test('formats full date for older dates', () {
      final oldDate = DateTime(2024, 1, 15);
      expect(DateFormatter.timeAgo(oldDate), equals('15/1/2024'));
    });
  });

  group('CurrencyFormatter', () {
    test('formats plain currency correctly', () {
      expect(CurrencyFormatter.formatINR(1000), equals('₹1000'));
      expect(CurrencyFormatter.formatINR(50000), equals('₹50000'));
    });

    test('formats compact currency in thousands', () {
      expect(CurrencyFormatter.formatINR(1500, compact: true), equals('₹1.5K'));
      expect(CurrencyFormatter.formatINR(50000, compact: true), equals('₹50.0K'));
    });

    test('formats compact currency in lakhs', () {
      expect(CurrencyFormatter.formatINR(150000, compact: true), equals('₹1.5L'));
      expect(CurrencyFormatter.formatINR(500000, compact: true), equals('₹5.0L'));
    });

    test('formats compact currency in crores', () {
      expect(CurrencyFormatter.formatINR(15000000, compact: true), equals('₹1.5Cr'));
    });
  });
}
```

---

## 4. Widget Tests

### 4.1 Shared Widget Tests

```dart
// test/widget/shared/app_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doer_app/shared/widgets/app_button.dart';

import '../../test_utils/pump_app.dart';

void main() {
  group('AppButton', () {
    testWidgets('displays text correctly', (tester) async {
      await tester.pumpApp(
        AppButton(
          text: 'Click Me',
          onPressed: () {},
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var pressed = false;

      await tester.pumpApp(
        AppButton(
          text: 'Click Me',
          onPressed: () => pressed = true,
        ),
      );

      await tester.tap(find.byType(AppButton));
      expect(pressed, isTrue);
    });

    testWidgets('shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpApp(
        AppButton(
          text: 'Submit',
          onPressed: () {},
          isLoading: true,
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('is disabled when onPressed is null', (tester) async {
      await tester.pumpApp(
        const AppButton(
          text: 'Disabled',
          onPressed: null,
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpApp(
        AppButton(
          text: 'Save',
          onPressed: () {},
          icon: Icons.save,
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
    });
  });
}
```

### 4.2 Feature Widget Tests

```dart
// test/widget/features/dashboard/project_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:doer_app/features/dashboard/widgets/project_card.dart';
import 'package:doer_app/providers/workspace_provider.dart';

import '../../../test_utils/pump_app.dart';
import '../../../fixtures/project_fixtures.dart';

void main() {
  group('ProjectCard', () {
    testWidgets('displays project title', (tester) async {
      final project = ProjectFixtures.sampleProject;

      await tester.pumpApp(
        ProjectCard(
          project: project,
          onTap: () {},
        ),
      );

      expect(find.text(project.title), findsOneWidget);
    });

    testWidgets('displays deadline', (tester) async {
      final project = ProjectFixtures.sampleProject;

      await tester.pumpApp(
        ProjectCard(
          project: project,
          onTap: () {},
        ),
      );

      expect(find.textContaining('deadline'), findsOneWidget);
    });

    testWidgets('shows correct status badge', (tester) async {
      final project = ProjectFixtures.inProgressProject;

      await tester.pumpApp(
        ProjectCard(
          project: project,
          onTap: () {},
        ),
      );

      expect(find.text('In Progress'), findsOneWidget);
    });

    testWidgets('calls onTap when pressed', (tester) async {
      var tapped = false;
      final project = ProjectFixtures.sampleProject;

      await tester.pumpApp(
        ProjectCard(
          project: project,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(ProjectCard));
      expect(tapped, isTrue);
    });
  });
}
```

---

## 5. Integration Tests

### 5.1 Auth Flow Test

```dart
// integration_test/auth_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:doer_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth Flow', () {
    testWidgets('user can login with valid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen to finish
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to login (if not already there)
      if (find.byType(LoginScreen).evaluate().isEmpty) {
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();
      }

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'password123',
      );

      // Tap login button
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify navigation to dashboard
      expect(find.byType(DashboardScreen), findsOneWidget);
    });

    testWidgets('shows error for invalid credentials', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('email_field')),
        'wrong@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('password_field')),
        'wrongpassword',
      );

      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
```

### 5.2 Running Integration Tests

```bash
# Run on connected device
flutter test integration_test/auth_flow_test.dart

# Run on specific device
flutter test integration_test --device-id=<device_id>

# Run all integration tests
flutter test integration_test/
```

---

## 6. Test Fixtures

```dart
// test/fixtures/user_fixtures.dart
import 'package:doer_app/providers/profile_provider.dart';

class UserFixtures {
  static UserProfile get sampleUser => UserProfile(
    id: 'test_user_1',
    email: 'test@example.com',
    fullName: 'Test User',
    rating: 4.5,
    completedProjects: 10,
    totalEarnings: 50000,
    joinedAt: DateTime(2024, 1, 1),
    isVerified: true,
    isAvailable: true,
    skills: ['Research', 'Writing', 'APA Format'],
  );

  static UserProfile get newUser => UserProfile(
    id: 'new_user_1',
    email: 'new@example.com',
    fullName: 'New User',
    rating: 0,
    completedProjects: 0,
    totalEarnings: 0,
    joinedAt: DateTime.now(),
    isVerified: false,
    isAvailable: true,
    skills: [],
  );

  static UserProfile get topRatedUser => UserProfile(
    id: 'top_user_1',
    email: 'top@example.com',
    fullName: 'Top Writer',
    rating: 5.0,
    completedProjects: 100,
    totalEarnings: 500000,
    joinedAt: DateTime(2023, 1, 1),
    isVerified: true,
    isAvailable: true,
    skills: ['Research', 'Writing', 'Technical Writing', 'APA', 'MLA'],
  );
}

// test/fixtures/project_fixtures.dart
import 'package:doer_app/providers/workspace_provider.dart';

class ProjectFixtures {
  static Project get sampleProject => Project(
    id: 'proj_1',
    title: 'Sample Research Paper',
    subject: 'Computer Science',
    type: 'Research Paper',
    description: 'A sample research paper project',
    deadline: DateTime.now().add(const Duration(days: 7)),
    wordCount: 3000,
    budget: 5000,
    status: ProjectStatus.available,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  );

  static Project get inProgressProject => sampleProject.copyWith(
    id: 'proj_2',
    status: ProjectStatus.inProgress,
  );

  static Project get completedProject => sampleProject.copyWith(
    id: 'proj_3',
    status: ProjectStatus.completed,
  );
}
```

---

## 7. Running Tests

### 7.1 Commands

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/providers/profile_provider_test.dart

# Run tests matching pattern
flutter test --name="validateEmail"

# Run with verbose output
flutter test --reporter=expanded

# Generate coverage report (requires lcov)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 7.2 CI/CD Configuration

```yaml
# .github/workflows/test.yml
name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## 8. Best Practices

### 8.1 Test Naming

```dart
// Use descriptive names
test('returns error when email is empty', () { });
test('formats currency in lakhs when amount exceeds 100000', () { });
test('calls onPressed callback when button is tapped', () { });
```

### 8.2 Arrange-Act-Assert Pattern

```dart
test('updateProfile updates state correctly', () async {
  // Arrange
  final notifier = container.read(profileProvider.notifier);
  final originalName = container.read(profileProvider).profile?.fullName;

  // Act
  await notifier.updateProfile(fullName: 'New Name');

  // Assert
  final updatedName = container.read(profileProvider).profile?.fullName;
  expect(updatedName, equals('New Name'));
  expect(updatedName, isNot(equals(originalName)));
});
```

### 8.3 Test Independence

```dart
// Each test should be independent
setUp(() {
  // Fresh state for each test
  container = ProviderContainer();
});

tearDown(() {
  // Clean up
  container.dispose();
});
```

---

## Related Documents

- [Architecture](./ARCHITECTURE.md)
- [Coding Standards](./CODING_STANDARDS.md)
- [Technical Debt](./TECHNICAL_DEBT.md)

---

*Last updated: December 27, 2024*

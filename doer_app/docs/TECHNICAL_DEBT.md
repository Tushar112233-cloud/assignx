# DOER App - Technical Debt Register

**Last Updated:** December 27, 2024
**Maintainer:** Development Team

---

## Overview

This document tracks technical debt items identified during code analysis. Items are prioritized by impact and effort, with clear acceptance criteria for resolution.

### Priority Definitions

| Priority | Description | Timeline |
|----------|-------------|----------|
| P0 - Critical | Security/stability issues | Immediate |
| P1 - High | Major improvements needed | Next sprint |
| P2 - Medium | Quality improvements | Next 2-3 sprints |
| P3 - Low | Nice to have | Backlog |

### Status Definitions

| Status | Description |
|--------|-------------|
| Open | Not started |
| In Progress | Currently being worked on |
| In Review | PR submitted |
| Done | Completed and merged |

---

## P0 - Critical Issues

### TD-001: Input Validation Missing

**Status:** Open
**Component:** Multiple screens
**Identified:** 2024-12-27

**Description:**
User input fields lack proper validation, allowing potentially malicious or malformed data.

**Affected Files:**
- `lib/features/profile/screens/edit_profile_screen.dart`
- `lib/features/activation/screens/bank_details_screen.dart`
- `lib/features/auth/screens/register_screen.dart`

**Required Changes:**
```dart
// Add to edit_profile_screen.dart
validator: (value) {
  if (value == null || value.isEmpty) return 'Required';
  if (value.length > 100) return 'Maximum 100 characters';
  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
    return 'Only letters and spaces allowed';
  }
  return null;
},
```

**Acceptance Criteria:**
- [ ] All text fields have appropriate validators
- [ ] Phone fields validate format
- [ ] Email fields validate format
- [ ] Bank details validate IFSC/account format
- [ ] Maximum length limits on all fields

**Effort:** 4 hours
**Risk if not fixed:** Data corruption, security vulnerabilities

---

### TD-002: Sensitive Data Not Masked

**Status:** Open
**Component:** Bank Details, Profile
**Identified:** 2024-12-27

**Description:**
Bank account numbers and other sensitive data are displayed in plain text.

**Affected Files:**
- `lib/features/activation/screens/bank_details_screen.dart`
- `lib/features/profile/screens/payment_history_screen.dart`

**Required Changes:**
```dart
// Add to lib/shared/utils/masking_utils.dart
class MaskingUtils {
  static String maskAccountNumber(String number) {
    if (number.length <= 4) return number;
    return '${'*' * (number.length - 4)}${number.substring(number.length - 4)}';
  }

  static String maskPhone(String phone) {
    if (phone.length <= 4) return phone;
    return '${phone.substring(0, 2)}${'*' * (phone.length - 4)}${phone.substring(phone.length - 2)}';
  }
}
```

**Acceptance Criteria:**
- [ ] Account numbers show only last 4 digits
- [ ] Phone numbers partially masked
- [ ] IFSC codes partially masked

**Effort:** 2 hours
**Risk if not fixed:** Privacy violation, compliance issues

---

## P1 - High Priority

### TD-003: Mock Data in Providers

**Status:** Open
**Component:** Providers
**Identified:** 2024-12-27

**Description:**
Providers contain 500+ lines of hardcoded mock data, making them difficult to maintain and test.

**Affected Files:**
- `lib/providers/profile_provider.dart` (~200 lines mock)
- `lib/providers/workspace_provider.dart` (~150 lines mock)
- `lib/providers/resources_provider.dart` (~200 lines mock)
- `lib/providers/dashboard_provider.dart` (~100 lines mock)

**Required Changes:**
Create new directory structure:
```
lib/data/
├── mock/
│   ├── mock_profile_data.dart
│   ├── mock_workspace_data.dart
│   ├── mock_resources_data.dart
│   └── mock_dashboard_data.dart
└── repositories/
    └── (future implementation)
```

**Acceptance Criteria:**
- [ ] All mock data extracted to `lib/data/mock/`
- [ ] Providers import mock data from separate files
- [ ] Mock data can be easily swapped for real API calls
- [ ] Environment flag to toggle mock/real data

**Effort:** 6 hours
**Impact:** Maintainability, testability

---

### TD-004: No Repository Layer

**Status:** Open
**Component:** Architecture
**Identified:** 2024-12-27

**Description:**
Providers directly contain data fetching logic. Adding a repository layer would improve testability and allow easy swapping of data sources.

**Required Changes:**
```dart
// lib/repositories/profile_repository.dart
abstract class ProfileRepository {
  Future<UserProfile> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<List<PaymentTransaction>> getPaymentHistory(String userId);
}

// lib/repositories/impl/supabase_profile_repository.dart
class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client;

  @override
  Future<UserProfile> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserProfile.fromJson(response);
  }
}

// lib/repositories/impl/mock_profile_repository.dart
class MockProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile> getProfile(String userId) async {
    return MockProfileData.sampleProfile;
  }
}
```

**Acceptance Criteria:**
- [ ] Repository interfaces defined for all features
- [ ] Supabase implementations created
- [ ] Mock implementations created
- [ ] Providers use repository interfaces
- [ ] DI setup for repository injection

**Effort:** 16 hours
**Impact:** Testability, maintainability, flexibility

---

### TD-005: Inconsistent Route Constants

**Status:** Open
**Component:** Router
**Identified:** 2024-12-27

**Description:**
Some routes use `RouteNames.*` constants while others use hardcoded strings, leading to inconsistency and potential errors.

**Affected Files:**
- `lib/core/router/app_router.dart`
- `lib/core/router/route_names.dart`

**Current State:**
```dart
// Inconsistent usage in app_router.dart
GoRoute(path: RouteNames.dashboard, ...)     // Constant
GoRoute(path: '/profile', ...)                // Hardcoded
GoRoute(path: '/project/:id', ...)            // Hardcoded
```

**Required Changes:**
```dart
// route_names.dart - Add missing constants
class RouteNames {
  // ... existing
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const paymentHistory = '/profile/payments';
  static const bankDetailsEdit = '/profile/bank-details';
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const support = '/support';
  static const projectDetail = '/project/:id';
  static const workspace = '/project/:id/workspace';
  static const submitWork = '/project/:id/submit';
  static const revision = '/project/:id/revision';
  static const projectChat = '/project/:id/chat';
  static const myProjects = '/dashboard/projects';
}
```

**Acceptance Criteria:**
- [ ] All routes defined in `RouteNames`
- [ ] All `GoRoute` declarations use constants
- [ ] All navigation calls use constants
- [ ] No hardcoded route strings in codebase

**Effort:** 3 hours
**Impact:** Maintainability, type safety

---

### TD-006: Missing Error Logging

**Status:** Open
**Component:** Providers, Services
**Identified:** 2024-12-27

**Description:**
Errors are caught but not logged, making debugging difficult in production.

**Required Changes:**
```dart
// lib/core/services/logger_service.dart
class LoggerService {
  static void error(String message, dynamic error, [StackTrace? stackTrace]) {
    // In development: print to console
    debugPrint('ERROR: $message');
    debugPrint('Details: $error');
    if (stackTrace != null) debugPrint('Stack: $stackTrace');

    // In production: send to crash reporting service
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  static void info(String message) {
    debugPrint('INFO: $message');
  }
}

// Usage in providers
} catch (e, stackTrace) {
  LoggerService.error('Failed to load profile', e, stackTrace);
  state = state.copyWith(error: e.toString());
}
```

**Acceptance Criteria:**
- [ ] LoggerService created with error/info/debug methods
- [ ] All catch blocks use LoggerService
- [ ] Crash reporting integration ready (Firebase Crashlytics)
- [ ] Log levels configurable by environment

**Effort:** 4 hours
**Impact:** Debuggability, monitoring

---

## P2 - Medium Priority

### TD-007: Duplicate Helper Functions

**Status:** Open
**Component:** Screens
**Identified:** 2024-12-27

**Description:**
Date and currency formatting functions are duplicated across multiple files.

**Affected Files:**
- `lib/features/profile/screens/notifications_screen.dart` - `_formatTime()`
- `lib/features/profile/screens/payment_history_screen.dart` - `_formatDate()`, `_formatCurrency()`
- `lib/features/workspace/screens/chat_screen.dart` - `_formatTime()`
- `lib/features/dashboard/screens/dashboard_screen.dart` - `_formatCurrency()`

**Required Changes:**
```dart
// lib/shared/utils/formatters.dart
class DateFormatter {
  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  static String shortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class CurrencyFormatter {
  static String formatINR(num amount, {bool compact = false}) {
    if (!compact) return '₹${amount.toStringAsFixed(0)}';

    if (amount >= 10000000) return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '₹${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '₹${(amount / 1000).toStringAsFixed(1)}K';
    return '₹${amount.toStringAsFixed(0)}';
  }
}
```

**Acceptance Criteria:**
- [ ] Formatter utilities created in `lib/shared/utils/`
- [ ] All screens updated to use shared formatters
- [ ] Unit tests for formatters
- [ ] No duplicate formatting functions

**Effort:** 3 hours
**Impact:** Maintainability, consistency

---

### TD-008: Large Build Methods

**Status:** Open
**Component:** Screens
**Identified:** 2024-12-27

**Description:**
Several screens have build methods exceeding 200 lines, making them hard to read and maintain.

**Affected Files:**
| File | Build Lines | Target |
|------|-------------|--------|
| `settings_screen.dart` | ~250 | <100 |
| `profile_screen.dart` | ~200 | <100 |
| `workspace_screen.dart` | ~300 | <100 |
| `resources_hub_screen.dart` | ~180 | <100 |

**Required Changes:**
Extract widgets:
```dart
// settings_screen.dart refactor
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const InnerHeader(title: 'Settings'),
          Expanded(
            child: SettingsBody(ref: ref),
          ),
        ],
      ),
    );
  }
}

// Extracted widgets
class _AccountSection extends StatelessWidget { ... }
class _NotificationSection extends ConsumerWidget { ... }
class _AppSettingsSection extends StatelessWidget { ... }
class _SupportSection extends StatelessWidget { ... }
```

**Acceptance Criteria:**
- [ ] No build method exceeds 100 lines
- [ ] Extracted widgets are in same file or `widgets/` subfolder
- [ ] Proper const usage for static widgets
- [ ] No functionality changes

**Effort:** 8 hours
**Impact:** Readability, maintainability

---

### TD-009: No Image Caching

**Status:** Open
**Component:** Profile, Dashboard
**Identified:** 2024-12-27

**Description:**
Network images are loaded without caching, causing repeated downloads and poor performance.

**Affected Files:**
- `lib/features/profile/screens/profile_screen.dart`
- `lib/features/profile/screens/edit_profile_screen.dart`
- `lib/features/dashboard/screens/dashboard_screen.dart`

**Required Changes:**
```yaml
# pubspec.yaml
dependencies:
  cached_network_image: ^3.3.1
```

```dart
// Replace Image.network with CachedNetworkImage
CachedNetworkImage(
  imageUrl: profile.avatarUrl!,
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => _buildAvatarText(profile),
  width: 96,
  height: 96,
  fit: BoxFit.cover,
)
```

**Acceptance Criteria:**
- [ ] `cached_network_image` package added
- [ ] All network images use caching
- [ ] Placeholder widgets for loading
- [ ] Error widgets for failed loads

**Effort:** 2 hours
**Impact:** Performance, UX

---

### TD-010: Hardcoded App Version

**Status:** Open
**Component:** Settings
**Identified:** 2024-12-27

**Description:**
App version is hardcoded in settings screen instead of reading from package info.

**Affected Files:**
- `lib/features/profile/screens/settings_screen.dart:239`

**Required Changes:**
```yaml
# pubspec.yaml
dependencies:
  package_info_plus: ^8.0.0
```

```dart
// Create version provider
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

// In settings_screen.dart
Consumer(
  builder: (context, ref, _) {
    final version = ref.watch(appVersionProvider);
    return version.when(
      data: (v) => Text('Version $v'),
      loading: () => const Text('Loading...'),
      error: (_, __) => const Text('Version unknown'),
    );
  },
)
```

**Acceptance Criteria:**
- [ ] `package_info_plus` package added
- [ ] Version provider created
- [ ] Settings screen uses dynamic version
- [ ] Build number included

**Effort:** 1 hour
**Impact:** Accuracy, maintainability

---

### TD-011: Models Not Consolidated

**Status:** Open
**Component:** Architecture
**Identified:** 2024-12-27

**Description:**
Model classes are defined inside provider files instead of a centralized models directory.

**Current State:**
- `UserProfile` in `profile_provider.dart`
- `Project` in `workspace_provider.dart`
- `TrainingModule` in `resources_provider.dart`
- etc.

**Required Changes:**
```
lib/models/
├── user/
│   ├── user_profile.dart
│   └── user_preferences.dart
├── project/
│   ├── project.dart
│   ├── project_file.dart
│   └── project_message.dart
├── payment/
│   ├── payment_transaction.dart
│   └── bank_details.dart
├── notification/
│   └── app_notification.dart
└── resources/
    ├── training_module.dart
    ├── ai_check_result.dart
    └── citation.dart
```

**Acceptance Criteria:**
- [ ] All models in `lib/models/` directory
- [ ] Models exported via barrel file
- [ ] Providers import from models directory
- [ ] No model definitions in providers

**Effort:** 4 hours
**Impact:** Organization, reusability

---

## P3 - Low Priority

### TD-012: No Const Constructors on Static Widgets

**Status:** Open
**Component:** Various
**Identified:** 2024-12-27

**Description:**
Some widgets that could be const are not marked as such, missing optimization opportunities.

**Example:**
```dart
// Current
SizedBox(height: 16),
Icon(Icons.check, color: Colors.green),

// Should be
const SizedBox(height: 16),
const Icon(Icons.check, color: Colors.green),
```

**Acceptance Criteria:**
- [ ] All eligible widgets use const
- [ ] Lint rule `prefer_const_constructors` enabled
- [ ] CI check for const usage

**Effort:** 2 hours
**Impact:** Performance (minor)

---

### TD-013: Anonymous Functions in Callbacks

**Status:** Open
**Component:** Various screens
**Identified:** 2024-12-27

**Description:**
Using anonymous functions in callbacks creates new function instances on each rebuild.

**Example:**
```dart
// Current (creates new function each build)
Switch(
  onChanged: (value) => _updatePreference(value),
)

// Better (for simple cases, use tear-off)
Switch(
  onChanged: _updatePreference,
)
```

**Acceptance Criteria:**
- [ ] Simple callbacks use tear-offs
- [ ] Complex callbacks extracted to methods
- [ ] Lint rule `prefer_function_declarations_over_variables`

**Effort:** 2 hours
**Impact:** Performance (minor)

---

### TD-014: Missing Loading States

**Status:** Open
**Component:** Various screens
**Identified:** 2024-12-27

**Description:**
Some screens don't show loading indicators while data is being fetched.

**Affected Areas:**
- Profile screen initial load
- Payment history refresh
- Settings preferences update

**Acceptance Criteria:**
- [ ] All async operations show loading state
- [ ] Shimmer/skeleton loaders for lists
- [ ] Button loading states for actions

**Effort:** 4 hours
**Impact:** UX

---

## Completed Items

_(Move items here when done)_

| ID | Title | Completed | Notes |
|----|-------|-----------|-------|
| - | - | - | - |

---

## Appendix: Quick Reference

### Files Requiring Most Attention

1. `lib/features/profile/screens/settings_screen.dart` - TD-008, TD-010
2. `lib/providers/profile_provider.dart` - TD-003, TD-011
3. `lib/features/profile/screens/edit_profile_screen.dart` - TD-001
4. `lib/core/router/app_router.dart` - TD-005
5. `lib/providers/workspace_provider.dart` - TD-003, TD-011

### Estimated Total Effort

| Priority | Items | Total Hours |
|----------|-------|-------------|
| P0 | 2 | 6 hours |
| P1 | 4 | 29 hours |
| P2 | 5 | 18 hours |
| P3 | 3 | 8 hours |
| **Total** | **14** | **61 hours** |

---

*Last reviewed: 2024-12-27*

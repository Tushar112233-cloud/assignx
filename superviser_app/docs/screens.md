# Screens Documentation

This document describes all screens (pages) in the Superviser App.

## Table of Contents

- [Navigation Structure](#navigation-structure)
- [Authentication Screens](#authentication-screens)
- [Onboarding Screens](#onboarding-screens)
- [Registration Screens](#registration-screens)
- [Activation Screens](#activation-screens)
- [Main App Screens](#main-app-screens)
- [Screen State Management](#screen-state-management)

---

## Navigation Structure

The app uses GoRouter for navigation with the following hierarchy:

```
App
├── Public Routes (No Auth Required)
│   ├── /splash          → SplashScreen
│   ├── /login           → LoginScreen
│   ├── /register        → RegisterScreen
│   ├── /forgot-password → ForgotPasswordScreen
│   └── /onboarding      → OnboardingScreen
│
├── Semi-Protected Routes (Auth Required, Activation Optional)
│   ├── /registration         → RegistrationWizardScreen
│   └── /registration-pending → ApplicationPendingScreen
│
├── Activation Routes
│   ├── /activation              → ActivationScreen
│   ├── /activation/video/:id    → TrainingVideoScreen
│   ├── /activation/document/:id → TrainingDocumentScreen
│   ├── /activation/quiz/:id     → QuizScreen
│   └── /activation/complete     → ActivationCompleteScreen
│
└── Protected Routes (Full Auth + Activation Required)
    └── ShellRoute (with BottomNavigationBar)
        ├── /dashboard     → DashboardScreen
        ├── /projects      → ProjectsScreen
        │   └── /:id       → ProjectDetailScreen
        ├── /chat          → ChatListScreen
        │   └── /:roomId   → ChatScreen
        ├── /profile       → ProfileScreen
        │   ├── /reviews   → ReviewsScreen
        │   └── /blacklist → BlacklistScreen
        ├── /earnings      → EarningsScreen
        ├── /resources     → ResourcesScreen
        │   ├── /video/:id → TrainingVideoPlayerScreen
        │   └── /webview   → ToolWebViewScreen
        ├── /support       → SupportScreen
        │   └── /ticket/:id → TicketDetailScreen
        ├── /faq           → FAQScreen
        ├── /notifications → NotificationsScreen
        ├── /users         → UsersScreen
        │   └── /:clientId → ClientDetailScreen
        └── /doers         → DoersScreen
```

---

## Authentication Screens

### SplashScreen

**File:** `lib/features/auth/presentation/screens/splash_screen.dart`
**Route:** `/splash`

The initial loading screen shown on app launch.

**Responsibilities:**
- Initialize app services
- Check authentication state
- Recover existing session
- Navigate to appropriate screen

**State Flow:**
```
SplashScreen
    │
    ├─ Session Found → Dashboard
    ├─ No Session → Login
    └─ First Launch → Onboarding
```

---

### LoginScreen

**File:** `lib/features/auth/presentation/screens/login_screen.dart`
**Route:** `/login`

Email/password and Google Sign-In screen.

**Features:**
- Email/password form with validation
- Google Sign-In button
- "Forgot Password" link
- "Create Account" link
- Loading state during authentication
- Error display

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Email | `TextFormField` | Valid email format |
| Password | `TextFormField` | Min 8 characters |

**Actions:**
- `signInWithEmail()` - Email/password login
- `signInWithGoogle()` - OAuth with Google
- Navigate to `/register` - Create new account
- Navigate to `/forgot-password` - Reset password

---

### RegisterScreen

**File:** `lib/features/auth/presentation/screens/register_screen.dart`
**Route:** `/register`

New user registration screen.

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Full Name | `TextFormField` | Required, min 2 chars |
| Email | `TextFormField` | Valid email format |
| Password | `TextFormField` | Min 8 chars, mixed case |
| Confirm Password | `TextFormField` | Must match password |

**Actions:**
- `signUpWithEmail()` - Create account
- Navigate to `/login` - Back to login

---

### ForgotPasswordScreen

**File:** `lib/features/auth/presentation/screens/forgot_password_screen.dart`
**Route:** `/forgot-password`

Password reset request screen.

**Form Fields:**
| Field | Type | Validation |
|-------|------|------------|
| Email | `TextFormField` | Valid email format |

**Actions:**
- `resetPassword()` - Send reset email
- Navigate back to `/login`

---

## Onboarding Screens

### OnboardingScreen

**File:** `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
**Route:** `/onboarding`

First-time user introduction carousel.

**Features:**
- Swipeable page views
- Page indicators
- Skip button
- Get Started button

**Pages:**
1. Welcome to AdminX
2. Manage Projects
3. Track Earnings
4. Support & Resources

---

## Registration Screens

### RegistrationWizardScreen

**File:** `lib/features/registration/presentation/screens/registration_wizard_screen.dart`
**Route:** `/registration`

Multi-step supervisor registration form.

**Steps:**

| Step | Component | Fields |
|------|-----------|--------|
| 1 | `PersonalInfoStep` | Name, phone, address, bio |
| 2 | `ExperienceStep` | Education, subjects, experience |
| 3 | `BankingStep` | Bank details for payments |
| 4 | `ReviewStep` | Review and submit |

**Features:**
- Progress indicator
- Step navigation
- Form validation per step
- Data persistence between steps
- Document upload capability

---

### ApplicationPendingScreen

**File:** `lib/features/registration/presentation/screens/application_pending_screen.dart`
**Route:** `/registration-pending`

Displays pending application status.

**Features:**
- Application status display
- Estimated review time
- Contact support link
- Refresh status button

---

## Activation Screens

### ActivationScreen

**File:** `lib/features/activation/presentation/screens/activation_screen.dart`
**Route:** `/activation`

Training module overview for new doers.

**Features:**
- Training modules list
- Completion progress
- Module status (locked/available/completed)
- Continue learning button

---

### TrainingVideoScreen

**File:** `lib/features/activation/presentation/screens/training_video_screen.dart`
**Route:** `/activation/video/:moduleId`

Video training content player.

**Features:**
- Video player with controls
- Progress tracking
- Mark as complete button
- Next module navigation

---

### TrainingDocumentScreen

**File:** `lib/features/activation/presentation/screens/training_document_screen.dart`
**Route:** `/activation/document/:moduleId`

Document/PDF training content viewer.

**Features:**
- Document viewer
- Page navigation
- Mark as complete
- Download option

---

### QuizScreen

**File:** `lib/features/activation/presentation/screens/quiz_screen.dart`
**Route:** `/activation/quiz/:quizId`

Training assessment quiz.

**Features:**
- Question display
- Multiple choice answers
- Progress indicator
- Submit and score
- Pass/fail result

---

### ActivationCompleteScreen

**File:** `lib/features/activation/presentation/screens/activation_complete_screen.dart`
**Route:** `/activation/complete`

Successful activation celebration.

**Features:**
- Success animation
- Completion message
- Start working button

---

## Main App Screens

### DashboardScreen

**File:** `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
**Route:** `/dashboard`

Main supervisor dashboard.

**Sections:**
1. **Header** - Menu, notifications, greeting
2. **Field Filter** - Subject category chips
3. **New Requests** - Submitted projects awaiting quotes
4. **Ready to Assign** - Paid projects for doer assignment
5. **Quick Actions FAB** - Common actions

**Actions:**
- Pull-to-refresh
- Filter by subject
- View request details
- Submit quote
- Assign doer

---

### ProjectsScreen

**File:** `lib/features/projects/presentation/screens/projects_screen.dart`
**Route:** `/projects`

All projects list with filtering.

**Features:**
- Tab filtering (Active/Completed/All)
- Search functionality
- Project cards
- Pull-to-refresh

---

### ProjectDetailScreen

**File:** `lib/features/projects/presentation/screens/project_detail_screen.dart`
**Route:** `/projects/:id`

Individual project details and management.

**Sections:**
1. Project info (title, subject, deadline)
2. Client info
3. Assigned doer
4. Status timeline
5. Deliverables
6. Chat shortcut
7. Action buttons

---

### ChatListScreen

**File:** `lib/features/chat/presentation/screens/chat_list_screen.dart`
**Route:** `/chat`

All chat conversations list.

**Features:**
- Chat room tiles
- Unread indicators
- Last message preview
- Search chats

---

### ChatScreen

**File:** `lib/features/chat/presentation/screens/chat_screen.dart`
**Route:** `/chat/:roomId`

Individual chat conversation.

**Features:**
- Message list
- Realtime updates
- Message input
- Send attachments
- Read receipts

---

### ProfileScreen

**File:** `lib/features/profile/presentation/screens/profile_screen.dart`
**Route:** `/profile`

User profile and settings.

**Sections:**
1. Profile header (avatar, name, stats)
2. Account settings
3. App settings
4. Support links
5. Sign out

**Menu Items:**
- Edit Profile
- Reviews
- Blacklist
- Notification Settings
- Privacy Settings
- Help & Support
- Sign Out

---

### ReviewsScreen

**File:** `lib/features/profile/presentation/screens/reviews_screen.dart`
**Route:** `/profile/reviews`

Reviews received from clients.

**Features:**
- Review cards
- Star ratings
- Reviewer info
- Date display

---

### BlacklistScreen

**File:** `lib/features/profile/presentation/screens/blacklist_screen.dart`
**Route:** `/profile/blacklist`

Manage blocked doers/clients.

**Features:**
- Blocked users list
- Unblock option
- Add to blacklist

---

### EarningsScreen

**File:** `lib/features/earnings/presentation/screens/earnings_screen.dart`
**Route:** `/earnings`

Earnings overview and transaction history.

**Sections:**
1. Earnings summary card
2. Earnings chart
3. Transaction history
4. Period filter

---

### ResourcesScreen

**File:** `lib/features/resources/presentation/screens/resources_screen.dart`
**Route:** `/resources`

Tools and training resources.

**Sections:**
1. Quick tools (Plagiarism, AI detector)
2. Training videos library
3. Pricing guide
4. Templates

---

### TrainingVideoPlayerScreen

**File:** `lib/features/resources/presentation/screens/training_video_screen.dart`
**Route:** `/resources/video/:videoId`

Training video player.

**Features:**
- Video player
- Description
- Related videos

---

### ToolWebViewScreen

**File:** `lib/features/resources/presentation/screens/tool_webview_screen.dart`
**Route:** `/resources/webview`

External tool WebView.

**Features:**
- WebView browser
- Navigation controls
- Share URL

---

### SupportScreen

**File:** `lib/features/support/presentation/screens/support_screen.dart`
**Route:** `/support`

Help and support center.

**Features:**
- Create ticket button
- Tickets list
- Quick FAQs link

---

### TicketDetailScreen

**File:** `lib/features/support/presentation/screens/ticket_detail_screen.dart`
**Route:** `/support/ticket/:ticketId`

Individual support ticket conversation.

**Features:**
- Ticket info
- Message thread
- Reply input
- Close ticket

---

### FAQScreen

**File:** `lib/features/support/presentation/screens/faq_screen.dart`
**Route:** `/faq`

Frequently asked questions.

**Features:**
- Accordion FAQ list
- Category tabs
- Search FAQs

---

### NotificationsScreen

**File:** `lib/features/notifications/presentation/screens/notifications_screen.dart`
**Route:** `/notifications`

All notifications list.

**Features:**
- Notification cards
- Read/unread status
- Mark all as read
- Delete notifications
- Filter by type

---

### UsersScreen

**File:** `lib/features/users/presentation/screens/users_screen.dart`
**Route:** `/users`

Client users management.

**Features:**
- Client list
- Search clients
- View client details

---

### DoersScreen

**File:** `lib/features/doers/presentation/screens/doers_screen.dart`
**Route:** `/doers`

Doers management.

**Features:**
- Doers list
- Filter by availability
- Search doers
- View doer profiles

---

## Screen State Management

Each screen uses Riverpod providers for state management.

### Provider Pattern

```dart
// Provider definition
final myScreenProvider = StateNotifierProvider<MyScreenNotifier, MyScreenState>((ref) {
  return MyScreenNotifier(ref.read(repositoryProvider));
});

// State class
class MyScreenState {
  final bool isLoading;
  final List<Item> items;
  final String? error;

  const MyScreenState({
    this.isLoading = false,
    this.items = const [],
    this.error,
  });
}

// Notifier class
class MyScreenNotifier extends StateNotifier<MyScreenState> {
  MyScreenNotifier(this._repository) : super(const MyScreenState()) {
    _loadData();
  }

  final Repository _repository;

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repository.getItems();
      state = state.copyWith(isLoading: false, items: items);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

### Screen Usage

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myScreenProvider);

    if (state.isLoading) {
      return const LoadingSkeleton();
    }

    if (state.error != null) {
      return ErrorDisplay(error: state.error!);
    }

    return ItemList(items: state.items);
  }
}
```

---

## Navigation Helpers

### Route Constants

**File:** `lib/core/router/routes.dart`

```dart
abstract class RoutePaths {
  static const splash = '/splash';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const projects = '/projects';
  static const projectDetail = '/projects/:id';
  // ... more routes
}

abstract class RouteNames {
  static const splash = 'splash';
  static const login = 'login';
  static const dashboard = 'dashboard';
  // ... more names
}
```

### Navigation Examples

```dart
// Navigate and replace stack
context.go(RoutePaths.dashboard);

// Push onto stack
context.push(RoutePaths.projects);

// Push with parameters
context.pushNamed(
  RouteNames.projectDetail,
  pathParameters: {'id': projectId},
);

// Pop back
context.pop();

// Pop with result
context.pop(result);
```

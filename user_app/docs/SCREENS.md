# Screens Documentation

This document describes all screens in the AssignX User App.

## Overview

Screens are organized by feature in `lib/features/*/screens/`. Each screen is a Flutter widget that represents a full page in the application.

---

## Navigation Structure

```
App Launch
    │
    ▼
┌─────────────────┐
│  Splash Screen  │ (Auto-redirect based on auth state)
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌────────┐  ┌─────────────────┐
│ Login  │  │  Main App Shell │
└────────┘  └────────┬────────┘
                     │
    ┌────────────────┼────────────────┐
    ▼                ▼                ▼
┌────────┐    ┌──────────┐    ┌──────────┐
│  Home  │    │ Projects │    │ Profile  │
└────────┘    └──────────┘    └──────────┘
```

---

## Splash & Auth Screens

### SplashScreen

**File:** `lib/features/splash/screens/splash_screen.dart`

The initial loading screen shown when the app launches.

#### Responsibilities

- Display app branding (logo, app name)
- Check authentication state
- Redirect to appropriate screen

#### Navigation Logic

```dart
if (isAuthenticated) {
  if (profile.onboardingCompleted) {
    → Navigate to Home
  } else {
    → Navigate to Onboarding (resume at current step)
  }
} else {
  → Navigate to Login
}
```

---

### LoginScreen

**File:** `lib/features/auth/screens/login_screen.dart`

Authentication screen for user sign-in.

#### Features

- Google Sign-In button
- App branding and welcome message
- Terms of service link
- Privacy policy link

#### Flow

1. User taps "Sign in with Google"
2. OAuth flow opens in browser/webview
3. User authenticates with Google
4. Callback returns to app
5. Profile created/fetched
6. Navigate to Onboarding or Home

---

## Onboarding Screens

### RoleSelectionScreen

**File:** `lib/features/onboarding/screens/role_selection_screen.dart`

First step of onboarding - user selects their account type.

#### Options

| Role | Description | Icon |
|------|-------------|------|
| Student | Currently pursuing education | `school` |
| Professional | Working professional | `business_center` |

#### Next Steps

- Student → StudentProfileScreen
- Professional → ProfessionalProfileScreen

---

### StudentProfileScreen

**File:** `lib/features/onboarding/screens/student_profile_screen.dart`

Collects student-specific information.

#### Form Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Full Name | Text | Yes | Display name |
| Phone | Phone | No | Contact number |
| University | Dropdown/Search | Yes | Educational institution |
| Course | Dropdown | Yes | Program of study |
| Year | Dropdown | Yes | Current year (1-5) |
| Semester | Dropdown | No | Current semester |

#### Validation

- Name: 2-100 characters
- Phone: Valid Indian number (+91)
- University: Must be selected
- Course: Must be selected

---

### ProfessionalProfileScreen

**File:** `lib/features/onboarding/screens/professional_profile_screen.dart`

Collects professional-specific information.

#### Form Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| Full Name | Text | Yes | Display name |
| Phone | Phone | No | Contact number |
| Professional Type | Selection | Yes | Job Seeker/Business/Creator |
| Industry | Dropdown | Yes | Work industry |
| Job Title | Text | No | Current position |
| Company | Text | No | Current employer |
| LinkedIn | URL | No | Profile URL |

---

## Main App Screens

### HomeScreen

**File:** `lib/features/home/screens/home_screen.dart`

Main dashboard and entry point after login.

#### Sections

1. **Header**
   - User greeting
   - Wallet balance
   - Notification bell

2. **Promo Banners**
   - Auto-scrolling carousel
   - Deep link support
   - Promotional content

3. **Quick Actions**
   - New Project
   - My Projects
   - Proofreading
   - Expert Opinion
   - Marketplace
   - Wallet

4. **Active Projects**
   - Recent project cards
   - Status indicators
   - Quick access to details

#### Widgets Used

- `PromoBannerCarousel`
- `QuickActionsGrid`
- `ProjectCard`
- `WalletSummary`

---

### ProjectsScreen

**File:** `lib/features/projects/screens/projects_screen.dart`

List view of all user projects.

#### Features

- Tabbed filtering (All, Active, Completed)
- Search functionality
- Sort options (Date, Status)
- Pull-to-refresh
- Empty state handling

#### Tabs

| Tab | Filter |
|-----|--------|
| In Review | draft, submitted, analyzing, quoted, payment_pending |
| In Progress | paid, assigning, assigned, in_progress, submitted_for_qc |
| For Review | delivered |
| History | completed, cancelled, refunded |

---

### ProjectDetailScreen

**File:** `lib/features/projects/screens/project_detail_screen.dart`

Detailed view of a single project.

#### Sections

1. **Status Banner**
   - Current status with color
   - Progress percentage
   - Action button (context-dependent)

2. **Project Brief**
   - Title and service type
   - Subject and topic
   - Word/page count
   - Special instructions
   - Reference files

3. **Timeline**
   - Visual progress tracker
   - Milestone status
   - Timestamps

4. **Deliverables** (when available)
   - Download buttons
   - Version history
   - Quality reports (AI, Plagiarism)

5. **Live Draft** (during progress)
   - Document preview
   - Progress updates
   - Full-screen option

6. **Actions**
   - Approve delivery
   - Request revision
   - Contact support

---

### ProjectTimelineScreen

**File:** `lib/features/projects/screens/project_timeline_screen.dart`

Full-screen timeline view.

#### Features

- Vertical timeline layout
- Completed/pending indicators
- Milestone descriptions
- Timestamps
- Expected dates

---

## Project Creation Screens

### AddProjectScreen

**File:** `lib/features/add_project/screens/add_project_screen.dart`

Multi-step project creation wizard.

#### Steps

1. **Service Selection**
   - New Project
   - Proofreading
   - Plagiarism Check
   - AI Detection
   - Expert Opinion

2. **Basic Details**
   - Title
   - Subject category
   - Topic
   - Description

3. **Requirements**
   - Word count / Page count
   - Reference style
   - Deadline
   - Special instructions

4. **File Upload**
   - Reference materials
   - Guidelines documents
   - Multiple file support

5. **Review & Submit**
   - Summary of all details
   - Edit options
   - Submit button

---

## Profile Screens

### ProfileScreen

**File:** `lib/features/profile/screens/profile_screen.dart`

User profile and settings hub.

#### Sections

1. **Profile Hero**
   - Avatar with edit option
   - Display name
   - User type badge
   - Verification status

2. **Stats Card**
   - Wallet balance
   - Projects completed
   - Quick actions (Top Up, View All)

3. **Settings Menu**
   - Edit Profile
   - Payment Methods
   - Notifications
   - Help & Support
   - Terms & Privacy
   - Sign Out

4. **App Version**
   - Version number
   - Build information

---

### EditProfileScreen

**File:** `lib/features/profile/screens/edit_profile_screen.dart`

Profile editing form.

#### Editable Fields

- Profile photo
- Full name
- Phone number
- City
- State
- Email (read-only)

---

### WalletScreen

**File:** `lib/features/profile/screens/wallet_screen.dart`

Wallet management and transactions.

#### Sections

1. **Balance Card**
   - Current balance
   - Locked amount
   - Available balance
   - Top Up button

2. **Quick Actions**
   - Add Money
   - Transaction History
   - Payment Methods

3. **Recent Transactions**
   - Transaction list
   - Type indicators
   - Amount with +/- sign
   - Date/time

---

## Marketplace Screens

### MarketplaceScreen

**File:** `lib/features/marketplace/screens/marketplace_screen.dart`

Campus marketplace listing view.

#### Features

- Category filters
- Search bar
- Grid/List view toggle
- Sort options (Recent, Price)
- Like/save functionality

#### Categories

- Hard Goods (Books, Electronics)
- Housing (PG, Flatmates)
- Opportunities (Internships, Jobs)
- Discussions (Q&A, Groups)
- Events (Campus events)
- Rides (Carpooling)

---

### ListingDetailScreen

**File:** `lib/features/marketplace/screens/listing_detail_screen.dart`

Single marketplace listing detail.

#### Sections

- Image gallery
- Title and price
- Description
- Seller info
- Contact button
- Report option

---

### CreateListingScreen

**File:** `lib/features/marketplace/screens/create_listing_screen.dart`

Create new marketplace listing.

#### Form Fields

- Category selection
- Listing type (Sell, Buy, Rent)
- Title
- Description
- Price
- Images (up to 5)
- Location

---

## Screen Patterns

### Loading States

```dart
AsyncValue.when(
  data: (data) => ContentWidget(data: data),
  loading: () => const LoadingShimmer(),
  error: (e, _) => ErrorWidget(
    message: 'Failed to load data',
    onRetry: () => ref.refresh(dataProvider),
  ),
)
```

### Empty States

```dart
if (items.isEmpty) {
  return EmptyState(
    icon: Icons.inbox_outlined,
    title: 'No items yet',
    message: 'Your items will appear here',
    action: ElevatedButton(
      onPressed: () => navigateToCreate(),
      child: Text('Create New'),
    ),
  );
}
```

### Pull to Refresh

```dart
RefreshIndicator(
  onRefresh: () => ref.refresh(dataProvider.future),
  child: ListView.builder(...),
)
```

### Form Validation

```dart
Form(
  key: _formKey,
  autovalidateMode: AutovalidateMode.onUserInteraction,
  child: Column(
    children: [
      TextFormField(
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'This field is required';
          }
          return null;
        },
      ),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            _submit();
          }
        },
        child: Text('Submit'),
      ),
    ],
  ),
)
```

---

## Screen Lifecycle

### ConsumerStatefulWidget Example

```dart
class MyScreen extends ConsumerStatefulWidget {
  const MyScreen({super.key});

  @override
  ConsumerState<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends ConsumerState<MyScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data
  }

  @override
  void dispose() {
    // Clean up controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(dataProvider);
    // Build UI
  }
}
```

### ConsumerWidget Example

```dart
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dataProvider);

    return dataAsync.when(
      data: (data) => _buildContent(context, data),
      loading: () => const LoadingScreen(),
      error: (e, _) => ErrorScreen(error: e),
    );
  }

  Widget _buildContent(BuildContext context, Data data) {
    // Build content
  }
}
```

---

## Accessibility

### Screen Reader Support

- Use `Semantics` widgets for custom components
- Provide meaningful labels
- Announce state changes

### Navigation

- Maintain focus order
- Support keyboard navigation
- Provide back button handling

### Visual

- Minimum touch target size (48x48)
- Sufficient color contrast
- Support for text scaling

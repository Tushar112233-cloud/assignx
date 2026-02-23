# Screen/Page Documentation

**Version:** 1.0.0
**Last Updated:** December 28, 2024
**Status:** Production Ready

---

## Table of Contents

1. [Overview](#1-overview)
2. [Splash Screen](#2-splash-screen)
3. [Onboarding Screens](#3-onboarding-screens)
4. [Auth Screens](#4-auth-screens)
5. [Activation Screens](#5-activation-screens)
6. [Dashboard Screens](#6-dashboard-screens)
7. [Profile Screens](#7-profile-screens)
8. [Resources Screens](#8-resources-screens)
9. [Workspace Screens](#9-workspace-screens)
10. [Navigation Flow](#10-navigation-flow)

---

## 1. Overview

### 1.1 Screen Organization

Screens are organized by feature module following a feature-first architecture.

```
lib/features/
├── splash/
│   └── splash_screen.dart
├── onboarding/
│   └── screens/
│       ├── onboarding_screen.dart
│       └── profile_setup_screen.dart
├── auth/
│   └── screens/
│       ├── login_screen.dart
│       ├── register_screen.dart
│       └── otp_verification_screen.dart
├── activation/
│   └── screens/
│       ├── activation_gate_screen.dart
│       ├── training_screen.dart
│       ├── quiz_screen.dart
│       └── bank_details_screen.dart
├── dashboard/
│   └── screens/
│       ├── dashboard_screen.dart
│       ├── statistics_screen.dart
│       └── reviews_screen.dart
├── profile/
│   └── screens/
│       ├── profile_screen.dart
│       ├── edit_profile_screen.dart
│       ├── notifications_screen.dart
│       ├── payment_history_screen.dart
│       └── settings_screen.dart
├── resources/
│   └── screens/
│       ├── resources_hub_screen.dart
│       ├── training_center_screen.dart
│       ├── ai_checker_screen.dart
│       └── citation_builder_screen.dart
└── workspace/
    └── screens/
        ├── project_detail_screen.dart
        ├── workspace_screen.dart
        ├── submit_work_screen.dart
        ├── revision_screen.dart
        └── chat_screen.dart
```

### 1.2 Screen Categories Summary

| Feature | Location | Count |
|---------|----------|-------|
| **Splash** | `lib/features/splash/` | 1 |
| **Onboarding** | `lib/features/onboarding/screens/` | 2 |
| **Authentication** | `lib/features/auth/screens/` | 3 |
| **Activation** | `lib/features/activation/screens/` | 4 |
| **Dashboard** | `lib/features/dashboard/screens/` | 3 |
| **Profile** | `lib/features/profile/screens/` | 5 |
| **Resources** | `lib/features/resources/screens/` | 4 |
| **Workspace** | `lib/features/workspace/screens/` | 5 |

**Total: 27 screens**

### 1.3 Screen Pattern

All screens follow a consistent pattern:

```dart
class ExampleScreen extends ConsumerWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleProvider);

    if (state.isLoading) {
      return const LoadingIndicator();
    }

    if (state.error != null) {
      return ErrorState(
        message: state.error!,
        onRetry: () => ref.invalidate(exampleProvider),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Example')),
      body: ExampleContent(data: state.data),
    );
  }
}
```

---

## 2. Splash Screen

**Location:** `lib/features/splash/splash_screen.dart`
**Route:** `/`

### Purpose

Initial loading screen that determines the user's authentication state and routes them appropriately.

### Key Features

- App logo and branding display
- Authentication state check
- Automatic navigation based on user status
- Graceful loading animation

### Navigation Flow

```
Splash Screen
    │
    ├── Not authenticated ──────────> Onboarding/Login
    │
    ├── Authenticated but not onboarded ──> Profile Setup
    │
    ├── Authenticated but not activated ──> Activation Gate
    │
    └── Fully activated ──────────────> Dashboard
```

### State Dependencies

| Provider | Purpose |
|----------|---------|
| `authProvider` | Check authentication state |
| `SupabaseConfig.isAuthenticated` | Session validation |

---

## 3. Onboarding Screens

### 3.1 OnboardingScreen

**Location:** `lib/features/onboarding/screens/onboarding_screen.dart`
**Route:** `/onboarding`

#### Purpose

Introduce new users to the app with feature highlights and navigation to registration.

#### Key Features

- Welcome message and app introduction
- Feature highlights carousel with page indicators
- Swipeable pages with smooth animations
- Skip functionality
- Sign Up / Sign In navigation buttons

#### Navigation Flow

```
Onboarding Screen
    │
    ├── Sign Up ──────> Register Screen
    │
    ├── Sign In ──────> Login Screen
    │
    └── Skip ──────> Login Screen
```

---

### 3.2 ProfileSetupScreen

**Location:** `lib/features/onboarding/screens/profile_setup_screen.dart`
**Route:** `/profile-setup`

#### Purpose

Collect doer profile information after registration in a multi-step form.

#### Key Features

- Multi-step form with progress indicator
- Step navigation (forward/backward)
- Form validation per step
- Experience level selector
- Skill and subject selection with chips
- Primary subject designation

#### Form Steps

| Step | Title | Fields |
|------|-------|--------|
| 1 | Education | Qualification, University Name |
| 2 | Experience | Experience Level (slider), Years of Experience |
| 3 | Skills | Skills (multi-select with ChipSelector) |
| 4 | Subjects | Subjects (multi-select), Primary Subject |

#### Navigation Flow

```
Profile Setup Screen
    │
    ├── Previous Step ──────> Go back in form
    │
    ├── Next Step ──────> Advance in form
    │
    └── Complete Setup ──────> Activation Gate Screen
```

---

## 4. Auth Screens

### 4.1 LoginScreen

**Location:** `lib/features/auth/screens/login_screen.dart`
**Route:** `/login`

#### Purpose

Allow existing users to sign in with email/password or social login.

#### Key Features

- Email and password input with validation
- Password visibility toggle
- Remember me checkbox option
- Forgot password link
- Google sign-in button with OAuth flow
- Navigation to registration
- Loading state during authentication
- Error handling with user-friendly messages

#### Navigation Flow

```
Login Screen
    │
    ├── Successful login ──────> Dashboard or Activation Gate
    │
    ├── Create Account ──────> Register Screen
    │
    ├── Forgot Password ──────> Password Reset Screen
    │
    └── Google Sign In ──────> Dashboard or Activation Gate
```

---

### 4.2 RegisterScreen

**Location:** `lib/features/auth/screens/register_screen.dart`
**Route:** `/register`

#### Purpose

Register new users with email, password, and basic information.

#### Key Features

- Full name input with validation
- Email input with format validation
- Phone number with country code (+91)
- Password with strength indicator
- Confirm password with match validation
- Terms and conditions checkbox
- Form validation before submission
- Loading state during registration

#### Form Fields

| Field | Validation |
|-------|------------|
| Full Name | Required, min 2 characters |
| Email | Required, valid email format |
| Phone | Required, 10 digits |
| Password | Required, min 8 chars, strength check |
| Confirm Password | Required, must match password |
| Terms | Must be accepted |

#### Navigation Flow

```
Register Screen
    │
    ├── Successful registration ──────> OTP Verification Screen
    │
    ├── Already have account ──────> Login Screen
    │
    └── Google Sign Up ──────> Profile Setup
```

---

### 4.3 OTPVerificationScreen

**Location:** `lib/features/auth/screens/otp_verification_screen.dart`
**Route:** `/otp`

#### Purpose

Verify phone number with OTP code sent via SMS.

#### Key Features

- OTP input with auto-focus between fields
- Resend OTP with countdown timer (60 seconds)
- Verification status display
- Error handling for invalid codes
- Auto-submit when all digits entered
- Clear input option

#### Navigation Flow

```
OTP Verification Screen
    │
    ├── Successful verification ──────> Profile Setup Screen
    │
    ├── Resend OTP ──────> Stay on screen, new OTP sent
    │
    └── Back ──────> Register Screen
```

---

## 5. Activation Screens

### 5.1 ActivationGateScreen

**Location:** `lib/features/activation/screens/activation_gate_screen.dart`
**Route:** `/activation`

#### Purpose

Hub screen showing activation progress and guiding users through the 3-step activation process.

#### Key Features

- Activation progress stepper (Training, Quiz, Bank Details)
- Progress percentage display with animated progress bar
- Step status indicators (completed, in-progress, locked)
- Interactive step navigation
- Activation completion celebration animation
- Pending approval message when awaiting verification

#### Activation Steps

| Step | Title | Description | Unlock Condition |
|------|-------|-------------|------------------|
| 1 | Training | Complete training modules | Always available |
| 2 | Quiz | Pass the interview quiz | Training completed |
| 3 | Bank Details | Submit bank account | Quiz passed |

#### Navigation Flow

```
Activation Gate Screen
    │
    ├── Training Step ──────> Training Screen
    │
    ├── Quiz Step ──────> Quiz Screen (after training)
    │
    ├── Bank Details Step ──────> Bank Details Screen (after quiz)
    │
    └── Fully Activated ──────> Dashboard
```

---

### 5.2 TrainingScreen

**Location:** `lib/features/activation/screens/training_screen.dart`
**Route:** `/training`

#### Purpose

Display training modules and track completion progress.

#### Key Features

- List of training modules with type indicators (video, PDF, article)
- Progress tracking per module with percentage
- Duration display for each module
- Completion checkmarks for finished modules
- Overall progress percentage header
- Module content viewer (video player, PDF viewer, article)
- Required vs optional module distinction

#### Navigation Flow

```
Training Screen
    │
    ├── Video Module ──────> Video Player
    │
    ├── PDF Module ──────> PDF Viewer
    │
    ├── Article Module ──────> Article View
    │
    └── All Complete ──────> Return to Activation Gate (Quiz unlocked)
```

---

### 5.3 QuizScreen

**Location:** `lib/features/activation/screens/quiz_screen.dart`
**Route:** `/quiz`

#### Purpose

Conduct the activation quiz to verify understanding of platform rules and processes.

#### Key Features

- Question display with multiple choice options
- Navigation between questions (previous/next)
- Progress indicator showing current question number
- Timer display (optional, configurable)
- Answer selection with visual feedback
- Result display with score breakdown
- Retry option if failed (limited attempts)
- Explanation for correct answers

#### Quiz Flow States

| State | Display |
|-------|---------|
| Not Started | Instructions and start button |
| In Progress | Questions with navigation |
| Submitting | Loading overlay |
| Passed | Success result with continue button |
| Failed | Failure result with retry option |

#### Navigation Flow

```
Quiz Screen
    │
    ├── Quiz Passed ──────> Return to Activation Gate (Bank unlocked)
    │
    ├── Quiz Failed ──────> Retry Quiz or Return to Training
    │
    └── Exit (during quiz) ──────> Confirm exit dialog
```

---

### 5.4 BankDetailsScreen

**Location:** `lib/features/activation/screens/bank_details_screen.dart`
**Route:** `/bank-details`

#### Purpose

Collect bank account information for payment processing.

#### Key Features

- Account holder name input
- Account number with confirmation field
- IFSC code input with format validation (11 characters)
- Bank name auto-lookup based on IFSC
- Branch name display
- UPI ID input (optional alternative)
- Form validation with real-time feedback
- Secure data handling indication
- Bank verification status badge

#### Form Fields

| Field | Validation | Required |
|-------|------------|----------|
| Account Holder Name | Match with profile name | Yes |
| Account Number | 9-18 digits | Yes |
| Confirm Account Number | Must match | Yes |
| IFSC Code | 11 alphanumeric, format check | Yes |
| Bank Name | Auto-populated | Display only |
| UPI ID | Valid UPI format | No |

#### Navigation Flow

```
Bank Details Screen
    │
    ├── Submit Success ──────> Activation Complete - Dashboard
    │
    ├── Verification Pending ──────> Return to Activation Gate
    │
    └── Back ──────> Return to Activation Gate
```

---

## 6. Dashboard Screens

### 6.1 DashboardScreen

**Location:** `lib/features/dashboard/screens/dashboard_screen.dart`
**Route:** `/dashboard`

#### Purpose

Main home screen showing projects, stats, and quick actions.

#### Key Features

- User greeting with time-based message (Good morning/afternoon/evening)
- Profile avatar with notification badge
- Availability toggle switch
- Stats cards grid (active projects, completed, earnings, rating)
- Active/assigned projects list with status
- Available projects section (if capacity available)
- Pull-to-refresh functionality
- Navigation drawer with menu items
- Bottom navigation (Dashboard, Resources, Profile)

#### Dashboard Sections

| Section | Content |
|---------|---------|
| Header | Greeting, avatar, notifications |
| Stats Grid | 4 stat cards with key metrics |
| Active Projects | List of in-progress projects |
| Available Tasks | Open tasks for acceptance (if capacity) |
| Quick Actions | Training, AI Checker shortcuts |

#### Navigation Flow

```
Dashboard Screen
    │
    ├── Project Card ──────> Project Detail Screen
    │
    ├── Stats Card ──────> Statistics Screen
    │
    ├── Notification Icon ──────> Notifications Screen
    │
    ├── Avatar ──────> Profile Screen
    │
    ├── Drawer Menu ──────> Various screens
    │
    └── Bottom Nav ──────> Resources / Profile
```

---

### 6.2 StatisticsScreen

**Location:** `lib/features/dashboard/screens/statistics_screen.dart`
**Route:** `/statistics`

#### Purpose

Detailed view of performance metrics and earnings over time.

#### Key Features

- Earnings chart with time period selector (week/month/year)
- Performance metrics grid
- Project completion statistics
- Rating breakdown with star distribution
- On-time delivery rate percentage
- Success rate trends
- Comparison with previous period

#### Metrics Displayed

| Metric | Description |
|--------|-------------|
| Total Earnings | Sum for selected period |
| Projects Completed | Count for period |
| Average Rating | Star rating with review count |
| On-Time Rate | Percentage delivered before deadline |
| Success Rate | Completed without revision |
| Trend Indicators | Up/down arrows vs previous period |

#### Navigation Flow

```
Statistics Screen
    │
    ├── Earnings Section ──────> Payment History
    │
    ├── Rating Section ──────> Reviews Screen
    │
    └── Back ──────> Dashboard
```

---

### 6.3 ReviewsScreen

**Location:** `lib/features/dashboard/screens/reviews_screen.dart`
**Route:** `/reviews`

#### Purpose

Display all reviews received from supervisors.

#### Key Features

- Review list sorted by date (newest first)
- Filter by rating (all, 5-star, 4-star, etc.)
- Sort options (date, rating)
- Review card with rating stars
- Supervisor name and project reference
- Review text expansion for long reviews
- Average rating summary at top
- Empty state for no reviews

#### Review Card Content

| Element | Description |
|---------|-------------|
| Rating | 1-5 stars with visual display |
| Supervisor | Name of reviewer |
| Project | Linked project title |
| Date | Review submission date |
| Comment | Review text (expandable) |

#### Navigation Flow

```
Reviews Screen
    │
    ├── Review Card ──────> Expand/collapse review text
    │
    ├── Project Link ──────> Project Detail Screen
    │
    └── Back ──────> Dashboard/Profile
```

---

## 7. Profile Screens

### 7.1 ProfileScreen

**Location:** `lib/features/profile/screens/profile_screen.dart`
**Route:** `/profile`

#### Purpose

Display user profile information and navigation to settings.

#### Key Features

- Profile header with large avatar
- Personal information section
- Skills and subjects display with badges
- Bank details summary (masked)
- Stats scorecard (earnings, projects, rating)
- Quick action buttons (edit, settings)
- Logout option

#### Profile Sections

| Section | Content |
|---------|---------|
| Header | Avatar, name, email, verification badge |
| Personal Info | Phone, location, qualification |
| Skills | List of selected skills |
| Subjects | Primary and secondary subjects |
| Stats | Scorecard grid |
| Bank Details | Masked account info, verification status |
| Actions | Edit, Settings, Logout |

#### Navigation Flow

```
Profile Screen
    │
    ├── Edit Button ──────> Edit Profile Screen
    │
    ├── Settings ──────> Settings Screen
    │
    ├── Payment History ──────> Payment History Screen
    │
    ├── Notifications ──────> Notifications Screen
    │
    └── Logout ──────> Confirm - Login Screen
```

---

### 7.2 EditProfileScreen

**Location:** `lib/features/profile/screens/edit_profile_screen.dart`
**Route:** `/profile/edit`

#### Purpose

Edit personal and professional information.

#### Key Features

- Avatar upload with camera/gallery picker
- Personal info editing (name, phone, city, state)
- Bio/description editing with character limit
- Skills modification with ChipSelector
- Subjects modification
- Qualification and experience update
- Save confirmation dialog
- Unsaved changes warning on back

#### Editable Fields

| Field | Type |
|-------|------|
| Avatar | Image upload |
| Full Name | Text input |
| Phone | Phone input with validation |
| City | Text input |
| State | Dropdown/Text |
| Bio | Multi-line text (500 chars max) |
| Qualification | Dropdown selection |
| Skills | Multi-select chips |
| Subjects | Multi-select chips |

#### Navigation Flow

```
Edit Profile Screen
    │
    ├── Save ──────> Return to Profile Screen
    │
    ├── Cancel (unsaved changes) ──────> Confirm discard dialog
    │
    └── Cancel (no changes) ──────> Return to Profile Screen
```

---

### 7.3 NotificationsScreen

**Location:** `lib/features/profile/screens/notifications_screen.dart`
**Route:** `/notifications`

#### Purpose

Display in-app notifications and alerts.

#### Key Features

- Notification list grouped by date
- Read/unread status with visual distinction
- Notification types (project, payment, system)
- Tap to mark as read and navigate
- Swipe to delete
- Mark all as read action
- Clear all option
- Empty state when no notifications

#### Notification Types

| Type | Icon | Action |
|------|------|--------|
| New Project | Assignment | Open project |
| Payment | Currency | Open payment history |
| Revision | Edit | Open revision screen |
| Message | Chat | Open chat |
| System | Info | Expand details |

#### Navigation Flow

```
Notifications Screen
    │
    ├── Project notification ──────> Project Detail
    │
    ├── Payment notification ──────> Payment History
    │
    ├── Message notification ──────> Chat Screen
    │
    └── Back ──────> Previous screen
```

---

### 7.4 PaymentHistoryScreen

**Location:** `lib/features/profile/screens/payment_history_screen.dart`
**Route:** `/payments`

#### Purpose

Display payment transaction history and earnings.

#### Key Features

- Transaction list with amount and status
- Filter by status (all, pending, completed, failed)
- Date range filter (this month, last month, custom)
- Total earnings display
- Transaction details on tap
- Export to CSV option
- Pagination for large lists
- Empty state for new users

#### Transaction Card Content

| Field | Description |
|-------|-------------|
| Amount | Payment amount in INR |
| Status | Pending/Completed/Failed badge |
| Project | Associated project name |
| Date | Transaction date |
| Reference | Transaction ID |

#### Navigation Flow

```
Payment History Screen
    │
    ├── Transaction Card ──────> Transaction Details Modal
    │
    ├── Project Link ──────> Project Detail Screen
    │
    └── Back ──────> Profile Screen
```

---

### 7.5 SettingsScreen

**Location:** `lib/features/profile/screens/settings_screen.dart`
**Route:** `/settings`

#### Purpose

App settings and account management.

#### Key Features

- Notification settings (push, email, SMS)
- Theme preference (light/dark/system)
- Language selection
- Bank details management link
- Privacy settings
- Help and support (FAQ, contact)
- App version and about
- Logout option
- Account deletion (with confirmation)

#### Settings Sections

| Section | Options |
|---------|---------|
| Notifications | Push, Email, SMS toggles |
| Appearance | Theme selection |
| Language | Language dropdown |
| Account | Bank details, Privacy |
| Support | Help, FAQ, Contact |
| About | Version, Terms, Privacy Policy |
| Actions | Logout, Delete Account |

#### Navigation Flow

```
Settings Screen
    │
    ├── Bank Details ──────> Bank Details Screen
    │
    ├── Help ──────> Help/FAQ Screen
    │
    ├── Logout ──────> Confirm - Login Screen
    │
    ├── Delete Account ──────> Confirm - Account deleted - Login
    │
    └── Back ──────> Profile Screen
```

---

## 8. Resources Screens

### 8.1 ResourcesHubScreen

**Location:** `lib/features/resources/screens/resources_hub_screen.dart`
**Route:** `/resources`

#### Purpose

Central hub for all resources and tools available to doers.

#### Key Features

- Resource categories grid with icons
- Quick access cards for popular tools
- Training center shortcut
- AI checker shortcut
- Citation builder shortcut
- Featured/new resources section
- Search functionality
- Recent resources accessed

#### Resource Categories

| Category | Description | Route |
|----------|-------------|-------|
| Training Center | Additional learning modules | `/resources/training` |
| AI Checker | AI content detection tool | `/resources/ai-checker` |
| Citation Builder | Citation generation tool | `/resources/citations` |
| Style Guides | Writing style references | Link/PDF |
| FAQ | Frequently asked questions | Link/Modal |

#### Navigation Flow

```
Resources Hub Screen
    │
    ├── Training Center ──────> Training Center Screen
    │
    ├── AI Checker ──────> AI Checker Screen
    │
    ├── Citation Builder ──────> Citation Builder Screen
    │
    └── Bottom Nav ──────> Dashboard / Profile
```

---

### 8.2 TrainingCenterScreen

**Location:** `lib/features/resources/screens/training_center_screen.dart`
**Route:** `/resources/training`

#### Purpose

Access to additional training materials beyond activation requirements.

#### Key Features

- Training category tabs (Writing, Research, Tools, etc.)
- Course list with progress indicators
- Completion status per module
- Certificate display for completed courses
- Video player integration
- PDF viewer integration
- Bookmark/save for later
- Search within training content

#### Course Card Content

| Field | Description |
|-------|-------------|
| Title | Course name |
| Category | Category badge |
| Duration | Total time |
| Progress | Percentage completed |
| Modules | Number of modules |

#### Navigation Flow

```
Training Center Screen
    │
    ├── Course Card ──────> Course Content/Module List
    │
    ├── Module ──────> Video/PDF/Article Viewer
    │
    └── Back ──────> Resources Hub
```

---

### 8.3 AICheckerScreen

**Location:** `lib/features/resources/screens/ai_checker_screen.dart`
**Route:** `/resources/ai-checker`

#### Purpose

Check content for AI-generated text detection before submission.

#### Key Features

- Large text input area
- File upload option (DOCX, PDF)
- Character/word count display
- Analysis button
- AI detection score with percentage
- Detailed report with highlighted sections
- Tips for improvement
- Check history (recent checks)

#### Analysis Results

| Element | Description |
|---------|-------------|
| AI Score | Percentage likely AI-generated |
| Human Score | Percentage likely human-written |
| Highlighted Text | Sections flagged as AI |
| Recommendations | Tips to improve originality |
| Confidence Level | Analysis confidence rating |

#### Navigation Flow

```
AI Checker Screen
    │
    ├── Check Content ──────> Analysis Results
    │
    ├── View History ──────> Previous Checks List
    │
    └── Back ──────> Resources Hub
```

---

### 8.4 CitationBuilderScreen

**Location:** `lib/features/resources/screens/citation_builder_screen.dart`
**Route:** `/resources/citations`

#### Purpose

Generate properly formatted citations in various academic styles.

#### Key Features

- Citation style selection (APA, MLA, Chicago, Harvard, IEEE)
- Source type selection (book, journal, website, etc.)
- Dynamic form fields based on source type
- Generated citation preview
- Copy to clipboard button
- Save citations to library
- Multiple citations management
- Export as formatted list

#### Supported Source Types

| Type | Fields |
|------|--------|
| Book | Authors, Title, Publisher, Year, Edition |
| Journal Article | Authors, Title, Journal, Volume, Issue, Pages, Year |
| Website | Authors, Title, URL, Access Date, Publisher |
| Conference Paper | Authors, Title, Conference, Location, Year |

#### Navigation Flow

```
Citation Builder Screen
    │
    ├── Generate ──────> Citation Output Preview
    │
    ├── Save ──────> Add to My Citations
    │
    ├── My Citations ──────> Saved Citations List
    │
    └── Back ──────> Resources Hub
```

---

## 9. Workspace Screens

### 9.1 ProjectDetailScreen

**Location:** `lib/features/workspace/screens/project_detail_screen.dart`
**Route:** `/project/:id`

#### Purpose

Display full project details and available actions.

#### Key Features

- Project header with status badge
- Deadline countdown timer
- Requirements checklist (read-only)
- Project description with formatting
- Supervisor info with contact option
- Price and word count display
- Reference style indicator
- Action buttons based on status
- Revision notes display (if applicable)

#### Project States and Actions

| Status | Available Actions |
|--------|-------------------|
| Open | Accept Task |
| Assigned | Start Working |
| In Progress | Continue Working, Chat |
| Submitted | View Submission, Chat |
| Revision Requested | Handle Revision, Chat |
| Completed | View Details |

#### Navigation Flow

```
Project Detail Screen
    │
    ├── Accept Task ──────> Project assigned, stay on screen
    │
    ├── Start/Continue Working ──────> Workspace Screen
    │
    ├── Handle Revision ──────> Revision Screen
    │
    ├── Chat ──────> Chat Screen
    │
    └── Back ──────> Dashboard
```

---

### 9.2 WorkspaceScreen

**Location:** `lib/features/workspace/screens/workspace_screen.dart`
**Route:** `/workspace/:id`

#### Purpose

Active workspace for working on assigned project.

#### Key Features

- Collapsible project info card
- Interactive requirements checklist
- File upload area with drag support
- Uploaded files list with actions
- Set primary file option
- Progress tracker
- Notes/comments input section
- Auto-save indicator
- Submit work button

#### Workspace Sections

| Section | Functionality |
|---------|---------------|
| Project Info | Collapsed card with key details |
| Requirements | Checkable list with progress |
| Files | Upload area and file list |
| Notes | Personal notes for work |
| Actions | Save, Submit buttons |

#### Navigation Flow

```
Workspace Screen
    │
    ├── Submit Work ──────> Submit Work Screen
    │
    ├── View Project Details ──────> Project Detail Screen
    │
    ├── Chat ──────> Chat Screen
    │
    └── Back ──────> Dashboard (with unsaved warning)
```

---

### 9.3 SubmitWorkScreen

**Location:** `lib/features/workspace/screens/submit_work_screen.dart`
**Route:** `/submit/:id`

#### Purpose

Final submission of completed work for review.

#### Key Features

- File list verification
- Primary file selection/confirmation
- Submission notes input
- Requirements completion confirmation
- Preview before submit
- Submit confirmation dialog
- Success animation
- Warning for missing items

#### Submission Checklist

| Item | Required |
|------|----------|
| At least one file uploaded | Yes |
| Primary file designated | Yes |
| All requirements checked | Recommended |
| Submission notes | Optional |

#### Navigation Flow

```
Submit Work Screen
    │
    ├── Submit ──────> Confirmation Dialog - Success - Dashboard
    │
    ├── Back ──────> Workspace Screen
    │
    └── Edit Files ──────> Return to Workspace
```

---

### 9.4 RevisionScreen

**Location:** `lib/features/workspace/screens/revision_screen.dart`
**Route:** `/revision/:id`

#### Purpose

Handle revision requests for submitted work.

#### Key Features

- Revision notes display prominently
- Original submission view
- Changed requirements highlight
- Re-upload area for new files
- Keep existing files option
- Revision notes input
- Resubmit action
- Chat shortcut for clarification

#### Revision Workflow

| Step | Action |
|------|--------|
| 1 | Review revision notes |
| 2 | Review original submission |
| 3 | Upload revised files |
| 4 | Add response notes |
| 5 | Resubmit |

#### Navigation Flow

```
Revision Screen
    │
    ├── Resubmit ──────> Confirmation - Project Detail
    │
    ├── Chat ──────> Chat Screen
    │
    ├── View Original ──────> Original Submission Modal
    │
    └── Back ──────> Project Detail Screen
```

---

### 9.5 ChatScreen

**Location:** `lib/features/workspace/screens/chat_screen.dart`
**Route:** `/chat/:id`

#### Purpose

Real-time communication with supervisor about project.

#### Key Features

- Message list with timestamps
- Text input with send button
- File attachment support
- Message status indicators (sent, delivered, read)
- Typing indicator
- Real-time updates via Supabase
- Image preview in chat
- Scroll to bottom button
- Load older messages on scroll

#### Message Types

| Type | Display |
|------|---------|
| Text | Message bubble |
| File | File card with download |
| Image | Thumbnail with full view |
| System | Centered italic text |

#### Navigation Flow

```
Chat Screen
    │
    ├── Send Message ──────> Message added to list
    │
    ├── Attachment ──────> File picker - Upload - Send
    │
    └── Back ──────> Previous screen
```

---

## 10. Navigation Flow

### 10.1 Complete App Flow Diagram

```
                                    ┌─────────────────────┐
                                    │    Splash Screen    │
                                    └──────────┬──────────┘
                                               │
                         ┌─────────────────────┼─────────────────────┐
                         │                     │                     │
                         ▼                     ▼                     ▼
              ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
              │    Onboarding    │  │  Activation Gate │  │     Dashboard    │
              └────────┬─────────┘  └────────┬─────────┘  └────────┬─────────┘
                       │                     │                     │
          ┌────────────┴────────────┐        │            ┌────────┴────────┐
          │                         │        │            │                 │
          ▼                         ▼        │            ▼                 ▼
   ┌─────────────┐           ┌───────────┐   │     ┌───────────┐     ┌───────────┐
   │   Register  │           │   Login   │   │     │  Projects │     │  Profile  │
   └──────┬──────┘           └─────┬─────┘   │     └─────┬─────┘     └─────┬─────┘
          │                        │         │           │                 │
          ▼                        │         │           ▼                 ▼
   ┌─────────────┐                 │         │     ┌───────────┐     ┌───────────┐
   │  OTP Verify │                 │         │     │ Workspace │     │ Settings  │
   └──────┬──────┘                 │         │     └───────────┘     └───────────┘
          │                        │         │
          ▼                        │         │
   ┌─────────────┐                 │         │
   │Profile Setup│─────────────────┼────────►│
   └─────────────┘                 │         │
                                   │         │
                    ┌──────────────┘         │
                    │                        │
                    ▼                        │
          ┌─────────┴─────────┬──────────────┘
          │                   │
          ▼                   ▼
   ┌─────────────┐     ┌───────────┐     ┌───────────┐
   │  Training   │────►│   Quiz    │────►│   Bank    │
   └─────────────┘     └───────────┘     │  Details  │
                                         └─────┬─────┘
                                               │
                                               ▼
                                        ┌───────────┐
                                        │ Dashboard │
                                        └───────────┘
```

### 10.2 Route Configuration

**Location:** `lib/core/router/route_names.dart`

| Route | Path | Auth Required | Description |
|-------|------|---------------|-------------|
| `splash` | `/` | No | Initial splash screen |
| `onboarding` | `/onboarding` | No | App introduction |
| `login` | `/login` | No | Login screen |
| `register` | `/register` | No | Registration screen |
| `otpVerification` | `/otp` | No | OTP verification |
| `profileSetup` | `/profile-setup` | Yes | Profile setup |
| `activationGate` | `/activation` | Yes | Activation hub |
| `training` | `/activation/training` | Yes | Training modules |
| `quiz` | `/activation/quiz` | Yes | Activation quiz |
| `bankDetails` | `/activation/bank` | Yes | Bank details |
| `dashboard` | `/dashboard` | Yes | Main dashboard |
| `statistics` | `/statistics` | Yes | Statistics view |
| `reviews` | `/reviews` | Yes | Reviews list |
| `profile` | `/profile` | Yes | User profile |
| `editProfile` | `/profile/edit` | Yes | Edit profile |
| `notifications` | `/notifications` | Yes | Notifications |
| `paymentHistory` | `/payments` | Yes | Payment history |
| `settings` | `/settings` | Yes | App settings |
| `resources` | `/resources` | Yes | Resources hub |
| `trainingCenter` | `/resources/training` | Yes | Training center |
| `aiChecker` | `/resources/ai-checker` | Yes | AI checker |
| `citationBuilder` | `/resources/citations` | Yes | Citation builder |
| `projectDetail` | `/project/:id` | Yes | Project details |
| `workspace` | `/workspace/:id` | Yes | Project workspace |
| `submitWork` | `/submit/:id` | Yes | Submit work |
| `revision` | `/revision/:id` | Yes | Revision handling |
| `chat` | `/chat/:id` | Yes | Project chat |

---

## Appendix

### A. Screen Dependencies

| Screen | Provider | Repository |
|--------|----------|------------|
| Splash | `authProvider` | `AuthRepository` |
| Login/Register | `authProvider` | `AuthRepository` |
| Dashboard | `dashboardProvider` | DashboardRepository |
| Profile | `authProvider`, `profileProvider` | `AuthRepository` |
| Activation | `activationProvider` | ActivationRepository |
| Workspace | `workspaceProvider` | WorkspaceRepository |
| Resources | `resourcesProvider` | ResourcesRepository |

### B. Screen Best Practices

```dart
// 1. Use ConsumerWidget for state access
class ExampleScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exampleProvider);
    // ...
  }
}

// 2. Handle loading states
if (state.isLoading) {
  return const LoadingOverlay(isLoading: true, child: SizedBox());
}

// 3. Handle error states
if (state.hasError) {
  return ErrorDisplay(
    message: state.errorMessage!,
    onRetry: () => ref.invalidate(exampleProvider),
  );
}

// 4. Use go_router for navigation
context.go('/dashboard');
context.push('/project/$projectId');
context.pop();
```

### C. Related Documents

- [Components](./COMPONENTS.md) - Widget documentation
- [API](./API.md) - Data layer documentation
- [Architecture](./ARCHITECTURE.md) - System overview

---

*Document maintained by Development Team*
*Last reviewed: December 28, 2024*

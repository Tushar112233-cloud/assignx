# API and Data Layer Documentation

**Version:** 1.0.0
**Last Updated:** December 28, 2024
**Status:** Production Ready

---

## Table of Contents

1. [Overview](#1-overview)
2. [Data Models](#2-data-models)
3. [Repositories](#3-repositories)
4. [Supabase Integration](#4-supabase-integration)
5. [Mock Data](#5-mock-data)
6. [Error Handling](#6-error-handling)

---

## 1. Overview

### 1.1 Data Architecture

The DOER App follows a layered data architecture that separates concerns between data sources, repositories, and state management.

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│                    (Screens & Widgets)                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   State Management Layer                     │
│                    (Riverpod Providers)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Repository Layer                         │
│              (AuthRepository, etc.)                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Sources                           │
│              ┌─────────────┐    ┌─────────────┐             │
│              │  Supabase   │    │  Mock Data  │             │
│              │   (Remote)  │    │   (Local)   │             │
│              └─────────────┘    └─────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Directory Structure

```
lib/data/
├── models/                    # Domain models
│   ├── models.dart           # Barrel file
│   ├── user_model.dart       # Combined user model
│   ├── profile_model.dart    # Base profile model
│   ├── doer_model.dart       # Doer-specific data
│   ├── project_model.dart    # Project/task model
│   ├── activation_model.dart # Activation flow models
│   ├── bank_details_model.dart
│   ├── quiz_model.dart
│   └── training_model.dart
│
├── repositories/              # Data access layer
│   ├── repositories.dart     # Barrel file
│   └── auth_repository.dart  # Authentication repository
│
└── mock/                      # Development mock data
    ├── mock_data.dart        # Barrel file
    ├── mock_activation_data.dart
    ├── mock_dashboard_data.dart
    ├── mock_profile_data.dart
    └── mock_resources_data.dart
```

---

## 2. Data Models

### 2.1 UserModel

Combined model representing a DOER user with both profile and doer-specific data.

**Location:** `lib/data/models/user_model.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | UUID from Supabase Auth (primary key) |
| `email` | `String` | User's email address (unique) |
| `fullName` | `String` | Display name |
| `phone` | `String?` | Phone number with country code (+919876543210) |
| `phoneVerified` | `bool` | OTP verification status |
| `avatarUrl` | `String?` | Profile image URL |
| `userType` | `String` | Account type: 'doer', 'student', 'supervisor', 'admin' |
| `isActive` | `bool` | Account active status |
| `city` | `String?` | City of residence |
| `state` | `String?` | State/province |
| `country` | `String` | Country (default: 'India') |
| `onboardingStep` | `String` | Current onboarding step |
| `onboardingCompleted` | `bool` | Onboarding completion status |
| `referralCode` | `String?` | Unique referral code |
| `createdAt` | `DateTime` | Account creation timestamp |
| `updatedAt` | `DateTime?` | Last update timestamp |
| `doerId` | `String?` | Doer record ID (if exists) |
| `qualification` | `String?` | Highest educational qualification |
| `universityName` | `String?` | Institution attended |
| `experienceLevel` | `String` | 'beginner', 'intermediate', 'expert' |
| `yearsOfExperience` | `int` | Years of experience |
| `bio` | `String?` | Self-introduction |
| `isAvailable` | `bool` | Available for new projects |
| `isActivated` | `bool` | Activation completion status |
| `activatedAt` | `DateTime?` | Activation timestamp |
| `totalProjectsCompleted` | `int` | Completed project count |
| `totalEarnings` | `double` | Total earnings in INR |
| `averageRating` | `double` | Average review rating (0-5) |
| `totalReviews` | `int` | Total review count |
| `bankAccountName` | `String?` | Bank account holder name |
| `bankAccountNumber` | `String?` | Bank account number |
| `bankIfscCode` | `String?` | IFSC code |
| `bankName` | `String?` | Bank name |
| `upiId` | `String?` | UPI ID |
| `bankVerified` | `bool` | Bank verification status |
| `skills` | `List<SkillModel>` | User's skills |
| `subjects` | `List<SubjectModel>` | User's subjects |

**Computed Properties:**

```dart
bool get hasDoerProfile => doerId != null;
bool get hasBankDetails => bankAccountName != null && bankAccountNumber != null && bankIfscCode != null;
List<String> get skillNames => skills.map((s) => s.name).toList();
List<String> get subjectNames => subjects.map((s) => s.name).toList();
```

**Factory Constructors:**

```dart
// From database JSON
UserModel.fromJson(Map<String, dynamic> json)

// From separate models
UserModel.fromModels({
  required ProfileModel profile,
  DoerModel? doer,
  List<SkillModel>? skills,
  List<SubjectModel>? subjects,
})
```

---

### 2.2 DoerModel

Doer-specific data from the `doers` table.

**Location:** `lib/data/models/doer_model.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Doer record UUID |
| `profileId` | `String` | Reference to profiles table |
| `qualification` | `String` | Educational qualification |
| `universityName` | `String?` | Institution name |
| `experienceLevel` | `String` | Experience level |
| `yearsOfExperience` | `int` | Years of experience |
| `bio` | `String?` | User biography |
| `isAvailable` | `bool` | Availability status |
| `availabilityUpdatedAt` | `DateTime?` | Last availability change |
| `maxConcurrentProjects` | `int` | Max projects allowed (default: 3) |
| `isActivated` | `bool` | Activation status |
| `activatedAt` | `DateTime?` | Activation timestamp |
| `totalProjectsCompleted` | `int` | Completed projects |
| `totalEarnings` | `double` | Total earnings |
| `averageRating` | `double` | Average rating |
| `totalReviews` | `int` | Review count |
| `successRate` | `double` | Success rate percentage |
| `onTimeDeliveryRate` | `double` | On-time delivery percentage |
| `bankAccountName` | `String?` | Bank details |
| `bankAccountNumber` | `String?` | Bank details |
| `bankIfscCode` | `String?` | Bank details |
| `bankName` | `String?` | Bank details |
| `upiId` | `String?` | UPI ID |
| `bankVerified` | `bool` | Bank verification status |
| `isFlagged` | `bool` | Flag status |
| `flagReason` | `String?` | Reason for flagging |
| `flaggedBy` | `String?` | Admin who flagged |
| `flaggedAt` | `DateTime?` | Flag timestamp |
| `createdAt` | `DateTime` | Creation timestamp |
| `updatedAt` | `DateTime?` | Update timestamp |

**Helper Models:**

```dart
// Skill model
class SkillModel {
  final String id;
  final String name;
  final String slug;
  final String? category;
  final String? subjectId;
  final bool isActive;
}

// Subject model
class SubjectModel {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? icon;
  final String? parentId;
  final String? category;
  final int? displayOrder;
  final bool isActive;
}
```

---

### 2.3 ProjectModel

Project/task data model.

**Location:** `lib/data/models/project_model.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Project UUID |
| `title` | `String` | Project title |
| `description` | `String?` | Detailed description |
| `subject` | `String` | Academic subject |
| `status` | `ProjectStatus` | Current status |
| `urgency` | `ProjectUrgency` | Urgency level |
| `price` | `double` | Payment amount in INR |
| `deadline` | `DateTime` | Due date/time |
| `createdAt` | `DateTime` | Creation timestamp |
| `acceptedAt` | `DateTime?` | When doer accepted |
| `submittedAt` | `DateTime?` | Submission timestamp |
| `completedAt` | `DateTime?` | Completion timestamp |
| `supervisorId` | `String?` | Assigned supervisor |
| `supervisorName` | `String?` | Supervisor display name |
| `doerId` | `String?` | Assigned doer |
| `wordCount` | `int?` | Required word count |
| `referenceStyle` | `String?` | Citation style (APA, MLA, etc.) |
| `requirements` | `List<String>` | Project requirements |
| `hasRevision` | `bool` | Revision requested flag |
| `revisionNote` | `String?` | Revision details |

**Enums:**

```dart
enum ProjectStatus {
  open('open'),
  assigned('assigned'),
  inProgress('in_progress'),
  submitted('submitted'),
  underReview('under_review'),
  revisionRequested('revision_requested'),
  completed('completed'),
  paid('paid'),
  cancelled('cancelled');
}

enum ProjectUrgency {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');
}
```

**Computed Properties:**

```dart
bool get isUrgent => timeRemaining.inHours < 6 && !isOverdue;
Duration get timeRemaining => deadline.difference(DateTime.now());
bool get isOverdue => DateTime.now().isAfter(deadline);
String get formattedPrice => 'Rs${price.toStringAsFixed(0)}';
```

---

### 2.4 ActivationModel

Activation flow tracking models.

**Location:** `lib/data/models/activation_model.dart`

#### ActivationStatus

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Record UUID |
| `doerId` | `String` | Reference to doer |
| `trainingCompleted` | `bool` | Training step status |
| `trainingCompletedAt` | `DateTime?` | Training completion time |
| `quizPassed` | `bool` | Quiz step status |
| `quizPassedAt` | `DateTime?` | Quiz pass time |
| `quizAttemptId` | `String?` | Last quiz attempt ID |
| `totalQuizAttempts` | `int` | Number of attempts |
| `bankDetailsAdded` | `bool` | Bank details status |
| `bankDetailsAddedAt` | `DateTime?` | Bank submission time |
| `isFullyActivated` | `bool` | Full activation status |
| `activatedAt` | `DateTime?` | Full activation time |

**Computed Properties:**

```dart
int get completedSteps // 0-3
int get totalSteps => 3
double get completionPercentage => (completedSteps / totalSteps) * 100
int get currentStep // 1-indexed current step
```

#### ActivationStep Enum

```dart
enum ActivationStep {
  training(1, 'Training', 'Complete training modules'),
  quiz(2, 'Quiz', 'Pass the interview quiz'),
  bankDetails(3, 'Bank Details', 'Submit bank account details');
}
```

---

### 2.5 BankDetails

Bank account information model.

**Location:** `lib/data/models/bank_details_model.dart`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Record UUID |
| `doerId` | `String` | Reference to doer |
| `accountHolderName` | `String` | Account holder name |
| `accountNumber` | `String` | Bank account number |
| `ifscCode` | `String` | IFSC code (11 chars) |
| `bankName` | `String?` | Bank name |
| `branchName` | `String?` | Branch name |
| `upiId` | `String?` | UPI ID |
| `isVerified` | `bool` | Verification status |

**Masking Methods:**

```dart
String get maskedAccountNumber // ****1234
String get maskedIfsc // SBIN****234
String? get maskedUpi // jo***@upi
```

---

### 2.6 QuizModel

Quiz question and attempt models.

**Location:** `lib/data/models/quiz_model.dart`

#### QuizQuestion

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Question UUID |
| `question` | `String` | Question text |
| `options` | `List<QuizOption>` | Answer options |
| `correctOptionIndex` | `int` | Index of correct answer |
| `explanation` | `String?` | Answer explanation |
| `orderIndex` | `int` | Display order |

#### QuizAttempt

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Attempt UUID |
| `doerId` | `String` | Reference to doer |
| `score` | `int` | Correct answers |
| `totalQuestions` | `int` | Total questions |
| `passed` | `bool` | Pass/fail status |
| `attemptNumber` | `int` | Attempt number |
| `answers` | `List<QuizAnswer>` | Individual answers |
| `attemptedAt` | `DateTime` | Attempt timestamp |

---

### 2.7 TrainingModule

Training content models.

**Location:** `lib/data/models/training_model.dart`

#### TrainingModule

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Module UUID |
| `title` | `String` | Module title |
| `description` | `String` | Module description |
| `type` | `TrainingModuleType` | Content type |
| `contentUrl` | `String` | URL to content |
| `durationMinutes` | `int` | Estimated duration |
| `orderIndex` | `int` | Display order |
| `isRequired` | `bool` | Required completion |

```dart
enum TrainingModuleType {
  video('video'),
  pdf('pdf'),
  article('article');
}
```

#### TrainingProgress

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Progress UUID |
| `doerId` | `String` | Reference to doer |
| `moduleId` | `String` | Reference to module |
| `isCompleted` | `bool` | Completion status |
| `progressPercent` | `int` | Progress percentage (0-100) |
| `completedAt` | `DateTime?` | Completion timestamp |
| `startedAt` | `DateTime` | Start timestamp |

---

## 3. Repositories

### 3.1 AuthRepository

Abstract interface and Supabase implementation for authentication.

**Location:** `lib/data/repositories/auth_repository.dart`

#### Interface Methods

| Method | Parameters | Returns | Description |
|--------|------------|---------|-------------|
| `currentSession` | - | `Session?` | Get current session |
| `currentUser` | - | `User?` | Get current user |
| `signUp` | email, password, fullName, phone | `Future<AuthResponse>` | Register new user |
| `signInWithPassword` | email, password | `Future<AuthResponse>` | Login with credentials |
| `signOut` | - | `Future<void>` | Sign out current user |
| `sendOtp` | phone | `Future<void>` | Send OTP to phone |
| `verifyOtp` | phone, otp | `Future<AuthResponse>` | Verify OTP code |
| `fetchUserProfile` | userId | `Future<UserModel?>` | Get user profile |
| `createProfile` | userId, email, fullName, phone | `Future<void>` | Create initial profile |
| `createDoerProfile` | profileId, data | `Future<String>` | Create doer record |
| `updateDoerProfile` | doerId, data | `Future<void>` | Update doer record |
| `addDoerSkills` | doerId, skillIds | `Future<void>` | Add skills to doer |
| `addDoerSubjects` | doerId, subjectIds, primaryId | `Future<void>` | Add subjects to doer |
| `updateBankDetails` | doerId, data | `Future<void>` | Update bank details |
| `signInWithGoogle` | - | `Future<bool>` | Google OAuth sign-in |
| `getAvailableSkills` | - | `Future<List<SkillModel>>` | Fetch all skills |
| `getAvailableSubjects` | - | `Future<List<SubjectModel>>` | Fetch all subjects |

#### Usage Example

```dart
final authRepo = SupabaseAuthRepository();

// Sign up new user
final response = await authRepo.signUp(
  email: 'user@example.com',
  password: 'securePassword123',
  fullName: 'John Doe',
  phone: '9876543210',
);

// Fetch user profile
final user = await authRepo.fetchUserProfile(response.user!.id);

// Create doer profile
final doerId = await authRepo.createDoerProfile(
  profileId: user!.id,
  data: ProfileSetupData(
    qualification: 'B.Tech',
    experienceLevel: 'intermediate',
    yearsOfExperience: 2,
  ),
);
```

---

## 4. Supabase Integration

### 4.1 Configuration

**Location:** `lib/core/config/supabase_config.dart`

#### Environment Variables

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Anonymous/public API key |
| `GOOGLE_WEB_CLIENT_ID` | Google OAuth web client ID |

#### Build Command

```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
             --dart-define=SUPABASE_ANON_KEY=your-anon-key \
             --dart-define=GOOGLE_WEB_CLIENT_ID=your-client-id
```

#### Static Accessors

```dart
// Initialize Supabase
await SupabaseConfig.initialize();

// Access client
final client = SupabaseConfig.client;

// Check authentication
if (SupabaseConfig.isAuthenticated) {
  final user = SupabaseConfig.currentUser;
  final session = SupabaseConfig.currentSession;
}

// Listen to auth changes
SupabaseConfig.authStateChanges.listen((state) {
  // Handle auth events
});
```

### 4.2 Database Tables

| Table | Description | Primary Key |
|-------|-------------|-------------|
| `profiles` | Base user profiles | `id` (UUID from Auth) |
| `doers` | Doer-specific data | `id` (UUID) |
| `skills` | Available skills | `id` (UUID) |
| `subjects` | Available subjects | `id` (UUID) |
| `doer_skills` | Doer-skill junction | `id` (UUID) |
| `doer_subjects` | Doer-subject junction | `id` (UUID) |
| `doer_activation` | Activation progress | `id` (UUID) |
| `projects` | Project/task data | `id` (UUID) |
| `reviews` | Project reviews | `id` (UUID) |

### 4.3 Database Relationships

```
profiles (1) ──── (1) doers
                      │
                      ├── (N) doer_skills ──── (N) skills
                      ├── (N) doer_subjects ──── (N) subjects
                      ├── (1) doer_activation
                      └── (N) projects
                               │
                               └── (N) reviews
```

---

## 5. Mock Data

### 5.1 Overview

Mock data is used for development and testing when the backend is unavailable.

**Location:** `lib/data/mock/`

### 5.2 Available Mock Classes

| Class | Description |
|-------|-------------|
| `MockActivationData` | Training modules and quiz questions |
| `MockDashboardData` | Projects, statistics, reviews |
| `MockProfileData` | User profiles, payments, notifications |
| `MockResourcesData` | Training content, AI checker simulations |

### 5.3 Usage Example

```dart
import 'package:doer_app/data/mock/mock_data.dart';

// Get mock projects
final projects = MockDashboardData.getAssignedProjects();

// Get mock profile
final profile = MockProfileData.getProfile();

// Get mock quiz questions
final questions = MockActivationData.getQuizQuestions();
```

### 5.4 Production Warning

Mock data should only be used in development/testing. Production builds must use repository classes with real Supabase integration.

---

## 6. Error Handling

### 6.1 Exception Types

**Location:** `lib/core/errors/exceptions.dart`

| Exception | Description | Use Case |
|-----------|-------------|----------|
| `AppException` | Base exception class | Parent for all custom exceptions |
| `ServerException` | Server-related errors | API failures, 500 errors |
| `NetworkException` | Network connectivity errors | No internet, timeouts |
| `AuthException` | Authentication errors | Invalid credentials, session expired |
| `ValidationException` | Input validation errors | Form validation failures |
| `CacheException` | Local storage errors | SharedPreferences failures |
| `PermissionException` | Permission denied | Camera, storage access denied |
| `FileException` | File operation errors | Upload failures, invalid files |

### 6.2 Exception Structure

```dart
class AppException implements Exception {
  final String message;     // User-friendly message
  final String? code;       // Error code for logging
  final dynamic originalError; // Original exception
}

// Validation exception with field errors
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
}
```

### 6.3 Usage Example

```dart
try {
  await authRepo.signInWithPassword(email, password);
} on AuthException catch (e) {
  showErrorDialog(e.message);
} on NetworkException catch (e) {
  showOfflineMessage();
} catch (e) {
  showGenericError();
}
```

---

## Appendix

### A. Data Transfer Objects

| DTO | Purpose |
|-----|---------|
| `RegistrationData` | New user signup data |
| `ProfileSetupData` | Doer profile completion data |
| `BankDetailsFormData` | Bank account submission data |

### B. Related Documents

- [Architecture](./ARCHITECTURE.md) - System architecture overview
- [Components](./COMPONENTS.md) - UI component documentation
- [Screens](./SCREENS.md) - Screen documentation

---

*Document maintained by Development Team*
*Last reviewed: December 28, 2024*

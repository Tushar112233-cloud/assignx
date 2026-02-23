# Data Models Documentation

This document describes all data models used in the AssignX User App.

## Overview

Models are organized in `lib/data/models/` and represent the data structures used throughout the application. Each model corresponds to a table in the Supabase database.

---

## User Models

### UserProfile

**File:** `lib/data/models/user_profile.dart`

Represents a user's profile information. Maps to the `profiles` table in Supabase.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier (UUID) |
| `email` | `String` | User's email address |
| `fullName` | `String?` | User's full name |
| `phone` | `String?` | Phone number |
| `phoneVerified` | `bool` | Whether phone is verified |
| `userType` | `UserType?` | Student or Professional |
| `avatarUrl` | `String?` | Profile picture URL |
| `city` | `String?` | User's city |
| `state` | `String?` | User's state |
| `country` | `String` | Country code (default: 'IN') |
| `onboardingStep` | `OnboardingStep` | Current onboarding progress |
| `onboardingCompleted` | `bool` | Whether onboarding is complete |
| `referralCode` | `String?` | User's referral code |
| `createdAt` | `DateTime` | Account creation timestamp |

#### Usage

```dart
// Create from JSON
final profile = UserProfile.fromJson(json);

// Access display name
print(profile.displayName); // Returns fullName or 'User'

// Check completion status
if (profile.isComplete) {
  // Navigate to home
}
```

---

### UserType

**File:** `lib/data/models/user_type.dart`

Enum representing user account types.

| Value | Display Name | Description |
|-------|--------------|-------------|
| `student` | Student | Academic student user |
| `professional` | Professional | Working professional user |

---

### StudentData

**File:** `lib/data/models/student_data.dart`

Extended profile data for student users. Maps to the `students` table.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `universityId` | `String?` | University reference ID |
| `universityName` | `String?` | University name |
| `courseId` | `String?` | Course reference ID |
| `courseName` | `String?` | Course name |
| `semester` | `int?` | Current semester |
| `yearOfStudy` | `int?` | Year of study (1-5) |
| `studentIdNumber` | `String?` | Student ID for verification |
| `preferredSubjects` | `List<String>?` | Preferred subject areas |

---

### ProfessionalData

**File:** `lib/data/models/professional_data.dart`

Extended profile data for professional users. Maps to the `professionals` table.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `professionalType` | `ProfessionalType` | Job seeker, Business, or Creator |
| `industryId` | `String?` | Industry reference ID |
| `jobTitle` | `String?` | Current job title |
| `companyName` | `String?` | Company name |
| `linkedinUrl` | `String?` | LinkedIn profile URL |
| `gstNumber` | `String?` | GST number for businesses |

---

## Project Models

### Project

**File:** `lib/data/models/project.dart`

Main project model representing an assignment request. Maps to the `projects` table.

#### Key Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Unique identifier (UUID) |
| `projectNumber` | `String` | Human-readable ID (e.g., AE-2024-001) |
| `serviceType` | `ServiceType` | Type of service requested |
| `title` | `String` | Project title |
| `status` | `ProjectStatus` | Current project status |
| `deadline` | `DateTime` | Project deadline |
| `userQuote` | `double?` | Quoted price to user |
| `progressPercentage` | `int` | Completion progress (0-100) |
| `deliverables` | `List<ProjectDeliverable>` | Deliverable files |
| `timeline` | `List<ProjectTimelineEvent>` | Status history |

#### Computed Properties

```dart
project.displayId      // "#AE-2024-001"
project.formattedQuote // "₹1,500"
project.isDeadlineUrgent // true if < 24 hours
project.timeUntilDeadline // Duration
```

---

### ProjectStatus

**File:** `lib/data/models/project_status.dart`

Enum representing all possible project states.

| Status | Display Name | Description |
|--------|--------------|-------------|
| `draft` | Draft | Project being created |
| `submitted` | Submitted | Awaiting review |
| `quoteProvided` | Quote Provided | Price quoted to user |
| `paymentPending` | Payment Pending | Waiting for payment |
| `paid` | Paid | Payment received |
| `inProgress` | In Progress | Being worked on |
| `delivered` | Delivered | Work submitted |
| `completed` | Completed | User approved |
| `revision` | Revision | Changes requested |
| `cancelled` | Cancelled | Project cancelled |

---

### ServiceType

**File:** `lib/data/models/service_type.dart`

Types of services offered.

| Value | Display Name | Description |
|-------|--------------|-------------|
| `newProject` | New Project | Full assignment writing |
| `proofreading` | Proofreading | Grammar and style check |
| `plagiarismCheck` | Plagiarism Check | Originality verification |
| `aiDetection` | AI Detection | AI content analysis |
| `expertOpinion` | Expert Opinion | Professional review |

---

## Wallet Models

### Wallet

**File:** `lib/data/models/wallet_model.dart`

User's wallet for payments. Maps to the `wallets` table.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Wallet ID |
| `profileId` | `String` | Owner's profile ID |
| `balance` | `double` | Current balance |
| `lockedAmount` | `double` | Amount locked for pending transactions |
| `currency` | `String` | Currency code (default: INR) |

#### Computed Properties

```dart
wallet.formattedBalance    // "₹2,450"
wallet.availableBalance    // balance - lockedAmount
wallet.hasSufficientBalance(amount) // Check if enough funds
```

---

### WalletTransaction

**File:** `lib/data/models/wallet_model.dart`

Individual wallet transactions. Maps to the `wallet_transactions` table.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `type` | `TransactionType` | Credit, Debit, TopUp, etc. |
| `amount` | `double` | Transaction amount |
| `balanceBefore` | `double` | Balance before transaction |
| `balanceAfter` | `double` | Balance after transaction |
| `description` | `String` | Transaction description |
| `status` | `TransactionStatus` | Pending, Completed, Failed |
| `referenceId` | `String?` | Related entity ID (project, etc.) |

---

## Marketplace Models

### MarketplaceListing

**File:** `lib/data/models/marketplace_model.dart`

Campus marketplace listings. Maps to the `marketplace_listings` table.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `id` | `String` | Listing ID |
| `userId` | `String` | Seller's user ID |
| `category` | `MarketplaceCategory` | Hard Goods, Housing, etc. |
| `type` | `ListingType` | Product, Housing, Event, etc. |
| `title` | `String` | Listing title |
| `price` | `double?` | Price (null for free items) |
| `isNegotiable` | `bool` | Whether price is negotiable |
| `location` | `String?` | Item location |
| `status` | `ListingStatus` | Active, Sold, Expired |

---

## Model Conventions

### JSON Serialization

All models implement `fromJson` and `toJson` methods:

```dart
// Create from Supabase response
final model = Model.fromJson(response);

// Convert for Supabase insert/update
final json = model.toJson();
```

### Database Column Mapping

Models use snake_case for database columns:
- Dart: `fullName` -> DB: `full_name`
- Dart: `createdAt` -> DB: `created_at`

### Enum Conversion

Enums provide `toDbString()` and `fromString()` methods:

```dart
// Convert enum to database value
final dbValue = userType.toDbString(); // "student"

// Parse from database value
final userType = UserType.fromString("student");
```

### Immutability

All models are immutable with `copyWith` methods:

```dart
final updated = profile.copyWith(
  fullName: 'New Name',
  city: 'Mumbai',
);
```

# API & Repository Documentation

This document describes the data access layer (repositories) in the AssignX User App.

## Overview

Repositories provide a clean abstraction over the Supabase client, handling all database operations, error handling, and data transformation.

**Location:** `lib/data/repositories/`

---

## Architecture

```
┌─────────────────────┐
│     UI Layer        │
│    (Widgets)        │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│   Providers Layer   │
│    (Riverpod)       │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│ Repository Layer    │◄─── This Document
│  (Data Access)      │
└──────────┬──────────┘
           │
┌──────────▼──────────┐
│  Supabase Client    │
│   (Network/DB)      │
└─────────────────────┘
```

---

## AuthRepository

**File:** `lib/data/repositories/auth_repository.dart`

Handles all authentication operations.

### Methods

#### `signInWithGoogle()`

Initiates Google OAuth sign-in flow using PKCE.

```dart
/// Signs in user with Google OAuth.
///
/// Returns the authenticated [User] on success.
/// Throws [AuthException] on failure.
///
/// Example:
/// ```dart
/// try {
///   final user = await authRepository.signInWithGoogle();
///   print('Signed in as ${user.email}');
/// } catch (e) {
///   print('Sign-in failed: $e');
/// }
/// ```
Future<User?> signInWithGoogle();
```

#### `signOut()`

Signs out the current user and clears session.

```dart
/// Signs out the current user.
///
/// Clears all stored credentials and tokens.
Future<void> signOut();
```

#### `getCurrentUser()`

Returns the currently authenticated user.

```dart
/// Gets the current authenticated user.
///
/// Returns `null` if no user is signed in.
User? getCurrentUser();
```

#### `createProfile()`

Creates a new user profile after authentication.

```dart
/// Creates a new profile for the authenticated user.
///
/// Parameters:
/// - [userType]: Student or Professional
/// - [fullName]: User's full name
/// - [phone]: Optional phone number
///
/// Returns the created [UserProfile].
Future<UserProfile> createProfile({
  required UserType userType,
  required String fullName,
  String? phone,
});
```

---

## ProfileRepository

**File:** `lib/data/repositories/profile_repository.dart`

Manages user profile data and wallet operations.

### Profile Operations

#### `getProfile()`

Fetches the current user's profile.

```dart
/// Gets the authenticated user's profile.
///
/// Throws [Exception] if user is not authenticated.
///
/// Example:
/// ```dart
/// final profile = await profileRepository.getProfile();
/// print('Hello, ${profile.displayName}');
/// ```
Future<UserProfile> getProfile();
```

#### `updateProfile()`

Updates profile information.

```dart
/// Updates the user's profile.
///
/// Only provided parameters are updated.
///
/// Parameters:
/// - [fullName]: New name
/// - [phone]: New phone number
/// - [avatarUrl]: New profile picture URL
/// - [city]: New city
/// - [state]: New state
///
/// Returns the updated [UserProfile].
Future<UserProfile> updateProfile({
  String? fullName,
  String? phone,
  String? avatarUrl,
  String? city,
  String? state,
});
```

### Wallet Operations

#### `getWallet()`

Gets the user's wallet.

```dart
/// Gets the user's wallet balance and details.
///
/// Returns the user's [Wallet].
/// Throws [Exception] if wallet doesn't exist.
Future<Wallet> getWallet();
```

#### `getTransactions()`

Fetches wallet transaction history.

```dart
/// Gets wallet transaction history.
///
/// Parameters:
/// - [limit]: Maximum transactions to return (default: 20)
/// - [offset]: Pagination offset (default: 0)
///
/// Returns list of [WalletTransaction] sorted by date descending.
Future<List<WalletTransaction>> getTransactions({
  int limit = 20,
  int offset = 0,
});
```

#### `topUpWallet()`

Initiates a wallet top-up.

```dart
/// Initiates a wallet top-up transaction.
///
/// Creates a pending transaction. Actual balance update
/// occurs after payment confirmation via webhook.
///
/// Parameters:
/// - [amount]: Amount to add (INR)
///
/// Returns the current [Wallet] (balance updates after payment).
Future<Wallet> topUpWallet(double amount);
```

### Payment Methods

#### `getPaymentMethods()`

Lists saved payment methods.

```dart
/// Gets all saved payment methods for the user.
///
/// Returns list of [PaymentMethod] sorted by default first.
Future<List<PaymentMethod>> getPaymentMethods();
```

#### `addPaymentMethod()`

Adds a new payment method.

```dart
/// Adds a new payment method.
///
/// Parameters:
/// - [type]: Card, UPI, or Net Banking
/// - [displayName]: Label for the method
/// - [lastFourDigits]: Last 4 digits (for cards)
/// - [upiId]: UPI ID (for UPI)
/// - [setAsDefault]: Whether to make default
///
/// Returns the created [PaymentMethod].
Future<PaymentMethod> addPaymentMethod({
  required PaymentMethodType type,
  required String displayName,
  String? lastFourDigits,
  String? upiId,
  bool setAsDefault = false,
});
```

---

## ProjectRepository

**File:** `lib/data/repositories/project_repository.dart`

Handles project CRUD operations.

### Fetching Projects

#### `getProjects()`

Lists user's projects with optional filters.

```dart
/// Gets projects for the current user.
///
/// Parameters:
/// - [status]: Filter by status
/// - [serviceType]: Filter by service type
/// - [limit]: Max results (default: 20)
/// - [offset]: Pagination offset
///
/// Returns list of [Project] sorted by creation date.
Future<List<Project>> getProjects({
  ProjectStatus? status,
  ServiceType? serviceType,
  int limit = 20,
  int offset = 0,
});
```

#### `getProjectById()`

Fetches a single project with all details.

```dart
/// Gets a project by ID with full details.
///
/// Includes deliverables, timeline, and related data.
///
/// Returns the [Project] or `null` if not found.
Future<Project?> getProjectById(String id);
```

### Creating Projects

#### `createProject()`

Creates a new project request.

```dart
/// Creates a new project.
///
/// Parameters:
/// - [serviceType]: Type of service
/// - [title]: Project title
/// - [subjectId]: Subject category
/// - [description]: Detailed description
/// - [wordCount]: Required word count
/// - [deadline]: Project deadline
/// - [referenceFiles]: Uploaded reference files
///
/// Returns the created [Project] in draft status.
Future<Project> createProject({
  required ServiceType serviceType,
  required String title,
  required String subjectId,
  String? description,
  int? wordCount,
  required DateTime deadline,
  List<String>? referenceFiles,
});
```

### Project Actions

#### `submitForQuote()`

Submits a draft project for quotation.

```dart
/// Submits a project for quotation.
///
/// Changes status from 'draft' to 'submitted'.
/// Admin will review and provide quote.
Future<Project> submitForQuote(String projectId);
```

#### `acceptQuote()`

Accepts a provided quote.

```dart
/// Accepts the provided quote.
///
/// Changes status to 'payment_pending'.
Future<Project> acceptQuote(String projectId);
```

#### `approveDelivery()`

Approves a delivered project.

```dart
/// Approves the project delivery.
///
/// Parameters:
/// - [projectId]: Project to approve
/// - [rating]: Optional rating (1-5)
/// - [feedback]: Optional feedback text
///
/// Changes status to 'completed'.
Future<Project> approveDelivery(
  String projectId, {
  int? rating,
  String? feedback,
});
```

#### `requestRevision()`

Requests changes to delivery.

```dart
/// Requests revision for a delivered project.
///
/// Parameters:
/// - [projectId]: Project ID
/// - [feedback]: Required revision details
///
/// Changes status to 'revision'.
Future<Project> requestRevision(
  String projectId, {
  required String feedback,
});
```

---

## HomeRepository

**File:** `lib/data/repositories/home_repository.dart`

Handles home screen data fetching.

### Methods

#### `getWallet()`

Gets wallet for home screen display.

```dart
/// Gets user wallet by profile ID.
Future<Wallet?> getWallet(String profileId);
```

#### `getBanners()`

Fetches promotional banners.

```dart
/// Gets active promotional banners.
///
/// Returns banners ordered by display_order.
/// Falls back to default banners on error.
Future<List<AppBanner>> getBanners();
```

#### `getNotifications()`

Fetches user notifications.

```dart
/// Gets user notifications.
///
/// Parameters:
/// - [profileId]: User's profile ID
///
/// Returns up to 20 most recent notifications.
Future<List<AppNotification>> getNotifications(String profileId);
```

#### `markAsRead()`

Marks a notification as read.

```dart
/// Marks a single notification as read.
Future<void> markAsRead(String notificationId);
```

---

## MarketplaceRepository

**File:** `lib/data/repositories/marketplace_repository.dart`

Handles campus marketplace operations.

### Methods

#### `getListings()`

Fetches marketplace listings.

```dart
/// Gets marketplace listings with optional filters.
///
/// Parameters:
/// - [category]: Filter by category
/// - [city]: Filter by city
/// - [searchQuery]: Text search
/// - [limit]: Max results (default: 20)
/// - [offset]: Pagination offset
///
/// Returns list of active [MarketplaceListing].
Future<List<MarketplaceListing>> getListings({
  MarketplaceCategory? category,
  String? city,
  String? searchQuery,
  int limit = 20,
  int offset = 0,
});
```

#### `createListing()`

Creates a new marketplace listing.

```dart
/// Creates a new marketplace listing.
///
/// Returns the created [MarketplaceListing].
Future<MarketplaceListing> createListing({
  required MarketplaceCategory category,
  required ListingType type,
  required String title,
  String? description,
  double? price,
  bool isNegotiable = false,
  List<String> images = const [],
  String? location,
});
```

#### `toggleLike()`

Toggles favorite status on a listing.

```dart
/// Toggles like/favorite on a listing.
///
/// Returns `true` if now liked, `false` if unliked.
Future<bool> toggleLike(String listingId);
```

---

## Error Handling

All repositories follow consistent error handling:

```dart
try {
  final result = await repository.someMethod();
  // Handle success
} on PostgrestException catch (e) {
  // Handle Supabase/database errors
  _logger.e('Database error: ${e.message}');
} on AuthException catch (e) {
  // Handle authentication errors
  _logger.e('Auth error: ${e.message}');
} catch (e) {
  // Handle unexpected errors
  _logger.e('Unexpected error: $e');
  rethrow;
}
```

---

## Provider Integration

Repositories are accessed through Riverpod providers:

```dart
// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

// Data provider
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile();
});

// Usage in widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) => Text(profile.displayName),
      loading: () => CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}
```

# API Documentation

This document describes the repository layer and API interactions in the Superviser App.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Supabase Client](#supabase-client)
- [Repositories](#repositories)
  - [AuthRepository](#authrepository)
  - [DashboardRepository](#dashboardrepository)
  - [ProjectRepository](#projectrepository)
  - [ChatRepository](#chatrepository)
  - [EarningsRepository](#earningsrepository)
  - [ProfileRepository](#profilerepository)
  - [ResourcesRepository](#resourcesrepository)
  - [SupportRepository](#supportrepository)
  - [NotificationRepository](#notificationrepository)
  - [UsersRepository](#usersrepository)
  - [DoersRepository](#doersrepository)
  - [ActivationRepository](#activationrepository)
- [Error Handling](#error-handling)
- [Data Models](#data-models)

---

## Architecture Overview

The app uses a **Repository Pattern** to abstract data access from the UI layer. All database operations go through Supabase.

```
┌─────────────────────────────────────────────────────────────┐
│                        UI Layer                              │
│              (Screens, Widgets, Components)                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     Provider Layer                           │
│         (StateNotifier, AsyncNotifier, Riverpod)            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Repository Layer                           │
│     (AuthRepository, DashboardRepository, etc.)             │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Supabase Client                           │
│         (Database, Auth, Storage, Realtime)                 │
└─────────────────────────────────────────────────────────────┘
```

---

## Supabase Client

**File:** `lib/core/network/supabase_client.dart`

### Initialization

```dart
// In main.dart
await SupabaseService.initialize();
```

### Available Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `initialize()` | `Future<void>` | Initializes Supabase with env config |
| `client` | `SupabaseClient` | Returns the initialized client instance |
| `currentUser` | `User?` | Gets the currently authenticated user |
| `currentSession` | `Session?` | Gets the current session |
| `isAuthenticated` | `bool` | Returns true if user is logged in |
| `authStateChanges` | `Stream<AuthState>` | Stream of auth state changes |

### Riverpod Providers

```dart
// Access the Supabase client
final client = ref.watch(supabaseClientProvider);

// Listen to auth state changes
final authState = ref.watch(authStateChangesProvider);
```

---

## Repositories

### AuthRepository

**File:** `lib/features/auth/data/repositories/auth_repository.dart`

Handles all authentication operations.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `signInWithEmail` | `email`, `password` | `Future<UserModel>` | Sign in with email/password |
| `signUpWithEmail` | `email`, `password`, `fullName` | `Future<UserModel>` | Create new account |
| `signInWithGoogle` | - | `Future<UserModel>` | Sign in with Google OAuth |
| `signOut` | - | `Future<void>` | Sign out current user |
| `resetPassword` | `email` | `Future<void>` | Send password reset email |
| `recoverSession` | - | `Future<Session?>` | Recover and refresh existing session |
| `getCurrentUser` | - | `UserModel?` | Get current user data |
| `updateProfile` | `updates` | `Future<void>` | Update user profile |
| `authStateChanges` | - | `Stream<AuthState>` | Stream of auth changes |

#### Usage Example

```dart
final authRepo = ref.read(authRepositoryProvider);

// Sign in
final user = await authRepo.signInWithEmail(
  'user@example.com',
  'password123',
);

// Recover session on app start
final session = await authRepo.recoverSession();
if (session != null) {
  // User is still logged in
}
```

---

### DashboardRepository

**File:** `lib/features/dashboard/data/repositories/dashboard_repository.dart`

Manages dashboard data including requests, quotes, and doer assignments.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getNewRequests` | - | `Future<List<RequestModel>>` | Get submitted requests awaiting quotes |
| `getPaidRequests` | - | `Future<List<RequestModel>>` | Get paid requests ready for assignment |
| `getRequestsBySubject` | `subject` | `Future<List<RequestModel>>` | Filter requests by subject |
| `submitQuote` | `quote` | `Future<void>` | Submit price quote for request |
| `getAvailableDoers` | `expertise?` | `Future<List<DoerModel>>` | Get available doers |
| `assignDoer` | `projectId`, `doerId` | `Future<void>` | Assign doer to project |
| `getDoerReviews` | `doerId` | `Future<List<DoerReview>>` | Get reviews for a doer |
| `updateAvailability` | `isAvailable` | `Future<void>` | Update supervisor availability |
| `getAvailability` | - | `Future<bool>` | Get current availability status |

#### Database Tables Used

- `projects` - Main projects table
- `project_quotes` - Quote submissions
- `project_assignments` - Doer assignments
- `doers` - Doer profiles
- `doer_reviews` - Doer reviews
- `supervisors` - Supervisor settings
- `profiles` - User profiles
- `subjects` - Subject categories

---

### ProjectRepository

**File:** `lib/features/projects/data/repositories/project_repository.dart`

Handles project management and status updates.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getProjects` | `status?` | `Future<List<ProjectModel>>` | Get projects with optional status filter |
| `getProjectById` | `id` | `Future<ProjectModel>` | Get single project by ID |
| `updateProjectStatus` | `id`, `status` | `Future<void>` | Update project status |
| `submitDeliverable` | `projectId`, `deliverable` | `Future<void>` | Submit project deliverable |
| `requestRevision` | `projectId`, `feedback` | `Future<void>` | Request project revision |
| `approveDeliverable` | `projectId` | `Future<void>` | Approve final deliverable |

---

### ChatRepository

**File:** `lib/features/chat/data/repositories/chat_repository.dart`

Manages chat rooms and messages with realtime support.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getChatRooms` | - | `Future<List<ChatRoomModel>>` | Get all chat rooms |
| `getMessages` | `roomId` | `Future<List<MessageModel>>` | Get messages for a room |
| `sendMessage` | `roomId`, `content` | `Future<void>` | Send a message |
| `markAsRead` | `roomId` | `Future<void>` | Mark messages as read |
| `subscribeToMessages` | `roomId` | `Stream<MessageModel>` | Realtime message stream |

---

### EarningsRepository

**File:** `lib/features/earnings/data/repositories/earnings_repository.dart`

Handles earnings and transaction data.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getEarningsSummary` | - | `Future<EarningsModel>` | Get earnings summary |
| `getTransactions` | `limit?`, `offset?` | `Future<List<TransactionModel>>` | Get transaction history |
| `getEarningsByPeriod` | `startDate`, `endDate` | `Future<EarningsModel>` | Get earnings for period |

---

### ProfileRepository

**File:** `lib/features/profile/data/repositories/profile_repository.dart`

Manages user profile data.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getProfile` | - | `Future<ProfileModel>` | Get current user profile |
| `updateProfile` | `updates` | `Future<void>` | Update profile fields |
| `uploadAvatar` | `file` | `Future<String>` | Upload profile picture |
| `getReviews` | - | `Future<List<ReviewModel>>` | Get reviews received |

---

### ResourcesRepository

**File:** `lib/features/resources/data/repositories/resources_repository.dart`

Manages tools, training videos, and pricing guides.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getTools` | - | `Future<List<ToolModel>>` | Get available tools |
| `getTrainingVideos` | - | `Future<List<TrainingVideoModel>>` | Get training videos |
| `getPricingGuide` | - | `Future<List<PricingModel>>` | Get pricing information |

---

### SupportRepository

**File:** `lib/features/support/data/repositories/support_repository.dart`

Handles support tickets and FAQs.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getTickets` | - | `Future<List<TicketModel>>` | Get all support tickets |
| `getTicketById` | `id` | `Future<TicketModel>` | Get ticket details |
| `createTicket` | `ticket` | `Future<void>` | Create new support ticket |
| `addReply` | `ticketId`, `message` | `Future<void>` | Reply to ticket |
| `getFAQs` | - | `Future<List<FAQModel>>` | Get FAQ list |

---

### NotificationRepository

**File:** `lib/features/notifications/data/repositories/notification_repository.dart`

Manages notification data.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getNotifications` | - | `Future<List<NotificationModel>>` | Get all notifications |
| `markAsRead` | `id` | `Future<void>` | Mark notification as read |
| `markAllAsRead` | - | `Future<void>` | Mark all as read |
| `deleteNotification` | `id` | `Future<void>` | Delete notification |

---

### UsersRepository

**File:** `lib/features/users/data/repositories/users_repository.dart`

Manages client user data.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getClients` | - | `Future<List<ClientModel>>` | Get all clients |
| `getClientById` | `id` | `Future<ClientModel>` | Get client details |
| `searchClients` | `query` | `Future<List<ClientModel>>` | Search clients |

---

### DoersRepository

**File:** `lib/features/doers/data/repositories/doers_repository.dart`

Manages doer data.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getDoers` | `filter?` | `Future<List<DoerModel>>` | Get all doers |
| `getDoerById` | `id` | `Future<DoerModel>` | Get doer details |
| `searchDoers` | `query` | `Future<List<DoerModel>>` | Search doers |

---

### ActivationRepository

**File:** `lib/features/activation/data/repositories/activation_repository.dart`

Handles doer activation and training.

#### Methods

| Method | Parameters | Return Type | Description |
|--------|------------|-------------|-------------|
| `getTrainingModules` | - | `Future<List<TrainingModule>>` | Get training modules |
| `getModuleById` | `id` | `Future<TrainingModule>` | Get module details |
| `completeModule` | `moduleId` | `Future<void>` | Mark module complete |
| `submitQuizAnswers` | `quizId`, `answers` | `Future<QuizResult>` | Submit quiz answers |
| `getActivationStatus` | - | `Future<ActivationStatus>` | Get activation progress |

---

## Error Handling

All repositories use a centralized error handling approach.

### Exception Types

**File:** `lib/core/network/api_exceptions.dart`

| Exception | Description | HTTP Codes |
|-----------|-------------|------------|
| `ApiException` | Base exception class | - |
| `AppAuthException` | Authentication errors | 401, 403 |
| `ServerException` | Server/database errors | 500, 502, 503 |
| `NetworkException` | Connectivity issues | - |
| `NotFoundException` | Resource not found | 404 |
| `ValidationException` | Invalid data | 400, 422 |

### Usage in Repositories

```dart
try {
  final response = await _client
      .from('projects')
      .select()
      .eq('id', projectId)
      .single();
  return ProjectModel.fromJson(response);
} on PostgrestException catch (e) {
  throw ServerException.fromPostgrest(e);
}
```

### Handling in Providers

```dart
Future<void> loadProjects() async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final projects = await _repository.getProjects();
    state = state.copyWith(
      isLoading: false,
      projects: projects,
    );
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}
```

---

## Data Models

All data models are located in their respective feature's `data/models/` directory.

### Core Models

| Model | File | Description |
|-------|------|-------------|
| `UserModel` | `auth/data/models/user_model.dart` | User data |
| `RequestModel` | `dashboard/data/models/request_model.dart` | Project requests |
| `QuoteModel` | `dashboard/data/models/quote_model.dart` | Price quotes |
| `DoerModel` | `dashboard/data/models/doer_model.dart` | Doer profiles |
| `ProjectModel` | `projects/data/models/project_model.dart` | Project data |
| `MessageModel` | `chat/data/models/message_model.dart` | Chat messages |
| `ChatRoomModel` | `chat/data/models/chat_room_model.dart` | Chat rooms |
| `EarningsModel` | `earnings/data/models/earnings_model.dart` | Earnings data |
| `TransactionModel` | `earnings/data/models/transaction_model.dart` | Transactions |
| `ProfileModel` | `profile/data/models/profile_model.dart` | Profile data |
| `NotificationModel` | `notifications/data/models/notification_model.dart` | Notifications |
| `TicketModel` | `support/data/models/ticket_model.dart` | Support tickets |

### Model Factory Methods

All models support:

```dart
// From JSON (Supabase response)
static Model fromJson(Map<String, dynamic> json);

// To JSON (for inserts/updates)
Map<String, dynamic> toJson();

// Copy with modifications
Model copyWith({...});
```

---

## Database Schema Reference

### Key Tables

| Table | Description | RLS |
|-------|-------------|-----|
| `profiles` | User profiles | Yes |
| `supervisors` | Supervisor data | Yes |
| `doers` | Doer profiles | Yes |
| `projects` | All projects | Yes |
| `project_quotes` | Quote submissions | Yes |
| `project_assignments` | Doer assignments | Yes |
| `subjects` | Subject categories | No |
| `messages` | Chat messages | Yes |
| `chat_rooms` | Chat room metadata | Yes |
| `notifications` | User notifications | Yes |
| `support_tickets` | Support tickets | Yes |

### Common Query Patterns

**Join with profiles:**
```dart
.select('''
  *,
  user:profiles!user_id(id, full_name, email, avatar_url)
''')
```

**Filter by supervisor:**
```dart
.eq('supervisor_id', supervisorId)
```

**Order by date:**
```dart
.order('created_at', ascending: false)
```

---

## Best Practices

1. **Always use repositories** - Never access Supabase directly from UI
2. **Handle errors** - Wrap database calls in try-catch
3. **Use proper types** - Convert JSON to typed models
4. **Validate data** - Check for null/invalid data before processing
5. **Use RLS** - Rely on Row Level Security for access control

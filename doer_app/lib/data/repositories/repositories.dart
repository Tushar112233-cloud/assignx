/// Data repositories barrel file for the DOER application.
///
/// This module provides centralized access to all repository classes that
/// abstract data access from the provider layer. Repositories handle
/// communication with external data sources (Supabase, APIs) and provide
/// a clean interface for business logic.
///
/// ## Repository Pattern
///
/// The repository pattern separates data access logic from business logic:
///
/// ```
/// +-------------+     +----------------+     +---------------+
/// |   UI Layer  | --> | Provider Layer | --> |  Repository   |
/// |  (Screens)  |     | (State Mgmt)   |     |    Layer      |
/// +-------------+     +----------------+     +---------------+
///                                                   |
///                                                   v
///                                           +---------------+
///                                           | Data Sources  |
///                                           | (Supabase/API)|
///                                           +---------------+
/// ```
///
/// ## Benefits
///
/// - **Testability**: Repositories can be mocked for unit testing
/// - **Maintainability**: Data logic is isolated and reusable
/// - **Flexibility**: Easy to swap data sources (e.g., local to remote)
/// - **Separation of Concerns**: Providers focus on state, repos on data
///
/// ## Available Repositories
///
/// ### Implemented
/// - [AuthRepository] - Authentication and user profile operations
///   - Sign up, sign in, sign out
///   - OTP verification
///   - Profile management
///   - Google OAuth integration
///
/// ### Planned
/// - **DashboardRepository** - Dashboard data: projects, stats, reviews
/// - **ProfileRepository** - User profile and settings management
/// - **WorkspaceRepository** - Workspace and project work operations
/// - **ResourcesRepository** - Training modules and resources
/// - **ActivationRepository** - Activation flow and quiz management
///
/// ## Usage
///
/// ```dart
/// import 'package:doer_app/data/repositories/repositories.dart';
///
/// // Create repository instance
/// final authRepo = SupabaseAuthRepository();
///
/// // Use in provider
/// class AuthProvider extends ChangeNotifier {
///   final AuthRepository _authRepo;
///
///   AuthProvider({AuthRepository? authRepo})
///       : _authRepo = authRepo ?? SupabaseAuthRepository();
///
///   Future<void> signIn(String email, String password) async {
///     final response = await _authRepo.signInWithPassword(
///       email: email,
///       password: password,
///     );
///     // Handle response...
///   }
/// }
/// ```
///
/// ## Dependency Injection
///
/// Repositories support dependency injection for testing:
///
/// ```dart
/// // In tests
/// class MockAuthRepository implements AuthRepository {
///   // Mock implementation...
/// }
///
/// final provider = AuthProvider(authRepo: MockAuthRepository());
/// ```
///
/// ## Error Handling
///
/// Repositories throw typed exceptions that providers should catch:
///
/// ```dart
/// try {
///   await authRepo.signInWithPassword(email: email, password: password);
/// } on AuthException catch (e) {
///   // Handle authentication errors
/// } on PostgrestException catch (e) {
///   // Handle database errors
/// }
/// ```
///
/// See also:
/// - `lib/providers/` for state management using repositories
/// - `lib/data/mock/` for mock data during development
/// - `lib/core/config/supabase_config.dart` for Supabase setup
library;

export 'auth_repository.dart';
export 'chat_repository.dart';
export 'deliverable_repository.dart';
export 'project_repository.dart';
export 'wallet_repository.dart';

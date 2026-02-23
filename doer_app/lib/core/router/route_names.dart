/// Route path constants for navigation.
///
/// This file defines all route paths used in the DOER app's navigation
/// system. Using constants ensures consistency and makes refactoring easier.
///
/// ## Route Categories
/// - **Initial Routes**: App entry points (splash, onboarding)
/// - **Auth Routes**: Authentication screens (login, register)
/// - **Activation Routes**: User onboarding flow
/// - **Main Routes**: Primary app screens (dashboard, projects, resources, profile)
/// - **Sub-Routes**: Nested screens within main sections
///
/// ## Path Parameters
/// Some routes include path parameters for dynamic content:
/// - `/project/:id` - Project detail with ID
/// - `/project/:id/workspace` - Project workspace
/// - `/chat/:roomId` - Chat room
///
/// ## Usage
/// ```dart
/// // Navigate to a static route
/// context.go(RouteNames.dashboard);
///
/// // Navigate with path parameters
/// context.go(RouteNames.projectDetail.replaceFirst(':id', projectId));
///
/// // Or use go_router's goNamed with parameters
/// context.goNamed('projectDetail', pathParameters: {'id': projectId});
/// ```
library;

/// Route names for navigation.
///
/// Contains all route paths as static constants. This centralized
/// approach prevents typos and makes route changes easier to manage.
///
/// ## Naming Convention
/// - Routes use kebab-case in paths (e.g., `/profile-setup`)
/// - Static constants use camelCase (e.g., `profileSetup`)
/// - Sub-routes are prefixed with parent path (e.g., `/dashboard/statistics`)
class RouteNames {
  /// Private constructor to prevent instantiation.
  RouteNames._();

  // ---------------------------------------------------------------------------
  // Initial Routes
  // ---------------------------------------------------------------------------

  /// Splash screen - app entry point.
  ///
  /// This is the initial route shown while the app loads.
  /// Path: `/`
  static const String splash = '/';

  /// Onboarding screen for new users.
  ///
  /// Shows app introduction and value proposition.
  /// Path: `/onboarding`
  static const String onboarding = '/onboarding';

  // ---------------------------------------------------------------------------
  // Auth Routes
  // ---------------------------------------------------------------------------

  /// Login screen for existing users.
  ///
  /// Path: `/login`
  static const String login = '/login';

  /// Registration screen for new users.
  ///
  /// Path: `/register`
  static const String register = '/register';

  /// Forgot password screen.
  ///
  /// Path: `/forgot-password`
  static const String forgotPassword = '/forgot-password';

  // ---------------------------------------------------------------------------
  // Profile Setup
  // ---------------------------------------------------------------------------

  /// Initial profile setup for new users.
  ///
  /// Collects basic profile information after registration.
  /// Path: `/profile-setup`
  static const String profileSetup = '/profile-setup';

  // ---------------------------------------------------------------------------
  // Activation Routes
  // ---------------------------------------------------------------------------

  /// Activation gate - main activation screen.
  ///
  /// Shows activation progress and remaining steps.
  /// Path: `/activation`
  static const String activationGate = '/activation';

  /// Training modules screen.
  ///
  /// Displays available training content.
  /// Path: `/activation/training`
  static const String training = '/activation/training';

  /// Quiz screen for activation assessment.
  ///
  /// Path: `/activation/quiz`
  static const String quiz = '/activation/quiz';

  /// Bank details entry for activation.
  ///
  /// Collects payment information.
  /// Path: `/activation/bank-details`
  static const String bankDetails = '/activation/bank-details';

  // ---------------------------------------------------------------------------
  // Main App Routes
  // ---------------------------------------------------------------------------

  /// Main dashboard screen.
  ///
  /// Shows overview of projects, earnings, and activity.
  /// Path: `/dashboard`
  static const String dashboard = '/dashboard';

  /// Projects listing screen.
  ///
  /// Path: `/projects`
  static const String projects = '/projects';

  /// Project detail screen with dynamic ID.
  ///
  /// Path: `/project/:id`
  /// Parameter: `id` - Project identifier
  static const String projectDetail = '/project/:id';

  /// Project workspace for active work.
  ///
  /// Path: `/project/:id/workspace`
  /// Parameter: `id` - Project identifier
  static const String workspace = '/project/:id/workspace';

  /// Work submission screen.
  ///
  /// Path: `/project/:id/submit`
  /// Parameter: `id` - Project identifier
  static const String submitWork = '/project/:id/submit';

  /// Revision handling screen.
  ///
  /// Path: `/project/:id/revision`
  /// Parameter: `id` - Project identifier
  static const String revision = '/project/:id/revision';

  /// Project chat screen.
  ///
  /// Path: `/project/:id/chat`
  /// Parameter: `id` - Project identifier
  static const String projectChat = '/project/:id/chat';

  /// Resources hub screen.
  ///
  /// Central location for learning resources and tools.
  /// Path: `/resources`
  static const String resources = '/resources';

  /// User profile screen.
  ///
  /// Path: `/profile`
  static const String profile = '/profile';

  // ---------------------------------------------------------------------------
  // Dashboard Sub-Routes
  // ---------------------------------------------------------------------------

  /// Statistics and analytics screen.
  ///
  /// Shows detailed performance metrics.
  /// Path: `/dashboard/statistics`
  static const String statistics = '/dashboard/statistics';

  /// Reviews and ratings screen.
  ///
  /// Displays client feedback.
  /// Path: `/dashboard/reviews`
  static const String reviews = '/dashboard/reviews';

  /// My projects listing.
  ///
  /// Path: `/dashboard/projects`
  static const String myProjects = '/dashboard/projects';

  // ---------------------------------------------------------------------------
  // Profile Sub-Routes
  // ---------------------------------------------------------------------------

  /// Edit profile screen.
  ///
  /// Path: `/profile/edit`
  static const String editProfile = '/profile/edit';

  /// Payment history screen.
  ///
  /// Shows past transactions and earnings.
  /// Path: `/profile/payments`
  static const String paymentHistory = '/profile/payments';

  /// Bank details edit screen (post-activation).
  ///
  /// Path: `/profile/bank-details`
  static const String bankDetailsEdit = '/profile/bank-details';

  /// Notifications screen.
  ///
  /// Path: `/notifications`
  static const String notifications = '/notifications';

  /// Settings screen.
  ///
  /// Path: `/settings`
  static const String settings = '/settings';

  // ---------------------------------------------------------------------------
  // Resource Sub-Routes
  // ---------------------------------------------------------------------------

  /// Training center with additional courses.
  ///
  /// Path: `/resources/training`
  static const String trainingCenter = '/resources/training';

  /// AI content checker tool.
  ///
  /// Path: `/resources/ai-checker`
  static const String aiChecker = '/resources/ai-checker';

  /// Citation builder tool.
  ///
  /// Path: `/resources/citation-builder`
  static const String citationBuilder = '/resources/citation-builder';

  /// Format templates screen.
  ///
  /// Downloadable document templates for various formats.
  /// Path: `/resources/templates`
  static const String formatTemplates = '/resources/templates';

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------

  /// Chat room screen with dynamic room ID.
  ///
  /// Path: `/chat/:roomId`
  /// Parameter: `roomId` - Chat room identifier
  static const String chat = '/chat/:roomId';

  // ---------------------------------------------------------------------------
  // Support
  // ---------------------------------------------------------------------------

  /// Help and support screen.
  ///
  /// Path: `/support`
  static const String support = '/support';

  /// Support ticket detail screen.
  ///
  /// Path: `/support/ticket/:id`
  /// Parameter: `id` - Ticket identifier
  static const String supportTicket = '/support/ticket/:id';
}

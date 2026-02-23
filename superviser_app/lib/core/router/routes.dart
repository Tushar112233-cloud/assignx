/// Route path and name constants for the Superviser App.
///
/// This file provides centralized constants for all route paths and names
/// used throughout the application. Using constants instead of string literals
/// helps prevent typos and makes refactoring easier.
///
/// ## Route Categories
///
/// - **Auth Routes**: Login, register, password reset
/// - **Onboarding Routes**: First-time user experience
/// - **Registration Routes**: User registration wizard
/// - **Activation Routes**: Doer activation flow
/// - **Main App Routes**: Dashboard, projects, chat, profile
/// - **User Management Routes**: Client and doer management
///
/// ## Usage
///
/// ```dart
/// // Navigation with path
/// context.go(RoutePaths.dashboard);
///
/// // Navigation with parameters
/// context.go(RoutePaths.projectDetail.replaceFirst(':id', projectId));
///
/// // Named navigation
/// context.goNamed(RouteNames.dashboard);
///
/// // Named navigation with parameters
/// context.goNamed(
///   RouteNames.projectDetail,
///   pathParameters: {'id': projectId},
/// );
/// ```
///
/// ## Path Parameters
///
/// Some routes include path parameters denoted by `:paramName`:
/// - `:id` - Generic identifier
/// - `:roomId` - Chat room identifier
/// - `:moduleId` - Training module identifier
/// - `:quizId` - Quiz identifier
/// - `:ticketId` - Support ticket identifier
/// - `:clientId` - Client user identifier
/// - `:doerId` - Doer user identifier
///
/// See also:
/// - [appRouterProvider] for the router configuration
/// - [GoRouter] for navigation methods
library;

/// Route path constants for navigation.
///
/// Contains all route paths as static string constants.
/// Paths with parameters use the `:paramName` syntax.
///
/// ## Example
///
/// ```dart
/// // Simple navigation
/// context.go(RoutePaths.login);
///
/// // With path parameters
/// final path = RoutePaths.projectDetail.replaceFirst(':id', '123');
/// context.go(path); // Goes to /projects/123
/// ```
abstract class RoutePaths {
  // ============ Auth Routes ============

  /// Splash screen shown on app launch.
  ///
  /// Path: `/`
  static const splash = '/';

  /// Login screen for user authentication.
  ///
  /// Path: `/login`
  static const login = '/login';

  /// Registration screen for new users.
  ///
  /// Path: `/register`
  static const register = '/register';

  /// Password reset request screen.
  ///
  /// Path: `/forgot-password`
  static const forgotPassword = '/forgot-password';

  // ============ Onboarding & Registration Routes ============

  /// Onboarding screens for first-time users.
  ///
  /// Path: `/onboarding`
  static const onboarding = '/onboarding';

  /// Registration wizard for new doer applications.
  ///
  /// Path: `/registration`
  static const registration = '/registration';

  /// Application pending screen shown while awaiting approval.
  ///
  /// Path: `/registration/pending`
  static const registrationPending = '/registration/pending';

  // ============ Activation Routes ============

  /// Main activation screen for doer training.
  ///
  /// Path: `/activation`
  static const activation = '/activation';

  /// Training video screen with module parameter.
  ///
  /// Path: `/activation/video/:moduleId`
  static const activationVideo = '/activation/video/:moduleId';

  /// Training document screen with module parameter.
  ///
  /// Path: `/activation/document/:moduleId`
  static const activationDocument = '/activation/document/:moduleId';

  /// Quiz screen with quiz parameter.
  ///
  /// Path: `/activation/quiz/:quizId`
  static const activationQuiz = '/activation/quiz/:quizId';

  /// Activation complete success screen.
  ///
  /// Path: `/activation/complete`
  static const activationComplete = '/activation/complete';

  // ============ Main App Routes ============

  /// Main dashboard / home screen.
  ///
  /// Path: `/dashboard`
  static const dashboard = '/dashboard';

  /// Projects list screen.
  ///
  /// Path: `/projects`
  static const projects = '/projects';

  /// Project detail screen with ID parameter.
  ///
  /// Path: `/projects/:id`
  static const projectDetail = '/projects/:id';

  /// Chat list / inbox screen.
  ///
  /// Path: `/chat`
  static const chat = '/chat';

  /// Individual chat room screen with room ID parameter.
  ///
  /// Path: `/chat/:roomId`
  static const chatRoom = '/chat/:roomId';

  /// User profile screen.
  ///
  /// Path: `/profile`
  static const profile = '/profile';

  /// Edit profile screen.
  ///
  /// Path: `/profile/edit`
  static const editProfile = '/profile/edit';

  /// User reviews screen.
  ///
  /// Path: `/profile/reviews`
  static const reviews = '/profile/reviews';

  /// Blacklist management screen.
  ///
  /// Path: `/profile/blacklist`
  static const blacklist = '/profile/blacklist';

  /// Earnings and payments screen.
  ///
  /// Path: `/earnings`
  static const earnings = '/earnings';

  /// Resources and tools screen.
  ///
  /// Path: `/resources`
  static const resources = '/resources';

  /// Support ticket list screen.
  ///
  /// Path: `/support`
  static const support = '/support';

  /// Support ticket detail screen with ticket ID parameter.
  ///
  /// Path: `/support/ticket/:ticketId`
  static const ticketDetail = '/support/ticket/:ticketId';

  /// Frequently asked questions screen.
  ///
  /// Path: `/faq`
  static const faq = '/faq';

  /// Notifications list screen.
  ///
  /// Path: `/notifications`
  static const notifications = '/notifications';

  /// Notification settings screen.
  ///
  /// Path: `/notifications/settings`
  static const notificationSettings = '/notifications/settings';

  /// App settings screen.
  ///
  /// Path: `/settings`
  static const settings = '/settings';

  // ============ User Management Routes ============

  /// Users / clients list screen.
  ///
  /// Path: `/users`
  static const users = '/users';

  /// Client detail screen with client ID parameter.
  ///
  /// Path: `/users/:clientId`
  static const clientDetail = '/users/:clientId';

  // ============ Doer Routes ============

  /// Doers list screen.
  ///
  /// Path: `/doers`
  static const doers = '/doers';

  /// Doer detail screen with doer ID parameter.
  ///
  /// Path: `/doers/:doerId`
  static const doerDetail = '/doers/:doerId';
}

/// Route name constants for named navigation.
///
/// Contains all route names as static string constants.
/// Use with [GoRouter.goNamed] or [GoRouter.pushNamed] for named navigation.
///
/// ## Benefits of Named Routes
///
/// - Type-safe parameter passing
/// - Easier refactoring of paths
/// - Better code readability
///
/// ## Example
///
/// ```dart
/// // Simple named navigation
/// context.goNamed(RouteNames.login);
///
/// // With path parameters
/// context.goNamed(
///   RouteNames.projectDetail,
///   pathParameters: {'id': '123'},
/// );
///
/// // With query parameters
/// context.goNamed(
///   RouteNames.projects,
///   queryParameters: {'status': 'active'},
/// );
/// ```
abstract class RouteNames {
  // ============ Auth Routes ============

  /// Name for the splash screen route.
  static const splash = 'splash';

  /// Name for the login screen route.
  static const login = 'login';

  /// Name for the register screen route.
  static const register = 'register';

  /// Name for the forgot password screen route.
  static const forgotPassword = 'forgot-password';

  // ============ Onboarding & Registration Routes ============

  /// Name for the onboarding screen route.
  static const onboarding = 'onboarding';

  /// Name for the registration wizard route.
  static const registration = 'registration';

  /// Name for the registration pending route.
  static const registrationPending = 'registration-pending';

  // ============ Activation Routes ============

  /// Name for the activation screen route.
  static const activation = 'activation';

  /// Name for the activation video route.
  static const activationVideo = 'activation-video';

  /// Name for the activation document route.
  static const activationDocument = 'activation-document';

  /// Name for the activation quiz route.
  static const activationQuiz = 'activation-quiz';

  /// Name for the activation complete route.
  static const activationComplete = 'activation-complete';

  // ============ Main App Routes ============

  /// Name for the dashboard route.
  static const dashboard = 'dashboard';

  /// Name for the projects list route.
  static const projects = 'projects';

  /// Name for the project detail route.
  static const projectDetail = 'project-detail';

  /// Name for the chat list route.
  static const chat = 'chat';

  /// Name for the chat room route.
  static const chatRoom = 'chat-room';

  /// Name for the profile route.
  static const profile = 'profile';

  /// Name for the edit profile route.
  static const editProfile = 'edit-profile';

  /// Name for the reviews route.
  static const reviews = 'reviews';

  /// Name for the blacklist route.
  static const blacklist = 'blacklist';

  /// Name for the earnings route.
  static const earnings = 'earnings';

  /// Name for the resources route.
  static const resources = 'resources';

  /// Name for the support route.
  static const support = 'support';

  /// Name for the ticket detail route.
  static const ticketDetail = 'ticket-detail';

  /// Name for the FAQ route.
  static const faq = 'faq';

  /// Name for the notifications route.
  static const notifications = 'notifications';

  /// Name for the notification settings route.
  static const notificationSettings = 'notification-settings';

  /// Name for the settings route.
  static const settings = 'settings';

  // ============ User Management Routes ============

  /// Name for the users list route.
  static const users = 'users';

  /// Name for the client detail route.
  static const clientDetail = 'client-detail';

  // ============ Doer Routes ============

  /// Name for the doers list route.
  static const doers = 'doers';

  /// Name for the doer detail route.
  static const doerDetail = 'doer-detail';
}

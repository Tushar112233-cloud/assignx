/// Application routing configuration using GoRouter for the Superviser App.
///
/// This file provides the complete routing configuration including:
/// - Route definitions for all screens
/// - Authentication-based route guards
/// - Bottom navigation shell route
/// - Error handling for unknown routes
///
/// ## Architecture
///
/// The routing system uses a hierarchical structure:
/// ```
/// Root Routes (public)
///     |
///     +-- /splash, /login, /register (auth flow)
///     +-- /onboarding (first-time users)
///     +-- /registration (user registration)
///     +-- /activation (doer activation)
///     |
/// Shell Route (authenticated)
///     |
///     +-- /dashboard (home)
///     +-- /projects (project management)
///     +-- /chat (messaging)
///     +-- /profile (user profile)
///     +-- /earnings, /resources, /support, etc.
/// ```
///
/// ## Route Guards
///
/// The router implements authentication guards that:
/// 1. Redirect unauthenticated users to login
/// 2. Redirect authenticated users away from auth pages
/// 3. Redirect unactivated users to registration pending
///
/// ## Usage
///
/// ```dart
/// // In main.dart
/// MaterialApp.router(
///   routerConfig: ref.watch(appRouterProvider),
/// );
///
/// // Navigation
/// context.go(RoutePaths.dashboard);
/// context.push(RoutePaths.projectDetail.replaceFirst(':id', projectId));
/// ```
///
/// See also:
/// - [RoutePaths] for route path constants
/// - [RouteNames] for named route constants
/// - [AuthProvider] for authentication state
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/registration/presentation/screens/application_pending_screen.dart';
import '../../features/registration/presentation/screens/registration_wizard_screen.dart';
import '../../features/activation/presentation/screens/activation_screen.dart';
import '../../features/activation/presentation/screens/training_video_screen.dart';
import '../../features/activation/presentation/screens/training_document_screen.dart';
import '../../features/activation/presentation/screens/quiz_screen.dart';
import '../../features/activation/presentation/screens/activation_complete_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/projects/presentation/screens/project_detail_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/resources/presentation/screens/resources_screen.dart';
import '../../features/resources/presentation/screens/tool_webview_screen.dart';
import '../../features/resources/presentation/screens/training_video_screen.dart'
    as resources;
import '../../features/resources/data/models/training_video_model.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/reviews_screen.dart';
import '../../features/profile/presentation/screens/blacklist_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../features/support/presentation/screens/ticket_detail_screen.dart';
import '../../features/support/presentation/screens/faq_screen.dart';
import '../../features/users/presentation/screens/users_screen.dart';
import '../../features/doers/presentation/screens/doers_screen.dart';
import '../../features/doers/presentation/screens/doer_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'routes.dart';

/// Riverpod provider for the application router.
///
/// This provider creates and configures the [GoRouter] instance with:
/// - All route definitions
/// - Authentication-based redirects
/// - Debug logging
/// - Error handling
///
/// The router automatically refreshes when authentication state changes,
/// ensuring users are redirected appropriately on sign in/out.
///
/// ## Example
///
/// ```dart
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final router = ref.watch(appRouterProvider);
///
///     return MaterialApp.router(
///       routerConfig: router,
///       theme: AppTheme.light,
///       darkTheme: AppTheme.dark,
///     );
///   }
/// }
/// ```
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      ref.read(authProvider.notifier).stream,
    ),
    redirect: (context, state) {
      // Read current auth state at redirect time (not captured at provider creation)
      final authState = ref.read(authProvider);
      final isLoggedIn = authState.isAuthenticated;
      final isActivated = authState.isActivated;
      final isLoading = authState.isLoading;
      final location = state.matchedLocation;

      // Don't redirect while loading
      if (isLoading && location == RoutePaths.splash) {
        return null;
      }

      // Public routes that don't require auth
      final publicRoutes = [
        RoutePaths.splash,
        RoutePaths.login,
        RoutePaths.register,
        RoutePaths.onboarding,
      ];

      // Routes allowed without activation (auth required but not activation)
      final preActivationRoutes = [
        RoutePaths.registration,
        RoutePaths.registrationPending,
        RoutePaths.activation,
        RoutePaths.activationComplete,
      ];

      final isPublicRoute = publicRoutes.contains(location);
      final isPreActivationRoute = preActivationRoutes.any(
        (route) => location.startsWith(route),
      );

      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isPublicRoute) {
        return RoutePaths.login;
      }

      // If logged in and trying to access auth routes
      if (isLoggedIn && isPublicRoute && location != RoutePaths.splash) {
        if (isActivated) {
          return RoutePaths.dashboard;
        } else {
          return RoutePaths.activation;
        }
      }

      // Allow access to pre-activation routes if logged in
      if (isLoggedIn && isPreActivationRoute) {
        return null;
      }

      // If logged in but not activated, redirect to activation (training modules)
      if (isLoggedIn && !isActivated && !isPreActivationRoute && !isPublicRoute) {
        return RoutePaths.activation;
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      // Onboarding Route
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Registration Routes
      GoRoute(
        path: RoutePaths.registration,
        name: RouteNames.registration,
        builder: (context, state) => const RegistrationWizardScreen(),
      ),
      GoRoute(
        path: RoutePaths.registrationPending,
        name: RouteNames.registrationPending,
        builder: (context, state) => const ApplicationPendingScreen(),
      ),

      // Activation Routes
      GoRoute(
        path: RoutePaths.activation,
        name: RouteNames.activation,
        builder: (context, state) => const ActivationScreen(),
      ),
      GoRoute(
        path: '/activation/video/:moduleId',
        name: RouteNames.activationVideo,
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return TrainingVideoScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/activation/document/:moduleId',
        name: RouteNames.activationDocument,
        builder: (context, state) {
          final moduleId = state.pathParameters['moduleId']!;
          return TrainingDocumentScreen(moduleId: moduleId);
        },
      ),
      GoRoute(
        path: '/activation/quiz/:quizId',
        name: RouteNames.activationQuiz,
        builder: (context, state) {
          final quizId = state.pathParameters['quizId']!;
          return QuizScreen(quizId: quizId);
        },
      ),
      GoRoute(
        path: RoutePaths.activationComplete,
        name: RouteNames.activationComplete,
        builder: (context, state) => const ActivationCompleteScreen(),
      ),

      // Main App Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.dashboard,
            name: RouteNames.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: RoutePaths.projects,
            name: RouteNames.projects,
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: RouteNames.projectDetail,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProjectDetailScreen(projectId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.chat,
            name: RouteNames.chat,
            builder: (context, state) => const ChatListScreen(),
            routes: [
              GoRoute(
                path: ':roomId',
                name: RouteNames.chatRoom,
                builder: (context, state) {
                  final roomId = state.pathParameters['roomId']!;
                  return ChatScreen(projectId: roomId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'reviews',
                name: RouteNames.reviews,
                builder: (context, state) => const ReviewsScreen(),
              ),
              GoRoute(
                path: 'blacklist',
                name: RouteNames.blacklist,
                builder: (context, state) => const BlacklistScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.earnings,
            name: RouteNames.earnings,
            builder: (context, state) => const EarningsScreen(),
          ),
          GoRoute(
            path: RoutePaths.resources,
            name: RouteNames.resources,
            builder: (context, state) => const ResourcesScreen(),
            routes: [
              GoRoute(
                path: 'plagiarism-checker',
                name: 'plagiarismChecker',
                builder: (context, state) => const PlagiarismCheckerScreen(),
              ),
              GoRoute(
                path: 'ai-detector',
                name: 'aiDetector',
                builder: (context, state) => const AIDetectorScreen(),
              ),
              GoRoute(
                path: 'webview',
                name: 'resourceWebview',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ToolWebViewScreen(
                    url: extra?['url'] ?? '',
                    title: extra?['title'] ?? 'Tool',
                  );
                },
              ),
              GoRoute(
                path: 'video/:videoId',
                name: 'trainingVideo',
                builder: (context, state) {
                  final videoId = state.pathParameters['videoId']!;
                  final video = state.extra as TrainingVideoModel?;
                  return resources.TrainingVideoPlayerScreen(
                    videoId: videoId,
                    video: video,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.support,
            name: RouteNames.support,
            builder: (context, state) => const SupportScreen(),
            routes: [
              GoRoute(
                path: 'ticket/:ticketId',
                name: RouteNames.ticketDetail,
                builder: (context, state) {
                  final ticketId = state.pathParameters['ticketId']!;
                  return TicketDetailScreen(ticketId: ticketId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.faq,
            name: RouteNames.faq,
            builder: (context, state) => const FAQScreen(),
          ),
          GoRoute(
            path: RoutePaths.notifications,
            name: RouteNames.notifications,
            builder: (context, state) => const NotificationsScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                name: RouteNames.notificationSettings,
                builder: (context, state) => const NotificationSettingsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.users,
            name: RouteNames.users,
            builder: (context, state) => const UsersScreen(),
            routes: [
              GoRoute(
                path: ':clientId',
                name: RouteNames.clientDetail,
                builder: (context, state) {
                  final clientId = state.pathParameters['clientId']!;
                  return ClientDetailScreen(clientId: clientId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.doers,
            name: RouteNames.doers,
            builder: (context, state) => const DoersScreen(),
            routes: [
              GoRoute(
                path: ':doerId',
                name: RouteNames.doerDetail,
                builder: (context, state) {
                  final doerId = state.pathParameters['doerId']!;
                  return DoerDetailScreen(doerId: doerId);
                },
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.dashboard),
              child: const Text('Go to Dashboard'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Helper class that converts a [Stream] to a [ChangeNotifier].
///
/// This allows GoRouter to listen for auth state changes and trigger
/// route redirects when the authentication state changes.
///
/// ## Example
///
/// ```dart
/// GoRouter(
///   refreshListenable: GoRouterRefreshStream(authStateStream),
///   // ...
/// );
/// ```
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a refresh stream from the given authentication state stream.
  ///
  /// Listens to the stream and calls [notifyListeners] on each event,
  /// triggering a route redirect check.
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Main application shell with bottom navigation bar.
///
/// This widget wraps the main app content and provides a persistent
/// bottom navigation bar for navigating between main sections.
///
/// ## Usage
///
/// Used internally by the router's [ShellRoute] to wrap authenticated screens.
///
/// ```dart
/// ShellRoute(
///   builder: (context, state, child) => AppShell(child: child),
///   routes: [...],
/// );
/// ```
class AppShell extends ConsumerWidget {
  /// Creates an app shell with the given child widget.
  const AppShell({super.key, required this.child});

  /// The current screen content to display above the navigation bar.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: child,
      bottomNavigationBar: const AppBottomNavigationBar(),
    );
  }
}

/// Bottom navigation bar for the main app sections.
///
/// Provides navigation between:
/// - Dashboard (home)
/// - Projects
/// - Chat
/// - Profile
///
/// The selected index is determined by the current route location.
class AppBottomNavigationBar extends ConsumerWidget {
  /// Creates the bottom navigation bar.
  const AppBottomNavigationBar({super.key});

  /// The navigation items displayed in the bar.
  static final _items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard_outlined),
      activeIcon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.folder_outlined),
      activeIcon: Icon(Icons.folder),
      label: 'Projects',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_outlined),
      activeIcon: Icon(Icons.chat),
      label: 'Chat',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outlined),
      activeIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  /// Calculates the selected index based on the current route location.
  ///
  /// Returns the index corresponding to the current route:
  /// - 0: Dashboard
  /// - 1: Projects
  /// - 2: Chat
  /// - 3: Profile
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.dashboard)) return 0;
    if (location.startsWith(RoutePaths.projects)) return 1;
    if (location.startsWith(RoutePaths.chat)) return 2;
    if (location.startsWith(RoutePaths.profile)) return 3;
    return 0;
  }

  /// Handles navigation when a bar item is tapped.
  ///
  /// Navigates to the corresponding route for the tapped index.
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RoutePaths.dashboard);
        break;
      case 1:
        context.go(RoutePaths.projects);
        break;
      case 2:
        context.go(RoutePaths.chat);
        break;
      case 3:
        context.go(RoutePaths.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _calculateSelectedIndex(context),
      onTap: (index) => _onItemTapped(context, index),
      items: _items,
    );
  }
}

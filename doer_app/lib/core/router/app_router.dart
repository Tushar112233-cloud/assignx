/// Application router configuration using go_router.
///
/// This file defines the complete navigation structure for the DOER app,
/// including route definitions, authentication guards, and redirect logic.
///
/// ## Features
/// - Declarative routing with go_router
/// - Authentication-based route guards
/// - Activation state-based access control
/// - Dynamic route parameters for projects
/// - Error page handling
///
/// ## Route Categories
/// - **Public Routes**: Accessible without authentication (splash, onboarding, login)
/// - **Activation Routes**: Accessible during user activation process
/// - **Protected Routes**: Require full authentication and activation
///
/// ## Navigation Flow
/// ```
/// Splash -> Check Auth
///   |
///   +-> Authenticated & Activated -> Dashboard
///   +-> Authenticated & Not Activated -> Activation Gate
///   +-> Not Authenticated -> Onboarding
/// ```
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import '../../shared/animations/page_transitions.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/activation/screens/activation_gate_screen.dart';
import '../../features/activation/screens/training_screen.dart';
import '../../features/activation/screens/quiz_screen.dart';
import '../../features/activation/screens/bank_details_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/dashboard/screens/statistics_screen.dart';
import '../../features/dashboard/screens/reviews_screen.dart';
import '../../features/workspace/screens/project_detail_screen.dart';
import '../../features/workspace/screens/workspace_screen.dart';
import '../../features/workspace/screens/submit_work_screen.dart';
import '../../features/workspace/screens/revision_screen.dart';
import '../../features/workspace/screens/chat_screen.dart';
import '../../features/resources/screens/training_center_screen.dart';
import '../../features/resources/screens/citation_builder_screen.dart';
import '../../features/resources/screens/format_templates_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/notifications_screen.dart';
import '../../features/projects/screens/open_pool_screen.dart';
import '../../features/support/screens/support_screen.dart';
import '../../providers/auth_provider.dart';

/// Public routes that don't require authentication.
///
/// Users can access these routes regardless of authentication state.
/// Includes onboarding flow and authentication screens.
const _publicRoutes = [
  RouteNames.splash,
  RouteNames.onboarding,
  RouteNames.login,
  RouteNames.register,
];

/// Routes accessible during activation (unactivated but authenticated users).
///
/// Authenticated users who haven't completed activation can only access
/// these routes until they complete the activation process.
const _activationRoutes = [
  RouteNames.activationGate,
  RouteNames.training,
  RouteNames.quiz,
  RouteNames.bankDetails,
  RouteNames.profileSetup,
];

/// App router configuration using go_router.
///
/// This provider creates and manages the [GoRouter] instance with:
/// - Route definitions for all screens
/// - Authentication-based redirect logic
/// - Deep linking support
/// - Error page handling
///
/// ## Usage
/// Access the router in widgets via Riverpod:
/// ```dart
/// final router = ref.watch(appRouterProvider);
/// router.go(RouteNames.dashboard);
/// ```
///
/// ## Redirect Logic
/// The router implements the following redirect rules:
/// 1. Splash screen is always accessible (handles its own navigation)
/// 2. Unauthenticated users are redirected to onboarding
/// 3. Authenticated but unactivated users are restricted to activation routes
/// 4. Activated users trying to access activation routes are redirected to dashboard
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    refreshListenable: _AuthStateNotifier(ref),
    redirect: (context, state) {
      // Read current auth state at redirect time (not captured at provider creation)
      final authState = ref.read(authProvider);
      final path = state.matchedLocation;
      final isPublicRoute = _publicRoutes.contains(path);
      final isActivationRoute = _activationRoutes.contains(path);

      // Allow splash screen always (it handles its own navigation)
      if (path == RouteNames.splash) {
        return null;
      }

      // Still loading auth state - let splash handle it
      if (authState.status == AuthStatus.initial ||
          authState.status == AuthStatus.loading) {
        // Only redirect to splash if not already on a public route
        if (!isPublicRoute) {
          return RouteNames.splash;
        }
        return null;
      }

      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;
      final isActivated = user?.isActivated ?? false;
      final hasDoerProfile = user?.hasDoerProfile ?? false;

      // Unauthenticated user trying to access protected route
      if (!isAuthenticated && !isPublicRoute) {
        return RouteNames.onboarding;
      }

      // Authenticated user on public route - redirect appropriately
      if (isAuthenticated && isPublicRoute && path != RouteNames.splash) {
        if (isActivated) {
          return RouteNames.dashboard;
        } else if (hasDoerProfile) {
          return RouteNames.activationGate;
        } else {
          return RouteNames.profileSetup;
        }
      }

      // Authenticated but not activated - restrict to activation routes
      if (isAuthenticated && !isActivated && !isActivationRoute && !isPublicRoute) {
        if (hasDoerProfile) {
          return RouteNames.activationGate;
        } else {
          return RouteNames.profileSetup;
        }
      }

      // Activated user trying to access activation routes - redirect to dashboard
      if (isAuthenticated && isActivated && isActivationRoute) {
        return RouteNames.dashboard;
      }

      return null; // No redirect needed
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Routes
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => FadeScalePage(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteNames.register,
        name: 'register',
        pageBuilder: (context, state) => FadeScalePage(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      // Profile Setup
      GoRoute(
        path: RouteNames.profileSetup,
        name: 'profileSetup',
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Activation Routes
      GoRoute(
        path: RouteNames.activationGate,
        name: 'activationGate',
        builder: (context, state) => const ActivationGateScreen(),
      ),
      GoRoute(
        path: RouteNames.training,
        name: 'training',
        builder: (context, state) => const TrainingScreen(),
      ),
      GoRoute(
        path: RouteNames.quiz,
        name: 'quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      GoRoute(
        path: RouteNames.bankDetails,
        name: 'bankDetails',
        builder: (context, state) => const BankDetailsScreen(),
      ),

      // Dashboard Routes
      GoRoute(
        path: RouteNames.dashboard,
        name: 'dashboard',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: RouteNames.statistics,
        name: 'statistics',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: RouteNames.insights,
        name: 'insights',
        builder: (context, state) => const StatisticsScreen(),
      ),
      GoRoute(
        path: RouteNames.reviews,
        name: 'reviews',
        builder: (context, state) => const ReviewsScreen(),
      ),

      // Profile Routes
      GoRoute(
        path: RouteNames.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.bankDetailsEdit,
        name: 'bankDetailsEdit',
        builder: (context, state) => const BankDetailsScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.support,
        name: 'support',
        builder: (context, state) => const SupportScreen(),
      ),

      // Open Pool
      GoRoute(
        path: RouteNames.openPool,
        name: 'openPool',
        builder: (context, state) => const OpenPoolScreen(),
      ),

      // Project & Workspace Routes
      GoRoute(
        path: RouteNames.projectDetail,
        name: 'projectDetail',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return SlideRightPage(
            key: state.pageKey,
            child: ProjectDetailScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.workspace,
        name: 'workspace',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return SlideRightPage(
            key: state.pageKey,
            child: WorkspaceScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.submitWork,
        name: 'submitWork',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return SlideUpPage(
            key: state.pageKey,
            child: SubmitWorkScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.revision,
        name: 'revision',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return SlideUpPage(
            key: state.pageKey,
            child: RevisionScreen(projectId: projectId),
          );
        },
      ),
      GoRoute(
        path: RouteNames.projectChat,
        name: 'projectChat',
        pageBuilder: (context, state) {
          final projectId = state.pathParameters['id']!;
          return SlideRightPage(
            key: state.pageKey,
            child: ChatScreen(projectId: projectId),
          );
        },
      ),
      // Resources Routes
      GoRoute(
        path: RouteNames.trainingCenter,
        name: 'trainingCenter',
        builder: (context, state) => const TrainingCenterScreen(),
      ),
      GoRoute(
        path: RouteNames.citationBuilder,
        name: 'citationBuilder',
        builder: (context, state) => const CitationBuilderScreen(),
      ),
      GoRoute(
        path: RouteNames.formatTemplates,
        name: 'formatTemplates',
        builder: (context, state) => const FormatTemplatesScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.path,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Notifier that triggers router refresh when auth state changes.
///
/// This class bridges Riverpod's state management with go_router's
/// refresh mechanism, ensuring routes are re-evaluated when the
/// authentication state changes.
///
/// ## How It Works
/// 1. Listens to the [authProvider] for state changes
/// 2. Calls [notifyListeners] when auth state changes
/// 3. go_router's [refreshListenable] triggers route re-evaluation
class _AuthStateNotifier extends ChangeNotifier {
  /// Creates an auth state notifier that listens to auth changes.
  ///
  /// @param _ref Riverpod reference for watching auth provider
  _AuthStateNotifier(this._ref) {
    _ref.listen(authProvider, (previous, next) {
      notifyListeners();
    });
  }

  /// Riverpod reference for accessing providers.
  final Ref _ref;
}

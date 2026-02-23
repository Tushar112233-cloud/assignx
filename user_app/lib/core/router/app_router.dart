import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/add_project/screens/expert_opinion_form.dart';
import '../../features/add_project/screens/new_project_form.dart';
import '../../features/add_project/screens/proofreading_form.dart';
import '../../features/add_project/screens/report_request_form.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/magic_link_screen.dart';
import '../../features/auth/screens/signin_screen.dart';
import '../../features/chat/screens/project_chat_screen.dart';
import '../../features/experts/screens/booking_screen.dart';
import '../../features/experts/screens/expert_detail_screen.dart';
import '../../features/experts/screens/experts_screen.dart';
import '../../features/experts/screens/my_bookings_screen.dart';
import '../../features/home/screens/main_shell.dart';
import '../../features/campus_connect/screens/create_post_screen.dart';
import '../../features/campus_connect/screens/post_detail_screen.dart';
import '../../features/campus_connect/screens/saved_listings_screen.dart';
import '../../features/marketplace/screens/create_listing_screen.dart';
import '../../features/marketplace/screens/item_detail_screen.dart';
import '../../features/marketplace/screens/marketplace_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/professional_profile_screen.dart';
import '../../features/onboarding/screens/role_selection_screen.dart';
import '../../features/onboarding/screens/signup_success_screen.dart';
import '../../features/onboarding/screens/student_profile_screen.dart';
import '../../features/profile/screens/account_upgrade_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/payment_methods_screen.dart';
import '../../features/profile/screens/wallet_screen.dart';
import '../../features/profile/widgets/account_upgrade_card.dart';
import '../../features/projects/screens/live_draft_webview.dart';
import '../../features/projects/screens/project_detail_screen.dart';
import '../../features/projects/screens/project_timeline_screen.dart';
import '../../features/profile/screens/security_screen.dart';
import '../../features/auth/screens/college_verification_screen.dart';
import '../../features/connect/screens/connect_screen.dart';
import '../../features/connect/screens/study_groups_screen.dart';
import '../../features/projects/screens/project_payment_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../providers/auth_provider.dart';
import '../../shared/animations/page_transitions.dart';
import 'route_names.dart';

/// Global navigator key for navigation without context.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// App router provider with auth-based redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
      final hasProfile = authState.valueOrNull?.hasProfile ?? false;
      final currentPath = state.matchedLocation;

      // Don't redirect while loading or on splash screen
      if (isLoading || currentPath == RouteNames.splash) {
        return null;
      }

      // Public routes that don't require auth
      final publicRoutes = [
        RouteNames.onboarding,
        RouteNames.login,
        RouteNames.signin,
        RouteNames.magicLink,
        RouteNames.authCallback,
      ];

      // Profile completion routes
      final profileRoutes = [
        RouteNames.roleSelection,
        RouteNames.studentProfile,
        RouteNames.professionalProfile,
        RouteNames.signupSuccess,
      ];

      // If not authenticated and not on public route, go to onboarding
      if (!isAuthenticated) {
        if (!publicRoutes.contains(currentPath)) {
          return RouteNames.onboarding;
        }
        return null;
      }

      // If authenticated but no profile, go to role selection
      if (isAuthenticated && !hasProfile) {
        if (!profileRoutes.contains(currentPath)) {
          return RouteNames.roleSelection;
        }
        return null;
      }

      // If authenticated with profile and on auth routes, go to home
      if (isAuthenticated && hasProfile) {
        if (publicRoutes.contains(currentPath) || profileRoutes.contains(currentPath)) {
          return RouteNames.home;
        }
        return null;
      }

      return null;
    },
    routes: [
      // Splash - no transition for initial load
      GoRoute(
        path: RouteNames.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding - fade scale transition
      GoRoute(
        path: RouteNames.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const OnboardingScreen(),
          state: state,
        ),
      ),

      // Auth - fade scale transition
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const LoginScreen(),
          state: state,
        ),
      ),

      // Sign In - for returning users
      GoRoute(
        path: RouteNames.signin,
        name: 'signin',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const SignInScreen(),
          state: state,
        ),
      ),

      // Magic Link confirmation screen
      GoRoute(
        path: RouteNames.magicLink,
        name: 'magicLink',
        pageBuilder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return AppPageTransitions.fadeScale(
            child: MagicLinkScreen(email: email),
            state: state,
          );
        },
      ),

      // Auth callback - handles deep link from magic link email
      // Pattern: assignx://auth-callback?access_token=...&refresh_token=...
      GoRoute(
        path: RouteNames.authCallback,
        name: 'authCallback',
        redirect: (context, state) {
          // The Supabase auth listener will handle the session
          // Just redirect to home - if not authenticated, the main redirect will handle it
          return RouteNames.home;
        },
      ),

      // Role Selection - fade scale transition
      GoRoute(
        path: RouteNames.roleSelection,
        name: 'roleSelection',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const RoleSelectionScreen(),
          state: state,
        ),
      ),

      // Student Profile - slide right transition
      GoRoute(
        path: RouteNames.studentProfile,
        name: 'studentProfile',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const StudentProfileScreen(),
          state: state,
        ),
      ),

      // Professional Profile - slide right transition
      GoRoute(
        path: RouteNames.professionalProfile,
        name: 'professionalProfile',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const ProfessionalProfileScreen(),
          state: state,
        ),
      ),

      // Signup Success - fade scale transition
      GoRoute(
        path: RouteNames.signupSuccess,
        name: 'signupSuccess',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const SignupSuccessScreen(),
          state: state,
        ),
      ),

      // Main App Shell (Home with dock navigation)
      GoRoute(
        path: RouteNames.home,
        name: 'home',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const MainShell(),
          state: state,
        ),
      ),

      // Add Project routes - slide up transitions for modal-like forms
      GoRoute(
        path: '/add-project/new',
        name: 'addProjectNew',
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          child: const NewProjectForm(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/add-project/proofread',
        name: 'addProjectProofread',
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          child: const ProofreadingForm(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/add-project/report',
        name: 'addProjectReport',
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          child: const ReportRequestForm(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/add-project/expert',
        name: 'addProjectExpert',
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          child: const ExpertOpinionForm(),
          state: state,
        ),
      ),

      // Marketplace - fade scale for main, slide for details
      GoRoute(
        path: '/marketplace',
        name: 'marketplace',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const MarketplaceScreen(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'create',
            name: 'createListing',
            pageBuilder: (context, state) => AppPageTransitions.slideUp(
              child: const CreateListingScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'listingDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppPageTransitions.slideRight(
                child: ItemDetailScreen(listingId: id),
                state: state,
              );
            },
          ),
        ],
      ),

      // Experts/Consultations routes
      GoRoute(
        path: '/experts',
        name: 'experts',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const ExpertsScreen(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'my-bookings',
            name: 'myBookings',
            pageBuilder: (context, state) => AppPageTransitions.slideRight(
              child: const MyBookingsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: ':id',
            name: 'expertDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppPageTransitions.slideRight(
                child: ExpertDetailScreen(expertId: id),
                state: state,
              );
            },
            routes: [
              GoRoute(
                path: 'book',
                name: 'expertBook',
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AppPageTransitions.slideUp(
                    child: BookingScreen(expertId: id),
                    state: state,
                  );
                },
              ),
            ],
          ),
        ],
      ),

      // Campus Connect routes - for post details, create, and saved listings
      GoRoute(
        path: '/campus-connect',
        name: 'campusConnect',
        redirect: (context, state) => RouteNames.home, // Redirect to main shell
        routes: [
          GoRoute(
            path: 'create',
            name: 'createPost',
            pageBuilder: (context, state) => AppPageTransitions.slideUp(
              child: const CreatePostScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'saved',
            name: 'savedListings',
            pageBuilder: (context, state) => AppPageTransitions.slideRight(
              child: const SavedListingsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'post/:id',
            name: 'postDetail',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppPageTransitions.slideRight(
                child: PostDetailScreen(postId: id),
                state: state,
            );
            },
          ),
        ],
      ),

      // Notifications - slide right transition
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const NotificationsScreen(),
          state: state,
        ),
      ),

      // Wallet - slide right transition
      GoRoute(
        path: '/wallet',
        name: 'wallet',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const WalletScreen(),
          state: state,
        ),
      ),

      // Profile routes - slide right transitions
      GoRoute(
        path: '/profile/edit',
        name: 'editProfile',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const EditProfileScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/profile/help',
        name: 'helpSupport',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const HelpSupportScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/profile/payment-methods',
        name: 'paymentMethods',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const PaymentMethodsScreen(),
          state: state,
        ),
      ),
      GoRoute(
        path: '/profile/upgrade',
        name: 'accountUpgrade',
        pageBuilder: (context, state) {
          // Get the current account type from query params or default to student
          final typeStr = state.uri.queryParameters['type'] ?? 'student';
          final currentType = AccountType.fromDbString(typeStr);
          return AppPageTransitions.slideUp(
            child: AccountUpgradeScreen(currentType: currentType),
            state: state,
          );
        },
      ),

      // Security Settings
      GoRoute(
        path: '/profile/security',
        name: 'security',
        pageBuilder: (context, state) => AppPageTransitions.slideRight(
          child: const SecurityScreen(),
          state: state,
        ),
      ),

      // College Email Verification
      GoRoute(
        path: '/verify-college',
        name: 'verifyCollege',
        pageBuilder: (context, state) => AppPageTransitions.slideUp(
          child: const CollegeVerificationScreen(),
          state: state,
        ),
      ),

      // Connect - Peer-to-peer features (tutors, study groups, resources)
      GoRoute(
        path: '/connect',
        name: 'connect',
        pageBuilder: (context, state) => AppPageTransitions.fadeScale(
          child: const ConnectScreen(),
          state: state,
        ),
        routes: [
          GoRoute(
            path: 'groups',
            name: 'studyGroups',
            pageBuilder: (context, state) => AppPageTransitions.slideRight(
              child: const StudyGroupsScreen(),
              state: state,
            ),
          ),
          GoRoute(
            path: 'groups/:id',
            name: 'studyGroupDetail',
            pageBuilder: (context, state) {
              // TODO: Create dedicated detail screen using state.pathParameters['id']
              return AppPageTransitions.slideRight(
                child: const StudyGroupsScreen(),
                state: state,
              );
            },
          ),
          GoRoute(
            path: 'resources',
            name: 'resources',
            pageBuilder: (context, state) => AppPageTransitions.slideRight(
              child: const ConnectScreen(), // TODO: Create dedicated resources screen
              state: state,
            ),
          ),
        ],
      ),

      // Projects - slide right for detail, sub-routes
      GoRoute(
        path: '/projects/:id',
        name: 'projectDetail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppPageTransitions.slideRight(
            child: ProjectDetailScreen(projectId: id),
            state: state,
          );
        },
        routes: [
          GoRoute(
            path: 'pay',
            name: 'projectPay',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppPageTransitions.slideUp(
                child: ProjectPaymentScreen(projectId: id),
                state: state,
              );
            },
          ),
          GoRoute(
            path: 'timeline',
            name: 'projectTimeline',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppPageTransitions.slideRight(
                child: ProjectTimelineScreen(projectId: id),
                state: state,
              );
            },
          ),
          GoRoute(
            path: 'chat',
            name: 'projectChat',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppPageTransitions.slideRight(
                child: ProjectChatScreen(projectId: id),
                state: state,
              );
            },
          ),
          GoRoute(
            path: 'draft',
            name: 'projectDraft',
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              // Get draft URL from query params or fetch from project
              final draftUrl = state.uri.queryParameters['url'];
              return AppPageTransitions.slideRight(
                child: LiveDraftWebview(projectId: id, draftUrl: draftUrl),
                state: state,
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );
});

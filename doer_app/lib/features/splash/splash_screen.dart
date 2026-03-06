import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/router/route_names.dart';
import '../../core/storage/token_storage.dart';
import '../../providers/auth_provider.dart';
import '../../core/translation/translation_extensions.dart';

/// Splash screen with animated logo and app name.
///
/// This is the entry point of the application, displaying the DOER branding
/// while checking authentication state and determining the appropriate
/// navigation destination.
///
/// ## Navigation
/// - Entry: App launch (initial route)
/// - Authenticated + Activated: Navigates to [DashboardScreen]
/// - Authenticated + Has Profile: Navigates to [ActivationGateScreen]
/// - Authenticated + No Profile: Navigates to [ProfileSetupScreen]
/// - Unauthenticated: Navigates to [OnboardingScreen]
///
/// ## Features
/// - Animated logo with scale and fade effects
/// - App name and tagline with staggered animations
/// - Automatic auth state resolution with retry logic
/// - Smart routing based on user activation status
///
/// ## Animation Sequence
/// 1. Logo fades in and scales (0-600ms)
/// 2. App name slides up and fades in (300-900ms)
/// 3. Tagline fades in (500-1100ms)
/// 4. Footer fades in (800-1400ms)
/// 5. Navigation occurs after 2500ms minimum
///
/// See also:
/// - [AuthProvider] for authentication state management
/// - [OnboardingScreen] for new users
/// - [DashboardScreen] for authenticated users
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// State class for [SplashScreen].
///
/// Handles the initialization logic and automatic navigation
/// after the splash animation completes.
class _SplashScreenState extends ConsumerState<SplashScreen> {
  /// Initializes the splash screen and triggers navigation.
  ///
  /// Called once when the widget is inserted into the tree.
  /// Immediately starts the navigation timer.
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  /// Determines and executes navigation to the appropriate screen.
  ///
  /// Waits for a minimum of 2500ms to allow animations to complete,
  /// then checks the authentication state. Includes retry logic
  /// (up to 10 attempts at 200ms intervals) to handle cases where
  /// the auth state is still being resolved.
  ///
  /// Navigation logic:
  /// - [AuthStatus.authenticated] with activated user -> Dashboard
  /// - [AuthStatus.authenticated] with profile -> Activation Gate
  /// - [AuthStatus.authenticated] without profile -> Profile Setup
  /// - Other states -> Onboarding
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // Check if already has tokens
    final hasTokens = await TokenStorage.hasTokens();
    if (hasTokens) {
      // Wait for auth state to resolve if still loading
      var authState = ref.read(authProvider);
      int retries = 0;
      while ((authState.status == AuthStatus.initial ||
              authState.status == AuthStatus.loading) &&
             retries < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        authState = ref.read(authProvider);
        retries++;
      }
      if (!mounted) return;
      _navigateBasedOnAuth(authState);
      return;
    }

    // No tokens — go to onboarding
    if (!mounted) return;
    context.go(RouteNames.onboarding);
  }

  void _navigateBasedOnAuth(AuthState authState) {
    if (!mounted) return;
    switch (authState.status) {
      case AuthStatus.authenticated:
        final user = authState.user;
        if (user != null && user.isActivated) {
          context.go(RouteNames.dashboard);
        } else if (user != null && user.hasDoerProfile) {
          context.go(RouteNames.activationGate);
        } else {
          context.go(RouteNames.profileSetup);
        }
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.initial:
      case AuthStatus.loading:
        context.go(RouteNames.onboarding);
    }
  }

  /// Builds the splash screen UI with animated branding elements.
  ///
  /// Layout structure:
  /// - Primary background color
  /// - Centered column with animated logo, app name, and tagline
  /// - Footer with "Powered by AssignX" text
  ///
  /// Uses [flutter_animate] package for staggered entrance animations.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo placeholder
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppSpacing.borderRadiusLg,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'D',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: AppSpacing.lg),
                  // App name
                  Text(
                    'DOER'.tr(context),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 8,
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  const SizedBox(height: AppSpacing.sm),
                  // Tagline
                  Text(
                    'Your Skills, Your Earnings'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms),
                ],
              ),
            ),
            const Spacer(),
            // Powered by footer
            Text(
              'Powered by AssignX'.tr(context),
              style: TextStyle(
                fontSize: 12,
                color: Colors.white54,
              ),
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 600.ms),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// {@template splash_screen}
/// Animated splash screen for the Superviser App.
///
/// Displays app branding with smooth animations while the application
/// initializes and determines the user's authentication state.
///
/// ## Overview
/// The splash screen serves as the visual entry point for the application,
/// providing a polished first impression while essential initialization
/// occurs in the background.
///
/// ## Responsibilities
/// - Display animated app logo and branding
/// - Wait for authentication state to initialize
/// - Navigate to appropriate screen based on auth status
/// - Handle loading timeout gracefully
///
/// ## Navigation Logic
/// After the splash duration completes:
/// - Authenticated + Activated -> `/dashboard`
/// - Authenticated + Not Activated -> `/activation`
/// - Not Authenticated -> `/login`
///
/// ## Animations
/// Uses `flutter_animate` for smooth entrance animations:
/// - Logo: Fade in + scale with ease-out-back curve
/// - App name: Fade in + slide up
/// - Tagline: Delayed fade in
/// - Loading indicator: Delayed fade in
///
/// ## Usage
/// Typically set as the initial route in GoRouter:
/// ```dart
/// GoRouter(
///   initialLocation: '/',
///   routes: [
///     GoRoute(
///       path: '/',
///       builder: (context, state) => const SplashScreen(),
///     ),
///     // ... other routes
///   ],
/// )
/// ```
///
/// ## Configuration
/// The splash duration is configured via [AppConstants.splashDuration].
///
/// ## See Also
/// - [AuthProvider] for authentication state
/// - [AppConstants] for configuration values
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/auth_provider.dart';

/// {@macro splash_screen}
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// State for [SplashScreen] managing navigation timing.
class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  /// Initiates navigation after the splash duration.
  ///
  /// Waits for [AppConstants.splashDuration], then checks auth state.
  /// If auth is still loading, polls until complete or timeout.
  Future<void> _navigateAfterDelay() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Check auth state and navigate accordingly
    final authState = ref.read(authProvider);

    if (authState.isLoading) {
      // Wait for auth to finish loading
      await _waitForAuth();
    }

    _navigate();
  }

  /// Polls the auth state until loading completes.
  ///
  /// Checks every 100ms for up to 5 seconds total.
  /// This ensures we don't navigate before auth initialization
  /// completes, while also preventing indefinite waiting.
  Future<void> _waitForAuth() async {
    // Poll until auth is no longer loading (max 5 seconds)
    for (var i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      if (!ref.read(authProvider).isLoading) break;
    }
  }

  /// Performs navigation based on authentication state.
  ///
  /// Routes to:
  /// - `/dashboard` if authenticated and activated
  /// - `/activation` if authenticated but not activated
  /// - `/login` if not authenticated
  void _navigate() {
    if (!mounted) return;

    final authState = ref.read(authProvider);

    if (authState.isAuthenticated) {
      if (authState.isActivated) {
        context.go('/dashboard');
      } else {
        context.go('/activation');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon container with animation
              _buildAnimatedLogo(),
              const SizedBox(height: 32),

              // App Name with slide-up animation
              _buildAnimatedAppName(),

              const SizedBox(height: 8),

              // Tagline with fade animation
              _buildAnimatedTagline(),

              const SizedBox(height: 64),

              // Loading indicator with delayed fade
              _buildAnimatedLoadingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the animated logo container.
  ///
  /// The logo fades in and scales from 80% to 100% with an
  /// ease-out-back curve for a subtle bounce effect.
  Widget _buildAnimatedLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(
        Icons.admin_panel_settings,
        size: 64,
        color: AppColors.primary,
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Builds the animated app name text.
  ///
  /// Fades in and slides up with a 300ms delay after the logo.
  Widget _buildAnimatedAppName() {
    return Text(
      AppConstants.appName,
      style: AppTypography.headlineLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    )
        .animate(delay: 300.ms)
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.3, end: 0);
  }

  /// Builds the animated tagline text.
  ///
  /// Simple fade in with 500ms delay for staggered appearance.
  Widget _buildAnimatedTagline() {
    return Text(
      AppConstants.tagline,
      style: AppTypography.bodyMedium.copyWith(
        color: Colors.white.withValues(alpha: 0.8),
      ),
    )
        .animate(delay: 500.ms)
        .fadeIn(duration: 500.ms);
  }

  /// Builds the animated loading indicator.
  ///
  /// Fades in with 700ms delay, appearing after the branding
  /// is fully visible to indicate ongoing background activity.
  Widget _buildAnimatedLoadingIndicator() {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        color: Colors.white.withValues(alpha: 0.8),
      ),
    )
        .animate(delay: 700.ms)
        .fadeIn(duration: 300.ms);
  }
}

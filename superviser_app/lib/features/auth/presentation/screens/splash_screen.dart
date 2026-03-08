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
/// - Logo: Spring scale-in animation (~800ms)
/// - App name: Shimmer/fade effect
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
import '../../../../core/storage/token_storage.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/auth_provider.dart';

/// {@macro splash_screen}
class SplashScreen extends ConsumerStatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

/// State for [SplashScreen] managing navigation timing.
class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    // Spring scale-in animation for the logo (~800ms)
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );
    _logoController.forward();

    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  /// Initiates navigation after the splash duration.
  ///
  /// Waits for [AppConstants.splashDuration], then checks auth state.
  /// If auth is still loading, polls until complete or timeout.
  Future<void> _navigateAfterDelay() async {
    // Wait for splash duration
    await Future.delayed(AppConstants.splashDuration);

    if (!mounted) return;

    // Check if already has tokens
    final hasTokens = await TokenStorage.hasTokens();
    if (hasTokens) {
      // Check auth state and navigate accordingly
      final authState = ref.read(authProvider);
      if (authState.isLoading) {
        await _waitForAuth();
      }
      _navigate();
      return;
    }

    if (!mounted) return;
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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: MeshGradientBackground(
        position: MeshPosition.center,
        colors: const [
          AppColors.meshAmber,
          AppColors.meshGold,
          AppColors.meshOrange,
          AppColors.meshPeach,
        ],
        opacity: 0.7,
        animated: true,
        animationDuration: const Duration(seconds: 20),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with spring scale-in animation
                _buildAnimatedLogo(),
                const SizedBox(height: 32),

                // App name with shimmer/fade effect
                _buildShimmerAppName(),

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
      ),
    );
  }

  /// Builds the animated logo container with spring scale-in.
  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScale.value,
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.admin_panel_settings,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Builds the app name with a shimmer/fade effect.
  Widget _buildShimmerAppName() {
    return Text(
      AppConstants.appName,
      style: AppTypography.headlineLarge.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .shimmer(
          duration: 1500.ms,
          delay: 600.ms,
          color: AppColors.accent.withValues(alpha: 0.4),
        );
  }

  /// Builds the animated tagline text.
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

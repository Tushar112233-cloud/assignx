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
import '../../shared/widgets/mesh_gradient_background.dart';

/// Splash screen with mesh gradient background and animated branding.
///
/// This is the entry point of the application, displaying the DOER branding
/// with a premium teal/cyan mesh gradient background and smooth entrance
/// animations while checking authentication state and determining the
/// appropriate navigation destination.
///
/// ## Navigation
/// - Entry: App launch (initial route)
/// - Authenticated + Activated: Navigates to [DashboardScreen]
/// - Authenticated + Has Profile: Navigates to [ActivationGateScreen]
/// - Authenticated + No Profile: Navigates to [ProfileSetupScreen]
/// - Unauthenticated: Navigates to [OnboardingScreen]
///
/// ## Features
/// - Full-screen animated mesh gradient background (teal/cyan)
/// - Logo scale-in with spring curve animation (~800ms)
/// - Brand text shimmer/fade effect with staggered delay
/// - Smooth fade-out transition to next screen
/// - Automatic auth state resolution with retry logic
///
/// ## Animation Sequence
/// 1. Mesh gradient background breathes continuously
/// 2. Logo scales in with spring curve (0-800ms)
/// 3. App name fades in with shimmer (400-1200ms)
/// 4. Tagline fades in (600-1200ms)
/// 5. Footer fades in (900-1500ms)
/// 6. Navigation occurs after 2500ms minimum with fade-out
///
/// See also:
/// - [MeshGradientBackground] for the gradient background widget
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
/// Manages logo scale animation, brand text shimmer, fade-out transition,
/// and automatic navigation after the splash animation completes.
class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  /// Controls the logo scale-in animation with spring curve.
  late final AnimationController _logoController;

  /// Animation for the logo scale (0.0 -> 1.0).
  late final Animation<double> _logoScale;

  /// Controls the shimmer sweep on the brand name text.
  late final AnimationController _shimmerController;

  /// Controls the fade-out transition before navigation.
  late final AnimationController _fadeOutController;

  /// Animation for the overall screen fade-out (1.0 -> 0.0).
  late final Animation<double> _fadeOutOpacity;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToNextScreen();
  }

  /// Sets up all animation controllers and their curves.
  void _initAnimations() {
    // Logo scale-in: spring curve over ~800ms
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Shimmer sweep on brand text: repeating cycle
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Fade-out before navigation
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeOutOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeInOut),
    );

    // Stagger the animation start
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _shimmerController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _shimmerController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  /// Determines and executes navigation to the appropriate screen.
  ///
  /// Waits for a minimum of 2500ms to allow animations to complete,
  /// then checks the authentication state. Includes retry logic
  /// (up to 10 attempts at 200ms intervals) to handle cases where
  /// the auth state is still being resolved.
  ///
  /// A smooth fade-out transition plays before the actual navigation
  /// to create a premium exit experience.
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

      // Play fade-out then navigate
      await _fadeOutController.forward();
      if (!mounted) return;
      _navigateBasedOnAuth(authState);
      return;
    }

    // No tokens — fade out then go to onboarding
    if (!mounted) return;
    await _fadeOutController.forward();
    if (!mounted) return;
    context.go(RouteNames.onboarding);
  }

  /// Routes to the appropriate screen based on authentication state.
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

  /// Builds the splash screen UI with mesh gradient and animated branding.
  ///
  /// Layout structure:
  /// - Full-screen animated mesh gradient background (teal/cyan)
  /// - Centered column with spring-animated logo, shimmer brand text, tagline
  /// - Footer with "Powered by DoLancer" text
  /// - Fade-out wrapper for smooth exit transition
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: AnimatedBuilder(
        animation: _fadeOutOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOutOpacity.value,
            child: child,
          );
        },
        child: MeshGradientBackground(
          position: MeshPosition.center,
          colors: const [
            AppColors.meshTeal,
            AppColors.meshCyan,
            AppColors.meshMint,
            AppColors.meshLavender,
          ],
          opacity: 0.8,
          animated: true,
          animationDuration: const Duration(seconds: 15),
          child: Container(
            color: AppColors.primary,
            child: SafeArea(
              child: Column(
                children: [
                  const Spacer(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with spring scale-in animation
                        ScaleTransition(
                          scale: _logoScale,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: AppSpacing.borderRadiusLg,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.15),
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
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        // Brand name with shimmer/fade effect
                        AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: const [
                                    Colors.white,
                                    AppColors.accent,
                                    Colors.white,
                                  ],
                                  stops: [
                                    (_shimmerController.value - 0.3)
                                        .clamp(0.0, 1.0),
                                    _shimmerController.value,
                                    (_shimmerController.value + 0.3)
                                        .clamp(0.0, 1.0),
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcIn,
                              child: child,
                            );
                          },
                          child: Text(
                            'DoLancer'.tr(context),
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        )
                            .animate(delay: 400.ms)
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.3, end: 0),
                        const SizedBox(height: AppSpacing.sm),
                        // Tagline
                        Text(
                          'Your Skills, Your Earnings'.tr(context),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.75),
                            letterSpacing: 1,
                          ),
                        )
                            .animate(delay: 600.ms)
                            .fadeIn(duration: 600.ms),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Powered by footer
                  Text(
                    'Powered by DoLancer'.tr(context),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  )
                      .animate(delay: 900.ms)
                      .fadeIn(duration: 600.ms),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

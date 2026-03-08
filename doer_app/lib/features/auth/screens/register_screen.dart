import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../core/translation/translation_extensions.dart';

/// Registration screen with Google OAuth only.
///
/// Provides a streamlined registration flow using Google Sign-In,
/// with links to Terms of Service and Privacy Policy.
///
/// ## Navigation
/// - Entry: From [OnboardingScreen] via "Get Started" or from [LoginScreen]
/// - Success + Activated: Navigates to [DashboardScreen] (returning user)
/// - Success + Has Profile: Navigates to [ActivationGateScreen] (returning user)
/// - Success + New User: Navigates to [ProfileSetupScreen]
/// - Login: Navigates to [LoginScreen] via "Sign In" link
/// - Back: Returns to [OnboardingScreen]
///
/// ## Features
/// - Google OAuth sign-in integration
/// - Terms of Service link (tappable)
/// - Privacy Policy link (tappable)
/// - Loading state during authentication
/// - Error feedback via SnackBar
/// - Automatic detection of returning users
///
/// ## Legal Links
/// Uses [TapGestureRecognizer] for handling taps on Terms and Privacy links
/// within the rich text widget.
///
/// See also:
/// - [LoginScreen] for email/password authentication
/// - [AuthProvider] for authentication state management
/// - [ProfileSetupScreen] for new user onboarding
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// State class for [RegisterScreen].
///
/// Manages loading state and gesture recognizers for legal links.
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// Whether a sign-in request is currently in progress.
  bool _isLoading = false;

  /// Gesture recognizer for Terms of Service link.
  late final TapGestureRecognizer _termsRecognizer;

  /// Gesture recognizer for Privacy Policy link.
  late final TapGestureRecognizer _privacyRecognizer;

  /// Initializes gesture recognizers for legal links.
  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()..onTap = _openTermsOfService;
    _privacyRecognizer = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
  }

  /// Disposes of gesture recognizers to prevent memory leaks.
  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  /// Opens the Terms of Service page.
  ///
  /// TODO: Implement URL launcher to open ToS webpage.
  void _openTermsOfService() {
    // TODO: Implement Terms of Service URL launch
  }

  /// Opens the Privacy Policy page.
  ///
  /// TODO: Implement URL launcher to open Privacy Policy webpage.
  void _openPrivacyPolicy() {
    // TODO: Implement Privacy Policy URL launch
  }

  /// Handles the Google Sign-In button press.
  ///
  /// Initiates Google OAuth flow via [AuthProvider]. On success,
  /// determines if the user is new or returning and navigates
  /// to the appropriate screen:
  /// - Activated users go to Dashboard
  /// - Users with profiles go to Activation Gate
  /// - New users go to Profile Setup
  ///
  /// Displays error feedback via SnackBar on failure.
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        // Wait briefly for auth state to update
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;

        // Check if user already has a profile (returning user)
        final user = ref.read(currentUserProvider);
        if (user != null && user.isActivated) {
          context.go(RouteNames.dashboard);
        } else if (user != null && user.hasDoerProfile) {
          context.go(RouteNames.activationGate);
        } else {
          context.go(RouteNames.profileSetup);
        }
      } else {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Sign up failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'.tr(context)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Builds the registration screen UI.
  ///
  /// Layout structure:
  /// - MeshGradientBackground with topRight position
  /// - Back navigation button
  /// - Header with "Join as a Doer" title and subtitle
  /// - GlassContainer wrapping the Google Sign-In button and legal text
  /// - Sign In link for existing users
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        child: SafeArea(
          child: Column(
            children: [
              // Custom back button row
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                  onPressed: () => context.go(RouteNames.onboarding),
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: AppSpacing.paddingLg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(flex: 1),

                      // Brand header
                      const Text(
                        'Join as a Doer',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Start your journey with DOER today'.tr(context),
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Glass form container
                      GlassContainer(
                        blur: 20,
                        opacity: 0.85,
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        enableHoverEffect: false,
                        child: Column(
                          children: [
                            // Google Sign In Button - secondary (glass) variant
                            AppButton(
                              text: 'Continue with Google'.tr(context),
                              icon: Icons.g_mobiledata,
                              variant: AppButtonVariant.secondary,
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              isLoading: _isLoading,
                              isFullWidth: true,
                              size: AppButtonSize.large,
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Terms text
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(text: 'By signing up, you agree to our '.tr(context)),
                                  TextSpan(
                                    text: 'Terms of Service'.tr(context),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: _termsRecognizer,
                                  ),
                                  TextSpan(text: ' and '.tr(context)),
                                  TextSpan(
                                    text: 'Privacy Policy'.tr(context),
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    recognizer: _privacyRecognizer,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Sign in link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? '.tr(context),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(RouteNames.login),
                            child: Text(
                              'Sign In'.tr(context),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

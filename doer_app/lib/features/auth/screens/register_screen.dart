import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';

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
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Builds the registration screen UI.
  ///
  /// Layout structure:
  /// - AppBar with back navigation to onboarding
  /// - Header with "Create Account" title and subtitle
  /// - Google Sign-In button with loading state
  /// - Terms of Service and Privacy Policy legal text
  /// - Sign In link for existing users
  ///
  /// Uses flexible spacers for vertical centering.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.onboarding),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 1),

              // Header
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Start your journey with DOER today',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(flex: 2),

              // Google Sign In Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: AppColors.surface,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.google.com/favicon.ico',
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata, size: 24),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Terms text
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    children: [
                      const TextSpan(text: 'By signing up, you agree to our '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: _termsRecognizer,
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                        recognizer: _privacyRecognizer,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Sign in link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.login),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
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
    );
  }
}

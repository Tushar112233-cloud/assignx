import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

/// Login screen for existing users.
///
/// Provides email/password authentication with form validation,
/// error handling, and navigation to registration for new users.
///
/// ## Navigation
/// - Entry: From [OnboardingScreen] via "Sign In" or when session expires
/// - Success + Activated: Navigates to [DashboardScreen]
/// - Success + Has Profile: Navigates to [ActivationGateScreen]
/// - Success + No Profile: Navigates to [ProfileSetupScreen]
/// - Register: Navigates to [RegisterScreen] via "Sign Up" link
/// - Back: Returns to [OnboardingScreen]
///
/// ## Features
/// - Email validation using [Validators.email]
/// - Password field with obscured text
/// - Forgot password link (placeholder)
/// - Google OAuth sign-in option (placeholder)
/// - Loading state during authentication
/// - Error feedback via SnackBar
///
/// ## Form Fields
/// - Email: Required, validated for email format
/// - Password: Required
///
/// See also:
/// - [RegisterScreen] for new user registration
/// - [AuthProvider] for authentication state management
/// - [Validators] for form validation utilities
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// State class for [LoginScreen].
///
/// Manages form state, text controllers, and loading state
/// for the login process.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Form key for validating the login form.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email input field.
  final _emailController = TextEditingController();

  /// Controller for the password input field.
  final _passwordController = TextEditingController();

  /// Whether a login request is currently in progress.
  bool _isLoading = false;

  /// Whether to show magic link mode instead of password.
  bool _useMagicLink = false;

  /// Whether magic link was sent successfully.
  bool _magicLinkSent = false;

  /// Disposes of text controllers to prevent memory leaks.
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the login form submission.
  ///
  /// Validates the form, then attempts to sign in using the
  /// [AuthProvider]. On success, router automatically navigates
  /// based on user activation status. On failure, displays an
  /// error message via SnackBar.
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!success) {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Login failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      // Router will automatically navigate based on auth state
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

  /// Handles Google OAuth sign-in.
  ///
  /// Initiates the native Google Sign-In flow. If successful,
  /// router automatically navigates based on activation status.
  /// Cancellation is handled silently; only errors show notifications.
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!success) {
        final errorMessage = ref.read(authProvider).errorMessage;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
      // Router will automatically navigate based on auth state
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google sign in failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Handles magic link sign-in.
  ///
  /// Sends a magic link to the user's email address for passwordless
  /// authentication. Shows a confirmation message when successful.
  Future<void> _handleMagicLink() async {
    // Validate email only
    final email = _emailController.text.trim();
    if (email.isEmpty || !Validators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).signInWithMagicLink(
            email: email,
          );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _magicLinkSent = success;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Magic link sent to $email. Check your inbox!'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 5),
          ),
        );
      } else {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to send magic link'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send magic link: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Builds the login screen UI.
  ///
  /// Layout structure:
  /// - AppBar with back navigation to onboarding
  /// - Header with welcome message
  /// - Email input field with validation
  /// - Password input field with validation
  /// - Forgot password link
  /// - Sign In button with loading state
  /// - Divider with "OR" text
  /// - Google OAuth button (placeholder)
  /// - Sign Up link for new users
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
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Header
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Sign in to continue your earning journey',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Email field
                AppTextField(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Show password field only if not using magic link
                if (!_useMagicLink) ...[
                  // Password field
                  AppTextField(
                    label: 'Password',
                    hint: 'Enter your password',
                    controller: _passwordController,
                    obscureText: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (value) => Validators.required(value, fieldName: 'Password'),
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go(RouteNames.forgotPassword),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Login button
                  AppButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: _isLoading,
                    isFullWidth: true,
                    size: AppButtonSize.large,
                  ),
                ] else ...[
                  // Magic link mode
                  const SizedBox(height: AppSpacing.lg),

                  if (_magicLinkSent) ...[
                    // Success message
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Magic link sent! Check your email inbox.',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      text: 'Resend Magic Link',
                      onPressed: _handleMagicLink,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      variant: AppButtonVariant.outline,
                    ),
                  ] else ...[
                    AppButton(
                      text: 'Send Magic Link',
                      onPressed: _handleMagicLink,
                      isLoading: _isLoading,
                      isFullWidth: true,
                      size: AppButtonSize.large,
                    ),
                  ],
                ],

                const SizedBox(height: AppSpacing.md),

                // Toggle between password and magic link
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _useMagicLink = !_useMagicLink;
                        _magicLinkSent = false;
                      });
                    },
                    child: Text(
                      _useMagicLink
                          ? 'Sign in with password instead'
                          : 'Sign in with magic link (passwordless)',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border)),
                    Padding(
                      padding: AppSpacing.paddingHorizontalMd,
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border)),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Google Sign In button
                AppButton(
                  text: 'Continue with Google',
                  onPressed: _handleGoogleSignIn,
                  variant: AppButtonVariant.outline,
                  isFullWidth: true,
                  icon: Icons.g_mobiledata,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go(RouteNames.register),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

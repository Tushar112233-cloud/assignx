/// {@template login_screen}
/// Login and password reset screens for the Superviser App.
///
/// This file contains the main authentication entry points for returning
/// users, including email/password login and password recovery functionality.
///
/// ## Screens
/// - [LoginScreen]: Main login form with email, password, and Google sign-in
/// - [ForgotPasswordScreen]: Password reset request form
///
/// ## Features
/// - Email/password authentication
/// - Google OAuth sign-in
/// - Form validation with real-time feedback
/// - Loading states during authentication
/// - Error handling with snackbar notifications
/// - Navigation to registration and dashboard
///
/// ## Navigation
/// - Success with activated user -> Dashboard
/// - Success with inactive user -> Activation screen
/// - Forgot password link -> Password reset screen
/// - Register link -> Registration screen
///
/// ## Usage
/// These screens are typically registered as routes in GoRouter:
/// ```dart
/// GoRoute(
///   path: '/login',
///   builder: (context, state) => const LoginScreen(),
/// ),
/// GoRoute(
///   path: '/forgot-password',
///   builder: (context, state) => const ForgotPasswordScreen(),
/// ),
/// ```
///
/// ## See Also
/// - [RegisterScreen] for new user registration
/// - [AuthProvider] for authentication state management
/// - [AuthRepository] for authentication operations
/// {@endtemplate}
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../providers/auth_provider.dart';

/// {@template login_screen_widget}
/// Main login screen for supervisor authentication.
///
/// Provides a complete login experience with:
/// - Email and password input fields with validation
/// - Google OAuth sign-in option
/// - Forgot password link
/// - Registration link for new users
///
/// ## State Management
/// Uses Riverpod's [ConsumerStatefulWidget] to access [authProvider]
/// for authentication operations and state monitoring.
///
/// ## Form Validation
/// All inputs are validated before submission using [Validators].
/// The form prevents submission until all fields pass validation.
///
/// ## Navigation Flow
/// After successful authentication:
/// - Activated supervisors -> `/dashboard`
/// - Non-activated users -> `/activation`
///
/// ## Example
/// ```dart
/// // In router configuration
/// GoRoute(
///   path: '/login',
///   builder: (context, state) => const LoginScreen(),
/// ),
/// ```
/// {@endtemplate}
class LoginScreen extends ConsumerStatefulWidget {
  /// Creates a [LoginScreen].
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// State for [LoginScreen] that manages form controllers and focus nodes.
class _LoginScreenState extends ConsumerState<LoginScreen> {
  /// Form key for validation state management.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email input field.
  final _emailController = TextEditingController();

  /// Controller for the password input field.
  final _passwordController = TextEditingController();

  /// Focus node for the email field, used for keyboard navigation.
  final _emailFocusNode = FocusNode();

  /// Focus node for the password field, used for form submission.
  final _passwordFocusNode = FocusNode();

  /// Whether magic link mode is active instead of password mode.
  bool _useMagicLink = false;

  /// Whether magic link was sent successfully.
  bool _magicLinkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Handles the login form submission.
  ///
  /// Validates the form, clears existing errors, and attempts
  /// authentication via [AuthNotifier.signIn]. On success,
  /// navigates to the appropriate screen based on activation status.
  Future<void> _handleLogin() async {
    // Clear any existing error
    ref.read(authProvider.notifier).clearError();

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Unfocus to hide keyboard
    context.unfocus();

    // Attempt login
    final success = await ref.read(authProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (!success) {
      // Show error snackbar
      final error = ref.read(authProvider).error;
      if (error != null) {
        context.showErrorSnackBar(error);
      }
    }
    // Router will automatically navigate based on auth state
  }

  /// Handles Google OAuth sign-in.
  ///
  /// Initiates the native Google Sign-In flow. If successful,
  /// navigates based on the user's activation status. Cancellation
  /// is handled silently; only errors show snackbar notifications.
  Future<void> _handleGoogleSignIn() async {
    // Clear any existing error
    ref.read(authProvider.notifier).clearError();

    // Attempt Google sign-in
    final success = await ref.read(authProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    if (!success) {
      // Show error snackbar if there's an error (not just cancelled)
      final error = ref.read(authProvider).error;
      if (error != null) {
        context.showErrorSnackBar(error);
      }
    }
    // Router will automatically navigate based on auth state
  }

  /// Handles magic link sign-in.
  ///
  /// Sends a magic link to the user's email for passwordless authentication.
  /// Shows a success state when the email is sent successfully.
  Future<void> _handleMagicLink() async {
    // Validate email only
    final email = _emailController.text.trim();
    if (email.isEmpty || Validators.email(email) != null) {
      context.showErrorSnackBar('Please enter a valid email address');
      return;
    }

    // Clear any existing error
    ref.read(authProvider.notifier).clearError();

    // Unfocus to hide keyboard
    context.unfocus();

    // Send magic link
    final success = await ref.read(authProvider.notifier).signInWithMagicLink(
          email: email,
        );

    if (!mounted) return;

    if (success) {
      setState(() => _magicLinkSent = true);
      context.showSuccessSnackBar('Magic link sent to $email. Check your inbox!');
    } else {
      final error = ref.read(authProvider).error;
      if (error != null) {
        context.showErrorSnackBar(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Logo
                _buildLogo(),

                const SizedBox(height: 48),

                // Welcome text
                _buildWelcomeText(),

                const SizedBox(height: 32),

                // Email field
                EmailTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  validator: Validators.email,
                  textInputAction: _useMagicLink ? TextInputAction.done : TextInputAction.next,
                  onSubmitted: (_) => _useMagicLink
                      ? _handleMagicLink()
                      : _passwordFocusNode.requestFocus(),
                ),

                const SizedBox(height: 16),

                // Show password field only if not using magic link
                if (!_useMagicLink) ...[
                  // Password field
                  PasswordTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),

                  const SizedBox(height: 8),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TertiaryButton(
                      text: 'Forgot Password?',
                      onPressed: () => context.push('/forgot-password'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  PrimaryButton(
                    text: 'Log In',
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                  ),
                ] else ...[
                  // Magic link mode
                  if (_magicLinkSent) ...[
                    // Success state
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Magic link sent! Check your email inbox.',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: isLoading ? null : _handleMagicLink,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Resend Magic Link',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 8),
                    // Send magic link button
                    PrimaryButton(
                      text: 'Send Magic Link',
                      onPressed: _handleMagicLink,
                      isLoading: isLoading,
                    ),
                  ],
                ],

                const SizedBox(height: 16),

                // Toggle between password and magic link
                Center(
                  child: TertiaryButton(
                    text: _useMagicLink
                        ? 'Sign in with password instead'
                        : 'Sign in with magic link (passwordless)',
                    onPressed: () {
                      setState(() {
                        _useMagicLink = !_useMagicLink;
                        _magicLinkSent = false;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Divider with "Or"
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.textSecondaryLight.withValues(alpha: 0.3))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.textSecondaryLight.withValues(alpha: 0.3))),
                  ],
                ),

                const SizedBox(height: 24),

                // Google Sign-In button
                _GoogleSignInButton(
                  onPressed: _handleGoogleSignIn,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // Register link
                _buildRegisterLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the application logo container.
  ///
  /// Displays a branded logo icon in a rounded container
  /// using the primary color scheme.
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.admin_panel_settings,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds the welcome text header.
  ///
  /// Displays a headline and subtitle welcoming returning users.
  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back',
          style: AppTypography.headlineLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue managing your projects',
          style: AppTypography.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the registration link row.
  ///
  /// Provides navigation to the registration screen for users
  /// who don't have an account yet.
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TertiaryButton(
          text: 'Register',
          onPressed: () => context.push('/register'),
        ),
      ],
    );
  }
}

/// {@template forgot_password_screen}
/// Password reset request screen.
///
/// Allows users to request a password reset link by providing
/// their email address. Displays success state after the email is sent.
///
/// ## Flow
/// 1. User enters their email address
/// 2. Form validates email format
/// 3. Request is sent to Supabase Auth
/// 4. Success screen displayed with confirmation
/// 5. User can navigate back to login
///
/// ## Error Handling
/// Invalid emails show validation errors inline. Server errors
/// are displayed via snackbar notifications.
/// {@endtemplate}
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Creates a [ForgotPasswordScreen].
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

/// State for [ForgotPasswordScreen] managing form and success states.
class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  /// Form key for email validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the email input field.
  final _emailController = TextEditingController();

  /// Tracks whether the reset email has been sent successfully.
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles the password reset form submission.
  ///
  /// Validates the email, sends the reset request, and updates
  /// the UI to show the success state on completion.
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    context.unfocus();

    final success = await ref
        .read(authProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      final error = ref.read(authProvider).error;
      if (error != null) {
        context.showErrorSnackBar(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _emailSent ? _buildSuccessState() : _buildForm(isLoading),
        ),
      ),
    );
  }

  /// Builds the email input form.
  ///
  /// Displays instructions and an email field for requesting
  /// the password reset link.
  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            'Forgot your password?',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          EmailTextField(
            controller: _emailController,
            validator: Validators.email,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSubmit(),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Send Reset Link',
            onPressed: _handleSubmit,
            isLoading: isLoading,
          ),
        ],
      ),
    );
  }

  /// Builds the success state after email is sent.
  ///
  /// Displays a confirmation message with the email address
  /// and a button to return to the login screen.
  Widget _buildSuccessState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 48),
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: AppColors.success,
        ),
        const SizedBox(height: 24),
        Text(
          'Check your email',
          style: AppTypography.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a password reset link to ${_emailController.text}',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        PrimaryButton(
          text: 'Back to Login',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}

/// {@template google_sign_in_button}
/// A styled button for Google OAuth sign-in.
///
/// Displays the Google brand icon alongside text, styled as an
/// outlined button to differentiate from the primary email login.
///
/// ## Properties
/// - [onPressed]: Callback when the button is tapped
/// - [isLoading]: Disables the button when true
///
/// ## Example
/// ```dart
/// _GoogleSignInButton(
///   onPressed: () => handleGoogleSignIn(),
///   isLoading: isAuthenticating,
/// )
/// ```
/// {@endtemplate}
class _GoogleSignInButton extends StatelessWidget {
  /// Creates a [_GoogleSignInButton].
  const _GoogleSignInButton({
    required this.onPressed,
    this.isLoading = false,
  });

  /// Callback invoked when the button is pressed.
  final VoidCallback onPressed;

  /// Whether a loading operation is in progress, disabling the button.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google logo (using a simple G icon)
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                'G',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Continue with Google',
            style: AppTypography.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

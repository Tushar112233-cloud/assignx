/// {@template register_screen}
/// Registration screen for new supervisor accounts.
///
/// This screen provides the entry point for new users to create an account
/// in the Superviser App, collecting essential information before the
/// full onboarding flow.
///
/// ## Overview
/// The registration screen collects:
/// - Full name
/// - Email address
/// - Password (with confirmation)
/// - Terms of service agreement
///
/// ## Features
/// - Real-time form validation
/// - Password confirmation matching
/// - Terms of service agreement checkbox
/// - Loading states during submission
/// - Error handling with snackbar notifications
///
/// ## Registration Flow
/// 1. User fills in all required fields
/// 2. User agrees to Terms of Service and Privacy Policy
/// 3. Form validates all inputs
/// 4. Account is created via Supabase Auth
/// 5. Email verification link is sent
/// 6. User is redirected to login screen
///
/// ## Post-Registration
/// After successful registration:
/// - User receives email verification link
/// - Must verify email before signing in (depending on settings)
/// - After email login, supervisor activation is required
///
/// ## Usage
/// Typically registered as a route in GoRouter:
/// ```dart
/// GoRoute(
///   path: '/register',
///   builder: (context, state) => const RegisterScreen(),
/// ),
/// ```
///
/// ## See Also
/// - [LoginScreen] for returning user authentication
/// - [AuthProvider] for registration state management
/// - [AuthRepository] for account creation operations
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

/// {@macro register_screen}
class RegisterScreen extends ConsumerStatefulWidget {
  /// Creates a [RegisterScreen].
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

/// State for [RegisterScreen] managing form controllers and checkbox state.
class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  /// Form key for coordinating field validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for the full name input field.
  final _nameController = TextEditingController();

  /// Controller for the email input field.
  final _emailController = TextEditingController();

  /// Controller for the password input field.
  final _passwordController = TextEditingController();

  /// Controller for the password confirmation input field.
  final _confirmPasswordController = TextEditingController();

  /// Focus node for the name field (first in tab order).
  final _nameFocusNode = FocusNode();

  /// Focus node for the email field.
  final _emailFocusNode = FocusNode();

  /// Focus node for the password field.
  final _passwordFocusNode = FocusNode();

  /// Focus node for the confirm password field (last in tab order).
  final _confirmPasswordFocusNode = FocusNode();

  /// Tracks whether the user has agreed to terms of service.
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Handles the registration form submission.
  ///
  /// Validates all form fields and terms agreement, then attempts
  /// to create the account via [AuthNotifier.signUp]. On success,
  /// shows a confirmation message and navigates to login.
  ///
  /// ## Validation Steps
  /// 1. Form field validation (name, email, password, confirmation)
  /// 2. Terms of service agreement check
  /// 3. Server-side validation during account creation
  Future<void> _handleRegister() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Check terms agreement
    if (!_agreedToTerms) {
      context.showErrorSnackBar('Please agree to the Terms of Service');
      return;
    }

    // Clear errors
    ref.read(authProvider.notifier).clearError();

    // Unfocus keyboard
    context.unfocus();

    // Attempt registration
    final success = await ref.read(authProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      // Show success and navigate
      context.showSuccessSnackBar(
        'Account created! Please check your email to verify.',
      );
      context.go('/login');
    } else {
      // Show error
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
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Full Name
                AppTextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outlined,
                  validator: Validators.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => _emailFocusNode.requestFocus(),
                ),

                const SizedBox(height: 16),

                // Email
                EmailTextField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  validator: Validators.email,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                ),

                const SizedBox(height: 16),

                // Password
                PasswordTextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  validator: Validators.password,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
                ),

                const SizedBox(height: 16),

                // Confirm Password
                PasswordTextField(
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  validator: (value) => Validators.confirmPassword(_passwordController.text)(value),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _handleRegister(),
                ),

                const SizedBox(height: 24),

                // Terms checkbox
                _buildTermsCheckbox(),

                const SizedBox(height: 24),

                // Register button
                PrimaryButton(
                  text: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: isLoading,
                ),

                const SizedBox(height: 24),

                // Login link
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the header section with title and subtitle.
  ///
  /// Provides context about what the registration screen does
  /// and what the user can expect after creating an account.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Join AdminX',
          style: AppTypography.headlineMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create your supervisor account to start managing projects',
          style: AppTypography.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the terms of service agreement checkbox.
  ///
  /// Contains a checkbox and tappable text that includes links to
  /// the Terms of Service and Privacy Policy. The text itself
  /// toggles the checkbox when tapped for better usability.
  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreedToTerms,
            onChanged: (value) {
              setState(() => _agreedToTerms = value ?? false);
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: AppTypography.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the login link row for existing users.
  ///
  /// Provides navigation to the login screen for users who
  /// already have an account.
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TertiaryButton(
          text: 'Log In',
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}

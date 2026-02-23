import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';

/// Forgot Password screen for initiating password reset.
///
/// Allows users to request a password reset link via email.
/// The screen provides:
/// - Email input field with validation
/// - Send reset link button
/// - Success/error feedback
/// - Back to login navigation
///
/// ## Navigation
/// - Entry: From [LoginScreen] via "Forgot Password?" button
/// - Success: Shows success message and stays on screen
/// - Back: Returns to [LoginScreen]
///
/// ## Features
/// - Email validation before submission
/// - Loading state during API call
/// - Success message with instructions
/// - Error handling with user-friendly messages
/// - Rate limiting feedback
///
/// ## State Management
/// Uses [AuthNotifier.resetPassword] to send reset email via Supabase.
///
/// See also:
/// - [LoginScreen] for sign-in functionality
/// - [AuthNotifier] for authentication operations
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

/// State class for [ForgotPasswordScreen].
///
/// Manages form state and email submission.
class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  /// Form key for validation.
  final _formKey = GlobalKey<FormState>();

  /// Controller for email input field.
  final _emailController = TextEditingController();

  /// Whether the reset email has been sent successfully.
  bool _emailSent = false;

  /// Whether a request is currently in progress.
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Validates form and sends password reset email.
  ///
  /// Shows success message on successful send, error snackbar on failure.
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
          );

      if (!mounted) return;

      if (success) {
        setState(() {
          _emailSent = true;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        final errorMessage = ref.read(authProvider).errorMessage ?? 'Failed to send reset email';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go(RouteNames.login),
        ),
        title: const Text(
          'Reset Password',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Header
              const Text(
                'Forgot your password?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Show success message or form
              if (_emailSent)
                _buildSuccessMessage()
              else
                _buildResetForm(),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the success message after email is sent.
  Widget _buildSuccessMessage() {
    return Container(
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Check your email',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'We\'ve sent a password reset link to\n${_emailController.text}',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Didn\'t receive the email? Check your spam folder or try again.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: 'Back to Login',
            onPressed: () => context.go(RouteNames.login),
            isFullWidth: true,
            size: AppButtonSize.large,
          ),
        ],
      ),
    );
  }

  /// Builds the password reset form.
  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            enabled: !_isLoading,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMd,
                borderSide: const BorderSide(color: AppColors.error, width: 1),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!Validators.isValidEmail(value.trim())) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // Send reset link button
          AppButton(
            text: 'Send Reset Link',
            onPressed: _isLoading ? null : _sendResetEmail,
            isLoading: _isLoading,
            isFullWidth: true,
            size: AppButtonSize.large,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Back to login link
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : () => context.go(RouteNames.login),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

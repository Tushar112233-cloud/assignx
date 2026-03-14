library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _otpFocusNode = FocusNode();

  bool _otpSent = false;
  String _email = '';
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _emailFocusNode.dispose();
    _otpFocusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendCooldown = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCooldown = 0);
      } else {
        if (mounted) setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    context.unfocus();

    final email = _emailController.text.trim();
    ref.read(authProvider.notifier).clearError();

    try {
      final status = await ref.read(authProvider.notifier).checkSupervisorStatus(email);
      if (!mounted) return;

      final supervisorStatus = status['status'] as String? ?? 'not_found';

      switch (supervisorStatus) {
        case 'not_found':
          context.showErrorSnackBar('No supervisor account found for this email. Please register first.'.tr(context));
          break;
        case 'pending':
          context.go('/registration/pending');
          break;
        case 'rejected':
          context.showErrorSnackBar('Your application was rejected. You may re-apply.'.tr(context));
          // Allow navigation to register for re-apply
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) context.push('/register');
          });
          break;
        case 'approved':
          await ref.read(authProvider.notifier).sendOTP(email: email, purpose: 'login');
          if (!mounted) return;
          setState(() {
            _otpSent = true;
            _email = email;
          });
          _startCooldown();
          context.showSuccessSnackBar('Verification code sent to $email'.tr(context));
          break;
        default:
          context.showErrorSnackBar('Unexpected status: $supervisorStatus');
      }
    } catch (e) {
      if (!mounted) return;
      final error = ref.read(authProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  Future<void> _handleResendOTP() async {
    if (_resendCooldown > 0) return;
    ref.read(authProvider.notifier).clearError();

    try {
      await ref.read(authProvider.notifier).sendOTP(email: _email, purpose: 'login');
      if (!mounted) return;
      _startCooldown();
      context.showSuccessSnackBar('Verification code resent'.tr(context));
    } catch (e) {
      if (!mounted) return;
      final error = ref.read(authProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      context.showErrorSnackBar('Please enter a 6-digit code'.tr(context));
      return;
    }
    context.unfocus();
    ref.read(authProvider.notifier).clearError();

    final success = await ref.read(authProvider.notifier).verifyOTP(
      email: _email,
      otp: otp,
      purpose: 'login',
    );

    if (!mounted) return;

    if (!success) {
      final error = ref.read(authProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
    // Router handles redirect on auth state change
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        colors: const [
          AppColors.meshAmber,
          AppColors.meshOrange,
          AppColors.meshPeach,
          AppColors.meshGold,
        ],
        opacity: 0.6,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  _buildLogo(),
                  const SizedBox(height: 48),
                  _buildWelcomeText(),
                  const SizedBox(height: 32),

                  // Glass container wrapping the form area
                  GlassContainer(
                    blur: 15,
                    opacity: 0.85,
                    borderRadius: BorderRadius.circular(20),
                    borderColor: Colors.white.withValues(alpha: 0.3),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_otpSent) ...[
                          EmailTextField(
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            validator: Validators.email,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleContinue(),
                          ),
                          const SizedBox(height: 24),
                          PrimaryButton(
                            text: 'Continue'.tr(context),
                            onPressed: _handleContinue,
                            isLoading: isLoading,
                          ),
                        ] else ...[
                          // Show email being verified
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.email_outlined, color: AppColors.accent, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _email,
                                    style: AppTypography.bodyMedium.copyWith(color: AppColors.accent),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    _otpSent = false;
                                    _otpController.clear();
                                    _cooldownTimer?.cancel();
                                    _resendCooldown = 0;
                                  }),
                                  child: Icon(Icons.edit, size: 18, color: AppColors.accent),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Text(
                            'Enter the 6-digit code sent to your email'.tr(context),
                            style: AppTypography.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),

                          AppTextField(
                            controller: _otpController,
                            focusNode: _otpFocusNode,
                            label: 'Verification Code'.tr(context),
                            hint: '000000',
                            prefixIcon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _handleVerify(),
                          ),
                          const SizedBox(height: 16),

                          // Resend row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Didn't receive the code? ".tr(context),
                                style: AppTypography.bodySmall.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (_resendCooldown > 0)
                                Text(
                                  'Resend in ${_resendCooldown}s',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                )
                              else
                                TertiaryButton(
                                  text: 'Resend'.tr(context),
                                  onPressed: _handleResendOTP,
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          PrimaryButton(
                            text: 'Verify'.tr(context),
                            onPressed: _handleVerify,
                            isLoading: isLoading,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: SvgPicture.asset(
        'assets/images/logo.svg',
        width: 80,
        height: 80,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome Back'.tr(context),
          style: AppTypography.headlineLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to continue managing your projects'.tr(context),
          style: AppTypography.bodyLarge.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ".tr(context),
          style: AppTypography.bodyMedium.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TertiaryButton(
          text: 'Register'.tr(context),
          onPressed: () => context.push('/register'),
        ),
      ],
    );
  }
}

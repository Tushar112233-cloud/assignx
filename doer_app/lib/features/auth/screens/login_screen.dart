import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/translation/translation_extensions.dart';

/// OTP-based login screen for doers.
///
/// Adapted from the doer-web split-panel design:
/// - Top: Dark gradient branding section with logo, headline, and stats
/// - Bottom: White card with email input -> 6-digit OTP input flow
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _otpSent = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  /// Returns the combined OTP string from all 6 digit controllers.
  String get _otpValue => _otpControllers.map((c) => c.text).join();

  void _startCooldown() {
    setState(() => _resendCooldown = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !Validators.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address'.tr(context)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref.read(authProvider.notifier).sendOtp(email);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        setState(() => _otpSent = true);
        _startCooldown();
        // Focus first OTP field after transition
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _otpFocusNodes[0].requestFocus();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP sent to $email'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Failed to send OTP'),
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

  Future<void> _handleVerifyOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpValue;

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter the complete 6-digit code'.tr(context)),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
          await ref.read(authProvider.notifier).verifyOtp(email, otp);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        final authState = ref.read(authProvider);
        _navigateBasedOnAuth(authState);
      } else {
        final errorMessage = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage ?? 'Invalid OTP. Please try again.'),
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

  void _navigateBasedOnAuth(AuthState authState) {
    if (!mounted) return;
    final user = authState.user;
    if (user != null && user.isActivated) {
      context.go(RouteNames.dashboard);
    } else if (user != null && user.hasDoerProfile) {
      context.go(RouteNames.activationGate);
    } else {
      context.go(RouteNames.profileSetup);
    }
  }

  void _resetToEmail() {
    setState(() {
      _otpSent = false;
      for (final c in _otpControllers) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // -- Top branding section --
          _buildBrandingSection(context),

          // -- Bottom form section --
          Expanded(
            child: Container(
              color: Colors.white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: _buildFormSection(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dark gradient header with D logo, brand name, headline, and stats bar.
  Widget _buildBrandingSection(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: screenHeight * 0.35,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topPadding + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B0F1A),
            Color(0xFF111631),
            Color(0xFF1A1F3A),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo badge + brand name
          Row(
            children: [
              SvgPicture.asset(
                'assets/images/logo.svg',
                width: 40,
                height: 40,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Dolancer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Headline with accent-colored "earnings"
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.25,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(text: 'Turn your skills\ninto real '),
                TextSpan(
                  text: 'earnings',
                  style: TextStyle(color: AppColors.primary),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('2,400+', 'Active Doers'),
                _buildStatDivider(),
                _buildStatItem('48h', 'Avg. Payout'),
                _buildStatDivider(),
                _buildStatItem('4.9', 'Avg. Rating'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.65),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 28,
      color: Colors.white.withValues(alpha: 0.12),
    );
  }

  /// White form section: title, subtitle, email/OTP inputs, actions.
  Widget _buildFormSection(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'Welcome back'.tr(context),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Subtitle
          Text(
            _otpSent
                ? 'Enter the 6-digit code sent to ${_emailController.text.trim()}'
                : 'Sign in with your email using OTP'.tr(context),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          if (!_otpSent) ...[
            // -- Email input --
            _buildEmailField(),

            const SizedBox(height: AppSpacing.lg),

            // Continue button
            _buildContinueButton(),
          ] else ...[
            // -- OTP digit boxes --
            _buildOtpDigitBoxes(),

            const SizedBox(height: AppSpacing.md),

            // Resend row
            _buildResendRow(),

            const SizedBox(height: AppSpacing.lg),

            // Verify button
            _buildVerifyButton(),

            const SizedBox(height: AppSpacing.md),

            // Change email link
            Center(
              child: TextButton(
                onPressed: _resetToEmail,
                child: const Text(
                  'Use a different email',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),

          // -- "or" divider --
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.borderLight)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.borderLight)),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // -- Sign up link --
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Don't have an account? ".tr(context),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.go(RouteNames.register),
                  child: const Text(
                    'Apply to join',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Email text field with mail icon and placeholder.
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSendOtp(),
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'you@example.com',
            hintStyle: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.mail_outline_rounded,
              size: 20,
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          validator: Validators.email,
        ),
      ],
    );
  }

  /// Continue button with arrow icon (sends OTP).
  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
      ),
    );
  }

  /// Six individual OTP digit input boxes in a row.
  Widget _buildOtpDigitBoxes() {
    final screenWidth = MediaQuery.of(context).size.width;
    final otpBoxWidth = (screenWidth - AppSpacing.lg * 2 - 5 * AppSpacing.sm) / 6;
    final clampedWidth = otpBoxWidth.clamp(40.0, 56.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: clampedWidth,
          height: clampedWidth * 1.15,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              }
              // Auto-verify when all 6 digits are entered
              if (_otpValue.length == 6) {
                _handleVerifyOtp();
              }
            },
            // Backspace handling is done via onChanged
          ),
        );
      }),
    );
  }

  /// Resend OTP row with countdown timer.
  Widget _buildResendRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
        GestureDetector(
          onTap: _resendCooldown > 0 ? null : _handleSendOtp,
          child: Text(
            _resendCooldown > 0
                ? 'Resend in ${_resendCooldown}s'
                : 'Resend',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _resendCooldown > 0
                  ? AppColors.textTertiary
                  : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Verify & Sign In button.
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleVerifyOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Verify & Sign In',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

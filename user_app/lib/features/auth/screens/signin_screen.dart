import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../core/utils/email_validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

/// Sign-up screen with OTP-based account creation.
///
/// Two-state flow:
/// 1. Email entry -> sends OTP with purpose 'signup'
/// 2. OTP verification -> navigates to role selection on success
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  // Flow state
  bool _showOtpEntry = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Email state
  final _emailController = TextEditingController();

  // OTP state
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Resend cooldown
  Timer? _resendTimer;
  int _resendCooldown = 0;

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  String get _email => _emailController.text.trim().toLowerCase();

  String get _otp => _otpControllers.map((c) => c.text).join();

  bool get _isEmailValid {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(_email);
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCooldown = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          timer.cancel();
        }
      });
    });
  }

  void _clearOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
  }

  Future<void> _submitEmail() async {
    if (_email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address');
      return;
    }
    if (!_isEmailValid) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    // Enforce .edu email for student signups.
    final userType = GoRouterState.of(context).uri.queryParameters['type'];
    if (userType == 'student' && !EmailValidators.isCollegeEmail(_email)) {
      setState(() => _errorMessage =
          'Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).sendOTP(
            email: _email,
            purpose: 'signup',
            role: userType ?? 'user',
          );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _showOtpEntry = true;
        });
        _startResendCooldown();
        // Focus on first OTP field after transition
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) _otpFocusNodes[0].requestFocus();
        });
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('already exists')) {
          setState(() => _isLoading = false);
          _showAccountExistsSnackBar();
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
          });
        }
      }
    }
  }

  void _showAccountExistsSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account already exists'),
        action: SnackBarAction(
          label: 'Log In',
          onPressed: () => context.go(RouteNames.login),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = _otp;
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userType = GoRouterState.of(context).uri.queryParameters['type'];
      final success = await ref.read(authStateProvider.notifier).verifyOtp(
            email: _email,
            token: otp,
            purpose: 'signup',
            role: userType ?? 'user',
          );

      if (mounted) {
        if (success) {
          // Check if user needs onboarding
          final profile = ref.read(currentProfileProvider);
          final needsOnboarding = profile == null ||
              profile.fullName == null ||
              profile.fullName!.isEmpty ||
              !profile.onboardingCompleted;
          if (needsOnboarding) {
            // Route to the right profile screen based on user type
            final userType = GoRouterState.of(context).uri.queryParameters['type'];
            if (userType == 'student') {
              context.go(RouteNames.studentProfile);
            } else if (userType == 'professional' || userType == 'business') {
              context.go(RouteNames.professionalProfile);
            } else {
              context.go(RouteNames.profileCompletion);
            }
          } else {
            context.go(RouteNames.home);
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid code. Please try again.';
          });
          _clearOtp();
          _otpFocusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
        _clearOtp();
        _otpFocusNodes[0].requestFocus();
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userType = GoRouterState.of(context).uri.queryParameters['type'];
      await ref.read(authStateProvider.notifier).sendOTP(
            email: _email,
            purpose: 'signup',
            role: userType ?? 'user',
          );
      if (mounted) {
        setState(() => _isLoading = false);
        _startResendCooldown();
        _clearOtp();
        _otpFocusNodes[0].requestFocus();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  void _goBackToEmail() {
    setState(() {
      _showOtpEntry = false;
      _errorMessage = null;
      _clearOtp();
    });
    _resendTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final userType = GoRouterState.of(context).uri.queryParameters['type'];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LoadingOverlay(
          isLoading: _isLoading,
          message: _showOtpEntry ? 'Verifying...' : 'Sending code...',
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App name header
                _buildHeader(),

                // Icon illustration — takes available space
                Expanded(
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // Bottom content pinned to bottom
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: _showOtpEntry
                      ? _OtpEntrySection(
                          key: const ValueKey('otp'),
                          email: _email,
                          otpControllers: _otpControllers,
                          otpFocusNodes: _otpFocusNodes,
                          errorMessage: _errorMessage,
                          resendCooldown: _resendCooldown,
                          onVerify: _verifyOtp,
                          onResend: _resendOtp,
                          onBack: _goBackToEmail,
                          onErrorClear: () {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        )
                      : _EmailEntrySection(
                          key: const ValueKey('email'),
                          emailController: _emailController,
                          errorMessage: _errorMessage,
                          userType: userType,
                          onSubmit: _submitEmail,
                          onErrorClear: () {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 50,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'AssignX',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom card wrapper (shared by both sections)
// ---------------------------------------------------------------------------

Widget _buildBottomCard({
  Key? key,
  required Widget child,
  required double bottomPadding,
}) {
  return Container(
    key: key,
    padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 16),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 8,
          offset: Offset(0, -2),
        ),
      ],
    ),
    child: SingleChildScrollView(child: child),
  );
}

// ---------------------------------------------------------------------------
// Email Entry Section
// ---------------------------------------------------------------------------

class _EmailEntrySection extends StatelessWidget {
  final TextEditingController emailController;
  final String? errorMessage;
  final String? userType;
  final VoidCallback onSubmit;
  final VoidCallback onErrorClear;

  const _EmailEntrySection({
    super.key,
    required this.emailController,
    this.errorMessage,
    this.userType,
    required this.onSubmit,
    required this.onErrorClear,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return _buildBottomCard(
      bottomPadding: bottomPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            'Create Account'.tr(context),
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Enter your email to get started'.tr(context),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Student info banner
          if (userType == 'student') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Use your educational email (.edu, .ac.in, .ac.uk, .edu.au, .edu.ca)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Error message
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Email field
          TextField(
            controller: emailController,
            onChanged: (_) => onErrorClear(),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email address'.tr(context),
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Create Account button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Create Account'.tr(context),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Already have an account? Log in
          Text(
            'Already have an account? '.tr(context),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go(RouteNames.login),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Log in'.tr(context),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Security note
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Secure passwordless authentication'.tr(context),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// OTP Entry Section
// ---------------------------------------------------------------------------

class _OtpEntrySection extends StatelessWidget {
  final String email;
  final List<TextEditingController> otpControllers;
  final List<FocusNode> otpFocusNodes;
  final String? errorMessage;
  final int resendCooldown;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onBack;
  final VoidCallback onErrorClear;

  const _OtpEntrySection({
    super.key,
    required this.email,
    required this.otpControllers,
    required this.otpFocusNodes,
    this.errorMessage,
    required this.resendCooldown,
    required this.onVerify,
    required this.onResend,
    required this.onBack,
    required this.onErrorClear,
  });

  void _onOtpFieldChanged(String value, int index) {
    onErrorClear();
    if (value.isNotEmpty && index < 5) {
      otpFocusNodes[index + 1].requestFocus();
    }
    // Auto-submit when all 6 digits entered
    if (index == 5 && value.isNotEmpty) {
      final otp = otpControllers.map((c) => c.text).join();
      if (otp.length == 6) {
        onVerify();
      }
    }
  }

  KeyEventResult _onOtpKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        otpControllers[index].text.isEmpty &&
        index > 0) {
      otpControllers[index - 1].clear();
      otpFocusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return _buildBottomCard(
      bottomPadding: bottomPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Back'.tr(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            'Verify your email'.tr(context),
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle with email
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(
                    text: '${'We sent a 6-digit code to'.tr(context)} '),
                TextSpan(
                  text: email,
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Error message
          if (errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // OTP input fields
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
              return Container(
                width: 44,
                height: 52,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onOtpKeyEvent(index, event),
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: otpFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onOtpFieldChanged(value, index),
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Verify button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Text(
                'Verify'.tr(context),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Resend code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't receive the code? ".tr(context),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: resendCooldown > 0 ? null : onResend,
                child: Text(
                  resendCooldown > 0
                      ? 'Resend in ${resendCooldown}s'
                      : 'Resend'.tr(context),
                  style: AppTextStyles.caption.copyWith(
                    color: resendCooldown > 0
                        ? AppColors.textSecondary.withValues(alpha: 0.5)
                        : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

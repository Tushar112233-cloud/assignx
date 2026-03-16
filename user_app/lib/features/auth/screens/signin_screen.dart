import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';
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

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin {
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

  // Animation
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
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

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).sendOTP(
            email: _email,
            purpose: 'signup',
            role: 'user',
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
      final success = await ref.read(authStateProvider.notifier).verifyOtp(
            email: _email,
            token: otp,
            purpose: 'signup',
            role: 'user',
          );

      if (mounted) {
        if (success) {
          // Check if user needs onboarding (name not set or onboarding not completed)
          final profile = ref.read(currentProfileProvider);
          final needsOnboarding = profile == null ||
              profile.fullName == null ||
              profile.fullName!.isEmpty ||
              !profile.onboardingCompleted;
          if (needsOnboarding) {
            context.go(RouteNames.profileCompletion);
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
      await ref.read(authStateProvider.notifier).sendOTP(
            email: _email,
            purpose: 'signup',
            role: 'user',
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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final lottieSize = (screenWidth * 0.35).clamp(140.0, 200.0);
    const headerHeight = 50.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _showOtpEntry ? 'Verifying...' : 'Sending code...',
        child: Stack(
          children: [
            // Mesh gradient background
            _MeshGradientBackground(
              height: screenHeight,
              colors: const [
                Color(0xFFFBE8E0),
                Color(0xFFF5E6D8),
                Color(0xFFEDE0D4),
              ],
            ),

            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // App name header
                  SizedBox(
                    height: headerHeight,
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
                      ).animate().fadeIn(duration: 600.ms).slideY(
                            begin: -0.3,
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          ),
                    ),
                  ),

                  // Lottie animation - takes available space, pushes card to bottom
                  Expanded(
                    child: Center(
                      child: _LottieHero(
                        floatAnimation: _floatController,
                        size: lottieSize,
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
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Email Entry Section
// ---------------------------------------------------------------------------

class _EmailEntrySection extends StatelessWidget {
  final TextEditingController emailController;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onErrorClear;

  const _EmailEntrySection({
    super.key,
    required this.emailController,
    this.errorMessage,
    required this.onSubmit,
    required this.onErrorClear,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Create Account'.tr(context),
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 4),

              Text(
                'Enter your email to get started'.tr(context),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: 16),

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
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSubmit(),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter your email address'.tr(context),
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: AppColors.primary, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Already have an account? Log in
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? '.tr(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.login),
                    child: Text(
                      'Log in'.tr(context),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Security note
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Secure passwordless authentication'.tr(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding + 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    'Back'.tr(context),
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pin_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Verify your email'.tr(context),
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle with email
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    TextSpan(text: '${'We sent a 6-digit code to'.tr(context)} '),
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
              const SizedBox(height: 16),

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
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 6,
                      right: index == 5 ? 0 : 6,
                    ),
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
                        onChanged: (value) =>
                            _onOtpFieldChanged(value, index),
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12),
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
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ".tr(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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
                            ? AppColors.textSecondary
                            : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ---------------------------------------------------------------------------
// Shared Widgets
// ---------------------------------------------------------------------------

/// Mesh gradient background widget.
class _MeshGradientBackground extends StatelessWidget {
  final double height;
  final List<Color> colors;

  const _MeshGradientBackground({
    required this.height,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ...List.generate(colors.length, (index) {
            final alignment = _getAlignment(index);
            final radius = _getRadius(index);
            final opacity = _getOpacity(index);

            return Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: alignment,
                    radius: radius,
                    colors: [
                      colors[index].withValues(alpha: opacity),
                      colors[index].withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Alignment _getAlignment(int index) {
    switch (index) {
      case 0:
        return const Alignment(1.2, -0.8);
      case 1:
        return const Alignment(-0.8, 0.6);
      case 2:
        return const Alignment(0.5, 1.2);
      default:
        return Alignment.center;
    }
  }

  double _getRadius(int index) {
    switch (index) {
      case 0:
        return 1.5;
      case 1:
        return 1.2;
      case 2:
        return 1.0;
      default:
        return 1.0;
    }
  }

  double _getOpacity(int index) {
    switch (index) {
      case 0:
        return 0.4;
      case 1:
        return 0.35;
      case 2:
        return 0.3;
      default:
        return 0.3;
    }
  }
}

/// Lottie animation hero with floating effect.
class _LottieHero extends StatelessWidget {
  final AnimationController floatAnimation;
  final double size;

  const _LottieHero({
    required this.floatAnimation,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        final floatValue = floatAnimation.value;
        final yOffset = math.sin(floatValue * math.pi * 2) * 6;

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: child,
        );
      },
      child: SizedBox(
        height: size,
        width: size,
        child: Lottie.network(
          'https://lottie.host/350df33f-fcc3-476f-9b46-475b0ab98268/u13av2s6ax.json',
          fit: BoxFit.contain,
          animate: true,
          repeat: true,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.games_rounded,
              size: size * 0.5,
              color: Colors.white.withValues(alpha: 0.6),
            );
          },
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          delay: 200.ms,
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

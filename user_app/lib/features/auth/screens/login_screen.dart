import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';

/// Login screen with a two-state OTP flow: email entry then OTP verification.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Flow state: false = email entry, true = OTP entry.
  bool _otpState = false;

  // Controllers.
  final _emailController = TextEditingController();
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // UI state.
  bool _isLoading = false;

  // Resend cooldown.
  int _resendCooldown = 0;
  Timer? _resendTimer;

  // Floating animation for Lottie hero.
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
    _resendTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final n in _otpFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String get _email => _emailController.text.trim().toLowerCase();

  String get _otpValue =>
      _otpControllers.map((c) => c.text).join();

  bool get _isEmailValid {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(_email);
  }

  void _showSnack(String message, {Widget? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: action != null
            ? SnackBarAction(
                label: '',
                onPressed: () {},
                // We use a custom action widget instead.
              )
            : null,
      ),
    );
    // If we have a custom action, show a different snackbar.
    if (action != null) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(child: Text(message)),
              action,
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _startResendCooldown() {
    setState(() => _resendCooldown = 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// State 1 -> submit email, check account, send OTP.
  Future<void> _onContinue() async {
    if (!_isEmailValid) {
      _showSnack('Please enter a valid email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final exists = await ref
          .read(authStateProvider.notifier)
          .checkAccount(_email);

      if (!exists) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showSnack(
          'No account found for this email',
          action: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              context.go(RouteNames.signin);
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        return;
      }

      // Account exists — send OTP.
      await ref
          .read(authStateProvider.notifier)
          .sendOTP(email: _email, purpose: 'login', role: 'user');

      if (!mounted) return;
      _startResendCooldown();
      setState(() {
        _otpState = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e.toString().replaceFirst('Exception: ', '').replaceFirst(RegExp(r'^ApiException\(\d+\): '), '');
      _showSnack(msg);
    }
  }

  /// State 2 -> verify OTP.
  Future<void> _onVerify() async {
    final otp = _otpValue;
    if (otp.length != 6) {
      _showSnack('Please enter the full 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await ref
          .read(authStateProvider.notifier)
          .verifyOtp(email: _email, token: otp, purpose: 'login', role: 'user');

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!success) {
        _showSnack('Invalid or expired code. Please try again.');
        _clearOtp();
      }
      // On success, GoRouter redirect logic handles navigation automatically.
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final msg = e.toString().replaceFirst('Exception: ', '').replaceFirst(RegExp(r'^ApiException\(\d+\): '), '');
      _showSnack(msg);
      _clearOtp();
    }
  }

  /// Resend OTP.
  Future<void> _onResend() async {
    if (_resendCooldown > 0) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authStateProvider.notifier)
          .sendOTP(email: _email, purpose: 'login', role: 'user');

      if (!mounted) return;
      _startResendCooldown();
      setState(() => _isLoading = false);
      _showSnack('A new code has been sent to your email');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Failed to resend code. Please try again.');
    }
  }

  /// Go back from OTP state to email state.
  void _goBackToEmail() {
    _resendTimer?.cancel();
    _clearOtp();
    setState(() {
      _otpState = false;
      _resendCooldown = 0;
    });
  }

  void _clearOtp() {
    for (final c in _otpControllers) {
      c.clear();
    }
    if (_otpFocusNodes.first.canRequestFocus) {
      _otpFocusNodes.first.requestFocus();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final lottieSize = (screenWidth * 0.35).clamp(140.0, 200.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            // Mesh gradient background.
            _MeshGradientBackground(height: screenHeight),

            SafeArea(
              child: Column(
                children: [
                  // App name header.
                  _buildHeader(),

                  // Lottie hero.
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _LottieHero(
                        floatAnimation: _floatController,
                        size: lottieSize,
                      ),
                    ),
                  ),

                  // Bottom content card.
                  Flexible(
                    flex: 3,
                    child: AnimatedSwitcher(
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
                      child: _otpState
                          ? _buildOtpSection(key: const ValueKey('otp'))
                          : _buildEmailSection(key: const ValueKey('email')),
                    ),
                  ),
                ],
              ),
            ),

            // Loading overlay.
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AssignX',
              style: AppTextStyles.headingSmall.copyWith(
                color: Colors.white,
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
    );
  }

  // ---------------------------------------------------------------------------
  // State 1: Email entry
  // ---------------------------------------------------------------------------

  Widget _buildEmailSection({Key? key}) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return _GlassCard(
      key: key,
      bottomPadding: bottomPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _handleIndicator(),
          const SizedBox(height: 12),

          Text(
            'Welcome Back',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter your email to sign in',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),

          // Email field.
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onContinue(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'you@example.com',
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Continue button.
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Sign up nudge.
          Text(
            "Don't have an account?",
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          GestureDetector(
            onTap: () => context.go(RouteNames.signin),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Create one here',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State 2: OTP entry
  // ---------------------------------------------------------------------------

  Widget _buildOtpSection({Key? key}) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return _GlassCard(
      key: key,
      bottomPadding: bottomPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Back button row.
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: _goBackToEmail,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Back',
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

          Text(
            'Enter Verification Code',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We sent a 6-digit code to $_email',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // OTP fields.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) => _buildOtpField(i)),
          ),
          const SizedBox(height: 16),

          // Verify button.
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Resend row.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Didn't get a code? ",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: _resendCooldown > 0 ? null : _onResend,
                child: Text(
                  _resendCooldown > 0
                      ? 'Resend in ${_resendCooldown}s'
                      : 'Resend Code',
                  style: AppTextStyles.caption.copyWith(
                    color: _resendCooldown > 0
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

  Widget _buildOtpField(int index) {
    return Container(
      width: 44,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: AppTextStyles.headingSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            // Backspace on empty field: move to previous.
            _otpFocusNodes[index - 1].requestFocus();
          }
          // Auto-submit when all 6 digits entered.
          if (value.isNotEmpty && _otpValue.length == 6) {
            FocusScope.of(context).unfocus();
            _onVerify();
          }
        },
      ),
    );
  }

  Widget _handleIndicator() {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// =============================================================================
// Shared widgets
// =============================================================================

/// Glass morphism card used for the bottom content area.
class _GlassCard extends StatelessWidget {
  final double bottomPadding;
  final Widget child;

  const _GlassCard({
    super.key,
    required this.bottomPadding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
          child: SingleChildScrollView(child: child),
        ),
      ),
    );
  }
}

/// Mesh gradient background (Dashboard-style).
class _MeshGradientBackground extends StatelessWidget {
  final double height;

  static const _colors = [
    Color(0xFFFBE8E8), // Soft pink (creamy)
    Color(0xFFFCEDE8), // Soft peach (orangish)
    Color(0xFFF0E8F8), // Soft purple
  ];

  static const _alignments = [
    Alignment(1.2, -0.8),
    Alignment(-0.8, 0.6),
    Alignment(0.5, 1.2),
  ];

  static const _radii = [1.5, 1.2, 1.0];
  static const _opacities = [0.4, 0.35, 0.3];

  const _MeshGradientBackground({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: List.generate(_colors.length, (i) {
          return Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: _alignments[i],
                  radius: _radii[i],
                  colors: [
                    _colors[i].withValues(alpha: _opacities[i]),
                    _colors[i].withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Lottie floating hero animation.
class _LottieHero extends StatelessWidget {
  final AnimationController floatAnimation;
  final double size;

  const _LottieHero({required this.floatAnimation, required this.size});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnimation,
      builder: (context, child) {
        final yOffset = math.sin(floatAnimation.value * math.pi * 2) * 6;
        return Transform.translate(offset: Offset(0, yOffset), child: child);
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
              Icons.computer_rounded,
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

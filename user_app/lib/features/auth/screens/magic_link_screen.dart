import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';

/// Magic link confirmation screen shown after sending a magic link.
///
/// Features:
/// - "Check Your Email" message with animated email icon
/// - Shows the email address magic link was sent to
/// - "Didn't receive it? Resend" link with 60-second cooldown
/// - "Try another method" link back to login
/// - Auto-checks for session every few seconds (in case user clicked link in browser)
class MagicLinkScreen extends ConsumerStatefulWidget {
  /// The email address the magic link was sent to.
  final String email;

  const MagicLinkScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<MagicLinkScreen> createState() => _MagicLinkScreenState();
}

class _MagicLinkScreenState extends ConsumerState<MagicLinkScreen>
    with TickerProviderStateMixin {
  // Resend cooldown state
  int _resendCooldown = 60;
  Timer? _cooldownTimer;
  bool _canResend = false;

  // Session check state
  Timer? _sessionCheckTimer;

  // UI state
  bool _isResending = false;
  String? _errorMessage;
  String? _successMessage;

  // Animation controllers
  late AnimationController _iconPulseController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _iconPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Start cooldown timer
    _startCooldownTimer();

    // Session detection is handled by ref.listen in build() only.
    // Do NOT also use Timer.periodic, as dual triggers cause a race condition.
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _sessionCheckTimer?.cancel();
    _iconPulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  /// Start the cooldown timer for resend button.
  void _startCooldownTimer() {
    _resendCooldown = 60;
    _canResend = false;

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendCooldown--;
          if (_resendCooldown <= 0) {
            _canResend = true;
            timer.cancel();
          }
        });
      }
    });
  }


  /// Resend the magic link.
  Future<void> _resendMagicLink() async {
    if (!_canResend || _isResending) return;

    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).signInWithMagicLink(
            email: widget.email,
            userType: null, // Preserve the previously selected user type
          );

      if (mounted) {
        setState(() {
          _successMessage = 'Magic link sent! Check your inbox.';
          _isResending = false;
        });

        // Restart cooldown
        _startCooldownTimer();

        // Clear success message after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _successMessage = null;
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to resend. Please try again.';
          _isResending = false;
        });
      }
    }
  }

  /// Navigate back to login screen.
  void _tryAnotherMethod() {
    context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Listen for auth state changes (sole navigation trigger to avoid race conditions)
    ref.listen<AsyncValue<AuthStateData>>(authStateProvider, (previous, next) {
      final isAuthenticated = next.valueOrNull?.isAuthenticated ?? false;
      if (isAuthenticated && mounted) {
        context.go(RouteNames.home);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Mesh gradient background
          _MeshGradientBackground(
            height: screenHeight,
            colors: const [
              Color(0xFFE8F4FB), // Soft blue
              Color(0xFFE8EEF8), // Soft lavender-blue
              Color(0xFFF0E8F8), // Soft purple-blue
            ],
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: IconButton(
                      onPressed: _tryAnotherMethod,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                // Main content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated email icon
                        _AnimatedEmailIcon(
                          pulseController: _iconPulseController,
                          floatController: _floatController,
                        ),

                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Check Your Email',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 500.ms),

                        const SizedBox(height: 12),

                        // Subtitle with email
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.5,
                            ),
                            children: [
                              const TextSpan(
                                text: 'We sent a magic link to\n',
                              ),
                              TextSpan(
                                text: widget.email,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms, duration: 500.ms),

                        const SizedBox(height: 24),

                        // Info card
                        _InfoCard().animate().fadeIn(delay: 200.ms, duration: 500.ms),

                        const SizedBox(height: 32),

                        // Error message
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().shake(),
                          const SizedBox(height: 16),
                        ],

                        // Success message
                        if (_successMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.successLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _successMessage!,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(duration: 300.ms),
                          const SizedBox(height: 16),
                        ],

                        // Resend button
                        _ResendButton(
                          canResend: _canResend,
                          cooldownSeconds: _resendCooldown,
                          isLoading: _isResending,
                          onPressed: _resendMagicLink,
                        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

                        const SizedBox(height: 16),

                        // Try another method link
                        TextButton(
                          onPressed: _tryAnotherMethod,
                          child: Text(
                            'Try another sign in method',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                ),

                // Bottom hint
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding + 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.security_rounded,
                        size: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Secure passwordless authentication',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
          // Radial gradient layers
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

/// Animated email icon with pulse and float effects.
class _AnimatedEmailIcon extends StatelessWidget {
  final AnimationController pulseController;
  final AnimationController floatController;

  const _AnimatedEmailIcon({
    required this.pulseController,
    required this.floatController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([pulseController, floatController]),
      builder: (context, child) {
        // Float animation
        final floatValue = floatController.value;
        final yOffset = (floatValue - 0.5) * 8;

        // Pulse animation for glow
        final pulseValue = pulseController.value;
        final glowOpacity = 0.2 + (pulseValue * 0.15);

        return Transform.translate(
          offset: Offset(0, yOffset),
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: glowOpacity),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    // Icon
                    const Icon(
                      Icons.mark_email_unread_rounded,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Info card with instructions.
class _InfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: AppColors.info,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'How it works',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _InfoItem(
                icon: Icons.mark_email_read_outlined,
                text: 'Click the link in the email we sent you',
              ),
              const SizedBox(height: 10),
              _InfoItem(
                icon: Icons.timer_outlined,
                text: 'The link expires in 10 minutes',
              ),
              const SizedBox(height: 10),
              _InfoItem(
                icon: Icons.folder_outlined,
                text: 'Check your spam folder if you don\'t see it',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Single info item with icon and text.
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Resend button with cooldown display.
class _ResendButton extends StatelessWidget {
  final bool canResend;
  final int cooldownSeconds;
  final bool isLoading;
  final VoidCallback onPressed;

  const _ResendButton({
    required this.canResend,
    required this.cooldownSeconds,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = canResend
        ? 'Resend magic link'
        : 'Resend in ${cooldownSeconds}s';

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: canResend && !isLoading ? onPressed : null,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    canResend ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              )
            : Icon(
                canResend ? Icons.refresh_rounded : Icons.timer_outlined,
                size: 20,
              ),
        label: Text(
          buttonText,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          side: BorderSide(
            color: canResend ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
          foregroundColor: canResend ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

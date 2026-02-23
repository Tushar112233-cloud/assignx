import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

/// Sign-in screen with Dashboard-inspired design.
///
/// Features:
/// - Subtle gradient backgrounds (cool blue-ish tints, different from signup)
/// - Glass morphism effects for cards/forms
/// - Smooth animations consistent with Dashboard
/// - Google Sign-in + Magic Link options
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with TickerProviderStateMixin {
  // UI state
  bool _termsAccepted = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Magic link state
  bool _showMagicLink = false;
  final _emailController = TextEditingController();
  bool _magicLinkSent = false;
  String? _magicLinkError;

  // Animation controllers
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
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'Please accept the Terms & Conditions to continue';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authStateProvider.notifier).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Sign in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      setState(() {
        _magicLinkError = 'Please enter your email address';
      });
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _magicLinkError = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _magicLinkError = null;
    });

    try {
      await ref.read(authStateProvider.notifier).signInWithMagicLink(
            email: email,
            userType: null,
          );

      if (mounted) {
        // Navigate to magic link confirmation screen
        context.go('${RouteNames.magicLink}?email=${Uri.encodeComponent(email)}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _magicLinkError = 'Failed to send magic link. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _tryDifferentEmail() {
    setState(() {
      _magicLinkSent = false;
      _emailController.clear();
      _magicLinkError = null;
    });
  }

  void _goBack() {
    if (_showMagicLink) {
      setState(() {
        _showMagicLink = false;
        _emailController.clear();
        _magicLinkError = null;
        _magicLinkSent = false;
      });
    } else {
      context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive Lottie size - smaller on small screens
    final lottieSize = (screenWidth * 0.35).clamp(140.0, 200.0);
    // Header height (app name area)
    const headerHeight = 50.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: _showMagicLink ? 'Sending magic link...' : 'Signing in...',
        child: Stack(
          children: [
            // Mesh gradient background (cool blue-ish colors)
            _MeshGradientBackground(
              height: screenHeight,
              colors: const [
                Color(0xFFE8F4FB), // Soft blue (creamy)
                Color(0xFFE8F0FB), // Soft lavender-blue
                Color(0xFFF0E8FB), // Soft purple-blue
              ],
            ),

            // Safe area content
            SafeArea(
              child: Column(
                children: [
                  // App name at top - fixed height
                  SizedBox(
                    height: headerHeight,
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
                  ),

                  // Lottie animation - flexible space
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: _LottieHero(
                        floatAnimation: _floatController,
                        size: lottieSize,
                      ),
                    ),
                  ),

                  // Bottom content section with glass morphism
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
                      child: _magicLinkSent
                          ? _MagicLinkSentView(
                              key: const ValueKey('sent'),
                              email: _emailController.text,
                              onTryDifferent: _tryDifferentEmail,
                              onBack: _goBack,
                            )
                          : _showMagicLink
                              ? _MagicLinkForm(
                                  key: const ValueKey('form'),
                                  emailController: _emailController,
                                  error: _magicLinkError,
                                  onSend: _sendMagicLink,
                                  onBack: _goBack,
                                  onEmailChanged: () {
                                    if (_magicLinkError != null) {
                                      setState(() => _magicLinkError = null);
                                    }
                                  },
                                )
                              : _SignInOptionsSection(
                                  key: const ValueKey('options'),
                                  termsAccepted: _termsAccepted,
                                  errorMessage: _errorMessage,
                                  onTermsChanged: (value) {
                                    setState(() {
                                      _termsAccepted = value;
                                      if (_termsAccepted) _errorMessage = null;
                                    });
                                  },
                                  onGoogleSignIn: _signInWithGoogle,
                                  onMagicLinkPressed: () {
                                    setState(() => _showMagicLink = true);
                                  },
                                  onBack: _goBack,
                                ),
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

/// Mesh gradient background widget (Dashboard-style).
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

/// Lottie animation hero for sign-in screen (game animation).
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
            // Fallback if Lottie fails to load
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

/// Sign-in options section with glass morphism.
class _SignInOptionsSection extends StatelessWidget {
  final bool termsAccepted;
  final String? errorMessage;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onMagicLinkPressed;
  final VoidCallback onBack;

  const _SignInOptionsSection({
    super.key,
    required this.termsAccepted,
    this.errorMessage,
    required this.onTermsChanged,
    required this.onGoogleSignIn,
    required this.onMagicLinkPressed,
    required this.onBack,
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

              // Welcome back icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.waving_hand_rounded,
                  color: Color(0xFF42A5F5),
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                'Welcome Back!',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 4),

              Text(
                'Sign in to continue your journey',
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

              // Terms checkbox
              Row(
                children: [
                  GestureDetector(
                    onTap: () => onTermsChanged(!termsAccepted),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: termsAccepted
                              ? const Color(0xFF42A5F5)
                              : AppColors.textSecondary.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        color: termsAccepted
                            ? const Color(0xFF42A5F5)
                            : Colors.transparent,
                      ),
                      child: termsAccepted
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onTermsChanged(!termsAccepted),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'I agree to the '),
                            TextSpan(
                              text: 'Terms',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF42A5F5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.caption.copyWith(
                                color: const Color(0xFF42A5F5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Google Sign-in button
              _GoogleSignInButton(
                onPressed: termsAccepted ? onGoogleSignIn : null,
                enabled: termsAccepted,
              ),

              const SizedBox(height: 12),

              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Or',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),

              const SizedBox(height: 12),

              // Magic Link button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: termsAccepted ? onMagicLinkPressed : null,
                  icon: const Icon(Icons.mail_outline_rounded, size: 20),
                  label: Text(
                    'Sign in with Email',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide(
                      color: termsAccepted
                          ? const Color(0xFF42A5F5)
                          : Colors.grey.shade300,
                    ),
                    foregroundColor: termsAccepted
                        ? const Color(0xFF42A5F5)
                        : AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Don't have account? Sign up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(RouteNames.login),
                    child: Text(
                      'Sign up',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFF42A5F5),
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
                    'Secure passwordless authentication',
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

/// Google sign-in button.
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool enabled;

  const _GoogleSignInButton({
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF4285F4),
                            Color(0xFF34A853),
                            Color(0xFFFBBC05),
                            Color(0xFFEA4335),
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 22, 22)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Continue with Google',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Magic link sent success view with glass morphism.
class _MagicLinkSentView extends StatelessWidget {
  final String email;
  final VoidCallback onTryDifferent;
  final VoidCallback onBack;

  const _MagicLinkSentView({
    super.key,
    required this.email,
    required this.onTryDifferent,
    required this.onBack,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 32,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Check your email',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  children: [
                    const TextSpan(text: 'We sent a magic link to\n'),
                    TextSpan(
                      text: email,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Click the link in your email to sign in.\nThe link expires in 10 minutes.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: onTryDifferent,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Try a different email',
                    style: AppTextStyles.labelMedium.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Magic link email form with glass morphism.
class _MagicLinkForm extends StatelessWidget {
  final TextEditingController emailController;
  final String? error;
  final VoidCallback onSend;
  final VoidCallback onBack;
  final VoidCallback onEmailChanged;

  const _MagicLinkForm({
    super.key,
    required this.emailController,
    this.error,
    required this.onSend,
    required this.onBack,
    required this.onEmailChanged,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: Text(
                    'Back to options',
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
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_rounded,
                  color: Color(0xFF42A5F5),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Sign in with email',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "We'll send you a magic link to sign in instantly",
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                onChanged: (_) => onEmailChanged(),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onSend(),
                style: AppTextStyles.bodySmall.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
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
                    borderSide:
                        const BorderSide(color: Color(0xFF42A5F5), width: 2),
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
              if (error != null) ...[
                const SizedBox(height: 6),
                Text(
                  error!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF42A5F5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Send Magic Link',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll send you a secure link that expires in 10 minutes.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

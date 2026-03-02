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
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

/// College email domain patterns for student validation.
final _collegeEmailPatterns = [
  RegExp(r'\.edu$', caseSensitive: false),
  RegExp(r'\.edu\.in$', caseSensitive: false),
  RegExp(r'\.ac\.in$', caseSensitive: false),
  RegExp(r'\.ac\.uk$', caseSensitive: false),
  RegExp(r'\.edu\.au$', caseSensitive: false),
  RegExp(r'\.edu\.ca$', caseSensitive: false),
  RegExp(r'\.edu\.[a-z]{2}$', caseSensitive: false),
];

/// Validates if email is from a college domain.
bool _isCollegeEmail(String email) {
  final parts = email.toLowerCase().split('@');
  if (parts.length != 2) return false;
  final domain = parts[1];
  return _collegeEmailPatterns.any((pattern) => pattern.hasMatch(domain));
}

/// Role definition for role selection cards.
class _RoleData {
  final UserType type;
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final String? emailHint;

  const _RoleData({
    required this.type,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.emailHint,
  });
}

/// Available roles for signup.
final _roles = [
  _RoleData(
    type: UserType.student,
    icon: Icons.school_rounded,
    title: 'Student',
    description:
        'Get expert help with your academic projects. From essays to dissertations.',
    color: const Color(0xFF8B5CF6),
    emailHint: 'Use your college email (e.g., name@college.edu)',
  ),
  _RoleData(
    type: UserType.professional,
    icon: Icons.work_rounded,
    title: 'Professional / Other',
    description:
        'Working professionals, businesses, and anyone looking for expert assistance.',
    color: const Color(0xFFF59E0B),
  ),
];

/// Modern login screen with Dashboard-inspired design.
///
/// Features:
/// - Subtle gradient backgrounds (creamy, orangish, purplish tints)
/// - Glass morphism effects for cards/forms
/// - Smooth animations consistent with Dashboard
/// - Role selection (Student, Professional, Other)
/// - Auth options (Google OAuth + Magic Link)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with TickerProviderStateMixin {
  // Step tracking: 0 = role selection, 1 = auth options
  int _currentStep = 0;
  UserType? _selectedRole;

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

  void _selectRole(UserType role) {
    setState(() {
      _selectedRole = role;
      _currentStep = 1;
      _errorMessage = null;
    });
  }

  void _goBack() {
    setState(() {
      if (_showMagicLink) {
        _showMagicLink = false;
        _emailController.clear();
        _magicLinkError = null;
        _magicLinkSent = false;
      } else {
        _currentStep = 0;
        _selectedRole = null;
        _errorMessage = null;
        _termsAccepted = false;
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    // Google OAuth removed - magic link only
    setState(() {
      _showMagicLink = true;
    });
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

    if (_selectedRole == UserType.student && !_isCollegeEmail(email)) {
      setState(() {
        _magicLinkError =
            'Student accounts require a valid educational email (.edu, .ac.in, .ac.uk, etc.)';
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
            userType: _selectedRole,
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
            // Mesh gradient background (Dashboard-style)
            _MeshGradientBackground(
              height: screenHeight,
              colors: const [
                Color(0xFFFBE8E8), // Soft pink (creamy)
                Color(0xFFFCEDE8), // Soft peach (orangish)
                Color(0xFFF0E8F8), // Soft purple
              ],
            ),

            // Safe area content
            SafeArea(
              child: Column(
                children: [
                  // App name at top
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
                      child: _currentStep == 0
                          ? _RoleSelectionSection(
                              key: const ValueKey('role'),
                              onRoleSelected: _selectRole,
                            )
                          : _AuthOptionsSection(
                              key: const ValueKey('auth'),
                              selectedRole: _selectedRole!,
                              termsAccepted: _termsAccepted,
                              errorMessage: _errorMessage,
                              showMagicLink: _showMagicLink,
                              magicLinkSent: _magicLinkSent,
                              magicLinkError: _magicLinkError,
                              emailController: _emailController,
                              onTermsChanged: (value) {
                                setState(() {
                                  _termsAccepted = value;
                                  if (_termsAccepted) _errorMessage = null;
                                });
                              },
                              onGoogleSignIn: _signInWithGoogle,
                              onMagicLinkPressed: () {
                                setState(() {
                                  _showMagicLink = true;
                                });
                              },
                              onSendMagicLink: _sendMagicLink,
                              onTryDifferentEmail: _tryDifferentEmail,
                              onBack: _goBack,
                              onEmailChanged: () {
                                if (_magicLinkError != null) {
                                  setState(() {
                                    _magicLinkError = null;
                                  });
                                }
                              },
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

/// Lottie animation hero for login screen.
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

/// Role selection section with glass morphism card.
class _RoleSelectionSection extends StatelessWidget {
  final ValueChanged<UserType> onRoleSelected;

  const _RoleSelectionSection({
    super.key,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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

              // Title
              Text(
                'Choose Your Path',
                style: AppTextStyles.headingSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

              const SizedBox(height: 6),

              Text(
                'Select the option that best describes you',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

              const SizedBox(height: 16),

              // Role cards
              ..._roles.asMap().entries.map((entry) {
                final index = entry.key;
                final role = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _RoleCard(
                    role: role,
                    onTap: () => onRoleSelected(role.type),
                  ).animate().fadeIn(
                        delay: Duration(milliseconds: 200 + (index * 80)),
                        duration: const Duration(milliseconds: 400),
                      ),
                );
              }),

              const SizedBox(height: 8),

              Text(
                'New user? We\'ll create your account automatically.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual role selection card.
class _RoleCard extends StatelessWidget {
  final _RoleData role;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: role.color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: role.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  role.icon,
                  color: role.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      role.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.15,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              // Arrow
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: role.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: role.color,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Auth options section with glass morphism.
class _AuthOptionsSection extends StatelessWidget {
  final UserType selectedRole;
  final bool termsAccepted;
  final String? errorMessage;
  final bool showMagicLink;
  final bool magicLinkSent;
  final String? magicLinkError;
  final TextEditingController emailController;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onMagicLinkPressed;
  final VoidCallback onSendMagicLink;
  final VoidCallback onTryDifferentEmail;
  final VoidCallback onBack;
  final VoidCallback onEmailChanged;

  const _AuthOptionsSection({
    super.key,
    required this.selectedRole,
    required this.termsAccepted,
    this.errorMessage,
    required this.showMagicLink,
    required this.magicLinkSent,
    this.magicLinkError,
    required this.emailController,
    required this.onTermsChanged,
    required this.onGoogleSignIn,
    required this.onMagicLinkPressed,
    required this.onSendMagicLink,
    required this.onTryDifferentEmail,
    required this.onBack,
    required this.onEmailChanged,
  });

  _RoleData get _roleData =>
      _roles.firstWhere((r) => r.type == selectedRole);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
          child: SingleChildScrollView(
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
                const SizedBox(height: 8),

                // Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded, size: 16),
                    label: Text(
                      showMagicLink ? 'Back to options' : 'Back',
                      style: AppTextStyles.caption.copyWith(fontSize: 13),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),

                if (magicLinkSent)
                  _MagicLinkSentView(
                    email: emailController.text,
                    onTryDifferent: onTryDifferentEmail,
                  )
                else if (showMagicLink)
                  _MagicLinkForm(
                    selectedRole: selectedRole,
                    emailController: emailController,
                    error: magicLinkError,
                    onSend: onSendMagicLink,
                    onEmailChanged: onEmailChanged,
                  )
                else
                  _GoogleAndMagicLinkOptions(
                    roleData: _roleData,
                    termsAccepted: termsAccepted,
                    errorMessage: errorMessage,
                    onTermsChanged: onTermsChanged,
                    onGoogleSignIn: onGoogleSignIn,
                    onMagicLinkPressed: onMagicLinkPressed,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Magic link sent success view.
class _MagicLinkSentView extends StatelessWidget {
  final String email;
  final VoidCallback onTryDifferent;

  const _MagicLinkSentView({
    required this.email,
    required this.onTryDifferent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF10B981),
            size: 28,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Check your email',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            children: [
              const TextSpan(text: 'We sent a magic link to\n'),
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
        const SizedBox(height: 8),
        Text(
          'Click the link in your email to sign in.\nThe link expires in 10 minutes.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onTryDifferent,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            'Try a different email',
            style: AppTextStyles.caption.copyWith(fontSize: 13),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Magic link email form.
class _MagicLinkForm extends StatelessWidget {
  final UserType selectedRole;
  final TextEditingController emailController;
  final String? error;
  final VoidCallback onSend;
  final VoidCallback onEmailChanged;

  const _MagicLinkForm({
    required this.selectedRole,
    required this.emailController,
    this.error,
    required this.onSend,
    required this.onEmailChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mail_rounded,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in with email',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "We'll send you a magic link to sign in instantly",
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        if (selectedRole == UserType.student) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB45309),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Use your college email (.edu, .ac.in, .ac.uk, etc.)',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFB45309),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: emailController,
          onChanged: (_) => onEmailChanged(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSend(),
          style: AppTextStyles.bodySmall.copyWith(fontSize: 13),
          decoration: InputDecoration(
            hintText: selectedRole == UserType.student
                ? 'yourname@college.edu'
                : 'Enter your email address',
            hintStyle: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(Icons.email_outlined, size: 18),
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            isDense: true,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onSend,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              elevation: 0,
            ),
            child: Text(
              'Send Magic Link',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We\'ll send you a secure link that expires in 10 minutes.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// Google sign-in and magic link options.
class _GoogleAndMagicLinkOptions extends StatelessWidget {
  final _RoleData roleData;
  final bool termsAccepted;
  final String? errorMessage;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onGoogleSignIn;
  final VoidCallback onMagicLinkPressed;

  const _GoogleAndMagicLinkOptions({
    required this.roleData,
    required this.termsAccepted,
    this.errorMessage,
    required this.onTermsChanged,
    required this.onGoogleSignIn,
    required this.onMagicLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: roleData.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: roleData.color.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            roleData.icon,
            color: roleData.color,
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign up as ${roleData.title}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Choose how you want to create your account',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        if (roleData.type == UserType.student) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFCD34D)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFB45309),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Requires a valid college email (e.g., name@university.edu)',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFB45309),
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            GestureDetector(
              onTap: () => onTermsChanged(!termsAccepted),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: termsAccepted
                        ? AppColors.primary
                        : AppColors.textSecondary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  color: termsAccepted ? AppColors.primary : Colors.transparent,
                ),
                child: termsAccepted
                    ? const Icon(
                        Icons.check,
                        size: 11,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => onTermsChanged(!termsAccepted),
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: AppTextStyles.caption.copyWith(
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
        ),
        const SizedBox(height: 10),
        _GoogleSignInButton(
          onPressed: termsAccepted ? onGoogleSignIn : null,
          enabled: termsAccepted,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Or',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            onPressed: termsAccepted ? onMagicLinkPressed : null,
            icon: const Icon(Icons.mail_outline_rounded, size: 18),
            label: Text(
              'Sign in with Email',
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              side: BorderSide(
                color: termsAccepted
                    ? AppColors.primary
                    : Colors.grey.shade300,
              ),
              foregroundColor: termsAccepted
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 10,
              color: AppColors.textSecondary.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Secure passwordless authentication',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary.withValues(alpha: 0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
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
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
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
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [
                            Color(0xFF4285F4),
                            Color(0xFF34A853),
                            Color(0xFFFBBC05),
                            Color(0xFFEA4335),
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Continue with Google',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 13,
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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';

/// User type selection screen shown as the first step of signup.
///
/// Presents three cards: Student, Professional, and Other.
/// On selection, navigates to the signin screen with the chosen type
/// as a query parameter.
class UserTypeScreen extends StatefulWidget {
  const UserTypeScreen({super.key});

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen>
    with TickerProviderStateMixin {
  String? _selectedType;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTypeSelected(String type) {
    setState(() => _selectedType = type);

    // Brief delay so the user sees the selection animation before navigating
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.go('${RouteNames.signin}?type=$type');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Mesh gradient background
          _MeshGradientBackground(height: screenHeight),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // App name header with back button
                SizedBox(
                  height: 50,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                          onPressed: () => context.go(RouteNames.login),
                          color: AppColors.textSecondary,
                        ),
                        Expanded(
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
                        ),
                        const SizedBox(width: 48), // Balance the back button
                      ],
                    ).animate().fadeIn(duration: 600.ms).slideY(
                          begin: -0.3,
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                ),

                const SizedBox(height: 24),

                // Title section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Text(
                        'Who are you?',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: 8),
                      Text(
                        'Select your profile type to get started',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _UserTypeCard(
                          type: 'student',
                          title: 'Student',
                          subtitle: "I'm a student at a college or university",
                          icon: Icons.school_rounded,
                          gradientColors: const [
                            Color(0xFF2196F3),
                            Color(0xFF1976D2),
                          ],
                          iconBackgroundColor: const Color(0xFF2196F3),
                          isSelected: _selectedType == 'student',
                          onTap: () => _onTypeSelected('student'),
                          delay: 400,
                        ),
                        const SizedBox(height: 16),
                        _UserTypeCard(
                          type: 'professional',
                          title: 'Professional',
                          subtitle: "I'm a working professional",
                          icon: Icons.work_rounded,
                          gradientColors: const [
                            Color(0xFF9C27B0),
                            Color(0xFF7B1FA2),
                          ],
                          iconBackgroundColor: const Color(0xFF9C27B0),
                          isSelected: _selectedType == 'professional',
                          onTap: () => _onTypeSelected('professional'),
                          delay: 500,
                        ),
                        const SizedBox(height: 16),
                        _UserTypeCard(
                          type: 'business',
                          title: 'Business',
                          subtitle: "I'm a business owner or entrepreneur",
                          icon: Icons.business_center_rounded,
                          gradientColors: const [
                            Color(0xFF009688),
                            Color(0xFF00796B),
                          ],
                          iconBackgroundColor: const Color(0xFF009688),
                          isSelected: _selectedType == 'business',
                          onTap: () => _onTypeSelected('business'),
                          delay: 600,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom section: Already have an account
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go(RouteNames.login),
                            child: Text(
                              'Log in',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 12,
                            color:
                                AppColors.textSecondary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Secure passwordless authentication',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary
                                  .withValues(alpha: 0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A premium-looking card for user type selection with gradient background
/// and selection animation.
class _UserTypeCard extends StatelessWidget {
  final String type;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color iconBackgroundColor;
  final bool isSelected;
  final VoidCallback onTap;
  final int delay;

  const _UserTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.iconBackgroundColor,
    required this.isSelected,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 0.97 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? gradientColors
                      : [
                          Colors.white.withValues(alpha: 0.9),
                          Colors.white.withValues(alpha: 0.75),
                        ],
                ),
                border: Border.all(
                  color: isSelected
                      ? gradientColors[0].withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? gradientColors[0].withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: isSelected ? 20 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon container
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : iconBackgroundColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      size: 28,
                      color: isSelected
                          ? Colors.white
                          : iconBackgroundColor,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Checkmark
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isSelected ? 1.0 : 0.0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms).slideX(
          begin: 0.1,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

/// Mesh gradient background widget.
class _MeshGradientBackground extends StatelessWidget {
  final double height;

  static const _colors = [
    Color(0xFFFBE8E0),
    Color(0xFFF5E6D8),
    Color(0xFFEDE0D4),
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

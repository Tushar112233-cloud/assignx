import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';

/// Success screen shown after profile completion.
///
/// Redesigned with gradient background, glass morphism,
/// confetti animation, and smooth entrance animations
/// to match Dashboard aesthetic.
class SignupSuccessScreen extends ConsumerStatefulWidget {
  const SignupSuccessScreen({super.key});

  @override
  ConsumerState<SignupSuccessScreen> createState() =>
      _SignupSuccessScreenState();
}

class _SignupSuccessScreenState extends ConsumerState<SignupSuccessScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 4),
    );
    // Start confetti after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider);
    final displayName = profile?.fullName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Gradient background
          MeshGradientBackground(
            position: MeshPosition.center,
            colors: [
              AppColors.meshBlue,
              AppColors.meshPurple,
              AppColors.meshPink,
              AppColors.meshOrange,
            ],
            opacity: 0.5,
            child: SafeArea(
              child: Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    const Spacer(),

                    // Success icon with glass container
                    GlassContainer(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Success icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.success,
                                  AppColors.success.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.3),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(
                                begin: const Offset(0.3, 0.3),
                                end: const Offset(1, 1),
                                duration: 600.ms,
                                curve: Curves.elasticOut,
                              ),

                          const SizedBox(height: 32),

                          // Welcome message
                          Text(
                            'Welcome, $displayName! 🎉',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ).animate(delay: 300.ms).fadeIn(duration: 500.ms).slideY(
                                begin: 0.2,
                                end: 0,
                                duration: 500.ms,
                              ),

                          const SizedBox(height: 12),

                          Text(
                            'Your account is ready',
                            style: AppTextStyles.headingMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ).animate(delay: 400.ms).fadeIn(duration: 500.ms),

                          const SizedBox(height: 8),

                          Text(
                            "You're all set to get expert help for your projects and connect with professionals.",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ).animate(delay: 500.ms).fadeIn(duration: 500.ms),
                        ],
                      ),
                    ).animate(delay: 100.ms).fadeIn(duration: 600.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic,
                        ),

                    const SizedBox(height: 32),

                    // Features preview
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            Icons.upload_file_outlined,
                            'Upload projects easily',
                            AppColors.primary,
                          ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideX(
                                begin: -0.2,
                                end: 0,
                                duration: 400.ms,
                              ),
                          const SizedBox(height: 16),
                          _buildFeatureRow(
                            Icons.visibility_outlined,
                            'Track progress in real-time',
                            AppColors.success,
                          ).animate(delay: 700.ms).fadeIn(duration: 400.ms).slideX(
                                begin: -0.2,
                                end: 0,
                                duration: 400.ms,
                              ),
                          const SizedBox(height: 16),
                          _buildFeatureRow(
                            Icons.verified_outlined,
                            'Get quality-assured work',
                            AppColors.success,
                          ).animate(delay: 800.ms).fadeIn(duration: 400.ms).slideX(
                                begin: -0.2,
                                end: 0,
                                duration: 400.ms,
                              ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Go to dashboard button with glass effect
                    GlassContainer(
                      padding: const EdgeInsets.all(4),
                      child: AppButton(
                        label: 'Go to Dashboard',
                        onPressed: () => context.go(RouteNames.home),
                        icon: Icons.arrow_forward,
                      ),
                    ).animate(delay: 900.ms).fadeIn(duration: 400.ms).slideY(
                          begin: 0.2,
                          end: 0,
                          duration: 400.ms,
                        ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                AppColors.primary,
                AppColors.success,
                AppColors.success,
                AppColors.warning,
                AppColors.primaryLight,
                AppColors.meshBlue,
                AppColors.meshPurple,
                AppColors.meshPink,
              ],
              numberOfParticles: 40,
              maxBlastForce: 25,
              minBlastForce: 8,
              emissionFrequency: 0.03,
              gravity: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.success,
            size: 18,
          ),
        ),
      ],
    );
  }
}

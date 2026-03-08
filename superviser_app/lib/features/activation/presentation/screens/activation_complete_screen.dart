import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Activation Complete Screen (S17)
///
/// Welcome message after completing all training.
class ActivationCompleteScreen extends ConsumerStatefulWidget {
  const ActivationCompleteScreen({super.key});

  @override
  ConsumerState<ActivationCompleteScreen> createState() =>
      _ActivationCompleteScreenState();
}

class _ActivationCompleteScreenState
    extends ConsumerState<ActivationCompleteScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    // Refresh user data to update activation status
    ref.read(authProvider.notifier).refreshUser();
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/activation'),
        ),
        title: Text('Activation Complete'.tr(context)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MeshGradientBackground(
        position: MeshPosition.center,
        colors: const [
          MeshColors.meshOrange,
          MeshColors.meshYellow,
          MeshColors.meshGreen,
        ],
        opacity: 0.6,
        animated: true,
        animationDuration: const Duration(seconds: 25),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated success icon with celebratory glow
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.2),
                          AppColors.success.withValues(alpha: 0.2),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      size: 64,
                      color: AppColors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Welcome text in glass card
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 28,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    elevation: 3,
                    child: Column(
                      children: [
                        Text(
                          'Welcome aboard,'.tr(context),
                          style: AppTypography.titleLarge.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          user?.fullName ?? 'Supervisor'.tr(context),
                          style: AppTypography.headlineMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'You have successfully completed all training modules and are now an activated supervisor.'
                              .tr(context),
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Features cards
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.dashboard_outlined,
                        title: 'Access Dashboard'.tr(context),
                        description:
                            'View and manage your assignments'.tr(context),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.chat_outlined,
                        title: 'Chat with Clients'.tr(context),
                        description:
                            'Communicate directly with clients'.tr(context),
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureCard(
                        icon: Icons.payments_outlined,
                        title: 'Earn Money'.tr(context),
                        description:
                            'Complete tasks and receive payments'.tr(context),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Gradient CTA button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: GlassButton(
                    label: 'Go to Dashboard'.tr(context),
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _goToDashboard,
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    borderColor: AppColors.accentLight.withValues(alpha: 0.5),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.accent,
                        AppColors.accentDark,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textTertiaryLight,
          ),
        ],
      ),
    );
  }
}

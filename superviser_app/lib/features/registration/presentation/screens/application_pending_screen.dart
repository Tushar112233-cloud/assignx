import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/registration_provider.dart';

/// Application Pending Screen (S09)
///
/// Shows when supervisor application is submitted and awaiting review.
class ApplicationPendingScreen extends ConsumerStatefulWidget {
  const ApplicationPendingScreen({super.key});

  @override
  ConsumerState<ApplicationPendingScreen> createState() =>
      _ApplicationPendingScreenState();
}

class _ApplicationPendingScreenState
    extends ConsumerState<ApplicationPendingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animated waiting icon pulse
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Check current application status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationProvider.notifier).checkApplicationStatus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return Scaffold(
      body: MeshGradientBackground(
        position: MeshPosition.center,
        colors: MeshColors.warmColors,
        opacity: 0.5,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                _buildStatusContent(state.applicationStatus),
                const Spacer(),
                _buildActionButton(context, state.applicationStatus),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusContent(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return _buildPendingContent();
      case ApplicationStatus.underReview:
        return _buildUnderReviewContent();
      case ApplicationStatus.approved:
        return _buildApprovedContent();
      case ApplicationStatus.rejected:
        return _buildRejectedContent();
      case ApplicationStatus.needsRevision:
        return _buildNeedsRevisionContent();
      case ApplicationStatus.none:
        return _buildPendingContent();
    }
  }

  Widget _buildPendingContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated waiting icon
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.hourglass_top_rounded,
              size: 64,
              color: AppColors.accent,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Application Submitted!'.tr(context),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Thank you for applying to become a supervisor at AssignX.'
              .tr(context),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Glass hero card
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule, color: AppColors.info, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Under Review'.tr(context),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your application is in the queue. Our team reviews applications within 2-3 business days.'
                          .tr(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.email_outlined,
          text: 'We\'ll notify you via email once reviewed'.tr(context),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.notifications_outlined,
          text: 'You\'ll also receive an in-app notification'.tr(context),
        ),
      ],
    );
  }

  Widget _buildUnderReviewContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.2),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.info,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Under Review'.tr(context),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Our team is currently reviewing your application.'.tr(context),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_search_outlined,
                    color: AppColors.info, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Being Reviewed'.tr(context),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.info,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'A team member is actively reviewing your qualifications and experience.'
                          .tr(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withValues(alpha: 0.2),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Congratulations!'.tr(context),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your application has been approved. Welcome to the AssignX supervisor team!'
              .tr(context),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.celebration_outlined,
                    color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'re In!'.tr(context),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You can now access the supervisor dashboard and start accepting assignments.'
                          .tr(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel_outlined,
            size: 64,
            color: AppColors.error,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Application Not Approved'.tr(context),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Unfortunately, your application was not approved at this time.'
              .tr(context),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline,
                    color: AppColors.error, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s Next?'.tr(context),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You may reapply after 30 days. Consider enhancing your qualifications or expertise areas.'
                          .tr(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeedsRevisionContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.edit_note_outlined,
            size: 64,
            color: AppColors.warning,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Revision Needed'.tr(context),
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your application needs some updates before we can proceed.'
              .tr(context),
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        GlassCard(
          padding: const EdgeInsets.all(20),
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: AppColors.warning, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Action Required'.tr(context),
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Please review the feedback and update your application accordingly.'
                          .tr(context),
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiaryLight),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.approved:
        return PrimaryButton(
          text: 'Go to Dashboard'.tr(context),
          onPressed: () => context.go('/dashboard'),
          icon: Icons.dashboard_outlined,
        );
      case ApplicationStatus.needsRevision:
        return PrimaryButton(
          text: 'Edit Application'.tr(context),
          onPressed: () => context.go('/registration'),
          icon: Icons.edit_outlined,
        );
      case ApplicationStatus.rejected:
        return Column(
          children: [
            PrimaryButton(
              text: 'Contact Support'.tr(context),
              onPressed: () {
                // Open support dialog or email
              },
              icon: Icons.support_agent_outlined,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text('Back to Login'.tr(context)),
            ),
          ],
        );
      default:
        return Column(
          children: [
            SecondaryButton(
              text: 'Refresh Status'.tr(context),
              onPressed: () {
                ref
                    .read(registrationProvider.notifier)
                    .checkApplicationStatus();
              },
              icon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text('Sign Out'.tr(context)),
            ),
          ],
        );
    }
  }
}

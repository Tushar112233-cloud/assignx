import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
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
    extends ConsumerState<ApplicationPendingScreen> {
  @override
  void initState() {
    super.initState();
    // Check current application status
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationProvider.notifier).checkApplicationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationProvider);

    return Scaffold(
      body: SafeArea(
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
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            size: 64,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Application Submitted!',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Thank you for applying to become a supervisor at AssignX.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildStatusCard(
          icon: Icons.schedule,
          title: 'Under Review',
          description:
              'Your application is in the queue. Our team reviews applications within 2-3 business days.',
          color: AppColors.info,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(
          icon: Icons.email_outlined,
          text: 'We\'ll notify you via email once reviewed',
        ),
        const SizedBox(height: 8),
        _buildInfoRow(
          icon: Icons.notifications_outlined,
          text: 'You\'ll also receive an in-app notification',
        ),
      ],
    );
  }

  Widget _buildUnderReviewContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppColors.info,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Under Review',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Our team is currently reviewing your application.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildStatusCard(
          icon: Icons.person_search_outlined,
          title: 'Being Reviewed',
          description:
              'A team member is actively reviewing your qualifications and experience.',
          color: AppColors.info,
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
            color: AppColors.success.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Congratulations!',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your application has been approved. Welcome to the AssignX supervisor team!',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildStatusCard(
          icon: Icons.celebration_outlined,
          title: 'You\'re In!',
          description:
              'You can now access the supervisor dashboard and start accepting assignments.',
          color: AppColors.success,
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
            color: AppColors.error.withValues(alpha: 0.1),
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
          'Application Not Approved',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Unfortunately, your application was not approved at this time.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildStatusCard(
          icon: Icons.info_outline,
          title: 'What\'s Next?',
          description:
              'You may reapply after 30 days. Consider enhancing your qualifications or expertise areas.',
          color: AppColors.error,
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
            color: AppColors.warning.withValues(alpha: 0.1),
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
          'Revision Needed',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your application needs some updates before we can proceed.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildStatusCard(
          icon: Icons.assignment_outlined,
          title: 'Action Required',
          description:
              'Please review the feedback and update your application accordingly.',
          color: AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: color,
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
        ],
      ),
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
          text: 'Go to Dashboard',
          onPressed: () => context.go('/dashboard'),
          icon: Icons.dashboard_outlined,
        );
      case ApplicationStatus.needsRevision:
        return PrimaryButton(
          text: 'Edit Application',
          onPressed: () => context.go('/registration'),
          icon: Icons.edit_outlined,
        );
      case ApplicationStatus.rejected:
        return Column(
          children: [
            PrimaryButton(
              text: 'Contact Support',
              onPressed: () {
                // Open support dialog or email
              },
              icon: Icons.support_agent_outlined,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Back to Login'),
            ),
          ],
        );
      default:
        return Column(
          children: [
            SecondaryButton(
              text: 'Refresh Status',
              onPressed: () {
                ref.read(registrationProvider.notifier).checkApplicationStatus();
              },
              icon: Icons.refresh,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign Out'),
            ),
          ],
        );
    }
  }
}

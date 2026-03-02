import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Step metadata for the wizard progress header.
class WizardStepInfo {
  final String title;
  final String subtitle;
  final String proTip;

  const WizardStepInfo({
    required this.title,
    required this.subtitle,
    required this.proTip,
  });
}

/// Mobile-optimized progress header for the project wizard.
///
/// Shows:
/// - Step number/total with percentage circle
/// - Step title and subtitle
/// - Pro tip text box
/// - Trust badges (project count, rating, on-time delivery)
///
/// Adapts content per step automatically.
class WizardProgressHeader extends StatelessWidget {
  /// Current step index (0-based).
  final int currentStep;

  /// Total number of steps.
  final int totalSteps;

  const WizardProgressHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  /// Step definitions.
  static const List<WizardStepInfo> _steps = [
    WizardStepInfo(
      title: 'Choose Your Focus',
      subtitle: 'Select the subject area that matches your project',
      proTip: 'Be specific with your project type for better expert matching.',
    ),
    WizardStepInfo(
      title: 'Set Requirements',
      subtitle: 'Define what you need help with',
      proTip: 'Detailed requirements help us deliver exactly what you need.',
    ),
    WizardStepInfo(
      title: 'Upload & Deadline',
      subtitle: 'Add files and set your timeline',
      proTip: 'Longer deadlines often get better pricing. Plan ahead!',
    ),
    WizardStepInfo(
      title: 'Review & Submit',
      subtitle: 'Review your project details before submitting',
      proTip: 'Double-check everything before submitting for the best results.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final step = _steps[currentStep.clamp(0, _steps.length - 1)];
    final progress = (currentStep + 1) / totalSteps;
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: progress bar + percentage circle
          Row(
            children: [
              // Step indicator text
              Text(
                'Step ${currentStep + 1} of $totalSteps',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Progress bar
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withAlpha(50),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Percentage circle
              _PercentageCircle(percentage: percentage),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Step title
          Text(
            step.title,
            style: AppTextStyles.headingSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),

          // Step subtitle
          Text(
            step.subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withAlpha(200),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Pro tip box
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: Colors.white.withAlpha(30),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.amber.shade200,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    step.proTip,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white.withAlpha(220),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Trust badges
          const _TrustBadges(),
        ],
      ),
    );
  }
}

/// Circular percentage indicator.
class _PercentageCircle extends StatelessWidget {
  final int percentage;

  const _PercentageCircle({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.white.withAlpha(40),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
          Center(
            child: Text(
              '$percentage%',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Trust badges row showing platform statistics.
class _TrustBadges extends StatelessWidget {
  const _TrustBadges();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TrustBadge(
          icon: Icons.work_outline,
          label: '15,234 projects',
        ),
        const SizedBox(width: AppSpacing.sm),
        _TrustBadge(
          icon: Icons.star_outline,
          label: '4.9/5 rating',
        ),
        const SizedBox(width: AppSpacing.sm),
        _TrustBadge(
          icon: Icons.schedule,
          label: '98% on-time',
        ),
      ],
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustBadge({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 12,
              color: Colors.white.withAlpha(180),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white.withAlpha(180),
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

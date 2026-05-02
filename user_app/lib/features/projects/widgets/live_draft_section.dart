import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import 'progress_indicator.dart';

/// Live draft tracking section with progress and open button.
class LiveDraftSection extends StatelessWidget {
  final Project project;

  const LiveDraftSection({
    super.key,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final hasLiveDraft = project.liveDocumentUrl != null;
    final isAvailable = project.status == ProjectStatus.inProgress ||
        project.status == ProjectStatus.delivered ||
        project.status == ProjectStatus.completed ||
        project.status == ProjectStatus.autoApproved;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.visibility_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Progress Live',
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasLiveDraft
                          ? 'View real-time updates on your project'
                          : 'Live draft will be available soon',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Progress indicator (if in progress)
          if (project.status == ProjectStatus.inProgress &&
              project.progressPercentage > 0) ...[
            const SizedBox(height: 16),
            ProjectProgressIndicator(
              percent: project.progressPercentage,
              showLabel: true,
            ),
          ],

          const SizedBox(height: 16),

          // Open Live Draft button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isAvailable && hasLiveDraft
                  ? () => context.push('/projects/${project.id}/draft')
                  : null,
              icon: Icon(
                hasLiveDraft ? Icons.open_in_new : Icons.lock_outline,
                size: 18,
              ),
              label: Text(
                hasLiveDraft ? 'Open Live Draft' : 'Not Available Yet',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surfaceVariant,
                disabledForegroundColor: AppColors.textTertiary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // Note about read-only
          if (hasLiveDraft) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  'View only - editing is not allowed',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

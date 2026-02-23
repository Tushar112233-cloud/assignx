import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Section displaying AI and plagiarism quality badges.
class QualityBadgesSection extends StatelessWidget {
  final Project project;
  final VoidCallback? onDownloadAiReport;
  final VoidCallback? onDownloadPlagiarismReport;

  const QualityBadgesSection({
    super.key,
    required this.project,
    this.onDownloadAiReport,
    this.onDownloadPlagiarismReport,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = project.status == ProjectStatus.delivered ||
        project.status == ProjectStatus.completed ||
        project.status == ProjectStatus.autoApproved;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  color: isUnlocked ? AppColors.success : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quality Assurance',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (!isUnlocked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Locked',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Badges
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // AI Score Badge
                Expanded(
                  child: _QualityBadge(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI Check',
                    isUnlocked: isUnlocked,
                    isPassed: project.aiScore != null &&
                        project.aiScore! < 20,
                    passedText: 'Human Written',
                    lockedText: 'Pending',
                    score: project.aiScore?.toInt(),
                    onDownload: isUnlocked ? onDownloadAiReport : null,
                  ),
                ),

                const SizedBox(width: 12),

                // Plagiarism Badge
                Expanded(
                  child: _QualityBadge(
                    icon: Icons.fingerprint,
                    title: 'Plagiarism',
                    isUnlocked: isUnlocked,
                    isPassed: project.plagiarismScore != null &&
                        project.plagiarismScore! < 15,
                    passedText: 'Unique Content',
                    lockedText: 'Pending',
                    score: project.plagiarismScore?.toInt(),
                    onDownload: isUnlocked ? onDownloadPlagiarismReport : null,
                  ),
                ),
              ],
            ),
          ),

          // Note
          if (isUnlocked) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reports are generated using industry-standard tools',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isUnlocked;
  final bool isPassed;
  final String passedText;
  final String lockedText;
  final int? score;
  final VoidCallback? onDownload;

  const _QualityBadge({
    required this.icon,
    required this.title,
    required this.isUnlocked,
    required this.isPassed,
    required this.passedText,
    required this.lockedText,
    this.score,
    this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    final color = !isUnlocked
        ? AppColors.textTertiary
        : isPassed
            ? AppColors.success
            : AppColors.warning;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and title
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Status
          Row(
            children: [
              if (isUnlocked) ...[
                Icon(
                  isPassed ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color: color,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  isUnlocked
                      ? (isPassed ? passedText : '${score ?? 0}% detected')
                      : lockedText,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),

          // Download link
          if (isUnlocked && onDownload != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onDownload,
              child: Row(
                children: [
                  Icon(
                    Icons.download_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Download Report',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/connect_models.dart';
import '../../../shared/widgets/glass_container.dart';

/// Card widget for displaying study group information.
///
/// Shows group name, subject, member count, and next session time.
/// Includes join/leave functionality.
class StudyGroupCard extends StatelessWidget {
  /// The study group data to display.
  final StudyGroup group;

  /// Whether the current user has joined this group.
  final bool isJoined;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when join/leave button is pressed.
  final VoidCallback? onJoinLeave;

  const StudyGroupCard({
    super.key,
    required this.group,
    this.isJoined = false,
    this.onTap,
    this.onJoinLeave,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.85,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with avatar and info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group avatar
              _buildGroupAvatar(),
              const SizedBox(width: AppSpacing.sm),

              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      group.name,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Subject chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        group.subject,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Member count badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount}/${group.maxMembers}',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Description if available
          if (group.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              group.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Tags
          if (group.tags.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: group.tags.take(3).map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Divider
          Divider(
            color: AppColors.border.withAlpha(77),
            height: 1,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Bottom row: Next session and join button
          Row(
            children: [
              // Next session
              if (group.nextSessionTime != null) ...[
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    group.nextSessionString ?? 'No session scheduled',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else ...[
                Icon(
                  Icons.event_busy,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'No upcoming session',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],

              // Join/Leave button
              _buildActionButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(180),
            AppColors.primaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Center(
        child: Text(
          group.initials,
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '#$tag',
        style: AppTextStyles.caption.copyWith(
          fontSize: 10,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (group.isFull && !isJoined) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Text(
          'Full',
          style: AppTextStyles.buttonSmall.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return Material(
      color: isJoined ? AppColors.surfaceVariant : AppColors.primary,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onJoinLeave,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isJoined ? Icons.check : Icons.add,
                size: 14,
                color: isJoined ? AppColors.textSecondary : Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                isJoined ? 'Joined' : 'Join',
                style: AppTextStyles.buttonSmall.copyWith(
                  color: isJoined ? AppColors.textSecondary : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact study group card for horizontal lists.
class CompactStudyGroupCard extends StatelessWidget {
  final StudyGroup group;
  final bool isJoined;
  final VoidCallback? onTap;

  const CompactStudyGroupCard({
    super.key,
    required this.group,
    this.isJoined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 180,
      blur: 10,
      opacity: 0.8,
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar and joined badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(180),
                      AppColors.primaryDark,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    group.initials,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (isJoined)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Joined',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 9,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            group.name,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),

          // Subject
          Text(
            group.subject,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 8),

          // Member count and next session
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 2),
              Text(
                '${group.memberCount}',
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
              const Spacer(),
              if (group.nextSessionTime != null) ...[
                Icon(
                  Icons.schedule,
                  size: 12,
                  color: AppColors.success,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    group.nextSessionString ?? '',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: AppColors.success,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

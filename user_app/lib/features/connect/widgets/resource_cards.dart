import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/connect_models.dart';
import '../../../shared/widgets/glass_container.dart';

/// Card widget for displaying shared study resources.
///
/// Shows resource title, type, uploader info, and download stats.
/// Includes save/download functionality.
class ResourceCard extends StatelessWidget {
  /// The resource data to display.
  final SharedResource resource;

  /// Whether the current user has saved this resource.
  final bool isSaved;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when save button is pressed.
  final VoidCallback? onSave;

  /// Callback when download button is pressed.
  final VoidCallback? onDownload;

  const ResourceCard({
    super.key,
    required this.resource,
    this.isSaved = false,
    this.onTap,
    this.onSave,
    this.onDownload,
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
          // Header with type icon and verified badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type icon
              _buildTypeIcon(),
              const SizedBox(width: AppSpacing.sm),

              // Title and subject
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            resource.title,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (resource.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.info,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Subject and type
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor().withAlpha(26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            resource.type.label,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: _getTypeColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          resource.subject,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Description if available
          if (resource.description != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              resource.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Tags
          if (resource.tags.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: resource.tags.take(3).map((tag) => _buildTag(tag)).toList(),
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Uploader info
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.primaryLight.withAlpha(50),
                child: Text(
                  resource.uploaderInitials,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Name and time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.uploaderName,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      resource.timeAgo,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Divider
          const SizedBox(height: AppSpacing.sm),
          Divider(
            color: AppColors.border.withAlpha(77),
            height: 1,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Bottom row: Stats and actions
          Row(
            children: [
              // Rating
              Icon(
                Icons.star,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 2),
              Text(
                resource.ratingString,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (resource.ratingCount > 0) ...[
                Text(
                  ' (${resource.ratingCount})',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],

              const SizedBox(width: 12),

              // Downloads
              Icon(
                Icons.download_outlined,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 2),
              Text(
                '${resource.downloadCount}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const Spacer(),

              // Save button
              _buildIconButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? AppColors.primary : AppColors.textTertiary,
                onTap: onSave,
              ),

              const SizedBox(width: 8),

              // Download button
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: InkWell(
                  onTap: onDownload,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getDownloadIcon(),
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getDownloadLabel(),
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _getTypeColor().withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Icon(
        _getTypeIconData(),
        size: 22,
        color: _getTypeColor(),
      ),
    );
  }

  IconData _getTypeIconData() {
    switch (resource.type) {
      case ResourceType.notes:
        return Icons.description_outlined;
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.pastPaper:
        return Icons.quiz_outlined;
    }
  }

  Color _getTypeColor() {
    switch (resource.type) {
      case ResourceType.notes:
        return AppColors.categoryBlue;
      case ResourceType.video:
        return AppColors.error;
      case ResourceType.link:
        return AppColors.categoryTeal;
      case ResourceType.pastPaper:
        return AppColors.categoryIndigo;
    }
  }

  IconData _getDownloadIcon() {
    switch (resource.type) {
      case ResourceType.notes:
      case ResourceType.pastPaper:
        return Icons.download;
      case ResourceType.video:
        return Icons.play_arrow;
      case ResourceType.link:
        return Icons.open_in_new;
    }
  }

  String _getDownloadLabel() {
    switch (resource.type) {
      case ResourceType.notes:
      case ResourceType.pastPaper:
        return 'Download';
      case ResourceType.video:
        return 'Watch';
      case ResourceType.link:
        return 'Open';
    }
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

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}

/// Compact resource card for grid views.
class CompactResourceCard extends StatelessWidget {
  final SharedResource resource;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const CompactResourceCard({
    super.key,
    required this.resource,
    this.isSaved = false,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.8,
      padding: const EdgeInsets.all(AppSpacing.sm),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Type icon and save button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getTypeColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIconData(),
                  size: 18,
                  color: _getTypeColor(),
                ),
              ),
              GestureDetector(
                onTap: onSave,
                child: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  size: 20,
                  color: isSaved ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            resource.title,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Type and subject
          Row(
            children: [
              Text(
                resource.type.label,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: _getTypeColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  resource.subject,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Stats row
          Row(
            children: [
              Icon(
                Icons.star,
                size: 12,
                color: AppColors.warning,
              ),
              const SizedBox(width: 2),
              Text(
                resource.ratingString,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.download_outlined,
                size: 12,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 2),
              Text(
                '${resource.downloadCount}',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIconData() {
    switch (resource.type) {
      case ResourceType.notes:
        return Icons.description_outlined;
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.pastPaper:
        return Icons.quiz_outlined;
    }
  }

  Color _getTypeColor() {
    switch (resource.type) {
      case ResourceType.notes:
        return AppColors.categoryBlue;
      case ResourceType.video:
        return AppColors.error;
      case ResourceType.link:
        return AppColors.categoryTeal;
      case ResourceType.pastPaper:
        return AppColors.categoryIndigo;
    }
  }
}

/// Resource type filter chips.
class ResourceTypeChips extends StatelessWidget {
  final ResourceType? selectedType;
  final ValueChanged<ResourceType?> onTypeSelected;

  const ResourceTypeChips({
    super.key,
    this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // All chip
          _buildChip(
            label: 'All',
            icon: Icons.apps,
            isSelected: selectedType == null,
            onTap: () => onTypeSelected(null),
          ),
          const SizedBox(width: 8),

          // Type chips
          ...ResourceType.values.map((type) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildChip(
                label: type.label,
                icon: _getTypeIcon(type),
                isSelected: selectedType == type,
                onTap: () => onTypeSelected(type),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border.withAlpha(128),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(ResourceType type) {
    switch (type) {
      case ResourceType.notes:
        return Icons.description_outlined;
      case ResourceType.video:
        return Icons.play_circle_outline;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.pastPaper:
        return Icons.quiz_outlined;
    }
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/training_video_model.dart';

/// Card widget for displaying a training video thumbnail.
///
/// Shows thumbnail, title, duration, and progress.
class VideoThumbnailCard extends StatelessWidget {
  const VideoThumbnailCard({
    super.key,
    required this.video,
    required this.onTap,
    this.width,
    this.showProgress = true,
    this.showCategory = true,
  });

  /// Video to display.
  final TrainingVideoModel video;

  /// Called when card is tapped.
  final VoidCallback onTap;

  /// Fixed width (for horizontal lists).
  final double? width;

  /// Whether to show progress indicator.
  final bool showProgress;

  /// Whether to show category badge.
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    Image.network(
                      video.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: video.category.color.withValues(alpha: 0.2),
                          child: Icon(
                            video.category.icon,
                            size: 48,
                            color: video.category.color,
                          ),
                        );
                      },
                    ),
                    // Play overlay
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          video.isCompleted ? Icons.replay : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    // Duration badge
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Completed badge
                    if (video.isCompleted)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    // Required badge
                    if (video.isRequired && !video.isCompleted)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Progress indicator
                    if (showProgress && video.watchProgress > 0 && !video.isCompleted)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: LinearProgressIndicator(
                          value: video.watchProgress,
                          backgroundColor: Colors.black.withValues(alpha: 0.3),
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          minHeight: 3,
                        ),
                      ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and difficulty
                    if (showCategory)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: video.category.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.category.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: video.category.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: video.difficulty.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.difficulty.displayName,
                              style: TextStyle(
                                fontSize: 10,
                                color: video.difficulty.color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (showCategory) const SizedBox(height: 8),
                    // Title
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Instructor
                    if (video.instructor != null)
                      Text(
                        video.instructor!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact video list item.
class VideoListItem extends StatelessWidget {
  const VideoListItem({
    super.key,
    required this.video,
    required this.onTap,
  });

  final TrainingVideoModel video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 45,
              child: Image.network(
                video.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: video.category.color.withValues(alpha: 0.2),
                    child: Icon(
                      video.category.icon,
                      color: video.category.color,
                    ),
                  );
                },
              ),
            ),
          ),
          if (video.isCompleted)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
      title: Text(
        video.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Text(
            video.formattedDuration,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(width: 8),
          if (video.watchProgress > 0 && !video.isCompleted)
            Expanded(
              child: LinearProgressIndicator(
                value: video.watchProgress,
                backgroundColor: AppColors.textSecondaryLight.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
        ],
      ),
      trailing: Icon(
        Icons.play_circle_outline,
        color: AppColors.primary,
      ),
    );
  }
}

/// Video category chip.
class VideoCategoryChip extends StatelessWidget {
  const VideoCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
    this.count,
  });

  final VideoCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            category.icon,
            size: 16,
            color: isSelected ? Colors.white : category.color,
          ),
          const SizedBox(width: 4),
          Text(category.displayName),
          if (count != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white : category.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      backgroundColor: category.color.withValues(alpha: 0.1),
      selectedColor: category.color,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : category.color,
        fontWeight: FontWeight.w600,
      ),
      showCheckmark: false,
    );
  }
}

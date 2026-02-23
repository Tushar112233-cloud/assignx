import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/training_video_model.dart';
import 'video_thumbnail_card.dart';

/// Training library widget.
///
/// Shows videos organized by category with progress tracking.
class TrainingLibrary extends StatelessWidget {
  const TrainingLibrary({
    super.key,
    required this.videos,
    required this.videosByCategory,
    required this.onVideoTap,
    this.selectedCategory,
    this.onCategorySelected,
    this.searchQuery = '',
    this.onSearchChanged,
  });

  /// All videos.
  final List<TrainingVideoModel> videos;

  /// Videos grouped by category.
  final Map<VideoCategory, List<TrainingVideoModel>> videosByCategory;

  /// Called when a video is tapped.
  final void Function(TrainingVideoModel video) onVideoTap;

  /// Currently selected category filter.
  final VideoCategory? selectedCategory;

  /// Called when category filter changes.
  final void Function(VideoCategory?)? onCategorySelected;

  /// Current search query.
  final String searchQuery;

  /// Called when search query changes.
  final void Function(String)? onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress overview
        _ProgressOverview(videos: videos),
        const SizedBox(height: 16),
        // Search bar
        if (onSearchChanged != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search videos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => onSearchChanged!(''),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        // Category chips
        if (onCategorySelected != null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  selected: selectedCategory == null,
                  onSelected: (_) => onCategorySelected!(null),
                  label: const Text('All'),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  showCheckmark: false,
                ),
                const SizedBox(width: 8),
                ...VideoCategory.values.map((category) {
                  final count = videosByCategory[category]?.length ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: VideoCategoryChip(
                      category: category,
                      isSelected: selectedCategory == category,
                      onTap: () => onCategorySelected!(
                        selectedCategory == category ? null : category,
                      ),
                      count: count,
                    ),
                  );
                }),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Video grid or category sections
        if (selectedCategory != null || searchQuery.isNotEmpty)
          _FilteredVideoGrid(
            videos: _getFilteredVideos(),
            onVideoTap: onVideoTap,
          )
        else
          _CategorySections(
            videosByCategory: videosByCategory,
            onVideoTap: onVideoTap,
          ),
      ],
    );
  }

  List<TrainingVideoModel> _getFilteredVideos() {
    var filtered = selectedCategory != null
        ? videosByCategory[selectedCategory] ?? []
        : videos;

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((v) {
        return v.title.toLowerCase().contains(query) ||
            v.description.toLowerCase().contains(query) ||
            v.tags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    }

    return filtered;
  }
}

/// Progress overview card.
class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview({required this.videos});

  final List<TrainingVideoModel> videos;

  @override
  Widget build(BuildContext context) {
    final required = videos.where((v) => v.isRequired).toList();
    final completedRequired = required.where((v) => v.isCompleted).length;
    final totalCompleted = videos.where((v) => v.isCompleted).length;
    final progress = required.isEmpty ? 1.0 : completedRequired / required.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(width: 8),
              Text(
                'Training Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              _StatItem(
                label: 'Required',
                value: '$completedRequired/${required.length}',
              ),
              const SizedBox(width: 24),
              _StatItem(
                label: 'Completed',
                value: '$totalCompleted/${videos.length}',
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat item for progress overview.
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

/// Filtered video grid.
class _FilteredVideoGrid extends StatelessWidget {
  const _FilteredVideoGrid({
    required this.videos,
    required this.onVideoTap,
  });

  final List<TrainingVideoModel> videos;
  final void Function(TrainingVideoModel) onVideoTap;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.video_library_outlined,
                size: 64,
                color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No videos found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final video = videos[index];
        return VideoThumbnailCard(
          video: video,
          onTap: () => onVideoTap(video),
        );
      },
    );
  }
}

/// Category sections with horizontal scrolling.
class _CategorySections extends StatelessWidget {
  const _CategorySections({
    required this.videosByCategory,
    required this.onVideoTap,
  });

  final Map<VideoCategory, List<TrainingVideoModel>> videosByCategory;
  final void Function(TrainingVideoModel) onVideoTap;

  @override
  Widget build(BuildContext context) {
    final categories = videosByCategory.entries
        .where((e) => e.value.isNotEmpty)
        .toList()
      ..sort((a, b) => a.key.index.compareTo(b.key.index));

    return Column(
      children: categories.map((entry) {
        return _CategorySection(
          category: entry.key,
          videos: entry.value,
          onVideoTap: onVideoTap,
        );
      }).toList(),
    );
  }
}

/// Single category section.
class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.videos,
    required this.onVideoTap,
  });

  final VideoCategory category;
  final List<TrainingVideoModel> videos;
  final void Function(TrainingVideoModel) onVideoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                category.displayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  videos.length.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    color: category.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Horizontal video list
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < videos.length - 1 ? 12 : 0,
                ),
                child: VideoThumbnailCard(
                  video: video,
                  onTap: () => onVideoTap(video),
                  width: 180,
                  showCategory: false,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

/// Continue watching section.
class ContinueWatching extends StatelessWidget {
  const ContinueWatching({
    super.key,
    required this.videos,
    required this.onVideoTap,
  });

  /// Videos currently in progress.
  final List<TrainingVideoModel> videos;

  /// Called when a video is tapped.
  final void Function(TrainingVideoModel) onVideoTap;

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.play_circle, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Continue Watching',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < videos.length - 1 ? 12 : 0,
                ),
                child: _ContinueWatchingItem(
                  video: video,
                  onTap: () => onVideoTap(video),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Continue watching item.
class _ContinueWatchingItem extends StatelessWidget {
  const _ContinueWatchingItem({
    required this.video,
    required this.onTap,
  });

  final TrainingVideoModel video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: SizedBox(
                width: 100,
                height: 130,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
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
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${video.watchProgressPercent}% completed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: video.watchProgress,
                      backgroundColor: AppColors.textSecondaryLight.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

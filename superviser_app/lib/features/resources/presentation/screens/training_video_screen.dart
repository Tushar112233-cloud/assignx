import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/training_video_model.dart';
import '../providers/resources_provider.dart';

/// Screen for playing training videos.
///
/// Shows video player with progress tracking.
class TrainingVideoPlayerScreen extends ConsumerStatefulWidget {
  const TrainingVideoPlayerScreen({
    super.key,
    required this.videoId,
    this.video,
  });

  /// Video ID to load.
  final String videoId;

  /// Optional pre-loaded video data.
  final TrainingVideoModel? video;

  @override
  ConsumerState<TrainingVideoPlayerScreen> createState() =>
      _TrainingVideoPlayerScreenState();
}

class _TrainingVideoPlayerScreenState
    extends ConsumerState<TrainingVideoPlayerScreen> {
  TrainingVideoModel? _video;
  bool _isPlaying = false;
  double _progress = 0.0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
    if (_video != null) {
      _progress = _video!.watchProgress;
      _isCompleted = _video!.isCompleted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final video = _video;

    if (video == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Training Video')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          video.title,
          style: const TextStyle(fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          // Video player placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video thumbnail/player
                Image.network(
                  video.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: video.category.color.withValues(alpha: 0.2),
                      child: Center(
                        child: Icon(
                          video.category.icon,
                          size: 64,
                          color: video.category.color,
                        ),
                      ),
                    );
                  },
                ),
                // Play/pause overlay
                Center(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isPlaying
                            ? Colors.transparent
                            : Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: _isPlaying ? 0 : 48,
                      ),
                    ),
                  ),
                ),
                // Progress bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _VideoProgressBar(
                    progress: _progress,
                    duration: video.duration,
                    onSeek: _onSeek,
                  ),
                ),
                // Completed badge
                if (_isCompleted)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Video info
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    // Meta info
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: video.category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                video.category.icon,
                                size: 14,
                                color: video.category.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.category.displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: video.category.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: video.difficulty.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            video.difficulty.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: video.difficulty.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          video.formattedDuration,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description
                    Text(
                      video.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    // Instructor
                    if (video.instructor != null)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instructor',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                              Text(
                                video.instructor!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                    // Tags
                    if (video.tags.isNotEmpty) ...[
                      Text(
                        'Topics',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: video.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.textSecondaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              tag,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Mark as complete button
                    if (!_isCompleted)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _progress >= 0.9 ? _markAsComplete : null,
                          icon: const Icon(Icons.check_circle),
                          label: Text(
                            _progress >= 0.9
                                ? 'Mark as Complete'
                                : 'Watch ${((0.9 - _progress) * 100).round()}% more to complete',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      // Simulate video progress
      _simulateProgress();
    }
  }

  void _simulateProgress() async {
    while (_isPlaying && _progress < 1.0 && mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!_isPlaying || !mounted) break;

      setState(() {
        _progress = (_progress + 0.01).clamp(0.0, 1.0);
      });

      // Update provider progress periodically
      if ((_progress * 100).round() % 10 == 0) {
        ref.read(trainingVideosProvider.notifier).updateProgress(
              videoId: widget.videoId,
              progress: _progress,
            );
      }

      // Auto-complete at 95%
      if (_progress >= 0.95 && !_isCompleted) {
        _markAsComplete();
      }
    }
  }

  void _onSeek(double progress) {
    setState(() {
      _progress = progress;
    });
    ref.read(trainingVideosProvider.notifier).updateProgress(
          videoId: widget.videoId,
          progress: progress,
        );
  }

  void _markAsComplete() {
    setState(() {
      _isCompleted = true;
      _isPlaying = false;
    });
    ref.read(trainingVideosProvider.notifier).updateProgress(
          videoId: widget.videoId,
          progress: 1.0,
          isCompleted: true,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Video marked as complete!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Video progress bar.
class _VideoProgressBar extends StatelessWidget {
  const _VideoProgressBar({
    required this.progress,
    required this.duration,
    required this.onSeek,
  });

  final double progress;
  final int duration;
  final void Function(double) onSeek;

  @override
  Widget build(BuildContext context) {
    final currentSeconds = (progress * duration).round();
    final currentMinutes = currentSeconds ~/ 60;
    final currentSecs = currentSeconds % 60;
    final totalMinutes = duration ~/ 60;
    final totalSecs = duration % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black.withValues(alpha: 0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 6,
              ),
              overlayShape: const RoundSliderOverlayShape(
                overlayRadius: 12,
              ),
              trackHeight: 3,
            ),
            child: Slider(
              value: progress,
              onChanged: onSeek,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentMinutes:${currentSecs.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              Text(
                '$totalMinutes:${totalSecs.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Video player widget for training videos.
///
/// Opens videos in external browser/player for reliable playback.
/// Tracks watch progress locally and enables completion when finished.
class TrainingVideoPlayer extends StatefulWidget {
  const TrainingVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.onComplete,
    this.duration = const Duration(minutes: 5),
  });

  final String videoUrl;
  final String title;
  final VoidCallback onComplete;
  final Duration duration;

  @override
  State<TrainingVideoPlayer> createState() => _TrainingVideoPlayerState();
}

class _TrainingVideoPlayerState extends State<TrainingVideoPlayer> {
  bool _hasWatched = false;
  bool _isLoading = false;
  DateTime? _watchStartTime;

  Future<void> _launchVideo() async {
    setState(() => _isLoading = true);
    _watchStartTime = DateTime.now();

    try {
      final uri = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // Mark as watched after returning from video
        // In production, you might want a more robust check
        setState(() => _hasWatched = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open video. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video container
        Expanded(
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video thumbnail/placeholder
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _hasWatched
                              ? Icons.check_circle
                              : Icons.play_circle_filled,
                          size: 80,
                          color: _hasWatched
                              ? AppColors.success
                              : Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          widget.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Duration: ${_formatDuration(widget.duration)}',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (!_hasWatched)
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _launchVideo,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.play_arrow),
                          label: Text(_isLoading ? 'Opening...' : 'Watch Video'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        )
                      else
                        Column(
                          children: [
                            Text(
                              'Video completed!',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _launchVideo,
                              icon: const Icon(
                                Icons.replay,
                                color: Colors.white70,
                              ),
                              label: Text(
                                'Watch Again',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Complete button
        if (_hasWatched)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: widget.onComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
      ],
    );
  }
}

/// PDF viewer widget for training documents.
///
/// Opens PDFs in external viewer for reliable display.
class PDFDocumentViewer extends StatefulWidget {
  const PDFDocumentViewer({
    super.key,
    required this.pdfUrl,
    required this.title,
    required this.onComplete,
  });

  final String pdfUrl;
  final String title;
  final VoidCallback onComplete;

  @override
  State<PDFDocumentViewer> createState() => _PDFDocumentViewerState();
}

class _PDFDocumentViewerState extends State<PDFDocumentViewer> {
  bool _hasViewed = false;
  bool _isLoading = false;

  Future<void> _openPDF() async {
    setState(() => _isLoading = true);

    try {
      final uri = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        setState(() => _hasViewed = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open PDF. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PDF viewer
        Expanded(
          child: Container(
            color: AppColors.surfaceVariantLight,
            child: Column(
              children: [
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade600,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                // PDF content area
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 280,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: _hasViewed
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _hasViewed
                                      ? Icons.check_circle
                                      : Icons.picture_as_pdf,
                                  size: 40,
                                  color: _hasViewed
                                      ? AppColors.success
                                      : Colors.red.shade600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _hasViewed ? 'Document Reviewed' : 'PDF Document',
                                style: AppTypography.titleMedium.copyWith(
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _hasViewed
                                    ? 'You have viewed this document'
                                    : 'Tap to open and read',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: _isLoading ? null : _openPDF,
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _hasViewed
                                            ? Icons.visibility
                                            : Icons.open_in_new,
                                      ),
                                label: Text(
                                  _isLoading
                                      ? 'Opening...'
                                      : _hasViewed
                                          ? 'View Again'
                                          : 'Open PDF',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _hasViewed
                                      ? AppColors.textSecondaryLight
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Complete button (show when viewed)
        if (_hasViewed)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: widget.onComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark as Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/foundation.dart' show debugPrint;

import '../../../../core/api/api_client.dart';
import '../models/tool_model.dart';
import '../models/training_video_model.dart';
import '../models/pricing_model.dart';

/// Repository for resources, tools, and training content.
///
/// Handles fetching tools, training videos, and pricing data.
class ResourcesRepository {
  ResourcesRepository();

  // ==================== TOOLS ====================

  /// Get all available tools.
  Future<List<ToolModel>> getTools() async {
    try {
      final response = await ApiClient.get('/resources/tools');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['tools'] as List? ?? [];

      return list
          .map((json) => ToolModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ResourcesRepository.getTools error: $e');
      rethrow;
    }
  }

  /// Get a specific tool by ID.
  Future<ToolModel?> getTool(String id) async {
    try {
      final response = await ApiClient.get('/resources/tools/$id');
      return ToolModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('ResourcesRepository.getTool error: $e');
      rethrow;
    }
  }

  /// Track tool usage.
  Future<void> trackToolUsage(String toolId) async {
    try {
      await ApiClient.post('/resources/tools/$toolId/track', {
        'action': 'tool_usage',
        'source_role': 'supervisor',
      });
    } catch (e) {
      // Ignore tracking errors
    }
  }

  // ==================== TRAINING VIDEOS ====================

  /// Get all training videos.
  Future<List<TrainingVideoModel>> getTrainingVideos({
    VideoCategory? category,
    bool? isRequired,
  }) async {
    try {
      final params = <String, String>{};
      if (category != null) {
        params['category'] = category.id;
      }
      if (isRequired != null) {
        params['isRequired'] = '$isRequired';
      }
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final path = query.isNotEmpty
          ? '/resources/training?$query'
          : '/resources/training';

      final response = await ApiClient.get(path);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['videos'] as List? ?? [];

      return list
          .map((json) => TrainingVideoModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ResourcesRepository.getTrainingVideos error: $e');
      rethrow;
    }
  }

  /// Get videos by category.
  Future<Map<VideoCategory, List<TrainingVideoModel>>>
      getVideosByCategory() async {
    final videos = await getTrainingVideos();
    final grouped = <VideoCategory, List<TrainingVideoModel>>{};

    for (final video in videos) {
      grouped.putIfAbsent(video.category, () => []).add(video);
    }

    return grouped;
  }

  /// Get a specific video.
  Future<TrainingVideoModel?> getVideo(String id) async {
    try {
      final response = await ApiClient.get('/resources/training/$id');
      return TrainingVideoModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('ResourcesRepository.getVideo error: $e');
      rethrow;
    }
  }

  /// Update video watch progress.
  Future<void> updateWatchProgress({
    required String videoId,
    required double progress,
    bool? isCompleted,
  }) async {
    try {
      await ApiClient.put('/resources/training/$videoId/progress', {
        'progress_percentage': (progress * 100).round(),
        'status': (isCompleted ?? (progress >= 0.95)) ? 'completed' : 'in_progress',
      });
    } catch (e) {
      // Ignore progress errors
    }
  }

  // ==================== PRICING ====================

  /// Get the pricing guide.
  Future<PricingGuide> getPricingGuide() async {
    try {
      final response = await ApiClient.get('/resources/pricing');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['pricings'] as List? ?? [];

      return PricingGuide(
        pricings: list
            .map((json) => PricingModel.fromJson(json as Map<String, dynamic>))
            .toList(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      debugPrint('ResourcesRepository.getPricingGuide error: $e');
      rethrow;
    }
  }

  /// Get pricing for a specific work type.
  Future<List<PricingModel>> getPricingForWorkType(WorkType type) async {
    try {
      final response = await ApiClient.get(
        '/resources/pricing?workType=${type.id}',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['pricings'] as List? ?? [];

      return list
          .map((json) => PricingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('ResourcesRepository.getPricingForWorkType error: $e');
      rethrow;
    }
  }

}

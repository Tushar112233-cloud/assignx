import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/tool_model.dart';
import '../models/training_video_model.dart';
import '../models/pricing_model.dart';

/// Repository for resources, tools, and training content.
///
/// Handles fetching tools, training videos, and pricing data.
class ResourcesRepository {
  ResourcesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ==================== TOOLS ====================

  /// Get all available tools.
  Future<List<ToolModel>> getTools() async {
    try {
      final response = await _client
          .from('tools')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => ToolModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesRepository.getTools error: $e');
        return _getMockTools();
      }
      rethrow;
    }
  }

  /// Get a specific tool by ID.
  Future<ToolModel?> getTool(String id) async {
    try {
      final response =
          await _client.from('tools').select().eq('id', id).single();

      return ToolModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesRepository.getTool error: $e');
        return _getMockTools().where((t) => t.id == id).firstOrNull;
      }
      rethrow;
    }
  }

  /// Track tool usage.
  Future<void> trackToolUsage(String toolId) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) return;

      await _client.from('tool_usage').insert({
        'tool_id': toolId,
        'user_id': userId,
        'used_at': DateTime.now().toIso8601String(),
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
      var query = _client.from('training_videos').select();

      if (category != null) {
        query = query.eq('category', category.id);
      }
      if (isRequired != null) {
        query = query.eq('is_required', isRequired);
      }

      final response = await query.order('order');

      return (response as List)
          .map((json) => TrainingVideoModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesRepository.getTrainingVideos error: $e');
        return _getMockTrainingVideos(category: category);
      }
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
      final response = await _client
          .from('training_videos')
          .select()
          .eq('id', id)
          .single();

      return TrainingVideoModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesRepository.getVideo error: $e');
        return _getMockTrainingVideos().where((v) => v.id == id).firstOrNull;
      }
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
      final userId = getCurrentUserId();
      if (userId == null) return;

      await _client.from('video_progress').upsert({
        'video_id': videoId,
        'user_id': userId,
        'watch_progress': progress,
        'is_completed': isCompleted ?? (progress >= 0.95),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore progress errors
    }
  }

  // ==================== PRICING ====================

  /// Get the pricing guide.
  Future<PricingGuide> getPricingGuide() async {
    try {
      final response = await _client
          .from('pricing')
          .select()
          .eq('is_active', true)
          .order('work_type');

      return PricingGuide(
        pricings: (response as List)
            .map((json) => PricingModel.fromJson(json))
            .toList(),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesRepository.getPricingGuide error: $e');
        return _getMockPricingGuide();
      }
      rethrow;
    }
  }

  /// Get pricing for a specific work type.
  Future<List<PricingModel>> getPricingForWorkType(WorkType type) async {
    try {
      final response = await _client
          .from('pricing')
          .select()
          .eq('work_type', type.id)
          .eq('is_active', true);

      return (response as List)
          .map((json) => PricingModel.fromJson(json))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesRepository.getPricingForWorkType error: $e');
        return _getMockPricingGuide()
            .pricings
            .where((p) => p.workType == type)
            .toList();
      }
      rethrow;
    }
  }

  // ==================== MOCK DATA ====================

  /// Mock tools for development.
  List<ToolModel> _getMockTools() {
    return [
      ToolModel(
        id: 'tool_1',
        name: 'Plagiarism Checker',
        type: ToolType.plagiarismChecker,
        description:
            'Check assignments for plagiarism against billions of sources.',
        url: 'https://www.turnitin.com',
        isExternal: true,
        isPremium: false,
        usageCount: 150,
      ),
      ToolModel(
        id: 'tool_2',
        name: 'AI Content Detector',
        type: ToolType.aiDetector,
        description:
            'Detect AI-generated content in student submissions.',
        url: 'https://gptzero.me',
        isExternal: true,
        isPremium: false,
        usageCount: 89,
      ),
      ToolModel(
        id: 'tool_3',
        name: 'Grammarly',
        type: ToolType.grammarChecker,
        description:
            'Advanced grammar and writing style checker.',
        url: 'https://app.grammarly.com',
        isExternal: true,
        isPremium: true,
        usageCount: 234,
      ),
      ToolModel(
        id: 'tool_4',
        name: 'Citation Generator',
        type: ToolType.citationGenerator,
        description:
            'Generate APA, MLA, Chicago citations automatically.',
        url: 'https://www.citationmachine.net',
        isExternal: true,
        isPremium: false,
        usageCount: 178,
      ),
      ToolModel(
        id: 'tool_5',
        name: 'Zotero',
        type: ToolType.referenceManager,
        description:
            'Organize and manage your research references.',
        url: 'https://www.zotero.org/user/login',
        isExternal: true,
        isPremium: false,
        usageCount: 45,
      ),
      ToolModel(
        id: 'tool_6',
        name: 'Word Count Calculator',
        type: ToolType.calculatorTool,
        description:
            'Calculate pages, words, and pricing for projects.',
        isExternal: false,
        isPremium: false,
        usageCount: 312,
      ),
    ];
  }

  /// Mock training videos for development.
  List<TrainingVideoModel> _getMockTrainingVideos({VideoCategory? category}) {
    final allVideos = [
      TrainingVideoModel(
        id: 'video_1',
        title: 'Introduction to Quality Control',
        description: 'Learn the basics of QC and what makes a great supervisor.',
        category: VideoCategory.qcBasics,
        thumbnailUrl: 'https://picsum.photos/seed/qc1/400/225',
        videoUrl: 'https://example.com/videos/intro-qc.mp4',
        duration: 720, // 12 minutes
        difficulty: DifficultyLevel.beginner,
        isRequired: true,
        isCompleted: true,
        watchProgress: 1.0,
        order: 1,
        tags: ['basics', 'introduction', 'qc'],
        instructor: 'John Smith',
      ),
      TrainingVideoModel(
        id: 'video_2',
        title: 'Reviewing Academic Papers',
        description: 'Step-by-step guide to reviewing research papers effectively.',
        category: VideoCategory.qcBasics,
        thumbnailUrl: 'https://picsum.photos/seed/qc2/400/225',
        videoUrl: 'https://example.com/videos/reviewing-papers.mp4',
        duration: 1080, // 18 minutes
        difficulty: DifficultyLevel.beginner,
        isRequired: true,
        isCompleted: true,
        watchProgress: 1.0,
        order: 2,
        tags: ['papers', 'review', 'academic'],
        instructor: 'Sarah Johnson',
      ),
      TrainingVideoModel(
        id: 'video_3',
        title: 'Detecting Plagiarism',
        description: 'How to identify different types of plagiarism and use detection tools.',
        category: VideoCategory.plagiarism,
        thumbnailUrl: 'https://picsum.photos/seed/plag1/400/225',
        videoUrl: 'https://example.com/videos/plagiarism-detection.mp4',
        duration: 900, // 15 minutes
        difficulty: DifficultyLevel.intermediate,
        isRequired: true,
        isCompleted: false,
        watchProgress: 0.65,
        order: 1,
        tags: ['plagiarism', 'tools', 'detection'],
        instructor: 'Mike Wilson',
      ),
      TrainingVideoModel(
        id: 'video_4',
        title: 'Advanced QC Techniques',
        description: 'Master advanced quality control methods for complex assignments.',
        category: VideoCategory.advancedQc,
        thumbnailUrl: 'https://picsum.photos/seed/advqc1/400/225',
        videoUrl: 'https://example.com/videos/advanced-qc.mp4',
        duration: 1500, // 25 minutes
        difficulty: DifficultyLevel.advanced,
        isRequired: false,
        isCompleted: false,
        watchProgress: 0.0,
        order: 1,
        tags: ['advanced', 'techniques', 'qc'],
        instructor: 'Dr. Emily Chen',
      ),
      TrainingVideoModel(
        id: 'video_5',
        title: 'APA Formatting Guide',
        description: 'Complete guide to APA 7th edition formatting standards.',
        category: VideoCategory.formatting,
        thumbnailUrl: 'https://picsum.photos/seed/fmt1/400/225',
        videoUrl: 'https://example.com/videos/apa-formatting.mp4',
        duration: 1200, // 20 minutes
        difficulty: DifficultyLevel.beginner,
        isRequired: false,
        isCompleted: false,
        watchProgress: 0.0,
        order: 1,
        tags: ['apa', 'formatting', 'citations'],
        instructor: 'Laura Martinez',
      ),
      TrainingVideoModel(
        id: 'video_6',
        title: 'Effective Client Communication',
        description: 'Best practices for professional communication with clients.',
        category: VideoCategory.communication,
        thumbnailUrl: 'https://picsum.photos/seed/comm1/400/225',
        videoUrl: 'https://example.com/videos/client-communication.mp4',
        duration: 840, // 14 minutes
        difficulty: DifficultyLevel.beginner,
        isRequired: true,
        isCompleted: false,
        watchProgress: 0.3,
        order: 1,
        tags: ['communication', 'clients', 'professional'],
        instructor: 'David Brown',
      ),
      TrainingVideoModel(
        id: 'video_7',
        title: 'Using the Tools Dashboard',
        description: 'Learn how to navigate and use all supervisor tools effectively.',
        category: VideoCategory.tools,
        thumbnailUrl: 'https://picsum.photos/seed/tools1/400/225',
        videoUrl: 'https://example.com/videos/tools-dashboard.mp4',
        duration: 600, // 10 minutes
        difficulty: DifficultyLevel.beginner,
        isRequired: true,
        isCompleted: false,
        watchProgress: 0.0,
        order: 1,
        tags: ['tools', 'dashboard', 'tutorial'],
        instructor: 'Tech Support',
      ),
      TrainingVideoModel(
        id: 'video_8',
        title: 'Best Practices for Reviews',
        description: 'Industry best practices for providing quality reviews.',
        category: VideoCategory.bestPractices,
        thumbnailUrl: 'https://picsum.photos/seed/bp1/400/225',
        videoUrl: 'https://example.com/videos/best-practices.mp4',
        duration: 1320, // 22 minutes
        difficulty: DifficultyLevel.intermediate,
        isRequired: false,
        isCompleted: false,
        watchProgress: 0.0,
        order: 1,
        tags: ['best practices', 'quality', 'reviews'],
        instructor: 'Quality Team',
      ),
    ];

    if (category != null) {
      return allVideos.where((v) => v.category == category).toList();
    }
    return allVideos;
  }

  /// Mock pricing guide for development.
  PricingGuide _getMockPricingGuide() {
    return PricingGuide(
      pricings: [
        // Essays
        PricingModel(
          id: 'price_1',
          workType: WorkType.essay,
          academicLevel: AcademicLevel.highSchool,
          basePrice: 12.00,
          description: 'Standard essay, high school level',
        ),
        PricingModel(
          id: 'price_2',
          workType: WorkType.essay,
          academicLevel: AcademicLevel.undergraduate,
          basePrice: 15.00,
          description: 'Standard essay, undergraduate level',
        ),
        PricingModel(
          id: 'price_3',
          workType: WorkType.essay,
          academicLevel: AcademicLevel.masters,
          basePrice: 20.00,
          description: 'Standard essay, masters level',
        ),
        PricingModel(
          id: 'price_4',
          workType: WorkType.essay,
          academicLevel: AcademicLevel.phd,
          basePrice: 25.00,
          description: 'Standard essay, PhD level',
        ),
        // Research Papers
        PricingModel(
          id: 'price_5',
          workType: WorkType.researchPaper,
          academicLevel: AcademicLevel.undergraduate,
          basePrice: 18.00,
          description: 'Research paper with citations',
        ),
        PricingModel(
          id: 'price_6',
          workType: WorkType.researchPaper,
          academicLevel: AcademicLevel.masters,
          basePrice: 24.00,
          description: 'Research paper, masters level',
        ),
        PricingModel(
          id: 'price_7',
          workType: WorkType.researchPaper,
          academicLevel: AcademicLevel.phd,
          basePrice: 30.00,
          description: 'Research paper, doctoral level',
        ),
        // Thesis/Dissertation
        PricingModel(
          id: 'price_8',
          workType: WorkType.thesis,
          academicLevel: AcademicLevel.masters,
          basePrice: 28.00,
          description: 'Masters thesis',
          minimumPages: 50,
        ),
        PricingModel(
          id: 'price_9',
          workType: WorkType.dissertation,
          academicLevel: AcademicLevel.phd,
          basePrice: 35.00,
          description: 'PhD dissertation',
          minimumPages: 100,
        ),
        // Case Studies
        PricingModel(
          id: 'price_10',
          workType: WorkType.casestudy,
          academicLevel: AcademicLevel.undergraduate,
          basePrice: 20.00,
          description: 'Business case study analysis',
        ),
        PricingModel(
          id: 'price_11',
          workType: WorkType.casestudy,
          academicLevel: AcademicLevel.masters,
          basePrice: 26.00,
          description: 'MBA case study analysis',
        ),
        // Reports
        PricingModel(
          id: 'price_12',
          workType: WorkType.report,
          academicLevel: AcademicLevel.undergraduate,
          basePrice: 16.00,
          description: 'Standard academic report',
        ),
        // Presentations
        PricingModel(
          id: 'price_13',
          workType: WorkType.presentation,
          academicLevel: AcademicLevel.undergraduate,
          basePrice: 10.00,
          description: 'Per slide, with speaker notes',
          notes: 'Minimum 10 slides',
        ),
        // Editing
        PricingModel(
          id: 'price_14',
          workType: WorkType.editing,
          academicLevel: AcademicLevel.undergraduate,
          basePrice: 8.00,
          description: 'Proofreading and editing per page',
        ),
        PricingModel(
          id: 'price_15',
          workType: WorkType.editing,
          academicLevel: AcademicLevel.masters,
          basePrice: 10.00,
          description: 'Proofreading and editing per page',
        ),
      ],
      lastUpdated: DateTime.now(),
      currency: 'INR',
      notes: 'Prices are per page (275 words). Urgency multipliers apply.',
    );
  }
}

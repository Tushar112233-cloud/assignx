import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/tool_model.dart';
import '../../data/models/training_video_model.dart';
import '../../data/models/pricing_model.dart';
import '../../data/repositories/resources_repository.dart';

/// Provider for the resources repository.
final resourcesRepositoryProvider = Provider<ResourcesRepository>((ref) {
  return ResourcesRepository();
});

// ==================== TOOLS STATE ====================

/// State for the tools section.
class ToolsState {
  const ToolsState({
    this.tools = const [],
    this.isLoading = false,
    this.error,
    this.selectedTool,
  });

  final List<ToolModel> tools;
  final bool isLoading;
  final String? error;
  final ToolModel? selectedTool;

  ToolsState copyWith({
    List<ToolModel>? tools,
    bool? isLoading,
    String? error,
    ToolModel? selectedTool,
  }) {
    return ToolsState(
      tools: tools ?? this.tools,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTool: selectedTool ?? this.selectedTool,
    );
  }

  /// Get tools by type.
  List<ToolModel> getToolsByType(ToolType type) {
    return tools.where((t) => t.type == type).toList();
  }

  /// Get frequently used tools.
  List<ToolModel> get frequentlyUsed {
    final sorted = List<ToolModel>.from(tools)
      ..sort((a, b) => b.usageCount.compareTo(a.usageCount));
    return sorted.take(4).toList();
  }
}

/// Notifier for tools state.
class ToolsNotifier extends StateNotifier<ToolsState> {
  ToolsNotifier(this._repository) : super(const ToolsState()) {
    loadTools();
  }

  final ResourcesRepository _repository;

  /// Load all tools.
  Future<void> loadTools() async {
    state = state.copyWith(isLoading: true);

    try {
      final tools = await _repository.getTools();
      state = state.copyWith(
        tools: tools,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tools: $e',
      );
    }
  }

  /// Select a tool.
  void selectTool(ToolModel tool) {
    state = state.copyWith(selectedTool: tool);
  }

  /// Track tool usage.
  Future<void> trackUsage(String toolId) async {
    await _repository.trackToolUsage(toolId);
    // Refresh to update usage counts
    await loadTools();
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for tools state.
final toolsProvider = StateNotifierProvider<ToolsNotifier, ToolsState>((ref) {
  final repository = ref.watch(resourcesRepositoryProvider);
  return ToolsNotifier(repository);
});

// ==================== TRAINING VIDEOS STATE ====================

/// State for training videos.
class TrainingVideosState {
  const TrainingVideosState({
    this.videos = const [],
    this.videosByCategory = const {},
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.searchQuery = '',
  });

  final List<TrainingVideoModel> videos;
  final Map<VideoCategory, List<TrainingVideoModel>> videosByCategory;
  final bool isLoading;
  final String? error;
  final VideoCategory? selectedCategory;
  final String searchQuery;

  TrainingVideosState copyWith({
    List<TrainingVideoModel>? videos,
    Map<VideoCategory, List<TrainingVideoModel>>? videosByCategory,
    bool? isLoading,
    String? error,
    VideoCategory? selectedCategory,
    String? searchQuery,
  }) {
    return TrainingVideosState(
      videos: videos ?? this.videos,
      videosByCategory: videosByCategory ?? this.videosByCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Get filtered videos based on search and category.
  List<TrainingVideoModel> get filteredVideos {
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

  /// Get required videos.
  List<TrainingVideoModel> get requiredVideos {
    return videos.where((v) => v.isRequired).toList();
  }

  /// Get completed videos.
  List<TrainingVideoModel> get completedVideos {
    return videos.where((v) => v.isCompleted).toList();
  }

  /// Get in-progress videos.
  List<TrainingVideoModel> get inProgressVideos {
    return videos.where((v) => !v.isCompleted && v.watchProgress > 0).toList();
  }

  /// Calculate overall progress.
  double get overallProgress {
    if (requiredVideos.isEmpty) return 1.0;
    final completed = requiredVideos.where((v) => v.isCompleted).length;
    return completed / requiredVideos.length;
  }
}

/// Notifier for training videos.
class TrainingVideosNotifier extends StateNotifier<TrainingVideosState> {
  TrainingVideosNotifier(this._repository) : super(const TrainingVideosState()) {
    loadVideos();
  }

  final ResourcesRepository _repository;

  /// Load all videos.
  Future<void> loadVideos() async {
    state = state.copyWith(isLoading: true);

    try {
      final videos = await _repository.getTrainingVideos();
      final byCategory = await _repository.getVideosByCategory();

      state = state.copyWith(
        videos: videos,
        videosByCategory: byCategory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load videos: $e',
      );
    }
  }

  /// Select a category filter.
  void selectCategory(VideoCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Update search query.
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Update video progress.
  Future<void> updateProgress({
    required String videoId,
    required double progress,
    bool? isCompleted,
  }) async {
    await _repository.updateWatchProgress(
      videoId: videoId,
      progress: progress,
      isCompleted: isCompleted,
    );

    // Update local state
    final updatedVideos = state.videos.map((v) {
      if (v.id == videoId) {
        return v.copyWith(
          watchProgress: progress,
          isCompleted: isCompleted ?? (progress >= 0.95),
        );
      }
      return v;
    }).toList();

    state = state.copyWith(videos: updatedVideos);
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for training videos.
final trainingVideosProvider =
    StateNotifierProvider<TrainingVideosNotifier, TrainingVideosState>((ref) {
  final repository = ref.watch(resourcesRepositoryProvider);
  return TrainingVideosNotifier(repository);
});

// ==================== PRICING STATE ====================

/// State for pricing guide.
class PricingState {
  const PricingState({
    this.pricingGuide,
    this.isLoading = false,
    this.error,
    this.selectedWorkType,
    this.selectedLevel = AcademicLevel.undergraduate,
    this.selectedUrgency = UrgencyLevel.standard,
    this.pageCount = 1,
  });

  final PricingGuide? pricingGuide;
  final bool isLoading;
  final String? error;
  final WorkType? selectedWorkType;
  final AcademicLevel selectedLevel;
  final UrgencyLevel selectedUrgency;
  final int pageCount;

  PricingState copyWith({
    PricingGuide? pricingGuide,
    bool? isLoading,
    String? error,
    WorkType? selectedWorkType,
    AcademicLevel? selectedLevel,
    UrgencyLevel? selectedUrgency,
    int? pageCount,
  }) {
    return PricingState(
      pricingGuide: pricingGuide ?? this.pricingGuide,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedWorkType: selectedWorkType ?? this.selectedWorkType,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      selectedUrgency: selectedUrgency ?? this.selectedUrgency,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  /// Calculate price for current selection.
  double? get calculatedPrice {
    if (pricingGuide == null || selectedWorkType == null) return null;

    final pricing = pricingGuide!.getPricing(
      selectedWorkType!,
      level: selectedLevel,
    );

    if (pricing == null) return null;

    return pricing.calculatePrice(
      pages: pageCount,
      urgency: selectedUrgency,
    );
  }

  /// Get pricings for a work type.
  List<PricingModel> getPricingsForType(WorkType type) {
    return pricingGuide?.getPricingsForType(type) ?? [];
  }
}

/// Notifier for pricing state.
class PricingNotifier extends StateNotifier<PricingState> {
  PricingNotifier(this._repository) : super(const PricingState()) {
    loadPricing();
  }

  final ResourcesRepository _repository;

  /// Load pricing guide.
  Future<void> loadPricing() async {
    state = state.copyWith(isLoading: true);

    try {
      final guide = await _repository.getPricingGuide();
      state = state.copyWith(
        pricingGuide: guide,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load pricing: $e',
      );
    }
  }

  /// Select work type.
  void selectWorkType(WorkType type) {
    state = state.copyWith(selectedWorkType: type);
  }

  /// Select academic level.
  void selectLevel(AcademicLevel level) {
    state = state.copyWith(selectedLevel: level);
  }

  /// Select urgency.
  void selectUrgency(UrgencyLevel urgency) {
    state = state.copyWith(selectedUrgency: urgency);
  }

  /// Update page count.
  void setPageCount(int pages) {
    state = state.copyWith(pageCount: pages.clamp(1, 500));
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for pricing.
final pricingProvider =
    StateNotifierProvider<PricingNotifier, PricingState>((ref) {
  final repository = ref.watch(resourcesRepositoryProvider);
  return PricingNotifier(repository);
});

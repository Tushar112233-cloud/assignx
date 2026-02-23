import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/routes.dart';
import '../providers/resources_provider.dart';
import '../widgets/tool_card.dart';
import '../widgets/training_library.dart';
import '../widgets/pricing_guide_table.dart';

/// Main resources screen.
///
/// Provides access to tools, training videos, and pricing guide.
class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});

  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resources'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.build_outlined), text: 'Tools'),
            Tab(icon: Icon(Icons.school_outlined), text: 'Training'),
            Tab(icon: Icon(Icons.monetization_on_outlined), text: 'Pricing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ToolsTab(),
          _TrainingTab(),
          _PricingTab(),
        ],
      ),
    );
  }
}

/// Tools tab content.
class _ToolsTab extends ConsumerWidget {
  const _ToolsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(toolsProvider);

    if (state.isLoading && state.tools.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.tools.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(toolsProvider.notifier).loadTools(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(toolsProvider.notifier).loadTools(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick access
            if (state.frequentlyUsed.isNotEmpty) ...[
              const SizedBox(height: 16),
              ToolQuickAccess(
                title: 'Frequently Used',
                tools: state.frequentlyUsed,
                onToolTap: (tool) => _openTool(context, ref, tool),
              ),
            ],
            const SizedBox(height: 24),
            // All tools
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'All Tools',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ToolGrid(
              tools: state.tools,
              onToolTap: (tool) => _openTool(context, ref, tool),
              padding: const EdgeInsets.all(16),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _openTool(BuildContext context, WidgetRef ref, dynamic tool) {
    // Track usage
    ref.read(toolsProvider.notifier).trackUsage(tool.id);

    // Navigate based on tool type
    switch (tool.type.id) {
      case 'plagiarism':
        context.push('${RoutePaths.resources}/plagiarism-checker');
        break;
      case 'ai_detector':
        context.push('${RoutePaths.resources}/ai-detector');
        break;
      default:
        if (tool.url != null) {
          context.push(
            '${RoutePaths.resources}/webview',
            extra: {'url': tool.url, 'title': tool.name},
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${tool.name}...')),
          );
        }
    }
  }
}

/// Training tab content.
class _TrainingTab extends ConsumerWidget {
  const _TrainingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trainingVideosProvider);

    if (state.isLoading && state.videos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(trainingVideosProvider.notifier).loadVideos(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(trainingVideosProvider.notifier).loadVideos(),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Continue watching
            if (state.inProgressVideos.isNotEmpty)
              ContinueWatching(
                videos: state.inProgressVideos,
                onVideoTap: (video) => _openVideo(context, video),
              ),
            // Training library
            TrainingLibrary(
              videos: state.videos,
              videosByCategory: state.videosByCategory,
              onVideoTap: (video) => _openVideo(context, video),
              selectedCategory: state.selectedCategory,
              onCategorySelected: (category) =>
                  ref.read(trainingVideosProvider.notifier).selectCategory(category),
              searchQuery: state.searchQuery,
              onSearchChanged: (query) =>
                  ref.read(trainingVideosProvider.notifier).search(query),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _openVideo(BuildContext context, dynamic video) {
    context.push(
      '${RoutePaths.resources}/video/${video.id}',
      extra: video,
    );
  }
}

/// Pricing tab content.
class _PricingTab extends ConsumerWidget {
  const _PricingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pricingProvider);

    if (state.isLoading && state.pricingGuide == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.pricingGuide == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(pricingProvider.notifier).loadPricing(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final guide = state.pricingGuide;
    if (guide == null) {
      return const Center(child: Text('No pricing data available'));
    }

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: 'Price Table'),
                Tab(text: 'Calculator'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Price table
                RefreshIndicator(
                  onRefresh: () => ref.read(pricingProvider.notifier).loadPricing(),
                  child: SingleChildScrollView(
                    child: PricingGuideTable(
                      guide: guide,
                      onWorkTypeSelected: (type) {
                        ref.read(pricingProvider.notifier).selectWorkType(type);
                        DefaultTabController.of(context).animateTo(1);
                      },
                    ),
                  ),
                ),
                // Calculator
                SingleChildScrollView(
                  child: PricingCalculator(
                    selectedWorkType: state.selectedWorkType,
                    selectedLevel: state.selectedLevel,
                    selectedUrgency: state.selectedUrgency,
                    pageCount: state.pageCount,
                    calculatedPrice: state.calculatedPrice,
                    onWorkTypeChanged: (type) {
                      if (type != null) {
                        ref.read(pricingProvider.notifier).selectWorkType(type);
                      }
                    },
                    onLevelChanged: (level) {
                      ref.read(pricingProvider.notifier).selectLevel(level);
                    },
                    onUrgencyChanged: (urgency) {
                      ref.read(pricingProvider.notifier).selectUrgency(urgency);
                    },
                    onPageCountChanged: (pages) {
                      ref.read(pricingProvider.notifier).setPageCount(pages);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

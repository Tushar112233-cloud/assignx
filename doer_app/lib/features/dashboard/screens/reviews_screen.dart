import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../widgets/app_header.dart';
import '../widgets/reviews/reviews_hero_banner.dart';
import '../widgets/reviews/rating_analytics_dashboard.dart';
import '../widgets/reviews/review_highlights_section.dart';
import '../widgets/reviews/reviews_list_section.dart';
import '../widgets/reviews/achievement_cards.dart';

/// Redesigned reviews screen with hero banner, analytics, highlights,
/// achievements, and full review list.
///
/// Provider watches are split into focused ConsumerWidget children
/// so that only the relevant section rebuilds when its data changes.
/// The outer ListView uses a fixed set of section widgets (not a dynamic
/// list), so eager child building is acceptable here.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        colors: MeshColors.defaultColors,
        opacity: 0.5,
        child: const _ReviewsLoadingWrapper(),
      ),
    );
  }
}

// =============================================================================
// Loading Wrapper - watches only dashboardLoadingProvider
// =============================================================================

class _ReviewsLoadingWrapper extends ConsumerWidget {
  const _ReviewsLoadingWrapper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(dashboardLoadingProvider);

    return LoadingOverlay(
      isLoading: isLoading,
      child: Column(
        children: [
          InnerHeader(
            title: 'Reviews'.tr(context),
            onBack: () => Navigator.pop(context),
          ),
          const Expanded(
            child: _ReviewsBody(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Reviews Body - watches loading + reviews for empty state logic
// =============================================================================

class _ReviewsBody extends ConsumerWidget {
  const _ReviewsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(doerReviewsProvider);
    final isLoading = ref.watch(dashboardLoadingProvider);

    // Show empty state only when not loading and no reviews exist
    if (reviews.isEmpty && !isLoading) {
      return EmptyState(
        icon: Icons.rate_review_outlined,
        title: 'No Reviews Yet'.tr(context),
        description:
            'Complete projects to receive reviews from clients.'.tr(context),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(dashboardProvider.notifier).refresh();
      },
      color: AppColors.accent,
      // The outer ListView contains a fixed set of section widgets (6 items),
      // not a dynamic list that grows with data. Each section internally
      // handles its own list rendering. Eager building is acceptable here.
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        children: const [
          // Hero banner with overall rating - watches stats + reviews
          _ReviewsHeroBannerSection(),
          SizedBox(height: AppSpacing.lg),

          // Rating analytics dashboard - watches reviews
          _ReviewsAnalyticsSection(),
          SizedBox(height: AppSpacing.lg),

          // Review highlights (bento grid) - watches reviews
          _ReviewsHighlightsSection(),
          SizedBox(height: AppSpacing.lg),

          // Achievements - watches reviews + stats
          _ReviewsAchievementsSection(),
          SizedBox(height: AppSpacing.lg),

          // Full reviews list with tabs and search - watches reviews
          _ReviewsListContentSection(),

          // Bottom padding
          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// =============================================================================
// Hero Banner Section - watches doerStatsProvider + doerReviewsProvider
// =============================================================================

class _ReviewsHeroBannerSection extends ConsumerWidget {
  const _ReviewsHeroBannerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(doerStatsProvider);
    final reviews = ref.watch(doerReviewsProvider);

    return ReviewsHeroBanner(
      stats: stats,
      reviews: reviews,
    );
  }
}

// =============================================================================
// Analytics Section - watches doerReviewsProvider
// =============================================================================

class _ReviewsAnalyticsSection extends ConsumerWidget {
  const _ReviewsAnalyticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(doerReviewsProvider);
    return RatingAnalyticsDashboard(reviews: reviews);
  }
}

// =============================================================================
// Highlights Section - watches doerReviewsProvider
// =============================================================================

class _ReviewsHighlightsSection extends ConsumerWidget {
  const _ReviewsHighlightsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(doerReviewsProvider);
    return ReviewHighlightsSection(reviews: reviews);
  }
}

// =============================================================================
// Achievements Section - watches doerReviewsProvider + doerStatsProvider
// =============================================================================

class _ReviewsAchievementsSection extends ConsumerWidget {
  const _ReviewsAchievementsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(doerReviewsProvider);
    final stats = ref.watch(doerStatsProvider);

    return AchievementCards(
      reviews: reviews,
      stats: stats,
    );
  }
}

// =============================================================================
// Reviews List Section - watches doerReviewsProvider
// =============================================================================

class _ReviewsListContentSection extends ConsumerWidget {
  const _ReviewsListContentSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(doerReviewsProvider);
    return ReviewsListSection(reviews: reviews);
  }
}

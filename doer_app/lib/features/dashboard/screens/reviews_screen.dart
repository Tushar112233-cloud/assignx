import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../widgets/app_header.dart';
import '../widgets/reviews/reviews_hero_banner.dart';
import '../widgets/reviews/rating_analytics_dashboard.dart';
import '../widgets/reviews/review_highlights_section.dart';
import '../widgets/reviews/reviews_list_section.dart';
import '../widgets/reviews/achievement_cards.dart';

/// Redesigned reviews screen with hero banner, analytics, highlights,
/// achievements, and full review list.
class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(doerReviewsProvider);
    final stats = ref.watch(doerStatsProvider);
    final isLoading = ref.watch(dashboardLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Column(
          children: [
            InnerHeader(
              title: 'Reviews'.tr(context),
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: reviews.isEmpty && !isLoading
                  ? EmptyState(
                      icon: Icons.rate_review_outlined,
                      title: 'No Reviews Yet'.tr(context),
                      description:
                          'Complete projects to receive reviews from clients.'.tr(context),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.read(dashboardProvider.notifier).refresh();
                      },
                      color: AppColors.accent,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        children: [
                          // Hero banner with overall rating
                          ReviewsHeroBanner(
                            stats: stats,
                            reviews: reviews,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Rating analytics dashboard
                          RatingAnalyticsDashboard(reviews: reviews),
                          const SizedBox(height: AppSpacing.lg),

                          // Review highlights (bento grid)
                          ReviewHighlightsSection(reviews: reviews),
                          const SizedBox(height: AppSpacing.lg),

                          // Achievements
                          AchievementCards(
                            reviews: reviews,
                            stats: stats,
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Full reviews list with tabs and search
                          ReviewsListSection(reviews: reviews),

                          // Bottom padding
                          const SizedBox(height: AppSpacing.xxl),
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

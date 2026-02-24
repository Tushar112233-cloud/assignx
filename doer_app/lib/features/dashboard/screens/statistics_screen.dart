/// Statistics screen showing detailed doer performance analytics.
///
/// Displays comprehensive performance metrics, interactive charts,
/// heatmaps, and insights for the authenticated doer user.
///
/// ## Navigation
/// - Entry: From [AppDrawer] or dashboard stats tap
/// - Back: Returns to previous screen
///
/// ## Sections
/// 1. **Performance Hero Banner**: Key metrics with period selector
/// 2. **Quick Stats Grid**: 4-card overview grid
/// 3. **Interactive Earnings Chart**: Line chart with toggle
/// 4. **Rating Breakdown**: Quality/Timeliness/Communication bars
/// 5. **Project Distribution**: Donut chart by status
/// 6. **Top Subjects**: Ranked list with earnings
/// 7. **Monthly Heatmap**: 12-month performance grid
/// 8. **Insights & Goals**: AI insights and progress tracking
///
/// ## Data Sources
/// Uses [statisticsProvider] for detailed statistics data.
///
/// See also:
/// - [StatisticsNotifier] for data management
/// - [PerformanceHeroBanner] for hero metrics
/// - [InteractiveEarningsChart] for charts
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/statistics_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../widgets/app_header.dart';
import '../widgets/statistics/enhanced_stat_card.dart';
import '../widgets/statistics/insights_panel.dart';
import '../widgets/statistics/interactive_earnings_chart.dart';
import '../widgets/statistics/monthly_performance_heatmap.dart';
import '../widgets/statistics/performance_hero_banner.dart';
import '../widgets/statistics/project_distribution_chart.dart';
import '../widgets/statistics/rating_breakdown_card.dart';
import '../widgets/statistics/top_subjects_ranking.dart';

/// Statistics screen with comprehensive analytics dashboard.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final isLoading = stats.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: Column(
          children: [
            InnerHeader(
              title: 'Statistics'.tr(context),
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(statisticsProvider.notifier).refresh(),
                color: AppColors.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Performance Hero Banner
                      const PerformanceHeroBanner(),
                      const SizedBox(height: 20),

                      // 2. Quick Stats Grid
                      _buildQuickStatsGrid(context, stats),
                      const SizedBox(height: 20),

                      // 3. Interactive Earnings Chart
                      const InteractiveEarningsChart(),
                      const SizedBox(height: 20),

                      // 4. Rating Breakdown + Distribution row
                      const RatingBreakdownCard(),
                      const SizedBox(height: 16),
                      const ProjectDistributionChart(),
                      const SizedBox(height: 20),

                      // 5. Top Subjects Ranking
                      const TopSubjectsRanking(),
                      const SizedBox(height: 20),

                      // 6. Monthly Performance Heatmap
                      const MonthlyPerformanceHeatmap(),
                      const SizedBox(height: 20),

                      // 7. Insights & Goals
                      const InsightsPanel(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 2x2 quick stats grid with enhanced cards.
  Widget _buildQuickStatsGrid(BuildContext context, StatisticsState stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: [
        EnhancedStatCard(
          icon: Icons.assignment_rounded,
          title: 'Active Projects'.tr(context),
          value: stats.distribution.inProgress.toString(),
          subtitle: 'Currently working on'.tr(context),
          variant: StatCardVariant.teal,
        ),
        EnhancedStatCard(
          icon: Icons.check_circle_rounded,
          title: 'Completed'.tr(context),
          value: stats.distribution.completed.toString(),
          subtitle: 'All time'.tr(context),
          trend: 8.5,
          variant: StatCardVariant.blue,
        ),
        EnhancedStatCard(
          icon: Icons.currency_rupee_rounded,
          title: 'Total Earnings'.tr(context),
          value: _formatCurrency(stats.totalEarnings),
          subtitle: 'From completed projects'.tr(context),
          trend: stats.earningsTrend,
          variant: StatCardVariant.purple,
        ),
        EnhancedStatCard(
          icon: Icons.star_rounded,
          title: 'Rating'.tr(context),
          value: stats.averageRating.toStringAsFixed(1),
          subtitle: 'out of 5.0'.tr(context),
          trend: stats.ratingTrend,
          variant: StatCardVariant.orange,
        ),
      ],
    );
  }

  /// Formats currency with K/L suffix for large amounts.
  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }
}

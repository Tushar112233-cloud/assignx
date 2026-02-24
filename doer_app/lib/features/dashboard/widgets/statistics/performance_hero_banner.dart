/// Performance hero banner for the statistics screen.
///
/// Full-width gradient banner displaying key metrics:
/// total earnings, average rating, project velocity,
/// and a period selector toggle.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../providers/statistics_provider.dart';

/// Full-width hero banner showing key performance metrics.
class PerformanceHeroBanner extends ConsumerWidget {
  const PerformanceHeroBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final selectedPeriod = stats.selectedPeriod;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            _buildPeriodSelector(context, ref, selectedPeriod),
            const SizedBox(height: 20),

            // Main metrics row
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    label: 'Total Earnings'.tr(context),
                    value: _formatCurrency(stats.totalEarnings),
                    trend: stats.earningsTrend,
                    icon: Icons.account_balance_wallet_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildMetric(
                    label: 'Avg Rating'.tr(context),
                    value: stats.averageRating.toStringAsFixed(1),
                    trend: stats.ratingTrend,
                    icon: Icons.star_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildMetric(
                    label: 'Velocity'.tr(context),
                    value: '${stats.projectVelocity.toStringAsFixed(1)}/wk',
                    icon: Icons.speed_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context, WidgetRef ref, StatsPeriod selected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: StatsPeriod.values.map((period) {
          final isSelected = period == selected;
          return GestureDetector(
            onTap: () {
              ref.read(statisticsProvider.notifier).setPeriod(period);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: AppSpacing.borderRadiusXs,
              ),
              child: Text(
                _periodLabel(context, period),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    double? trend,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        if (trend != null) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                trend >= 0 ? Icons.trending_up : Icons.trending_down,
                size: 12,
                color: trend >= 0
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFFCA5A5),
              ),
              const SizedBox(width: 2),
              Text(
                '${trend.abs().toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: trend >= 0
                      ? const Color(0xFF86EFAC)
                      : const Color(0xFFFCA5A5),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _periodLabel(BuildContext context, StatsPeriod period) {
    switch (period) {
      case StatsPeriod.week:
        return 'Week'.tr(context);
      case StatsPeriod.month:
        return 'Month'.tr(context);
      case StatsPeriod.year:
        return 'Year'.tr(context);
      case StatsPeriod.all:
        return 'All'.tr(context);
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '\u20B9${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '\u20B9${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '\u20B9${amount.toStringAsFixed(0)}';
  }
}

/// Monthly performance heatmap widget.
///
/// Grid showing last 12 months, each cell colored by performance
/// level (number of projects completed that month).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../providers/statistics_provider.dart';

/// Heatmap grid showing 12 months of project completion data.
class MonthlyPerformanceHeatmap extends ConsumerWidget {
  const MonthlyPerformanceHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final performance = stats.monthlyPerformance;

    final maxProjects = performance.isEmpty
        ? 1
        : performance.map((p) => p.projectsCompleted).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.success),
              SizedBox(width: 8),
              Text(
                'Monthly Performance',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Heatmap grid
          if (performance.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No performance data available',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.6,
              ),
              itemCount: performance.length,
              itemBuilder: (context, index) {
                final item = performance[index];
                final intensity = maxProjects > 0
                    ? item.projectsCompleted / maxProjects
                    : 0.0;
                return _buildHeatmapCell(item, intensity);
              },
            ),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Less',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
              const SizedBox(width: 6),
              ...List.generate(5, (i) {
                final intensity = i / 4;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: _getHeatColor(intensity),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
              const SizedBox(width: 6),
              const Text(
                'More',
                style: TextStyle(fontSize: 10, color: AppColors.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCell(MonthlyPerformance item, double intensity) {
    final date = DateTime(item.year, item.month);
    final monthLabel = DateFormat('MMM').format(date);
    final yearLabel = DateFormat('yy').format(date);

    return Tooltip(
      message: '${DateFormat('MMMM yyyy').format(date)}: ${item.projectsCompleted} projects',
      child: Container(
        decoration: BoxDecoration(
          color: _getHeatColor(intensity),
          borderRadius: AppSpacing.borderRadiusXs,
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              monthLabel,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: intensity > 0.5
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
            Text(
              "'$yearLabel",
              style: TextStyle(
                fontSize: 8,
                color: intensity > 0.5
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textTertiary,
              ),
            ),
            if (item.projectsCompleted > 0)
              Text(
                '${item.projectsCompleted}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: intensity > 0.5
                      ? Colors.white
                      : AppColors.success,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getHeatColor(double intensity) {
    if (intensity <= 0) return AppColors.surfaceVariant;
    if (intensity < 0.25) return const Color(0xFFDCFCE7);
    if (intensity < 0.5) return const Color(0xFF86EFAC);
    if (intensity < 0.75) return const Color(0xFF22C55E);
    return const Color(0xFF15803D);
  }
}

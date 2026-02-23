/// Project distribution donut chart using fl_chart.
///
/// Shows completed, in-progress, pending, and revision
/// project counts as a donut/pie chart.
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../providers/statistics_provider.dart';

/// Donut chart showing project distribution by status.
class ProjectDistributionChart extends ConsumerWidget {
  const ProjectDistributionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final dist = stats.distribution;

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
              Icon(Icons.donut_large_rounded, size: 18, color: Color(0xFF8B5CF6)),
              SizedBox(width: 8),
              Text(
                'Project Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart and legend row
          Row(
            children: [
              // Donut chart
              SizedBox(
                height: 140,
                width: 140,
                child: dist.total == 0
                    ? const Center(
                        child: Text(
                          'No projects',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _buildSections(dist),
                              pieTouchData: PieTouchData(enabled: true),
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                dist.total.toString(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const SizedBox(width: 20),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Completed', dist.completed, AppColors.success),
                    const SizedBox(height: 10),
                    _buildLegendItem('In Progress', dist.inProgress, AppColors.accent),
                    const SizedBox(height: 10),
                    _buildLegendItem('Pending', dist.pending, AppColors.warning),
                    const SizedBox(height: 10),
                    _buildLegendItem('Revision', dist.revision, AppColors.error),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(ProjectDistribution dist) {
    final sections = <PieChartSectionData>[];

    if (dist.completed > 0) {
      sections.add(PieChartSectionData(
        value: dist.completed.toDouble(),
        color: AppColors.success,
        radius: 20,
        showTitle: false,
      ));
    }
    if (dist.inProgress > 0) {
      sections.add(PieChartSectionData(
        value: dist.inProgress.toDouble(),
        color: AppColors.accent,
        radius: 20,
        showTitle: false,
      ));
    }
    if (dist.pending > 0) {
      sections.add(PieChartSectionData(
        value: dist.pending.toDouble(),
        color: AppColors.warning,
        radius: 20,
        showTitle: false,
      ));
    }
    if (dist.revision > 0) {
      sections.add(PieChartSectionData(
        value: dist.revision.toDouble(),
        color: AppColors.error,
        radius: 20,
        showTitle: false,
      ));
    }

    return sections;
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

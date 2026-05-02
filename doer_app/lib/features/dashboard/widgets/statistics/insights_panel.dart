/// Insights and goals panel widget.
///
/// Two-section panel: insights (success/info/warning messages)
/// and goals with progress bars.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../providers/statistics_provider.dart';
import '../../../../core/translation/translation_extensions.dart';

/// Panel displaying AI insights and goal progress.
class InsightsPanel extends ConsumerWidget {
  const InsightsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);

    return Column(
      children: [
        // Insights section
        _buildInsightsSection(context, stats.insights),
        const SizedBox(height: 16),
        // Goals section
        _buildGoalsSection(context, stats.goals),
      ],
    );
  }

  Widget _buildInsightsSection(BuildContext context, List<InsightItem> insights) {
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
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, size: 18, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'Insights'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (insights.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No insights available yet'.tr(context),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildInsightItem(insight),
                )),
        ],
      ),
    );
  }

  Widget _buildInsightItem(InsightItem insight) {
    final config = _insightConfig(insight.type);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(color: config.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(config.icon, size: 16, color: config.color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              insight.message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: config.color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, List<GoalItem> goals) {
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
          Row(
            children: [
              Icon(Icons.flag_rounded, size: 18, color: AppColors.accent),
              SizedBox(width: 8),
              Text(
                'Goals'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (goals.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No goals set yet'.tr(context),
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            )
          else
            ...goals.map((goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildGoalItem(goal),
                )),
        ],
      ),
    );
  }

  Widget _buildGoalItem(GoalItem goal) {
    final progress = goal.progress;
    final progressPercent = (progress * 100).toInt();
    final isComplete = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: isComplete ? AppColors.success : AppColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                goal.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isComplete
                      ? AppColors.success
                      : AppColors.textPrimary,
                  decoration: isComplete ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Text(
              '$progressPercent%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isComplete ? AppColors.success : AppColors.accent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: AppSpacing.borderRadiusXs,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? AppColors.success : AppColors.accent,
            ),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_formatNumber(goal.current)} / ${_formatNumber(goal.target)}',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  ({Color color, Color bgColor, IconData icon}) _insightConfig(InsightType type) {
    switch (type) {
      case InsightType.success:
        return (
          color: AppColors.success,
          bgColor: AppColors.successLight,
          icon: Icons.check_circle_outline,
        );
      case InsightType.info:
        return (
          color: AppColors.info,
          bgColor: AppColors.infoLight,
          icon: Icons.info_outline,
        );
      case InsightType.warning:
        return (
          color: AppColors.warning,
          bgColor: AppColors.warningLight,
          icon: Icons.warning_amber_rounded,
        );
    }
  }

  String _formatNumber(int number) {
    if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

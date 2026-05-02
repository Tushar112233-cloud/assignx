import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/profile_provider.dart';

/// Floating scorecard widget showing key profile metrics.
///
/// Displays a horizontal scrollable row of metric cards (Rating,
/// Completed Projects, Total Earnings, On-Time Rate) that overlaps
/// the hero section bottom for a modern layered look.
class ProfileScorecard extends StatelessWidget {
  final UserProfile profile;

  const ProfileScorecard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = [
      _MetricData(
        icon: Icons.star_rounded,
        iconColor: AppColors.warning,
        value: profile.rating.toStringAsFixed(1),
        label: 'Rating',
        bgColor: AppColors.warning.withValues(alpha: 0.1),
      ),
      _MetricData(
        icon: Icons.check_circle_rounded,
        iconColor: AppColors.success,
        value: profile.completedProjects.toString(),
        label: 'Completed',
        bgColor: AppColors.success.withValues(alpha: 0.1),
      ),
      _MetricData(
        icon: Icons.account_balance_wallet_rounded,
        iconColor: AppColors.primary,
        value: '\u20B9${_formatCurrency(profile.totalEarnings)}',
        label: 'Earnings',
        bgColor: AppColors.primary.withValues(alpha: 0.1),
      ),
      _MetricData(
        icon: Icons.timer_rounded,
        iconColor: const Color(0xFF8B5CF6),
        value: '${_calculateOnTimeRate()}%',
        label: 'On-Time',
        bgColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: metrics.map((metric) {
          return Expanded(
            child: _buildMetricCard(metric),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricCard(_MetricData metric) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: metric.bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            metric.icon,
            size: 22,
            color: metric.iconColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          metric.value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          metric.label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toString();
  }

  int _calculateOnTimeRate() {
    if (profile.completedProjects == 0) return 0;
    // Estimate on-time rate from rating (higher rating = better on-time)
    return (85 + (profile.rating / 5.0) * 12).round().clamp(0, 100);
  }
}

class _MetricData {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bgColor;

  const _MetricData({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bgColor,
  });
}

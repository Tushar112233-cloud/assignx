import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Quick stats row displaying key metrics as pills.
///
/// Shows: Active Projects | Pending Actions | Wallet Balance
/// Matches web dashboard's QuickStats component.
///
/// Example:
/// ```dart
/// QuickStatsRow(
///   activeProjects: 3,
///   pendingActions: 2,
///   walletBalance: 1500.0,
///   isLoading: false,
/// )
/// ```
class QuickStatsRow extends StatelessWidget {
  /// Number of active/in-progress projects.
  final int activeProjects;

  /// Number of projects requiring user action.
  final int pendingActions;

  /// Current wallet balance in INR.
  final double walletBalance;

  /// Whether to show loading skeleton.
  final bool isLoading;

  const QuickStatsRow({
    super.key,
    required this.activeProjects,
    required this.pendingActions,
    required this.walletBalance,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _StatPill(
            icon: Icons.folder_outlined,
            label: 'Active',
            value: '$activeProjects',
            highlight: activeProjects > 0,
          ),
          _StatPill(
            icon: Icons.schedule_outlined,
            label: 'Pending',
            value: '$pendingActions',
            highlight: pendingActions > 0,
          ),
          _StatPill(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            value: _formatBalance(walletBalance),
            highlight: false,
          ),
        ],
      ),
    );
  }

  /// Formats wallet balance with currency symbol.
  String _formatBalance(double balance) {
    if (balance >= 1000) {
      return '\u20B9${(balance / 1000).toStringAsFixed(1)}k';
    }
    return '\u20B9${balance.toInt()}';
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          SkeletonLoader(width: 80, height: 32, borderRadius: 16),
          const SizedBox(width: 8),
          SkeletonLoader(width: 90, height: 32, borderRadius: 16),
          const SizedBox(width: 8),
          SkeletonLoader(width: 100, height: 32, borderRadius: 16),
        ],
      ),
    );
  }
}

/// Individual stat pill component.
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = highlight
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surfaceLight;
    final iconColor = highlight ? AppColors.primary : AppColors.textTertiary;
    final valueColor = highlight ? AppColors.primary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

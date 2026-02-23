import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Floating stats card showing wallet balance and projects completed.
class StatsCard extends StatelessWidget {
  final double walletBalance;
  final int projectsCompleted;
  final VoidCallback? onWalletTap;
  final VoidCallback? onProjectsTap;
  final VoidCallback? onTopUpTap;

  const StatsCard({
    super.key,
    required this.walletBalance,
    required this.projectsCompleted,
    this.onWalletTap,
    this.onProjectsTap,
    this.onTopUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Wallet Balance
          Expanded(
            child: GestureDetector(
              onTap: onWalletTap,
              child: _StatItem(
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.primaryLight,
                label: 'Wallet Balance',
                value: '\u20B9${walletBalance.toStringAsFixed(0)}',
                action: onTopUpTap != null
                    ? GestureDetector(
                        onTap: onTopUpTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Top Up',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.border,
          ),

          // Projects Completed
          Expanded(
            child: GestureDetector(
              onTap: onProjectsTap,
              child: _StatItem(
                icon: Icons.task_alt_outlined,
                iconColor: AppColors.success,
                iconBgColor: AppColors.successLight,
                label: 'Projects Done',
                value: projectsCompleted.toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual stat item.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String label;
  final String value;
  final Widget? action;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.label,
    required this.value,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const Spacer(),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.headingSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Mini stats row for compact display.
class MiniStatsRow extends StatelessWidget {
  final double walletBalance;
  final int projectsCompleted;

  const MiniStatsRow({
    super.key,
    required this.walletBalance,
    required this.projectsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatChip(
            icon: Icons.account_balance_wallet_outlined,
            value: '\u20B9${walletBalance.toStringAsFixed(0)}',
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatChip(
            icon: Icons.task_alt_outlined,
            value: '$projectsCompleted Projects',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

/// Mini stat chip.
class _MiniStatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _MiniStatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

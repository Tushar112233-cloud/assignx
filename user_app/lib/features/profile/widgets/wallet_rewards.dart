import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Reward tier levels.
enum RewardTier {
  bronze,
  silver,
  gold,
  platinum,
}

/// Extension to get tier properties.
extension RewardTierExtension on RewardTier {
  String get name {
    switch (this) {
      case RewardTier.bronze:
        return 'Bronze';
      case RewardTier.silver:
        return 'Silver';
      case RewardTier.gold:
        return 'Gold';
      case RewardTier.platinum:
        return 'Platinum';
    }
  }

  IconData get icon {
    switch (this) {
      case RewardTier.bronze:
        return Icons.workspace_premium_outlined;
      case RewardTier.silver:
        return Icons.workspace_premium_rounded;
      case RewardTier.gold:
        return Icons.emoji_events_rounded;
      case RewardTier.platinum:
        return Icons.diamond_rounded;
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case RewardTier.bronze:
        return const [Color(0xFFCD7F32), Color(0xFFB8860B)];
      case RewardTier.silver:
        return const [Color(0xFFC0C0C0), Color(0xFFA9A9A9)];
      case RewardTier.gold:
        return const [Color(0xFFFFD700), Color(0xFFFFA500)];
      case RewardTier.platinum:
        return const [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
    }
  }

  int get minPoints {
    switch (this) {
      case RewardTier.bronze:
        return 0;
      case RewardTier.silver:
        return 1000;
      case RewardTier.gold:
        return 5000;
      case RewardTier.platinum:
        return 15000;
    }
  }

  List<String> get benefits {
    switch (this) {
      case RewardTier.bronze:
        return [
          'Earn 1 point per Rs. 10 spent',
          'Access to basic offers',
          'Priority email support',
        ];
      case RewardTier.silver:
        return [
          'Earn 1.5 points per Rs. 10 spent',
          'Exclusive Silver offers',
          'Priority chat support',
          '5% bonus on wallet top-ups',
        ];
      case RewardTier.gold:
        return [
          'Earn 2 points per Rs. 10 spent',
          'Exclusive Gold offers',
          'Dedicated support line',
          '10% bonus on wallet top-ups',
          'Free project consultation',
        ];
      case RewardTier.platinum:
        return [
          'Earn 3 points per Rs. 10 spent',
          'VIP exclusive offers',
          'Personal account manager',
          '15% bonus on wallet top-ups',
          'Free premium consultations',
          'Early access to new features',
        ];
    }
  }
}

/// Data model for wallet rewards.
class WalletRewardsData {
  final int totalPoints;
  final int pointsThisMonth;
  final RewardTier currentTier;

  const WalletRewardsData({
    required this.totalPoints,
    required this.pointsThisMonth,
    required this.currentTier,
  });

  /// Calculate progress to next tier (0.0 to 1.0).
  double get progressToNextTier {
    if (currentTier == RewardTier.platinum) return 1.0;

    final nextTier = RewardTier.values[currentTier.index + 1];
    final currentMin = currentTier.minPoints;
    final nextMin = nextTier.minPoints;
    final range = nextMin - currentMin;
    final progress = totalPoints - currentMin;

    return (progress / range).clamp(0.0, 1.0);
  }

  /// Points needed for next tier.
  int get pointsToNextTier {
    if (currentTier == RewardTier.platinum) return 0;
    final nextTier = RewardTier.values[currentTier.index + 1];
    return nextTier.minPoints - totalPoints;
  }

  /// Next tier name.
  String? get nextTierName {
    if (currentTier == RewardTier.platinum) return null;
    return RewardTier.values[currentTier.index + 1].name;
  }
}

/// Redemption option for points.
class RedemptionOption {
  final IconData icon;
  final String title;
  final String description;
  final int pointsCost;
  final List<Color> gradientColors;

  const RedemptionOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.gradientColors,
  });
}

/// Wallet rewards display widget.
///
/// Features:
/// - Points balance display with coin icon
/// - Tier progress bar (Bronze -> Silver -> Gold -> Platinum)
/// - Points earned this month
/// - "Redeem Points" button (opens bottom sheet)
/// - Tier benefits preview
class WalletRewards extends StatelessWidget {
  /// Rewards data. If null, uses sample data.
  final WalletRewardsData? data;

  /// Callback when redeem is tapped.
  final VoidCallback? onRedeemTap;

  const WalletRewards({
    super.key,
    this.data,
    this.onRedeemTap,
  });

  /// Sample data for demonstration.
  static const WalletRewardsData _sampleData = WalletRewardsData(
    totalPoints: 1250,
    pointsThisMonth: 320,
    currentTier: RewardTier.silver,
  );

  WalletRewardsData get _data => data ?? _sampleData;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.71),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _data.currentTier.gradientColors.first.withValues(alpha: 0.08),
                    _data.currentTier.gradientColors.last.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row - Points and Tier badge
              Row(
                children: [
                  // Coin icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _data.currentTier.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _data.currentTier.gradientColors.first.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.monetization_on_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Points display
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REWARD POINTS',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _data.totalPoints.toString(),
                        style: AppTextStyles.headingMedium.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Tier badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _data.currentTier.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _data.currentTier.gradientColors.first.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _data.currentTier.icon,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _data.currentTier.name,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tier progress bar
              _TierProgressBar(
                currentTier: _data.currentTier,
                progress: _data.progressToNextTier,
              ),

              const SizedBox(height: 12),

              // Progress text
              if (_data.currentTier != RewardTier.platinum)
                Text(
                  '${_data.pointsToNextTier} points to ${_data.nextTierName}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                )
              else
                Text(
                  'You\'ve reached the highest tier!',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: _data.currentTier.gradientColors.first,
                    fontWeight: FontWeight.w500,
                  ),
                ),

              const SizedBox(height: 16),

              // Bottom row - Points this month and Redeem button
              Row(
                children: [
                  // Points this month
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '+${_data.pointsThisMonth} this month',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Redeem button
                  GestureDetector(
                    onTap: () => _showRedeemSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.redeem_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Redeem',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Shows the redemption options bottom sheet.
  void _showRedeemSheet(BuildContext context) {
    HapticFeedback.mediumImpact();
    onRedeemTap?.call();

    final redemptionOptions = [
      const RedemptionOption(
        icon: Icons.account_balance_wallet_rounded,
        title: 'Wallet Credit',
        description: 'Convert points to wallet balance',
        pointsCost: 500,
        gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      ),
      const RedemptionOption(
        icon: Icons.local_offer_rounded,
        title: 'Project Discount',
        description: 'Get 15% off your next project',
        pointsCost: 750,
        gradientColors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
      ),
      const RedemptionOption(
        icon: Icons.support_agent_rounded,
        title: 'Free Consultation',
        description: '30-minute expert consultation',
        pointsCost: 1000,
        gradientColors: [Color(0xFFF59E0B), Color(0xFFF97316)],
      ),
      const RedemptionOption(
        icon: Icons.bolt_rounded,
        title: 'Priority Processing',
        description: 'Fast-track your next project',
        pointsCost: 1500,
        gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      ),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Text(
                  'Redeem Points',
                  style: AppTextStyles.headingSmall,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _data.currentTier.gradientColors.first.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on_rounded,
                        size: 14,
                        color: _data.currentTier.gradientColors.first,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_data.totalPoints} pts',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _data.currentTier.gradientColors.first,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to use your points',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 20),

            // Redemption options list
            ...redemptionOptions.map((option) => _RedemptionOptionTile(
              option: option,
              availablePoints: _data.totalPoints,
              onTap: () {
                Navigator.pop(context);
                _showRedeemConfirmation(context, option);
              },
            )),

            const SizedBox(height: 12),

            // Tier benefits section
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _data.currentTier.gradientColors.first.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _data.currentTier.gradientColors.first.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _data.currentTier.icon,
                        size: 16,
                        color: _data.currentTier.gradientColors.first,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_data.currentTier.name} Benefits',
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _data.currentTier.gradientColors.first,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...(_data.currentTier.benefits.take(3).map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: _data.currentTier.gradientColors.first,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            benefit,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows confirmation dialog for redemption.
  void _showRedeemConfirmation(BuildContext context, RedemptionOption option) {
    if (_data.totalPoints < option.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You need ${option.pointsCost - _data.totalPoints} more points'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Confirm Redemption',
          style: AppTextStyles.headingSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: option.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                option.icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              option.title,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${option.pointsCost} points',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${option.title} redeemed successfully!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: option.gradientColors.first,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

/// Tier progress bar widget.
class _TierProgressBar extends StatelessWidget {
  final RewardTier currentTier;
  final double progress;

  const _TierProgressBar({
    required this.currentTier,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tier labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: RewardTier.values.map((tier) {
            final isActive = tier.index <= currentTier.index;
            final isCurrent = tier == currentTier;
            return Expanded(
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: isActive
                            ? LinearGradient(
                                colors: tier.gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isActive ? null : AppColors.border,
                        shape: BoxShape.circle,
                        border: isCurrent
                            ? Border.all(
                                color: Colors.white,
                                width: 2,
                              )
                            : null,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: tier.gradientColors.first.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        tier.icon,
                        size: 12,
                        color: isActive ? Colors.white : AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tier.name,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 9,
                        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                        color: isCurrent
                            ? tier.gradientColors.first
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Progress bar
        Stack(
          children: [
            // Background track
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            // Filled progress
            FractionallySizedBox(
              widthFactor: _calculateFullProgress(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentTier.gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: currentTier.gradientColors.first.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Calculates the full progress across all tiers.
  double _calculateFullProgress() {
    final tierSegment = 1.0 / RewardTier.values.length;
    final completedTiers = currentTier.index;
    final baseProgress = completedTiers * tierSegment;
    final currentProgress = progress * tierSegment;
    return (baseProgress + currentProgress).clamp(0.0, 1.0);
  }
}

/// Redemption option tile widget.
class _RedemptionOptionTile extends StatelessWidget {
  final RedemptionOption option;
  final int availablePoints;
  final VoidCallback onTap;

  const _RedemptionOptionTile({
    required this.option,
    required this.availablePoints,
    required this.onTap,
  });

  bool get _canRedeem => availablePoints >= option.pointsCost;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _canRedeem
                    ? option.gradientColors.first.withValues(alpha: 0.2)
                    : AppColors.border,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Opacity(
              opacity: _canRedeem ? 1.0 : 0.5,
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: option.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      option.icon,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.description,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Points cost
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: option.gradientColors.first.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${option.pointsCost} pts',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: option.gradientColors.first,
                          ),
                        ),
                      ),
                      if (!_canRedeem)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Need ${option.pointsCost - availablePoints} more',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Pricing tier for urgency.
enum UrgencyTier {
  relaxed('Relaxed', '7+ days', 0.8, Icons.spa),
  standard('Standard', '3-7 days', 1.0, Icons.schedule),
  express('Express', '1-3 days', 1.3, Icons.flash_on),
  urgent('Urgent', '< 24 hours', 1.6, Icons.warning_amber);

  final String name;
  final String timeFrame;
  final double multiplier;
  final IconData icon;

  const UrgencyTier(this.name, this.timeFrame, this.multiplier, this.icon);
}

/// Budget display widget with price breakdown.
class BudgetDisplay extends StatelessWidget {
  final double? basePrice;
  final UrgencyTier? urgencyTier;
  final int? wordCount;
  final bool showBreakdown;
  final VoidCallback? onTierChange;

  const BudgetDisplay({
    super.key,
    this.basePrice,
    this.urgencyTier,
    this.wordCount,
    this.showBreakdown = true,
    this.onTierChange,
  });

  @override
  Widget build(BuildContext context) {
    final calculatedPrice = _calculateTotalPrice();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(15),
            AppColors.primaryLight.withAlpha(10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Estimated Price',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              if (calculatedPrice != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Best Value',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Main price
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calculatedPrice != null
                    ? '₹${calculatedPrice.toStringAsFixed(0)}'
                    : '--',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'INR',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),

          // Price breakdown
          if (showBreakdown && calculatedPrice != null) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            _BreakdownRow(
              label: 'Base Price',
              value: '₹${basePrice?.toStringAsFixed(0) ?? '--'}',
            ),
            if (urgencyTier != null) ...[
              const SizedBox(height: 8),
              _BreakdownRow(
                label: '${urgencyTier!.name} (${urgencyTier!.timeFrame})',
                value: '×${urgencyTier!.multiplier}',
                valueColor: urgencyTier!.multiplier > 1
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ],
            if (wordCount != null) ...[
              const SizedBox(height: 8),
              _BreakdownRow(
                label: 'Word Count',
                value: '$wordCount words',
                isInfo: true,
              ),
            ],
          ],

          // No data state
          if (calculatedPrice == null) ...[
            const SizedBox(height: 8),
            Text(
              'Complete the form to see pricing',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],

          // Urgency tiers selector
          if (onTierChange != null) ...[
            const SizedBox(height: 16),
            Text(
              'Select Urgency',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: UrgencyTier.values.map((tier) {
                final isSelected = urgencyTier == tier;
                return Expanded(
                  child: GestureDetector(
                    onTap: onTierChange,
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            tier.icon,
                            size: 16,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tier.name,
                            style: AppTextStyles.caption.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  double? _calculateTotalPrice() {
    if (basePrice == null) return null;
    final multiplier = urgencyTier?.multiplier ?? 1.0;
    return basePrice! * multiplier;
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isInfo;

  const _BreakdownRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isInfo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.labelSmall.copyWith(
            color: valueColor ?? (isInfo ? AppColors.textTertiary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// Compact budget card for form summary.
class BudgetCard extends StatelessWidget {
  final double? price;
  final String? subtitle;

  const BudgetCard({
    super.key,
    this.price,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subtitle ?? 'Estimated Total',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withAlpha(180),
                  ),
                ),
                Text(
                  price != null ? '₹${price!.toStringAsFixed(0)}' : 'Calculating...',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}

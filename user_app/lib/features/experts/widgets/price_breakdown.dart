import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';

/// Price breakdown widget with animated expansion.
///
/// Shows detailed pricing information:
/// - Base consultation fee
/// - Platform fee (10%)
/// - Taxes (18% GST on subtotal)
/// - Total amount
///
/// Uses flat Coffee Bean card design (no glass morphism).
class PriceBreakdown extends StatefulWidget {
  /// Base consultation price (expert's fee).
  final double basePrice;

  /// Platform fee percentage (default 10%).
  final double platformFeePercent;

  /// Tax percentage (default 18% GST).
  final double taxPercent;

  /// Whether to show the breakdown expanded by default.
  final bool initiallyExpanded;

  /// Optional title override.
  final String? title;

  const PriceBreakdown({
    super.key,
    required this.basePrice,
    this.platformFeePercent = 10.0,
    this.taxPercent = 18.0,
    this.initiallyExpanded = false,
    this.title,
  });

  @override
  State<PriceBreakdown> createState() => _PriceBreakdownState();
}

class _PriceBreakdownState extends State<PriceBreakdown>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  double get platformFee => widget.basePrice * (widget.platformFeePercent / 100);
  double get subtotal => widget.basePrice + platformFee;
  double get tax => subtotal * (widget.taxPercent / 100);
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row (always visible)
          InkWell(
            onTap: _toggleExpand,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title ?? 'Price Breakdown'.tr(context),
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _isExpanded
                              ? 'Tap to hide details'.tr(context)
                              : 'Tap to view details'.tr(context),
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\u20B9${total.toStringAsFixed(0)}',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: _rotateAnimation,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable details
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1.0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  // Base fee
                  _buildPriceRow(
                    label: 'Consultation Fee'.tr(context),
                    value: widget.basePrice,
                  ),
                  const SizedBox(height: 12),

                  // Platform fee
                  _buildPriceRow(
                    label: '${'Platform Fee'.tr(context)} (${widget.platformFeePercent.toStringAsFixed(0)}%)',
                    value: platformFee,
                  ),
                  const SizedBox(height: 12),

                  // Subtotal
                  _buildPriceRow(
                    label: 'Subtotal'.tr(context),
                    value: subtotal,
                    bold: true,
                  ),
                  const SizedBox(height: 12),

                  // GST
                  _buildPriceRow(
                    label: 'GST (${widget.taxPercent.toStringAsFixed(0)}%)',
                    value: tax,
                  ),
                  const SizedBox(height: 16),

                  Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: 16),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount'.tr(context),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '\u20B9${total.toStringAsFixed(0)}',
                        style: AppTextStyles.headingMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withAlpha(30)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'All prices are inclusive of applicable taxes'
                                .tr(context),
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double value,
    bool bold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '\u20B9${value.toStringAsFixed(0)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Compact price breakdown for inline display.
class PriceBreakdownCompact extends StatelessWidget {
  final double basePrice;
  final double platformFeePercent;
  final double taxPercent;

  const PriceBreakdownCompact({
    super.key,
    required this.basePrice,
    this.platformFeePercent = 10.0,
    this.taxPercent = 18.0,
  });

  double get platformFee => basePrice * (platformFeePercent / 100);
  double get subtotal => basePrice + platformFee;
  double get tax => subtotal * (taxPercent / 100);
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\u20B9${total.toStringAsFixed(0)}',
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'incl. taxes & fees'.tr(context),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

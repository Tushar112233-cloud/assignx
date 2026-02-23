import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Price breakdown widget with animated expansion.
///
/// Shows detailed pricing information:
/// - Base consultation fee
/// - Platform fee (5%)
/// - Taxes (18% GST)
/// - Total amount
///
/// Features:
/// - Animated expand/collapse for details
/// - Glassmorphic card styling
/// - Takes basePrice and calculates all fees
class PriceBreakdown extends StatefulWidget {
  /// Base consultation price (expert's fee).
  final double basePrice;

  /// Platform fee percentage (default 5%).
  final double platformFeePercent;

  /// Tax percentage (default 18% GST).
  final double taxPercent;

  /// Whether to show the breakdown expanded by default.
  final bool initiallyExpanded;

  /// Optional title override.
  final String? title;

  /// Use dark theme styling.
  final bool darkTheme;

  const PriceBreakdown({
    super.key,
    required this.basePrice,
    this.platformFeePercent = 5.0,
    this.taxPercent = 18.0,
    this.initiallyExpanded = false,
    this.title,
    this.darkTheme = false,
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

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

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

  // Calculate fees
  double get platformFee => widget.basePrice * (widget.platformFeePercent / 100);
  double get subtotal => widget.basePrice + platformFee;
  double get tax => subtotal * (widget.taxPercent / 100);
  double get total => subtotal + tax;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.darkTheme
        ? AppColors.surfaceDark
        : Colors.white;
    final textColor = widget.darkTheme
        ? Colors.white
        : AppColors.textPrimary;
    final secondaryTextColor = widget.darkTheme
        ? Colors.white70
        : AppColors.textSecondary;
    final tertiaryTextColor = widget.darkTheme
        ? Colors.white54
        : AppColors.textTertiary;
    final borderColor = widget.darkTheme
        ? Colors.white.withAlpha(20)
        : AppColors.border;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: widget.darkTheme
                ? bgColor.withAlpha(200)
                : bgColor.withAlpha(230),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row (always visible)
              InkWell(
                onTap: _toggleExpand,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
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
                              widget.title ?? 'Price Breakdown',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            Text(
                              'Tap to ${_isExpanded ? 'hide' : 'view'} details',
                              style: AppTextStyles.caption.copyWith(
                                color: tertiaryTextColor,
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
                          color: secondaryTextColor,
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
                      Container(
                        height: 1,
                        color: borderColor,
                      ),
                      const SizedBox(height: 16),

                      // Base consultation fee
                      _buildPriceRow(
                        label: 'Consultation Fee',
                        value: widget.basePrice,
                        textColor: textColor,
                        secondaryColor: secondaryTextColor,
                      ),
                      const SizedBox(height: 12),

                      // Platform fee
                      _buildPriceRow(
                        label: 'Platform Fee (${widget.platformFeePercent.toStringAsFixed(0)}%)',
                        value: platformFee,
                        textColor: textColor,
                        secondaryColor: secondaryTextColor,
                        showFreeIfZero: true,
                      ),
                      const SizedBox(height: 12),

                      // Tax
                      _buildPriceRow(
                        label: 'GST (${widget.taxPercent.toStringAsFixed(0)}%)',
                        value: tax,
                        textColor: textColor,
                        secondaryColor: secondaryTextColor,
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              borderColor.withAlpha(0),
                              borderColor,
                              borderColor.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: textColor,
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

                      // Tax info note
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.info.withAlpha(15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.info.withAlpha(30),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: AppColors.info,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'All prices are inclusive of applicable taxes',
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
        ),
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required double value,
    required Color textColor,
    required Color secondaryColor,
    bool showFreeIfZero = false,
  }) {
    final displayValue = showFreeIfZero && value == 0
        ? 'Free'
        : '\u20B9${value.toStringAsFixed(0)}';
    final valueColor = showFreeIfZero && value == 0
        ? AppColors.success
        : textColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: secondaryColor,
          ),
        ),
        Text(
          displayValue,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: valueColor,
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
    this.platformFeePercent = 5.0,
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
              'incl. taxes & fees',
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

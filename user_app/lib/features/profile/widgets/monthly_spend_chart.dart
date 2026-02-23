import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Category for spending breakdown.
class SpendCategory {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  const SpendCategory({
    required this.name,
    required this.amount,
    required this.color,
    required this.icon,
  });
}

/// Monthly spend data for the chart.
class MonthlySpendData {
  final String month;
  final double amount;
  final bool isCurrentMonth;

  const MonthlySpendData({
    required this.month,
    required this.amount,
    this.isCurrentMonth = false,
  });
}

/// Chart data including monthly amounts and category breakdown.
class SpendChartData {
  final List<MonthlySpendData> monthlyData;
  final List<SpendCategory> categories;
  final double totalThisMonth;

  const SpendChartData({
    required this.monthlyData,
    required this.categories,
    required this.totalThisMonth,
  });

  /// Get the maximum amount for scaling the chart.
  double get maxAmount {
    if (monthlyData.isEmpty) return 0;
    return monthlyData.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
  }
}

/// Monthly spend chart widget with bar chart and category breakdown.
///
/// Features:
/// - Simple bar chart showing last 6 months spending
/// - Custom painted chart (no external package required)
/// - Total spent this month highlighted
/// - Category breakdown (Projects, Consultations, Top-ups)
/// - Collapsible design
class MonthlySpendChart extends StatefulWidget {
  /// Chart data. If null, uses sample data.
  final SpendChartData? data;

  /// Whether to start expanded.
  final bool initiallyExpanded;

  const MonthlySpendChart({
    super.key,
    this.data,
    this.initiallyExpanded = false,
  });

  @override
  State<MonthlySpendChart> createState() => _MonthlySpendChartState();
}

class _MonthlySpendChartState extends State<MonthlySpendChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _barAnimation;
  bool _isExpanded = false;

  /// Sample data for demonstration.
  static final SpendChartData _sampleData = SpendChartData(
    monthlyData: [
      const MonthlySpendData(month: 'Aug', amount: 2400),
      const MonthlySpendData(month: 'Sep', amount: 3200),
      const MonthlySpendData(month: 'Oct', amount: 2800),
      const MonthlySpendData(month: 'Nov', amount: 4100),
      const MonthlySpendData(month: 'Dec', amount: 3500),
      const MonthlySpendData(month: 'Jan', amount: 2950, isCurrentMonth: true),
    ],
    categories: [
      SpendCategory(
        name: 'Projects',
        amount: 1850,
        color: AppColors.primary,
        icon: Icons.work_outline_rounded,
      ),
      SpendCategory(
        name: 'Consultations',
        amount: 650,
        color: const Color(0xFF3B82F6),
        icon: Icons.support_agent_rounded,
      ),
      SpendCategory(
        name: 'Top-ups',
        amount: 450,
        color: const Color(0xFF10B981),
        icon: Icons.account_balance_wallet_rounded,
      ),
    ],
    totalThisMonth: 2950,
  );

  SpendChartData get _data => widget.data ?? _sampleData;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _barAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
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

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    const Color(0xFF8B5CF6).withValues(alpha: 0.06),
                    const Color(0xFF7C3AED).withValues(alpha: 0.03),
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
            children: [
              // Header - always visible
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleExpanded,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Chart icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Title and amount
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Monthly Spending',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '\u20B9${_data.totalThisMonth.toStringAsFixed(0)}',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF8B5CF6),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'this month',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 11,
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Expand icon
                        RotationTransition(
                          turns: _rotationAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expandable content
              SizeTransition(
                sizeFactor: _heightAnimation,
                child: Column(
                  children: [
                    // Divider
                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),

                    // Bar chart
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: AnimatedBuilder(
                        animation: _barAnimation,
                        builder: (context, child) {
                          return _BarChart(
                            data: _data.monthlyData,
                            maxAmount: _data.maxAmount,
                            animationValue: _barAnimation.value,
                          );
                        },
                      ),
                    ),

                    // Category breakdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: _CategoryBreakdown(categories: _data.categories),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Custom bar chart widget.
class _BarChart extends StatelessWidget {
  final List<MonthlySpendData> data;
  final double maxAmount;
  final double animationValue;

  const _BarChart({
    required this.data,
    required this.maxAmount,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((monthData) {
          final barHeight = maxAmount > 0
              ? (monthData.amount / maxAmount) * 100 * animationValue
              : 0.0;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Amount label (only for current month)
                  if (monthData.isCurrentMonth)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '\u20B9${monthData.amount.toStringAsFixed(0)}',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 18),

                  // Bar
                  Container(
                    height: barHeight,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: monthData.isCurrentMonth
                            ? const [Color(0xFF8B5CF6), Color(0xFF7C3AED)]
                            : [
                                AppColors.border.withValues(alpha: 0.8),
                                AppColors.border,
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                      boxShadow: monthData.isCurrentMonth
                          ? [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Month label
                  Text(
                    monthData.month,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      fontWeight: monthData.isCurrentMonth
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: monthData.isCurrentMonth
                          ? const Color(0xFF8B5CF6)
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Category breakdown widget.
class _CategoryBreakdown extends StatelessWidget {
  final List<SpendCategory> categories;

  const _CategoryBreakdown({required this.categories});

  @override
  Widget build(BuildContext context) {
    final total = categories.fold<double>(0, (sum, cat) => sum + cat.amount);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Breakdown',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar showing all categories
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Row(
                children: categories.map((category) {
                  final width = total > 0 ? category.amount / total : 0.0;
                  return Flexible(
                    flex: (width * 100).round(),
                    child: Container(
                      color: category.color,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category list
          Row(
            children: categories.map((category) {
              final percentage = total > 0
                  ? ((category.amount / total) * 100).round()
                  : 0;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: category.color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '$percentage%',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: category.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

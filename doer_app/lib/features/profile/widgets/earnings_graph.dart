/// Earnings Graph widget for visualizing doer earnings over time.
///
/// Displays a line chart using fl_chart with gradient fill, period selection
/// (daily, weekly, monthly views), and trend indicators.
///
/// ## Features
/// - fl_chart line chart with gradient fill
/// - Period selector (7 days, 30 days, 90 days)
/// - Total earnings for selected period
/// - Interactive touch data points
/// - Trend indicators
///
/// ## Usage
/// ```dart
/// EarningsGraph(
///   earningsData: earningsData,
///   totalEarnings: 45000,
/// )
/// ```
///
/// See also:
/// - [ProfileScreen] for profile display
/// - [PaymentHistoryScreen] for payment details
library;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';

/// Earnings data point model.
class EarningsDataPoint {
  /// Date of the earnings.
  final DateTime date;

  /// Amount earned on this date.
  final double amount;

  const EarningsDataPoint({
    required this.date,
    required this.amount,
  });
}

/// Time period for earnings display.
enum EarningsPeriod {
  week('7 Days', 7),
  month('30 Days', 30),
  quarter('90 Days', 90);

  final String label;
  final int days;

  const EarningsPeriod(this.label, this.days);
}

/// Earnings Graph widget using fl_chart.
class EarningsGraph extends StatefulWidget {
  /// List of earnings data points.
  final List<EarningsDataPoint>? earningsData;

  /// Total earnings to display.
  final double? totalEarnings;

  /// Callback when period changes.
  final ValueChanged<EarningsPeriod>? onPeriodChanged;

  const EarningsGraph({
    super.key,
    this.earningsData,
    this.totalEarnings,
    this.onPeriodChanged,
  });

  @override
  State<EarningsGraph> createState() => _EarningsGraphState();
}

class _EarningsGraphState extends State<EarningsGraph> {
  EarningsPeriod _selectedPeriod = EarningsPeriod.month;

  /// Mock earnings data for demonstration.
  List<EarningsDataPoint> get _data {
    if (widget.earningsData != null) {
      return widget.earningsData!;
    }

    // Generate mock data
    final now = DateTime.now();
    return List.generate(_selectedPeriod.days, (index) {
      final date =
          now.subtract(Duration(days: _selectedPeriod.days - index - 1));
      final baseAmount = 500.0 + (index * 50);
      final variation = (index % 7 == 0 || index % 7 == 6) ? 0.3 : 1.0;
      final weeklyBonus = (index % 7 == 5) ? 800.0 : 0.0;
      return EarningsDataPoint(
        date: date,
        amount: (baseAmount * variation + weeklyBonus) *
            (0.5 + (index / _selectedPeriod.days)),
      );
    });
  }

  /// Calculates total for the selected period.
  double get _periodTotal {
    if (widget.totalEarnings != null) {
      return widget.totalEarnings!;
    }
    return _data.fold(0.0, (sum, point) => sum + point.amount);
  }

  /// Calculates average daily earnings.
  double get _dailyAverage {
    if (_data.isEmpty) return 0;
    return _periodTotal / _data.length;
  }

  /// Calculates trend percentage.
  double get _trendPercentage {
    if (_data.length < 2) return 0;

    final halfLength = _data.length ~/ 2;
    final firstHalf = _data.sublist(0, halfLength);
    final secondHalf = _data.sublist(halfLength);

    final firstSum = firstHalf.fold(0.0, (sum, p) => sum + p.amount);
    final secondSum = secondHalf.fold(0.0, (sum, p) => sum + p.amount);

    if (firstSum == 0) return 100;
    return ((secondSum - firstSum) / firstSum) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and period selector
            _buildHeader(),

            const SizedBox(height: AppSpacing.md),

            // Stats row
            _buildStatsRow(),

            const SizedBox(height: AppSpacing.lg),

            // fl_chart line chart
            _buildFlChart(),

            const SizedBox(height: AppSpacing.md),

            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  /// Builds the header with title and period selector.
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.trending_up,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          'Earnings Overview'.tr(context),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: EarningsPeriod.values.map((period) {
              final isSelected = period == _selectedPeriod;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPeriod = period;
                  });
                  widget.onPeriodChanged?.call(period);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    period.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Builds the statistics row.
  Widget _buildStatsRow() {
    final trend = _trendPercentage;
    final isPositive = trend >= 0;

    return Row(
      children: [
        // Total earnings
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Earnings'.tr(context),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\u20B9'.tr(context),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  Text(
                    _formatAmount(_periodTotal),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Trend indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: (isPositive ? AppColors.success : AppColors.error)
                .withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Daily average
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Daily Avg'.tr(context),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\u20B9${_formatAmount(_dailyAverage)}'.tr(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the fl_chart line chart with gradient fill.
  Widget _buildFlChart() {
    if (_data.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(child: Text('No data available'.tr(context))),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < _data.length; i++) {
      spots.add(FlSpot(i.toDouble(), _data[i].amount));
    }

    final maxY =
        _data.map((p) => p.amount).reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = 0.0;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.border,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: const FlTitlesData(
            show: false,
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (_data.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '\u20B9${_formatAmount(spot.y)}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: const Color(0xFF5A7CFF),
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Only show dots at key intervals
                  final step = (_data.length / 7).ceil();
                  if (index % step != 0 && index != _data.length - 1) {
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
                      strokeWidth: 0,
                      strokeColor: Colors.transparent,
                    );
                  }
                  return FlDotCirclePainter(
                    radius: 3.5,
                    color: const Color(0xFF5A7CFF),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF5A7CFF).withValues(alpha: 0.3),
                    const Color(0xFF5A7CFF).withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
  }

  /// Builds the chart legend.
  Widget _buildLegend() {
    if (_data.isEmpty) return const SizedBox.shrink();

    final firstDate = _data.first.date;
    final lastDate = _data.last.date;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDate(firstDate),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
        Text(
          _formatDate(lastDate),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  /// Formats amount for display.
  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Formats date for display.
  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }
}

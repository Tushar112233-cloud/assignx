import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/earnings_model.dart';

/// Earnings line chart widget.
class EarningsLineChart extends StatelessWidget {
  const EarningsLineChart({
    super.key,
    required this.dataPoints,
    this.height = 200,
    this.showGrid = true,
    this.animate = true,
  });

  final List<EarningsDataPoint> dataPoints;
  final double height;
  final bool showGrid;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('No data available'.tr(context)),
        ),
      );
    }

    final maxY = dataPoints.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final minY = dataPoints.map((e) => e.amount).reduce((a, b) => a < b ? a : b);
    final range = maxY - minY;
    final safeRange = range <= 0 ? (maxY <= 0 ? 1.0 : maxY * 0.25) : range;
    final adjustedMaxY = maxY + (safeRange * 0.1);
    final adjustedMinY = (minY - (safeRange * 0.1)).clamp(0.0, double.infinity);
    final safeInterval = ((adjustedMaxY - adjustedMinY) / 4).abs();
    final horizontalInterval = safeInterval > 0 ? safeInterval : 1.0;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: false,
            horizontalInterval: horizontalInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dataPoints.length) {
                    return const SizedBox.shrink();
                  }
                  // Show every other label to avoid crowding
                  if (dataPoints.length > 7 && index % 2 != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dataPoints[index].shortLabel,
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: horizontalInterval,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${value.toInt()}',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: adjustedMinY,
          maxY: adjustedMaxY,
          lineBarsData: [
            LineChartBarData(
              spots: dataPoints.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount);
              }).toList(),
              isCurved: true,
              curveSmoothness: 0.3,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.3),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) => AppColors.surface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final dataPoint = dataPoints[spot.x.toInt()];
                  return LineTooltipItem(
                    '₹${dataPoint.amount.toStringAsFixed(2)}\n${dataPoint.label}',
                    TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: animate ? const Duration(milliseconds: 500) : Duration.zero,
      ),
    );
  }
}

/// Earnings bar chart widget.
class EarningsBarChart extends StatelessWidget {
  const EarningsBarChart({
    super.key,
    required this.dataPoints,
    this.height = 200,
    this.showGrid = true,
  });

  final List<EarningsDataPoint> dataPoints;
  final double height;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text('No data available'.tr(context)),
        ),
      );
    }

    final maxY = dataPoints.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final safeMaxY = maxY > 0 ? maxY : 1.0;
    final horizontalInterval = (safeMaxY / 4).clamp(0.25, double.infinity);

    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(
            show: showGrid,
            drawVerticalLine: false,
            horizontalInterval: horizontalInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dataPoints.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dataPoints[index].shortLabel,
                      style: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: horizontalInterval,
                reservedSize: 45,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${value.toInt()}',
                    style: TextStyle(
                      color: AppColors.textSecondaryLight,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: dataPoints.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.amount,
                  color: AppColors.primary,
                  width: dataPoints.length > 10 ? 12 : 20,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: safeMaxY * 1.1,
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.05),
                  ),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => AppColors.surface,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final dataPoint = dataPoints[groupIndex];
                return BarTooltipItem(
                  '₹${dataPoint.amount.toStringAsFixed(2)}\n${dataPoint.label}',
                  TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Commission pie chart widget.
class CommissionPieChart extends StatefulWidget {
  const CommissionPieChart({
    super.key,
    required this.breakdown,
    this.size = 200,
  });

  final List<CommissionBreakdown> breakdown;
  final double size;

  @override
  State<CommissionPieChart> createState() => _CommissionPieChartState();
}

class _CommissionPieChartState extends State<CommissionPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.breakdown.isEmpty) {
      return SizedBox(
        height: widget.size,
        child: Center(
          child: Text('No data available'.tr(context)),
        ),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: widget.size * 0.2,
              sections: widget.breakdown.asMap().entries.map((entry) {
                final isTouched = entry.key == touchedIndex;
                final radius = isTouched ? widget.size * 0.35 : widget.size * 0.3;
                return PieChartSectionData(
                  color: entry.value.color,
                  value: entry.value.amount,
                  title: '${entry.value.percentage.toStringAsFixed(0)}%',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: isTouched ? 14 : 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.breakdown.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.category,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '₹${item.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Earnings chart card with toggle between line and bar chart.
class EarningsChartCard extends StatefulWidget {
  const EarningsChartCard({
    super.key,
    required this.dataPoints,
    this.title = 'Earnings Overview',
  });

  final List<EarningsDataPoint> dataPoints;
  final String title;

  @override
  State<EarningsChartCard> createState() => _EarningsChartCardState();
}

class _EarningsChartCardState extends State<EarningsChartCard> {
  bool _showLineChart = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    _ChartTypeButton(
                      icon: Icons.show_chart,
                      isSelected: _showLineChart,
                      onTap: () => setState(() => _showLineChart = true),
                    ),
                    const SizedBox(width: 4),
                    _ChartTypeButton(
                      icon: Icons.bar_chart,
                      isSelected: !_showLineChart,
                      onTap: () => setState(() => _showLineChart = false),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showLineChart
                  ? EarningsLineChart(
                      key: const ValueKey('line'),
                      dataPoints: widget.dataPoints,
                    )
                  : EarningsBarChart(
                      key: const ValueKey('bar'),
                      dataPoints: widget.dataPoints,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartTypeButton extends StatelessWidget {
  const _ChartTypeButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

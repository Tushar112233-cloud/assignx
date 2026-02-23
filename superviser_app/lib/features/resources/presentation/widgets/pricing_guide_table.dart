import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/pricing_model.dart';

/// Widget for displaying the pricing guide table.
///
/// Shows prices for different work types and academic levels.
class PricingGuideTable extends StatelessWidget {
  const PricingGuideTable({
    super.key,
    required this.guide,
    this.onWorkTypeSelected,
  });

  /// Pricing guide data.
  final PricingGuide guide;

  /// Called when a work type is selected.
  final void Function(WorkType)? onWorkTypeSelected;

  @override
  Widget build(BuildContext context) {
    // Group pricings by work type
    final groupedPricings = <WorkType, List<PricingModel>>{};
    for (final pricing in guide.pricings) {
      groupedPricings.putIfAbsent(pricing.workType, () => []).add(pricing);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.monetization_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Pricing Guide',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              if (guide.lastUpdated != null)
                Text(
                  'Updated ${_formatDate(guide.lastUpdated!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
            ],
          ),
        ),
        // Urgency legend
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _UrgencyLegend(),
        ),
        const SizedBox(height: 16),
        // Work type sections
        ...WorkType.values.map((type) {
          final pricings = groupedPricings[type];
          if (pricings == null || pricings.isEmpty) return const SizedBox();
          return _WorkTypeSection(
            workType: type,
            pricings: pricings,
            onTap: onWorkTypeSelected != null
                ? () => onWorkTypeSelected!(type)
                : null,
          );
        }),
        // Notes
        if (guide.notes != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      guide.notes!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.info,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Section for a specific work type.
class _WorkTypeSection extends StatelessWidget {
  const _WorkTypeSection({
    required this.workType,
    required this.pricings,
    this.onTap,
  });

  final WorkType workType;
  final List<PricingModel> pricings;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      workType.icon,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      workType.displayName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Price table
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: BoxDecoration(
                      color: AppColors.textSecondaryLight.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    children: [
                      _TableCell(
                        text: 'Academic Level',
                        isHeader: true,
                      ),
                      _TableCell(
                        text: 'Per Page',
                        isHeader: true,
                        alignment: TextAlign.right,
                      ),
                    ],
                  ),
                  // Data rows
                  ...pricings.map((pricing) => TableRow(
                        children: [
                          _TableCell(
                            text: pricing.academicLevel.displayName,
                          ),
                          _TableCell(
                            text: '₹${pricing.basePrice.toStringAsFixed(2)}',
                            alignment: TextAlign.right,
                            color: AppColors.success,
                            isBold: true,
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Table cell widget.
class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.text,
    this.isHeader = false,
    this.alignment = TextAlign.left,
    this.color,
    this.isBold = false,
  });

  final String text;
  final bool isHeader;
  final TextAlign alignment;
  final Color? color;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: alignment,
        style: TextStyle(
          fontSize: isHeader ? 12 : 14,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: color ??
              (isHeader ? AppColors.textSecondaryLight : null),
        ),
      ),
    );
  }
}

/// Urgency multiplier legend.
class _UrgencyLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: UrgencyLevel.values.map((level) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _getUrgencyColor(level).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                level.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: _getUrgencyColor(level),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '×${level.multiplier.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 11,
                  color: _getUrgencyColor(level),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getUrgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.standard:
        return Colors.green;
      case UrgencyLevel.moderate:
        return Colors.orange;
      case UrgencyLevel.urgent:
        return Colors.deepOrange;
      case UrgencyLevel.express:
        return Colors.red;
    }
  }
}

/// Pricing calculator widget.
class PricingCalculator extends StatelessWidget {
  const PricingCalculator({
    super.key,
    required this.selectedWorkType,
    required this.selectedLevel,
    required this.selectedUrgency,
    required this.pageCount,
    required this.calculatedPrice,
    required this.onWorkTypeChanged,
    required this.onLevelChanged,
    required this.onUrgencyChanged,
    required this.onPageCountChanged,
  });

  final WorkType? selectedWorkType;
  final AcademicLevel selectedLevel;
  final UrgencyLevel selectedUrgency;
  final int pageCount;
  final double? calculatedPrice;
  final void Function(WorkType?) onWorkTypeChanged;
  final void Function(AcademicLevel) onLevelChanged;
  final void Function(UrgencyLevel) onUrgencyChanged;
  final void Function(int) onPageCountChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price Calculator',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            // Work Type Dropdown
            DropdownButtonFormField<WorkType>(
              value: selectedWorkType,
              decoration: const InputDecoration(
                labelText: 'Work Type',
                prefixIcon: Icon(Icons.work_outline),
              ),
              items: WorkType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(type.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onWorkTypeChanged,
            ),
            const SizedBox(height: 16),
            // Academic Level Dropdown
            DropdownButtonFormField<AcademicLevel>(
              value: selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Academic Level',
                prefixIcon: Icon(Icons.school_outlined),
              ),
              items: AcademicLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onLevelChanged(value);
              },
            ),
            const SizedBox(height: 16),
            // Urgency Dropdown
            DropdownButtonFormField<UrgencyLevel>(
              value: selectedUrgency,
              decoration: const InputDecoration(
                labelText: 'Urgency',
                prefixIcon: Icon(Icons.schedule_outlined),
              ),
              items: UrgencyLevel.values.map((urgency) {
                return DropdownMenuItem(
                  value: urgency,
                  child: Row(
                    children: [
                      Text(urgency.displayName),
                      const SizedBox(width: 8),
                      Text(
                        '(×${urgency.multiplier})',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) onUrgencyChanged(value);
              },
            ),
            const SizedBox(height: 16),
            // Page Count
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Number of Pages',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: pageCount > 1
                      ? () => onPageCountChanged(pageCount - 1)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    pageCount.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => onPageCountChanged(pageCount + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Calculated Price
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Price',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    calculatedPrice != null
                        ? '₹${calculatedPrice!.toStringAsFixed(2)}'
                        : '--',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (calculatedPrice != null)
                    Text(
                      '($pageCount pages × ₹${(calculatedPrice! / pageCount).toStringAsFixed(2)}/page)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

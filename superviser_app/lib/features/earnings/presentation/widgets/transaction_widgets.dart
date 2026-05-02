import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/misc/status_badge.dart';
import '../../data/models/transaction_model.dart';

/// Card displaying a single transaction.
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Transaction type icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: transaction.type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  transaction.type.icon,
                  color: transaction.type.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.type.displayName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          transaction.formattedAmount,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: transaction.type.isCredit
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.description ?? '',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusBadge.fromDisplayable(
                          displayName: transaction.status.displayName,
                          color: transaction.status.color,
                          size: StatusBadgeSize.small,
                          showIcon: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (transaction.projectTitle != null) ...[
                          Icon(
                            Icons.folder_outlined,
                            size: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              transaction.projectTitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ] else
                          const Spacer(),
                        Text(
                          transaction.formattedTime,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// List of transactions grouped by date.
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoading = false,
  });

  final List<TransactionModel> transactions;
  final void Function(TransactionModel) onTransactionTap;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty && !isLoading) {
      return const _EmptyTransactions();
    }

    // Group transactions by date
    final grouped = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      grouped.putIfAbsent(tx.formattedDate, () => []).add(tx);
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            hasMore &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: grouped.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= grouped.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final date = grouped.keys.elementAt(index);
          final dayTransactions = grouped[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  date,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              ...dayTransactions.map((tx) => TransactionCard(
                    transaction: tx,
                    onTap: () => onTransactionTap(tx),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet'.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your earnings and withdrawals will appear here'.tr(context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction filter sheet.
class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  final TransactionFilter currentFilter;
  final void Function(TransactionFilter) onApply;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late Set<TransactionType> _selectedTypes;
  late Set<TransactionStatus> _selectedStatuses;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedTypes = widget.currentFilter.types?.toSet() ?? {};
    _selectedStatuses = widget.currentFilter.statuses?.toSet() ?? {};
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Transactions'.tr(context),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: Text('Clear All'.tr(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction Types
          Text(
            'Transaction Type'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransactionType.values.map((type) {
              final isSelected = _selectedTypes.contains(type);
              return FilterChip(
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTypes.add(type);
                    } else {
                      _selectedTypes.remove(type);
                    }
                  });
                },
                label: Text(type.displayName),
                selectedColor: type.color.withValues(alpha: 0.2),
                avatar: Icon(type.icon, size: 16, color: type.color),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Transaction Status
          Text(
            'Status'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TransactionStatus.values.map((status) {
              final isSelected = _selectedStatuses.contains(status);
              return FilterChip(
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
                label: Text(status.displayName),
                selectedColor: status.color.withValues(alpha: 0.2),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Date Range
          Text(
            'Date Range'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateButton(
                  label: 'From'.tr(context),
                  date: _startDate,
                  onTap: () => _selectDate(true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: 'To'.tr(context),
                  date: _endDate,
                  onTap: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _applyFilters,
              child: Text('Apply Filters'.tr(context)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes.clear();
      _selectedStatuses.clear();
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(2020),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilters() {
    widget.onApply(TransactionFilter(
      types: _selectedTypes.isEmpty ? null : _selectedTypes.toList(),
      statuses: _selectedStatuses.isEmpty ? null : _selectedStatuses.toList(),
      startDate: _startDate,
      endDate: _endDate,
    ));
    Navigator.pop(context);
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              date != null
                  ? '${date!.day}/${date!.month}/${date!.year}'
                  : label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction detail bottom sheet.
class TransactionDetailSheet extends StatelessWidget {
  const TransactionDetailSheet({
    super.key,
    required this.transaction,
  });

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon and amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transaction.type.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.type.icon,
              color: transaction.type.color,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            transaction.formattedAmount,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.type.isCredit
                      ? AppColors.success
                      : AppColors.error,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            transaction.type.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 24),

          // Details
          _DetailRow(
            label: 'Status'.tr(context),
            value: transaction.status.displayName,
            valueColor: transaction.status.color,
          ),
          _DetailRow(
            label: 'Date'.tr(context),
            value: transaction.formattedDate,
          ),
          _DetailRow(
            label: 'Time'.tr(context),
            value: transaction.formattedTime,
          ),
          if (transaction.description != null && transaction.description!.isNotEmpty)
            _DetailRow(
              label: 'Description'.tr(context),
              value: transaction.description!,
            ),
          if (transaction.projectTitle != null)
            _DetailRow(
              label: 'Project'.tr(context),
              value: transaction.projectTitle!,
            ),
          if (transaction.reference != null)
            _DetailRow(
              label: 'Reference'.tr(context),
              value: transaction.reference!,
            ),
          if (transaction.balanceAfter != null)
            _DetailRow(
              label: 'Balance After'.tr(context),
              value: '₹${transaction.balanceAfter!.toStringAsFixed(2)}',
            ),
          const SizedBox(height: 24),

          // Close button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'.tr(context)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

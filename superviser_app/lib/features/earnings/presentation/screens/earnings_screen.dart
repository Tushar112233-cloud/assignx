import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/earnings_model.dart';
import '../../data/models/transaction_model.dart';
import '../providers/earnings_provider.dart';
import '../widgets/earnings_chart.dart';
import '../widgets/stats_widgets.dart';
import '../widgets/transaction_widgets.dart';

/// Main earnings screen with tabs for overview, transactions, and commission.
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);
    final transactionsState = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Earnings'.tr(context)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Overview'.tr(context)),
            Tab(text: 'Transactions'.tr(context)),
            Tab(text: 'Commission'.tr(context)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(earningsProvider.notifier).refresh();
              ref.read(transactionsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: earningsState.isLoading && earningsState.summary == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Overview Tab
                _OverviewTab(
                  state: earningsState,
                  onPeriodChanged: (period) {
                    ref.read(earningsProvider.notifier).changePeriod(period);
                  },
                  onWithdraw: () => _showWithdrawDialog(context),
                  onRefresh: () async {
                    await ref.read(earningsProvider.notifier).refresh();
                  },
                ),
                // Transactions Tab
                _TransactionsTab(
                  state: transactionsState,
                  onTransactionTap: (tx) => _showTransactionDetail(context, tx),
                  onLoadMore: () =>
                      ref.read(transactionsProvider.notifier).loadMore(),
                  onFilterChanged: (filter) {
                    ref.read(transactionsProvider.notifier).updateFilter(filter);
                  },
                ),
                // Commission Tab
                _CommissionTab(
                  breakdown: earningsState.commissionBreakdown,
                  period: earningsState.selectedPeriod,
                  onPeriodChanged: (period) {
                    ref.read(earningsProvider.notifier).changePeriod(period);
                  },
                ),
              ],
            ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _WithdrawDialog(),
    );
  }

  void _showTransactionDetail(BuildContext context, TransactionModel tx) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionDetailSheet(transaction: tx),
    );
  }
}

/// Overview tab showing balance, metrics, and charts.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.state,
    required this.onPeriodChanged,
    this.onWithdraw,
    this.onRefresh,
  });

  final EarningsState state;
  final void Function(EarningsPeriod) onPeriodChanged;
  final VoidCallback? onWithdraw;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh ?? () async {},
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            PeriodSelector(
              selectedPeriod: state.selectedPeriod,
              onPeriodChanged: onPeriodChanged,
            ),

            // Empty state when no data
            if (state.summary == null && !state.isLoading) ...[
              const SizedBox(height: 80),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: AppColors.textSecondaryLight.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No earnings yet'.tr(context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Your earnings will appear here once you complete projects.'.tr(context),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Balance Card
            if (state.summary != null)
              BalanceCard(
                totalEarnings: state.summary!.totalEarnings,
                availableBalance: state.summary!.availableBalance,
                pendingEarnings: state.summary!.pendingEarnings,
                onWithdraw: onWithdraw,
              ),

            // Goal Tracker
            if (state.summary != null)
              _GoalTracker(
                currentEarnings: state.summary!.totalEarnings,
                goalAmount: 50000,
              ),

            // Earnings Snapshot
            if (state.summary != null)
              _EarningsSnapshot(
                totalEarnings: state.summary!.totalEarnings,
                monthlyEarnings: state.summary!.totalEarnings -
                    (state.summary!.previousPeriodEarnings ?? 0),
                todayEarnings: state.summary!.pendingEarnings,
              ),

            const SizedBox(height: 8),

            // Stats Cards Row
            if (state.summary != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: StatsCard(
                        title: 'Projects'.tr(context),
                        value: state.summary!.projectsCompleted.toString(),
                        icon: Icons.folder_copy,
                        iconColor: Colors.blue,
                        trend: (state.summary!.growthPercentage ?? 0) > 0
                            ? '+${state.summary!.growthPercentage!.toStringAsFixed(1)}%'
                            : null,
                        trendPositive: (state.summary!.growthPercentage ?? 0) > 0,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatsCard(
                        title: 'Avg/Project'.tr(context),
                        value: '₹${state.summary!.averagePerProject.toStringAsFixed(0)}',
                        icon: Icons.trending_up,
                        iconColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Earnings Chart
            if (state.chartData.isNotEmpty)
              EarningsChartCard(
                dataPoints: state.chartData,
                title: 'Earnings Trend'.tr(context),
              ),

            // Performance Metrics
            if (state.performanceMetrics != null)
              PerformanceMetricsWidget(
                metrics: state.performanceMetrics!,
              ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Transactions tab with list and filters.
class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab({
    required this.state,
    required this.onTransactionTap,
    required this.onLoadMore,
    required this.onFilterChanged,
  });

  final TransactionsState state;
  final void Function(TransactionModel) onTransactionTap;
  final VoidCallback onLoadMore;
  final void Function(TransactionFilter) onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Quick stats
              Expanded(
                child: Row(
                  children: [
                    _QuickStat(
                      label: 'Income'.tr(context),
                      value: '₹${state.totalCredits.toStringAsFixed(0)}',
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 16),
                    _QuickStat(
                      label: 'Outgoing'.tr(context),
                      value: '₹${state.totalDebits.toStringAsFixed(0)}',
                      color: AppColors.error,
                    ),
                  ],
                ),
              ),
              // Filter button
              IconButton.filledTonal(
                onPressed: () => _showFilterSheet(context),
                icon: Badge(
                  isLabelVisible: state.filter.hasFilters,
                  child: const Icon(Icons.filter_list),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Transaction list
        Expanded(
          child: TransactionList(
            transactions: state.transactions,
            onTransactionTap: onTransactionTap,
            onLoadMore: onLoadMore,
            hasMore: state.hasMore,
            isLoading: state.isLoading,
          ),
        ),
      ],
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionFilterSheet(
        currentFilter: state.filter,
        onApply: onFilterChanged,
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontSize: 10,
                  ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Commission tab with pie chart breakdown.
class _CommissionTab extends StatelessWidget {
  const _CommissionTab({
    required this.breakdown,
    required this.period,
    required this.onPeriodChanged,
  });

  final List<CommissionBreakdown> breakdown;
  final EarningsPeriod period;
  final void Function(EarningsPeriod) onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    final total = breakdown.fold(0.0, (sum, item) => sum + item.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          PeriodSelector(
            selectedPeriod: period,
            onPeriodChanged: onPeriodChanged,
          ),
          const SizedBox(height: 16),

          // Total earnings card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Total Commission'.tr(context),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${total.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${breakdown.fold(0, (sum, item) => sum + item.projectCount)} ${'projects'.tr(context)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pie chart
          Text(
            'Commission by Category'.tr(context),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          if (breakdown.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No commission data for this period'.tr(context),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ),
            )
          else
            CommissionPieChart(
              breakdown: breakdown,
              size: 180,
            ),

          const SizedBox(height: 24),

          // Detailed breakdown list
          if (breakdown.isNotEmpty) ...[
            Text(
              'Detailed Breakdown'.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...breakdown.map((item) => _CommissionItem(item: item)),
          ],
        ],
      ),
    );
  }
}

class _CommissionItem extends StatelessWidget {
  const _CommissionItem({required this.item});

  final CommissionBreakdown item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (item.color ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${item.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: item.color ?? AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    '${item.projectCount} ${'projects'.tr(context)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${item.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Goal tracker showing monthly earnings progress toward a target.
class _GoalTracker extends StatelessWidget {
  const _GoalTracker({
    required this.currentEarnings,
    required this.goalAmount,
  });

  final double currentEarnings;
  final double goalAmount;

  @override
  Widget build(BuildContext context) {
    final progress = (currentEarnings / goalAmount).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Monthly Goal'.tr(context),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '₹${goalAmount.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor:
                        AppColors.textSecondaryLight.withValues(alpha: 0.1),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${'₹${currentEarnings.toStringAsFixed(0)}'} ${'earned this month'.tr(context)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}

/// Earnings snapshot row with Total, This Month, and Today cards.
class _EarningsSnapshot extends StatelessWidget {
  const _EarningsSnapshot({
    required this.totalEarnings,
    required this.monthlyEarnings,
    required this.todayEarnings,
  });

  final double totalEarnings;
  final double monthlyEarnings;
  final double todayEarnings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _SnapshotCard(
              label: 'Total'.tr(context),
              value: '₹${totalEarnings.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SnapshotCard(
              label: 'This Month'.tr(context),
              value: '₹${monthlyEarnings.toStringAsFixed(0)}',
              icon: Icons.calendar_month,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _SnapshotCard(
              label: 'Today'.tr(context),
              value: '₹${todayEarnings.toStringAsFixed(0)}',
              icon: Icons.today,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual snapshot card used in [_EarningsSnapshot].
class _SnapshotCard extends StatelessWidget {
  const _SnapshotCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

/// Withdrawal dialog.
class _WithdrawDialog extends ConsumerStatefulWidget {
  const _WithdrawDialog();

  @override
  ConsumerState<_WithdrawDialog> createState() => _WithdrawDialogState();
}

class _WithdrawDialogState extends ConsumerState<_WithdrawDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'upi';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionsState = ref.watch(transactionsProvider);

    return AlertDialog(
      title: Text('Request Withdrawal'.tr(context)),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount'.tr(context),
                prefixText: '₹',
                hintText: '0.00',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
              ),
              items: const [
                DropdownMenuItem(value: 'upi', child: Text('UPI')),
                DropdownMenuItem(value: 'neft', child: Text('NEFT')),
                DropdownMenuItem(value: 'imps', child: Text('IMPS')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedMethod = value);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: transactionsState.isWithdrawing ? null : _submit,
          child: transactionsState.isWithdrawing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final result = await ref.read(transactionsProvider.notifier).requestWithdrawal(
            amount: amount,
            paymentMethod: _selectedMethod,
          );

      if (mounted) {
        Navigator.pop(context);
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Withdrawal request submitted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }
}

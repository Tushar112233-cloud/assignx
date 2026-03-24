import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/earnings_model.dart';
import '../../data/models/transaction_model.dart';
import '../providers/earnings_provider.dart';
import '../widgets/earnings_chart.dart';
import '../widgets/transaction_widgets.dart';

/// Redesigned earnings screen with a single-scroll layout.
///
/// Layout (top to bottom):
/// 1. Header with title and refresh
/// 2. Period selector pills
/// 3. 2x2 summary stat cards
/// 4. Monthly earnings chart section
/// 5. Recent transactions list
/// 6. Commission breakdown section
class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> {
  @override
  Widget build(BuildContext context) {
    final earningsState = ref.watch(earningsProvider);
    final transactionsState = ref.watch(transactionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              ref.read(earningsProvider.notifier).refresh(),
              ref.read(transactionsProvider.notifier).refresh(),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- Header --
                _Header(
                  onRefresh: () {
                    ref.read(earningsProvider.notifier).refresh();
                    ref.read(transactionsProvider.notifier).refresh();
                  },
                ),

                // -- Period Selector --
                _PeriodPills(
                  selected: earningsState.selectedPeriod,
                  onChanged: (p) {
                    ref.read(earningsProvider.notifier).changePeriod(p);
                  },
                ),
                const SizedBox(height: 20),

                // -- Loading state --
                if (earningsState.isLoading && earningsState.summary == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(child: CircularProgressIndicator()),
                  ),

                // -- Empty state --
                if (earningsState.summary == null &&
                    !earningsState.isLoading) ...[
                  const SizedBox(height: 60),
                  _EmptyState(),
                ],

                // -- Summary Cards 2x2 --
                if (earningsState.summary != null)
                  _SummaryGrid(summary: earningsState.summary!),

                // -- Earnings Chart --
                if (earningsState.chartData.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Monthly Earnings'.tr(context),
                    icon: Icons.bar_chart_rounded,
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _CardWrapper(
                      child: EarningsChartCard(
                        dataPoints: earningsState.chartData,
                        title: 'Earnings Trend'.tr(context),
                      ),
                    ),
                  ),
                ],

                // -- Recent Transactions --
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Recent Transactions'.tr(context),
                  icon: Icons.receipt_long_rounded,
                ),
                const SizedBox(height: 12),
                _RecentTransactionsList(
                  transactions: transactionsState.transactions,
                  isLoading: transactionsState.isLoading,
                  onTransactionTap: (tx) => _showTransactionDetail(context, tx),
                ),

                // -- Commission Breakdown --
                if (earningsState.commissionBreakdown.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: 'Commission Breakdown'.tr(context),
                    icon: Icons.pie_chart_rounded,
                  ),
                  const SizedBox(height: 12),
                  _CommissionBreakdownSection(
                    breakdown: earningsState.commissionBreakdown,
                  ),
                ],

                // -- Withdraw Button --
                if (earningsState.summary != null &&
                    earningsState.summary!.availableBalance > 0) ...[
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => _showWithdrawDialog(context),
                        icon: const Icon(Icons.account_balance_wallet_outlined),
                        label: Text(
                          'Request Withdrawal'.tr(context),
                          style: AppTypography.buttonMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
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

// =============================================================================
// Header
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          Text(
            'Earnings'.tr(context),
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Period Selector Pills
// =============================================================================

class _PeriodPills extends StatelessWidget {
  const _PeriodPills({required this.selected, required this.onChanged});

  final EarningsPeriod selected;
  final ValueChanged<EarningsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: EarningsPeriod.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final period = EarningsPeriod.values[index];
          final isSelected = period == selected;

          return GestureDetector(
            onTap: () => onChanged(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.borderLight,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                period.displayName,
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// =============================================================================
// Empty State
// =============================================================================

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 48,
                color: AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No earnings yet'.tr(context),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your earnings will appear here once you complete projects.'
                  .tr(context),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// 2x2 Summary Stat Cards
// =============================================================================

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final EarningsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Earnings'.tr(context),
                  value: _formatCurrency(summary.totalEarnings),
                  icon: Icons.account_balance_wallet_rounded,
                  iconBgColor: AppColors.info.withValues(alpha: 0.1),
                  iconColor: AppColors.info,
                  trend: summary.growthPercentage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'This Month'.tr(context),
                  value: _formatCurrency(
                    summary.totalEarnings -
                        (summary.previousPeriodEarnings ?? 0),
                  ),
                  icon: Icons.calendar_month_rounded,
                  iconBgColor: AppColors.accent.withValues(alpha: 0.1),
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Balance'.tr(context),
                  value: _formatCurrency(summary.availableBalance),
                  icon: Icons.savings_rounded,
                  iconBgColor: AppColors.success.withValues(alpha: 0.1),
                  iconColor: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Pending'.tr(context),
                  value: _formatCurrency(summary.pendingEarnings),
                  icon: Icons.hourglass_bottom_rounded,
                  iconBgColor: AppColors.warning.withValues(alpha: 0.1),
                  iconColor: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }
}

/// Individual stat card used in the 2x2 summary grid.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.trend,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final double? trend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              if (trend != null) _TrendBadge(trend: trend!),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small trend indicator badge showing growth percentage.
class _TrendBadge extends StatelessWidget {
  const _TrendBadge({required this.trend});

  final double trend;

  @override
  Widget build(BuildContext context) {
    final isPositive = trend >= 0;
    final color = isPositive ? AppColors.success : AppColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            '${isPositive ? '+' : ''}${trend.toStringAsFixed(1)}%',
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Section Header
// =============================================================================

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryLight),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Card Wrapper (removes the margin from inner chart card)
// =============================================================================

/// Wraps the existing [EarningsChartCard] to remove its built-in margin
/// so the outer padding controls positioning consistently.
class _CardWrapper extends StatelessWidget {
  const _CardWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
        ),
      ),
      child: child,
    );
  }
}

// =============================================================================
// Recent Transactions
// =============================================================================

class _RecentTransactionsList extends StatelessWidget {
  const _RecentTransactionsList({
    required this.transactions,
    required this.isLoading,
    required this.onTransactionTap,
  });

  final List<TransactionModel> transactions;
  final bool isLoading;
  final void Function(TransactionModel) onTransactionTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading && transactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (transactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 40,
                color: AppColors.textTertiaryLight,
              ),
              const SizedBox(height: 12),
              Text(
                'No transactions yet'.tr(context),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show up to 5 most recent transactions
    final recentTx = transactions.take(5).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < recentTx.length; i++) ...[
              _TransactionTile(
                transaction: recentTx[i],
                onTap: () => onTransactionTap(recentTx[i]),
              ),
              if (i < recentTx.length - 1)
                Divider(
                  height: 1,
                  indent: 68,
                  color: AppColors.borderLight,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Clean transaction row with directional icon, description, amount, and date.
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.isCredit;
    final amountColor = isCredit ? AppColors.success : AppColors.error;
    final arrowIcon = isCredit
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;
    final arrowBgColor = isCredit
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.error.withValues(alpha: 0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Directional arrow icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: arrowBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(arrowIcon, size: 20, color: amountColor),
            ),
            const SizedBox(width: 12),
            // Description and date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ??
                        transaction.type.displayName,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.formattedDate}  ${transaction.formattedTime}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Amount
            Text(
              transaction.formattedAmount,
              style: AppTypography.titleSmall.copyWith(
                color: amountColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Commission Breakdown Section
// =============================================================================

class _CommissionBreakdownSection extends StatelessWidget {
  const _CommissionBreakdownSection({required this.breakdown});

  final List<CommissionBreakdown> breakdown;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            for (int i = 0; i < breakdown.length; i++) ...[
              _CommissionRow(item: breakdown[i]),
              if (i < breakdown.length - 1)
                Divider(
                  height: 1,
                  indent: 68,
                  color: AppColors.borderLight,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single commission category row showing category, projects count,
/// percentage, and amount.
class _CommissionRow extends StatelessWidget {
  const _CommissionRow({required this.item});

  final CommissionBreakdown item;

  @override
  Widget build(BuildContext context) {
    final color = item.color ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Category color indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '${item.percentage.toStringAsFixed(0)}%',
                style: AppTypography.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Category name and project count
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.category,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item.projectCount} ${'projects'.tr(context)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            '₹${item.amount.toStringAsFixed(2)}',
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Withdraw Dialog (preserved from original)
// =============================================================================

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        'Request Withdrawal'.tr(context),
        style: AppTypography.titleLarge,
      ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount'.tr(context);
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount'.tr(context);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              decoration: InputDecoration(
                labelText: 'Payment Method'.tr(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
          child: Text('Cancel'.tr(context)),
        ),
        FilledButton(
          onPressed: transactionsState.isWithdrawing ? null : _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: transactionsState.isWithdrawing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Submit'.tr(context)),
        ),
      ],
    );
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);
      final result =
          await ref.read(transactionsProvider.notifier).requestWithdrawal(
                amount: amount,
                paymentMethod: _selectedMethod,
              );

      if (mounted) {
        Navigator.pop(context);
        if (result != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Withdrawal request submitted successfully'.tr(context),
              ),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }
}

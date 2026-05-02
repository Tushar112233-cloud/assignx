/// Modern earnings screen matching the Projects page design language.
///
/// Layout (top to bottom):
/// 1. Gradient hero banner with balance + "Earnings Hub" heading
/// 2. Three stat cards row (Available, This Month, Total Earned)
/// 3. Withdraw CTA card (dark gradient, matching Browse Open Pool style)
/// 4. Filter pill tabs for transaction types
/// 5. Transaction list in glass cards
///
/// Uses [EarningsProvider] backed by [DoerWalletRepository].
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/wallet_model.dart';
import '../../../providers/earnings_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_indicator.dart';

/// Returns responsive horizontal padding based on screen width.
double _responsiveHPadding(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width > 600) return AppSpacing.xl;
  if (width > 400) return AppSpacing.md;
  return AppSpacing.sm;
}

/// Main Earnings screen with wallet balance, stats, and transaction history.
class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earningsState = ref.watch(earningsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: earningsState.isLoading && earningsState.wallet == null
          ? const Center(child: LoadingIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(earningsProvider.notifier).refresh(),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  // 1. Gradient hero banner
                  SliverToBoxAdapter(
                    child: _HeroBanner(
                      balance: earningsState.wallet?.balance ?? 0,
                      totalCredited: earningsState.wallet?.totalCredited ?? 0,
                      totalWithdrawn: earningsState.wallet?.totalWithdrawn ?? 0,
                      transactionCount: earningsState.transactions.length,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),

                  // 2. Stat cards row
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _responsiveHPadding(context),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: LucideIcons.wallet,
                              iconColor: AppColors.primary,
                              label: 'Available'.tr(context),
                              value: _formatCompact(
                                earningsState.wallet?.availableBalance ?? 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _StatCard(
                              icon: LucideIcons.calendar,
                              iconColor: AppColors.accent,
                              label: 'This Month'.tr(context),
                              value: _formatCompact(
                                earningsState.thisMonthEarnings,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: _StatCard(
                              icon: LucideIcons.trendingUp,
                              iconColor: AppColors.success,
                              label: 'Total Earned'.tr(context),
                              value: _formatCompact(
                                earningsState.wallet?.totalCredited ?? 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),

                  // 3. Withdraw CTA card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _responsiveHPadding(context),
                      ),
                      child: _WithdrawCard(
                        availableBalance:
                            earningsState.wallet?.availableBalance ?? 0,
                        onTap: () => _showWithdrawSheet(context, ref),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.lg),
                  ),

                  // 4. Section header + filter pills
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _responsiveHPadding(context),
                      ),
                      child: Text(
                        'Transaction History'.tr(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.sm),
                  ),

                  SliverToBoxAdapter(
                    child: _FilterPills(
                      activeFilter: earningsState.activeFilter,
                      onFilterChanged: (filter) =>
                          ref.read(earningsProvider.notifier).setFilter(filter),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.md),
                  ),

                  // 5. Transaction list
                  _buildTransactionList(context, earningsState),

                  // Bottom clearance for floating nav bar
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              ),
            ),
    );
  }

  /// Builds the transaction list or empty state.
  Widget _buildTransactionList(
    BuildContext context,
    EarningsState earningsState,
  ) {
    final transactions = earningsState.filteredTransactions;

    if (transactions.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.receipt_long,
          title: 'No transactions yet'.tr(context),
          description:
              'Complete projects to start earning'.tr(context),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final txn = transactions[index];
          return _TransactionCard(transaction: txn);
        },
        childCount: transactions.length,
      ),
    );
  }

  /// Shows a bottom sheet for withdrawal.
  void _showWithdrawSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => _WithdrawBottomSheet(
        availableBalance:
            ref.read(earningsProvider).wallet?.availableBalance ?? 0,
      ),
    );
  }

  /// Formats amount in compact form for stat cards.
  static String _formatCompact(double amount) {
    if (amount >= 10000000) {
      return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

// =============================================================================
// Hero Banner
// =============================================================================

/// Gradient hero banner showing the wallet balance prominently.
class _HeroBanner extends StatelessWidget {
  final double balance;
  final double totalCredited;
  final double totalWithdrawn;
  final int transactionCount;

  const _HeroBanner({
    required this.balance,
    required this.totalCredited,
    required this.totalWithdrawn,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        topPadding + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.gradientStart,
            AppColors.gradientMiddle,
            AppColors.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Hub'.tr(context),
            style: TextStyle(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Wallet'.tr(context),
            style: TextStyle(
              fontSize: isCompact ? 22 : 26,
              fontWeight: FontWeight.w800,
              color: Colors.white.withAlpha(180),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Balance display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u20B9',
                style: TextStyle(
                  fontSize: isCompact ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    CurrencyFormatter.formatCompactINR(balance.toInt()),
                    style: TextStyle(
                      fontSize: isCompact ? 34 : 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Current Balance'.tr(context),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withAlpha(160),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Mini stat chips row
          Row(
            children: [
              _HeroStatChip(
                label: 'Credited'.tr(context),
                value: _formatShort(totalCredited),
                color: AppColors.success,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroStatChip(
                label: 'Withdrawn'.tr(context),
                value: _formatShort(totalWithdrawn),
                color: AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.sm),
              _HeroStatChip(
                label: 'Txns'.tr(context),
                value: '$transactionCount',
                color: AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatShort(double amount) {
    if (amount >= 10000000) return '${(amount / 10000000).toStringAsFixed(1)}Cr';
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(0);
  }
}

/// Small stat chip used inside the hero banner.
class _HeroStatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HeroStatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(18),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: Colors.white.withAlpha(20),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(140),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Stat Card
// =============================================================================

/// Stat card inside a GlassContainer, matching the projects page pattern.
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 12,
      opacity: 0.8,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(26),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\u20B9$value',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Withdraw CTA Card
// =============================================================================

/// Dark gradient card prompting the doer to withdraw funds.
class _WithdrawCard extends StatelessWidget {
  final double availableBalance;
  final VoidCallback? onTap;

  const _WithdrawCard({
    required this.availableBalance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final canWithdraw = availableBalance > 0;

    return GestureDetector(
      onTap: canWithdraw ? onTap : null,
      child: AnimatedOpacity(
        opacity: canWithdraw ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientMiddle],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withAlpha(40),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdraw Funds'.tr(context),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      canWithdraw
                          ? 'Transfer earnings to your bank account'.tr(context)
                          : 'No funds available for withdrawal'.tr(context),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withAlpha(200),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(50),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  canWithdraw
                      ? Icons.account_balance_wallet_outlined
                      : LucideIcons.lock,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Filter Pills
// =============================================================================

/// Horizontal scrolling filter pills for transaction types.
class _FilterPills extends StatelessWidget {
  final String? activeFilter;
  final ValueChanged<String?> onFilterChanged;

  const _FilterPills({
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = <_FilterOption>[
      _FilterOption(label: 'All'.tr(context), value: null),
      _FilterOption(label: 'Credits'.tr(context), value: 'credit'),
      _FilterOption(label: 'Debits'.tr(context), value: 'debit'),
      _FilterOption(label: 'Holds'.tr(context), value: 'hold'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: _responsiveHPadding(context),
      ),
      child: Row(
        children: filters.map((filter) {
          final isSelected = activeFilter == filter.value;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onFilterChanged(filter.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withAlpha(40),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  border: isSelected
                      ? null
                      : Border.all(
                          color: AppColors.border.withAlpha(80),
                        ),
                ),
                child: Text(
                  filter.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final String? value;
  const _FilterOption({required this.label, required this.value});
}

// =============================================================================
// Transaction Card
// =============================================================================

/// Glass-morphism transaction card with icon, description, amount, and date.
class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final amountColor = isCredit ? AppColors.success : AppColors.error;
    final amountPrefix = isCredit ? '+' : '-';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _responsiveHPadding(context),
        vertical: AppSpacing.xs + 1,
      ),
      child: GlassCard(
        blur: 10,
        opacity: 0.8,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Transaction type icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getTypeColor(transaction.transactionType).withAlpha(26),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                _getTypeIcon(transaction.transactionType),
                size: 20,
                color: _getTypeColor(transaction.transactionType),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Description + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ??
                        _getTypeLabel(transaction.transactionType),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.status)
                              .withAlpha(26),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          transaction.status.toUpperCase().substring(0, 1) +
                              transaction.status.substring(1),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(transaction.status),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.clock,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        DateFormatter.relativeDate(transaction.createdAt),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix\u20B9${transaction.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTypeLabel(transaction.transactionType),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Returns the icon for a transaction type.
  IconData _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.credit:
        return LucideIcons.arrowDownLeft;
      case TransactionType.debit:
        return LucideIcons.arrowUpRight;
      case TransactionType.hold:
        return LucideIcons.lock;
      case TransactionType.release:
        return LucideIcons.unlock;
    }
  }

  /// Returns the color for a transaction type.
  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.credit:
        return AppColors.success;
      case TransactionType.debit:
        return AppColors.error;
      case TransactionType.hold:
        return AppColors.warning;
      case TransactionType.release:
        return AppColors.info;
    }
  }

  /// Returns a human-readable label for a transaction type.
  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.credit:
        return 'Credit';
      case TransactionType.debit:
        return 'Debit';
      case TransactionType.hold:
        return 'Hold';
      case TransactionType.release:
        return 'Release';
    }
  }

  /// Returns a color for a transaction status string.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'processing':
        return AppColors.info;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }
}

// =============================================================================
// Withdraw Bottom Sheet
// =============================================================================

/// Bottom sheet for initiating a withdrawal.
class _WithdrawBottomSheet extends StatefulWidget {
  final double availableBalance;

  const _WithdrawBottomSheet({required this.availableBalance});

  @override
  State<_WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<_WithdrawBottomSheet> {
  final _amountController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Withdraw Funds'.tr(context),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Available: \u20B9${widget.availableBalance.toStringAsFixed(2)}'
                .tr(context),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Amount input
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            cursorColor: AppColors.primary,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixText: '\u20B9 ',
              prefixStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              hintText: '0.00',
              hintStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary.withAlpha(100),
              ),
              errorText: _errorText,
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            onChanged: (_) {
              if (_errorText != null) {
                setState(() => _errorText = null);
              }
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _handleWithdraw,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                elevation: 0,
              ),
              child: Text(
                'Request Withdrawal'.tr(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }

  void _handleWithdraw() {
    final text = _amountController.text.trim();
    final amount = double.tryParse(text);

    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Enter a valid amount');
      return;
    }
    if (amount > widget.availableBalance) {
      setState(() => _errorText = 'Amount exceeds available balance');
      return;
    }

    // Close sheet - actual withdrawal logic would be called via provider.
    Navigator.of(context).pop(amount);
  }
}

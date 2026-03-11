import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../core/translation/translation_extensions.dart';

/// Payment history screen displaying all financial transactions.
///
/// Shows a comprehensive view of the user's earnings, payments,
/// and transaction history with filtering options.
///
/// ## Navigation
/// - Entry: From [ProfileScreen] via "Payment History" quick action
/// - Back: Returns to [ProfileScreen]
/// - Tap transaction: Shows transaction detail modal (TODO)
///
/// ## Features
/// - Earnings summary card with gradient background
/// - Total earnings, monthly earnings, and pending amounts
/// - Transaction list with type-based icons and colors
/// - Filter sheet for transaction type filtering
/// - Pull-to-refresh functionality
/// - Empty state for new users
///
/// ## Transaction Types
/// - projectPayment: Earnings from completed projects (green)
/// - bonus: Performance bonuses (yellow/warning)
/// - referral: Referral bonuses (blue/info)
/// - withdrawal: Bank withdrawals (red)
///
/// ## Payment Statuses
/// - pending: Awaiting processing (yellow)
/// - processing: Currently being processed (blue)
/// - completed: Successfully completed (green)
/// - failed: Transaction failed (red)
/// - refunded: Refunded transaction (gray)
///
/// ## State Management
/// Uses [ProfileProvider] for payment history data.
///
/// See also:
/// - [ProfileProvider] for payment data
/// - [PaymentTransaction] for transaction model
/// - [CurrencyFormatter] for amount formatting
class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final payments = profileState.paymentHistory;
    final profile = profileState.profile;
    final isLoading = profileState.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LoadingOverlay(
        isLoading: isLoading,
        child: RefreshIndicator(
          onRefresh: () => ref.read(profileProvider.notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppSpacing.paddingMd,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // Summary card in glass container
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: _buildSummaryCard(context, profileState, profile),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Transactions header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions'.tr(context),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showFilterSheet(context),
                      icon: const Icon(Icons.filter_list, size: 18),
                      label: Text('Filter'.tr(context)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Transactions list
                if (payments.isEmpty)
                  _buildEmptyState(context)
                else
                  ...payments.map((payment) => _buildTransactionCard(payment)),

                // Bottom padding for floating nav bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ProfileState state, UserProfile? profile) {
    final thisMonth = state.totalEarningsThisMonth;
    final pending = state.paymentHistory
        .where((p) =>
            p.status == PaymentStatus.pending ||
            p.status == PaymentStatus.processing)
        .fold(0.0, (sum, p) => sum + p.amount);

    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final titleFontSize = isCompact ? 12.0 : 14.0;
    final earningsFontSize = isCompact ? 26.0 : 32.0;

    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Container(
        width: double.infinity,
        padding: AppSpacing.paddingMd,
        decoration: BoxDecoration(
          borderRadius: AppSpacing.borderRadiusMd,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.accent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Earnings'.tr(context),
              style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.formatCompactINR(profile?.totalEarnings ?? 0),
                style: TextStyle(
                  fontSize: earningsFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'This Month',
                    CurrencyFormatter.formatCompactINR(thisMonth.toInt()),
                    Icons.calendar_today,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white24,
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Pending',
                    CurrencyFormatter.formatCompactINR(pending.toInt()),
                    Icons.hourglass_empty,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(PaymentTransaction payment) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      onTap: () => _showTransactionDetail(payment),
      padding: AppSpacing.paddingMd,
      child: Row(
            children: [
              // Type icon
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _getTypeColor(payment.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getTypeIcon(payment.type),
                  size: 22,
                  color: _getTypeColor(payment.type),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.projectTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusBadge(payment.status),
                        const SizedBox(width: 8),
                        Text(
                          DateFormatter.relativeDate(payment.createdAt),
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

              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${payment.type == PaymentType.withdrawal ? '-' : '+'}₹${payment.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: payment.type == PaymentType.withdrawal
                          ? AppColors.error
                          : AppColors.success,
                    ),
                  ),
                  Text(
                    payment.type.displayName,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No transactions yet'.tr(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Complete projects to start earning'.tr(context),
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.projectPayment:
        return AppColors.success;
      case PaymentType.bonus:
        return AppColors.warning;
      case PaymentType.referral:
        return AppColors.info;
      case PaymentType.withdrawal:
        return AppColors.error;
    }
  }

  IconData _getTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.projectPayment:
        return Icons.assignment;
      case PaymentType.bonus:
        return Icons.stars;
      case PaymentType.referral:
        return Icons.people;
      case PaymentType.withdrawal:
        return Icons.account_balance;
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return AppColors.warning;
      case PaymentStatus.processing:
        return AppColors.info;
      case PaymentStatus.completed:
        return AppColors.success;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.textSecondary;
    }
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: AppSpacing.paddingMd,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Filter Transactions'.tr(context),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFilterOption('All Transactions', true),
            _buildFilterOption('Project Payments', false),
            _buildFilterOption('Bonuses', false),
            _buildFilterOption('Referrals', false),
            _buildFilterOption('Withdrawals', false),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String label, bool isSelected) {
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      onTap: () {
        // TODO: Apply filter
      },
    );
  }

  void _showTransactionDetail(PaymentTransaction payment) {
    // TODO: Show transaction detail modal
  }
}

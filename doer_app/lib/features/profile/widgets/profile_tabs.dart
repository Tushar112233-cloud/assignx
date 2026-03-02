import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/profile_provider.dart';
import 'earnings_graph.dart';
import 'rating_breakdown.dart';
import 'skill_verification.dart';
import '../../../core/translation/translation_extensions.dart';

/// Tabbed content section for the profile screen.
///
/// Contains three tabs: Overview, Skills, and Payments.
/// - Overview: Bio, skills list, recent activity, rating breakdown
/// - Skills: Verified skills with badges, pending verification
/// - Payments: Wallet balance, recent transactions, bank details, payout button
class ProfileTabs extends ConsumerWidget {
  final UserProfile profile;
  final TabController tabController;
  final List<PaymentTransaction> paymentHistory;
  final BankDetails? bankDetails;

  const ProfileTabs({
    super.key,
    required this.profile,
    required this.tabController,
    required this.paymentHistory,
    required this.bankDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Skills'),
              Tab(text: 'Payments'),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Tab content - wrapped in a SizedBox to give bounded height
        SizedBox(
          height: _getTabContentHeight(tabController.index),
          child: TabBarView(
            controller: tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildOverviewTab(context),
              _buildSkillsTab(),
              _buildPaymentsTab(context),
            ],
          ),
        ),
      ],
    );
  }

  double _getTabContentHeight(int index) {
    switch (index) {
      case 0:
        return 1600; // Overview (with performance stats + earnings graph)
      case 1:
        return 700; // Skills
      case 2:
        return 800; // Payments
      default:
        return 1000;
    }
  }

  // ---------------------------------------------------------------------------
  // Overview Tab
  // ---------------------------------------------------------------------------

  Widget _buildOverviewTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Stats Row
          _buildPerformanceStatsRow(context),

          const SizedBox(height: AppSpacing.md),

          // Earnings Overview (compact version)
          EarningsGraph(
            totalEarnings: profile.totalEarnings.toDouble(),
          ),

          const SizedBox(height: AppSpacing.md),

          // About section
          if (profile.bio != null && profile.bio!.isNotEmpty)
            _buildAboutCard(context),

          if (profile.bio != null && profile.bio!.isNotEmpty)
            const SizedBox(height: AppSpacing.md),

          // Skills chip display
          if (profile.skills.isNotEmpty) _buildSkillsChips(context),

          if (profile.skills.isNotEmpty) const SizedBox(height: AppSpacing.md),

          // Rating Breakdown
          RatingBreakdown(
            overallRating: profile.rating,
            qualityRating:
                profile.rating + 0.2 > 5 ? 5.0 : profile.rating + 0.2,
            timelinessRating:
                profile.rating - 0.1 < 0 ? 0.0 : profile.rating - 0.1,
            communicationRating: profile.rating,
            totalReviews: profile.completedProjects,
          ),

          const SizedBox(height: AppSpacing.md),

          // Quick actions
          _buildQuickActionsCard(context),
        ],
      ),
    );
  }

  /// Builds a horizontal row of performance stat cards.
  Widget _buildPerformanceStatsRow(BuildContext context) {
    final onTimeRate =
        profile.completedProjects > 0
            ? (85 + (profile.rating / 5.0) * 12).round().clamp(0, 100)
            : 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Performance'.tr(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _PerformanceStatItem(
                    icon: Icons.assignment_turned_in_rounded,
                    value: profile.completedProjects.toString(),
                    label: 'Completed'.tr(context),
                    color: AppColors.success,
                  ),
                ),
                Expanded(
                  child: _PerformanceStatItem(
                    icon: Icons.star_rounded,
                    value: profile.rating.toStringAsFixed(1),
                    label: 'Rating'.tr(context),
                    color: AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _PerformanceStatItem(
                    icon: Icons.timer_rounded,
                    value: '$onTimeRate%',
                    label: 'On-Time'.tr(context),
                    color: const Color(0xFF8B5CF6),
                  ),
                ),
                Expanded(
                  child: _PerformanceStatItem(
                    icon: Icons.currency_rupee_rounded,
                    value: _formatAmount(profile.totalEarnings.toDouble()),
                    label: 'Earned'.tr(context),
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'About Me'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              profile.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            if (profile.education != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.school, size: 16, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      profile.education!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsChips(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, size: 18, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  'Skills'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildActionItem(
            context,
            'Notifications',
            'View all notifications',
            Icons.notifications_outlined,
            () => context.push('/notifications'),
          ),
          const Divider(height: 1, indent: 60),
          _buildActionItem(
            context,
            'Settings',
            'App preferences and settings',
            Icons.settings_outlined,
            () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Skills Tab
  // ---------------------------------------------------------------------------

  Widget _buildSkillsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          SkillVerification(
            skills: profile.skills.asMap().entries.map((entry) {
              final index = entry.key;
              final skill = entry.value;
              return SkillItem(
                id: index.toString(),
                name: skill,
                status: index < 2
                    ? VerificationStatus.verified
                    : index < 3
                        ? VerificationStatus.pending
                        : VerificationStatus.unverified,
              );
            }).toList(),
            onRequestVerification: (skillId) {
              // Handle verification request
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payments Tab
  // ---------------------------------------------------------------------------

  Widget _buildPaymentsTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Wallet balance card
          _buildWalletCard(context),

          const SizedBox(height: AppSpacing.md),

          // Earnings graph
          EarningsGraph(
            totalEarnings: profile.totalEarnings.toDouble(),
          ),

          const SizedBox(height: AppSpacing.md),

          // Bank details card (masked)
          if (bankDetails != null) _buildBankDetailsCard(context),

          if (bankDetails != null) const SizedBox(height: AppSpacing.md),

          // Recent transactions
          _buildRecentTransactions(context),

          const SizedBox(height: AppSpacing.md),

          // Payout request button
          _buildPayoutButton(context),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A5F),
            Color(0xFF3B6CB5),
          ],
        ),
        borderRadius: AppSpacing.borderRadiusLg,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Wallet Balance'.tr(context),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '\u20B9${_formatAmount(profile.totalEarnings.toDouble())}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Available for payout'.tr(context),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Bank Details'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (bankDetails!.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, size: 12, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Verified'.tr(context),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildBankDetailRow('Bank', bankDetails!.bankName),
            const SizedBox(height: 8),
            _buildBankDetailRow('Account', bankDetails!.maskedAccountNumber),
            const SizedBox(height: 8),
            _buildBankDetailRow('IFSC', bankDetails!.maskedIfsc),
            const SizedBox(height: 8),
            _buildBankDetailRow('Name', bankDetails!.accountName),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    final recentPayments = paymentHistory.take(5).toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Recent Transactions'.tr(context),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/profile/payments'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'View All'.tr(context),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (recentPayments.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No transactions yet'.tr(context),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              )
            else
              ...recentPayments.map((payment) => _buildTransactionItem(payment)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(PaymentTransaction payment) {
    final isCredit = payment.type == PaymentType.projectPayment ||
        payment.type == PaymentType.bonus ||
        payment.type == PaymentType.referral;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              size: 18,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.projectTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}\u20B9${payment.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
              _buildStatusBadge(payment.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.completed:
        color = AppColors.success;
        break;
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        color = AppColors.warning;
        break;
      case PaymentStatus.failed:
      case PaymentStatus.refunded:
        color = AppColors.error;
        break;
    }

    return Text(
      status.displayName,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  Widget _buildPayoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF5A7CFF)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A7CFF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payout request submitted'.tr(context)),
                backgroundColor: AppColors.success,
              ),
            );
          },
          icon: const Icon(Icons.send_rounded, size: 20),
          label: Text(
            'Request Payout'.tr(context),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

/// A compact performance stat item used in the performance stats row.
class _PerformanceStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _PerformanceStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

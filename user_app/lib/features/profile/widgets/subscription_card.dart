import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/profile_provider.dart';
import 'account_upgrade_card.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

/// Colors used in the subscription card.
class _SubscriptionColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const checkIconColor = Color(0xFF22C55E);
  static const renewalBg = Color(0xFFF5F5F5);
}

// ============================================================
// SUBSCRIPTION PLAN MODEL
// ============================================================

/// Model for subscription plan details.
class SubscriptionPlan {
  /// The account type associated with this plan.
  final AccountType accountType;

  /// The renewal date (if applicable).
  final DateTime? renewalDate;

  /// Whether the subscription is active.
  final bool isActive;

  const SubscriptionPlan({
    required this.accountType,
    this.renewalDate,
    this.isActive = true,
  });

  /// Get features list based on account type.
  List<String> get features {
    switch (accountType) {
      case AccountType.student:
        return [
          '5 projects per month',
          'Standard support (24-48h response)',
          'Student discounts on all services',
          'Basic revision rounds',
          'Access to student resources',
        ];
      case AccountType.professional:
        return [
          'Unlimited projects',
          'Priority support (4-12h response)',
          'Extended revision period',
          'Advanced formatting options',
          'Dedicated project manager',
        ];
      case AccountType.businessOwner:
        return [
          'Unlimited projects',
          'VIP support (1-4h response)',
          'Up to 10 team members',
          'Dedicated account manager',
          'Custom integrations',
          'Bulk project discounts',
        ];
    }
  }

  /// Get the plan price label.
  String get priceLabel {
    switch (accountType) {
      case AccountType.student:
        return 'Free';
      case AccountType.professional:
        return 'Rs. 499/month';
      case AccountType.businessOwner:
        return 'Rs. 1,999/month';
    }
  }
}

// ============================================================
// SUBSCRIPTION CARD WIDGET
// ============================================================

/// A card widget that displays the user's current subscription plan.
///
/// Shows:
/// - Current plan name and badge
/// - Plan features list
/// - Renewal date (if applicable)
/// - Upgrade button (if not on highest tier)
///
/// Example usage:
/// ```dart
/// SubscriptionCard()
/// ```
class SubscriptionCard extends ConsumerWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return profileAsync.when(
      data: (profile) {
        // Convert UserType to AccountType (map professional to professional, else student)
        final accountType = profile.userType?.toDbString() == 'professional'
            ? AccountType.professional
            : AccountType.student;
        final plan = SubscriptionPlan(
          accountType: accountType,
          // For demo purposes, set renewal date 30 days from now for paid plans
          renewalDate: accountType != AccountType.student
              ? DateTime.now().add(const Duration(days: 30))
              : null,
        );

        return _buildSubscriptionCard(context, plan);
      },
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildSubscriptionCard(
        context,
        const SubscriptionPlan(accountType: AccountType.student),
      ),
    );
  }

  /// Builds the main subscription card.
  Widget _buildSubscriptionCard(BuildContext context, SubscriptionPlan plan) {
    final canUpgrade = plan.accountType.canUpgradeTo.isNotEmpty;
    final nextTier = canUpgrade ? plan.accountType.canUpgradeTo.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _SubscriptionColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with plan info
          _buildPlanHeader(plan),

          // Features list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan Features',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _SubscriptionColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 10),
                ...plan.features.map((feature) => _buildFeatureItem(feature)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Renewal date (if applicable)
          if (plan.renewalDate != null) _buildRenewalSection(plan.renewalDate!),

          // Upgrade section or premium badge
          if (canUpgrade && nextTier != null) ...[
            _buildUpgradeSection(context, plan.accountType, nextTier),
          ] else ...[
            _buildPremiumBadge(),
          ],
        ],
      ),
    );
  }

  /// Builds the plan header with icon and badge.
  Widget _buildPlanHeader(SubscriptionPlan plan) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            plan.accountType.backgroundColor,
            plan.accountType.backgroundColor.withAlpha(180),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Plan icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: plan.accountType.color.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              plan.accountType.icon,
              size: 26,
              color: plan.accountType.color,
            ),
          ),
          const SizedBox(width: 14),

          // Plan info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${plan.accountType.displayName} Plan',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _SubscriptionColors.primaryText,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Active badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: plan.accountType.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: plan.accountType.color.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: plan.accountType.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.priceLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 14,
                    color: _SubscriptionColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single feature item.
  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: _SubscriptionColors.checkIconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14,
                color: _SubscriptionColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the renewal date section.
  Widget _buildRenewalSection(DateTime renewalDate) {
    final formattedDate = DateFormat('MMMM d, yyyy').format(renewalDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _SubscriptionColors.renewalBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: _SubscriptionColors.mutedText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Renewal',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: _SubscriptionColors.mutedText,
                  ),
                ),
                Text(
                  formattedDate,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _SubscriptionColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle manage subscription
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: Text(
              'Manage',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the upgrade section.
  Widget _buildUpgradeSection(
    BuildContext context,
    AccountType currentType,
    AccountType nextTier,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            nextTier.backgroundColor,
            nextTier.backgroundColor.withAlpha(180),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: nextTier.color.withAlpha(50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                size: 18,
                color: nextTier.color,
              ),
              const SizedBox(width: 8),
              Text(
                'Upgrade to ${nextTier.displayName}',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _SubscriptionColors.primaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Unlock ${nextTier.benefits.first.toLowerCase()} and more premium features',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: _SubscriptionColors.secondaryText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/profile/upgrade?type=${currentType.toDbString()}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: nextTier.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Upgrade Now',
                    style: AppTextStyles.buttonMedium.copyWith(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the premium member badge for highest tier.
  Widget _buildPremiumBadge() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFA7F3D0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            size: 22,
            color: AppColors.success,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Member',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have the highest account tier',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: const Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a loading placeholder card.
  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 280,
      decoration: BoxDecoration(
        color: _SubscriptionColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

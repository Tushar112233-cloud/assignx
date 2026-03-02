import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/profile_provider.dart';
import 'account_upgrade_card.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

/// Colors used in the account role card.
class _RoleCardColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const checkIconColor = Color(0xFF22C55E);
}

// ============================================================
// ACCOUNT ROLE MODEL
// ============================================================

/// Model for the user's account role and its perks.
class AccountRole {
  /// The account type (role) of the user.
  final AccountType accountType;

  /// Whether the role is active.
  final bool isActive;

  const AccountRole({
    required this.accountType,
    this.isActive = true,
  });

  /// Get perks list based on account role.
  List<String> get perks {
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
}

// ============================================================
// SUBSCRIPTION CARD WIDGET (now shows Account Role)
// ============================================================

/// A card widget that displays the user's current account role.
///
/// Shows:
/// - Current role name and badge (Student / Professional / Business)
/// - Role perks list
/// - Switch account type button (if not on highest tier)
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
        final accountType = profile.userType?.toDbString() == 'professional'
            ? AccountType.professional
            : AccountType.student;
        final role = AccountRole(accountType: accountType);

        return _buildRoleCard(context, role);
      },
      loading: () => _buildLoadingCard(),
      error: (_, __) => _buildRoleCard(
        context,
        const AccountRole(accountType: AccountType.student),
      ),
    );
  }

  /// Builds the main account role card.
  Widget _buildRoleCard(BuildContext context, AccountRole role) {
    final canUpgrade = role.accountType.canUpgradeTo.isNotEmpty;
    final nextTier = canUpgrade ? role.accountType.canUpgradeTo.first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: _RoleCardColors.cardBackground,
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
          // Header with role info
          _buildRoleHeader(role),

          // Perks list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Perks',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _RoleCardColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 10),
                ...role.perks.map((perk) => _buildPerkItem(perk)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Switch role section or top-tier badge
          if (canUpgrade && nextTier != null) ...[
            _buildSwitchRoleSection(context, role.accountType, nextTier),
          ] else ...[
            _buildTopTierBadge(),
          ],
        ],
      ),
    );
  }

  /// Builds the role header with icon and badge.
  Widget _buildRoleHeader(AccountRole role) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            role.accountType.backgroundColor,
            role.accountType.backgroundColor.withAlpha(180),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Role icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: role.accountType.color.withAlpha(30),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              role.accountType.icon,
              size: 26,
              color: role.accountType.color,
            ),
          ),
          const SizedBox(width: 14),

          // Role info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${role.accountType.displayName} Account',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _RoleCardColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                        color: role.accountType.color.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: role.accountType.color.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        'Active',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: role.accountType.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  role.accountType.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: _RoleCardColors.secondaryText,
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

  /// Builds a single perk item.
  Widget _buildPerkItem(String perk) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: _RoleCardColors.checkIconColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              perk,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 14,
                color: _RoleCardColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the switch account type section.
  Widget _buildSwitchRoleSection(
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
              Flexible(
                child: Text(
                  'Switch to ${nextTier.displayName}',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _RoleCardColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Unlock ${nextTier.benefits.first.toLowerCase()} and more features',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: _RoleCardColors.secondaryText,
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
                    'Switch Account Type',
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

  /// Builds the top-tier badge for highest role.
  Widget _buildTopTierBadge() {
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
                  'Top Tier Account',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have the highest account role',
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
        color: _RoleCardColors.cardBackground,
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

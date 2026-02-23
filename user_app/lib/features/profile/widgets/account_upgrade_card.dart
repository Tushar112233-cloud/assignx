import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Account types for upgrade system.
enum AccountType {
  student,
  professional,
  businessOwner;

  /// Convert to database string format.
  String toDbString() {
    switch (this) {
      case AccountType.student:
        return 'student';
      case AccountType.professional:
        return 'professional';
      case AccountType.businessOwner:
        return 'business_owner';
    }
  }

  /// Parse from database string format.
  static AccountType fromDbString(String value) {
    switch (value.toLowerCase()) {
      case 'professional':
        return AccountType.professional;
      case 'business_owner':
        return AccountType.businessOwner;
      default:
        return AccountType.student;
    }
  }

  /// Get display name for the account type.
  String get displayName {
    switch (this) {
      case AccountType.student:
        return 'Student';
      case AccountType.professional:
        return 'Professional';
      case AccountType.businessOwner:
        return 'Business';
    }
  }

  /// Get description for the account type.
  String get description {
    switch (this) {
      case AccountType.student:
        return 'Perfect for students working on academic projects';
      case AccountType.professional:
        return 'For working professionals and graduates';
      case AccountType.businessOwner:
        return 'For businesses and teams';
    }
  }

  /// Get icon for the account type.
  IconData get icon {
    switch (this) {
      case AccountType.student:
        return Icons.school_outlined;
      case AccountType.professional:
        return Icons.work_outline;
      case AccountType.businessOwner:
        return Icons.business_outlined;
    }
  }

  /// Get color for the account type.
  Color get color {
    switch (this) {
      case AccountType.student:
        return const Color(0xFF1D4ED8); // blue
      case AccountType.professional:
        return const Color(0xFF7C3AED); // purple
      case AccountType.businessOwner:
        return const Color(0xFFB45309); // amber
    }
  }

  /// Get background color for the account type.
  Color get backgroundColor {
    switch (this) {
      case AccountType.student:
        return const Color(0xFFDBEAFE); // blue-100
      case AccountType.professional:
        return const Color(0xFFF3E8FF); // purple-100
      case AccountType.businessOwner:
        return const Color(0xFFFEF3C7); // amber-100
    }
  }

  /// Get available upgrade paths.
  List<AccountType> get canUpgradeTo {
    switch (this) {
      case AccountType.student:
        return [AccountType.professional];
      case AccountType.professional:
        return [AccountType.businessOwner];
      case AccountType.businessOwner:
        return [];
    }
  }

  /// Get key benefits for the account type.
  List<String> get benefits {
    switch (this) {
      case AccountType.student:
        return [
          '5 projects per month',
          'Standard support',
          'Student discounts',
        ];
      case AccountType.professional:
        return [
          'Unlimited projects',
          'Priority support',
          'Extended revision period',
        ];
      case AccountType.businessOwner:
        return [
          'Unlimited projects',
          'Up to 10 team members',
          'Dedicated account manager',
        ];
    }
  }
}

/// Colors used in account upgrade card.
class _UpgradeCardColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const upgradeBanner = Color(0xFFFFF7ED);
  static const upgradeBannerBorder = Color(0xFFFED7AA);
}

/// Account upgrade card widget for the profile screen.
///
/// Displays the current account tier and provides an upgrade CTA button
/// with a preview of benefits.
///
/// Example usage:
/// ```dart
/// AccountUpgradeCard(
///   currentType: AccountType.student,
///   onUpgradeTap: () => context.push('/profile/upgrade'),
/// )
/// ```
class AccountUpgradeCard extends StatelessWidget {
  /// The current account type of the user.
  final AccountType currentType;

  /// Callback when upgrade button is tapped.
  final VoidCallback? onUpgradeTap;

  /// Whether the account is verified.
  final bool isVerified;

  const AccountUpgradeCard({
    super.key,
    required this.currentType,
    this.onUpgradeTap,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final canUpgrade = currentType.canUpgradeTo.isNotEmpty;
    final nextTier = canUpgrade ? currentType.canUpgradeTo.first : null;

    return Container(
      decoration: BoxDecoration(
        color: _UpgradeCardColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with current tier
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Account icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: currentType.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    currentType.icon,
                    size: 24,
                    color: currentType.color,
                  ),
                ),
                const SizedBox(width: 14),
                // Account info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${currentType.displayName} Account',
                            style: AppTextStyles.headingSmall.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _UpgradeCardColors.primaryText,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentType.description,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _UpgradeCardColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: _UpgradeCardColors.mutedText,
                  size: 20,
                ),
              ],
            ),
          ),

          // Current benefits preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: currentType.benefits.map((benefit) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          benefit,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13,
                            color: _UpgradeCardColors.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Upgrade banner
          if (canUpgrade && nextTier != null) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _UpgradeCardColors.upgradeBanner,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _UpgradeCardColors.upgradeBannerBorder,
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
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upgrade to ${nextTier.displayName}',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: _UpgradeCardColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock ${nextTier.benefits.first.toLowerCase()} and more premium features',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 13,
                      color: _UpgradeCardColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onUpgradeTap,
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
            ),
          ] else ...[
            // Premium badge for highest tier
            Container(
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
                    size: 20,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 10),
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
            ),
          ],
        ],
      ),
    );
  }
}

/// Compact account upgrade banner for settings screen.
///
/// Shows a smaller upgrade prompt that fits well in settings lists.
class CompactUpgradeBanner extends StatelessWidget {
  /// The current account type of the user.
  final AccountType currentType;

  /// Callback when upgrade button is tapped.
  final VoidCallback? onUpgradeTap;

  const CompactUpgradeBanner({
    super.key,
    required this.currentType,
    this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    final canUpgrade = currentType.canUpgradeTo.isNotEmpty;
    final nextTier = canUpgrade ? currentType.canUpgradeTo.first : null;

    if (!canUpgrade || nextTier == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onUpgradeTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              nextTier.backgroundColor,
              nextTier.backgroundColor.withAlpha(200),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: nextTier.color.withAlpha(50),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                nextTier.icon,
                size: 22,
                color: nextTier.color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upgrade to ${nextTier.displayName}',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _UpgradeCardColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Unlock more features',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: _UpgradeCardColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: nextTier.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Upgrade',
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

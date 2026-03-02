import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';

/// Explore More section for the dashboard.
///
/// Provides quick access to features that are available in the web app's
/// sidebar/dock navigation but not in the mobile bottom nav bar.
/// This ensures feature parity between web and mobile platforms.
///
/// Items:
/// - Marketplace (buy/sell items, housing, opportunities)
/// - Connect (tutors, resources, study groups, Q&A)
/// - Pro Network (professional networking - via ConnectHub)
/// - Business Hub (business networking - via ConnectHub)
class ExploreMoreSection extends StatelessWidget {
  final VoidCallback? onMarketplace;
  final VoidCallback? onConnect;
  final VoidCallback? onProNetwork;
  final VoidCallback? onBusinessHub;

  const ExploreMoreSection({
    super.key,
    this.onMarketplace,
    this.onConnect,
    this.onProNetwork,
    this.onBusinessHub,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.explore_outlined,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore More'.tr(context),
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Discover all platform features'.tr(context),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal scrollable chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _ExploreChip(
                  icon: LucideIcons.shoppingBag,
                  label: 'Marketplace'.tr(context),
                  color: const Color(0xFFE11D48), // Rose
                  onTap: onMarketplace,
                ),
                const SizedBox(width: 10),
                _ExploreChip(
                  icon: LucideIcons.bookOpen,
                  label: 'Connect'.tr(context),
                  color: const Color(0xFF7C3AED), // Violet
                  onTap: onConnect,
                ),
                const SizedBox(width: 10),
                _ExploreChip(
                  icon: LucideIcons.briefcase,
                  label: 'Pro Network'.tr(context),
                  color: const Color(0xFF2563EB), // Blue
                  onTap: onProNetwork,
                ),
                const SizedBox(width: 10),
                _ExploreChip(
                  icon: LucideIcons.building2,
                  label: 'Business Hub'.tr(context),
                  color: const Color(0xFF059669), // Emerald
                  onTap: onBusinessHub,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual explore chip with icon, label, and color accent.
class _ExploreChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ExploreChip({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

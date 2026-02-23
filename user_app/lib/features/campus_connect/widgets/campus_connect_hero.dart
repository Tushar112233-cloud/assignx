import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Production-grade hero section for Campus Connect.
///
/// Inspired by the dashboard greeting section - clean, minimal, professional.
/// Features a greeting-style header with animated illustration.
class CampusConnectHero extends StatelessWidget {
  /// Optional user name for personalized greeting.
  final String? userName;

  /// Whether to show animation (can be disabled for performance).
  final bool showAnimation;

  const CampusConnectHero({
    super.key,
    this.userName,
    this.showAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main title
                Text(
                  'Campus Connect',
                  style: AppTextStyles.displayMedium.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                Text(
                  'Discover events, housing, resources & more',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Quick action chips
                _QuickActionChips(),
              ],
            ),
          ),

          // Right: Animated illustration
          if (showAnimation) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset(
                'assets/animations/computer.json',
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback icon if Lottie fails
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick action chips for common campus connect actions.
class _QuickActionChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionChip(
          icon: Icons.add_circle_outline,
          label: 'Post',
          onTap: () {
            // Navigate to create post
          },
        ),
        _ActionChip(
          icon: Icons.bookmark_outline,
          label: 'Saved',
          onTap: () {
            // Navigate to saved
          },
        ),
      ],
    );
  }
}

/// Individual action chip widget.
class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header bar for Campus Connect - DEPRECATED, use DashboardAppBar instead.
/// Kept for backward compatibility but should not be used.
class CampusConnectHeader extends StatelessWidget implements PreferredSizeWidget {
  final double walletBalance;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onWalletTap;

  const CampusConnectHeader({
    super.key,
    this.walletBalance = 10100,
    this.onNotificationTap,
    this.onWalletTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    // Return empty container - use DashboardAppBar instead
    return const SizedBox.shrink();
  }
}

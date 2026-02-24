library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Production-grade hero section for Business Hub.
///
/// Inspired by the dashboard greeting section - clean, minimal, professional.
/// Features a greeting-style header with animated illustration.
class CampusConnectHero extends StatelessWidget {
  /// Optional user name for personalized greeting.
  final String? userName;

  /// Whether to show animation (can be disabled for performance).
  final bool showAnimation;

  /// Callback when "Post" quick action is tapped.
  final VoidCallback? onCreatePost;

  /// Callback when "Saved" quick action is tapped.
  final VoidCallback? onViewSaved;

  const CampusConnectHero({
    super.key,
    this.userName,
    this.showAnimation = true,
    this.onCreatePost,
    this.onViewSaved,
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
                  'Business Hub',
                  style: AppTypography.displayMedium.copyWith(
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
                  'Industry insights, recruitment, business opportunities',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // Quick action chips
                _QuickActionChips(
                  onCreatePost: onCreatePost,
                  onViewSaved: onViewSaved,
                ),
              ],
            ),
          ),

          // Right: Illustration
          if (showAnimation) ...[
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              height: 80,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick action chips for common business hub actions.
class _QuickActionChips extends StatelessWidget {
  final VoidCallback? onCreatePost;
  final VoidCallback? onViewSaved;

  const _QuickActionChips({
    this.onCreatePost,
    this.onViewSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ActionChip(
          icon: Icons.add_circle_outline,
          label: 'Post',
          onTap: onCreatePost ?? () {},
        ),
        _ActionChip(
          icon: Icons.bookmark_outline,
          label: 'Saved',
          onTap: onViewSaved ?? () {},
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
      color: AppColors.primary.withAlpha(20),
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
                style: AppTypography.labelMedium.copyWith(
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

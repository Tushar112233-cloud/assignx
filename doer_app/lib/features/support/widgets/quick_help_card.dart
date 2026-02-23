/// Quick help card widget for the support screen.
///
/// Displays a compact card with an icon, title, and description
/// representing a help topic category.
///
/// ## Usage
/// ```dart
/// QuickHelpCard(
///   icon: Icons.task_alt,
///   title: 'Accepting Tasks',
///   description: 'Learn how to find and accept tasks',
///   color: AppColors.accent,
///   onTap: () => scrollToFaq('tasks'),
/// )
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// A compact card widget representing a quick help category.
///
/// Provides a visual entry point to help topics with icon,
/// title, and brief description.
class QuickHelpCard extends StatelessWidget {
  /// Creates a quick help card with the specified properties.
  const QuickHelpCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.onTap,
  });

  /// The icon to display in the colored container.
  final IconData icon;

  /// The title of the help topic.
  final String title;

  /// A brief description of the help topic.
  final String description;

  /// The theme color for the icon background.
  final Color color;

  /// Callback invoked when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

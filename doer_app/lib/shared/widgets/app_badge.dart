/// A collection of badge widgets for displaying status and labels.
///
/// This file provides reusable badge components for showing status
/// indicators, urgency levels, and categorical labels.
///
/// ## Features
/// - Multiple color variants (primary, success, warning, error, info, neutral)
/// - Optional icon support
/// - Small and regular size options
/// - Specialized badges for urgency and status
///
/// ## Example
/// ```dart
/// AppBadge(
///   text: 'Active',
///   variant: BadgeVariant.success,
///   icon: Icons.check_circle,
/// )
/// ```
///
/// See also:
/// - [UrgencyBadge] for time-based urgency indicators
/// - [StatusBadge] for project/task status display
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// Available badge color variants.
///
/// Each variant provides appropriate background and text colors:
/// - [primary]: Primary brand color
/// - [success]: Green for positive states
/// - [warning]: Yellow/orange for caution states
/// - [error]: Red for negative states
/// - [info]: Blue for informational states
/// - [neutral]: Gray for default/inactive states
enum BadgeVariant { primary, success, warning, error, info, neutral }

/// A customizable badge widget for displaying labels and status.
///
/// Provides consistent badge styling with multiple color variants
/// and optional icon support.
///
/// ## Usage
/// ```dart
/// AppBadge(
///   text: 'Active',
///   variant: BadgeVariant.success,
///   icon: Icons.check_circle,
/// )
/// ```
///
/// ## Size Options
/// Set [isSmall] to true for a more compact badge.
///
/// See also:
/// - [BadgeVariant] for available color variants
/// - [UrgencyBadge] for deadline-based badges
/// - [StatusBadge] for project status badges
class AppBadge extends StatelessWidget {
  /// Creates a badge with the specified properties.
  ///
  /// The [text] parameter is required.
  const AppBadge({
    super.key,
    required this.text,
    this.variant = BadgeVariant.primary,
    this.icon,
    this.isSmall = false,
  });

  /// The text label to display.
  final String text;

  /// The color variant of the badge.
  ///
  /// Defaults to [BadgeVariant.primary].
  final BadgeVariant variant;

  /// Optional icon displayed before the text.
  final IconData? icon;

  /// Whether to use a smaller, more compact size.
  ///
  /// Defaults to false.
  final bool isSmall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.xs : AppSpacing.sm,
        vertical: isSmall ? AppSpacing.xxs : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: isSmall ? 10 : 12,
              color: _getTextColor(),
            ),
            SizedBox(width: isSmall ? 2 : 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the background color for the current variant.
  Color _getBackgroundColor() {
    switch (variant) {
      case BadgeVariant.primary:
        return AppColors.primary.withValues(alpha: 0.1);
      case BadgeVariant.success:
        return AppColors.successLight;
      case BadgeVariant.warning:
        return AppColors.warningLight;
      case BadgeVariant.error:
        return AppColors.errorLight;
      case BadgeVariant.info:
        return AppColors.infoLight;
      case BadgeVariant.neutral:
        return AppColors.surfaceVariant;
    }
  }

  /// Returns the text color for the current variant.
  Color _getTextColor() {
    switch (variant) {
      case BadgeVariant.primary:
        return AppColors.primary;
      case BadgeVariant.success:
        return AppColors.success;
      case BadgeVariant.warning:
        return AppColors.warning;
      case BadgeVariant.error:
        return AppColors.error;
      case BadgeVariant.info:
        return AppColors.info;
      case BadgeVariant.neutral:
        return AppColors.textSecondary;
    }
  }
}

/// An urgency badge widget that displays time-based status.
///
/// Automatically determines the appropriate color and message
/// based on the hours remaining until a deadline.
///
/// ## Usage
/// ```dart
/// UrgencyBadge(hoursLeft: 5)  // Shows "Urgent" in red
/// UrgencyBadge(hoursLeft: 12) // Shows "12h left" in yellow
/// UrgencyBadge(hoursLeft: 48) // Shows "2d left" in green
/// ```
///
/// ## Display Logic
/// - <= 0 hours: "Overdue" (error)
/// - <= 6 hours: "Urgent" with fire icon (error)
/// - <= 24 hours: "Xh left" (warning)
/// - > 24 hours: "Xd left" (success)
///
/// See also:
/// - [AppBadge] for general purpose badges
class UrgencyBadge extends StatelessWidget {
  /// Creates an urgency badge for the given time remaining.
  const UrgencyBadge({
    super.key,
    required this.hoursLeft,
  });

  /// The number of hours remaining until the deadline.
  ///
  /// Negative values indicate an overdue state.
  final int hoursLeft;

  @override
  Widget build(BuildContext context) {
    if (hoursLeft <= 0) {
      return const AppBadge(
        text: 'Overdue',
        variant: BadgeVariant.error,
        icon: Icons.warning,
      );
    }

    if (hoursLeft <= 6) {
      return const AppBadge(
        text: 'Urgent',
        variant: BadgeVariant.error,
        icon: Icons.local_fire_department,
      );
    }

    if (hoursLeft <= 24) {
      return AppBadge(
        text: '${hoursLeft}h left',
        variant: BadgeVariant.warning,
        icon: Icons.schedule,
      );
    }

    final days = (hoursLeft / 24).floor();
    return AppBadge(
      text: '${days}d left',
      variant: BadgeVariant.success,
      icon: Icons.schedule,
    );
  }
}

/// A status badge widget for displaying project or task status.
///
/// Automatically maps common status strings to appropriate colors.
///
/// ## Usage
/// ```dart
/// StatusBadge(status: 'In Progress') // Shows in info blue
/// StatusBadge(status: 'Completed')   // Shows in success green
/// StatusBadge(status: 'Pending')     // Shows in warning yellow
/// ```
///
/// ## Supported Statuses
/// - Active/In Progress: Info (blue)
/// - Completed/Approved/Paid: Success (green)
/// - Pending/Under Review: Warning (yellow)
/// - Revision/Rejected: Error (red)
/// - Other: Neutral (gray)
///
/// See also:
/// - [AppBadge] for custom badges
/// - [BadgeVariant] for available colors
class StatusBadge extends StatelessWidget {
  /// Creates a status badge for the given status text.
  const StatusBadge({
    super.key,
    required this.status,
  });

  /// The status text to display.
  ///
  /// The text is matched case-insensitively to determine color.
  final String status;

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      text: status,
      variant: _getVariant(),
    );
  }

  /// Determines the badge variant based on status text.
  BadgeVariant _getVariant() {
    switch (status.toLowerCase()) {
      case 'active':
      case 'in progress':
        return BadgeVariant.info;
      case 'completed':
      case 'approved':
      case 'paid':
        return BadgeVariant.success;
      case 'pending':
      case 'under review':
        return BadgeVariant.warning;
      case 'revision':
      case 'rejected':
        return BadgeVariant.error;
      default:
        return BadgeVariant.neutral;
    }
  }
}

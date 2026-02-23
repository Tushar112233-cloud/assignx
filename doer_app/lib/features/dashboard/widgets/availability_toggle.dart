/// Availability toggle widgets for work status management.
///
/// This file provides components for toggling and displaying
/// the user's availability status for accepting new projects.
///
/// ## Features
/// - Full toggle with icon, text, and switch
/// - Compact inline status display
/// - Status badge for headers
/// - Riverpod state management integration
///
/// ## Example
/// ```dart
/// AvailabilityToggle()           // Full toggle
/// AvailabilityToggle(compact: true) // Inline display
/// AvailabilityBadge(isAvailable: true)
/// ```
///
/// See also:
/// - [dashboardProvider] for state management
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/dashboard_provider.dart';

/// A toggle widget for managing work availability status.
///
/// Allows users to toggle their availability for receiving new
/// project assignments. Integrates with the dashboard provider
/// for state persistence.
///
/// ## Usage
/// ```dart
/// AvailabilityToggle()           // Full display with switch
/// AvailabilityToggle(compact: true) // Compact inline display
/// ```
///
/// ## Display Modes
/// - Full: Card with icon, status text, description, and switch
/// - Compact: Dot indicator with status text only
///
/// ## State
/// - Available: Green styling, shows new projects
/// - Unavailable: Gray styling, hides new projects
///
/// See also:
/// - [AvailabilityBadge] for display-only badge
class AvailabilityToggle extends ConsumerWidget {
  /// Creates an availability toggle with the specified properties.
  const AvailabilityToggle({
    super.key,
    this.compact = false,
  });

  /// Whether to use compact inline display.
  ///
  /// Defaults to false.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(isAvailableProvider);
    final isLoading = ref.watch(dashboardProvider).isLoading;

    if (compact) {
      return _buildCompact(context, ref, isAvailable, isLoading);
    }

    return _buildFull(context, ref, isAvailable, isLoading);
  }

  /// Builds the compact inline display.
  Widget _buildCompact(
    BuildContext context,
    WidgetRef ref,
    bool isAvailable,
    bool isLoading,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.success : AppColors.textTertiary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isAvailable ? AppColors.success : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds the full toggle card display.
  Widget _buildFull(
    BuildContext context,
    WidgetRef ref,
    bool isAvailable,
    bool isLoading,
  ) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.border.withValues(alpha: 0.5),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isAvailable
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Status indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAvailable ? Icons.check_circle : Icons.pause_circle_outline,
              color: isAvailable ? AppColors.success : AppColors.textSecondary,
              size: 24,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Status text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Available for Work' : 'Currently Unavailable',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                      ? 'New projects will be shown to you'
                      : 'You won\'t see new projects',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Toggle switch
          Switch(
            value: isAvailable,
            onChanged: isLoading
                ? null
                : (_) {
                    ref.read(dashboardProvider.notifier).toggleAvailability();
                  },
            activeThumbColor: AppColors.success,
            activeTrackColor: AppColors.success.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }
}

/// A display-only availability status badge.
///
/// Shows the availability status without toggle functionality.
/// Useful for headers or read-only contexts.
///
/// ## Usage
/// ```dart
/// AvailabilityBadge(isAvailable: true)
/// AvailabilityBadge(isAvailable: false, showLabel: false)
/// ```
///
/// ## Display
/// - Dot indicator with matching background color
/// - Optional "Available"/"Unavailable" label
///
/// See also:
/// - [AvailabilityToggle] for interactive toggle
class AvailabilityBadge extends StatelessWidget {
  /// Creates an availability badge with the specified properties.
  ///
  /// [isAvailable] is required.
  const AvailabilityBadge({
    super.key,
    required this.isAvailable,
    this.showLabel = true,
  });

  /// Whether the user is available for work.
  final bool isAvailable;

  /// Whether to display the text label.
  ///
  /// Defaults to true.
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.success : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              isAvailable ? 'Available' : 'Unavailable',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isAvailable
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

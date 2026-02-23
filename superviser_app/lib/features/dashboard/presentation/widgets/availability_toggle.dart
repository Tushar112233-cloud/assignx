/// Availability toggle widgets for supervisor status management.
///
/// This file contains:
/// - [AvailabilityToggle]: Interactive switch for toggling availability
/// - [_CompactToggle]: Compact version for space-constrained layouts
/// - [AvailabilityChip]: Read-only status indicator chip
///
/// These widgets allow supervisors to manage their availability status
/// for receiving new project assignments.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// A toggle switch widget for supervisor availability status.
///
/// Displays the current availability state with a visual indicator
/// and allows the supervisor to toggle between available and unavailable
/// states for receiving new project assignments.
///
/// ## Features
///
/// - Colored container with border based on status
/// - Status indicator dot (green = available, gray = unavailable)
/// - Optional status label with description
/// - Animated switch toggle
/// - Compact mode for space-constrained layouts
///
/// ## Usage
///
/// ```dart
/// AvailabilityToggle(
///   isAvailable: true,
///   onChanged: (newValue) => updateAvailability(newValue),
///   showLabel: true,
///   compact: false,
/// )
/// ```
///
/// See also:
/// - [AvailabilityChip] for a read-only status display
/// - [_CompactToggle] for the compact layout variant
class AvailabilityToggle extends StatelessWidget {
  /// Creates a new [AvailabilityToggle] instance.
  ///
  /// Parameters:
  /// - [isAvailable]: Current availability status
  /// - [onChanged]: Callback when toggle is changed
  /// - [showLabel]: Whether to show status description label (default: true)
  /// - [compact]: Use compact layout variant (default: false)
  const AvailabilityToggle({
    super.key,
    required this.isAvailable,
    required this.onChanged,
    this.showLabel = true,
    this.compact = false,
  });

  /// Current availability status.
  ///
  /// When `true`, the supervisor is available and can receive new project
  /// assignments. When `false`, the supervisor is marked as unavailable.
  final bool isAvailable;

  /// Callback invoked when the toggle is changed.
  ///
  /// The new availability value is passed as the parameter.
  final ValueChanged<bool> onChanged;

  /// Whether to show the status description label.
  ///
  /// When `true`, shows additional text like "Accepting new requests"
  /// or "Not accepting requests" below the status title.
  final bool showLabel;

  /// Use compact layout variant.
  ///
  /// When `true`, renders using [_CompactToggle] which uses less space.
  /// When `false`, renders the full-featured toggle with container styling.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactToggle(
        isAvailable: isAvailable,
        onChanged: onChanged,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.secondaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.secondaryLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Status indicator dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.success : AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          // Label text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isAvailable
                            ? AppColors.success
                            : AppColors.secondaryLight,
                      ),
                ),
                if (showLabel)
                  Text(
                    isAvailable
                        ? 'Accepting new requests'
                        : 'Not accepting requests',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
              ],
            ),
          ),
          // Switch toggle
          Switch.adaptive(
            value: isAvailable,
            onChanged: onChanged,
            activeTrackColor: AppColors.success.withValues(alpha: 0.4),
            thumbColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.success;
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}

/// Compact version of the availability toggle.
///
/// A space-efficient variant that displays only the essential elements:
/// status indicator dot, status text, and toggle switch in a row.
///
/// This widget is used when [AvailabilityToggle.compact] is `true`.
///
/// See also:
/// - [AvailabilityToggle] for the full-featured toggle
class _CompactToggle extends StatelessWidget {
  /// Creates a new [_CompactToggle] instance.
  ///
  /// Parameters:
  /// - [isAvailable]: Current availability status
  /// - [onChanged]: Callback when toggle changes
  const _CompactToggle({
    required this.isAvailable,
    required this.onChanged,
  });

  /// Current availability status.
  final bool isAvailable;

  /// Callback when toggle changes.
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.success : AppColors.secondaryLight,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        // Status text
        Text(
          isAvailable ? 'Available' : 'Unavailable',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isAvailable ? AppColors.success : AppColors.secondaryLight,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(width: 8),
        // Switch toggle
        Switch.adaptive(
          value: isAvailable,
          onChanged: onChanged,
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.success;
            }
            return null;
          }),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

/// A read-only availability status chip.
///
/// Displays the availability status as a small colored chip with
/// indicator dot and text. This is a display-only widget without
/// interactive toggle functionality.
///
/// ## Usage
///
/// ```dart
/// AvailabilityChip(isAvailable: doer.isAvailable)
/// ```
///
/// Use this for displaying doer availability in lists or cards
/// where interaction is not needed.
///
/// See also:
/// - [AvailabilityToggle] for interactive toggle
class AvailabilityChip extends StatelessWidget {
  /// Creates a new [AvailabilityChip] instance.
  ///
  /// Parameters:
  /// - [isAvailable]: The availability status to display
  const AvailabilityChip({
    super.key,
    required this.isAvailable,
  });

  /// The availability status to display.
  ///
  /// When `true`, shows green "Available" chip.
  /// When `false`, shows gray "Unavailable" chip.
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.secondaryLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status indicator dot
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isAvailable ? AppColors.success : AppColors.secondaryLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // Status text
          Text(
            isAvailable ? 'Available' : 'Unavailable',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color:
                      isAvailable ? AppColors.success : AppColors.secondaryLight,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

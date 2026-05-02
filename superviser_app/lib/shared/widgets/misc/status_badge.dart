import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Interface for objects that can be displayed in a status badge.
///
/// Implement this mixin on status enums to enable unified badge rendering.
mixin StatusDisplayable {
  /// Human-readable name for display
  String get displayName;

  /// Color associated with this status
  Color get color;

  /// Optional icon for this status (returns null if no icon)
  IconData? get icon => null;
}

/// Status badge for displaying project/item status.
///
/// Supports both string-based status and objects implementing [StatusDisplayable].
///
/// Example with string:
/// ```dart
/// StatusBadge(status: 'in_progress')
/// ```
///
/// Example with enum:
/// ```dart
/// StatusBadge.fromDisplayable(ProjectStatus.inProgress)
/// ```
class StatusBadge extends StatelessWidget {
  /// Creates a status badge from a string status.
  const StatusBadge({
    super.key,
    required this.status,
    this.size = StatusBadgeSize.medium,
    this.showIcon = false,
  })  : _displayName = null,
        _color = null,
        _icon = null;

  /// Creates a status badge from a [StatusDisplayable] object.
  const StatusBadge.fromDisplayable({
    super.key,
    required String displayName,
    required Color color,
    IconData? icon,
    this.size = StatusBadgeSize.medium,
    this.showIcon = true,
  })  : status = '',
        _displayName = displayName,
        _color = color,
        _icon = icon;

  /// Status text to display (for string-based status)
  final String status;

  /// Size of the badge
  final StatusBadgeSize size;

  /// Whether to show the icon (if available)
  final bool showIcon;

  // Private fields for displayable-based construction
  final String? _displayName;
  final Color? _color;
  final IconData? _icon;

  @override
  Widget build(BuildContext context) {
    final color = _color ?? AppColors.getStatusColor(status);
    final displayText = _displayName ?? _formatStatus(status);
    final icon = _icon;

    return Semantics(
      label: 'Status: $displayText',
      child: Container(
      padding: size.padding,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size.borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon && icon != null) ...[
            Icon(icon, size: size.iconSize, color: color),
            SizedBox(width: size.iconSpacing),
          ],
          Text(
            displayText,
            style: size.textStyle.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      ),
    );
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

/// Size variants for status badge
enum StatusBadgeSize {
  small(
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    borderRadius: 4,
    textStyle: AppTypography.labelSmall,
    iconSize: 10,
    iconSpacing: 3,
  ),
  medium(
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    borderRadius: 6,
    textStyle: AppTypography.labelMedium,
    iconSize: 12,
    iconSpacing: 4,
  ),
  large(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    borderRadius: 8,
    textStyle: AppTypography.labelLarge,
    iconSize: 14,
    iconSpacing: 4,
  );

  const StatusBadgeSize({
    required this.padding,
    required this.borderRadius,
    required this.textStyle,
    required this.iconSize,
    required this.iconSpacing,
  });

  final EdgeInsets padding;
  final double borderRadius;
  final TextStyle textStyle;
  final double iconSize;
  final double iconSpacing;
}

/// Simple colored badge
class Badge extends StatelessWidget {
  const Badge({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.primary;

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor ?? effectiveColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: effectiveColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Numeric counter badge (e.g., notification count)
class CountBadge extends StatelessWidget {
  const CountBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
    this.color,
  });

  final int count;
  final int maxCount;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final displayText = count > maxCount ? '$maxCount+' : count.toString();
    final semanticLabel = count > maxCount
        ? 'More than $maxCount notifications'
        : '$count notification${count == 1 ? '' : 's'}';

    return Semantics(
      label: semanticLabel,
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 20,
          minHeight: 20,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color ?? theme.colorScheme.error,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          displayText,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

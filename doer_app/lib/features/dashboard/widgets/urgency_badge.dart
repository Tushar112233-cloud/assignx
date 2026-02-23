/// Urgency and priority indicator widgets.
///
/// This file provides visual indicators for project urgency, priority levels,
/// and time remaining status. These badges help users quickly identify
/// time-sensitive tasks.
///
/// ## Widgets
/// - [UrgencyBadge] - Fire icon badge for urgent projects
/// - [PriorityIndicator] - Colored dot with priority label
/// - [TimeRemainingBadge] - Time remaining with color coding
///
/// ## Urgency Colors
/// - **Urgent (orange)**: Time-critical tasks requiring immediate attention
/// - **High (red)**: High priority tasks
/// - **Medium (yellow)**: Normal priority tasks
/// - **Low (green)**: Low priority or completed tasks
///
/// ## Example
/// ```dart
/// // Show urgency badge
/// if (project.isUrgent)
///   const UrgencyBadge()
///
/// // Priority indicator
/// PriorityIndicator(priority: project.priority)
///
/// // Time remaining badge
/// TimeRemainingBadge(remaining: project.deadline.difference(DateTime.now()))
/// ```
///
/// See also:
/// - [DeadlineCountdown] for countdown timers
/// - [ProjectCard] for usage context
/// - [AppColors] for color definitions
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Urgency badge widget with fire icon.
///
/// Displays a prominent badge indicating that a project is time-sensitive
/// and requires immediate attention. Available in full and compact modes.
///
/// ## Props
/// - [compact]: Use circular compact mode (icon only)
/// - [label]: Custom label text (default: "Urgent")
class UrgencyBadge extends StatelessWidget {
  final bool compact;
  final String? label;

  const UrgencyBadge({
    super.key,
    this.compact = false,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.urgentBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.local_fire_department,
          size: 14,
          color: AppColors.urgent,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.urgentBg,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: AppColors.urgent.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 14,
            color: AppColors.urgent,
          ),
          const SizedBox(width: 4),
          Text(
            label ?? 'Urgent',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.urgent,
            ),
          ),
        ],
      ),
    );
  }
}

/// Priority indicator widget.
///
/// Displays a colored dot with priority label. Priority levels 1-4
/// correspond to Low, Medium, High, and Critical.
///
/// ## Priority Levels
/// - **1 (green)**: Low priority
/// - **2 (yellow)**: Medium priority
/// - **3 (red)**: High priority
/// - **4 (orange)**: Critical priority
class PriorityIndicator extends StatelessWidget {
  final int priority; // 1-4, where 4 is highest

  const PriorityIndicator({
    super.key,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority) {
      case 4:
        color = AppColors.urgent;
        label = 'Critical';
        break;
      case 3:
        color = AppColors.error;
        label = 'High';
        break;
      case 2:
        color = AppColors.warning;
        label = 'Medium';
        break;
      default:
        color = AppColors.success;
        label = 'Low';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Time remaining badge.
///
/// Displays remaining time with color-coded urgency. Automatically
/// formats duration and changes color based on time remaining.
///
/// ## Color States
/// - **Green**: More than 24 hours remaining
/// - **Yellow**: Less than 24 hours remaining
/// - **Orange**: Less than 6 hours remaining
/// - **Red**: Overdue
class TimeRemainingBadge extends StatelessWidget {
  final Duration remaining;

  const TimeRemainingBadge({
    super.key,
    required this.remaining,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = remaining.inHours < 6;
    final isOverdue = remaining.isNegative;

    Color bgColor;
    Color textColor;
    String text;

    if (isOverdue) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      text = 'Overdue';
    } else if (isUrgent) {
      bgColor = AppColors.urgentBg;
      textColor = AppColors.urgent;
      text = _formatDuration(remaining);
    } else if (remaining.inHours < 24) {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      text = _formatDuration(remaining);
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      text = _formatDuration(remaining);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? Icons.error_outline : Icons.access_time,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '<1m';
    }
  }
}

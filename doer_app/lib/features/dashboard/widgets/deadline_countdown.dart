/// Deadline countdown widgets for displaying time remaining.
///
/// This file provides real-time countdown timers for project deadlines,
/// with automatic color coding based on urgency and overdue status.
///
/// ## Widgets
/// - [DeadlineCountdown] - Compact deadline display for cards
/// - [LargeDeadlineTimer] - Full countdown timer for workspace view
///
/// ## Features
/// - Real-time updates every second
/// - Color-coded urgency states (green, yellow, orange, red)
/// - Overdue detection and display
/// - Automatic formatting (days, hours, minutes, seconds)
/// - Compact and full display modes
///
/// ## Urgency States
/// - **Normal (green)**: More than 24 hours remaining
/// - **Warning (yellow)**: Less than 24 hours remaining
/// - **Urgent (orange)**: Less than 6 hours remaining
/// - **Overdue (red)**: Deadline has passed
///
/// ## Example
/// ```dart
/// // Compact countdown for project cards
/// DeadlineCountdown(
///   deadline: project.deadline,
///   showIcon: true,
/// )
///
/// // Full timer for workspace
/// LargeDeadlineTimer(deadline: project.deadline)
/// ```
///
/// See also:
/// - [ProjectCard] for card-based deadline display
/// - [AppColors] for urgency color scheme
library;

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Deadline countdown widget for project cards.
///
/// Displays time remaining until deadline with color-coded urgency
/// and automatic updates every second.
///
/// ## Props
/// - [deadline]: The target deadline date/time
/// - [showIcon]: Whether to show the status icon
/// - [compact]: Use compact display mode
class DeadlineCountdown extends StatefulWidget {
  final DateTime deadline;
  final bool showIcon;
  final bool compact;

  const DeadlineCountdown({
    super.key,
    required this.deadline,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  State<DeadlineCountdown> createState() => _DeadlineCountdownState();
}

class _DeadlineCountdownState extends State<DeadlineCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    setState(() {
      _remaining = widget.deadline.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _remaining.isNegative;
    final isUrgent = !isOverdue && _remaining.inHours < 6;
    final isWarning = !isOverdue && !isUrgent && _remaining.inHours < 24;

    Color bgColor;
    Color textColor;
    IconData icon;

    if (isOverdue) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      icon = Icons.error_outline;
    } else if (isUrgent) {
      bgColor = AppColors.urgentBg;
      textColor = AppColors.urgent;
      icon = Icons.local_fire_department;
    } else if (isWarning) {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      icon = Icons.schedule;
    } else {
      bgColor = AppColors.success.withValues(alpha: 0.1);
      textColor = AppColors.success;
      icon = Icons.check_circle_outline;
    }

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            _formatRemaining(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          if (widget.showIcon) ...[
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isOverdue ? 'Overdue' : 'Deadline',
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withValues(alpha: 0.8),
                ),
              ),
              Text(
                _formatRemaining(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            _formatDate(),
            style: TextStyle(
              fontSize: 12,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatRemaining() {
    if (_remaining.isNegative) {
      final overdue = _remaining.abs();
      if (overdue.inDays > 0) {
        return '${overdue.inDays}d ${overdue.inHours % 24}h ago';
      } else if (overdue.inHours > 0) {
        return '${overdue.inHours}h ${overdue.inMinutes % 60}m ago';
      } else {
        return '${overdue.inMinutes}m ago';
      }
    }

    if (_remaining.inDays > 0) {
      return '${_remaining.inDays}d ${_remaining.inHours % 24}h left';
    } else if (_remaining.inHours > 0) {
      return '${_remaining.inHours}h ${_remaining.inMinutes % 60}m left';
    } else if (_remaining.inMinutes > 0) {
      return '${_remaining.inMinutes}m ${_remaining.inSeconds % 60}s left';
    } else {
      return '${_remaining.inSeconds}s left';
    }
  }

  String _formatDate() {
    final date = widget.deadline;
    final now = DateTime.now();

    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'Today ${_formatTime(date)}';
    } else if (date.day == now.day + 1 && date.month == now.month && date.year == now.year) {
      return 'Tomorrow ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month} ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }
}

/// Large deadline timer for workspace view.
///
/// Displays a prominent countdown with days, hours, minutes, and seconds
/// in individual boxes. Suitable for workspace screens where deadline
/// visibility is critical.
///
/// ## Display Format
/// ```
///   TIME REMAINING
/// [DD] : [HH] : [MM] : [SS]
/// DAYS   HRS    MIN    SEC
/// ```
///
/// ## Color States
/// - **Normal**: Primary text color
/// - **Urgent**: Orange color (< 6 hours)
/// - **Overdue**: Red color with "OVERDUE" label
class LargeDeadlineTimer extends StatefulWidget {
  final DateTime deadline;

  const LargeDeadlineTimer({
    super.key,
    required this.deadline,
  });

  @override
  State<LargeDeadlineTimer> createState() => _LargeDeadlineTimerState();
}

class _LargeDeadlineTimerState extends State<LargeDeadlineTimer> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    setState(() {
      _remaining = widget.deadline.difference(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _remaining.isNegative;
    final isUrgent = !isOverdue && _remaining.inHours < 6;

    Color textColor;
    if (isOverdue) {
      textColor = AppColors.error;
    } else if (isUrgent) {
      textColor = AppColors.urgent;
    } else {
      textColor = AppColors.textPrimary;
    }

    final days = _remaining.abs().inDays;
    final hours = _remaining.abs().inHours % 24;
    final minutes = _remaining.abs().inMinutes % 60;
    final seconds = _remaining.abs().inSeconds % 60;

    return Column(
      children: [
        if (isOverdue)
          const Text(
            'OVERDUE',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
              letterSpacing: 2,
            ),
          )
        else
          const Text(
            'TIME REMAINING',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (days > 0) ...[
              _buildTimeUnit(days.toString(), 'DAYS', textColor),
              _buildSeparator(textColor),
            ],
            _buildTimeUnit(hours.toString().padLeft(2, '0'), 'HRS', textColor),
            _buildSeparator(textColor),
            _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'MIN', textColor),
            _buildSeparator(textColor),
            _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'SEC', textColor),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeUnit(String value, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color.withValues(alpha: 0.7),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

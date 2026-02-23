import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget that displays a countdown timer to a deadline.
///
/// Updates in real-time and changes color based on urgency.
class DeadlineTimer extends StatefulWidget {
  const DeadlineTimer({
    super.key,
    required this.deadline,
    this.compact = false,
    this.showIcon = true,
    this.onExpired,
  });

  /// The deadline to count down to
  final DateTime deadline;

  /// Whether to use compact layout
  final bool compact;

  /// Whether to show the clock icon
  final bool showIcon;

  /// Called when the deadline expires
  final VoidCallback? onExpired;

  @override
  State<DeadlineTimer> createState() => _DeadlineTimerState();
}

class _DeadlineTimerState extends State<DeadlineTimer> {
  Timer? _timer;
  late Duration _remaining;
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _startTimer();
  }

  @override
  void didUpdateWidget(DeadlineTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline) {
      _updateRemaining();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateRemaining() {
    _remaining = widget.deadline.difference(DateTime.now());
    if (_remaining.isNegative && !_expired) {
      _expired = true;
      widget.onExpired?.call();
    }
  }

  void _startTimer() {
    // Update every minute for long durations, every second for short
    final updateInterval = _remaining.inMinutes > 60
        ? const Duration(minutes: 1)
        : const Duration(seconds: 1);

    _timer = Timer.periodic(updateInterval, (_) {
      if (mounted) {
        setState(_updateRemaining);
      }
    });
  }

  Color get _color {
    if (_remaining.isNegative) return AppColors.error;
    if (_remaining.inHours < 6) return AppColors.error;
    if (_remaining.inHours < 24) return Colors.orange;
    if (_remaining.inDays < 3) return Colors.amber;
    return AppColors.textSecondaryLight;
  }

  String get _displayText {
    if (_remaining.isNegative) {
      final overdue = _remaining.abs();
      if (overdue.inDays > 0) {
        return '${overdue.inDays}d overdue';
      } else if (overdue.inHours > 0) {
        return '${overdue.inHours}h overdue';
      } else {
        return '${overdue.inMinutes}m overdue';
      }
    }

    if (_remaining.inDays > 7) {
      return '${_remaining.inDays}d';
    } else if (_remaining.inDays > 0) {
      final hours = _remaining.inHours % 24;
      return '${_remaining.inDays}d ${hours}h';
    } else if (_remaining.inHours > 0) {
      final minutes = _remaining.inMinutes % 60;
      return '${_remaining.inHours}h ${minutes}m';
    } else if (_remaining.inMinutes > 0) {
      return '${_remaining.inMinutes}m';
    } else {
      return 'Now';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showIcon) ...[
              Icon(
                _remaining.isNegative
                    ? Icons.warning_rounded
                    : Icons.schedule,
                size: 14,
                color: _color,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              _displayText,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showIcon)
            Icon(
              _remaining.isNegative
                  ? Icons.warning_rounded
                  : Icons.timer_outlined,
              size: 24,
              color: _color,
            ),
          if (widget.showIcon) const SizedBox(height: 4),
          Text(
            _displayText,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            _remaining.isNegative ? 'Overdue' : 'Remaining',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _color.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }
}

/// Widget that shows deadline as a progress bar.
class DeadlineProgress extends StatelessWidget {
  const DeadlineProgress({
    super.key,
    required this.startDate,
    required this.deadline,
  });

  /// When the project/task started
  final DateTime startDate;

  /// The deadline
  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final total = deadline.difference(startDate);
    final elapsed = now.difference(startDate);
    final progress = (elapsed.inMinutes / total.inMinutes).clamp(0.0, 1.0);
    final isOverdue = now.isAfter(deadline);

    final color = isOverdue
        ? AppColors.error
        : progress > 0.8
            ? Colors.orange
            : progress > 0.5
                ? Colors.amber
                : AppColors.success;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deadline Progress',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

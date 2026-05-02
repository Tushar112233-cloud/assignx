import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Deadline badge with color coding based on urgency.
class DeadlineBadge extends StatelessWidget {
  final DateTime deadline;
  final bool showIcon;
  final bool compact;

  const DeadlineBadge({
    super.key,
    required this.deadline,
    this.showIcon = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    final isPassed = deadline.isBefore(now);
    final isUrgent = !isPassed && difference.inHours < 24;
    final isWarning = !isPassed && !isUrgent && difference.inHours < 72;

    final color = isPassed
        ? AppColors.textTertiary
        : isUrgent
            ? AppColors.error
            : isWarning
                ? AppColors.warning
                : AppColors.textSecondary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            isPassed ? Icons.event_busy : Icons.schedule,
            size: compact ? 12 : 14,
            color: color,
          ),
          SizedBox(width: compact ? 4 : 6),
        ],
        Text(
          _formatDeadline(deadline, isPassed),
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: compact ? 11 : 12,
            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDeadline(DateTime deadline, bool isPassed) {
    if (isPassed) return 'Deadline passed';

    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inHours < 1) {
      return '${difference.inMinutes}m left';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h left';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d left';
    } else {
      final day = deadline.day.toString().padLeft(2, '0');
      final month = _monthName(deadline.month);
      return '$day $month';
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

/// Real-time countdown timer for deadlines.
class DeadlineTimer extends StatefulWidget {
  final DateTime deadline;
  final TextStyle? style;
  final bool showSeconds;

  const DeadlineTimer({
    super.key,
    required this.deadline,
    this.style,
    this.showSeconds = false,
  });

  @override
  State<DeadlineTimer> createState() => _DeadlineTimerState();
}

class _DeadlineTimerState extends State<DeadlineTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.deadline.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    // Cancel any existing timer before creating new one
    _timer?.cancel();

    // Don't start timer if already expired
    if (_remaining.isNegative) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      setState(() {
        _remaining = widget.deadline.difference(DateTime.now());
      });
      // Stop the timer if deadline has passed
      if (_remaining.isNegative) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return Text(
        'Deadline passed',
        style: widget.style?.copyWith(color: AppColors.error) ??
            AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      );
    }

    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;
    final seconds = _remaining.inSeconds % 60;

    String text;
    if (days > 0) {
      text = '${days}d ${hours}h ${minutes}m';
    } else if (hours > 0) {
      text = '${hours}h ${minutes}m';
      if (widget.showSeconds) text += ' ${seconds}s';
    } else {
      text = '${minutes}m ${seconds}s';
    }

    final isUrgent = _remaining.inHours < 24;
    final color = isUrgent ? AppColors.error : AppColors.textSecondary;

    return Text(
      text,
      style: widget.style?.copyWith(color: color) ??
          AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
          ),
    );
  }
}

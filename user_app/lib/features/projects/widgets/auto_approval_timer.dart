import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Auto-approval countdown timer widget
/// Shows remaining time before project auto-approves (48h default)
/// Implements U33 from feature spec
class AutoApprovalTimer extends StatefulWidget {
  final DateTime autoApprovalDeadline;
  final VoidCallback? onExpired;
  final bool compact;

  const AutoApprovalTimer({
    super.key,
    required this.autoApprovalDeadline,
    this.onExpired,
    this.compact = false,
  });

  @override
  State<AutoApprovalTimer> createState() => _AutoApprovalTimerState();
}

class _AutoApprovalTimerState extends State<AutoApprovalTimer> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final diff = widget.autoApprovalDeadline.difference(now);
    setState(() {
      _timeLeft = diff.isNegative ? Duration.zero : diff;
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _calculateTimeLeft();
      if (_timeLeft == Duration.zero) {
        _timer?.cancel();
        widget.onExpired?.call();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
    }
    return '${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _timeLeft == Duration.zero;
    final isUrgent = _timeLeft.inHours < 6 && !isExpired;

    if (isExpired) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 8 : 12,
          vertical: widget.compact ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: widget.compact ? 14 : 16,
              color: AppColors.success,
            ),
            const SizedBox(width: 6),
            Text(
              'Auto-approved',
              style: (widget.compact ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                  .copyWith(color: AppColors.success),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 8 : 12,
        vertical: widget.compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? AppColors.warning.withAlpha(25)
            : AppColors.primary.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: widget.compact ? 14 : 16,
            color: isUrgent ? AppColors.warning : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text.rich(
            TextSpan(
              text: 'Auto-approves in ',
              style: (widget.compact ? AppTextStyles.labelSmall : AppTextStyles.labelMedium)
                  .copyWith(
                color: isUrgent ? AppColors.warning : AppColors.primary,
              ),
              children: [
                TextSpan(
                  text: _formatDuration(_timeLeft),
                  style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

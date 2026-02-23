import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'message_approval_badge.dart';

/// A full status view widget for message senders.
///
/// Shows detailed information about the message approval status including
/// "Pending supervisor approval", approval confirmation, or rejection reason.
///
/// Example usage:
/// ```dart
/// MessageStatusIndicator(
///   status: MessageApprovalStatus.pending,
///   isVisible: true,
/// )
/// ```
class MessageStatusIndicator extends StatefulWidget {
  /// The current approval status of the message.
  final MessageApprovalStatus status;

  /// Whether this indicator should be visible.
  final bool isVisible;

  /// Optional name of the supervisor who took action.
  final String? supervisorName;

  /// Optional timestamp of the action.
  final DateTime? actionTimestamp;

  /// Optional rejection reason (only for rejected status).
  final String? rejectionReason;

  /// Whether to show in compact mode.
  final bool compact;

  /// Creates a message status indicator.
  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.isVisible = true,
    this.supervisorName,
    this.actionTimestamp,
    this.rejectionReason,
    this.compact = false,
  });

  @override
  State<MessageStatusIndicator> createState() => _MessageStatusIndicatorState();
}

class _MessageStatusIndicatorState extends State<MessageStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(MessageStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }

    // Animate on status change
    if (widget.status != oldWidget.status) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get configuration for the current status.
  _StatusIndicatorConfig get _config {
    switch (widget.status) {
      case MessageApprovalStatus.pending:
        return _StatusIndicatorConfig(
          icon: Icons.schedule_outlined,
          title: 'Pending Supervisor Approval',
          subtitle: 'Your message is waiting for review',
          backgroundColor: AppColors.warning.withValues(alpha: 0.15),
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case MessageApprovalStatus.approved:
        return _StatusIndicatorConfig(
          icon: Icons.check_circle_outline,
          title: 'Message Approved',
          subtitle: widget.supervisorName != null
              ? 'Approved by ${widget.supervisorName}'
              : 'Your message has been approved',
          backgroundColor: AppColors.success.withValues(alpha: 0.15),
          borderColor: AppColors.success.withValues(alpha: 0.3),
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case MessageApprovalStatus.rejected:
        return _StatusIndicatorConfig(
          icon: Icons.cancel_outlined,
          title: 'Message Rejected',
          subtitle: widget.rejectionReason ?? 'Your message was not approved',
          backgroundColor: AppColors.error.withValues(alpha: 0.15),
          borderColor: AppColors.error.withValues(alpha: 0.3),
          iconColor: AppColors.error,
          textColor: AppColors.error,
        );
    }
  }

  /// Format timestamp for display.
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final config = _config;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.compact
            ? _buildCompactIndicator(config)
            : _buildFullIndicator(config),
      ),
    );
  }

  Widget _buildCompactIndicator(_StatusIndicatorConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 12, color: config.iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              config.title,
              style: AppTextStyles.caption.copyWith(
                color: config.textColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullIndicator(_StatusIndicatorConfig config) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: config.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: config.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with icon and title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: config.iconColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      config.icon,
                      size: 18,
                      color: config.iconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          config.title,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: config.textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.actionTimestamp != null)
                          Text(
                            _formatTimestamp(widget.actionTimestamp!),
                            style: AppTextStyles.caption.copyWith(
                              color: config.textColor.withValues(alpha: 0.7),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              // Subtitle/description
              const SizedBox(height: 8),
              Text(
                config.subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: config.textColor.withValues(alpha: 0.9),
                ),
              ),

              // Additional info for rejected status
              if (widget.status == MessageApprovalStatus.rejected &&
                  widget.rejectionReason != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: config.iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: config.iconColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.rejectionReason!,
                          style: AppTextStyles.caption.copyWith(
                            color: config.textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Configuration for status indicator appearance.
class _StatusIndicatorConfig {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const _StatusIndicatorConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}

/// A banner widget that shows pending approval status at the top of the chat.
///
/// Displays when the user has messages pending supervisor approval.
class PendingApprovalBanner extends StatelessWidget {
  /// Number of messages pending approval.
  final int pendingCount;

  /// Whether the banner is visible.
  final bool isVisible;

  /// Creates a pending approval banner.
  const PendingApprovalBanner({
    super.key,
    required this.pendingCount,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.warning.withValues(alpha: 0.2),
                AppColors.warning.withValues(alpha: 0.1),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pendingCount == 1
                          ? '1 message pending approval'
                          : '$pendingCount messages pending approval',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Your messages will be delivered after supervisor review',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A floating indicator that pulses when there are pending messages.
class PendingMessagesIndicator extends StatefulWidget {
  /// Number of pending messages.
  final int count;

  /// Creates a pending messages indicator.
  const PendingMessagesIndicator({
    super.key,
    required this.count,
  });

  @override
  State<PendingMessagesIndicator> createState() =>
      _PendingMessagesIndicatorState();
}

class _PendingMessagesIndicatorState extends State<PendingMessagesIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.count == 0) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warning,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  '${widget.count}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

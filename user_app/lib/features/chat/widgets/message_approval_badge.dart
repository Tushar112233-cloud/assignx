import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Message approval status enumeration.
enum MessageApprovalStatus {
  /// Message is pending supervisor approval
  pending,

  /// Message has been approved by supervisor
  approved,

  /// Message has been rejected by supervisor
  rejected,
}

/// Extension to parse status from string.
extension MessageApprovalStatusExtension on MessageApprovalStatus {
  /// Convert status to display string
  String get displayName {
    switch (this) {
      case MessageApprovalStatus.pending:
        return 'Pending';
      case MessageApprovalStatus.approved:
        return 'Approved';
      case MessageApprovalStatus.rejected:
        return 'Rejected';
    }
  }

  /// Parse status from string value
  static MessageApprovalStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'approved':
        return MessageApprovalStatus.approved;
      case 'rejected':
        return MessageApprovalStatus.rejected;
      case 'pending':
      default:
        return MessageApprovalStatus.pending;
    }
  }
}

/// A badge widget that displays the approval status of a message.
///
/// Shows a small animated badge with icon indicating whether the message
/// is pending approval, approved, or rejected by the supervisor.
///
/// Example usage:
/// ```dart
/// MessageApprovalBadge(
///   status: MessageApprovalStatus.pending,
///   size: MessageApprovalBadgeSize.small,
/// )
/// ```
class MessageApprovalBadge extends StatefulWidget {
  /// The current approval status of the message.
  final MessageApprovalStatus status;

  /// Optional name of the supervisor who approved/rejected.
  final String? approvedBy;

  /// Optional timestamp when the message was approved/rejected.
  final DateTime? approvedAt;

  /// Optional reason for rejection (only applicable when status is rejected).
  final String? rejectionReason;

  /// Size of the badge.
  final MessageApprovalBadgeSize size;

  /// Whether to show animation on status change.
  final bool animate;

  /// Creates a message approval badge.
  const MessageApprovalBadge({
    super.key,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.size = MessageApprovalBadgeSize.small,
    this.animate = true,
  });

  @override
  State<MessageApprovalBadge> createState() => _MessageApprovalBadgeState();
}

/// Size variants for the message approval badge.
enum MessageApprovalBadgeSize {
  /// Small size (16x16)
  small,

  /// Medium size (20x20)
  medium,

  /// Large size (24x24)
  large,
}

class _MessageApprovalBadgeState extends State<MessageApprovalBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  MessageApprovalStatus? _previousStatus;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    if (widget.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MessageApprovalBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate when status changes
    if (widget.status != oldWidget.status && widget.animate) {
      _previousStatus = oldWidget.status;
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Get the size in pixels based on size variant.
  double get _badgeSize {
    switch (widget.size) {
      case MessageApprovalBadgeSize.small:
        return 16.0;
      case MessageApprovalBadgeSize.medium:
        return 20.0;
      case MessageApprovalBadgeSize.large:
        return 24.0;
    }
  }

  /// Get the icon size based on badge size.
  double get _iconSize {
    switch (widget.size) {
      case MessageApprovalBadgeSize.small:
        return 10.0;
      case MessageApprovalBadgeSize.medium:
        return 12.0;
      case MessageApprovalBadgeSize.large:
        return 14.0;
    }
  }

  /// Get the status configuration.
  _StatusConfig get _config {
    switch (widget.status) {
      case MessageApprovalStatus.pending:
        return _StatusConfig(
          icon: Icons.schedule,
          backgroundColor: AppColors.warning.withValues(alpha: 0.2),
          iconColor: AppColors.warning,
          borderColor: AppColors.warning.withValues(alpha: 0.4),
        );
      case MessageApprovalStatus.approved:
        return _StatusConfig(
          icon: Icons.check,
          backgroundColor: AppColors.success.withValues(alpha: 0.2),
          iconColor: AppColors.success,
          borderColor: AppColors.success.withValues(alpha: 0.4),
        );
      case MessageApprovalStatus.rejected:
        return _StatusConfig(
          icon: Icons.close,
          backgroundColor: AppColors.error.withValues(alpha: 0.2),
          iconColor: AppColors.error,
          borderColor: AppColors.error.withValues(alpha: 0.4),
        );
    }
  }

  /// Format date for tooltip.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      final hours = date.hour.toString().padLeft(2, '0');
      final minutes = date.minute.toString().padLeft(2, '0');
      return 'Today at $hours:$minutes';
    } else if (difference.inDays == 1) {
      final hours = date.hour.toString().padLeft(2, '0');
      final minutes = date.minute.toString().padLeft(2, '0');
      return 'Yesterday at $hours:$minutes';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showTooltip(BuildContext context) {
    final config = _config;
    final tooltipText = _buildTooltipText();

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.4,
              left: 20,
              right: 20,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: config.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                config.icon,
                                size: 16,
                                color: config.iconColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.status.displayName,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: config.iconColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (tooltipText.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              tooltipText,
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildTooltipText() {
    final lines = <String>[];

    if (widget.approvedBy != null) {
      lines.add('By: ${widget.approvedBy}');
    }

    if (widget.approvedAt != null) {
      lines.add('At: ${_formatDate(widget.approvedAt!)}');
    }

    if (widget.rejectionReason != null &&
        widget.status == MessageApprovalStatus.rejected) {
      lines.add('Reason: ${widget.rejectionReason}');
    }

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;

    return GestureDetector(
      onTap: () => _showTooltip(context),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: _badgeSize,
                height: _badgeSize,
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: config.borderColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: config.iconColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  config.icon,
                  size: _iconSize,
                  color: config.iconColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Configuration for status appearance.
class _StatusConfig {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final Color borderColor;

  const _StatusConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.borderColor,
  });
}

/// An inline variant of the approval badge for use within message content.
///
/// Shows status as text with icon for clearer visibility.
class MessageApprovalBadgeInline extends StatelessWidget {
  /// The current approval status.
  final MessageApprovalStatus status;

  /// Optional rejection reason.
  final String? rejectionReason;

  /// Creates an inline message approval badge.
  const MessageApprovalBadgeInline({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    late final IconData icon;
    late final Color backgroundColor;
    late final Color textColor;
    late final String label;

    switch (status) {
      case MessageApprovalStatus.pending:
        icon = Icons.schedule;
        backgroundColor = AppColors.warning.withValues(alpha: 0.2);
        textColor = AppColors.warning;
        label = 'Pending';
        break;
      case MessageApprovalStatus.approved:
        icon = Icons.check;
        backgroundColor = AppColors.success.withValues(alpha: 0.2);
        textColor = AppColors.success;
        label = 'Approved';
        break;
      case MessageApprovalStatus.rejected:
        icon = Icons.close;
        backgroundColor = AppColors.error.withValues(alpha: 0.2);
        textColor = AppColors.error;
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (rejectionReason != null &&
              status == MessageApprovalStatus.rejected) ...[
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '- $rejectionReason',
                style: AppTextStyles.caption.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

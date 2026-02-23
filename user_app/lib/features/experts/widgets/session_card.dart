import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../shared/widgets/glass_container.dart';

/// Session card widget for displaying booked consultations.
///
/// Shows booking details including expert info, date/time, status,
/// and action buttons based on session status.
class SessionCard extends StatelessWidget {
  /// The consultation booking to display.
  final ConsultationBooking booking;

  /// Expert information for the booking.
  final Expert? expert;

  /// Called when message button is pressed.
  final VoidCallback? onMessage;

  /// Called when reschedule button is pressed.
  final VoidCallback? onReschedule;

  /// Called when cancel button is pressed.
  final VoidCallback? onCancel;

  /// Called when join button is pressed.
  final VoidCallback? onJoin;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.booking,
    this.expert,
    this.onMessage,
    this.onReschedule,
    this.onCancel,
    this.onJoin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = booking.status == BookingStatus.upcoming ||
        booking.status == BookingStatus.inProgress;

    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        blur: 12,
        opacity: 0.8,
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Expert info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 12),

                // Expert details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              expert?.name ?? 'Expert',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        expert?.designation ?? 'Consultant',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date/time and meeting info
            Row(
              children: [
                _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: _formatDate(booking.date),
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  icon: Icons.access_time,
                  label: '${booking.startTime} - ${booking.endTime}',
                ),
                if (booking.meetLink != null) ...[
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    icon: Icons.videocam,
                    label: 'Video Call',
                  ),
                ],
              ],
            ),

            // Topic
            if (booking.topic != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Topic: ',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      booking.topic!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),

            // Bottom row with amount and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isUpcoming) ...[
                      Text(
                        'Starts in',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        _getTimeUntil(),
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Amount Paid',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        '\u20B9${booking.totalAmount.toStringAsFixed(0)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),

                // Action buttons
                if (isUpcoming && booking.status != BookingStatus.inProgress)
                  _buildActionButtons()
                else if (booking.status == BookingStatus.inProgress &&
                    booking.meetLink != null)
                  _buildJoinButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build avatar widget.
  Widget _buildAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryLight.withAlpha(50),
        backgroundImage:
            expert?.avatar != null ? NetworkImage(expert!.avatar!) : null,
        child: expert?.avatar == null
            ? Text(
                expert?.initials ?? '?',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
    );
  }

  /// Build status badge.
  Widget _buildStatusBadge() {
    final (color, bgColor) = _getStatusColors();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withAlpha(50),
        ),
      ),
      child: Text(
        booking.status.label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  /// Get status colors.
  (Color, Color) _getStatusColors() {
    switch (booking.status) {
      case BookingStatus.upcoming:
        return (AppColors.success, AppColors.success.withAlpha(30));
      case BookingStatus.inProgress:
        return (AppColors.primary, AppColors.primary.withAlpha(30));
      case BookingStatus.completed:
        return (AppColors.success, AppColors.success.withAlpha(30));
      case BookingStatus.cancelled:
        return (AppColors.error, AppColors.error.withAlpha(30));
      case BookingStatus.noShow:
        return (AppColors.neutralGray, AppColors.neutralGray.withAlpha(30));
    }
  }

  /// Build info chip.
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons for upcoming sessions.
  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildIconButton(
          icon: Icons.message_outlined,
          onTap: onMessage,
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.refresh,
          onTap: onReschedule,
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.delete_outline,
          onTap: onCancel,
          isDestructive: true,
        ),
      ],
    );
  }

  /// Build icon button.
  Widget _buildIconButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return Material(
      color: Colors.white.withAlpha(180),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDestructive
                  ? AppColors.error.withAlpha(50)
                  : AppColors.border.withAlpha(128),
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDestructive ? AppColors.error : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Build join button.
  Widget _buildJoinButton() {
    return Material(
      color: AppColors.darkBrown,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onJoin,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.videocam,
                size: 18,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'Join Now',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format date for display.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';

    return DateFormat('EEE, MMM d').format(date);
  }

  /// Get time until session starts.
  String _getTimeUntil() {
    final now = DateTime.now();
    final timeParts = booking.startTime.split(':');
    final sessionStart = DateTime(
      booking.date.year,
      booking.date.month,
      booking.date.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final diff = sessionStart.difference(now);

    if (diff.isNegative) return 'Started';

    if (diff.inDays > 0) {
      return '${diff.inDays}d ${diff.inHours % 24}h';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ${diff.inMinutes % 60}m';
    } else {
      return '${diff.inMinutes}m';
    }
  }
}

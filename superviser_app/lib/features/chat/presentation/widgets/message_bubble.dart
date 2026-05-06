import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/message_model.dart';
import 'voice_message_bar.dart';

/// Message bubble widget for chat.
///
/// Displays a single message with appropriate styling based on sender.
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSender = true,
    this.onFileTap,
    this.onReply,
    this.onDelete,
    this.onLongPress,
    this.onApprove,
    this.onReject,
  });

  /// The message to display
  final MessageModel message;

  /// Whether this message is from the current user
  final bool isMe;

  /// Whether to show sender name
  final bool showSender;

  /// Called when a file attachment is tapped
  final VoidCallback? onFileTap;

  /// Called when reply is selected
  final VoidCallback? onReply;

  /// Called when delete is selected
  final VoidCallback? onDelete;

  /// Called on long press
  final VoidCallback? onLongPress;

  /// Called when the supervisor approves a pending message
  final VoidCallback? onApprove;

  /// Called when the supervisor rejects a pending message
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.timeline) {
      return _TimelineEvent(message: message);
    }

    if (message.isSystemMessage) {
      return _SystemMessage(message: message);
    }

    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 48 : 12,
        right: isMe ? 12 : 48,
        top: 4,
        bottom: 4,
      ),
      child: GestureDetector(
        onLongPress: onLongPress,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar for other users
            if (!isMe) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: _getSenderColor().withValues(alpha: 0.2),
                backgroundImage: message.senderAvatar != null
                    ? NetworkImage(message.senderAvatar!)
                    : null,
                child: message.senderAvatar == null
                    ? Text(
                        message.senderInitials,
                        style: TextStyle(
                          color: _getSenderColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
            ],
            // Message content
            Flexible(
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // Sender name
                  if (showSender && !isMe)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message.senderName ?? 'Unknown'.tr(context),
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: _getSenderColor(),
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          if (message.senderRole != null) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: _getSenderColor().withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _capitalizeRole(message.senderRole!),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: _getSenderColor(),
                                      fontSize: 10,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  // Reply preview
                  if (message.replyToContent != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isMe
                                ? Colors.white
                                : AppColors.textSecondaryLight)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: _getSenderColor(),
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        message.replyToContent!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isMe
                                  ? Colors.white70
                                  : AppColors.textSecondaryLight,
                              fontStyle: FontStyle.italic,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  // Pending approval banner
                  if (message.approvalStatus == 'pending')
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hourglass_top,
                            size: 12,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pending approval'.tr(context),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.amber.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                  // Rejected banner
                  if (message.approvalStatus == 'rejected')
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.block,
                            size: 12,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Rejected'.tr(context),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ),
                    ),
                  // Message bubble
                  Opacity(
                    opacity: message.approvalStatus == 'rejected' ? 0.5 : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // File attachment
                          if (message.hasAttachment) ...[
                            if (message.isAudioAttachment)
                              Align(
                                alignment: Alignment.center,
                                child: VoiceMessageBar(
                                  roomId: message.chatRoomId,
                                  messageId: _voiceClipId(message),
                                  audioUrl: message.fileUrl!,
                                  playIconColor:
                                      isMe ? Colors.white : AppColors.primary,
                                  progressBackgroundColor: isMe
                                      ? Colors.white.withValues(alpha: 0.35)
                                      : AppColors.surfaceLight,
                                  progressForegroundColor:
                                      isMe ? Colors.white : AppColors.primary,
                                  timeLabelColor: isMe
                                      ? Colors.white.withValues(alpha: 0.95)
                                      : AppColors.textSecondaryLight,
                                  pillBackgroundColor: isMe
                                      ? Colors.white.withValues(alpha: 0.18)
                                      : AppColors.surfaceLight,
                                ),
                              )
                            else
                              _FileAttachment(
                                message: message,
                                isMe: isMe,
                                onTap: onFileTap,
                              ),
                            if (!message.isAudioAttachment &&
                                message.content?.isNotEmpty == true)
                              const SizedBox(height: 8),
                          ],
                          // Text content
                          if (message.content?.isNotEmpty == true &&
                              !_voiceOnlyCaption(message))
                            Text(
                              message.displayContent,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: isMe
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                    fontStyle: message.isDeleted
                                        ? FontStyle.italic
                                        : null,
                                    decoration:
                                        message.approvalStatus == 'rejected'
                                            ? TextDecoration.lineThrough
                                            : null,
                                  ),
                            ),
                          // Time and status
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                message.formattedTime,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: isMe
                                          ? Colors.white60
                                          : AppColors.textSecondaryLight,
                                      fontSize: 10,
                                    ),
                              ),
                              if (message.isEdited) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(edited)'.tr(context),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: isMe
                                            ? Colors.white60
                                            : AppColors.textSecondaryLight,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  message.isRead
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 14,
                                  color: message.isRead
                                      ? Colors.lightBlueAccent
                                      : Colors.white60,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Approve / Reject buttons for pending doer messages
                  if (message.approvalStatus == 'pending' &&
                      onApprove != null &&
                      onReject != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ModerationButton(
                            icon: Icons.check_circle_outline,
                            label: 'Approve'.tr(context),
                            color: Colors.green,
                            onTap: onApprove!,
                          ),
                          const SizedBox(width: 8),
                          _ModerationButton(
                            icon: Icons.cancel_outlined,
                            label: 'Reject'.tr(context),
                            color: Colors.red,
                            onTap: onReject!,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSenderColor() {
    if (isMe) return AppColors.primary;
    switch (message.senderRole) {
      case 'client':
        return Colors.blue;
      case 'doer':
        return Colors.purple;
      case 'supervisor':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _capitalizeRole(String role) {
    return role[0].toUpperCase() + role.substring(1);
  }

  bool _voiceOnlyCaption(MessageModel msg) {
    if (!msg.isAudioAttachment) return false;
    final t = (msg.content ?? '').trim().toLowerCase();
    return t.isEmpty || t == 'voice note';
  }

  String _voiceClipId(MessageModel msg) {
    final raw = msg.id.trim();
    if (raw.isNotEmpty) return raw;
    return '${msg.chatRoomId}:${msg.fileUrl ?? ''}:${msg.createdAt.microsecondsSinceEpoch}';
  }
}

/// File attachment widget.
class _FileAttachment extends StatelessWidget {
  const _FileAttachment({
    required this.message,
    required this.isMe,
    this.onTap,
  });

  final MessageModel message;
  final bool isMe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (message.isImageAttachment) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: message.fileUrl!,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 200,
              height: 150,
              color: Colors.grey.withValues(alpha: 0.1),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 200,
              height: 150,
              color: Colors.grey.withValues(alpha: 0.2),
              child: const Icon(Icons.broken_image, size: 48),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe
              ? Colors.white.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFileIcon(),
              color: isMe ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.fileName ?? 'File'.tr(context),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isMe ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w500,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (message.fileSize != null)
                    Text(
                      _formatSize(message.fileSize!),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isMe
                                ? Colors.white70
                                : AppColors.textSecondaryLight,
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.download,
              color: isMe ? Colors.white70 : AppColors.textSecondaryLight,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    final type = message.fileType?.toLowerCase() ?? '';
    final name = message.fileName?.toLowerCase() ?? '';

    if (type.contains('pdf') || name.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    }
    if (type.contains('word') || name.endsWith('.doc') || name.endsWith('.docx')) {
      return Icons.description;
    }
    if (type.contains('excel') || name.endsWith('.xls') || name.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    return Icons.insert_drive_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

/// Timeline event widget showing project status changes.
///
/// Renders as a centered card with an icon, status label, and timestamp
/// to visually represent project milestones in the chat.
class _TimelineEvent extends StatelessWidget {
  const _TimelineEvent({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final toStatus = message.metadata?['toStatus'] as String? ?? '';
    final icon = _statusIcon(toStatus);
    final color = _statusColor(toStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
      child: Row(
        children: [
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 2,
                height: 12,
                color: color.withValues(alpha: 0.3),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              Container(
                width: 2,
                height: 12,
                color: color.withValues(alpha: 0.3),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatTimelineDate(message.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'draft':
        return Icons.note_add_rounded;
      case 'submitted':
        return Icons.send_rounded;
      case 'quoted':
        return Icons.request_quote_rounded;
      case 'paid':
        return Icons.payment_rounded;
      case 'assigned':
        return Icons.person_add_rounded;
      case 'in_progress':
        return Icons.play_circle_rounded;
      case 'under_review':
        return Icons.rate_review_rounded;
      case 'revision_requested':
        return Icons.replay_rounded;
      case 'delivered':
        return Icons.local_shipping_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'refunded':
        return Icons.currency_exchange_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'submitted':
        return Colors.blue;
      case 'quoted':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'assigned':
        return Colors.purple;
      case 'in_progress':
        return Colors.indigo;
      case 'under_review':
        return Colors.amber.shade700;
      case 'revision_requested':
        return Colors.deepOrange;
      case 'delivered':
        return Colors.teal;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.red.shade300;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatTimelineDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute';
  }
}

/// System message widget.
class _SystemMessage extends StatelessWidget {
  const _SystemMessage({required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.displayContent,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontStyle: FontStyle.italic,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/// Small button used for message moderation (approve/reject).
class _ModerationButton extends StatelessWidget {
  const _ModerationButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Date separator for message groups.
class DateSeparator extends StatelessWidget {
  const DateSeparator({
    super.key,
    required this.date,
  });

  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              date,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}

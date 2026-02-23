import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/message_model.dart';

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

  @override
  Widget build(BuildContext context) {
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
                            message.senderName ?? 'Unknown',
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
                  // Message bubble
                  Container(
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
                          _FileAttachment(
                            message: message,
                            isMe: isMe,
                            onTap: onFileTap,
                          ),
                          if (message.content?.isNotEmpty == true)
                            const SizedBox(height: 8),
                        ],
                        // Text content
                        if (message.content?.isNotEmpty == true)
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
                                '(edited)',
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
          child: Image.network(
            message.fileUrl!,
            width: 200,
            height: 150,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
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
                    message.fileName ?? 'File',
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

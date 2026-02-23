import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_room_model.dart';

/// List tile widget for displaying a chat room.
///
/// Shows project info, last message, and unread count.
class ChatRoomTile extends StatelessWidget {
  const ChatRoomTile({
    super.key,
    required this.room,
    required this.onTap,
    this.onLongPress,
  });

  /// Chat room data
  final ChatRoomModel room;

  /// Called when tile is tapped
  final VoidCallback onTap;

  /// Called when tile is long pressed
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: room.hasUnread
              ? AppColors.primary.withValues(alpha: 0.02)
              : null,
          border: Border(
            bottom: BorderSide(
              color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar/Icon
            _ChatAvatar(room: room),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.displayTitle,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: room.hasUnread
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        room.formattedLastMessageTime,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: room.hasUnread
                                  ? AppColors.primary
                                  : AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Project number and type
                  Row(
                    children: [
                      if (room.projectNumber != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            room.projectNumber!,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          room.type.displayName,
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: _getTypeColor(),
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                      if (room.isSuspended) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.block,
                          size: 14,
                          color: AppColors.error,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Last message preview
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.lastMessage ?? 'No messages yet',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: room.hasUnread
                                        ? AppColors.textPrimaryLight
                                        : AppColors.textSecondaryLight,
                                    fontWeight: room.hasUnread
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (room.hasUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount > 99
                                ? '99+'
                                : room.unreadCount.toString(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                          ),
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
    );
  }

  Color _getTypeColor() {
    switch (room.type) {
      case ChatRoomType.clientSupervisor:
      case ChatRoomType.projectUserSupervisor:
        return Colors.blue;
      case ChatRoomType.doerSupervisor:
      case ChatRoomType.projectSupervisorDoer:
        return Colors.purple;
      case ChatRoomType.group:
        return Colors.teal;
    }
  }
}

/// Chat avatar widget.
class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({required this.room});

  final ChatRoomModel room;

  @override
  Widget build(BuildContext context) {
    final color = _getAvatarColor();

    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            _getAvatarIcon(),
            color: color,
            size: 24,
          ),
        ),
        // Unread indicator
        if (room.hasUnread)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Color _getAvatarColor() {
    switch (room.type) {
      case ChatRoomType.clientSupervisor:
      case ChatRoomType.projectUserSupervisor:
        return Colors.blue;
      case ChatRoomType.doerSupervisor:
      case ChatRoomType.projectSupervisorDoer:
        return Colors.purple;
      case ChatRoomType.group:
        return Colors.teal;
    }
  }

  IconData _getAvatarIcon() {
    switch (room.type) {
      case ChatRoomType.clientSupervisor:
      case ChatRoomType.projectUserSupervisor:
        return Icons.person;
      case ChatRoomType.doerSupervisor:
      case ChatRoomType.projectSupervisorDoer:
        return Icons.edit;
      case ChatRoomType.group:
        return Icons.groups;
    }
  }
}

/// Empty state for chat list.
class ChatListEmptyState extends StatelessWidget {
  const ChatListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 72,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Conversations',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat rooms will appear here when you have active projects.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

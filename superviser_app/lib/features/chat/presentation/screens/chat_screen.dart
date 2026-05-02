import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';

/// Screen for viewing and sending messages in a chat room.
///
/// Supports real-time messaging, file attachments, and replies.
/// Standalone route — uses MeshGradientBackground.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.projectId,
  });

  /// Project ID to open chat for
  final String projectId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = ref.read(currentUserProvider)?.id;

    // Open chat room by project ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeChatProvider.notifier).openByProject(widget.projectId);
    });

    // Setup scroll controller for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Close chat room when leaving
    ref.read(activeChatProvider.notifier).closeRoom();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 100) {
      ref.read(activeChatProvider.notifier).loadMore();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeChatProvider);

    // Scroll to bottom when new messages arrive
    ref.listen<ActiveChatState>(activeChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    });

    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      opacity: 0.3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.room?.displayTitle ?? 'Chat'.tr(context),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              if (state.room?.projectNumber != null)
                Text(
                  state.room!.projectNumber!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
            ],
          ),
          actions: [
            // Suspension toggle
            if (state.room != null)
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: state.room!.isSuspended ? 'unsuspend' : 'suspend',
                    child: Row(
                      children: [
                        Icon(
                          state.room!.isSuspended ? Icons.check : Icons.block,
                          size: 20,
                          color: state.room!.isSuspended
                              ? AppColors.success
                              : AppColors.error,
                        ),
                        const SizedBox(width: 12),
                        Text(state.room!.isSuspended
                            ? 'Unsuspend Chat'.tr(context)
                            : 'Suspend Chat'.tr(context)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'info',
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 12),
                        Text('Chat Info'.tr(context)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
        body: Column(
          children: [
            // Error banner
            if (state.error != null)
              GlassContainer(
                blur: 10,
                opacity: 0.15,
                borderRadius: BorderRadius.circular(0),
                borderColor: AppColors.error.withAlpha(40),
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          ref.read(activeChatProvider.notifier).clearError(),
                      icon: Icon(Icons.close, color: AppColors.error, size: 18),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            // Messages list
            Expanded(
              child: state.isLoading && state.messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.messages.isEmpty
                      ? _EmptyChat()
                      : _MessagesList(
                          messages: state.messages,
                          currentUserId: _currentUserId,
                          scrollController: _scrollController,
                          isLoadingMore: state.isLoading,
                          hasMore: state.hasMore,
                          onReply: (message) {
                            ref
                                .read(activeChatProvider.notifier)
                                .setReplyTo(message);
                          },
                          onApprove: (messageId) {
                            ref
                                .read(activeChatProvider.notifier)
                                .approveMessage(messageId);
                          },
                          onReject: (messageId) {
                            ref
                                .read(activeChatProvider.notifier)
                                .rejectMessage(messageId);
                          },
                        ),
            ),
            // Glass message input bar
            GlassContainer(
              blur: 20,
              opacity: 0.75,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              borderColor: Colors.white.withAlpha(60),
              child: MessageInput(
                onSend: (message) async {
                  await ref.read(activeChatProvider.notifier).sendMessage(message);
                },
                replyTo: state.replyTo,
                onCancelReply: () =>
                    ref.read(activeChatProvider.notifier).clearReplyTo(),
                enabled: !state.isSuspended,
                isSending: state.isSending,
                disabledMessage:
                    state.isSuspended ? 'Chat is suspended'.tr(context) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) async {
    switch (action) {
      case 'suspend':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Suspend Chat'.tr(context)),
            content: Text(
              'Are you sure you want to suspend this chat? Participants will not be able to send messages.'.tr(context),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'.tr(context)),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                ),
                child: Text('Suspend'.tr(context)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final success = await ref
              .read(activeChatProvider.notifier)
              .suspendChat(reason: 'Suspended by supervisor');

          if (success && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chat suspended'.tr(context)),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
        break;
      case 'unsuspend':
        final success =
            await ref.read(activeChatProvider.notifier).unsuspendChat();

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Chat unsuspended'.tr(context)),
              backgroundColor: Colors.green,
            ),
          );
        }
        break;
      case 'info':
        _showChatInfo();
        break;
    }
  }

  void _showChatInfo() {
    final room = ref.read(activeChatProvider).room;
    if (room == null) return;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: false,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat Information'.tr(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              icon: Icons.folder_outlined,
              label: 'Project'.tr(context),
              value: room.projectTitle ?? 'Unknown'.tr(context),
            ),
            _InfoRow(
              icon: Icons.tag,
              label: 'Project Number'.tr(context),
              value: room.projectNumber ?? 'N/A',
            ),
            _InfoRow(
              icon: Icons.group_outlined,
              label: 'Type'.tr(context),
              value: room.type.displayName,
            ),
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Participants'.tr(context),
              value: '${room.participants?.length ?? 0} ${'people'.tr(context)}',
            ),
            if (room.isSuspended)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat Suspended'.tr(context),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          if (room.suspensionReason != null)
                            Text(
                              room.suspensionReason!,
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// Messages list widget.
class _MessagesList extends StatelessWidget {
  const _MessagesList({
    required this.messages,
    required this.currentUserId,
    required this.scrollController,
    required this.isLoadingMore,
    required this.hasMore,
    required this.onReply,
    this.onApprove,
    this.onReject,
  });

  final List messages;
  final String? currentUserId;
  final ScrollController scrollController;
  final bool isLoadingMore;
  final bool hasMore;
  final void Function(dynamic message) onReply;
  final void Function(String messageId)? onApprove;
  final void Function(String messageId)? onReject;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: messages.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final adjustedIndex = isLoadingMore ? index - 1 : index;
        final message = messages[adjustedIndex];
        final isMe = message.senderId == currentUserId;

        // Check if we should show date separator
        final showDate = adjustedIndex == 0 ||
            message.formattedDate !=
                messages[adjustedIndex - 1].formattedDate;

        // Check if we should show sender name
        final showSender = adjustedIndex == 0 ||
            message.senderId != messages[adjustedIndex - 1].senderId ||
            showDate;

        return Column(
          children: [
            if (showDate) DateSeparator(date: message.formattedDate),
            MessageBubble(
              message: message,
              isMe: isMe,
              showSender: showSender,
              onReply: () => onReply(message),
              onApprove: message.approvalStatus == 'pending' && onApprove != null
                  ? () => onApprove!(message.id)
                  : null,
              onReject: message.approvalStatus == 'pending' && onReject != null
                  ? () => onReject!(message.id)
                  : null,
            ),
          ],
        );
      },
    );
  }
}

/// Empty chat state.
class _EmptyChat extends StatelessWidget {
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
              'No messages yet'.tr(context),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation!'.tr(context),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Info row widget for chat info sheet.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondaryLight),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

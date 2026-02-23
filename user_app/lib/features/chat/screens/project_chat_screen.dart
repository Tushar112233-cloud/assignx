import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide PresenceEvent;

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/chat_model.dart';
import '../../../providers/chat_provider.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_presence_banner.dart';
import '../widgets/message_approval_badge.dart';
import '../widgets/message_status_indicator.dart';

/// Chat screen colors matching the Coffee Bean Design System.
class _ChatColors {
  static const scaffoldBackground = Color(0xFFFAF8F5);
  static const headerGradientStart = Color(0xFF3D3228);
  static const headerGradientMiddle = Color(0xFF54442B);
  static const headerGradientEnd = Color(0xFF765341);
  static const warmAccent = Color(0xFF765341);
  static const lightAccent = Color(0xFF9D7B65);
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B5D4D);
  static const mutedText = Color(0xFF8F826F);
  static const borderColor = Color(0xFFDDD7CD);
  static const creamBackground = Color(0xFFF5F0E8);

  /// Header gradient for app bar
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [headerGradientStart, headerGradientMiddle, headerGradientEnd],
  );

  /// Background gradient for the chat screen
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFEFDFB), Color(0xFFFAF9F7)],
  );
}

/// User role enumeration for permission checks.
enum UserRole {
  /// Client who submitted the project
  client,

  /// Doer who is working on the project
  doer,

  /// Supervisor who moderates the chat
  supervisor,
}

/// System message types for project timeline events.
enum SystemMessageType {
  projectCreated,
  doerAssigned,
  supervisorJoined,
  paymentCompleted,
  deliverySubmitted,
  revisionRequested,
  projectCompleted,
  milestone,
  statusChange,
}

/// Modern project chat screen with Coffee Bean theme, glass morphism, animations,
/// typing indicators, presence, system messages, and message approval workflow.
class ProjectChatScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String? projectTitle;

  /// The current user's role in the project.
  final UserRole userRole;

  /// Whether the current user is a supervisor.
  final bool isSupervisor;

  const ProjectChatScreen({
    super.key,
    required this.projectId,
    this.projectTitle,
    this.userRole = UserRole.client,
    this.isSupervisor = false,
  });

  @override
  ConsumerState<ProjectChatScreen> createState() => _ProjectChatScreenState();
}

class _ProjectChatScreenState extends ConsumerState<ProjectChatScreen>
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _roomId;
  late AnimationController _animationController;

  // Typing indicator state
  bool _isTyping = false;
  Timer? _typingTimer;
  String? _typingUserName;

  // Presence state
  final StreamController<PresenceEvent> _presenceStreamController =
      StreamController<PresenceEvent>.broadcast();
  final List<OnlineUser> _onlineUsers = [];
  RealtimeChannel? _presenceChannel;
  RealtimeChannel? _typingChannel;

  /// Effective role considering supervisor flag.
  UserRole get effectiveRole =>
      widget.isSupervisor ? UserRole.supervisor : widget.userRole;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    _typingTimer?.cancel();
    _presenceChannel?.unsubscribe();
    _typingChannel?.unsubscribe();
    _presenceStreamController.close();
    super.dispose();
  }

  void _onTextChanged() {
    if (_messageController.text.isNotEmpty && !_isTyping) {
      _startTyping();
    } else if (_messageController.text.isEmpty && _isTyping) {
      _stopTyping();
    }
  }

  void _startTyping() {
    setState(() => _isTyping = true);
    _broadcastTyping(true);
    _resetTypingTimer();
  }

  void _stopTyping() {
    setState(() => _isTyping = false);
    _broadcastTyping(false);
    _typingTimer?.cancel();
  }

  void _resetTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), _stopTyping);
  }

  void _broadcastTyping(bool isTyping) {
    // Broadcast typing status via Supabase Realtime
    if (_roomId != null) {
      final channel = SupabaseConfig.client.channel('typing:$_roomId');
      channel.sendBroadcastMessage(
        event: 'typing',
        payload: {
          'userId': SupabaseConfig.currentUser?.id,
          'name': SupabaseConfig.currentUser?.userMetadata?['full_name'] ?? 'User',
          'isTyping': isTyping,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 100 &&
        _roomId != null) {
      ref.read(chatNotifierProvider(_roomId!).notifier).loadMoreMessages();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _roomId == null) return;

    _stopTyping();
    _messageController.clear();
    await ref.read(chatNotifierProvider(_roomId!).notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _handleAttachment() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('File attachments coming soon'),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _subscribeToPresence(String roomId) {
    // Unsubscribe from previous channels if switching rooms
    _presenceChannel?.unsubscribe();
    _typingChannel?.unsubscribe();

    final channel = SupabaseConfig.client.channel('presence:$roomId');
    _presenceChannel = channel;

    channel.onPresenceSync((payload) {
      final presenceState = channel.presenceState();
      final users = <OnlineUser>[];

      // presenceState is List<SinglePresenceState>
      for (final singleState in presenceState) {
        for (final presence in singleState.presences) {
          final data = presence.payload;
          if (!users.any((u) => u.id == data['id'])) {
            users.add(OnlineUser.fromJson(data));
          }
        }
      }

      if (mounted) {
        setState(() {
          _onlineUsers.clear();
          _onlineUsers.addAll(users);
        });
      }
    });

    channel.onPresenceJoin((payload) {
      final newPresences = payload.newPresences;
      for (final presence in newPresences) {
        final data = presence.payload;
        if (data['id'] != SupabaseConfig.currentUser?.id) {
          _presenceStreamController.add(PresenceEvent(
            id: PresenceEvent.generateId(),
            type: PresenceEventType.joined,
            userName: data['name'] as String? ?? 'Unknown',
            userRole: data['role'] as String?,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
        }
      }
    });

    channel.onPresenceLeave((payload) {
      final leftPresences = payload.leftPresences;
      for (final presence in leftPresences) {
        final data = presence.payload;
        if (data['id'] != SupabaseConfig.currentUser?.id) {
          _presenceStreamController.add(PresenceEvent(
            id: PresenceEvent.generateId(),
            type: PresenceEventType.left,
            userName: data['name'] as String? ?? 'Unknown',
            userRole: data['role'] as String?,
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ));
        }
      }
    });

    channel.subscribe((status, error) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await channel.track({
          'id': SupabaseConfig.currentUser?.id,
          'name': SupabaseConfig.currentUser?.userMetadata?['full_name'] ?? 'User',
          'online_at': DateTime.now().toIso8601String(),
        });
      }
    });

    // Subscribe to typing events
    final typingChannel = SupabaseConfig.client.channel('typing:$roomId');
    _typingChannel = typingChannel;
    typingChannel.onBroadcast(
      event: 'typing',
      callback: (payload) {
        final data = payload as Map<String, dynamic>;
        if (data['userId'] != SupabaseConfig.currentUser?.id) {
          if (mounted) {
            setState(() {
              if (data['isTyping'] == true) {
                _typingUserName = data['name'] as String?;
              } else {
                _typingUserName = null;
              }
            });
          }
        }
      },
    );
    typingChannel.subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final chatRoomAsync = ref.watch(projectChatRoomProvider(widget.projectId));

    return chatRoomAsync.when(
      data: (room) {
        if (_roomId != room.id) {
          _roomId = room.id;
          _subscribeToPresence(room.id);
        }
        return _ChatContent(
          roomId: room.id,
          projectId: widget.projectId,
          projectTitle: widget.projectTitle,
          messageController: _messageController,
          scrollController: _scrollController,
          onSend: _sendMessage,
          onAttachment: _handleAttachment,
          onScrollToBottom: _scrollToBottom,
          typingUserName: _typingUserName,
          onlineUsers: _onlineUsers,
          presenceStream: _presenceStreamController.stream,
          userRole: effectiveRole,
        );
      },
      loading: () => Scaffold(
        body: _buildGradientBackground(
          child: const Center(
            child: CircularProgressIndicator(color: _ChatColors.warmAccent),
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        body: _buildGradientBackground(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load chat',
                  style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.invalidate(projectChatRoomProvider(widget.projectId)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBackground({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: _ChatColors.backgroundGradient,
      ),
      child: child,
    );
  }
}

class _ChatContent extends ConsumerStatefulWidget {
  final String roomId;
  final String projectId;
  final String? projectTitle;
  final TextEditingController messageController;
  final ScrollController scrollController;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final VoidCallback onScrollToBottom;
  final String? typingUserName;
  final List<OnlineUser> onlineUsers;
  final Stream<PresenceEvent> presenceStream;
  final UserRole userRole;

  const _ChatContent({
    required this.roomId,
    required this.projectId,
    this.projectTitle,
    required this.messageController,
    required this.scrollController,
    required this.onSend,
    required this.onAttachment,
    required this.onScrollToBottom,
    this.typingUserName,
    required this.onlineUsers,
    required this.presenceStream,
    required this.userRole,
  });

  @override
  ConsumerState<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends ConsumerState<_ChatContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _messageAnimController;

  @override
  void initState() {
    super.initState();
    _messageAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onScrollToBottom();
      _messageAnimController.forward();
    });
  }

  @override
  void dispose() {
    _messageAnimController.dispose();
    super.dispose();
  }

  /// Check if a message is visible to the current user.
  bool _isMessageVisible(ChatMessage message, String currentUserId) {
    // Supervisors see all messages
    if (widget.userRole == UserRole.supervisor) {
      return true;
    }

    // Users always see their own messages
    if (message.senderId == currentUserId) {
      return true;
    }

    // For non-supervisor users, only show approved messages
    final status = MessageApprovalStatusExtension.fromString(
      message.approvalStatus,
    );

    // If no approval status set (legacy messages), show them
    if (message.approvalStatus == null) {
      return true;
    }

    return status == MessageApprovalStatus.approved;
  }

  /// Count pending messages for supervisor banner.
  int _countPendingMessages(List<ChatMessage> messages) {
    if (widget.userRole != UserRole.supervisor) return 0;

    return messages.where((msg) {
      final status = MessageApprovalStatusExtension.fromString(
        msg.approvalStatus,
      );
      return status == MessageApprovalStatus.pending;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider(widget.roomId));
    final currentUserId = SupabaseConfig.currentUser?.id ?? '';

    // Filter visible messages based on role
    final visibleMessages = chatState.messages
        .where((msg) => _isMessageVisible(msg, currentUserId))
        .toList();

    // Count pending for supervisor
    final pendingCount = _countPendingMessages(chatState.messages);

    ref.listen<ChatState>(chatNotifierProvider(widget.roomId), (prev, next) {
      if (prev != null && next.messages.length > prev.messages.length) {
        widget.onScrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: _ChatColors.scaffoldBackground,
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: _ChatColors.backgroundGradient,
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Modern App Bar
                _buildAppBar(context),

                // Project context banner with online users
                _buildContextBanner(),

                // Pending messages banner for supervisors
                if (widget.userRole == UserRole.supervisor && pendingCount > 0)
                  PendingApprovalBanner(pendingCount: pendingCount),

                // Messages list
                Expanded(
                  child: chatState.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: _ChatColors.warmAccent),
                        )
                      : visibleMessages.isEmpty
                          ? _EmptyChat()
                          : ListView.builder(
                              controller: widget.scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: visibleMessages.length +
                                  (chatState.isLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (chatState.isLoadingMore && index == 0) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }

                                final messageIndex =
                                    chatState.isLoadingMore ? index - 1 : index;
                                final message = visibleMessages[messageIndex];
                                final showDate = messageIndex == 0 ||
                                    !_isSameDay(
                                      visibleMessages[messageIndex - 1].createdAt,
                                      message.createdAt,
                                    );

                                return Column(
                                  key: ValueKey(message.id),
                                  children: [
                                    if (showDate)
                                      _DateSeparator(date: message.createdAt),
                                    _buildAnimatedMessage(
                                      index: messageIndex,
                                      child: _MessageBubble(
                                        message: message,
                                        isMe: message.isMe(currentUserId),
                                        userRole: widget.userRole,
                                        currentUserId: currentUserId,
                                        roomId: widget.roomId,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                ),

                // Typing indicator
                TypingIndicator(
                  typerName: widget.typingUserName,
                  isVisible: widget.typingUserName != null,
                ),

                // Input area
                _ChatInputArea(
                  controller: widget.messageController,
                  isSending: chatState.isSending,
                  onSend: widget.onSend,
                  onAttachment: widget.onAttachment,
                  showApprovalNote: widget.userRole != UserRole.supervisor,
                ),
              ],
            ),

            // Presence banners overlay
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 0,
              right: 0,
              child: ChatPresenceStack(
                eventStream: widget.presenceStream,
                maxBanners: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            left: 8,
            right: 8,
            bottom: 12,
          ),
          decoration: BoxDecoration(
            gradient: _ChatColors.headerGradient,
            boxShadow: [
              BoxShadow(
                color: _ChatColors.headerGradientStart.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Project Supervisor',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.userRole == UserRole.supervisor) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.shield_outlined,
                                  size: 10,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Supervisor',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 8,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.projectTitle != null)
                      Text(
                        widget.projectTitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Online users indicator in app bar
              if (widget.onlineUsers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: OnlineUsersIndicator(
                    users: widget.onlineUsers,
                    maxAvatars: 2,
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () => _showOptionsMenu(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContextBanner() {
    return ClipRRect(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _ChatColors.creamBackground,
          border: Border(
            bottom: BorderSide(
              color: _ChatColors.borderColor,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: _ChatColors.warmAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Chat for Project ${widget.projectId.substring(0, 8).toUpperCase()}',
                style: AppTextStyles.caption.copyWith(
                  color: _ChatColors.secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedMessage({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: _ChatColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.search, color: _ChatColors.warmAccent),
                title: Text(
                  'Search Messages',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _ChatColors.primaryText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search coming soon')),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.notifications_off_outlined,
                  color: _ChatColors.warmAccent,
                ),
                title: Text(
                  'Mute Notifications',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _ChatColors.primaryText,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mute coming soon')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _EmptyChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _ChatColors.creamBackground,
              shape: BoxShape.circle,
              border: Border.all(
                color: _ChatColors.borderColor,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: _ChatColors.lightAccent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No messages yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: _ChatColors.primaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start the conversation',
            style: AppTextStyles.bodyMedium.copyWith(
              color: _ChatColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatInputArea extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final bool showApprovalNote;

  const _ChatInputArea({
    required this.controller,
    required this.isSending,
    required this.onSend,
    required this.onAttachment,
    this.showApprovalNote = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: showApprovalNote ? 8 : 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: _ChatColors.cardBackground,
        border: Border(
          top: BorderSide(
            color: _ChatColors.borderColor,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Approval note for non-supervisor users
          if (showApprovalNote)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Messages are reviewed by supervisor before delivery',
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10,
                  color: _ChatColors.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          Row(
            children: [
              // Attachment button
              Container(
                decoration: BoxDecoration(
                  color: _ChatColors.creamBackground,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.attach_file, color: _ChatColors.warmAccent),
                  onPressed: onAttachment,
                ),
              ),

              const SizedBox(width: 8),

              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _ChatColors.creamBackground,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: _ChatColors.borderColor,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _ChatColors.primaryText,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: _ChatColors.mutedText,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 4,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => onSend(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _ChatColors.warmAccent,
                      _ChatColors.lightAccent,
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _ChatColors.warmAccent.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: isSending
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 22, color: Colors.white),
                  onPressed: isSending ? null : onSend,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: _ChatColors.borderColor,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _ChatColors.creamBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _ChatColors.borderColor,
                ),
              ),
              child: Text(
                _formatDate(date),
                style: AppTextStyles.caption.copyWith(
                  color: _ChatColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: _ChatColors.borderColor,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _MessageBubble extends ConsumerWidget {
  final ChatMessage message;
  final bool isMe;
  final UserRole userRole;
  final String currentUserId;
  final String roomId;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.userRole,
    required this.currentUserId,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Parse approval status
    final approvalStatus = MessageApprovalStatusExtension.fromString(
      message.approvalStatus,
    );

    // Determine what to show
    final showApprovalBadge =
        message.approvalStatus != null &&
        approvalStatus != MessageApprovalStatus.approved;

    final showSupervisorActions =
        userRole == UserRole.supervisor &&
        approvalStatus == MessageApprovalStatus.pending;

    final showRejectionReason =
        isMe &&
        approvalStatus == MessageApprovalStatus.rejected &&
        message.rejectionReason != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Message bubble with approval badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMe
                        ? _ChatColors.warmAccent
                        : _ChatColors.cardBackground,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isMe ? 20 : 6),
                      bottomRight: Radius.circular(isMe ? 6 : 20),
                    ),
                    border: Border.all(
                      color: isMe
                          ? _ChatColors.warmAccent
                          : _ChatColors.borderColor,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe && message.sender != null) ...[
                        Text(
                          message.sender!.fullName,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _ChatColors.warmAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],

                      // Message content
                      Text(
                        message.content,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isMe ? Colors.white : _ChatColors.primaryText,
                        ),
                      ),

                      // File attachment
                      if (message.fileUrl != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.2)
                                : _ChatColors.creamBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 16,
                                color: isMe ? Colors.white : _ChatColors.warmAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Attachment',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 12,
                                  color: isMe ? Colors.white : _ChatColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Timestamp and status
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: AppTextStyles.caption.copyWith(
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : _ChatColors.mutedText,
                              fontSize: 10,
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.readBy.isNotEmpty
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                          // Pending status text for sender
                          if (isMe &&
                              approvalStatus == MessageApprovalStatus.pending) ...[
                            const SizedBox(width: 4),
                            Text(
                              '• Pending',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.warning,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Approval badge positioned at bottom-right
                if (showApprovalBadge)
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: MessageApprovalBadge(
                      status: approvalStatus,
                      approvedBy: message.approverName,
                      approvedAt: message.approvedAt,
                      rejectionReason: message.rejectionReason,
                      size: MessageApprovalBadgeSize.small,
                    ),
                  ),
              ],
            ),

            // Supervisor action buttons
            if (showSupervisorActions) ...[
              const SizedBox(height: 4),
              _SupervisorActions(
                messageId: message.id,
                roomId: roomId,
                onAction: () {
                  // Refresh will happen via realtime subscription
                },
              ),
            ],

            // Rejection reason for sender
            if (showRejectionReason) ...[
              const SizedBox(height: 4),
              MessageStatusIndicator(
                status: MessageApprovalStatus.rejected,
                rejectionReason: message.rejectionReason,
                compact: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

/// Supervisor action buttons for approving/rejecting messages.
class _SupervisorActions extends ConsumerStatefulWidget {
  final String messageId;
  final String roomId;
  final VoidCallback? onAction;

  const _SupervisorActions({
    required this.messageId,
    required this.roomId,
    this.onAction,
  });

  @override
  ConsumerState<_SupervisorActions> createState() => _SupervisorActionsState();
}

class _SupervisorActionsState extends ConsumerState<_SupervisorActions> {
  bool _isApproving = false;
  bool _isRejecting = false;

  Future<void> _handleApprove() async {
    if (_isApproving) return;
    setState(() => _isApproving = true);

    try {
      // Call approval action
      await ref
          .read(chatNotifierProvider(widget.roomId).notifier)
          .approveMessage(widget.messageId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message approved'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      widget.onAction?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to approve: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isApproving = false);
      }
    }
  }

  void _showRejectDialog() {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(context);
              await _handleReject(reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReject(String reason) async {
    if (_isRejecting) return;
    setState(() => _isRejecting = true);

    try {
      await ref
          .read(chatNotifierProvider(widget.roomId).notifier)
          .rejectMessage(widget.messageId, reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Message rejected'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      widget.onAction?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRejecting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Approve button
        _ActionButton(
          icon: Icons.check,
          color: AppColors.success,
          isLoading: _isApproving,
          onPressed: _handleApprove,
          tooltip: 'Approve',
        ),
        const SizedBox(width: 4),
        // Reject button
        _ActionButton(
          icon: Icons.close,
          color: AppColors.error,
          isLoading: _isRejecting,
          onPressed: _showRejectDialog,
          tooltip: 'Reject',
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onPressed;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

/// Extension to add approval-related fields to ChatMessage.
extension ChatMessageApprovalExtension on ChatMessage {
  /// Get approval status string from the message's moderation status.
  String? get approvalStatus {
    switch (status) {
      case MessageStatus.pending:
        return 'pending';
      case MessageStatus.approved:
        return 'approved';
      case MessageStatus.rejected:
        return 'rejected';
      case MessageStatus.flagged:
        return 'pending';
    }
  }

  /// Get approver name (from message metadata if available).
  String? get approverName => null;

  /// Get approved at timestamp (from message metadata if available).
  DateTime? get approvedAt => null;

  /// Get rejection reason (from message metadata if available).
  String? get rejectionReason => null;
}

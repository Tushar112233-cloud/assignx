import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/chat_model.dart';
import '../data/repositories/chat_repository.dart';
import 'auth_provider.dart';

/// Provider for chat repository instance.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repository = ChatRepository();
  ref.onDispose(() => repository.dispose());
  return repository;
});

/// Provider for getting/creating a project chat room.
final projectChatRoomProvider =
    FutureProvider.autoDispose.family<ChatRoom, String>((ref, projectId) async {
  final repository = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return repository.getOrCreateProjectChatRoom(projectId, user.id);
});

/// Provider for chat messages in a room.
final chatMessagesProvider =
    FutureProvider.family<List<ChatMessage>, String>((ref, roomId) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(roomId);
});

/// Stream provider for real-time messages in a room.
final chatMessageStreamProvider =
    StreamProvider.family<ChatMessage, String>((ref, roomId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.subscribeToRoom(roomId);
});

/// Provider for total unread message count.
final totalUnreadCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) return 0;

  return repository.getTotalUnreadCount(user.id);
});

/// Notifier for managing chat state and actions.
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String roomId;
  final String userId;
  final String? projectId;
  StreamSubscription<ChatMessage>? _subscription;

  ChatNotifier({
    required ChatRepository repository,
    required this.roomId,
    required this.userId,
    this.projectId,
  })  : _repository = repository,
        super(const ChatState()) {
    _initialize();
  }

  /// Deduplicates a list of messages by ID, keeping the last occurrence.
  List<ChatMessage> _dedup(List<ChatMessage> msgs) {
    final seen = <String>{};
    final result = <ChatMessage>[];
    // Iterate in reverse so we keep the latest version of each message
    for (var i = msgs.length - 1; i >= 0; i--) {
      if (seen.add(msgs[i].id)) {
        result.add(msgs[i]);
      }
    }
    return result.reversed.toList();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load initial messages and timeline events in parallel
      final messagesFuture = _repository.getMessages(roomId);
      final timelineFuture = projectId != null
          ? _repository.getProjectTimeline(projectId!)
          : Future.value(<Map<String, dynamic>>[]);

      final results = await Future.wait([messagesFuture, timelineFuture]);
      final messages = _dedup(results[0] as List<ChatMessage>);
      final timelineRaw = results[1] as List<Map<String, dynamic>>;

      final timelineEvents = timelineRaw
          .map((e) => TimelineEvent.fromJson(e))
          .toList();

      state = state.copyWith(
        messages: messages,
        timelineEvents: timelineEvents,
        isLoading: false,
      );

      // Mark as read
      await _repository.markAsRead(roomId, userId);

      // Subscribe to new messages
      _subscription = _repository.subscribeToRoom(roomId).listen((message) {
        // Deduplicate: skip if message id already exists
        if (state.messages.any((m) => m.id == message.id)) return;

        state = state.copyWith(
          messages: [...state.messages, message],
        );

        // Mark as read if not from current user
        if (message.senderId != userId) {
          _repository.markAsRead(roomId, userId);
        }
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Sends a message to the chat room.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    state = state.copyWith(isSending: true);

    try {
      final message = await _repository.sendMessage(roomId, userId, content);

      // Add message with sender info
      final messageWithSender = message.copyWith(
        sender: ChatSender(
          id: userId,
          fullName: 'You',
        ),
      );

      state = state.copyWith(
        messages: _dedup([...state.messages, messageWithSender]),
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  /// Sends a voice note/audio file to the chat room.
  Future<void> sendVoiceMessage(String filePath) async {
    state = state.copyWith(isSending: true);
    try {
      final message = await _repository.sendFileMessage(
        roomId,
        filePath,
        content: 'Voice note',
      );

      final messageWithSender = message.copyWith(
        sender: ChatSender(
          id: userId,
          fullName: 'You',
        ),
      );

      state = state.copyWith(
        messages: _dedup([...state.messages, messageWithSender]),
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  /// Loads more messages (pagination).
  Future<void> loadMoreMessages() async {
    if (state.messages.isEmpty || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final oldestMessage = state.messages.first;
      final olderMessages = await _repository.getMessages(
        roomId,
        before: oldestMessage.createdAt.toIso8601String(),
      );

      // Merge and deduplicate
      state = state.copyWith(
        messages: _dedup([...olderMessages, ...state.messages]),
        isLoadingMore: false,
        hasMoreMessages: olderMessages.isNotEmpty,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Approves a pending message (supervisor action).
  Future<void> approveMessage(String messageId) async {
    try {
      await _repository.approveMessage(messageId);

      // Update message status in local state
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(status: MessageStatus.approved);
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Rejects a pending message (supervisor action).
  Future<void> rejectMessage(String messageId, String? reason) async {
    try {
      await _repository.rejectMessage(messageId, reason);

      // Update message status in local state
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(status: MessageStatus.rejected);
        }
        return msg;
      }).toList();

      state = state.copyWith(messages: updatedMessages);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// A single timeline event from the project's status history.
class TimelineEvent {
  final String fromStatus;
  final String toStatus;
  final String? changedBy;
  final String? changedByName;
  final String? notes;
  final DateTime createdAt;

  const TimelineEvent({
    required this.fromStatus,
    required this.toStatus,
    this.changedBy,
    this.changedByName,
    this.notes,
    required this.createdAt,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    final createdStr = (json['created_at'] ?? json['createdAt'] ?? '').toString();
    return TimelineEvent(
      fromStatus: (json['from_status'] ?? json['fromStatus'] ?? '').toString(),
      toStatus: (json['to_status'] ?? json['toStatus'] ?? '').toString(),
      changedBy: (json['changed_by'] ?? json['changedBy'])?.toString(),
      changedByName: (json['changed_by_name'] ?? json['changedByName'])?.toString(),
      notes: (json['notes'])?.toString(),
      createdAt: DateTime.tryParse(createdStr) ?? DateTime.now(),
    );
  }
}

/// A union type representing either a chat message or a timeline event in
/// the combined chat stream. Used by the ListView to render both types.
class ChatStreamItem {
  final ChatMessage? message;
  final TimelineEvent? event;
  final DateTime timestamp;

  ChatStreamItem.fromMessage(ChatMessage msg)
      : message = msg,
        event = null,
        timestamp = msg.createdAt;

  ChatStreamItem.fromEvent(TimelineEvent evt)
      : message = null,
        event = evt,
        timestamp = evt.createdAt;

  bool get isMessage => message != null;
  bool get isEvent => event != null;
}

/// State class for chat.
class ChatState {
  final List<ChatMessage> messages;
  final List<TimelineEvent> timelineEvents;
  final bool isLoading;
  final bool isSending;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.timelineEvents = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<TimelineEvent>? timelineEvents,
    bool? isLoading,
    bool? isSending,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      timelineEvents: timelineEvents ?? this.timelineEvents,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      error: error,
    );
  }
}

/// Parameter type for the chat notifier provider.
/// Uses a record to pass both roomId and optional projectId.
typedef ChatNotifierParams = ({String roomId, String? projectId});

/// Provider for chat notifier with room context.
final chatNotifierProvider =
    StateNotifierProvider.autoDispose.family<ChatNotifier, ChatState, ChatNotifierParams>(
        (ref, params) {
  final repository = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return ChatNotifier(
    repository: repository,
    roomId: params.roomId,
    userId: user.id,
    projectId: params.projectId,
  );
});

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
  StreamSubscription<ChatMessage>? _subscription;

  ChatNotifier({
    required ChatRepository repository,
    required this.roomId,
    required this.userId,
  })  : _repository = repository,
        super(const ChatState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);

    try {
      // Load initial messages
      final messages = await _repository.getMessages(roomId);
      state = state.copyWith(
        messages: messages,
        isLoading: false,
      );

      // Mark as read
      await _repository.markAsRead(roomId, userId);

      // Subscribe to new messages
      _subscription = _repository.subscribeToRoom(roomId).listen((message) {
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
        messages: [...state.messages, messageWithSender],
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

      state = state.copyWith(
        messages: [...olderMessages, ...state.messages],
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

/// State class for chat.
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isSending;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isSending,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      error: error,
    );
  }
}

/// Provider for chat notifier with room context.
final chatNotifierProvider =
    StateNotifierProvider.autoDispose.family<ChatNotifier, ChatState, String>(
        (ref, roomId) {
  final repository = ref.watch(chatRepositoryProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    throw Exception('User not authenticated');
  }

  return ChatNotifier(
    repository: repository,
    roomId: roomId,
    userId: user.id,
  );
});

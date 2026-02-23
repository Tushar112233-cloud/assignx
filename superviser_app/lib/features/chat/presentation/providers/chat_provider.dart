import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/chat_room_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository.dart';

/// State for chat rooms list.
class ChatRoomsState {
  const ChatRoomsState({
    this.chatRooms = const [],
    this.isLoading = false,
    this.error,
  });

  /// List of chat rooms
  final List<ChatRoomModel> chatRooms;

  /// Whether data is loading
  final bool isLoading;

  /// Error message
  final String? error;

  ChatRoomsState copyWith({
    List<ChatRoomModel>? chatRooms,
    bool? isLoading,
    String? error,
  }) {
    return ChatRoomsState(
      chatRooms: chatRooms ?? this.chatRooms,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Total unread count across all rooms.
  int get totalUnread =>
      chatRooms.fold(0, (sum, room) => sum + room.unreadCount);

  /// Chat rooms with unread messages.
  List<ChatRoomModel> get unreadRooms =>
      chatRooms.where((r) => r.hasUnread).toList();
}

/// Notifier for chat rooms list.
class ChatRoomsNotifier extends StateNotifier<ChatRoomsState> {
  ChatRoomsNotifier(this._repository) : super(const ChatRoomsState()) {
    loadChatRooms();
  }

  final ChatRepository _repository;

  /// Loads all chat rooms.
  Future<void> loadChatRooms() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rooms = await _repository.getChatRooms();
      state = state.copyWith(
        chatRooms: rooms,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load chats: $e',
      );
    }
  }

  /// Refreshes chat rooms.
  Future<void> refresh() async {
    await loadChatRooms();
  }

  /// Clears error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for chat rooms.
final chatRoomsProvider =
    StateNotifierProvider<ChatRoomsNotifier, ChatRoomsState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatRoomsNotifier(repository);
});

// ============================================================================
// Active Chat Provider
// ============================================================================

/// State for an active chat conversation.
class ActiveChatState {
  const ActiveChatState({
    this.room,
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.replyTo,
    this.hasMore = true,
  });

  /// Current chat room
  final ChatRoomModel? room;

  /// Messages in the chat
  final List<MessageModel> messages;

  /// Whether messages are loading
  final bool isLoading;

  /// Whether a message is being sent
  final bool isSending;

  /// Error message
  final String? error;

  /// Message being replied to
  final MessageModel? replyTo;

  /// Whether there are more messages to load
  final bool hasMore;

  ActiveChatState copyWith({
    ChatRoomModel? room,
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    MessageModel? replyTo,
    bool? hasMore,
    bool clearReplyTo = false,
  }) {
    return ActiveChatState(
      room: room ?? this.room,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
      replyTo: clearReplyTo ? null : (replyTo ?? this.replyTo),
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Whether chat is suspended.
  bool get isSuspended => room?.isSuspended ?? false;

  /// Oldest message for pagination.
  MessageModel? get oldestMessage => messages.isNotEmpty ? messages.first : null;
}

/// Notifier for active chat.
class ActiveChatNotifier extends StateNotifier<ActiveChatState> {
  ActiveChatNotifier(this._repository) : super(const ActiveChatState());

  final ChatRepository _repository;
  StreamSubscription? _messagesSubscription;

  /// Opens a chat room.
  Future<void> openRoom(String roomId) async {
    state = state.copyWith(isLoading: true, error: null, messages: []);

    try {
      final room = await _repository.getChatRoom(roomId);
      final messages = await _repository.getMessages(roomId);

      state = state.copyWith(
        room: room,
        messages: messages,
        isLoading: false,
        hasMore: messages.length >= 50,
      );

      // Mark as read
      await _repository.markAsRead(roomId);

      // Subscribe to real-time updates
      _subscribeToMessages(roomId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to open chat: $e',
      );
    }
  }

  /// Opens chat by project ID.
  Future<void> openByProject(String projectId) async {
    state = state.copyWith(isLoading: true, error: null, messages: []);

    try {
      final room = await _repository.getChatRoomByProject(projectId);
      if (room != null) {
        await openRoom(room.id);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Chat room not found',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to open chat: $e',
      );
    }
  }

  /// Subscribes to real-time message updates.
  void _subscribeToMessages(String roomId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.watchMessages(roomId).listen(
      (messages) {
        state = state.copyWith(messages: messages);
      },
      onError: (e) {
        // Handle stream error silently
      },
    );
  }

  /// Loads more messages (pagination).
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.oldestMessage == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final olderMessages = await _repository.getMessages(
        state.room!.id,
        before: state.oldestMessage!.createdAt,
      );

      state = state.copyWith(
        messages: [...olderMessages, ...state.messages],
        isLoading: false,
        hasMore: olderMessages.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Sends a text message.
  Future<bool> sendMessage(String content) async {
    if (state.room == null || content.trim().isEmpty) return false;
    if (state.isSuspended) return false;

    state = state.copyWith(isSending: true, error: null);

    try {
      final message = await _repository.sendMessage(
        roomId: state.room!.id,
        content: content.trim(),
        replyToId: state.replyTo?.id,
      );

      if (message != null) {
        state = state.copyWith(
          messages: [...state.messages, message],
          isSending: false,
          clearReplyTo: true,
        );
        return true;
      }

      state = state.copyWith(isSending: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send message: $e',
      );
      return false;
    }
  }

  /// Sends an attachment from local file path.
  ///
  /// This uploads the file to Supabase storage first, then sends as a message.
  Future<bool> sendAttachment(String filePath, String type) async {
    if (state.room == null) return false;
    if (state.isSuspended) return false;

    state = state.copyWith(isSending: true, error: null);

    try {
      // Read the file
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found');
      }

      final fileBytes = await file.readAsBytes();
      final fileName = filePath.split('/').last;
      final fileExtension = fileName.split('.').last.toLowerCase();

      // Validate file size (max 10MB)
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileBytes.length > maxSize) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Generate unique storage path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final roomId = state.room!.id;
      final storagePath = '$roomId/${timestamp}_$fileName';

      // Upload to Supabase storage
      final supabase = Supabase.instance.client;
      await supabase.storage.from('chat-files').uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: FileOptions(
          contentType: _getMimeType(fileExtension),
          upsert: true,
        ),
      );

      // Get public URL
      final fileUrl = supabase.storage
          .from('chat-files')
          .getPublicUrl(storagePath);

      // Determine message type based on file type
      final messageType = _getMessageType(fileExtension);

      // Send the file message
      final message = await _repository.sendMessage(
        roomId: state.room!.id,
        content: fileName,
        type: messageType,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: _getMimeType(fileExtension),
        fileSize: fileBytes.length,
      );

      if (message != null) {
        state = state.copyWith(
          messages: [...state.messages, message],
          isSending: false,
        );
        return true;
      }

      state = state.copyWith(isSending: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send attachment: $e',
      );
      return false;
    }
  }

  /// Gets the MIME type for a file extension.
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }

  /// Gets the message type based on file extension.
  MessageType _getMessageType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return MessageType.image;
      default:
        return MessageType.file;
    }
  }

  /// Sends a file message.
  Future<bool> sendFile({
    required String fileUrl,
    required String fileName,
    String? fileType,
    int? fileSize,
  }) async {
    if (state.room == null) return false;
    if (state.isSuspended) return false;

    state = state.copyWith(isSending: true, error: null);

    try {
      final message = await _repository.sendMessage(
        roomId: state.room!.id,
        content: fileName,
        type: MessageType.file,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSize,
      );

      if (message != null) {
        state = state.copyWith(
          messages: [...state.messages, message],
          isSending: false,
        );
        return true;
      }

      state = state.copyWith(isSending: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: 'Failed to send file: $e',
      );
      return false;
    }
  }

  /// Sets the message to reply to.
  void setReplyTo(MessageModel? message) {
    state = state.copyWith(replyTo: message, clearReplyTo: message == null);
  }

  /// Clears reply to.
  void clearReplyTo() {
    state = state.copyWith(clearReplyTo: true);
  }

  /// Suspends the chat.
  Future<bool> suspendChat({String? reason}) async {
    if (state.room == null) return false;

    try {
      final success =
          await _repository.suspendChat(state.room!.id, reason: reason);
      if (success) {
        state = state.copyWith(
          room: state.room!.copyWith(
            isSuspended: true,
            suspensionReason: reason,
          ),
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Unsuspends the chat.
  Future<bool> unsuspendChat() async {
    if (state.room == null) return false;

    try {
      final success = await _repository.unsuspendChat(state.room!.id);
      if (success) {
        state = state.copyWith(
          room: state.room!.copyWith(isSuspended: false),
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Deletes a message.
  Future<bool> deleteMessage(String messageId) async {
    try {
      final success = await _repository.deleteMessage(messageId);
      if (success) {
        state = state.copyWith(
          messages: state.messages
              .map((m) => m.id == messageId ? m.copyWith(isDeleted: true) : m)
              .toList(),
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Closes the current chat room.
  void closeRoom() {
    _messagesSubscription?.cancel();
    _messagesSubscription = null;
    state = const ActiveChatState();
  }

  /// Clears error message.
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for active chat.
final activeChatProvider =
    StateNotifierProvider<ActiveChatNotifier, ActiveChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ActiveChatNotifier(repository);
});

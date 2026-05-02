import 'dart:async';
import 'dart:io';

import '../../core/api/api_client.dart';
import '../../core/socket/socket_client.dart';
import '../models/chat_model.dart';

/// Repository for chat operations via the Express API.
///
/// Handles chat rooms, messages, and real-time subscriptions via Socket.IO.
class ChatRepository {
  final Map<String, Function> _socketListeners = {};

  ChatRepository();

  /// Gets or creates a chat room for a project.
  Future<ChatRoom> getOrCreateProjectChatRoom(
    String projectId,
    String userId,
  ) async {
    final response = await ApiClient.post('/chat/rooms/project/$projectId', {});
    // API wraps in { room: {...} }
    final data = response is Map<String, dynamic> && response.containsKey('room')
        ? response['room'] as Map<String, dynamic>
        : response as Map<String, dynamic>;
    return ChatRoom.fromJson(data);
  }

  /// Gets all chat rooms for a user.
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    final response = await ApiClient.get('/chat/rooms');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['rooms'] as List? ?? [];
    return list.map((r) => ChatRoom.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Gets messages for a chat room.
  Future<List<ChatMessage>> getMessages(
    String roomId, {
    int limit = 50,
    String? before,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
    };
    if (before != null) queryParams['before'] = before;

    final response = await ApiClient.get(
      '/chat/rooms/$roomId/messages',
      queryParams: queryParams,
    );
    // API returns { messages: [...], total, page } or raw list
    final list = response is Map<String, dynamic>
        ? (response['messages'] as List? ?? [])
        : response as List;
    return list
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// Sends a message to a chat room.
  Future<ChatMessage> sendMessage(
    String roomId,
    String senderId,
    String content, {
    String? attachmentUrl,
  }) async {
    final messageData = <String, dynamic>{
      'content': content,
    };
    if (attachmentUrl != null) {
      messageData['fileUrl'] = attachmentUrl;
      messageData['messageType'] = 'file';
    }

    final response = await ApiClient.post(
      '/chat/rooms/$roomId/messages',
      messageData,
    );
    // API returns { message: {...} } or raw object
    final data = response is Map<String, dynamic> && response.containsKey('message')
        ? response['message'] as Map<String, dynamic>
        : response as Map<String, dynamic>;
    return ChatMessage.fromJson(data);
  }

  /// Uploads a file attachment for chat.
  Future<String> uploadAttachment(String roomId, String filePath, String fileName) async {
    final file = File(filePath);
    final response = await ApiClient.uploadFile(
      '/upload',
      file,
      folder: 'chat-attachments',
    );
    return (response as Map<String, dynamic>)['url'] as String;
  }

  /// Marks messages as read.
  Future<void> markAsRead(String roomId, String userId) async {
    await ApiClient.put('/chat/rooms/$roomId/read', {});
  }

  /// Subscribes to new messages in a chat room via Socket.IO.
  Stream<ChatMessage> subscribeToRoom(String roomId) {
    final controller = StreamController<ChatMessage>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getSocket();

        void listener(dynamic data) {
          try {
            final message = ChatMessage.fromJson(data as Map<String, dynamic>);
            controller.add(message);
          } catch (_) {}
        }

        socket.on('chat:message', listener);
        _socketListeners['chat:message'] = listener;
      } catch (e) {
        controller.addError(e);
      }
    }();

    controller.onCancel = () {
      _unsubscribeFromRoom(roomId);
    };

    return controller.stream;
  }

  /// Emit typing start event.
  Future<void> startTyping(String roomId) async {
    try {
      final socket = await SocketClient.getSocket();
      socket.emit('typing:start', roomId);
    } catch (_) {}
  }

  /// Emit typing stop event.
  Future<void> stopTyping(String roomId) async {
    try {
      final socket = await SocketClient.getSocket();
      socket.emit('typing:stop', roomId);
    } catch (_) {}
  }

  /// Subscribe to typing events for a room.
  Stream<Map<String, dynamic>> subscribeToTyping(String roomId) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getSocket();
        socket.on('typing:start', (data) {
          if (data is Map<String, dynamic>) {
            controller.add({...data, 'isTyping': true});
          }
        });
        socket.on('typing:stop', (data) {
          if (data is Map<String, dynamic>) {
            controller.add({...data, 'isTyping': false});
          }
        });
      } catch (_) {}
    }();

    return controller.stream;
  }

  void _unsubscribeFromRoom(String roomId) {
    _socketListeners.remove('chat:message');
  }

  /// Approves a pending message (supervisor action).
  Future<void> approveMessage(String messageId) async {
    await ApiClient.put('/chat/messages/$messageId/approve', {});
  }

  /// Rejects a pending message (supervisor action).
  Future<void> rejectMessage(String messageId, String? reason) async {
    await ApiClient.put('/chat/messages/$messageId/reject', {
      'reason': reason,
    });
  }

  /// Gets total unread message count for a user.
  Future<int> getTotalUnreadCount(String userId) async {
    try {
      final response = await ApiClient.get('/chat/unread');
      return (response as Map<String, dynamic>)['total'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Fetches project timeline (status history) events.
  ///
  /// Returns a list of timeline entries from `GET /projects/:id/timeline`.
  Future<List<Map<String, dynamic>>> getProjectTimeline(String projectId) async {
    try {
      final response = await ApiClient.get('/projects/$projectId/timeline');
      // API may return { timeline: [...] } or raw list
      final list = response is Map<String, dynamic>
          ? (response['timeline'] ?? response['status_history'] ?? response['statusHistory'] ?? []) as List
          : response is List
              ? response
              : [];
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /// Cleans up all subscriptions.
  void dispose() {
    _socketListeners.clear();
  }
}

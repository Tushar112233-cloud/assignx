import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/socket/socket_client.dart';
import '../models/chat_room_model.dart';
import '../models/message_model.dart';

/// Repository for chat-related operations.
///
/// Handles messages, chat rooms, and real-time subscriptions.
class ChatRepository {
  ChatRepository();

  /// Fetches all chat rooms for the current supervisor.
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final response = await ApiClient.get('/chat/rooms');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['rooms'] as List? ?? [];

      return list
          .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.getChatRooms error: $e');
      }
      rethrow;
    }
  }

  /// Fetches a single chat room by ID.
  Future<ChatRoomModel?> getChatRoom(String roomId) async {
    try {
      final response = await ApiClient.get('/chat/rooms/$roomId');
      if (response == null) return null;
      return ChatRoomModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.getChatRoom error: $e');
      }
      rethrow;
    }
  }

  /// Fetches chat room by project ID.
  Future<ChatRoomModel?> getChatRoomByProject(String projectId) async {
    try {
      final response = await ApiClient.post(
        '/chat/rooms/project/$projectId',
        {},
      );
      if (response == null) return null;
      return ChatRoomModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.getChatRoomByProject error: $e');
      }
      rethrow;
    }
  }

  /// Fetches messages for a chat room.
  Future<List<MessageModel>> getMessages(
    String roomId, {
    int limit = 50,
    DateTime? before,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
      };
      if (before != null) {
        params['before'] = before.toIso8601String();
      }
      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await ApiClient.get('/chat/rooms/$roomId/messages?$query');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['messages'] as List? ?? [];

      return list
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.getMessages error: $e');
      }
      rethrow;
    }
  }

  /// Sends a message to a chat room.
  Future<MessageModel?> sendMessage({
    required String roomId,
    required String content,
    MessageType type = MessageType.text,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? replyToId,
  }) async {
    try {
      final response = await ApiClient.post('/chat/rooms/$roomId/messages', {
        'content': content,
        'message_type': type.value,
        if (fileUrl != null) 'file_url': fileUrl,
        if (fileName != null) 'file_name': fileName,
        if (fileType != null) 'file_type': fileType,
        if (fileSize != null) 'file_size_bytes': fileSize,
        if (replyToId != null) 'reply_to_id': replyToId,
      });

      return MessageModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.sendMessage error: $e');
      }
      rethrow;
    }
  }

  /// Marks messages as read.
  Future<void> markAsRead(String roomId) async {
    try {
      await ApiClient.put('/chat/rooms/$roomId/read', {});
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.markAsRead error: $e');
      }
      rethrow;
    }
  }

  /// Suspends a chat room.
  Future<bool> suspendChat(String roomId, {String? reason}) async {
    try {
      await ApiClient.put('/chat/rooms/$roomId/suspend', {
        if (reason != null) 'reason': reason,
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.suspendChat error: $e');
      }
      rethrow;
    }
  }

  /// Unsuspends a chat room.
  Future<bool> unsuspendChat(String roomId) async {
    try {
      await ApiClient.put('/chat/rooms/$roomId/unsuspend', {});
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository.unsuspendChat error: $e');
      }
      rethrow;
    }
  }

  /// Deletes a message.
  Future<bool> deleteMessage(String messageId) async {
    try {
      await ApiClient.delete('/chat/messages/$messageId');
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==========================================================================
  // Socket.IO real-time methods
  // ==========================================================================

  /// Joins a chat room via Socket.IO for real-time updates.
  Future<void> joinRoom(String roomId) async {
    try {
      final socket = await SocketClient.getInstance();
      socket.emit('chat:join', roomId);
      if (kDebugMode) debugPrint('ChatRepository.joinRoom: $roomId');
    } catch (e) {
      if (kDebugMode) debugPrint('ChatRepository.joinRoom error: $e');
    }
  }

  /// Leaves a chat room via Socket.IO.
  Future<void> leaveRoom(String roomId) async {
    try {
      final socket = await SocketClient.getInstance();
      socket.emit('chat:leave', roomId);
      if (kDebugMode) debugPrint('ChatRepository.leaveRoom: $roomId');
    } catch (e) {
      if (kDebugMode) debugPrint('ChatRepository.leaveRoom error: $e');
    }
  }

  /// Returns a stream of new messages for a specific room.
  ///
  /// Listens to the `chat:message` socket event and filters by [roomId].
  Stream<MessageModel> onNewMessage(String roomId) {
    final controller = StreamController<MessageModel>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getInstance();
        void handler(dynamic data) {
          try {
            final json = data as Map<String, dynamic>;
            final message = MessageModel.fromJson(json);
            if (message.chatRoomId == roomId) {
              controller.add(message);
            }
          } catch (e) {
            if (kDebugMode) debugPrint('onNewMessage parse error: $e');
          }
        }

        socket.on('chat:message', handler);

        controller.onCancel = () {
          socket.off('chat:message', handler);
          controller.close();
        };
      } catch (e) {
        controller.addError(e);
        await controller.close();
      }
    }();

    return controller.stream;
  }

  /// Emits typing start or stop for a room.
  Future<void> sendTyping(String roomId, bool isTyping) async {
    try {
      final socket = await SocketClient.getInstance();
      socket.emit(isTyping ? 'typing:start' : 'typing:stop', roomId);
    } catch (e) {
      if (kDebugMode) debugPrint('ChatRepository.sendTyping error: $e');
    }
  }

  /// Returns a stream of typing events for a specific room.
  ///
  /// Emits a map with `userId` and `isTyping` keys.
  Stream<Map<String, dynamic>> onTyping(String roomId) {
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getInstance();

        void startHandler(dynamic data) {
          try {
            final json = data as Map<String, dynamic>;
            controller.add({'userId': json['userId'], 'isTyping': true});
          } catch (_) {}
        }

        void stopHandler(dynamic data) {
          try {
            final json = data as Map<String, dynamic>;
            controller.add({'userId': json['userId'], 'isTyping': false});
          } catch (_) {}
        }

        socket.on('typing:start', startHandler);
        socket.on('typing:stop', stopHandler);

        controller.onCancel = () {
          socket.off('typing:start', startHandler);
          socket.off('typing:stop', stopHandler);
          controller.close();
        };
      } catch (e) {
        controller.addError(e);
        await controller.close();
      }
    }();

    return controller.stream;
  }

  /// Watches messages for real-time updates via Socket.IO.
  ///
  /// Returns a stream that emits individual new [MessageModel] objects
  /// received from the `chat:message` event for the given [roomId].
  Stream<MessageModel> watchMessages(String roomId) {
    return onNewMessage(roomId);
  }

  /// Watches chat rooms for real-time updates via Socket.IO.
  ///
  /// Listens for any `chat:message` event (all rooms) and emits the
  /// associated room ID so callers can refresh their room list.
  Stream<String> watchChatRooms() {
    final controller = StreamController<String>.broadcast();

    () async {
      try {
        final socket = await SocketClient.getInstance();
        void handler(dynamic data) {
          try {
            final json = data as Map<String, dynamic>;
            final roomId = (json['chatRoomId'] ?? json['chat_room_id'] ?? '').toString();
            if (roomId.isNotEmpty) {
              controller.add(roomId);
            }
          } catch (_) {}
        }

        socket.on('chat:message', handler);

        controller.onCancel = () {
          socket.off('chat:message', handler);
          controller.close();
        };
      } catch (e) {
        controller.addError(e);
        await controller.close();
      }
    }();

    return controller.stream;
  }

}

/// Provider for the chat repository.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

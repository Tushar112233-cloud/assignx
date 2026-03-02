import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
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
      final response = await ApiClient.get(
        '/chat/rooms/by-project/$projectId',
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

  /// Watches messages for real-time updates.
  /// Note: Real-time handled via Socket.IO at the provider level.
  Stream<List<MessageModel>> watchMessages(String roomId) {
    return Stream.value([]);
  }

  /// Watches chat rooms for real-time updates.
  /// Note: Real-time handled via Socket.IO at the provider level.
  Stream<List<ChatRoomModel>> watchChatRooms() {
    return Stream.value([]);
  }

}

/// Provider for the chat repository.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

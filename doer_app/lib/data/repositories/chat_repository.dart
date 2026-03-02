import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../core/api/api_client.dart';
import '../../core/socket/socket_client.dart';
import '../../core/validators/contact_detector.dart';
import '../models/chat_model.dart';

/// Repository for chat operations.
///
/// Handles fetching chat rooms, messages, sending messages,
/// and real-time subscriptions via Socket.IO.
class DoerChatRepository {
  DoerChatRepository();

  IO.Socket? _socket;
  String? _currentUserId;

  /// Lazily resolve the current user's ID from the API.
  Future<String?> _getUserId() async {
    if (_currentUserId != null) return _currentUserId;
    try {
      final response = await ApiClient.get('/auth/me');
      if (response is Map<String, dynamic>) {
        _currentUserId = (response['_id'] ?? response['id'])?.toString();
      }
    } catch (_) {}
    return _currentUserId;
  }

  /// Fetches the chat room for a project (doer-supervisor chat).
  Future<ChatRoomModel?> getProjectChatRoom(String projectId) async {
    try {
      final userId = await _getUserId();
      final response = await ApiClient.get('/chat/rooms/project/$projectId?type=project_supervisor_doer');
      if (response == null) return null;
      return ChatRoomModel.fromJson(response as Map<String, dynamic>, userId ?? '');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.getProjectChatRoom error: $e');
      }
      rethrow;
    }
  }

  /// Fetches all chat rooms for the doer.
  Future<List<ChatRoomModel>> getChatRooms() async {
    try {
      final userId = await _getUserId();
      final response = await ApiClient.get('/chat/rooms');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['rooms'] as List? ?? [];

      final rooms = list
          .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>, userId ?? ''))
          .toList();

      rooms.sort((a, b) => (b.lastMessageAt ?? b.createdAt)
          .compareTo(a.lastMessageAt ?? a.createdAt));

      return rooms;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.getChatRooms error: $e');
      }
      rethrow;
    }
  }

  /// Fetches messages for a chat room.
  Future<List<ChatMessageModel>> getMessages(
    String chatRoomId, {
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      final userId = await _getUserId();
      var path = '/chat/rooms/$chatRoomId/messages?limit=$limit';
      if (beforeMessageId != null) {
        path += '&before=$beforeMessageId';
      }

      final response = await ApiClient.get(path);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['messages'] as List? ?? [];

      return list
          .map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>, userId ?? ''))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.getMessages error: $e');
      }
      rethrow;
    }
  }

  /// Sends a text message.
  ///
  /// Includes contact info detection for S39 compliance.
  Future<ChatMessageModel?> sendMessage({
    required String chatRoomId,
    required String content,
    String? replyToId,
  }) async {
    if (content.trim().isEmpty) return null;

    try {
      final userId = await _getUserId();
      final detection = ContactDetector.detect(content);

      final response = await ApiClient.post('/chat/rooms/$chatRoomId/messages', {
        'content': content.trim(),
        'messageType': 'text',
        'containsContactInfo': detection.detected,
        if (replyToId != null) 'replyToId': replyToId,
      });

      if (response == null) return null;
      return ChatMessageModel.fromJson(response as Map<String, dynamic>, userId ?? '');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.sendMessage error: $e');
      }
      rethrow;
    }
  }

  /// Sends a file/attachment message.
  Future<ChatMessageModel?> sendFileMessage({
    required String chatRoomId,
    required String fileUrl,
    required String fileName,
    required String fileType,
    required int fileSize,
    String? caption,
  }) async {
    try {
      final userId = await _getUserId();
      final messageType = fileType.startsWith('image/') ? 'image' : 'file';

      final response = await ApiClient.post('/chat/rooms/$chatRoomId/messages', {
        'content': caption ?? fileName,
        'messageType': messageType,
        'fileUrl': fileUrl,
        'fileName': fileName,
        'fileType': fileType,
        'fileSizeBytes': fileSize,
      });

      if (response == null) return null;
      return ChatMessageModel.fromJson(response as Map<String, dynamic>, userId ?? '');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.sendFileMessage error: $e');
      }
      rethrow;
    }
  }

  /// Marks messages as read.
  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      await ApiClient.post('/chat/rooms/$chatRoomId/read');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.markMessagesAsRead error: $e');
      }
    }
  }

  /// Subscribes to new messages in a chat room via Socket.IO.
  ///
  /// Returns a stream of new messages.
  Stream<ChatMessageModel> subscribeToMessages(String chatRoomId) {
    final controller = StreamController<ChatMessageModel>.broadcast();

    () async {
      try {
        final userId = await _getUserId();
        _socket = await SocketClient.getSocket();

        _socket!.emit('join-room', {'roomId': chatRoomId});

        _socket!.on('new-message', (data) {
          if (data is Map<String, dynamic> && data['chatRoomId'] == chatRoomId) {
            try {
              controller.add(ChatMessageModel.fromJson(data, userId ?? ''));
            } catch (_) {}
          }
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('DoerChatRepository.subscribeToMessages error: $e');
        }
      }
    }();

    controller.onCancel = () {
      _socket?.emit('leave-room', {'roomId': chatRoomId});
    };

    return controller.stream;
  }

  /// Unsubscribes from message updates.
  void unsubscribe() {
    _socket?.off('new-message');
    _socket = null;
  }
}

/// Provider for the doer chat repository.
final doerChatRepositoryProvider = Provider<DoerChatRepository>((ref) {
  return DoerChatRepository();
});

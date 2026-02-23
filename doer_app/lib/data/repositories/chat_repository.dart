import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/validators/contact_detector.dart';
import '../models/chat_model.dart';

/// Repository for chat operations.
///
/// Handles fetching chat rooms, messages, sending messages,
/// and real-time subscriptions. Syncs with supervisor chat system.
class DoerChatRepository {
  DoerChatRepository(this._client);

  final SupabaseClient _client;
  RealtimeChannel? _messageChannel;

  /// Gets the current user's ID.
  String? get _userId => _client.auth.currentUser?.id;

  /// Fetches the chat room for a project (doer-supervisor chat).
  ///
  /// Returns the chat room of type 'project_supervisor_doer'.
  Future<ChatRoomModel?> getProjectChatRoom(String projectId) async {
    try {
      final response = await _client
          .from('chat_rooms')
          .select('''
            *,
            participants:chat_room_participants(
              profile:profiles(id, full_name, avatar_url, user_type)
            )
          ''')
          .eq('project_id', projectId)
          .eq('room_type', 'project_supervisor_doer')
          .maybeSingle();

      if (response == null) return null;
      return ChatRoomModel.fromJson(response, _userId!);
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
      // Get rooms where doer is a participant
      final response = await _client
          .from('chat_room_participants')
          .select('''
            chat_room:chat_rooms(
              *,
              participants:chat_room_participants(
                profile:profiles(id, full_name, avatar_url, user_type)
              )
            )
          ''')
          .eq('profile_id', _userId!)
          .order('created_at', ascending: false);

      final rooms = <ChatRoomModel>[];
      for (final item in response as List) {
        if (item['chat_room'] != null) {
          rooms.add(ChatRoomModel.fromJson(item['chat_room'], _userId!));
        }
      }

      // Sort by last message
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
  ///
  /// Returns messages in chronological order (oldest first).
  Future<List<ChatMessageModel>> getMessages(
    String chatRoomId, {
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      var query = _client.from('chat_messages').select('''
        *,
        sender:profiles!sender_id(id, full_name, avatar_url, user_type),
        reply_to:chat_messages!reply_to_id(id, content, sender:profiles!sender_id(full_name))
      ''').eq('chat_room_id', chatRoomId).eq('is_deleted', false);

      if (beforeMessageId != null) {
        query = query.lt('created_at', beforeMessageId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final messages = (response as List)
          .map((json) => ChatMessageModel.fromJson(json, _userId!))
          .toList();

      // Reverse to get chronological order
      return messages.reversed.toList();
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
      // Detect contact information (S39 - Contact Sharing Prevention)
      final detection = ContactDetector.detect(content);

      final messageData = {
        'chat_room_id': chatRoomId,
        'sender_id': _userId,
        'message_type': 'text',
        'content': content.trim(),
        'contains_contact_info': detection.detected,
        if (replyToId != null) 'reply_to_id': replyToId,
      };

      final response = await _client
          .from('chat_messages')
          .insert(messageData)
          .select('''
            *,
            sender:profiles!sender_id(id, full_name, avatar_url, user_type)
          ''')
          .single();

      // Update chat room's last_message_at
      await _client.from('chat_rooms').update({
        'last_message_at': DateTime.now().toIso8601String(),
        'message_count': SupabaseClient as dynamic, // Will use RPC for increment
      }).eq('id', chatRoomId);

      return ChatMessageModel.fromJson(response, _userId!);
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
      final messageType = fileType.startsWith('image/')
          ? 'image'
          : 'file';

      final messageData = {
        'chat_room_id': chatRoomId,
        'sender_id': _userId,
        'message_type': messageType,
        'content': caption ?? fileName,
        'file_url': fileUrl,
        'file_name': fileName,
        'file_type': fileType,
        'file_size_bytes': fileSize,
      };

      final response = await _client
          .from('chat_messages')
          .insert(messageData)
          .select('''
            *,
            sender:profiles!sender_id(id, full_name, avatar_url, user_type)
          ''')
          .single();

      return ChatMessageModel.fromJson(response, _userId!);
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
      // Update read_by jsonb field for all unread messages
      await _client.rpc('mark_messages_read', params: {
        'p_chat_room_id': chatRoomId,
        'p_user_id': _userId,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerChatRepository.markMessagesAsRead error: $e');
      }
    }
  }

  /// Subscribes to new messages in a chat room.
  ///
  /// Returns a stream of new messages.
  Stream<ChatMessageModel> subscribeToMessages(String chatRoomId) {
    final controller = StreamController<ChatMessageModel>.broadcast();

    _messageChannel = _client
        .channel('chat_room_$chatRoomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: chatRoomId,
          ),
          callback: (payload) {
            final json = payload.newRecord;
            // Fetch full message with relations
            _fetchMessageById(json['id'] as String).then((message) {
              if (message != null) {
                controller.add(message);
              }
            });
          },
        )
        .subscribe();

    controller.onCancel = () {
      _messageChannel?.unsubscribe();
    };

    return controller.stream;
  }

  /// Fetches a single message by ID.
  Future<ChatMessageModel?> _fetchMessageById(String messageId) async {
    try {
      final response = await _client.from('chat_messages').select('''
        *,
        sender:profiles!sender_id(id, full_name, avatar_url, user_type)
      ''').eq('id', messageId).single();

      return ChatMessageModel.fromJson(response, _userId!);
    } catch (e) {
      return null;
    }
  }

  /// Unsubscribes from message updates.
  void unsubscribe() {
    _messageChannel?.unsubscribe();
    _messageChannel = null;
  }

}

/// Provider for the doer chat repository.
final doerChatRepositoryProvider = Provider<DoerChatRepository>((ref) {
  return DoerChatRepository(SupabaseConfig.client);
});

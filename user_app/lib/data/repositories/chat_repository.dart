import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/chat_model.dart';

/// Repository for chat operations with Supabase.
///
/// Handles chat rooms, messages, and real-time subscriptions.
class ChatRepository {
  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _subscriptions = {};

  ChatRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  /// Gets or creates a chat room for a project.
  ///
  /// [projectId] - The project UUID
  /// [userId] - The user's profile ID
  Future<ChatRoom> getOrCreateProjectChatRoom(
    String projectId,
    String userId,
  ) async {
    // First, try to find existing chat room
    final existingResponse = await _client
        .from('chat_rooms')
        .select()
        .eq('project_id', projectId)
        .maybeSingle();

    if (existingResponse != null) {
      return ChatRoom.fromJson(existingResponse);
    }

    // Create new chat room
    final newRoomResponse = await _client
        .from('chat_rooms')
        .insert({
          'project_id': projectId,
          'room_type': 'project_user_supervisor',
        })
        .select()
        .single();

    final newRoom = ChatRoom.fromJson(newRoomResponse);

    // Add user as participant
    await _client.from('chat_participants').insert({
      'chat_room_id': newRoom.id,
      'profile_id': userId,
      'participant_role': 'user',
    });

    return newRoom;
  }

  /// Gets all chat rooms for a user.
  Future<List<ChatRoom>> getChatRooms(String userId) async {
    // Get rooms where user is a participant
    final participations = await _client
        .from('chat_participants')
        .select('chat_room_id')
        .eq('profile_id', userId);

    final roomIds =
        (participations as List).map((p) => p['chat_room_id'] as String).toList();

    if (roomIds.isEmpty) return [];

    // Get room details
    final rooms = await _client
        .from('chat_rooms')
        .select()
        .inFilter('id', roomIds)
        .order('updated_at', ascending: false);

    return (rooms as List).map((r) => ChatRoom.fromJson(r)).toList();
  }

  /// Gets messages for a chat room.
  ///
  /// [roomId] - The chat room UUID
  /// [limit] - Number of messages to fetch
  /// [before] - Fetch messages before this timestamp
  Future<List<ChatMessage>> getMessages(
    String roomId, {
    int limit = 50,
    String? before,
  }) async {
    dynamic query = _client
        .from('chat_messages')
        .select('''
          *,
          sender:profiles!chat_messages_sender_id_fkey(id, full_name, avatar_url)
        ''')
        .eq('chat_room_id', roomId);

    if (before != null) {
      query = query.lt('created_at', before);
    }

    query = query.order('created_at', ascending: false).limit(limit);

    final response = await query;
    final messages =
        (response as List).map((m) => ChatMessage.fromJson(m)).toList();

    // Reverse to get chronological order
    return messages.reversed.toList();
  }

  /// Sends a message to a chat room.
  Future<ChatMessage> sendMessage(
    String roomId,
    String senderId,
    String content, {
    String? attachmentUrl,
  }) async {
    final messageData = {
      'chat_room_id': roomId,
      'sender_id': senderId,
      'content': content,
      'file_url': attachmentUrl,
      'message_type': attachmentUrl != null ? 'file' : 'text',
    };

    final response = await _client
        .from('chat_messages')
        .insert(messageData)
        .select()
        .single();

    // Update room's updated_at
    await _client
        .from('chat_rooms')
        .update({'updated_at': DateTime.now().toIso8601String()}).eq(
            'id', roomId);

    return ChatMessage.fromJson(response);
  }

  /// Uploads a file attachment for chat.
  Future<String> uploadAttachment(String roomId, String filePath, String fileName) async {
    final storagePath = '$roomId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await _client.storage
        .from('chat-attachments')
        .upload(storagePath, filePath as dynamic);

    final urlResponse = _client.storage
        .from('chat-attachments')
        .getPublicUrl(storagePath);

    return urlResponse;
  }

  /// Marks messages as read by appending userId to read_by jsonb array.
  Future<void> markAsRead(String roomId, String userId) async {
    // Get unread messages not sent by the user
    final unreadMessages = await _client
        .from('chat_messages')
        .select('id, read_by')
        .eq('chat_room_id', roomId)
        .neq('sender_id', userId);

    // Update each message to add userId to read_by array if not already present
    for (final msg in unreadMessages as List) {
      final readBy = (msg['read_by'] as List?)?.cast<String>() ?? [];
      if (!readBy.contains(userId)) {
        readBy.add(userId);
        await _client
            .from('chat_messages')
            .update({'read_by': readBy})
            .eq('id', msg['id']);
      }
    }

    // Update participant's last_read_at
    await _client
        .from('chat_participants')
        .update({
          'last_read_at': DateTime.now().toIso8601String(),
          'unread_count': 0,
        })
        .eq('chat_room_id', roomId)
        .eq('profile_id', userId);
  }

  /// Subscribes to new messages in a chat room.
  ///
  /// Returns a stream of new messages.
  Stream<ChatMessage> subscribeToRoom(String roomId) {
    final controller = StreamController<ChatMessage>.broadcast();

    // Unsubscribe from existing subscription if any
    _unsubscribeFromRoom(roomId);

    // Create new subscription
    final channel = _client
        .channel('chat:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: roomId,
          ),
          callback: (payload) {
            final message = ChatMessage.fromJson(payload.newRecord);
            controller.add(message);
          },
        )
        .subscribe();

    _subscriptions[roomId] = channel;

    // Clean up when stream is cancelled
    controller.onCancel = () {
      _unsubscribeFromRoom(roomId);
    };

    return controller.stream;
  }

  /// Unsubscribes from a room's messages.
  void _unsubscribeFromRoom(String roomId) {
    final existingChannel = _subscriptions[roomId];
    if (existingChannel != null) {
      existingChannel.unsubscribe();
      _subscriptions.remove(roomId);
    }
  }

  /// Approves a pending message (supervisor action).
  Future<void> approveMessage(String messageId) async {
    await _client
        .from('chat_messages')
        .update({
          'moderation_status': 'approved',
          'approved_at': DateTime.now().toIso8601String(),
        })
        .eq('id', messageId);
  }

  /// Rejects a pending message (supervisor action).
  Future<void> rejectMessage(String messageId, String? reason) async {
    await _client
        .from('chat_messages')
        .update({
          'moderation_status': 'rejected',
          'rejection_reason': reason,
          'rejected_at': DateTime.now().toIso8601String(),
        })
        .eq('id', messageId);
  }

  /// Gets total unread message count for a user.
  /// Uses chat_participants.unread_count for efficiency.
  Future<int> getTotalUnreadCount(String userId) async {
    // Get total unread count from chat_participants table
    final participations = await _client
        .from('chat_participants')
        .select('unread_count')
        .eq('profile_id', userId)
        .eq('is_active', true);

    int total = 0;
    for (final p in participations as List) {
      total += (p['unread_count'] as int?) ?? 0;
    }
    return total;
  }

  /// Cleans up all subscriptions.
  void dispose() {
    for (final channel in _subscriptions.values) {
      channel.unsubscribe();
    }
    _subscriptions.clear();
  }
}

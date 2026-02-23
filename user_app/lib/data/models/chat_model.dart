/// Message moderation status enum.
enum MessageStatus {
  pending,
  approved,
  rejected,
  flagged,
}

/// Chat room model representing a conversation context.
///
/// Chat-related models for real-time messaging.
/// Includes [ChatRoom], [ChatMessage], and [ChatParticipant] models
/// that map to Supabase database tables.
class ChatRoom {
  final String id;
  final String? projectId;
  final String roomType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ChatMessage? lastMessage;
  final int unreadCount;

  const ChatRoom({
    required this.id,
    this.projectId,
    required this.roomType,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] as String,
      projectId: json['project_id'] as String?,
      roomType: json['room_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'room_type': roomType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

/// Chat message model representing a single message.
class ChatMessage {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String content;
  final String messageType;
  final String? fileUrl;
  final List<String> readBy;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  final ChatSender? sender;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.content,
    this.messageType = 'text',
    this.fileUrl,
    this.readBy = const [],
    this.deliveredAt,
    required this.createdAt,
    this.sender,
    this.status = MessageStatus.approved,
  });

  /// Whether this message was sent by the current user.
  bool isMe(String currentUserId) => senderId == currentUserId;

  /// Whether this message has been read by the given user.
  bool isReadBy(String userId) => readBy.contains(userId);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse read_by jsonb array
    List<String> readByList = [];
    if (json['read_by'] != null) {
      if (json['read_by'] is List) {
        readByList = (json['read_by'] as List).cast<String>();
      }
    }

    // Parse moderation status
    MessageStatus status = MessageStatus.approved;
    final moderationStatus = json['moderation_status'] as String?;
    if (moderationStatus != null) {
      switch (moderationStatus) {
        case 'pending':
          status = MessageStatus.pending;
          break;
        case 'rejected':
          status = MessageStatus.rejected;
          break;
        case 'flagged':
          status = MessageStatus.flagged;
          break;
        default:
          status = MessageStatus.approved;
      }
    }

    return ChatMessage(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      fileUrl: json['file_url'] as String?,
      readBy: readByList,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['sender'] != null
          ? ChatSender.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'content': content,
      'message_type': messageType,
      'file_url': fileUrl,
      'read_by': readBy,
      'delivered_at': deliveredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  ChatMessage copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? content,
    String? messageType,
    String? fileUrl,
    List<String>? readBy,
    DateTime? deliveredAt,
    DateTime? createdAt,
    ChatSender? sender,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      fileUrl: fileUrl ?? this.fileUrl,
      readBy: readBy ?? this.readBy,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
      status: status ?? this.status,
    );
  }
}

/// Sender information for a chat message.
class ChatSender {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? email;

  const ChatSender({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.email,
  });

  factory ChatSender.fromJson(Map<String, dynamic> json) {
    return ChatSender(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
    };
  }
}

/// Chat participant model.
class ChatParticipant {
  final String id;
  final String chatRoomId;
  final String profileId;
  final String participantRole;
  final bool isActive;
  final DateTime? lastReadAt;
  final int unreadCount;
  final bool notificationsEnabled;
  final DateTime joinedAt;

  const ChatParticipant({
    required this.id,
    required this.chatRoomId,
    required this.profileId,
    required this.participantRole,
    this.isActive = true,
    this.lastReadAt,
    this.unreadCount = 0,
    this.notificationsEnabled = true,
    required this.joinedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      profileId: json['profile_id'] as String,
      participantRole: json['participant_role'] as String? ?? 'user',
      isActive: json['is_active'] as bool? ?? true,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }
}

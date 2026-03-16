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
    DateTime? parseDate(String s, String c) {
      final v = json[s] ?? json[c];
      return v != null ? DateTime.tryParse(v.toString()) : null;
    }
    final lastMsg = json['last_message'] ?? json['lastMessage'];
    return ChatRoom(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      projectId: (json['project_id'] ?? json['projectId']) as String?,
      roomType: (json['room_type'] ?? json['roomType'] ?? 'project').toString(),
      createdAt: parseDate('created_at', 'createdAt') ?? DateTime.now(),
      updatedAt: parseDate('updated_at', 'updatedAt') ?? DateTime.now(),
      lastMessage: lastMsg != null
          ? ChatMessage.fromJson(lastMsg as Map<String, dynamic>)
          : null,
      unreadCount: (json['unread_count'] ?? json['unreadCount']) as int? ?? 0,
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

  /// Approval workflow fields for supervisor-moderated chat.
  final String? approvalStatus;
  final String? approverName;
  final DateTime? approvedAt;
  final String? rejectionReason;

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
    this.approvalStatus,
    this.approverName,
    this.approvedAt,
    this.rejectionReason,
  });

  /// Whether this message was sent by the current user.
  bool isMe(String currentUserId) => senderId == currentUserId;

  /// Whether this message has been read by the given user.
  bool isReadBy(String userId) => readBy.contains(userId);

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Parse read_by jsonb array
    List<String> readByList = [];
    final readByRaw = json['read_by'] ?? json['readBy'];
    if (readByRaw != null) {
      if (readByRaw is List) {
        readByList = readByRaw.cast<String>();
      }
    }

    // Parse moderation status from is_flagged and flagged_reason columns
    MessageStatus status = MessageStatus.approved;
    final isFlagged = (json['is_flagged'] ?? json['isFlagged']) as bool? ?? false;
    final flaggedReason = (json['flagged_reason'] ?? json['flaggedReason']) as String?;
    if (isFlagged) {
      status = MessageStatus.flagged;
    } else if (flaggedReason != null && flaggedReason.isNotEmpty) {
      // Previously flagged but now resolved
      status = MessageStatus.approved;
    }

    final deliveredStr = (json['delivered_at'] ?? json['deliveredAt'])?.toString();
    final createdStr = (json['created_at'] ?? json['createdAt'] ?? '').toString();
    final senderData = json['sender'] ?? json['senderProfile'];

    // Parse approval workflow fields
    final approvalStatusStr = (json['approval_status'] ?? json['approvalStatus']) as String?;
    final approverNameStr = (json['approver_name'] ?? json['approverName']) as String?;
    final approvedAtStr = (json['approved_at'] ?? json['approvedAt'])?.toString();
    final rejectionReasonStr = (json['rejection_reason'] ?? json['rejectionReason']) as String?;

    return ChatMessage(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      chatRoomId: (json['chat_room_id'] ?? json['chatRoomId'] ?? '').toString(),
      senderId: (json['sender_id'] ?? json['senderId'] ?? '').toString(),
      content: json['content'] as String? ?? '',
      messageType: (json['message_type'] ?? json['messageType']) as String? ?? 'text',
      fileUrl: (json['file_url'] ?? json['fileUrl']) as String?,
      readBy: readByList,
      deliveredAt: deliveredStr != null ? DateTime.tryParse(deliveredStr) : null,
      createdAt: DateTime.tryParse(createdStr) ?? DateTime.now(),
      sender: senderData != null
          ? ChatSender.fromJson(senderData as Map<String, dynamic>, senderRole: (json['sender_role'] ?? json['senderRole']) as String?)
          : (json['sender_role'] ?? json['senderRole']) != null
              ? ChatSender(id: (json['sender_id'] ?? json['senderId'] ?? '').toString(), fullName: (json['sender_name'] ?? 'Unknown') as String, role: (json['sender_role'] ?? json['senderRole']) as String?)
              : null,
      status: status,
      approvalStatus: approvalStatusStr,
      approverName: approverNameStr,
      approvedAt: approvedAtStr != null ? DateTime.tryParse(approvedAtStr) : null,
      rejectionReason: rejectionReasonStr,
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
      'approval_status': approvalStatus,
      'approver_name': approverName,
      'approved_at': approvedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
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
    String? approvalStatus,
    String? approverName,
    DateTime? approvedAt,
    String? rejectionReason,
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
      approvalStatus: approvalStatus ?? this.approvalStatus,
      approverName: approverName ?? this.approverName,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}

/// Sender information for a chat message.
class ChatSender {
  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String? role;

  const ChatSender({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.email,
    this.role,
  });

  factory ChatSender.fromJson(Map<String, dynamic> json, {String? senderRole}) {
    return ChatSender(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['full_name'] ?? json['fullName']) as String? ?? 'Unknown',
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String?,
      email: json['email'] as String?,
      role: senderRole ?? (json['role'] as String?),
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
  final String userId;
  final String participantRole;
  final bool isActive;
  final DateTime? lastReadAt;
  final int unreadCount;
  final bool notificationsEnabled;
  final DateTime joinedAt;

  const ChatParticipant({
    required this.id,
    required this.chatRoomId,
    required this.userId,
    required this.participantRole,
    this.isActive = true,
    this.lastReadAt,
    this.unreadCount = 0,
    this.notificationsEnabled = true,
    required this.joinedAt,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    final lastReadStr = (json['last_read_at'] ?? json['lastReadAt'])?.toString();
    final joinedStr = (json['joined_at'] ?? json['joinedAt'] ?? '').toString();
    return ChatParticipant(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      chatRoomId: (json['chat_room_id'] ?? json['chatRoomId'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      participantRole: (json['participant_role'] ?? json['participantRole']) as String? ?? 'user',
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      lastReadAt: lastReadStr != null ? DateTime.tryParse(lastReadStr) : null,
      unreadCount: (json['unread_count'] ?? json['unreadCount']) as int? ?? 0,
      notificationsEnabled: (json['notifications_enabled'] ?? json['notificationsEnabled']) as bool? ?? true,
      joinedAt: DateTime.tryParse(joinedStr) ?? DateTime.now(),
    );
  }
}

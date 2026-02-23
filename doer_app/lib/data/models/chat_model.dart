/// Chat models for the Doer application.
///
/// These models match the Supabase chat_rooms and chat_messages tables.
library;

/// Chat room model matching Supabase schema.
class ChatRoomModel {
  final String id;
  final ChatRoomType roomType;
  final String? name;
  final String? projectId;
  final bool isActive;
  final bool isSuspended;
  final String? suspensionReason;
  final DateTime? lastMessageAt;
  final int messageCount;
  final DateTime createdAt;
  final List<ChatParticipant> participants;

  /// The other participant (supervisor) for display.
  ChatParticipant? get otherParticipant {
    return participants.where((p) => p.userType == 'supervisor').firstOrNull;
  }

  const ChatRoomModel({
    required this.id,
    required this.roomType,
    this.name,
    this.projectId,
    this.isActive = true,
    this.isSuspended = false,
    this.suspensionReason,
    this.lastMessageAt,
    this.messageCount = 0,
    required this.createdAt,
    this.participants = const [],
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Parse participants
    List<ChatParticipant> participants = [];
    if (json['participants'] != null && json['participants'] is List) {
      for (final p in json['participants'] as List) {
        if (p['profile'] != null) {
          participants.add(ChatParticipant.fromJson(p['profile']));
        }
      }
    }

    return ChatRoomModel(
      id: json['id'] as String,
      roomType: ChatRoomType.fromString(json['room_type'] as String? ?? 'direct'),
      name: json['name'] as String?,
      projectId: json['project_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isSuspended: json['is_suspended'] as bool? ?? false,
      suspensionReason: json['suspension_reason'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      messageCount: json['message_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      participants: participants,
    );
  }
}

/// Chat room type enum matching Supabase enum.
enum ChatRoomType {
  /// Chat between user and supervisor.
  projectUserSupervisor('project_user_supervisor'),

  /// Chat between supervisor and doer.
  projectSupervisorDoer('project_supervisor_doer'),

  /// Chat with all three parties.
  projectAll('project_all'),

  /// Support chat.
  support('support'),

  /// Direct message.
  direct('direct');

  final String value;
  const ChatRoomType(this.value);

  static ChatRoomType fromString(String value) {
    return ChatRoomType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ChatRoomType.direct,
    );
  }
}

/// Chat participant model.
class ChatParticipant {
  final String id;
  final String name;
  final String? avatarUrl;
  final String userType;

  const ChatParticipant({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.userType,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? 'Unknown',
      avatarUrl: json['avatar_url'] as String?,
      userType: json['user_type'] as String? ?? 'user',
    );
  }
}

/// Chat message model matching Supabase schema.
class ChatMessageModel {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final MessageType messageType;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int? fileSizeBytes;
  final String? replyToId;
  final String? replyToContent;
  final String? replyToSenderName;
  final bool isEdited;
  final bool isDeleted;
  final bool isFlagged;
  final bool containsContactInfo;
  final DateTime createdAt;
  final bool isFromCurrentUser;

  /// Display content for the message.
  String get displayContent {
    if (isDeleted) return 'This message was deleted';
    return content;
  }

  /// Whether this message has a file attachment.
  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;

  /// Whether this is a reply to another message.
  bool get isReply => replyToId != null;

  /// Alias for createdAt to match chat UI expectations.
  DateTime get sentAt => createdAt;

  /// Whether this message is from the doer (current user in doer app).
  bool get isFromDoer => isFromCurrentUser;

  /// Alias for messageType to match UI expectations.
  MessageType get type => messageType;

  const ChatMessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.messageType,
    required this.content,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSizeBytes,
    this.replyToId,
    this.replyToContent,
    this.replyToSenderName,
    this.isEdited = false,
    this.isDeleted = false,
    this.isFlagged = false,
    this.containsContactInfo = false,
    required this.createdAt,
    required this.isFromCurrentUser,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // Parse sender
    String senderName = 'Unknown';
    String? senderAvatarUrl;
    if (json['sender'] != null && json['sender'] is Map) {
      senderName = json['sender']['full_name'] as String? ?? 'Unknown';
      senderAvatarUrl = json['sender']['avatar_url'] as String?;
    }

    // Parse reply_to
    String? replyToContent;
    String? replyToSenderName;
    if (json['reply_to'] != null && json['reply_to'] is Map) {
      replyToContent = json['reply_to']['content'] as String?;
      if (json['reply_to']['sender'] != null) {
        replyToSenderName = json['reply_to']['sender']['full_name'] as String?;
      }
    }

    return ChatMessageModel(
      id: json['id'] as String,
      chatRoomId: json['chat_room_id'] as String,
      senderId: json['sender_id'] as String,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      messageType: MessageType.fromString(json['message_type'] as String? ?? 'text'),
      content: json['content'] as String? ?? '',
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      fileType: json['file_type'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      replyToId: json['reply_to_id'] as String?,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      isEdited: json['is_edited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? false,
      isFlagged: json['is_flagged'] as bool? ?? false,
      containsContactInfo: json['contains_contact_info'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      isFromCurrentUser: json['sender_id'] == currentUserId,
    );
  }

  ChatMessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    MessageType? messageType,
    String? content,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSizeBytes,
    String? replyToId,
    String? replyToContent,
    String? replyToSenderName,
    bool? isEdited,
    bool? isDeleted,
    bool? isFlagged,
    bool? containsContactInfo,
    DateTime? createdAt,
    bool? isFromCurrentUser,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      messageType: messageType ?? this.messageType,
      content: content ?? this.content,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isFlagged: isFlagged ?? this.isFlagged,
      containsContactInfo: containsContactInfo ?? this.containsContactInfo,
      createdAt: createdAt ?? this.createdAt,
      isFromCurrentUser: isFromCurrentUser ?? this.isFromCurrentUser,
    );
  }
}

/// Message type enum matching Supabase enum.
enum MessageType {
  text('text'),
  image('image'),
  file('file'),
  audio('audio'),
  system('system'),
  action('action');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MessageType.text,
    );
  }
}

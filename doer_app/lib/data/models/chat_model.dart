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
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Parse participants - handle both nested profile and flat formats.
    List<ChatParticipant> participants = [];
    if (json['participants'] != null && json['participants'] is List) {
      for (final p in json['participants'] as List) {
        if (p is Map<String, dynamic>) {
          if (p['profile'] != null && p['profile'] is Map) {
            participants.add(ChatParticipant.fromJson(p['profile'] as Map<String, dynamic>));
          } else if (p['profileId'] != null && p['profileId'] is Map) {
            participants.add(ChatParticipant.fromJson(p['profileId'] as Map<String, dynamic>));
          } else {
            // Flat participant object.
            participants.add(ChatParticipant.fromJson(p));
          }
        }
      }
    }

    // Handle projectId which may be a populated Mongoose object.
    String? projectId;
    final rawProjectId = json['project_id'] ?? json['projectId'];
    if (rawProjectId is String) {
      projectId = rawProjectId;
    } else if (rawProjectId is Map<String, dynamic>) {
      projectId = (rawProjectId['_id'] ?? rawProjectId['id'])?.toString();
    }

    return ChatRoomModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      roomType: ChatRoomType.fromString((json['room_type'] ?? json['roomType'] ?? 'direct').toString()),
      name: json['name'] as String?,
      projectId: projectId,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      isSuspended: json['is_suspended'] as bool? ?? json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspension_reason'] as String? ?? json['suspensionReason'] as String?,
      lastMessageAt: _parseDate(json['last_message_at'] ?? json['lastMessageAt']),
      messageCount: (json['message_count'] ?? json['messageCount']) as int? ?? 0,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['full_name'] ?? json['fullName'] ?? json['name'] ?? 'Unknown').toString(),
      avatarUrl: json['avatar_url'] as String? ?? json['avatarUrl'] as String?,
      userType: (json['user_type'] ?? json['userType'] ?? 'user').toString(),
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
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Parse sender - may be a populated Mongoose object or nested profile.
    String senderName = 'Unknown';
    String? senderAvatarUrl;
    final senderRaw = json['sender'] ?? json['senderId'];
    if (senderRaw != null && senderRaw is Map) {
      senderName = (senderRaw['full_name'] ?? senderRaw['fullName'] ?? senderRaw['name'] ?? 'Unknown').toString();
      senderAvatarUrl = senderRaw['avatar_url'] as String? ?? senderRaw['avatarUrl'] as String?;
    }

    // Extract senderId from possibly populated object.
    String senderId = '';
    final rawSenderId = json['sender_id'] ?? json['senderId'];
    if (rawSenderId is String) {
      senderId = rawSenderId;
    } else if (rawSenderId is Map<String, dynamic>) {
      senderId = (rawSenderId['_id'] ?? rawSenderId['id'] ?? '').toString();
    }

    // Extract chatRoomId from possibly populated object.
    String chatRoomId = '';
    final rawChatRoomId = json['chat_room_id'] ?? json['chatRoomId'];
    if (rawChatRoomId is String) {
      chatRoomId = rawChatRoomId;
    } else if (rawChatRoomId is Map<String, dynamic>) {
      chatRoomId = (rawChatRoomId['_id'] ?? rawChatRoomId['id'] ?? '').toString();
    }

    // Parse reply_to / replyTo.
    String? replyToContent;
    String? replyToSenderName;
    final replyTo = json['reply_to'] ?? json['replyTo'];
    if (replyTo != null && replyTo is Map) {
      replyToContent = replyTo['content'] as String?;
      final replySender = replyTo['sender'] ?? replyTo['senderId'];
      if (replySender != null && replySender is Map) {
        replyToSenderName = (replySender['full_name'] ?? replySender['fullName']) as String?;
      }
    }

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      chatRoomId: chatRoomId,
      senderId: senderId,
      senderName: senderName,
      senderAvatarUrl: senderAvatarUrl,
      messageType: MessageType.fromString((json['message_type'] ?? json['messageType'] ?? 'text').toString()),
      content: json['content'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? json['fileUrl'] as String?,
      fileName: json['file_name'] as String? ?? json['fileName'] as String?,
      fileType: json['file_type'] as String? ?? json['fileType'] as String?,
      fileSizeBytes: (json['file_size_bytes'] ?? json['fileSizeBytes']) as int?,
      replyToId: json['reply_to_id'] as String? ?? json['replyToId'] as String?,
      replyToContent: replyToContent,
      replyToSenderName: replyToSenderName,
      isEdited: json['is_edited'] as bool? ?? json['isEdited'] as bool? ?? false,
      isDeleted: json['is_deleted'] as bool? ?? json['isDeleted'] as bool? ?? false,
      isFlagged: json['is_flagged'] as bool? ?? json['isFlagged'] as bool? ?? false,
      containsContactInfo: json['contains_contact_info'] as bool? ?? json['containsContactInfo'] as bool? ?? false,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      isFromCurrentUser: senderId == currentUserId,
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

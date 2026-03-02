/// Model representing a chat message.
///
/// Supports text, file attachments, and system messages.
class MessageModel {
  const MessageModel({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    this.senderName,
    this.senderRole,
    this.senderAvatar,
    this.content,
    required this.type,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
    this.replyToId,
    this.replyToContent,
    this.isRead = false,
    this.isEdited = false,
    this.isDeleted = false,
    this.isFiltered = false,
    this.metadata,
    required this.createdAt,
    this.editedAt,
  });

  /// Unique identifier
  final String id;

  /// Parent chat room ID
  final String chatRoomId;

  /// Sender user ID
  final String senderId;

  /// Sender display name
  final String? senderName;

  /// Sender role (client, supervisor, doer)
  final String? senderRole;

  /// Sender avatar URL
  final String? senderAvatar;

  /// Message content (text)
  final String? content;

  /// Message type
  final MessageType type;

  /// Attached file URL (if any)
  final String? fileUrl;

  /// Attached file name
  final String? fileName;

  /// Attached file MIME type
  final String? fileType;

  /// Attached file size in bytes
  final int? fileSize;

  /// ID of message being replied to
  final String? replyToId;

  /// Content preview of replied message
  final String? replyToContent;

  /// Whether message has been read
  final bool isRead;

  /// Whether message has been edited
  final bool isEdited;

  /// Whether message has been deleted
  final bool isDeleted;

  /// Whether message was filtered (contact info)
  final bool isFiltered;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Creation timestamp
  final DateTime createdAt;

  /// Edit timestamp
  final DateTime? editedAt;

  /// Creates a MessageModel from JSON.
  /// Handles both camelCase (MongoDB/Express) and snake_case (Supabase) fields.
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Extract sender info from populated object or flat fields
    String? senderName;
    String? senderRole;
    String? senderAvatar;
    String senderId = '';

    // Handle populated sender/senderId object
    final senderRaw = json['sender'] ?? json['senderId'] ?? json['sender_id'];
    if (senderRaw is Map<String, dynamic>) {
      senderId = (senderRaw['_id'] ?? senderRaw['id'] ?? '').toString();
      senderName = (senderRaw['fullName'] ?? senderRaw['full_name']) as String?;
      senderRole = (senderRaw['role'] ?? senderRaw['userType'] ?? senderRaw['user_type']) as String?;
      senderAvatar = (senderRaw['avatarUrl'] ?? senderRaw['avatar_url']) as String?;
    } else if (senderRaw is String) {
      senderId = senderRaw;
    }

    // Fallback to explicit flat fields
    senderName ??= (json['senderName'] ?? json['sender_name']) as String?;
    senderRole ??= (json['senderRole'] ?? json['sender_role']) as String?;
    senderAvatar ??= (json['senderAvatar'] ?? json['sender_avatar']) as String?;

    return MessageModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      chatRoomId: (json['chatRoomId'] ?? json['chat_room_id'] ?? '').toString(),
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      senderAvatar: senderAvatar,
      content: json['content'] as String?,
      type: MessageType.fromString(
          (json['messageType'] ?? json['message_type'] ?? json['type']) as String?),
      fileUrl: (json['fileUrl'] ?? json['file_url']) as String?,
      fileName: (json['fileName'] ?? json['file_name']) as String?,
      fileType: (json['fileType'] ?? json['file_type']) as String?,
      fileSize: ((json['fileSizeBytes'] ?? json['file_size_bytes'] ?? json['fileSize'] ?? json['file_size']) as num?)?.toInt(),
      replyToId: (json['replyToId'] ?? json['reply_to_id']) as String?,
      replyToContent: (json['replyToContent'] ?? json['reply_to_content']) as String?,
      isRead: (json['isRead'] ?? json['is_read']) as bool? ?? false,
      isEdited: (json['isEdited'] ?? json['is_edited']) as bool? ?? false,
      isDeleted: (json['isDeleted'] ?? json['is_deleted']) as bool? ?? false,
      isFiltered: (json['containsContactInfo'] ?? json['contains_contact_info'] ??
          json['isFiltered'] ?? json['is_filtered']) as bool? ?? false,
      metadata: (json['actionMetadata'] ?? json['action_metadata'] ??
          json['metadata']) as Map<String, dynamic>?,
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['created_at'] ?? '').toString()) ?? DateTime.now(),
      editedAt: _tryParseDate(json['editedAt'] ?? json['edited_at']),
    );
  }

  /// Safely parse a DateTime from dynamic value.
  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// Converts to JSON for sending.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_room_id': chatRoomId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_role': senderRole,
      'content': content,
      'type': type.value,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'reply_to_id': replyToId,
      'reply_to_content': replyToContent,
      'is_read': isRead,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'is_filtered': isFiltered,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  MessageModel copyWith({
    String? id,
    String? chatRoomId,
    String? senderId,
    String? senderName,
    String? senderRole,
    String? senderAvatar,
    String? content,
    MessageType? type,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? replyToId,
    String? replyToContent,
    bool? isRead,
    bool? isEdited,
    bool? isDeleted,
    bool? isFiltered,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? editedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      replyToId: replyToId ?? this.replyToId,
      replyToContent: replyToContent ?? this.replyToContent,
      isRead: isRead ?? this.isRead,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      isFiltered: isFiltered ?? this.isFiltered,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  /// Formatted timestamp for display.
  String get formattedTime {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formatted date for grouping.
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(createdAt.year, createdAt.month, createdAt.day);

    if (messageDay == today) {
      return 'Today';
    } else if (messageDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(messageDay).inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[messageDay.weekday - 1];
    }
    return '${messageDay.day}/${messageDay.month}/${messageDay.year}';
  }

  /// Display content accounting for deleted/filtered state.
  String get displayContent {
    if (isDeleted) return 'Message deleted';
    if (isFiltered) return 'Message filtered';
    return content ?? '';
  }

  /// Whether message has a file attachment.
  bool get hasAttachment => fileUrl != null && fileUrl!.isNotEmpty;

  /// Whether this is a system message.
  bool get isSystemMessage => type == MessageType.system;

  /// Whether the file is an image.
  bool get isImageAttachment {
    if (fileType == null) {
      if (fileName == null) return false;
      final ext = fileName!.toLowerCase();
      return ext.endsWith('.jpg') ||
          ext.endsWith('.jpeg') ||
          ext.endsWith('.png') ||
          ext.endsWith('.gif') ||
          ext.endsWith('.webp');
    }
    return fileType!.startsWith('image/');
  }

  /// Sender initials for avatar.
  String get senderInitials {
    if (senderName == null || senderName!.isEmpty) return '?';
    final parts = senderName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return senderName![0].toUpperCase();
  }
}

/// Types of messages.
enum MessageType {
  /// Regular text message
  text('text'),

  /// File attachment
  file('file'),

  /// Image attachment
  image('image'),

  /// System notification message
  system('system'),

  /// Status update message
  status('status');

  const MessageType(this.value);

  final String value;

  static MessageType fromString(String? value) {
    if (value == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => MessageType.text,
    );
  }
}

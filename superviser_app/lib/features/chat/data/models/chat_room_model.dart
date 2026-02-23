/// Model representing a chat room.
///
/// Chat rooms are associated with projects for communication
/// between clients, supervisors, and doers.
class ChatRoomModel {
  const ChatRoomModel({
    required this.id,
    required this.projectId,
    this.projectTitle,
    this.projectNumber,
    required this.type,
    this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageBy,
    this.unreadCount = 0,
    this.isSuspended = false,
    this.suspendedBy,
    this.suspendedAt,
    this.suspensionReason,
    required this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier
  final String id;

  /// Associated project ID
  final String projectId;

  /// Project title for display
  final String? projectTitle;

  /// Project number for display
  final String? projectNumber;

  /// Chat room type (client_supervisor, doer_supervisor, group)
  final ChatRoomType type;

  /// List of participant IDs
  final List<String>? participants;

  /// Last message content preview
  final String? lastMessage;

  /// Last message timestamp
  final DateTime? lastMessageAt;

  /// Last message sender name
  final String? lastMessageBy;

  /// Unread message count for current user
  final int unreadCount;

  /// Whether chat is suspended
  final bool isSuspended;

  /// Who suspended the chat
  final String? suspendedBy;

  /// When chat was suspended
  final DateTime? suspendedAt;

  /// Reason for suspension
  final String? suspensionReason;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// Creates a ChatRoomModel from JSON.
  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String? ?? '',
      projectTitle: json['project'] is Map
          ? json['project']['title'] as String?
          : json['project_title'] as String? ?? json['name'] as String?,
      projectNumber: json['project'] is Map
          ? json['project']['project_number'] as String?
          : json['project_number'] as String?,
      type: ChatRoomType.fromString(
          json['room_type'] as String? ?? json['type'] as String?),
      participants: (json['participants'] as List?)?.cast<String>(),
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      lastMessageBy: json['last_message_by'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
      isSuspended: json['is_suspended'] as bool? ?? false,
      suspendedBy: json['suspended_by'] as String?,
      suspendedAt: json['suspended_at'] != null
          ? DateTime.parse(json['suspended_at'] as String)
          : null,
      suspensionReason: json['suspension_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'project_title': projectTitle,
      'project_number': projectNumber,
      'type': type.value,
      'participants': participants,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'last_message_by': lastMessageBy,
      'unread_count': unreadCount,
      'is_suspended': isSuspended,
      'suspended_by': suspendedBy,
      'suspended_at': suspendedAt?.toIso8601String(),
      'suspension_reason': suspensionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  ChatRoomModel copyWith({
    String? id,
    String? projectId,
    String? projectTitle,
    String? projectNumber,
    ChatRoomType? type,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? lastMessageBy,
    int? unreadCount,
    bool? isSuspended,
    String? suspendedBy,
    DateTime? suspendedAt,
    String? suspensionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      projectNumber: projectNumber ?? this.projectNumber,
      type: type ?? this.type,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      lastMessageBy: lastMessageBy ?? this.lastMessageBy,
      unreadCount: unreadCount ?? this.unreadCount,
      isSuspended: isSuspended ?? this.isSuspended,
      suspendedBy: suspendedBy ?? this.suspendedBy,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      suspensionReason: suspensionReason ?? this.suspensionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Display title for the chat room.
  String get displayTitle => projectTitle ?? 'Chat #$projectNumber';

  /// Formatted last message time.
  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastMessageAt!.day}/${lastMessageAt!.month}';
  }

  /// Whether chat has unread messages.
  bool get hasUnread => unreadCount > 0;
}

/// Types of chat rooms.
enum ChatRoomType {
  /// Chat between client and supervisor
  clientSupervisor('client_supervisor'),

  /// Chat between doer and supervisor
  doerSupervisor('doer_supervisor'),

  /// Project chat with supervisor and doer (DB enum)
  projectSupervisorDoer('project_supervisor_doer'),

  /// Project chat with user and supervisor (DB enum)
  projectUserSupervisor('project_user_supervisor'),

  /// Group chat with all parties
  group('group');

  const ChatRoomType(this.value);

  final String value;

  static ChatRoomType fromString(String? value) {
    if (value == null) return ChatRoomType.group;
    return ChatRoomType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ChatRoomType.group,
    );
  }

  String get displayName {
    switch (this) {
      case ChatRoomType.clientSupervisor:
      case ChatRoomType.projectUserSupervisor:
        return 'Client Chat';
      case ChatRoomType.doerSupervisor:
      case ChatRoomType.projectSupervisorDoer:
        return 'Doer Chat';
      case ChatRoomType.group:
        return 'Group Chat';
    }
  }
}

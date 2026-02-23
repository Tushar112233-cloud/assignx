// Models for the Connect module - Study Groups and Shared Resources.

/// Study group model for peer-to-peer learning.
class StudyGroup {
  /// Unique identifier for the study group.
  final String id;

  /// Name of the study group.
  final String name;

  /// Subject or topic focus.
  final String subject;

  /// Description of the group's purpose.
  final String? description;

  /// User ID of the group creator.
  final String creatorId;

  /// Name of the group creator.
  final String creatorName;

  /// Avatar URL of the creator.
  final String? creatorAvatar;

  /// List of member user IDs.
  final List<String> memberIds;

  /// Current member count.
  final int memberCount;

  /// Maximum members allowed.
  final int maxMembers;

  /// Next scheduled session time.
  final DateTime? nextSessionTime;

  /// Meeting link or location.
  final String? meetingLink;

  /// Tags for searchability.
  final List<String> tags;

  /// Whether the group is currently active.
  final bool isActive;

  /// Whether the group is public or invite-only.
  final bool isPublic;

  /// Created timestamp.
  final DateTime createdAt;

  /// Last activity timestamp.
  final DateTime? lastActivityAt;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.subject,
    this.description,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatar,
    this.memberIds = const [],
    required this.memberCount,
    this.maxMembers = 10,
    this.nextSessionTime,
    this.meetingLink,
    this.tags = const [],
    this.isActive = true,
    this.isPublic = true,
    required this.createdAt,
    this.lastActivityAt,
  });

  /// Check if group is full.
  bool get isFull => memberCount >= maxMembers;

  /// Get formatted next session string.
  String? get nextSessionString {
    if (nextSessionTime == null) return null;
    final now = DateTime.now();
    final diff = nextSessionTime!.difference(now);

    if (diff.isNegative) return 'Past session';
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'In ${diff.inMinutes}m';
      }
      return 'Today at ${_formatTime(nextSessionTime!)}';
    }
    if (diff.inDays == 1) {
      return 'Tomorrow at ${_formatTime(nextSessionTime!)}';
    }
    return '${_formatDate(nextSessionTime!)} at ${_formatTime(nextSessionTime!)}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  /// Get group initials for avatar fallback.
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  factory StudyGroup.fromJson(Map<String, dynamic> json) {
    return StudyGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String?,
      creatorId: json['creator_id'] as String,
      creatorName: json['creator_name'] as String? ?? 'Anonymous',
      creatorAvatar: json['creator_avatar'] as String?,
      memberIds: (json['member_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      memberCount: json['member_count'] as int? ?? 0,
      maxMembers: json['max_members'] as int? ?? 10,
      nextSessionTime: json['next_session_time'] != null
          ? DateTime.parse(json['next_session_time'] as String)
          : null,
      meetingLink: json['meeting_link'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['is_active'] as bool? ?? true,
      isPublic: json['is_public'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'description': description,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'creator_avatar': creatorAvatar,
      'member_ids': memberIds,
      'member_count': memberCount,
      'max_members': maxMembers,
      'next_session_time': nextSessionTime?.toIso8601String(),
      'meeting_link': meetingLink,
      'tags': tags,
      'is_active': isActive,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'last_activity_at': lastActivityAt?.toIso8601String(),
    };
  }

  StudyGroup copyWith({
    String? id,
    String? name,
    String? subject,
    String? description,
    String? creatorId,
    String? creatorName,
    String? creatorAvatar,
    List<String>? memberIds,
    int? memberCount,
    int? maxMembers,
    DateTime? nextSessionTime,
    String? meetingLink,
    List<String>? tags,
    bool? isActive,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? lastActivityAt,
  }) {
    return StudyGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorAvatar: creatorAvatar ?? this.creatorAvatar,
      memberIds: memberIds ?? this.memberIds,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      nextSessionTime: nextSessionTime ?? this.nextSessionTime,
      meetingLink: meetingLink ?? this.meetingLink,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }
}

/// Resource type enum.
enum ResourceType {
  notes('Notes', 'document'),
  video('Video', 'video'),
  link('Link', 'link'),
  pastPaper('Past Paper', 'paper');

  final String label;
  final String iconType;

  const ResourceType(this.label, this.iconType);
}

/// Shared resource model for study materials.
class SharedResource {
  /// Unique identifier.
  final String id;

  /// Title of the resource.
  final String title;

  /// Description of the resource.
  final String? description;

  /// Type of resource.
  final ResourceType type;

  /// Subject/category.
  final String subject;

  /// User ID of the uploader.
  final String uploaderId;

  /// Name of the uploader.
  final String uploaderName;

  /// Avatar URL of the uploader.
  final String? uploaderAvatar;

  /// Download/view URL.
  final String? url;

  /// File size in bytes (for files).
  final int? fileSize;

  /// File extension (for files).
  final String? fileExtension;

  /// Number of downloads/views.
  final int downloadCount;

  /// Number of saves/bookmarks.
  final int saveCount;

  /// Average rating.
  final double rating;

  /// Number of ratings.
  final int ratingCount;

  /// Tags for searchability.
  final List<String> tags;

  /// Whether the resource is verified/approved.
  final bool isVerified;

  /// Created timestamp.
  final DateTime createdAt;

  const SharedResource({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.subject,
    required this.uploaderId,
    required this.uploaderName,
    this.uploaderAvatar,
    this.url,
    this.fileSize,
    this.fileExtension,
    this.downloadCount = 0,
    this.saveCount = 0,
    this.rating = 0,
    this.ratingCount = 0,
    this.tags = const [],
    this.isVerified = false,
    required this.createdAt,
  });

  /// Get formatted file size string.
  String? get fileSizeString {
    if (fileSize == null) return null;
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get uploader initials for avatar fallback.
  String get uploaderInitials {
    if (uploaderName.isEmpty) return '?';
    final parts = uploaderName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return uploaderName[0].toUpperCase();
  }

  /// Get formatted rating string.
  String get ratingString => rating.toStringAsFixed(1);

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}y ago';
    }
    if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}mo ago';
    }
    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }

  factory SharedResource.fromJson(Map<String, dynamic> json) {
    return SharedResource(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: ResourceType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ResourceType.notes,
      ),
      subject: json['subject'] as String? ?? 'General',
      uploaderId: json['uploader_id'] as String,
      uploaderName: json['uploader_name'] as String? ?? 'Anonymous',
      uploaderAvatar: json['uploader_avatar'] as String?,
      url: json['url'] as String?,
      fileSize: json['file_size'] as int?,
      fileExtension: json['file_extension'] as String?,
      downloadCount: json['download_count'] as int? ?? 0,
      saveCount: json['save_count'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'subject': subject,
      'uploader_id': uploaderId,
      'uploader_name': uploaderName,
      'uploader_avatar': uploaderAvatar,
      'url': url,
      'file_size': fileSize,
      'file_extension': fileExtension,
      'download_count': downloadCount,
      'save_count': saveCount,
      'rating': rating,
      'rating_count': ratingCount,
      'tags': tags,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

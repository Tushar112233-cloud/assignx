/// Client model for user management.
class ClientModel {
  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.totalProjects = 0,
    this.activeProjects = 0,
    this.completedProjects = 0,
    this.totalSpent = 0.0,
    this.joinedAt,
    this.lastActiveAt,
    this.isVerified = false,
    this.notes,
  });

  /// Unique client ID.
  final String id;

  /// Client name.
  final String name;

  /// Client email.
  final String email;

  /// Client phone number.
  final String? phone;

  /// Avatar URL.
  final String? avatarUrl;

  /// Total projects with this supervisor.
  final int totalProjects;

  /// Currently active projects.
  final int activeProjects;

  /// Completed projects.
  final int completedProjects;

  /// Total amount spent on projects.
  final double totalSpent;

  /// When client joined the platform.
  final DateTime? joinedAt;

  /// Last activity timestamp.
  final DateTime? lastActiveAt;

  /// Whether email is verified.
  final bool isVerified;

  /// Supervisor's notes about the client.
  final String? notes;

  /// Initials for avatar.
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '??';
  }

  /// Last active time ago string.
  String get lastActiveTimeAgo {
    if (lastActiveAt == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastActiveAt!);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      totalProjects: json['total_projects'] as int? ?? 0,
      activeProjects: json['active_projects'] as int? ?? 0,
      completedProjects: json['completed_projects'] as int? ?? 0,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.parse(json['last_active_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'total_projects': totalProjects,
      'active_projects': activeProjects,
      'completed_projects': completedProjects,
      'total_spent': totalSpent,
      'joined_at': joinedAt?.toIso8601String(),
      'last_active_at': lastActiveAt?.toIso8601String(),
      'is_verified': isVerified,
      'notes': notes,
    };
  }

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    int? totalProjects,
    int? activeProjects,
    int? completedProjects,
    double? totalSpent,
    DateTime? joinedAt,
    DateTime? lastActiveAt,
    bool? isVerified,
    String? notes,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalProjects: totalProjects ?? this.totalProjects,
      activeProjects: activeProjects ?? this.activeProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      totalSpent: totalSpent ?? this.totalSpent,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      isVerified: isVerified ?? this.isVerified,
      notes: notes ?? this.notes,
    );
  }
}

/// Client project history item.
class ClientProjectHistory {
  const ClientProjectHistory({
    required this.projectId,
    required this.title,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.amount,
    this.rating,
  });

  final String projectId;
  final String title;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final double? amount;
  final int? rating;

  /// Formatted date.
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  factory ClientProjectHistory.fromJson(Map<String, dynamic> json) {
    return ClientProjectHistory(
      projectId: json['project_id'] as String? ?? json['id'] as String,
      title: json['title'] as String? ?? 'Untitled Project',
      status: json['status'] as String? ?? 'unknown',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      amount: (json['amount'] as num?)?.toDouble(),
      rating: json['rating'] as int?,
    );
  }
}

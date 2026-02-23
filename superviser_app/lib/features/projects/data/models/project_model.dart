import '../../domain/entities/project_status.dart';

/// Model representing a project in the system.
///
/// Contains all project details including status, deadlines, and assignments.
class ProjectModel {
  const ProjectModel({
    required this.id,
    required this.projectNumber,
    required this.title,
    required this.description,
    required this.subject,
    required this.status,
    required this.userId,
    required this.supervisorId,
    this.doerId,
    this.deadline,
    this.wordCount,
    this.pageCount,
    this.userQuote,
    this.doerAmount,
    this.supervisorAmount,
    this.platformAmount,
    this.clientName,
    this.clientEmail,
    this.doerName,
    this.attachments,
    this.chatRoomId,
    this.instructions,
    this.revisionCount = 0,
    this.isUrgent = false,
    required this.createdAt,
    this.updatedAt,
    this.submittedAt,
    this.paidAt,
    this.assignedAt,
    this.startedAt,
    this.deliveredAt,
    this.completedAt,
  });

  /// Unique identifier
  final String id;

  /// Human-readable project number (e.g., PRJ-2025-0001)
  final String projectNumber;

  /// Project title
  final String title;

  /// Project description/requirements
  final String description;

  /// Subject/field of the project
  final String subject;

  /// Current project status
  final ProjectStatus status;

  /// Client user ID
  final String userId;

  /// Assigned supervisor ID
  final String supervisorId;

  /// Assigned doer ID (if assigned)
  final String? doerId;

  /// Project deadline
  final DateTime? deadline;

  /// Required word count
  final int? wordCount;

  /// Required page count
  final int? pageCount;

  /// Amount quoted to user
  final double? userQuote;

  /// Amount to be paid to doer
  final double? doerAmount;

  /// Supervisor commission
  final double? supervisorAmount;

  /// Platform fee
  final double? platformAmount;

  /// Client name for display
  final String? clientName;

  /// Client email
  final String? clientEmail;

  /// Doer name for display
  final String? doerName;

  /// List of attachment URLs
  final List<String>? attachments;

  /// Associated chat room ID
  final String? chatRoomId;

  /// Additional instructions
  final String? instructions;

  /// Number of revision requests
  final int revisionCount;

  /// Whether project is marked as urgent
  final bool isUrgent;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;

  /// When project was submitted
  final DateTime? submittedAt;

  /// When payment was received
  final DateTime? paidAt;

  /// When doer was assigned
  final DateTime? assignedAt;

  /// When work started
  final DateTime? startedAt;

  /// When work was delivered
  final DateTime? deliveredAt;

  /// When project was completed
  final DateTime? completedAt;

  /// Creates a ProjectModel from JSON data.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] as String,
      projectNumber: json['project_number'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      subject: json['subject'] is Map
          ? json['subject']['name'] as String
          : json['subject'] as String? ?? 'General',
      status: ProjectStatus.fromString(json['status'] as String?),
      userId: json['user_id'] as String,
      supervisorId: json['supervisor_id'] as String,
      doerId: json['doer_id'] as String?,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      wordCount: json['word_count'] as int?,
      pageCount: json['page_count'] as int?,
      userQuote: (json['user_quote'] as num?)?.toDouble(),
      doerAmount: (json['doer_payout'] as num?)?.toDouble() ?? (json['doer_amount'] as num?)?.toDouble(),
      supervisorAmount: (json['supervisor_commission'] as num?)?.toDouble() ?? (json['supervisor_amount'] as num?)?.toDouble(),
      platformAmount: (json['platform_fee'] as num?)?.toDouble() ?? (json['platform_amount'] as num?)?.toDouble(),
      clientName: json['user'] is Map
          ? json['user']['full_name'] as String?
          : json['client_name'] as String?,
      clientEmail: json['user'] is Map
          ? json['user']['email'] as String?
          : json['client_email'] as String?,
      doerName: json['doer'] is Map
          ? (json['doer']['profile'] is Map
              ? json['doer']['profile']['full_name'] as String?
              : json['doer']['full_name'] as String?)
          : json['doer_name'] as String?,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      chatRoomId: json['chat_room_id'] as String?,
      instructions: json['instructions'] as String?,
      revisionCount: json['revision_count'] as int? ?? 0,
      isUrgent: json['is_urgent'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  /// Converts the model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_number': projectNumber,
      'title': title,
      'description': description,
      'subject': subject,
      'status': status.value,
      'user_id': userId,
      'supervisor_id': supervisorId,
      'doer_id': doerId,
      'deadline': deadline?.toIso8601String(),
      'word_count': wordCount,
      'page_count': pageCount,
      'user_quote': userQuote,
      'doer_amount': doerAmount,
      'supervisor_amount': supervisorAmount,
      'platform_amount': platformAmount,
      'client_name': clientName,
      'client_email': clientEmail,
      'doer_name': doerName,
      'attachments': attachments,
      'chat_room_id': chatRoomId,
      'instructions': instructions,
      'revision_count': revisionCount,
      'is_urgent': isUrgent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'assigned_at': assignedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  ProjectModel copyWith({
    String? id,
    String? projectNumber,
    String? title,
    String? description,
    String? subject,
    ProjectStatus? status,
    String? userId,
    String? supervisorId,
    String? doerId,
    DateTime? deadline,
    int? wordCount,
    int? pageCount,
    double? userQuote,
    double? doerAmount,
    double? supervisorAmount,
    double? platformAmount,
    String? clientName,
    String? clientEmail,
    String? doerName,
    List<String>? attachments,
    String? chatRoomId,
    String? instructions,
    int? revisionCount,
    bool? isUrgent,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? paidAt,
    DateTime? assignedAt,
    DateTime? startedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      projectNumber: projectNumber ?? this.projectNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      supervisorId: supervisorId ?? this.supervisorId,
      doerId: doerId ?? this.doerId,
      deadline: deadline ?? this.deadline,
      wordCount: wordCount ?? this.wordCount,
      pageCount: pageCount ?? this.pageCount,
      userQuote: userQuote ?? this.userQuote,
      doerAmount: doerAmount ?? this.doerAmount,
      supervisorAmount: supervisorAmount ?? this.supervisorAmount,
      platformAmount: platformAmount ?? this.platformAmount,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      doerName: doerName ?? this.doerName,
      attachments: attachments ?? this.attachments,
      chatRoomId: chatRoomId ?? this.chatRoomId,
      instructions: instructions ?? this.instructions,
      revisionCount: revisionCount ?? this.revisionCount,
      isUrgent: isUrgent ?? this.isUrgent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      paidAt: paidAt ?? this.paidAt,
      assignedAt: assignedAt ?? this.assignedAt,
      startedAt: startedAt ?? this.startedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  /// Formatted deadline string.
  String get formattedDeadline {
    if (deadline == null) return 'No deadline';
    final now = DateTime.now();
    final diff = deadline!.difference(now);

    if (diff.isNegative) {
      return 'Overdue';
    } else if (diff.inDays == 0) {
      if (diff.inHours < 1) {
        return '${diff.inMinutes}m left';
      }
      return '${diff.inHours}h left';
    } else if (diff.inDays == 1) {
      return 'Tomorrow';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days';
    }
    return '${deadline!.day}/${deadline!.month}/${deadline!.year}';
  }

  /// Whether deadline has passed.
  bool get isOverdue {
    if (deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }

  /// Time remaining until deadline.
  Duration? get timeRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now());
  }

  /// Whether payment has been received.
  bool get isPaid => paidAt != null || status.index >= ProjectStatus.paid.index;

  /// Whether project has been assigned.
  bool get isAssigned => doerId != null;

  /// Total project amount.
  double get totalAmount =>
      (doerAmount ?? 0) + (supervisorAmount ?? 0) + (platformAmount ?? 0);
}

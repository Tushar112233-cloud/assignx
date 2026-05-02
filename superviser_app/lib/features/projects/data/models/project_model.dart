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
    this.topic,
    this.focusAreas,
    this.serviceType,
    this.liveDocumentUrl,
    this.progressPercentage,
    this.files,
    this.aiReportUrl,
    this.aiScore,
    this.plagiarismReportUrl,
    this.plagiarismScore,
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

  /// Project topic
  final String? topic;

  /// Focus areas for the project
  final List<String>? focusAreas;

  /// Service type (e.g., writing, editing)
  final String? serviceType;

  /// Live document URL (e.g., Google Docs link)
  final String? liveDocumentUrl;

  /// Progress percentage (0-100)
  final int? progressPercentage;

  /// Client-uploaded reference files
  final List<ProjectFile>? files;

  /// AI check report URL
  final String? aiReportUrl;

  /// AI check score
  final double? aiScore;

  /// Plagiarism report URL
  final String? plagiarismReportUrl;

  /// Plagiarism check score
  final double? plagiarismScore;

  /// Creates a ProjectModel from JSON data.
  ///
  /// Handles both flat Supabase-style and nested MongoDB/Mongoose-style responses.
  /// MongoDB may return populated objects for userId/supervisorId/doerId and
  /// nested sub-documents for pricing, payment, delivery, qualityCheck.
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    // Helper to extract ID from a field that may be a string or populated object.
    String _extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value.toString();
    }

    // Helper to extract string ID or null from a possibly populated field.
    String? _extractIdOrNull(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        final id = value['_id'] ?? value['id'];
        return id?.toString();
      }
      return value.toString();
    }

    // Helper to extract a display name from a populated object.
    String? _extractName(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) {
        return (value['fullName'] ?? value['full_name'] ?? value['name']) as String?;
      }
      return null;
    }

    // Helper to safely parse a double from various types.
    double? _parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper to safely parse DateTime.
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Extract nested sub-documents (MongoDB Mongoose style).
    final pricing = json['pricing'] as Map<String, dynamic>? ?? {};
    final payment = json['payment'] as Map<String, dynamic>? ?? {};
    final delivery = json['delivery'] as Map<String, dynamic>? ?? {};
    final qualityCheck = json['qualityCheck'] as Map<String, dynamic>?
        ?? json['quality_check'] as Map<String, dynamic>? ?? {};

    // Handle subject - prefer explicit name fields, fall back to populated object.
    String subject = 'General';
    final subjectName = json['subject_name'] ?? json['subject'];
    final subjectObj = json['subjectId'] ?? json['subject_id'];
    if (subjectName is String && subjectName.isNotEmpty && !subjectName.contains(RegExp(r'^[0-9a-f]{24}$'))) {
      // It's a readable name, not an ObjectId
      subject = subjectName;
    } else if (subjectObj is Map<String, dynamic>) {
      subject = (subjectObj['name'] as String?) ?? 'General';
    } else if (subjectName is String && subjectName.isNotEmpty) {
      subject = subjectName;
    }

    // Handle userId - may be a populated object.
    final userRaw = json['user_id'] ?? json['userId'] ?? json['user'];

    // Handle supervisorId - may be a populated object.
    final supervisorRaw = json['supervisor_id'] ?? json['supervisorId'];

    // Handle doerId - may be a populated object.
    final doerRaw = json['doer_id'] ?? json['doerId'] ?? json['doer'];

    // Extract client name: try populated user object, then explicit fields.
    String? clientName;
    if (json['user'] is Map) {
      clientName = (json['user']['fullName'] ?? json['user']['full_name']) as String?;
    }
    clientName ??= _extractName(json['user_id'] ?? json['userId']);
    clientName ??= json['client_name'] as String?;
    clientName ??= json['clientName'] as String?;

    // Extract client email.
    String? clientEmail;
    if (json['user'] is Map) {
      clientEmail = json['user']['email'] as String?;
    }
    final userIdPopulated = json['user_id'] ?? json['userId'];
    if (userIdPopulated is Map<String, dynamic>) {
      clientEmail ??= userIdPopulated['email'] as String?;
    }
    clientEmail ??= json['client_email'] as String?;

    // Extract doer name: try populated doer object, then explicit fields.
    String? doerName;
    if (json['doer'] is Map) {
      final doerObj = json['doer'] as Map<String, dynamic>;
      if (doerObj['profile'] is Map) {
        doerName = doerObj['profile']['full_name'] as String?;
      }
      doerName ??= (doerObj['fullName'] ?? doerObj['full_name']) as String?;
    }
    doerName ??= _extractName(json['doer_id'] ?? json['doerId']);
    doerName ??= json['doer_name'] as String?;
    doerName ??= json['doerName'] as String?;

    return ProjectModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      projectNumber: (json['project_number'] ?? json['projectNumber'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
      subject: subject,
      status: ProjectStatus.fromString((json['status'] ?? '').toString()),
      // Extract IDs from potentially populated objects.
      userId: _extractId(userRaw),
      supervisorId: _extractId(supervisorRaw),
      doerId: _extractIdOrNull(doerRaw),
      deadline: _parseDate(json['deadline']),
      wordCount: (json['word_count'] ?? json['wordCount']) as int?,
      pageCount: (json['page_count'] ?? json['pageCount']) as int?,
      // Pricing: check nested pricing object, then flat fields.
      userQuote: _parseDouble(json['user_quote'] ?? json['userQuote']
          ?? pricing['userQuote']),
      doerAmount: _parseDouble(json['doer_payout'] ?? json['doerPayout']
          ?? pricing['doerPayout']),
      supervisorAmount: _parseDouble(json['supervisor_commission']
          ?? json['supervisorCommission'] ?? pricing['supervisorCommission']),
      platformAmount: _parseDouble(json['platform_fee'] ?? json['platformFee']
          ?? pricing['platformFee']),
      clientName: clientName,
      clientEmail: clientEmail,
      doerName: doerName,
      attachments: (json['attachments'] as List?)?.map((e) => e.toString()).toList(),
      chatRoomId: (json['chat_room_id'] ?? json['chatRoomId']) as String?,
      instructions: (json['specific_instructions'] ?? json['specificInstructions']) as String?,
      revisionCount: (json['revision_count'] ?? json['revisionCount']) as int? ?? 0,
      isUrgent: json['is_urgent'] as bool? ?? false,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      submittedAt: _parseDate(json['submitted_at'] ?? json['submittedAt']),
      // Payment: check nested payment object, then flat fields.
      paidAt: _parseDate(json['paid_at'] ?? json['paidAt'] ?? payment['paidAt']),
      assignedAt: _parseDate(json['doer_assigned_at'] ?? json['doerAssignedAt']),
      startedAt: _parseDate(json['started_at'] ?? json['startedAt']),
      // Delivery: check nested delivery object, then flat fields.
      deliveredAt: _parseDate(json['delivered_at'] ?? json['deliveredAt']
          ?? delivery['deliveredAt']),
      completedAt: _parseDate(json['completed_at'] ?? json['completedAt']
          ?? delivery['completedAt']),
      // New fields
      topic: (json['topic'] as String?),
      focusAreas: (json['focusAreas'] as List?)?.map((e) => e.toString()).toList()
          ?? (json['focus_areas'] as List?)?.map((e) => e.toString()).toList(),
      serviceType: (json['serviceType'] ?? json['service_type']) as String?,
      liveDocumentUrl: (json['liveDocumentUrl'] ?? json['live_document_url']
          ?? qualityCheck['liveDocumentUrl']) as String?,
      progressPercentage: (json['progressPercentage'] ?? json['progress_percentage']) as int?,
      files: (json['files'] as List?)
          ?.map((f) => ProjectFile.fromJson(f as Map<String, dynamic>))
          .toList(),
      aiReportUrl: (qualityCheck['aiReportUrl'] ?? json['ai_report_url']) as String?,
      aiScore: _parseDouble(qualityCheck['aiScore'] ?? json['ai_score']),
      plagiarismReportUrl: (qualityCheck['plagiarismReportUrl']
          ?? json['plagiarism_report_url']) as String?,
      plagiarismScore: _parseDouble(qualityCheck['plagiarismScore']
          ?? json['plagiarism_score']),
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
      'doer_payout': doerAmount,
      'supervisor_commission': supervisorAmount,
      'platform_fee': platformAmount,
      'specific_instructions': instructions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'doer_assigned_at': assignedAt?.toIso8601String(),
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
    String? topic,
    List<String>? focusAreas,
    String? serviceType,
    String? liveDocumentUrl,
    int? progressPercentage,
    List<ProjectFile>? files,
    String? aiReportUrl,
    double? aiScore,
    String? plagiarismReportUrl,
    double? plagiarismScore,
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
      topic: topic ?? this.topic,
      focusAreas: focusAreas ?? this.focusAreas,
      serviceType: serviceType ?? this.serviceType,
      liveDocumentUrl: liveDocumentUrl ?? this.liveDocumentUrl,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      files: files ?? this.files,
      aiReportUrl: aiReportUrl ?? this.aiReportUrl,
      aiScore: aiScore ?? this.aiScore,
      plagiarismReportUrl: plagiarismReportUrl ?? this.plagiarismReportUrl,
      plagiarismScore: plagiarismScore ?? this.plagiarismScore,
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

/// Model representing a file attached to a project (client-uploaded references).
class ProjectFile {
  const ProjectFile({
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSizeBytes,
    this.fileCategory,
    this.uploadedBy,
    this.uploadedByRole,
    this.createdAt,
  });

  /// Original file name
  final String fileName;

  /// File URL in storage
  final String fileUrl;

  /// MIME type
  final String? fileType;

  /// File size in bytes
  final int? fileSizeBytes;

  /// Category (e.g., reference, requirement)
  final String? fileCategory;

  /// Uploader user ID
  final String? uploadedBy;

  /// Role of uploader (user, doer, supervisor)
  final String? uploadedByRole;

  /// Upload timestamp
  final DateTime? createdAt;

  /// Creates a ProjectFile from JSON.
  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    return ProjectFile(
      fileName: (json['fileName'] ?? json['file_name'] ?? '') as String,
      fileUrl: (json['fileUrl'] ?? json['file_url'] ?? '') as String,
      fileType: (json['fileType'] ?? json['file_type']) as String?,
      fileSizeBytes: (json['fileSizeBytes'] ?? json['file_size_bytes']) as int?,
      fileCategory: (json['fileCategory'] ?? json['file_category']) as String?,
      uploadedBy: json['uploadedBy']?.toString() ?? json['uploaded_by']?.toString(),
      uploadedByRole: (json['uploadedByRole'] ?? json['uploaded_by_role']) as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  /// Formatted file size string.
  String get formattedSize {
    if (fileSizeBytes == null) return '';
    if (fileSizeBytes! < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes! < 1024 * 1024) {
      return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// File extension.
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}

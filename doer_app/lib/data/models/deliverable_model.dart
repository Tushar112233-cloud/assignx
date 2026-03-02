/// Deliverable models for the Doer application.
///
/// These models match the Supabase project_deliverables table.
library;

/// Deliverable model representing uploaded work files.
class DeliverableModel {
  final String id;
  final String projectId;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSizeBytes;
  final int version;
  final bool isFinal;
  final QCStatus qcStatus;
  final String? qcNotes;
  final String? qcBy;
  final DateTime? qcAt;
  final String uploadedBy;
  final String? uploaderName;
  final String? uploaderAvatarUrl;
  final DateTime createdAt;

  /// Formatted file size string.
  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// File extension in uppercase.
  String get extension {
    if (!fileName.contains('.')) return 'FILE';
    return fileName.split('.').last.toUpperCase();
  }

  /// Whether this deliverable is pending QC review.
  bool get isPendingReview => qcStatus == QCStatus.pending;

  /// Whether this deliverable was approved.
  bool get isApproved => qcStatus == QCStatus.approved;

  /// Whether revision was requested for this deliverable.
  bool get needsRevision => qcStatus == QCStatus.revisionRequested;

  const DeliverableModel({
    required this.id,
    required this.projectId,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSizeBytes,
    required this.version,
    this.isFinal = false,
    required this.qcStatus,
    this.qcNotes,
    this.qcBy,
    this.qcAt,
    required this.uploadedBy,
    this.uploaderName,
    this.uploaderAvatarUrl,
    required this.createdAt,
  });

  factory DeliverableModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Handle nested uploader (may be a populated Mongoose object).
    String? uploaderName;
    String? uploaderAvatarUrl;
    final uploaderRaw = json['uploader'] ?? json['uploadedBy'];
    if (uploaderRaw != null && uploaderRaw is Map) {
      uploaderName = (uploaderRaw['full_name'] ?? uploaderRaw['fullName']) as String?;
      uploaderAvatarUrl = (uploaderRaw['avatar_url'] ?? uploaderRaw['avatarUrl']) as String?;
    }

    // Handle projectId which may be a populated Mongoose object.
    String projectId = '';
    final rawProjectId = json['project_id'] ?? json['projectId'];
    if (rawProjectId is String) {
      projectId = rawProjectId;
    } else if (rawProjectId is Map<String, dynamic>) {
      projectId = (rawProjectId['_id'] ?? rawProjectId['id'] ?? '').toString();
    }

    // Handle uploadedBy which may be a populated Mongoose object.
    String uploadedBy = '';
    final rawUploadedBy = json['uploaded_by'] ?? json['uploadedBy'];
    if (rawUploadedBy is String) {
      uploadedBy = rawUploadedBy;
    } else if (rawUploadedBy is Map<String, dynamic>) {
      uploadedBy = (rawUploadedBy['_id'] ?? rawUploadedBy['id'] ?? '').toString();
    }

    return DeliverableModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      projectId: projectId,
      fileUrl: (json['file_url'] ?? json['fileUrl'] ?? '').toString(),
      fileName: (json['file_name'] ?? json['fileName'] ?? '').toString(),
      fileType: (json['file_type'] ?? json['fileType'] ?? 'application/octet-stream').toString(),
      fileSizeBytes: (json['file_size_bytes'] ?? json['fileSizeBytes']) as int? ?? 0,
      version: json['version'] as int? ?? 1,
      isFinal: json['is_final'] as bool? ?? json['isFinal'] as bool? ?? false,
      qcStatus: QCStatus.fromString((json['qc_status'] ?? json['qcStatus'] ?? 'pending').toString()),
      qcNotes: json['qc_notes'] as String? ?? json['qcNotes'] as String?,
      qcBy: json['qc_by'] as String? ?? json['qcBy'] as String?,
      qcAt: _parseDate(json['qc_at'] ?? json['qcAt']),
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      uploaderAvatarUrl: uploaderAvatarUrl,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
    );
  }

  DeliverableModel copyWith({
    String? id,
    String? projectId,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSizeBytes,
    int? version,
    bool? isFinal,
    QCStatus? qcStatus,
    String? qcNotes,
    String? qcBy,
    DateTime? qcAt,
    String? uploadedBy,
    String? uploaderName,
    String? uploaderAvatarUrl,
    DateTime? createdAt,
  }) {
    return DeliverableModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      version: version ?? this.version,
      isFinal: isFinal ?? this.isFinal,
      qcStatus: qcStatus ?? this.qcStatus,
      qcNotes: qcNotes ?? this.qcNotes,
      qcBy: qcBy ?? this.qcBy,
      qcAt: qcAt ?? this.qcAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      uploaderAvatarUrl: uploaderAvatarUrl ?? this.uploaderAvatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// QC Status enum matching Supabase values.
enum QCStatus {
  pending('pending'),
  inReview('in_review'),
  approved('approved'),
  revisionRequested('revision_requested'),
  rejected('rejected');

  final String value;
  const QCStatus(this.value);

  static QCStatus fromString(String value) {
    return QCStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => QCStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case QCStatus.pending:
        return 'Pending Review';
      case QCStatus.inReview:
        return 'Under Review';
      case QCStatus.approved:
        return 'Approved';
      case QCStatus.revisionRequested:
        return 'Revision Needed';
      case QCStatus.rejected:
        return 'Rejected';
    }
  }
}

/// Revision request model.
class RevisionRequest {
  final String id;
  final String projectId;
  final String requestedBy;
  final String? requesterName;
  final String feedback;
  final List<String> issues;
  final bool isResolved;
  final DateTime? resolvedAt;
  final DateTime createdAt;

  const RevisionRequest({
    required this.id,
    required this.projectId,
    required this.requestedBy,
    this.requesterName,
    required this.feedback,
    this.issues = const [],
    this.isResolved = false,
    this.resolvedAt,
    required this.createdAt,
  });

  factory RevisionRequest.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Handle nested requester (may be a populated Mongoose object).
    String? requesterName;
    final requesterRaw = json['requester'] ?? json['requestedBy'];
    if (requesterRaw != null && requesterRaw is Map) {
      requesterName = (requesterRaw['full_name'] ?? requesterRaw['fullName']) as String?;
    }

    // Handle issues array.
    List<String> issues = [];
    if (json['issues'] != null && json['issues'] is List) {
      issues = (json['issues'] as List).map((e) => e.toString()).toList();
    }

    // Handle projectId which may be a populated Mongoose object.
    String projectId = '';
    final rawProjectId = json['project_id'] ?? json['projectId'];
    if (rawProjectId is String) {
      projectId = rawProjectId;
    } else if (rawProjectId is Map<String, dynamic>) {
      projectId = (rawProjectId['_id'] ?? rawProjectId['id'] ?? '').toString();
    }

    // Handle requestedBy which may be a populated Mongoose object.
    String requestedBy = '';
    final rawRequestedBy = json['requested_by'] ?? json['requestedBy'];
    if (rawRequestedBy is String) {
      requestedBy = rawRequestedBy;
    } else if (rawRequestedBy is Map<String, dynamic>) {
      requestedBy = (rawRequestedBy['_id'] ?? rawRequestedBy['id'] ?? '').toString();
    }

    return RevisionRequest(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      projectId: projectId,
      requestedBy: requestedBy,
      requesterName: requesterName,
      feedback: json['feedback'] as String? ?? '',
      issues: issues,
      isResolved: json['is_resolved'] as bool? ?? json['isResolved'] as bool? ?? false,
      resolvedAt: _parseDate(json['resolved_at'] ?? json['resolvedAt']),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
    );
  }
}

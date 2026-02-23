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
    // Handle nested uploader
    String? uploaderName;
    String? uploaderAvatarUrl;
    if (json['uploader'] != null && json['uploader'] is Map) {
      uploaderName = json['uploader']['full_name'] as String?;
      uploaderAvatarUrl = json['uploader']['avatar_url'] as String?;
    }

    return DeliverableModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String? ?? 'application/octet-stream',
      fileSizeBytes: json['file_size_bytes'] as int? ?? 0,
      version: json['version'] as int? ?? 1,
      isFinal: json['is_final'] as bool? ?? false,
      qcStatus: QCStatus.fromString(json['qc_status'] as String? ?? 'pending'),
      qcNotes: json['qc_notes'] as String?,
      qcBy: json['qc_by'] as String?,
      qcAt: json['qc_at'] != null
          ? DateTime.parse(json['qc_at'] as String)
          : null,
      uploadedBy: json['uploaded_by'] as String,
      uploaderName: uploaderName,
      uploaderAvatarUrl: uploaderAvatarUrl,
      createdAt: DateTime.parse(json['created_at'] as String),
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
    // Handle nested requester
    String? requesterName;
    if (json['requester'] != null && json['requester'] is Map) {
      requesterName = json['requester']['full_name'] as String?;
    }

    // Handle issues array
    List<String> issues = [];
    if (json['issues'] != null && json['issues'] is List) {
      issues = (json['issues'] as List).cast<String>();
    }

    return RevisionRequest(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      requestedBy: json['requested_by'] as String,
      requesterName: requesterName,
      feedback: json['feedback'] as String? ?? '',
      issues: issues,
      isResolved: json['is_resolved'] as bool? ?? false,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

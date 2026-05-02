/// Model representing a project deliverable (file submission).
///
/// Tracks files uploaded by doers for review.
class DeliverableModel {
  const DeliverableModel({
    required this.id,
    required this.projectId,
    required this.fileUrl,
    required this.fileName,
    this.fileType,
    this.fileSize,
    this.uploadedBy,
    this.uploaderName,
    this.description,
    this.version = 1,
    this.isApproved,
    this.reviewerNotes,
    required this.createdAt,
  });

  /// Unique identifier
  final String id;

  /// Parent project ID
  final String projectId;

  /// File URL in storage
  final String fileUrl;

  /// Original file name
  final String fileName;

  /// MIME type
  final String? fileType;

  /// File size in bytes
  final int? fileSize;

  /// Uploader user ID
  final String? uploadedBy;

  /// Uploader name for display
  final String? uploaderName;

  /// File description/notes
  final String? description;

  /// Version number (for revisions)
  final int version;

  /// Whether file has been approved
  final bool? isApproved;

  /// Notes from reviewer
  final String? reviewerNotes;

  /// Upload timestamp
  final DateTime createdAt;

  /// Creates a DeliverableModel from JSON.
  ///
  /// Handles both Supabase flat format and MongoDB nested format.
  factory DeliverableModel.fromJson(Map<String, dynamic> json) {
    // Derive isApproved from qc_status string column
    bool? isApproved;
    final qcStatus = (json['qc_status'] ?? json['qcStatus']) as String?;
    if (qcStatus != null) {
      isApproved = qcStatus == 'approved';
    }

    // Helper to extract ID from a field that may be a string or populated object.
    String _extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value.toString();
    }

    // Helper to safely parse DateTime.
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Handle uploadedBy which may be a populated object.
    final uploadedByRaw = json['uploaded_by'] ?? json['uploadedBy'];
    String? uploadedBy;
    String? uploaderName;
    if (uploadedByRaw is Map<String, dynamic>) {
      uploadedBy = (uploadedByRaw['_id'] ?? uploadedByRaw['id'])?.toString();
      uploaderName = (uploadedByRaw['fullName'] ?? uploadedByRaw['full_name']) as String?;
    } else if (uploadedByRaw is String) {
      uploadedBy = uploadedByRaw;
    }
    // Supabase-style joined uploader.
    if (json['uploader'] is Map) {
      uploaderName ??= (json['uploader']['fullName'] ?? json['uploader']['full_name']) as String?;
    }
    uploaderName ??= (json['uploader_name'] ?? json['uploaderName']) as String?;

    return DeliverableModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      projectId: _extractId(json['project_id'] ?? json['projectId']),
      fileUrl: (json['file_url'] ?? json['fileUrl'] ?? '') as String,
      fileName: (json['file_name'] ?? json['fileName'] ?? '') as String,
      fileType: (json['file_type'] ?? json['fileType']) as String?,
      fileSize: (json['file_size_bytes'] ?? json['fileSizeBytes'] ?? json['fileSize']) as int?,
      uploadedBy: uploadedBy,
      uploaderName: uploaderName,
      description: json['description'] as String?,
      version: json['version'] as int? ?? 1,
      isApproved: isApproved,
      reviewerNotes: (json['qc_notes'] ?? json['qcNotes'] ?? json['reviewerNotes']) as String?,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'file_url': fileUrl,
      'file_name': fileName,
      'file_type': fileType,
      'file_size': fileSize,
      'uploaded_by': uploadedBy,
      'uploader_name': uploaderName,
      'description': description,
      'version': version,
      'is_approved': isApproved,
      'reviewer_notes': reviewerNotes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  DeliverableModel copyWith({
    String? id,
    String? projectId,
    String? fileUrl,
    String? fileName,
    String? fileType,
    int? fileSize,
    String? uploadedBy,
    String? uploaderName,
    String? description,
    int? version,
    bool? isApproved,
    String? reviewerNotes,
    DateTime? createdAt,
  }) {
    return DeliverableModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      description: description ?? this.description,
      version: version ?? this.version,
      isApproved: isApproved ?? this.isApproved,
      reviewerNotes: reviewerNotes ?? this.reviewerNotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formatted file size string.
  String get formattedSize {
    if (fileSize == null) return 'Unknown';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Whether the file is an image.
  bool get isImage {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp');
  }

  /// Whether the file is a PDF.
  bool get isPdf => fileName.toLowerCase().endsWith('.pdf');

  /// Whether the file is a document.
  bool get isDocument {
    final ext = fileName.toLowerCase();
    return ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.txt') ||
        ext.endsWith('.rtf');
  }

  /// File extension.
  String get extension {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }
}

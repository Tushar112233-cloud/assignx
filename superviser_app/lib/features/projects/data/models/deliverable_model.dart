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
  factory DeliverableModel.fromJson(Map<String, dynamic> json) {
    return DeliverableModel(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String?,
      fileSize: json['file_size'] as int?,
      uploadedBy: json['uploaded_by'] as String?,
      uploaderName: json['uploader'] is Map
          ? json['uploader']['full_name'] as String?
          : json['uploader_name'] as String?,
      description: json['description'] as String?,
      version: json['version'] as int? ?? 1,
      isApproved: json['is_approved'] as bool?,
      reviewerNotes: json['reviewer_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
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

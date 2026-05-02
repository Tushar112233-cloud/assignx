/// Deliverable file for a project matching project_deliverables table.
class ProjectDeliverable {
  /// Unique identifier.
  final String id;

  /// Project this deliverable belongs to.
  final String projectId;

  /// Original file name.
  final String fileName;

  /// URL to download the file.
  final String fileUrl;

  /// MIME type of the file.
  final String? fileType;

  /// Size of the file in bytes.
  final int? fileSizeBytes;

  /// Version number of this deliverable.
  final int version;

  /// Whether this is the final version.
  final bool isFinal;

  /// QC status (pending, approved, rejected).
  final String? qcStatus;

  /// Notes from QC review.
  final String? qcNotes;

  /// User ID who performed QC.
  final String? qcBy;

  /// When QC was performed.
  final DateTime? qcAt;

  /// User ID who uploaded this file.
  final String uploadedBy;

  /// When this file was uploaded.
  final DateTime createdAt;

  /// Creates a new [ProjectDeliverable].
  const ProjectDeliverable({
    required this.id,
    required this.projectId,
    required this.fileName,
    required this.fileUrl,
    this.fileType,
    this.fileSizeBytes,
    this.version = 1,
    this.isFinal = false,
    this.qcStatus,
    this.qcNotes,
    this.qcBy,
    this.qcAt,
    required this.uploadedBy,
    required this.createdAt,
  });

  /// Creates a [ProjectDeliverable] from JSON data.
  ///
  /// Handles both the normalized API format (which uses `name`, `url`, `size`)
  /// and the raw MongoDB format (which uses `fileName`, `fileUrl`, etc.).
  factory ProjectDeliverable.fromJson(Map<String, dynamic> json) {
    // Parse file size: API may return a human-readable string like "1.2 MB"
    // or a numeric value in bytes.
    int? parseFileSize(dynamic sizeValue, dynamic bytesValue) {
      // Prefer raw bytes if available
      if (bytesValue != null) {
        if (bytesValue is num) return bytesValue.toInt();
        if (bytesValue is String) return int.tryParse(bytesValue);
      }
      // The API returns `size` as a formatted string like "1.2 MB" or "500 KB"
      if (sizeValue is num) return sizeValue.toInt();
      if (sizeValue is String) {
        final numericOnly = int.tryParse(sizeValue);
        if (numericOnly != null) return numericOnly;
        // Don't try to parse "1.2 MB" strings back to bytes -- leave as null
      }
      return null;
    }

    return ProjectDeliverable(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
      // API returns `name` for deliverables, raw format uses `fileName`
      fileName: (json['file_name'] ?? json['fileName'] ?? json['name'] ?? '').toString(),
      // API returns `url` for deliverables, raw format uses `fileUrl`
      fileUrl: (json['file_url'] ?? json['fileUrl'] ?? json['url'] ?? '').toString(),
      fileType: (json['file_type'] ?? json['fileType']) as String?,
      fileSizeBytes: parseFileSize(
        json['size'],
        json['file_size_bytes'] ?? json['fileSizeBytes'],
      ),
      version: json['version'] as int? ?? 1,
      isFinal: (json['is_final'] ?? json['isFinal']) as bool? ?? false,
      qcStatus: (json['qc_status'] ?? json['qcStatus']) as String?,
      qcNotes: (json['qc_notes'] ?? json['qcNotes']) as String?,
      qcBy: (json['qc_by'] ?? json['qcBy']) as String?,
      qcAt: (json['qc_at'] ?? json['qcAt']) != null
          ? DateTime.tryParse((json['qc_at'] ?? json['qcAt']).toString())
          : null,
      uploadedBy: (json['uploaded_by'] ?? json['uploadedBy'] ?? '').toString(),
      createdAt: DateTime.tryParse(
        (json['created_at'] ?? json['createdAt'] ?? json['uploadedAt'] ?? '').toString(),
      ) ?? DateTime.now(),
    );
  }

  /// Converts this [ProjectDeliverable] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size_bytes': fileSizeBytes,
      'version': version,
      'is_final': isFinal,
      'qc_status': qcStatus,
      'qc_notes': qcNotes,
      'qc_by': qcBy,
      'qc_at': qcAt?.toIso8601String(),
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy with modified fields.
  ProjectDeliverable copyWith({
    String? id,
    String? projectId,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSizeBytes,
    int? version,
    bool? isFinal,
    String? qcStatus,
    String? qcNotes,
    String? qcBy,
    DateTime? qcAt,
    String? uploadedBy,
    DateTime? createdAt,
  }) {
    return ProjectDeliverable(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      version: version ?? this.version,
      isFinal: isFinal ?? this.isFinal,
      qcStatus: qcStatus ?? this.qcStatus,
      qcNotes: qcNotes ?? this.qcNotes,
      qcBy: qcBy ?? this.qcBy,
      qcAt: qcAt ?? this.qcAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formatted file size for display.
  String get formattedSize {
    if (fileSizeBytes == null) return '';
    if (fileSizeBytes! < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes! < 1024 * 1024) {
      return '${(fileSizeBytes! / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

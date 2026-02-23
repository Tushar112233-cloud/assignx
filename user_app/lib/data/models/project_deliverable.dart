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
  factory ProjectDeliverable.fromJson(Map<String, dynamic> json) {
    return ProjectDeliverable(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String?,
      fileSizeBytes: json['file_size_bytes'] != null
          ? (json['file_size_bytes'] as num).toInt()
          : null,
      version: json['version'] as int? ?? 1,
      isFinal: json['is_final'] as bool? ?? false,
      qcStatus: json['qc_status'] as String?,
      qcNotes: json['qc_notes'] as String?,
      qcBy: json['qc_by'] as String?,
      qcAt: json['qc_at'] != null
          ? DateTime.parse(json['qc_at'] as String)
          : null,
      uploadedBy: json['uploaded_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
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

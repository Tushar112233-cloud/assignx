/// Doer-specific project model matching the Supabase projects table.
///
/// This model is used by doers to view and work on their assigned projects.
/// It includes all fields relevant to the doer's workflow.
library;

/// Doer project model with full Supabase schema support.
class DoerProjectModel {
  /// Unique identifier (UUID).
  final String id;

  /// Human-readable project number (e.g., PRJ-2025-0001).
  final String projectNumber;

  /// Project title.
  final String title;

  /// Detailed description and instructions.
  final String? description;

  /// Specific topic within the subject.
  final String? topic;

  /// Subject name (joined from subjects table).
  final String? subjectName;

  /// Subject ID for matching.
  final String? subjectId;

  /// Current project status.
  final DoerProjectStatus status;

  /// Deadline for completion.
  final DateTime deadline;

  /// Original deadline (if extended).
  final DateTime? originalDeadline;

  /// Whether deadline was extended.
  final bool deadlineExtended;

  /// Reason for deadline extension.
  final String? deadlineExtensionReason;

  /// Amount the doer will receive (their payout).
  final double doerPayout;

  /// Required word count.
  final int? wordCount;

  /// Required page count.
  final int? pageCount;

  /// Reference style name (APA, MLA, etc.).
  final String? referenceStyleName;

  /// Specific instructions from the user.
  final String? specificInstructions;

  /// Focus areas for the project.
  final List<String> focusAreas;

  /// Current progress percentage (0-100).
  final int progressPercentage;

  /// Supervisor's name (joined from profiles).
  final String? supervisorName;

  /// Supervisor ID.
  final String? supervisorId;

  /// User/Client name (for reference only).
  final String? userName;

  /// URL to live collaborative document.
  final String? liveDocumentUrl;

  /// AI score from quality check.
  final double? aiScore;

  /// Plagiarism score from check.
  final double? plagiarismScore;

  /// When the project was created.
  final DateTime createdAt;

  /// When doer was assigned.
  final DateTime? doerAssignedAt;

  /// When work was delivered.
  final DateTime? deliveredAt;

  /// Expected delivery date.
  final DateTime? expectedDeliveryAt;

  /// When project was completed.
  final DateTime? completedAt;

  /// Completion notes from doer.
  final String? completionNotes;

  /// Whether the project is urgent (deadline within 24 hours).
  bool get isUrgent {
    final remaining = deadline.difference(DateTime.now());
    return remaining.inHours < 24 && !remaining.isNegative;
  }

  /// Whether deadline has passed.
  bool get isOverdue => DateTime.now().isAfter(deadline);

  /// Time remaining until deadline.
  Duration get timeRemaining => deadline.difference(DateTime.now());

  /// Formatted payout string.
  String get formattedPayout => '₹${doerPayout.toStringAsFixed(0)}';

  /// Whether the project can be worked on.
  bool get canWork => status == DoerProjectStatus.assigned ||
                      status == DoerProjectStatus.inProgress ||
                      status == DoerProjectStatus.revisionRequested;

  /// Whether the project can be submitted.
  bool get canSubmit => status == DoerProjectStatus.inProgress && progressPercentage >= 50;

  /// Whether project has revision requests.
  bool get hasRevision =>
      status == DoerProjectStatus.revisionRequested ||
      status == DoerProjectStatus.inRevision;

  /// Subject name (alias for subjectName).
  String? get subject => subjectName;

  /// Project price (alias for doerPayout).
  double get price => doerPayout;

  /// Reference style (alias for referenceStyleName).
  String? get referenceStyle => referenceStyleName;

  /// Project requirements as a list (from focusAreas or specificInstructions).
  List<String> get requirements {
    if (focusAreas.isNotEmpty) return focusAreas;
    if (specificInstructions != null && specificInstructions!.isNotEmpty) {
      return [specificInstructions!];
    }
    if (description != null && description!.isNotEmpty) {
      return [description!];
    }
    return [];
  }

  /// Hours until deadline.
  int get hoursUntilDeadline => timeRemaining.inHours;

  const DoerProjectModel({
    required this.id,
    required this.projectNumber,
    required this.title,
    this.description,
    this.topic,
    this.subjectName,
    this.subjectId,
    required this.status,
    required this.deadline,
    this.originalDeadline,
    this.deadlineExtended = false,
    this.deadlineExtensionReason,
    required this.doerPayout,
    this.wordCount,
    this.pageCount,
    this.referenceStyleName,
    this.specificInstructions,
    this.focusAreas = const [],
    this.progressPercentage = 0,
    this.supervisorName,
    this.supervisorId,
    this.userName,
    this.liveDocumentUrl,
    this.aiScore,
    this.plagiarismScore,
    required this.createdAt,
    this.doerAssignedAt,
    this.deliveredAt,
    this.expectedDeliveryAt,
    this.completedAt,
    this.completionNotes,
  });

  /// Creates from Supabase JSON response.
  factory DoerProjectModel.fromJson(Map<String, dynamic> json) {
    // Handle nested subject
    String? subjectName;
    String? subjectId;
    if (json['subject'] != null && json['subject'] is Map) {
      subjectName = json['subject']['name'] as String?;
      subjectId = json['subject']['id'] as String?;
    }

    // Handle nested supervisor
    String? supervisorName;
    String? supervisorId;
    if (json['supervisor'] != null && json['supervisor'] is Map) {
      supervisorName = json['supervisor']['full_name'] as String?;
      supervisorId = json['supervisor']['id'] as String?;
    }

    // Handle nested user
    String? userName;
    if (json['user'] != null && json['user'] is Map) {
      userName = json['user']['full_name'] as String?;
    }

    // Handle nested reference style
    String? referenceStyleName;
    if (json['reference_style'] != null && json['reference_style'] is Map) {
      referenceStyleName = json['reference_style']['name'] as String? ??
                          json['reference_style']['slug'] as String?;
    }

    // Handle focus_areas array
    List<String> focusAreas = [];
    if (json['focus_areas'] != null && json['focus_areas'] is List) {
      focusAreas = (json['focus_areas'] as List).cast<String>();
    }

    return DoerProjectModel(
      id: json['id'] as String,
      projectNumber: json['project_number'] as String? ?? 'PRJ-UNKNOWN',
      title: json['title'] as String,
      description: json['description'] as String?,
      topic: json['topic'] as String?,
      subjectName: subjectName ?? json['subject_name'] as String?,
      subjectId: subjectId ?? json['subject_id'] as String?,
      status: DoerProjectStatus.fromString(json['status'] as String? ?? 'pending'),
      deadline: DateTime.parse(json['deadline'] as String),
      originalDeadline: json['original_deadline'] != null
          ? DateTime.parse(json['original_deadline'] as String)
          : null,
      deadlineExtended: json['deadline_extended'] as bool? ?? false,
      deadlineExtensionReason: json['deadline_extension_reason'] as String?,
      doerPayout: (json['doer_payout'] as num?)?.toDouble() ?? 0.0,
      wordCount: json['word_count'] as int?,
      pageCount: json['page_count'] as int?,
      referenceStyleName: referenceStyleName,
      specificInstructions: json['specific_instructions'] as String?,
      focusAreas: focusAreas,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      supervisorName: supervisorName,
      supervisorId: supervisorId ?? json['supervisor_id'] as String?,
      userName: userName,
      liveDocumentUrl: json['live_document_url'] as String?,
      aiScore: (json['ai_score'] as num?)?.toDouble(),
      plagiarismScore: (json['plagiarism_score'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      doerAssignedAt: json['doer_assigned_at'] != null
          ? DateTime.parse(json['doer_assigned_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      expectedDeliveryAt: json['expected_delivery_at'] != null
          ? DateTime.parse(json['expected_delivery_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completionNotes: json['completion_notes'] as String?,
    );
  }

  /// Creates a copy with updated fields.
  DoerProjectModel copyWith({
    String? id,
    String? projectNumber,
    String? title,
    String? description,
    String? topic,
    String? subjectName,
    String? subjectId,
    DoerProjectStatus? status,
    DateTime? deadline,
    DateTime? originalDeadline,
    bool? deadlineExtended,
    String? deadlineExtensionReason,
    double? doerPayout,
    int? wordCount,
    int? pageCount,
    String? referenceStyleName,
    String? specificInstructions,
    List<String>? focusAreas,
    int? progressPercentage,
    String? supervisorName,
    String? supervisorId,
    String? userName,
    String? liveDocumentUrl,
    double? aiScore,
    double? plagiarismScore,
    DateTime? createdAt,
    DateTime? doerAssignedAt,
    DateTime? deliveredAt,
    DateTime? expectedDeliveryAt,
    DateTime? completedAt,
    String? completionNotes,
  }) {
    return DoerProjectModel(
      id: id ?? this.id,
      projectNumber: projectNumber ?? this.projectNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      topic: topic ?? this.topic,
      subjectName: subjectName ?? this.subjectName,
      subjectId: subjectId ?? this.subjectId,
      status: status ?? this.status,
      deadline: deadline ?? this.deadline,
      originalDeadline: originalDeadline ?? this.originalDeadline,
      deadlineExtended: deadlineExtended ?? this.deadlineExtended,
      deadlineExtensionReason: deadlineExtensionReason ?? this.deadlineExtensionReason,
      doerPayout: doerPayout ?? this.doerPayout,
      wordCount: wordCount ?? this.wordCount,
      pageCount: pageCount ?? this.pageCount,
      referenceStyleName: referenceStyleName ?? this.referenceStyleName,
      specificInstructions: specificInstructions ?? this.specificInstructions,
      focusAreas: focusAreas ?? this.focusAreas,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      supervisorName: supervisorName ?? this.supervisorName,
      supervisorId: supervisorId ?? this.supervisorId,
      userName: userName ?? this.userName,
      liveDocumentUrl: liveDocumentUrl ?? this.liveDocumentUrl,
      aiScore: aiScore ?? this.aiScore,
      plagiarismScore: plagiarismScore ?? this.plagiarismScore,
      createdAt: createdAt ?? this.createdAt,
      doerAssignedAt: doerAssignedAt ?? this.doerAssignedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      expectedDeliveryAt: expectedDeliveryAt ?? this.expectedDeliveryAt,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
    );
  }
}

/// Project status enum matching Supabase enum values.
enum DoerProjectStatus {
  /// Draft project.
  draft('draft'),

  /// Submitted by user.
  submitted('submitted'),

  /// Being analyzed.
  analyzing('analyzing'),

  /// Quote sent, awaiting payment.
  quoted('quoted'),

  /// Awaiting payment.
  paymentPending('payment_pending'),

  /// Payment received.
  paid('paid'),

  /// Being assigned to a doer.
  assigning('assigning'),

  /// Assigned to doer, not started.
  assigned('assigned'),

  /// Doer is actively working.
  inProgress('in_progress'),

  /// Submitted for QC review.
  submittedForQc('submitted_for_qc'),

  /// QC review in progress.
  qcInProgress('qc_in_progress'),

  /// QC approved.
  qcApproved('qc_approved'),

  /// QC rejected.
  qcRejected('qc_rejected'),

  /// Delivered to client.
  delivered('delivered'),

  /// Revision requested by supervisor.
  revisionRequested('revision_requested'),

  /// Doer working on revision.
  inRevision('in_revision'),

  /// Client approved, project complete.
  completed('completed'),

  /// Auto-approved after timeout.
  autoApproved('auto_approved'),

  /// Project cancelled.
  cancelled('cancelled'),

  /// Payment refunded.
  refunded('refunded');

  final String value;
  const DoerProjectStatus(this.value);

  static DoerProjectStatus fromString(String value) {
    return DoerProjectStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DoerProjectStatus.draft,
    );
  }

  /// Display name for UI.
  String get displayName {
    switch (this) {
      case DoerProjectStatus.draft:
        return 'Draft';
      case DoerProjectStatus.submitted:
        return 'Submitted';
      case DoerProjectStatus.analyzing:
        return 'Analyzing';
      case DoerProjectStatus.quoted:
        return 'Quoted';
      case DoerProjectStatus.paymentPending:
        return 'Payment Pending';
      case DoerProjectStatus.paid:
        return 'Paid';
      case DoerProjectStatus.assigning:
        return 'Available';
      case DoerProjectStatus.assigned:
        return 'Assigned';
      case DoerProjectStatus.inProgress:
        return 'In Progress';
      case DoerProjectStatus.submittedForQc:
        return 'Under Review';
      case DoerProjectStatus.qcInProgress:
        return 'QC In Progress';
      case DoerProjectStatus.qcApproved:
        return 'QC Approved';
      case DoerProjectStatus.qcRejected:
        return 'QC Rejected';
      case DoerProjectStatus.delivered:
        return 'Delivered';
      case DoerProjectStatus.revisionRequested:
        return 'Revision Needed';
      case DoerProjectStatus.inRevision:
        return 'In Revision';
      case DoerProjectStatus.completed:
        return 'Completed';
      case DoerProjectStatus.autoApproved:
        return 'Auto Approved';
      case DoerProjectStatus.cancelled:
        return 'Cancelled';
      case DoerProjectStatus.refunded:
        return 'Refunded';
    }
  }

  /// Whether this is an active working status.
  bool get isActive => this == assigned ||
                       this == inProgress ||
                       this == revisionRequested ||
                       this == inRevision;

  /// Whether doer can accept this project.
  bool get canAccept => this == assigning;

  /// Whether this is a completed/final status.
  bool get isFinal => this == completed ||
                      this == autoApproved ||
                      this == cancelled ||
                      this == refunded;
}

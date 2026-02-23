import 'project_deliverable.dart';
import 'project_status.dart';
import 'project_timeline.dart';
import 'service_type.dart';

/// Main project model matching the projects table.
class Project {
  /// Unique identifier (UUID).
  final String id;

  /// Human-readable project number (e.g., AE-2024-001).
  final String projectNumber;

  /// User who created this project.
  final String userId;

  /// Type of service requested.
  final ServiceType serviceType;

  /// Project title.
  final String title;

  /// Subject/category ID (references subjects table).
  final String? subjectId;

  /// Subject name (populated from joined data).
  final String? subjectName;

  /// Specific topic within the subject.
  final String? topic;

  /// Project description.
  final String? description;

  /// Required word count.
  final int? wordCount;

  /// Required page count.
  final int? pageCount;

  /// Reference style ID (references reference_styles table).
  final String? referenceStyleId;

  /// Specific instructions from user.
  final String? specificInstructions;

  /// Focus areas for the project.
  final List<String>? focusAreas;

  /// Project deadline.
  final DateTime deadline;

  /// Original deadline (before any extensions).
  final DateTime? originalDeadline;

  /// Whether deadline was extended.
  final bool deadlineExtended;

  /// Reason for deadline extension.
  final String? deadlineExtensionReason;

  /// Current project status.
  final ProjectStatus status;

  /// When status was last updated.
  final DateTime? statusUpdatedAt;

  /// Assigned supervisor ID.
  final String? supervisorId;

  /// When supervisor was assigned.
  final DateTime? supervisorAssignedAt;

  /// Assigned doer (expert) ID.
  final String? doerId;

  /// When doer was assigned.
  final DateTime? doerAssignedAt;

  /// Quote amount shown to user.
  final double? userQuote;

  /// Payout to the doer.
  final double? doerPayout;

  /// Commission for the supervisor.
  final double? supervisorCommission;

  /// Platform fee.
  final double? platformFee;

  /// Whether payment has been received.
  final bool isPaid;

  /// When payment was received.
  final DateTime? paidAt;

  /// Payment transaction ID.
  final String? paymentId;

  /// When project was delivered.
  final DateTime? deliveredAt;

  /// Expected delivery date.
  final DateTime? expectedDeliveryAt;

  /// When project will be auto-approved.
  final DateTime? autoApproveAt;

  /// URL to AI detection report.
  final String? aiReportUrl;

  /// AI detection score (0-100, lower is more human).
  final double? aiScore;

  /// URL to plagiarism report.
  final String? plagiarismReportUrl;

  /// Plagiarism score (0-100, lower is better).
  final double? plagiarismScore;

  /// URL to live document (Google Docs, etc.).
  final String? liveDocumentUrl;

  /// Progress percentage (0-100).
  final int progressPercentage;

  /// When project was completed.
  final DateTime? completedAt;

  /// Notes about completion.
  final String? completionNotes;

  /// Whether user approved the delivery.
  final bool? userApproved;

  /// When user approved.
  final DateTime? userApprovedAt;

  /// Feedback from user.
  final String? userFeedback;

  /// Grade received by user.
  final String? userGrade;

  /// When project was cancelled.
  final DateTime? cancelledAt;

  /// Who cancelled the project.
  final String? cancelledBy;

  /// Reason for cancellation.
  final String? cancellationReason;

  /// Source of project creation (app, web, etc.).
  final String? source;

  /// When project was created.
  final DateTime createdAt;

  /// When project was last updated.
  final DateTime? updatedAt;

  /// Deliverable files.
  final List<ProjectDeliverable> deliverables;

  /// Reference files uploaded by user.
  final List<ProjectDeliverable> referenceFiles;

  /// Timeline events.
  final List<ProjectTimelineEvent> timeline;

  /// Revision feedback if status is revision.
  final String? revisionFeedback;

  /// Creates a new [Project].
  const Project({
    required this.id,
    required this.projectNumber,
    required this.userId,
    required this.serviceType,
    required this.title,
    this.subjectId,
    this.subjectName,
    this.topic,
    this.description,
    this.wordCount,
    this.pageCount,
    this.referenceStyleId,
    this.specificInstructions,
    this.focusAreas,
    required this.deadline,
    this.originalDeadline,
    this.deadlineExtended = false,
    this.deadlineExtensionReason,
    required this.status,
    this.statusUpdatedAt,
    this.supervisorId,
    this.supervisorAssignedAt,
    this.doerId,
    this.doerAssignedAt,
    this.userQuote,
    this.doerPayout,
    this.supervisorCommission,
    this.platformFee,
    this.isPaid = false,
    this.paidAt,
    this.paymentId,
    this.deliveredAt,
    this.expectedDeliveryAt,
    this.autoApproveAt,
    this.aiReportUrl,
    this.aiScore,
    this.plagiarismReportUrl,
    this.plagiarismScore,
    this.liveDocumentUrl,
    this.progressPercentage = 0,
    this.completedAt,
    this.completionNotes,
    this.userApproved,
    this.userApprovedAt,
    this.userFeedback,
    this.userGrade,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.source,
    required this.createdAt,
    this.updatedAt,
    this.deliverables = const [],
    this.referenceFiles = const [],
    this.timeline = const [],
    this.revisionFeedback,
  });

  /// Project ID in display format (uses projectNumber).
  String get displayId => '#$projectNumber';

  /// Quote amount formatted for display.
  String get formattedQuote {
    if (userQuote == null) return 'Pending';
    return '\u20B9${userQuote!.toStringAsFixed(0)}';
  }

  /// Whether payment is pending.
  bool get isPendingPayment => status == ProjectStatus.paymentPending;

  /// Whether the project can be approved by user.
  bool get canApprove => status == ProjectStatus.delivered;

  /// Whether the deadline is approaching (less than 24 hours).
  bool get isDeadlineUrgent {
    final now = DateTime.now();
    return deadline.difference(now).inHours < 24 && deadline.isAfter(now);
  }

  /// Whether the deadline has passed.
  bool get isDeadlinePassed => deadline.isBefore(DateTime.now());

  /// Time remaining until deadline.
  Duration get timeUntilDeadline => deadline.difference(DateTime.now());

  /// Time remaining until auto-approval.
  Duration? get timeUntilAutoApproval {
    if (autoApproveAt == null) return null;
    return autoApproveAt!.difference(DateTime.now());
  }

  /// Creates a [Project] from JSON data.
  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      projectNumber: json['project_number'] as String,
      userId: json['user_id'] as String,
      serviceType: ServiceTypeX.fromString(json['service_type'] as String),
      title: json['title'] as String,
      subjectId: json['subject_id'] as String?,
      subjectName: json['subject_name'] as String? ??
          (json['subjects'] != null
              ? (json['subjects'] as Map<String, dynamic>)['name'] as String?
              : null),
      topic: json['topic'] as String?,
      description: json['description'] as String?,
      wordCount: json['word_count'] as int?,
      pageCount: json['page_count'] as int?,
      referenceStyleId: json['reference_style_id'] as String?,
      specificInstructions: json['specific_instructions'] as String?,
      focusAreas: (json['focus_areas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      deadline: DateTime.parse(json['deadline'] as String),
      originalDeadline: json['original_deadline'] != null
          ? DateTime.parse(json['original_deadline'] as String)
          : null,
      deadlineExtended: json['deadline_extended'] as bool? ?? false,
      deadlineExtensionReason: json['deadline_extension_reason'] as String?,
      status: ProjectStatusX.fromString(json['status'] as String),
      statusUpdatedAt: json['status_updated_at'] != null
          ? DateTime.parse(json['status_updated_at'] as String)
          : null,
      supervisorId: json['supervisor_id'] as String?,
      supervisorAssignedAt: json['supervisor_assigned_at'] != null
          ? DateTime.parse(json['supervisor_assigned_at'] as String)
          : null,
      doerId: json['doer_id'] as String?,
      doerAssignedAt: json['doer_assigned_at'] != null
          ? DateTime.parse(json['doer_assigned_at'] as String)
          : null,
      userQuote: json['user_quote'] != null
          ? (json['user_quote'] as num).toDouble()
          : null,
      doerPayout: json['doer_payout'] != null
          ? (json['doer_payout'] as num).toDouble()
          : null,
      supervisorCommission: json['supervisor_commission'] != null
          ? (json['supervisor_commission'] as num).toDouble()
          : null,
      platformFee: json['platform_fee'] != null
          ? (json['platform_fee'] as num).toDouble()
          : null,
      isPaid: json['is_paid'] as bool? ?? false,
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      paymentId: json['payment_id'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      expectedDeliveryAt: json['expected_delivery_at'] != null
          ? DateTime.parse(json['expected_delivery_at'] as String)
          : null,
      autoApproveAt: json['auto_approve_at'] != null
          ? DateTime.parse(json['auto_approve_at'] as String)
          : null,
      aiReportUrl: json['ai_report_url'] as String?,
      aiScore: json['ai_score'] != null
          ? (json['ai_score'] as num).toDouble()
          : null,
      plagiarismReportUrl: json['plagiarism_report_url'] as String?,
      plagiarismScore: json['plagiarism_score'] != null
          ? (json['plagiarism_score'] as num).toDouble()
          : null,
      liveDocumentUrl: json['live_document_url'] as String?,
      progressPercentage: json['progress_percentage'] as int? ?? 0,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      completionNotes: json['completion_notes'] as String?,
      userApproved: json['user_approved'] as bool?,
      userApprovedAt: json['user_approved_at'] != null
          ? DateTime.parse(json['user_approved_at'] as String)
          : null,
      userFeedback: json['user_feedback'] as String?,
      userGrade: json['user_grade'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancelledBy: json['cancelled_by'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      source: json['source'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      deliverables: (json['deliverables'] as List<dynamic>?)
              ?.map(
                  (e) => ProjectDeliverable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['project_deliverables'] as List<dynamic>?)
              ?.map(
                  (e) => ProjectDeliverable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      referenceFiles: (json['reference_files'] as List<dynamic>?)
              ?.map(
                  (e) => ProjectDeliverable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) =>
                  ProjectTimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['project_timeline'] as List<dynamic>?)
              ?.map((e) =>
                  ProjectTimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revisionFeedback: json['revision_feedback'] as String?,
    );
  }

  /// Converts this [Project] to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_number': projectNumber,
      'user_id': userId,
      'service_type': serviceType.toDbString(),
      'title': title,
      'subject_id': subjectId,
      'topic': topic,
      'description': description,
      'word_count': wordCount,
      'page_count': pageCount,
      'reference_style_id': referenceStyleId,
      'specific_instructions': specificInstructions,
      'focus_areas': focusAreas,
      'deadline': deadline.toIso8601String(),
      'original_deadline': originalDeadline?.toIso8601String(),
      'deadline_extended': deadlineExtended,
      'deadline_extension_reason': deadlineExtensionReason,
      'status': status.toDbString(),
      'status_updated_at': statusUpdatedAt?.toIso8601String(),
      'supervisor_id': supervisorId,
      'supervisor_assigned_at': supervisorAssignedAt?.toIso8601String(),
      'doer_id': doerId,
      'doer_assigned_at': doerAssignedAt?.toIso8601String(),
      'user_quote': userQuote,
      'doer_payout': doerPayout,
      'supervisor_commission': supervisorCommission,
      'platform_fee': platformFee,
      'is_paid': isPaid,
      'paid_at': paidAt?.toIso8601String(),
      'payment_id': paymentId,
      'delivered_at': deliveredAt?.toIso8601String(),
      'expected_delivery_at': expectedDeliveryAt?.toIso8601String(),
      'auto_approve_at': autoApproveAt?.toIso8601String(),
      'ai_report_url': aiReportUrl,
      'ai_score': aiScore,
      'plagiarism_report_url': plagiarismReportUrl,
      'plagiarism_score': plagiarismScore,
      'live_document_url': liveDocumentUrl,
      'progress_percentage': progressPercentage,
      'completed_at': completedAt?.toIso8601String(),
      'completion_notes': completionNotes,
      'user_approved': userApproved,
      'user_approved_at': userApprovedAt?.toIso8601String(),
      'user_feedback': userFeedback,
      'user_grade': userGrade,
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancelled_by': cancelledBy,
      'cancellation_reason': cancellationReason,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deliverables': deliverables.map((e) => e.toJson()).toList(),
      'reference_files': referenceFiles.map((e) => e.toJson()).toList(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
      'revision_feedback': revisionFeedback,
    };
  }

  /// Creates a copy with modified fields.
  Project copyWith({
    String? id,
    String? projectNumber,
    String? userId,
    ServiceType? serviceType,
    String? title,
    String? subjectId,
    String? subjectName,
    String? topic,
    String? description,
    int? wordCount,
    int? pageCount,
    String? referenceStyleId,
    String? specificInstructions,
    List<String>? focusAreas,
    DateTime? deadline,
    DateTime? originalDeadline,
    bool? deadlineExtended,
    String? deadlineExtensionReason,
    ProjectStatus? status,
    DateTime? statusUpdatedAt,
    String? supervisorId,
    DateTime? supervisorAssignedAt,
    String? doerId,
    DateTime? doerAssignedAt,
    double? userQuote,
    double? doerPayout,
    double? supervisorCommission,
    double? platformFee,
    bool? isPaid,
    DateTime? paidAt,
    String? paymentId,
    DateTime? deliveredAt,
    DateTime? expectedDeliveryAt,
    DateTime? autoApproveAt,
    String? aiReportUrl,
    double? aiScore,
    String? plagiarismReportUrl,
    double? plagiarismScore,
    String? liveDocumentUrl,
    int? progressPercentage,
    DateTime? completedAt,
    String? completionNotes,
    bool? userApproved,
    DateTime? userApprovedAt,
    String? userFeedback,
    String? userGrade,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ProjectDeliverable>? deliverables,
    List<ProjectDeliverable>? referenceFiles,
    List<ProjectTimelineEvent>? timeline,
    String? revisionFeedback,
  }) {
    return Project(
      id: id ?? this.id,
      projectNumber: projectNumber ?? this.projectNumber,
      userId: userId ?? this.userId,
      serviceType: serviceType ?? this.serviceType,
      title: title ?? this.title,
      subjectId: subjectId ?? this.subjectId,
      subjectName: subjectName ?? this.subjectName,
      topic: topic ?? this.topic,
      description: description ?? this.description,
      wordCount: wordCount ?? this.wordCount,
      pageCount: pageCount ?? this.pageCount,
      referenceStyleId: referenceStyleId ?? this.referenceStyleId,
      specificInstructions: specificInstructions ?? this.specificInstructions,
      focusAreas: focusAreas ?? this.focusAreas,
      deadline: deadline ?? this.deadline,
      originalDeadline: originalDeadline ?? this.originalDeadline,
      deadlineExtended: deadlineExtended ?? this.deadlineExtended,
      deadlineExtensionReason:
          deadlineExtensionReason ?? this.deadlineExtensionReason,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      supervisorId: supervisorId ?? this.supervisorId,
      supervisorAssignedAt: supervisorAssignedAt ?? this.supervisorAssignedAt,
      doerId: doerId ?? this.doerId,
      doerAssignedAt: doerAssignedAt ?? this.doerAssignedAt,
      userQuote: userQuote ?? this.userQuote,
      doerPayout: doerPayout ?? this.doerPayout,
      supervisorCommission: supervisorCommission ?? this.supervisorCommission,
      platformFee: platformFee ?? this.platformFee,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      paymentId: paymentId ?? this.paymentId,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      expectedDeliveryAt: expectedDeliveryAt ?? this.expectedDeliveryAt,
      autoApproveAt: autoApproveAt ?? this.autoApproveAt,
      aiReportUrl: aiReportUrl ?? this.aiReportUrl,
      aiScore: aiScore ?? this.aiScore,
      plagiarismReportUrl: plagiarismReportUrl ?? this.plagiarismReportUrl,
      plagiarismScore: plagiarismScore ?? this.plagiarismScore,
      liveDocumentUrl: liveDocumentUrl ?? this.liveDocumentUrl,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      completedAt: completedAt ?? this.completedAt,
      completionNotes: completionNotes ?? this.completionNotes,
      userApproved: userApproved ?? this.userApproved,
      userApprovedAt: userApprovedAt ?? this.userApprovedAt,
      userFeedback: userFeedback ?? this.userFeedback,
      userGrade: userGrade ?? this.userGrade,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelledBy: cancelledBy ?? this.cancelledBy,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliverables: deliverables ?? this.deliverables,
      referenceFiles: referenceFiles ?? this.referenceFiles,
      timeline: timeline ?? this.timeline,
      revisionFeedback: revisionFeedback ?? this.revisionFeedback,
    );
  }
}

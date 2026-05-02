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
  ///
  /// Handles both flat Supabase-style and nested MongoDB/Mongoose-style responses.
  /// MongoDB may return populated objects for userId/supervisorId/doerId and
  /// nested sub-documents for pricing, payment, delivery, qualityCheck, userApproval.
  factory Project.fromJson(Map<String, dynamic> json) {
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
        return (value['_id'] ?? value['id'] ?? '').toString();
      }
      return value.toString();
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

    // Helper to safely parse bool from any type.
    bool _parseBool(dynamic v, [bool fallback = false]) {
      if (v == null) return fallback;
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true' || v == '1';
      if (v is num) return v != 0;
      return fallback;
    }

    // Extract nested sub-documents (MongoDB Mongoose style).
    final pricing = json['pricing'] is Map<String, dynamic> ? json['pricing'] as Map<String, dynamic> : <String, dynamic>{};
    final payment = json['payment'] is Map<String, dynamic> ? json['payment'] as Map<String, dynamic> : <String, dynamic>{};
    final delivery = json['delivery'] is Map<String, dynamic> ? json['delivery'] as Map<String, dynamic> : <String, dynamic>{};
    final qualityCheck = json['qualityCheck'] is Map<String, dynamic> ? json['qualityCheck'] as Map<String, dynamic> : (json['quality_check'] is Map<String, dynamic> ? json['quality_check'] as Map<String, dynamic> : <String, dynamic>{});
    final userApproval = json['userApproval'] is Map<String, dynamic> ? json['userApproval'] as Map<String, dynamic> : (json['user_approval'] is Map<String, dynamic> ? json['user_approval'] as Map<String, dynamic> : <String, dynamic>{});

    // Extract subject info from populated subjectId.
    final subjectRaw = json['subjectId'] ?? json['subject_id'];
    String? subjectId;
    String? subjectName;
    if (subjectRaw is Map<String, dynamic>) {
      subjectId = (subjectRaw['_id'] ?? subjectRaw['id'] ?? '').toString();
      subjectName = subjectRaw['name'] as String?;
    } else if (subjectRaw is String) {
      subjectId = subjectRaw;
    }
    // Override with explicit fields if present.
    subjectId = (json['subject_id'] is String ? json['subject_id'] : null) ?? subjectId;
    subjectName = (json['subject_name'] ?? json['subjectName']) as String? ??
        subjectName ??
        (json['subjects'] is Map<String, dynamic>
            ? (json['subjects'] as Map<String, dynamic>)['name'] as String?
            : null);

    // Extract referenceStyleId (may be populated).
    final refStyleRaw = json['referenceStyleId'] ?? json['reference_style_id'];
    String? referenceStyleId;
    if (refStyleRaw is Map<String, dynamic>) {
      referenceStyleId = (refStyleRaw['_id'] ?? refStyleRaw['id'] ?? '').toString();
    } else if (refStyleRaw is String) {
      referenceStyleId = refStyleRaw;
    }

    return Project(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      projectNumber: (json['project_number'] ?? json['projectNumber'] ?? '').toString(),
      userId: _extractId(json['user_id'] ?? json['userId']),
      serviceType: ServiceTypeX.fromString((json['service_type'] ?? json['serviceType'] ?? '').toString()),
      title: (json['title'] as String?) ?? '',
      subjectId: subjectId,
      subjectName: subjectName,
      topic: json['topic'] as String?,
      description: json['description'] as String?,
      wordCount: (json['word_count'] ?? json['wordCount']) as int?,
      pageCount: (json['page_count'] ?? json['pageCount']) as int?,
      referenceStyleId: referenceStyleId,
      specificInstructions: (json['specific_instructions'] ?? json['specificInstructions']) as String?,
      focusAreas: ((json['focus_areas'] ?? json['focusAreas']) as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      deadline: _parseDate(json['deadline']) ?? DateTime.now(),
      originalDeadline: _parseDate(json['original_deadline'] ?? json['originalDeadline']),
      deadlineExtended: _parseBool(json['deadline_extended'] ?? json['deadlineExtended']),
      deadlineExtensionReason: (json['deadline_extension_reason'] ?? json['deadlineExtensionReason']) as String?,
      status: ProjectStatusX.fromString((json['status'] ?? '').toString()),
      statusUpdatedAt: _parseDate(json['status_updated_at'] ?? json['statusUpdatedAt']),
      supervisorId: _extractIdOrNull(json['supervisor_id'] ?? json['supervisorId']),
      supervisorAssignedAt: _parseDate(json['supervisor_assigned_at'] ?? json['supervisorAssignedAt']),
      doerId: _extractIdOrNull(json['doer_id'] ?? json['doerId']),
      doerAssignedAt: _parseDate(json['doer_assigned_at'] ?? json['doerAssignedAt']),
      // Pricing: check nested pricing object, then flat fields.
      userQuote: _parseDouble(json['user_quote'] ?? json['userQuote'] ?? pricing['userQuote']),
      doerPayout: _parseDouble(json['doer_payout'] ?? json['doerPayout'] ?? pricing['doerPayout']),
      supervisorCommission: _parseDouble(json['supervisor_commission'] ?? json['supervisorCommission'] ?? pricing['supervisorCommission']),
      platformFee: _parseDouble(json['platform_fee'] ?? json['platformFee'] ?? pricing['platformFee']),
      // Payment: check nested payment object, then flat fields.
      isPaid: _parseBool(json['is_paid'] ?? json['isPaid'] ?? payment['isPaid']),
      paidAt: _parseDate(json['paid_at'] ?? json['paidAt'] ?? payment['paidAt']),
      paymentId: (json['payment_id'] ?? json['paymentId'] ?? payment['paymentId']) as String?,
      // Delivery: check nested delivery object, then flat fields.
      deliveredAt: _parseDate(json['delivered_at'] ?? json['deliveredAt'] ?? delivery['deliveredAt']),
      expectedDeliveryAt: _parseDate(json['expected_delivery_at'] ?? json['expectedDeliveryAt'] ?? delivery['expectedDeliveryAt']),
      autoApproveAt: _parseDate(json['auto_approve_at'] ?? json['autoApproveAt'] ?? delivery['autoApproveAt']),
      // Quality check: check nested qualityCheck object, then flat fields.
      aiReportUrl: (json['ai_report_url'] ?? json['aiReportUrl'] ?? qualityCheck['aiReportUrl']) as String?,
      aiScore: _parseDouble(json['ai_score'] ?? json['aiScore'] ?? qualityCheck['aiScore']),
      plagiarismReportUrl: (json['plagiarism_report_url'] ?? json['plagiarismReportUrl'] ?? qualityCheck['plagiarismReportUrl']) as String?,
      plagiarismScore: _parseDouble(json['plagiarism_score'] ?? json['plagiarismScore'] ?? qualityCheck['plagiarismScore']),
      liveDocumentUrl: (json['live_document_url'] ?? json['liveDocumentUrl']) as String?,
      progressPercentage: int.tryParse((json['progress_percentage'] ?? json['progressPercentage'] ?? 0).toString()) ?? 0,
      // Completion: check nested delivery object for completedAt, then flat fields.
      completedAt: _parseDate(json['completed_at'] ?? json['completedAt'] ?? delivery['completedAt']),
      completionNotes: (json['completion_notes'] ?? json['completionNotes']) as String?,
      // User approval: check nested userApproval object, then flat fields.
      userApproved: _parseBool(json['user_approved'] ?? json['userApproved'] ?? userApproval['approved']),
      userApprovedAt: _parseDate(json['user_approved_at'] ?? json['userApprovedAt'] ?? userApproval['approvedAt']),
      userFeedback: (json['user_feedback'] ?? json['userFeedback'] ?? userApproval['feedback']) as String?,
      userGrade: (json['user_grade'] ?? json['userGrade'] ?? userApproval['grade']) as String?,
      cancelledAt: _parseDate(json['cancelled_at'] ?? json['cancelledAt']),
      cancelledBy: (json['cancelled_by'] ?? json['cancelledBy']) as String?,
      cancellationReason: (json['cancellation_reason'] ?? json['cancellationReason']) as String?,
      source: json['source'] as String?,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
      deliverables: (json['deliverables'] as List<dynamic>?)
              ?.map(
                  (e) => ProjectDeliverable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          ((json['project_deliverables'] ?? json['projectDeliverables']) as List<dynamic>?)
              ?.map(
                  (e) => ProjectDeliverable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      referenceFiles: ((json['reference_files'] ?? json['referenceFiles']) as List<dynamic>?)
              ?.map(
                  (e) => ProjectDeliverable.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) =>
                  ProjectTimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          ((json['project_timeline'] ?? json['projectTimeline']) as List<dynamic>?)
              ?.map((e) =>
                  ProjectTimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      revisionFeedback: (json['revision_feedback'] ?? json['revisionFeedback']) as String?,
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

/// Timeline event for project progress.
class ProjectTimelineEvent {
  final String id;
  final String projectId;
  final String milestoneType;
  final String milestoneTitle;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
  final int sequenceOrder;
  final DateTime? expectedAt;
  final DateTime createdAt;

  const ProjectTimelineEvent({
    required this.id,
    required this.projectId,
    required this.milestoneType,
    required this.milestoneTitle,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    required this.sequenceOrder,
    this.expectedAt,
    required this.createdAt,
  });

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    if (v is num) return v != 0;
    return false;
  }

  /// Status labels for display.
  static const _statusLabels = {
    'draft': 'Draft Created',
    'submitted': 'Project Submitted',
    'analyzing': 'Under Review',
    'quoted': 'Quote Ready',
    'payment_pending': 'Awaiting Payment',
    'paid': 'Payment Successful',
    'assigning': 'Finding Expert',
    'assigned': 'Expert Assigned',
    'in_progress': 'Work Started',
    'submitted_for_qc': 'Submitted for QC',
    'qc_in_progress': 'QC In Progress',
    'qc_approved': 'QC Approved',
    'qc_rejected': 'QC Needs Revision',
    'delivered': 'Project Delivered',
    'revision_requested': 'Revision Requested',
    'in_revision': 'In Revision',
    'completed': 'Project Completed',
    'auto_approved': 'Auto-Approved',
    'cancelled': 'Project Cancelled',
  };

  static String _titleFor(String status) {
    return _statusLabels[status] ??
        status.replaceAll('_', ' ').replaceAllMapped(
          RegExp(r'(^|\s)\w'),
          (m) => m.group(0)!.toUpperCase(),
        );
  }

  /// Creates from API JSON — handles BOTH formats:
  /// 1. Status history: { from_status, to_status, notes, created_at }
  /// 2. Milestone format: { milestoneType, milestoneTitle, isCompleted, ... }
  factory ProjectTimelineEvent.fromJson(Map<String, dynamic> json) {
    // Detect which format: status_history has 'to_status' or 'toStatus'
    final toStatus = (json['to_status'] ?? json['toStatus']) as String?;

    if (toStatus != null && toStatus.isNotEmpty) {
      // Status history format from API
      return ProjectTimelineEvent(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
        milestoneType: toStatus,
        milestoneTitle: _titleFor(toStatus),
        description: (json['notes'] as String?) ?? (json['changed_by_name'] as String?),
        isCompleted: true, // All status_history entries are completed events
        completedAt: DateTime.tryParse(
            (json['created_at'] ?? json['createdAt'] ?? '').toString()),
        sequenceOrder: 0,
        createdAt: DateTime.tryParse(
                (json['created_at'] ?? json['createdAt'] ?? '').toString()) ??
            DateTime.now(),
      );
    }

    // Legacy milestone format
    return ProjectTimelineEvent(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      projectId: (json['project_id'] ?? json['projectId'] ?? '').toString(),
      milestoneType:
          (json['milestone_type'] ?? json['milestoneType'] ?? '').toString(),
      milestoneTitle:
          (json['milestone_title'] ?? json['milestoneTitle'] ?? '').toString(),
      description: json['description'] as String?,
      isCompleted: _parseBool(json['is_completed'] ?? json['isCompleted']),
      completedAt: (json['completed_at'] ?? json['completedAt']) != null
          ? DateTime.tryParse(
              (json['completed_at'] ?? json['completedAt']).toString())
          : null,
      sequenceOrder:
          (json['sequence_order'] ?? json['sequenceOrder'] ?? 0) as int,
      expectedAt: (json['expected_at'] ?? json['expectedAt']) != null
          ? DateTime.tryParse(
              (json['expected_at'] ?? json['expectedAt']).toString())
          : null,
      createdAt: DateTime.tryParse(
              (json['created_at'] ?? json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'milestone_type': milestoneType,
      'milestone_title': milestoneTitle,
      'description': description,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'sequence_order': sequenceOrder,
      'expected_at': expectedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  ProjectTimelineEvent copyWith({
    String? id,
    String? projectId,
    String? milestoneType,
    String? milestoneTitle,
    String? description,
    bool? isCompleted,
    DateTime? completedAt,
    int? sequenceOrder,
    DateTime? expectedAt,
    DateTime? createdAt,
  }) {
    return ProjectTimelineEvent(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      milestoneType: milestoneType ?? this.milestoneType,
      milestoneTitle: milestoneTitle ?? this.milestoneTitle,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sequenceOrder: sequenceOrder ?? this.sequenceOrder,
      expectedAt: expectedAt ?? this.expectedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

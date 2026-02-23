/// Timeline event for project progress matching project_timeline table.
class ProjectTimelineEvent {
  /// Unique identifier.
  final String id;

  /// Project this event belongs to.
  final String projectId;

  /// Type of milestone (e.g., 'submission', 'payment', 'delivery').
  final String milestoneType;

  /// Display title for the milestone.
  final String milestoneTitle;

  /// Optional description.
  final String? description;

  /// Whether this milestone is completed.
  final bool isCompleted;

  /// When the milestone was completed.
  final DateTime? completedAt;

  /// Order in the timeline sequence.
  final int sequenceOrder;

  /// Expected completion date.
  final DateTime? expectedAt;

  /// When this record was created.
  final DateTime createdAt;

  /// Creates a new [ProjectTimelineEvent].
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

  /// Creates a [ProjectTimelineEvent] from JSON data.
  factory ProjectTimelineEvent.fromJson(Map<String, dynamic> json) {
    return ProjectTimelineEvent(
      id: json['id'] as String,
      projectId: json['project_id'] as String,
      milestoneType: json['milestone_type'] as String,
      milestoneTitle: json['milestone_title'] as String,
      description: json['description'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      sequenceOrder: json['sequence_order'] as int,
      expectedAt: json['expected_at'] != null
          ? DateTime.parse(json['expected_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [ProjectTimelineEvent] to JSON.
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

  /// Creates a copy with modified fields.
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

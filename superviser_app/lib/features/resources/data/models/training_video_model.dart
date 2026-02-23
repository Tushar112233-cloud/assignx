import 'package:flutter/material.dart';

/// Categories for training videos.
enum VideoCategory {
  qcBasics('qc_basics', 'QC Basics', Icons.school),
  advancedQc('advanced_qc', 'Advanced QC', Icons.workspace_premium),
  plagiarism('plagiarism', 'Plagiarism Detection', Icons.plagiarism),
  formatting('formatting', 'Formatting & Style', Icons.format_paint),
  communication('communication', 'Communication Skills', Icons.forum),
  tools('tools', 'Tools & Software', Icons.build),
  bestPractices('best_practices', 'Best Practices', Icons.star);

  const VideoCategory(this.id, this.displayName, this.icon);

  final String id;
  final String displayName;
  final IconData icon;

  /// Get color for this category.
  Color get color {
    switch (this) {
      case VideoCategory.qcBasics:
        return Colors.blue;
      case VideoCategory.advancedQc:
        return Colors.purple;
      case VideoCategory.plagiarism:
        return Colors.red;
      case VideoCategory.formatting:
        return Colors.orange;
      case VideoCategory.communication:
        return Colors.green;
      case VideoCategory.tools:
        return Colors.teal;
      case VideoCategory.bestPractices:
        return Colors.amber;
    }
  }

  /// Creates a VideoCategory from a string ID.
  static VideoCategory fromId(String id) {
    return VideoCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => VideoCategory.qcBasics,
    );
  }
}

/// Difficulty level for training content.
enum DifficultyLevel {
  beginner('beginner', 'Beginner'),
  intermediate('intermediate', 'Intermediate'),
  advanced('advanced', 'Advanced');

  const DifficultyLevel(this.id, this.displayName);

  final String id;
  final String displayName;

  Color get color {
    switch (this) {
      case DifficultyLevel.beginner:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.orange;
      case DifficultyLevel.advanced:
        return Colors.red;
    }
  }

  static DifficultyLevel fromId(String id) {
    return DifficultyLevel.values.firstWhere(
      (d) => d.id == id,
      orElse: () => DifficultyLevel.beginner,
    );
  }
}

/// Model representing a training video.
///
/// Used for supervisor training and skill development.
class TrainingVideoModel {
  const TrainingVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    this.difficulty = DifficultyLevel.beginner,
    this.isRequired = false,
    this.isCompleted = false,
    this.watchProgress = 0.0,
    this.order = 0,
    this.tags = const [],
    this.instructor,
    this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// Video title.
  final String title;

  /// Video description.
  final String description;

  /// Category of the video.
  final VideoCategory category;

  /// Thumbnail image URL.
  final String thumbnailUrl;

  /// Video playback URL.
  final String videoUrl;

  /// Duration in seconds.
  final int duration;

  /// Difficulty level.
  final DifficultyLevel difficulty;

  /// Whether this video is required for activation.
  final bool isRequired;

  /// Whether the user has completed this video.
  final bool isCompleted;

  /// Watch progress (0.0 to 1.0).
  final double watchProgress;

  /// Order in the category.
  final int order;

  /// Tags for searching.
  final List<String> tags;

  /// Instructor name.
  final String? instructor;

  /// When this video was created.
  final DateTime? createdAt;

  /// When this video was last updated.
  final DateTime? updatedAt;

  /// Get formatted duration string.
  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get watch progress percentage.
  int get watchProgressPercent => (watchProgress * 100).round();

  /// Creates a TrainingVideoModel from JSON.
  factory TrainingVideoModel.fromJson(Map<String, dynamic> json) {
    return TrainingVideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: VideoCategory.fromId(json['category'] as String? ?? 'qc_basics'),
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      videoUrl: json['video_url'] as String? ?? '',
      duration: json['duration'] as int? ?? 0,
      difficulty: DifficultyLevel.fromId(json['difficulty'] as String? ?? 'beginner'),
      isRequired: json['is_required'] as bool? ?? false,
      isCompleted: json['is_completed'] as bool? ?? false,
      watchProgress: (json['watch_progress'] as num?)?.toDouble() ?? 0.0,
      order: json['order'] as int? ?? 0,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
      instructor: json['instructor'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.id,
      'thumbnail_url': thumbnailUrl,
      'video_url': videoUrl,
      'duration': duration,
      'difficulty': difficulty.id,
      'is_required': isRequired,
      'is_completed': isCompleted,
      'watch_progress': watchProgress,
      'order': order,
      'tags': tags,
      'instructor': instructor,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  TrainingVideoModel copyWith({
    String? id,
    String? title,
    String? description,
    VideoCategory? category,
    String? thumbnailUrl,
    String? videoUrl,
    int? duration,
    DifficultyLevel? difficulty,
    bool? isRequired,
    bool? isCompleted,
    double? watchProgress,
    int? order,
    List<String>? tags,
    String? instructor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrainingVideoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      isRequired: isRequired ?? this.isRequired,
      isCompleted: isCompleted ?? this.isCompleted,
      watchProgress: watchProgress ?? this.watchProgress,
      order: order ?? this.order,
      tags: tags ?? this.tags,
      instructor: instructor ?? this.instructor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

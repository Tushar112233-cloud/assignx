import 'package:flutter/material.dart';

/// Model for a review from a client.
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.rating,
    required this.projectId,
    required this.projectTitle,
    required this.clientId,
    required this.clientName,
    required this.createdAt,
    this.comment,
    this.response,
    this.respondedAt,
    this.isPublic = true,
    this.tags = const [],
  });

  /// Unique identifier.
  final String id;

  /// Rating (1-5 stars).
  final double rating;

  /// Related project ID.
  final String projectId;

  /// Project title.
  final String projectTitle;

  /// Client ID who left review.
  final String clientId;

  /// Client name.
  final String clientName;

  /// When review was created.
  final DateTime createdAt;

  /// Review comment.
  final String? comment;

  /// Supervisor's response.
  final String? response;

  /// When responded.
  final DateTime? respondedAt;

  /// Whether review is public.
  final bool isPublic;

  /// Tags for categorization.
  final List<String> tags;

  /// Star icon color based on rating.
  Color get ratingColor {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.lightGreen;
    if (rating >= 2.5) return Colors.orange;
    if (rating >= 1.5) return Colors.deepOrange;
    return Colors.red;
  }

  /// Rating text description.
  String get ratingDescription {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Good';
    if (rating >= 2.5) return 'Average';
    if (rating >= 1.5) return 'Below Average';
    return 'Poor';
  }

  /// Formatted date.
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} weeks ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Time ago string (alias for formattedDate).
  String get timeAgo => formattedDate;

  /// Whether has a response.
  bool get hasResponse => response != null && response!.isNotEmpty;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      projectId: json['project_id'] as String? ?? '',
      projectTitle: json['project_title'] as String? ?? 'Unknown Project',
      clientId: json['client_id'] as String? ?? '',
      clientName: json['client_name'] as String? ?? 'Anonymous',
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      comment: json['comment'] as String?,
      response: json['response'] as String?,
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
      isPublic: json['is_public'] as bool? ?? true,
      tags:
          (json['tags'] as List?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'project_id': projectId,
      'project_title': projectTitle,
      'client_id': clientId,
      'client_name': clientName,
      'created_at': createdAt.toIso8601String(),
      'comment': comment,
      'response': response,
      'responded_at': respondedAt?.toIso8601String(),
      'is_public': isPublic,
      'tags': tags,
    };
  }

  ReviewModel copyWith({
    String? id,
    double? rating,
    String? projectId,
    String? projectTitle,
    String? clientId,
    String? clientName,
    DateTime? createdAt,
    String? comment,
    String? response,
    DateTime? respondedAt,
    bool? isPublic,
    List<String>? tags,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      rating: rating ?? this.rating,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      createdAt: createdAt ?? this.createdAt,
      comment: comment ?? this.comment,
      response: response ?? this.response,
      respondedAt: respondedAt ?? this.respondedAt,
      isPublic: isPublic ?? this.isPublic,
      tags: tags ?? this.tags,
    );
  }
}

/// Summary of reviews for display.
class ReviewsSummary {
  const ReviewsSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    this.recentReviews = const [],
  });

  /// Average rating (0-5).
  final double averageRating;

  /// Total number of reviews.
  final int totalReviews;

  /// Distribution of ratings (1-5 stars).
  final Map<int, int> ratingDistribution;

  /// Recent reviews.
  final List<ReviewModel> recentReviews;

  /// Get percentage for a rating.
  double getPercentage(int rating) {
    if (totalReviews == 0) return 0;
    return ((ratingDistribution[rating] ?? 0) / totalReviews) * 100;
  }

  factory ReviewsSummary.fromJson(Map<String, dynamic> json) {
    return ReviewsSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      ratingDistribution: (json['rating_distribution'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(int.parse(key), value as int)) ??
          {},
      recentReviews: (json['recent_reviews'] as List?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Filter options for reviews.
class ReviewFilter {
  const ReviewFilter({
    this.minRating,
    this.maxRating,
    this.hasComment,
    this.hasResponse,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  final double? minRating;
  final double? maxRating;
  final bool? hasComment;
  final bool? hasResponse;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  bool get hasFilters =>
      minRating != null ||
      maxRating != null ||
      hasComment != null ||
      hasResponse != null ||
      startDate != null ||
      endDate != null ||
      (searchQuery?.isNotEmpty ?? false);
}

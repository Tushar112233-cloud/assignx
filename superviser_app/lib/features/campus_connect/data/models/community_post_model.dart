library;

import 'package:flutter/material.dart';

/// Business category types for the Business Hub community feed.
enum BusinessCategory {
  all('All', Icons.dashboard_outlined),
  industryInsights('Industry Insights', Icons.lightbulb_outline),
  businessOpportunities('Business Opportunities', Icons.trending_up),
  teamBuilding('Team Building', Icons.groups_outlined),
  serviceShowcase('Service Showcase', Icons.storefront_outlined),
  recruitment('Recruitment', Icons.person_search_outlined),
  companyUpdates('Company Updates', Icons.business_outlined),
  resources('Resources', Icons.menu_book_outlined),
  events('Events', Icons.event_outlined),
  helpAdvice('Help & Advice', Icons.help_outline);

  final String label;
  final IconData icon;

  const BusinessCategory(this.label, this.icon);
}

/// Business post type for the Business Hub.
enum BusinessPostType {
  insight('Insight', Icons.lightbulb_outline),
  opportunity('Opportunity', Icons.trending_up),
  jobListing('Job Listing', Icons.work_outline),
  serviceOffer('Service Offer', Icons.storefront_outlined),
  companyUpdate('Company Update', Icons.business_outlined),
  event('Event', Icons.event_outlined),
  question('Question', Icons.help_outline),
  resource('Resource', Icons.menu_book_outlined);

  final String displayName;
  final IconData icon;

  const BusinessPostType(this.displayName, this.icon);
}

/// Post status for community posts.
enum CommunityPostStatus {
  active('Active'),
  hidden('Hidden'),
  removed('Removed');

  final String displayName;
  const CommunityPostStatus(this.displayName);
}

/// Community post model for the Business Hub.
class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userCompany;
  final BusinessCategory category;
  final BusinessPostType type;
  final String title;
  final String? description;
  final List<String>? images;
  final String? location;
  final CommunityPostStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final Map<String, dynamic>? metadata;

  const CommunityPost({
    required this.id,
    this.userId = '',
    required this.userName,
    this.userAvatar,
    this.userCompany,
    this.category = BusinessCategory.all,
    required this.type,
    required this.title,
    this.description,
    this.images,
    this.location,
    this.status = CommunityPostStatus.active,
    required this.createdAt,
    this.expiresAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.metadata,
  });

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  /// Check if post has images.
  bool get hasImages => images != null && images!.isNotEmpty;

  /// Get first image or null.
  String? get primaryImage =>
      images != null && images!.isNotEmpty ? images!.first : null;

  /// Create from JSON.
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Anonymous',
      userAvatar: json['user_avatar'] as String?,
      userCompany: json['user_company'] as String?,
      category: BusinessCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => BusinessCategory.all,
      ),
      type: BusinessPostType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => BusinessPostType.insight,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      location: json['location'] as String?,
      status: CommunityPostStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => CommunityPostStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'user_company': userCompany,
      'category': category.name,
      'type': type.name,
      'title': title,
      'description': description,
      'images': images,
      'location': location,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'is_saved': isSaved,
      'metadata': metadata,
    };
  }

  /// Create a copy with updated fields.
  CommunityPost copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userCompany,
    BusinessCategory? category,
    BusinessPostType? type,
    String? title,
    String? description,
    List<String>? images,
    String? location,
    CommunityPostStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isSaved,
    Map<String, dynamic>? metadata,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userCompany: userCompany ?? this.userCompany,
      category: category ?? this.category,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      location: location ?? this.location,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      metadata: metadata ?? this.metadata,
    );
  }
}

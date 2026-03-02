/// Community post data models for the Pro Network feature.
///
/// Defines enums and classes for professional community posts
/// including categories, post types, and the main CommunityPost model.
library;

import 'package:flutter/material.dart';

/// Category types for professional community posts.
enum ProfessionalCategory {
  all('All', 'Browse all posts', Icons.dashboard_outlined),
  jobDiscussions('Job Discussions', 'Career & job insights', Icons.work_outline),
  portfolioShowcase('Portfolio Showcase', 'Show your work', Icons.photo_library_outlined),
  skillExchange('Skill Exchange', 'Trade skills & learn', Icons.swap_horiz),
  industryNews('Industry News', 'Latest updates', Icons.newspaper_outlined),
  networking('Networking', 'Connect & collaborate', Icons.people_outline),
  freelanceOpportunities('Freelance Gigs', 'Find work', Icons.attach_money),
  tools('Tools & Resources', 'Useful tools', Icons.build_outlined),
  events('Events', 'Meetups & webinars', Icons.event_outlined),
  helpAdvice('Help & Advice', 'Ask the community', Icons.help_outline);

  final String displayName;
  final String description;
  final IconData icon;

  const ProfessionalCategory(this.displayName, this.description, this.icon);

  String get label => displayName;

  Color get color {
    switch (this) {
      case ProfessionalCategory.all:
        return const Color(0xFF64748B);
      case ProfessionalCategory.jobDiscussions:
        return const Color(0xFF3B82F6);
      case ProfessionalCategory.portfolioShowcase:
        return const Color(0xFF8B5CF6);
      case ProfessionalCategory.skillExchange:
        return const Color(0xFF009688);
      case ProfessionalCategory.industryNews:
        return const Color(0xFF2196F3);
      case ProfessionalCategory.networking:
        return const Color(0xFFE07B4C);
      case ProfessionalCategory.freelanceOpportunities:
        return const Color(0xFF4CAF50);
      case ProfessionalCategory.tools:
        return const Color(0xFF5C6BC0);
      case ProfessionalCategory.events:
        return const Color(0xFFF5A623);
      case ProfessionalCategory.helpAdvice:
        return const Color(0xFFEF4444);
    }
  }
}

/// Post type for community posts.
enum ProfessionalPostType {
  discussion('Discussion', Icons.chat_bubble_outline),
  portfolioItem('Portfolio Item', Icons.photo_library_outlined),
  skillOffer('Skill Offer', Icons.swap_horiz),
  newsArticle('News Article', Icons.newspaper_outlined),
  freelanceGig('Freelance Gig', Icons.attach_money),
  event('Event', Icons.event),
  question('Question', Icons.help_outline),
  resource('Resource', Icons.build_outlined);

  final String displayName;
  final IconData icon;

  const ProfessionalPostType(this.displayName, this.icon);
}

/// Post status.
enum PostStatus {
  active('Active'),
  closed('Closed'),
  expired('Expired'),
  hidden('Hidden');

  final String displayName;
  const PostStatus(this.displayName);
}

/// Community post model.
class CommunityPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userTitle;
  final ProfessionalCategory category;
  final ProfessionalPostType type;
  final String title;
  final String? description;
  final List<String>? images;
  final String? location;
  final PostStatus status;
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
    this.userTitle,
    this.category = ProfessionalCategory.all,
    required this.type,
    required this.title,
    this.description,
    this.images,
    this.location,
    this.status = PostStatus.active,
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
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Handle userId which may be a populated Mongoose object.
    String userId = '';
    String userName = 'Anonymous';
    String? userAvatar;
    String? userTitle;
    final rawUserId = json['user_id'] ?? json['userId'];
    if (rawUserId is String) {
      userId = rawUserId;
    } else if (rawUserId is Map<String, dynamic>) {
      userId = (rawUserId['_id'] ?? rawUserId['id'] ?? '').toString();
      userName = (rawUserId['full_name'] ?? rawUserId['fullName'] ?? rawUserId['name'] ?? 'Anonymous').toString();
      userAvatar = rawUserId['avatar_url'] as String? ?? rawUserId['avatarUrl'] as String?;
      userTitle = rawUserId['user_title'] as String? ?? rawUserId['userTitle'] as String?;
    }

    // Fall back to flat fields if not populated.
    userName = (json['user_name'] ?? json['userName'])?.toString() ?? userName;
    userAvatar = userAvatar ?? json['user_avatar'] as String? ?? json['userAvatar'] as String?;
    userTitle = userTitle ?? json['user_title'] as String? ?? json['userTitle'] as String?;

    return CommunityPost(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userTitle: userTitle,
      category: ProfessionalCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ProfessionalCategory.all,
      ),
      type: ProfessionalPostType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ProfessionalPostType.discussion,
      ),
      title: (json['title'] as String?) ?? '',
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      location: json['location'] as String?,
      status: PostStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => PostStatus.active,
      ),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      expiresAt: _parseDate(json['expires_at'] ?? json['expiresAt']),
      viewCount: (json['view_count'] ?? json['viewCount']) as int? ?? 0,
      likeCount: (json['like_count'] ?? json['likeCount']) as int? ?? 0,
      commentCount: (json['comment_count'] ?? json['commentCount']) as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? json['isLiked'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? json['isSaved'] as bool? ?? false,
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
      'user_title': userTitle,
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
    String? userTitle,
    ProfessionalCategory? category,
    ProfessionalPostType? type,
    String? title,
    String? description,
    List<String>? images,
    String? location,
    PostStatus? status,
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
      userTitle: userTitle ?? this.userTitle,
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

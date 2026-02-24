library;

import 'package:flutter/material.dart';

/// Filter categories for Business Hub.
enum BusinessCategory {
  all('All', Icons.dashboard_outlined),
  industryInsights('Industry Insights', Icons.insights_outlined),
  recruitment('Recruitment', Icons.people_outline),
  businessOpportunities('Opportunities', Icons.business_center_outlined),
  marketTrends('Market Trends', Icons.trending_up),
  leadership('Leadership', Icons.emoji_events_outlined),
  innovation('Innovation', Icons.lightbulb_outline),
  partnerships('Partnerships', Icons.handshake_outlined),
  events('Events', Icons.event_outlined),
  funding('Funding', Icons.account_balance_outlined);

  final String label;
  final IconData icon;

  const BusinessCategory(this.label, this.icon);
}

/// Post type variants for business content.
enum BusinessPostType {
  insight('Insight'),
  recruitment('Recruitment'),
  opportunity('Opportunity'),
  marketAnalysis('Market Analysis'),
  leadership('Leadership'),
  innovation('Innovation'),
  partnership('Partnership'),
  event('Event'),
  funding('Funding');

  final String label;

  const BusinessPostType(this.label);
}

/// Business Hub post model.
class BusinessHubPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userTitle;
  final String? companyName;
  final BusinessCategory category;
  final BusinessPostType postType;
  final String title;
  final String? description;
  final List<String>? images;
  final String? location;
  final List<String>? tags;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const BusinessHubPost({
    required this.id,
    this.userId = '',
    required this.userName,
    this.userAvatar,
    this.userTitle,
    this.companyName,
    this.category = BusinessCategory.all,
    this.postType = BusinessPostType.insight,
    required this.title,
    this.description,
    this.images,
    this.location,
    this.tags,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    required this.createdAt,
    this.metadata,
  });

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

  bool get hasImages => images != null && images!.isNotEmpty;

  factory BusinessHubPost.fromJson(Map<String, dynamic> json) {
    return BusinessHubPost(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['author']?['full_name'] as String? ?? 'Anonymous',
      userAvatar: json['author']?['avatar_url'] as String?,
      userTitle: json['author_title'] as String?,
      companyName: json['company_name'] as String?,
      category: BusinessCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => BusinessCategory.all,
      ),
      postType: BusinessPostType.values.firstWhere(
        (t) => t.name == json['post_type'],
        orElse: () => BusinessPostType.insight,
      ),
      title: json['title'] as String? ?? '',
      description: json['content'] as String?,
      images:
          json['images'] != null ? List<String>.from(json['images']) : null,
      location: json['location'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      likeCount: json['likes_count'] as int? ?? 0,
      commentCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

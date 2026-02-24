library;

import 'package:flutter/material.dart';

/// Filter categories for Pro Network.
enum ProfessionalCategory {
  all('All', Icons.dashboard_outlined),
  jobDiscussions('Job Discussions', Icons.work_outline),
  portfolioShowcase('Portfolio', Icons.photo_library_outlined),
  skillExchange('Skill Exchange', Icons.swap_horiz),
  industryNews('Industry News', Icons.newspaper_outlined),
  networking('Networking', Icons.people_outline),
  freelanceOpportunities('Freelance', Icons.rocket_launch_outlined),
  tools('Tools & Resources', Icons.build_outlined),
  events('Events', Icons.event_outlined),
  helpAdvice('Help & Advice', Icons.help_outline);

  final String label;
  final IconData icon;

  const ProfessionalCategory(this.label, this.icon);
}

/// Post type variants for professional content.
enum ProfessionalPostType {
  discussion('Discussion'),
  portfolioItem('Portfolio'),
  skillOffer('Skill Offer'),
  newsArticle('News'),
  freelanceGig('Freelance Gig'),
  event('Event'),
  question('Question'),
  resource('Resource');

  final String label;

  const ProfessionalPostType(this.label);
}

/// Pro Network post model.
class ProNetworkPost {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userTitle;
  final ProfessionalCategory category;
  final ProfessionalPostType postType;
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

  const ProNetworkPost({
    required this.id,
    this.userId = '',
    required this.userName,
    this.userAvatar,
    this.userTitle,
    this.category = ProfessionalCategory.all,
    this.postType = ProfessionalPostType.discussion,
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

  factory ProNetworkPost.fromJson(Map<String, dynamic> json) {
    return ProNetworkPost(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['author']?['full_name'] as String? ?? 'Anonymous',
      userAvatar: json['author']?['avatar_url'] as String?,
      userTitle: json['author_title'] as String?,
      category: ProfessionalCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ProfessionalCategory.all,
      ),
      postType: ProfessionalPostType.values.firstWhere(
        (t) => t.name == json['post_type'],
        orElse: () => ProfessionalPostType.discussion,
      ),
      title: json['title'] as String? ?? '',
      description: json['content'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      location: json['location'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      likeCount: json['likes_count'] as int? ?? 0,
      commentCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

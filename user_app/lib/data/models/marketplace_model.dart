import 'package:flutter/material.dart';

/// Category types for marketplace listings.
enum MarketplaceCategory {
  hardGoods('Hard Goods', 'Books, Calculators, etc.', Icons.inventory_2_outlined),
  housing('Housing', 'Flatmates, Rooms', Icons.home_outlined),
  opportunities('Opportunities', 'Internships, Gigs, Events', Icons.work_outline),
  community('Community', 'Polls, Reviews, Questions', Icons.forum_outlined);

  final String displayName;
  final String description;
  final IconData icon;

  const MarketplaceCategory(this.displayName, this.description, this.icon);

  /// Alias for displayName for convenience.
  String get label => displayName;

  Color get color {
    switch (this) {
      case MarketplaceCategory.hardGoods:
        return const Color(0xFF3B82F6); // Blue
      case MarketplaceCategory.housing:
        return const Color(0xFF22C55E); // Green
      case MarketplaceCategory.opportunities:
        return const Color(0xFFF59E0B); // Orange
      case MarketplaceCategory.community:
        return const Color(0xFF8B5CF6); // Purple
    }
  }
}

/// Listing type for marketplace.
enum ListingType {
  product('Product', Icons.shopping_bag_outlined),
  housing('Housing', Icons.apartment_outlined),
  opportunity('Opportunity', Icons.trending_up),
  communityPost('Community Post', Icons.chat_bubble_outline),
  event('Event', Icons.event),
  poll('Poll', Icons.poll_outlined);

  final String displayName;
  final IconData icon;

  const ListingType(this.displayName, this.icon);
}

/// Listing status.
enum ListingStatus {
  active('Active'),
  sold('Sold'),
  expired('Expired'),
  hidden('Hidden');

  final String displayName;
  const ListingStatus(this.displayName);
}

/// Marketplace listing model.
class MarketplaceListing {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userUniversity;
  final String? collegeName;
  final MarketplaceCategory category;
  final ListingType type;
  final String title;
  final String? description;
  final double? price;
  final bool isNegotiable;
  final List<String>? images;
  final String? location;
  final double? distanceKm;
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isSaved;
  final Map<String, dynamic>? metadata;

  const MarketplaceListing({
    required this.id,
    this.userId = '',
    required this.userName,
    this.userAvatar,
    this.userUniversity,
    this.collegeName,
    this.category = MarketplaceCategory.community,
    required this.type,
    required this.title,
    this.description,
    this.price,
    this.isNegotiable = false,
    this.images,
    this.location,
    this.distanceKm,
    this.status = ListingStatus.active,
    required this.createdAt,
    this.expiresAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    this.metadata,
  });

  /// Get formatted price string.
  String get priceString {
    if (price == null) return 'Free';
    if (price == 0) return 'Free';
    return '\u20B9${price!.toStringAsFixed(0)}';
  }

  /// Get formatted distance string.
  String? get distanceString {
    if (distanceKm == null) return null;
    if (distanceKm! < 1) {
      return '${(distanceKm! * 1000).toStringAsFixed(0)}m away';
    }
    return '${distanceKm!.toStringAsFixed(1)}km away';
  }

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

  /// Check if listing has images.
  bool get hasImages => images != null && images!.isNotEmpty;

  /// Get first image or null.
  String? get primaryImage => images != null && images!.isNotEmpty ? images!.first : null;

  /// Create from JSON.
  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Anonymous',
      userAvatar: json['user_avatar'] as String?,
      userUniversity: json['user_university'] as String?,
      collegeName: json['college_name'] as String?,
      category: MarketplaceCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => MarketplaceCategory.hardGoods,
      ),
      type: ListingType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => ListingType.product,
      ),
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      images: (json['images'] as List<dynamic>?)?.cast<String>(),
      location: json['location'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      status: ListingStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => ListingStatus.active,
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
      'user_university': userUniversity,
      'college_name': collegeName,
      'category': category.name,
      'type': type.name,
      'title': title,
      'description': description,
      'price': price,
      'is_negotiable': isNegotiable,
      'images': images,
      'location': location,
      'distance_km': distanceKm,
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
  MarketplaceListing copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userUniversity,
    String? collegeName,
    MarketplaceCategory? category,
    ListingType? type,
    String? title,
    String? description,
    double? price,
    bool? isNegotiable,
    List<String>? images,
    String? location,
    double? distanceKm,
    ListingStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    bool? isSaved,
    Map<String, dynamic>? metadata,
  }) {
    return MarketplaceListing(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userUniversity: userUniversity ?? this.userUniversity,
      collegeName: collegeName ?? this.collegeName,
      category: category ?? this.category,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      images: images ?? this.images,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
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

/// Community post for polls/questions.
class CommunityPost extends MarketplaceListing {
  final List<PollOption>? pollOptions;
  final int? totalVotes;
  final String? selectedOption;

  const CommunityPost({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    super.userUniversity,
    required super.title,
    super.description,
    required super.createdAt,
    super.likeCount,
    super.commentCount,
    super.isLiked,
    this.pollOptions,
    this.totalVotes,
    this.selectedOption,
  }) : super(
          category: MarketplaceCategory.community,
          type: pollOptions != null ? ListingType.poll : ListingType.communityPost,
        );

  bool get isPoll => pollOptions != null && pollOptions!.isNotEmpty;
  bool get hasVoted => selectedOption != null;
}

/// Poll option model.
class PollOption {
  final String id;
  final String text;
  final int votes;
  final double percentage;

  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.percentage = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] as String,
      text: json['text'] as String,
      votes: json['votes'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Event/opportunity listing.
class OpportunityListing extends MarketplaceListing {
  final String? companyName;
  final String? companyLogo;
  final DateTime? eventDate;
  final String? eventLocation;
  final String? applyLink;
  final bool isRemote;
  final String? salary;

  const OpportunityListing({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.title,
    super.description,
    required super.createdAt,
    super.expiresAt,
    super.images,
    this.companyName,
    this.companyLogo,
    this.eventDate,
    this.eventLocation,
    this.applyLink,
    this.isRemote = false,
    this.salary,
  }) : super(
          category: MarketplaceCategory.opportunities,
          type: eventDate != null ? ListingType.event : ListingType.opportunity,
        );

  bool get isEvent => eventDate != null;
  bool get isUpcoming => eventDate != null && eventDate!.isAfter(DateTime.now());
}

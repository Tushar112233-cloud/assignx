/// Banner model matching Supabase 'banners' table schema.
///
/// Represents promotional banners displayed in various locations
/// throughout the app (home, marketplace, project pages).
///
/// Named [AppBanner] to avoid conflict with Flutter's built-in [Banner] widget.
class AppBanner {
  /// Unique identifier (UUID).
  final String id;

  /// Banner title text.
  final String title;

  /// Optional subtitle/description text.
  final String? subtitle;

  /// Primary image URL (required).
  final String imageUrl;

  /// Mobile-optimized image URL (optional).
  final String? imageUrlMobile;

  /// Call-to-action button text.
  final String? ctaText;

  /// URL or route for CTA navigation.
  final String? ctaUrl;

  /// CTA action type: 'navigate', 'open_url', 'open_modal'.
  final String? ctaAction;

  /// Target user types: ['student', 'professional'].
  final List<String>? targetUserTypes;

  /// Target user roles: ['user', 'doer', 'supervisor'].
  final List<String>? targetRoles;

  /// Display location: 'home', 'marketplace', 'project'.
  final String displayLocation;

  /// Display order for sorting banners.
  final int displayOrder;

  /// When the banner should start displaying.
  final DateTime? startDate;

  /// When the banner should stop displaying.
  final DateTime? endDate;

  /// Whether the banner is currently active.
  final bool isActive;

  /// Number of times the banner has been viewed.
  final int impressionCount;

  /// Number of times the banner has been clicked.
  final int clickCount;

  /// Timestamp when the banner was created.
  final DateTime? createdAt;

  /// Timestamp when the banner was last updated.
  final DateTime? updatedAt;

  const AppBanner({
    required this.id,
    required this.title,
    this.subtitle,
    required this.imageUrl,
    this.imageUrlMobile,
    this.ctaText,
    this.ctaUrl,
    this.ctaAction,
    this.targetUserTypes,
    this.targetRoles,
    required this.displayLocation,
    this.displayOrder = 0,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.impressionCount = 0,
    this.clickCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates an AppBanner instance from JSON (Supabase response).
  factory AppBanner.fromJson(Map<String, dynamic> json) {
    return AppBanner(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] as String?) ?? '',
      subtitle: json['subtitle'] as String?,
      imageUrl: (json['image_url'] ?? json['imageUrl'] ?? '').toString(),
      imageUrlMobile: (json['image_url_mobile'] ?? json['imageUrlMobile']) as String?,
      ctaText: (json['cta_text'] ?? json['ctaText']) as String?,
      ctaUrl: (json['cta_url'] ?? json['ctaUrl']) as String?,
      ctaAction: (json['cta_action'] ?? json['ctaAction']) as String?,
      targetUserTypes: ((json['target_user_types'] ?? json['targetUserTypes']) as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      targetRoles: ((json['target_roles'] ?? json['targetRoles']) as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      displayLocation: (json['display_location'] ?? json['displayLocation'] ?? '').toString(),
      displayOrder: (json['display_order'] ?? json['displayOrder']) as int? ?? 0,
      startDate: (json['start_date'] ?? json['startDate']) != null
          ? DateTime.tryParse((json['start_date'] ?? json['startDate']).toString())
          : null,
      endDate: (json['end_date'] ?? json['endDate']) != null
          ? DateTime.tryParse((json['end_date'] ?? json['endDate']).toString())
          : null,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      impressionCount: (json['impression_count'] ?? json['impressionCount']) as int? ?? 0,
      clickCount: (json['click_count'] ?? json['clickCount']) as int? ?? 0,
      createdAt: (json['created_at'] ?? json['createdAt']) != null
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']).toString())
          : null,
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null
          ? DateTime.tryParse((json['updated_at'] ?? json['updatedAt']).toString())
          : null,
    );
  }

  /// Converts the Banner instance to JSON for Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'image_url_mobile': imageUrlMobile,
      'cta_text': ctaText,
      'cta_url': ctaUrl,
      'cta_action': ctaAction,
      'target_user_types': targetUserTypes,
      'target_roles': targetRoles,
      'display_location': displayLocation,
      'display_order': displayOrder,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'impression_count': impressionCount,
      'click_count': clickCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this AppBanner with the given fields replaced.
  AppBanner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? imageUrlMobile,
    String? ctaText,
    String? ctaUrl,
    String? ctaAction,
    List<String>? targetUserTypes,
    List<String>? targetRoles,
    String? displayLocation,
    int? displayOrder,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? impressionCount,
    int? clickCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppBanner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrlMobile: imageUrlMobile ?? this.imageUrlMobile,
      ctaText: ctaText ?? this.ctaText,
      ctaUrl: ctaUrl ?? this.ctaUrl,
      ctaAction: ctaAction ?? this.ctaAction,
      targetUserTypes: targetUserTypes ?? this.targetUserTypes,
      targetRoles: targetRoles ?? this.targetRoles,
      displayLocation: displayLocation ?? this.displayLocation,
      displayOrder: displayOrder ?? this.displayOrder,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      impressionCount: impressionCount ?? this.impressionCount,
      clickCount: clickCount ?? this.clickCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mock banners for initial display and testing.
  static List<AppBanner> get mockBanners => [
        AppBanner(
          id: '550e8400-e29b-41d4-a716-446655440001',
          title: 'Get 20% Off',
          subtitle: 'On your first project',
          imageUrl: 'https://example.com/banners/promo-20-off.jpg',
          ctaText: 'Start Now',
          ctaUrl: '/add-project',
          ctaAction: 'navigate',
          targetUserTypes: ['student', 'professional'],
          targetRoles: ['user'],
          displayLocation: 'home',
          displayOrder: 1,
          startDate: DateTime.now(),
          isActive: true,
        ),
        AppBanner(
          id: '550e8400-e29b-41d4-a716-446655440002',
          title: 'Free AI Report',
          subtitle: 'With every project submission',
          imageUrl: 'https://example.com/banners/ai-report.jpg',
          ctaText: 'Learn More',
          ctaUrl: 'https://example.com/ai-report-info',
          ctaAction: 'open_url',
          targetUserTypes: ['student'],
          targetRoles: ['user'],
          displayLocation: 'home',
          displayOrder: 2,
          isActive: true,
        ),
        AppBanner(
          id: '550e8400-e29b-41d4-a716-446655440003',
          title: 'Refer & Earn',
          subtitle: 'Get \u20B9100 for each referral',
          imageUrl: 'https://example.com/banners/referral.jpg',
          ctaText: 'Share Now',
          ctaUrl: '/profile',
          ctaAction: 'navigate',
          targetUserTypes: ['student', 'professional'],
          targetRoles: ['user', 'doer'],
          displayLocation: 'home',
          displayOrder: 3,
          isActive: true,
        ),
      ];

  /// Checks if the banner should be displayed based on current date.
  bool get isCurrentlyDisplayable {
    final now = DateTime.now();
    final afterStart = startDate == null || now.isAfter(startDate!);
    final beforeEnd = endDate == null || now.isBefore(endDate!);
    return isActive && afterStart && beforeEnd;
  }

  /// Checks if this banner targets a specific user type.
  bool targetsUserType(String userType) {
    if (targetUserTypes == null || targetUserTypes!.isEmpty) {
      return true; // No targeting means show to all
    }
    return targetUserTypes!.contains(userType);
  }

  /// Checks if this banner targets a specific role.
  bool targetsRole(String role) {
    if (targetRoles == null || targetRoles!.isEmpty) {
      return true; // No targeting means show to all
    }
    return targetRoles!.contains(role);
  }

  @override
  String toString() {
    return 'AppBanner(id: $id, title: $title, displayLocation: $displayLocation, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppBanner && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

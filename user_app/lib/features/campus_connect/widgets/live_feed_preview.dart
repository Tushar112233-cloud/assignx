import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Data model for a compact feed preview item.
class _FeedItem {
  final String id;
  final String collegeName;
  final String content;
  final String category;
  final DateTime createdAt;

  const _FeedItem({
    required this.id,
    required this.collegeName,
    required this.content,
    required this.category,
    required this.createdAt,
  });
}

/// Live feed preview card showing recent campus posts.
///
/// Displays a header with connected cities count and the 4 most recent posts
/// as compact preview items. Each item shows college avatar, name, timestamp,
/// content snippet, and category chip. Tapping opens the post detail screen.
class LiveFeedPreview extends StatefulWidget {
  const LiveFeedPreview({super.key});

  @override
  State<LiveFeedPreview> createState() => _LiveFeedPreviewState();
}

class _LiveFeedPreviewState extends State<LiveFeedPreview> {
  List<_FeedItem> _items = [];
  int _citiesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
  }

  /// Fetch recent posts and cities count from API.
  Future<void> _fetchFeed() async {
    try {
      final response = await ApiClient.get('/community/campus/feed-preview');
      if (!mounted || response == null) return;

      final data = response as Map<String, dynamic>;
      final posts = data['posts'] as List? ?? [];
      final citiesCount = (data['cities_count'] ?? data['citiesCount'] ?? 50) as int;

      setState(() {
        _items = posts.map((post) {
          final p = post as Map<String, dynamic>;
          return _FeedItem(
            id: (p['_id'] ?? p['id'] ?? '').toString(),
            collegeName: (p['college_name'] ?? p['collegeName'] ?? 'Campus') as String,
            content: (p['content'] ?? '') as String,
            category: (p['category'] ?? 'discussions') as String,
            createdAt: DateTime.tryParse((p['created_at'] ?? p['createdAt'] ?? '') as String) ??
                DateTime.now(),
          );
        }).toList();
        _citiesCount = citiesCount > 0 ? citiesCount : 50;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _citiesCount = 50;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.4),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_citiesCount+ cities connected',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Live Feed',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),
            // Feed items
            ...List.generate(_items.length, (index) {
              final item = _items[index];
              return _FeedItemWidget(
                item: item,
                showDivider: index < _items.length - 1,
                onTap: () {
                  if (item.id.isNotEmpty) {
                    context.push('/campus-connect/post/${item.id}');
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Individual feed preview item widget.
class _FeedItemWidget extends StatelessWidget {
  final _FeedItem item;
  final bool showDivider;
  final VoidCallback? onTap;

  const _FeedItemWidget({
    required this.item,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // College avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    item.collegeName.isNotEmpty
                        ? item.collegeName[0].toUpperCase()
                        : 'C',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // College name and timestamp
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.collegeName,
                              style: AppTextStyles.labelSmall.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            _formatTimestamp(item.createdAt),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Content snippet
                      Text(
                        item.content,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Category chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatCategory(item.category),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: _getCategoryColor(item.category),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showDivider)
            Padding(
              padding: const EdgeInsets.only(left: 58),
              child: Divider(
                height: 1,
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
        ],
      ),
    );
  }

  /// Format a timestamp as a relative time string.
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }

  /// Get the display color for a post category.
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'questions':
        return const Color(0xFF6366F1);
      case 'opportunities':
        return AppColors.categoryTeal;
      case 'events':
        return AppColors.categoryIndigo;
      case 'marketplace':
        return AppColors.categoryGreen;
      case 'resources':
        return const Color(0xFFF59E0B);
      case 'lost_found':
        return AppColors.error;
      case 'housing':
        return AppColors.categoryAmber;
      case 'rides':
        return const Color(0xFF3B82F6);
      case 'study_groups':
        return const Color(0xFF8B5CF6);
      case 'clubs':
        return AppColors.categoryOrange;
      case 'announcements':
        return AppColors.warning;
      case 'discussions':
        return AppColors.categoryBlue;
      default:
        return AppColors.textTertiary;
    }
  }

  /// Format a category slug into a display label.
  String _formatCategory(String category) {
    switch (category) {
      case 'lost_found':
        return 'Lost';
      case 'study_groups':
        return 'Study';
      default:
        if (category.isEmpty) return '';
        if (category.length > 8) {
          return '${category[0].toUpperCase()}${category.substring(1, 7)}..';
        }
        return category[0].toUpperCase() + category.substring(1);
    }
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';

/// Card for community posts (questions, reviews, polls).
class TextCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const TextCard({
    super.key,
    required this.listing,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    final isPoll = listing.type == ListingType.poll;
    final backgroundColor = _getBackgroundColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              backgroundColor.withAlpha(200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white.withAlpha(60),
                  child: Text(
                    listing.userName.isNotEmpty
                        ? listing.userName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listing.userName,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (listing.userUniversity != null)
                        Text(
                          listing.userUniversity!,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withAlpha(180),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                // Time ago
                Text(
                  listing.timeAgo,
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withAlpha(150),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Post type tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPoll ? Icons.poll_outlined : Icons.chat_bubble_outline,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPoll ? 'Poll' : 'Discussion',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Title/Question
            Text(
              listing.title,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            // Description (if any)
            if (listing.description != null) ...[
              const SizedBox(height: 6),
              Text(
                listing.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withAlpha(200),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Poll options preview (if poll)
            if (isPoll && listing.metadata?['pollOptions'] != null) ...[
              const SizedBox(height: 12),
              _buildPollPreview(listing.metadata!['pollOptions']),
            ],

            const SizedBox(height: 14),

            // Footer with stats
            Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: onLike,
                  child: Row(
                    children: [
                      Icon(
                        listing.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.likeCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Comment button
                GestureDetector(
                  onTap: onComment,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${listing.commentCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // View count
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 14,
                      color: Colors.white.withAlpha(150),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${listing.viewCount}',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPollPreview(List<dynamic> options) {
    final topOption = options.isNotEmpty ? options.first : null;
    if (topOption == null) return const SizedBox.shrink();

    final totalVotes = listing.metadata?['totalVotes'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  topOption['text'] ?? '',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${topOption['percentage'] ?? 0}%',
                style: AppTextStyles.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (topOption['percentage'] ?? 0) / 100,
              backgroundColor: Colors.white.withAlpha(50),
              valueColor: AlwaysStoppedAnimation(Colors.white.withAlpha(200)),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$totalVotes votes • ${options.length} options',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withAlpha(150),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    // Rotate through nice gradient colors
    final colors = [
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber
      const Color(0xFFEC4899), // Pink
      const Color(0xFF6366F1), // Indigo
    ];

    final hash = listing.id.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/review_model.dart';
import '../providers/profile_provider.dart';

/// Reviews screen showing client reviews with ratings.
class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsState = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref, reviewsState.filter),
          ),
        ],
      ),
      body: reviewsState.isLoading && reviewsState.reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(reviewsProvider.notifier).refresh(),
              child: CustomScrollView(
                slivers: [
                  // Summary card
                  if (reviewsState.summary != null)
                    SliverToBoxAdapter(
                      child: _ReviewsSummaryCard(summary: reviewsState.summary!),
                    ),

                  // Reviews list
                  if (reviewsState.reviews.isEmpty)
                    const SliverFillRemaining(
                      child: _EmptyReviews(),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= reviewsState.reviews.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final review = reviewsState.reviews[index];
                            return _ReviewCard(
                              review: review,
                              onRespond: () =>
                                  _showRespondDialog(context, ref, review),
                            );
                          },
                          childCount: reviewsState.reviews.length +
                              (reviewsState.isLoading ? 1 : 0),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  void _showFilterSheet(
      BuildContext context, WidgetRef ref, ReviewFilter currentFilter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReviewFilterSheet(
        currentFilter: currentFilter,
        onApply: (filter) {
          ref.read(reviewsProvider.notifier).updateFilter(filter);
        },
      ),
    );
  }

  void _showRespondDialog(
      BuildContext context, WidgetRef ref, ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) => _RespondDialog(
        review: review,
        onRespond: (response) async {
          final success = await ref
              .read(reviewsProvider.notifier)
              .respondToReview(review.id, response);

          if (context.mounted && success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Response submitted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}

/// Reviews summary card with rating distribution.
class _ReviewsSummaryCard extends StatelessWidget {
  const _ReviewsSummaryCard({required this.summary});

  final ReviewsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Average rating
              Column(
                children: [
                  Text(
                    summary.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < summary.averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 18,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary.totalReviews} reviews',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              // Rating distribution
              Expanded(
                child: Column(
                  children: [5, 4, 3, 2, 1].map((rating) {
                    final count = summary.ratingDistribution[rating] ?? 0;
                    final total = summary.totalReviews;
                    final percentage = total > 0 ? count / total : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            '$rating',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                            ),
                          ),
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.amber,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 30,
                            child: Text(
                              count.toString(),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Individual review card.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    this.onRespond,
  });

  final ReviewModel review;
  final VoidCallback? onRespond;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    review.clientName.isNotEmpty
                        ? review.clientName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.clientName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        review.projectTitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < review.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: review.ratingColor,
                          size: 16,
                        );
                      }),
                    ),
                    Text(
                      review.timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ),

            // Comment
            if (review.comment != null && review.comment!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                review.comment!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Tags
            if (review.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: review.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // Response
            if (review.response != null && review.response!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Your response',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (review.respondedAt != null) ...[
                          const Spacer(),
                          Text(
                            _formatDate(review.respondedAt!),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                      fontSize: 10,
                                    ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      review.response!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],

            // Respond button
            if (review.response == null && onRespond != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRespond,
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Respond'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Empty reviews widget.
class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reviews from clients will appear here',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Review filter sheet.
class _ReviewFilterSheet extends StatefulWidget {
  const _ReviewFilterSheet({
    required this.currentFilter,
    required this.onApply,
  });

  final ReviewFilter currentFilter;
  final void Function(ReviewFilter) onApply;

  @override
  State<_ReviewFilterSheet> createState() => _ReviewFilterSheetState();
}

class _ReviewFilterSheetState extends State<_ReviewFilterSheet> {
  late int? _minRating;
  late int? _maxRating;

  @override
  void initState() {
    super.initState();
    _minRating = widget.currentFilter.minRating?.toInt();
    _maxRating = widget.currentFilter.maxRating?.toInt();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Reviews',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _minRating = null;
                      _maxRating = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text(
              'Rating Range',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // Rating selector
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 2, 3, 4, 5].map((rating) {
                final isInRange = (_minRating == null || rating >= _minRating!) &&
                    (_maxRating == null || rating <= _maxRating!);
                final isEndpoint = rating == _minRating || rating == _maxRating;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_minRating == null) {
                        _minRating = rating;
                        _maxRating = rating;
                      } else if (rating < _minRating!) {
                        _minRating = rating;
                      } else if (rating > _maxRating!) {
                        _maxRating = rating;
                      } else if (rating == _minRating && rating == _maxRating) {
                        _minRating = null;
                        _maxRating = null;
                      } else if (rating == _minRating) {
                        _minRating = rating + 1;
                      } else {
                        _maxRating = rating - 1;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isEndpoint
                          ? AppColors.primary
                          : isInRange
                              ? AppColors.primary.withValues(alpha: 0.2)
                              : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isInRange
                            ? AppColors.primary
                            : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$rating',
                          style: TextStyle(
                            color: isEndpoint
                                ? Colors.white
                                : isInRange
                                    ? AppColors.primary
                                    : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: isEndpoint
                              ? Colors.white
                              : isInRange
                                  ? Colors.amber
                                  : AppColors.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(ReviewFilter(
                    minRating: _minRating?.toDouble(),
                    maxRating: _maxRating?.toDouble(),
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Apply Filter'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// Respond dialog.
class _RespondDialog extends StatefulWidget {
  const _RespondDialog({
    required this.review,
    required this.onRespond,
  });

  final ReviewModel review;
  final void Function(String) onRespond;

  @override
  State<_RespondDialog> createState() => _RespondDialogState();
}

class _RespondDialogState extends State<_RespondDialog> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Respond to Review'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.review.clientName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < widget.review.rating.round()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                    ),
                  ],
                ),
                if (widget.review.comment != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.review.comment!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Your response',
              hintText: 'Write a professional response...',
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            maxLength: 500,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting
              ? null
              : () {
                  if (_controller.text.isNotEmpty) {
                    setState(() => _isSubmitting = true);
                    widget.onRespond(_controller.text);
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}

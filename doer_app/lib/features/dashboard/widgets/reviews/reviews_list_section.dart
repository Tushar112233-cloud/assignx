import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../data/models/project_model.dart';
import 'review_card.dart';

/// Full reviews list with tabs, search, and scrollable review cards.
class ReviewsListSection extends StatefulWidget {
  final List<ReviewModel> reviews;

  const ReviewsListSection({super.key, required this.reviews});

  @override
  State<ReviewsListSection> createState() => _ReviewsListSectionState();
}

class _ReviewsListSectionState extends State<ReviewsListSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ReviewModel> get _filteredReviews {
    var filtered = List<ReviewModel>.from(widget.reviews);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((r) =>
              r.reviewerName.toLowerCase().contains(query) ||
              r.projectTitle.toLowerCase().contains(query) ||
              (r.comment?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Apply tab filter
    switch (_tabController.index) {
      case 0: // All
        break;
      case 1: // Recent (last 30 days)
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        filtered = filtered.where((r) => r.createdAt.isAfter(cutoff)).toList();
        break;
      case 2: // Highest rated
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 3: // Lowest rated
        filtered.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Icon(Icons.reviews_outlined,
                  size: 18, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'All Reviews',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.reviews.length} total',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // Search bar
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Search reviews...',
              hintStyle: const TextStyle(
                  color: AppColors.textTertiary, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.textTertiary, size: 20),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: const Icon(Icons.clear_rounded,
                          color: AppColors.textTertiary, size: 18),
                    )
                  : null,
            ),
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

        const SizedBox(height: AppSpacing.sm),

        // Tabs
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.accent,
              borderRadius: AppSpacing.borderRadiusMd,
            ),
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            tabs: const [
              Tab(text: 'All', height: 36),
              Tab(text: 'Recent', height: 36),
              Tab(text: 'Highest', height: 36),
              Tab(text: 'Lowest', height: 36),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

        const SizedBox(height: AppSpacing.md),

        // Review cards list
        if (filtered.isEmpty)
          Container(
            padding: AppSpacing.paddingLg,
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 40, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'No reviews found',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textTertiary),
                ),
              ],
            ),
          )
        else
          ...filtered.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ReviewCard(
                  review: entry.value,
                  animationIndex: entry.key,
                ),
              )),
      ],
    );
  }
}

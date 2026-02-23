import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Tab bar for project categories.
///
/// Shows Active, For Review, and Completed tabs with counts.
class ProjectTabs extends StatelessWidget {
  const ProjectTabs({
    super.key,
    required this.tabController,
    required this.activeCount,
    required this.forReviewCount,
    required this.completedCount,
  });

  /// Tab controller for managing tab state
  final TabController tabController;

  /// Count of active projects
  final int activeCount;

  /// Count of projects awaiting review
  final int forReviewCount;

  /// Count of completed projects
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondaryLight,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 13,
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          _TabItem(
            label: 'Active',
            count: activeCount,
            isSelected: tabController.index == 0,
          ),
          _TabItem(
            label: 'Review',
            count: forReviewCount,
            isSelected: tabController.index == 1,
            hasNotification: forReviewCount > 0,
          ),
          _TabItem(
            label: 'History',
            count: completedCount,
            isSelected: tabController.index == 2,
          ),
        ],
      ),
    );
  }
}

/// Individual tab item with optional count badge.
class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.count,
    this.isSelected = false,
    this.hasNotification = false,
  });

  final String label;
  final int count;
  final bool isSelected;
  final bool hasNotification;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : hasNotification
                        ? AppColors.error
                        : AppColors.textSecondaryLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : hasNotification
                          ? Colors.white
                          : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Segmented tab control alternative.
class ProjectSegmentedTabs extends StatelessWidget {
  const ProjectSegmentedTabs({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.activeCount,
    required this.forReviewCount,
    required this.completedCount,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final int activeCount;
  final int forReviewCount;
  final int completedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<int>(
        segments: [
          ButtonSegment(
            value: 0,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pending, size: 18),
                const SizedBox(width: 4),
                Text('Active ($activeCount)'),
              ],
            ),
          ),
          ButtonSegment(
            value: 1,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.rate_review, size: 18),
                const SizedBox(width: 4),
                Text('Review ($forReviewCount)'),
              ],
            ),
          ),
          ButtonSegment(
            value: 2,
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.history, size: 18),
                const SizedBox(width: 4),
                Text('Done ($completedCount)'),
              ],
            ),
          ),
        ],
        selected: {selectedIndex},
        onSelectionChanged: (set) => onChanged(set.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}

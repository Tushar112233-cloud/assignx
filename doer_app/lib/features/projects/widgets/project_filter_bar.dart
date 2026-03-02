/// Search, filter, and sort bar for the My Projects screen.
///
/// Provides a search text field, horizontal scrolling subject filter chips,
/// and a sort dropdown for ordering projects.
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../providers/projects_provider.dart';

/// A search bar with quick filter chips and sort option for projects.
class ProjectFilterBar extends StatelessWidget {
  final String searchQuery;
  final String? selectedSubject;
  final List<String> availableSubjects;
  final ProjectSortOption sortOption;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<ProjectSortOption> onSortChanged;

  const ProjectFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedSubject,
    required this.availableSubjects,
    required this.sortOption,
    required this.onSearchChanged,
    required this.onSubjectChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search field with sort button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search projects...'.tr(context),
                    hintStyle: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppColors.textTertiary,
                              size: 18,
                            ),
                            onPressed: () => onSearchChanged(''),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      borderSide: const BorderSide(
                        color: AppColors.accent,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Sort button
              _SortButton(
                currentSort: sortOption,
                onSortChanged: onSortChanged,
              ),
            ],
          ),
        ),

        // Subject filter chips
        if (availableSubjects.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: availableSubjects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = selectedSubject == null;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: _FilterChip(
                      label: 'All',
                      isSelected: isSelected,
                      onTap: () => onSubjectChanged(null),
                    ),
                  );
                }

                final subject = availableSubjects[index - 1];
                final isSelected = selectedSubject == subject;

                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _FilterChip(
                    label: subject,
                    isSelected: isSelected,
                    onTap: () => onSubjectChanged(isSelected ? null : subject),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Sort button that opens a bottom sheet with sort options.
class _SortButton extends StatelessWidget {
  final ProjectSortOption currentSort;
  final ValueChanged<ProjectSortOption> onSortChanged;

  const _SortButton({
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceVariant,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => _showSortSheet(context),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: currentSort != ProjectSortOption.dueSoon
                  ? AppColors.accent
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.sort_rounded,
            size: 20,
            color: currentSort != ProjectSortOption.dueSoon
                ? AppColors.accent
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Sort By'.tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ...ProjectSortOption.values.map((option) {
                  final isSelected = option == currentSort;
                  return ListTile(
                    onTap: () {
                      onSortChanged(option);
                      Navigator.pop(context);
                    },
                    leading: Icon(
                      _getSortIcon(option),
                      color: isSelected ? AppColors.accent : AppColors.textSecondary,
                      size: 22,
                    ),
                    title: Text(
                      option.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.accent : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.accent, size: 22)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    tileColor: isSelected
                        ? AppColors.accent.withValues(alpha: 0.06)
                        : null,
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getSortIcon(ProjectSortOption option) {
    switch (option) {
      case ProjectSortOption.dueSoon:
        return Icons.schedule_rounded;
      case ProjectSortOption.recent:
        return Icons.access_time_filled_rounded;
      case ProjectSortOption.amountHigh:
        return Icons.arrow_upward_rounded;
      case ProjectSortOption.amountLow:
        return Icons.arrow_downward_rounded;
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

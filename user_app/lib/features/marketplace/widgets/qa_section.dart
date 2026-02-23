import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_subject.dart';
import '../../../data/models/question_model.dart';
import '../../../providers/marketplace_provider.dart';
import 'ask_question_sheet.dart';
import 'question_card.dart';

/// Q&A section widget for the Connect/Marketplace screen.
class QASection extends ConsumerWidget {
  /// Callback when a question is tapped.
  final void Function(Question question)? onQuestionTap;

  const QASection({
    super.key,
    this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(questionsProvider);
    final filters = ref.watch(qaFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Questions & Answers',
                style: AppTextStyles.headingSmall,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => AskQuestionSheet.show(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ask'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _QASearchBar(
            onSearch: (query) {
              ref.read(qaFilterProvider.notifier).setSearchQuery(query);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Sort dropdown
              _FilterChip(
                label: filters.sortBy.displayName,
                icon: filters.sortBy.icon,
                onTap: () => _showSortOptions(context, ref),
              ),
              const SizedBox(width: 8),
              // Subject filter
              _FilterChip(
                label: filters.subject?.displayName ?? 'All Subjects',
                icon: filters.subject?.icon ?? Icons.category,
                isActive: filters.subject != null,
                onTap: () => _showSubjectFilter(context, ref),
              ),
              const SizedBox(width: 8),
              // Answered/Unanswered toggle
              _FilterChip(
                label: filters.showUnansweredOnly
                    ? 'Unanswered'
                    : filters.showAnsweredOnly
                        ? 'Answered'
                        : 'All Status',
                icon: filters.showUnansweredOnly
                    ? Icons.help_outline
                    : filters.showAnsweredOnly
                        ? Icons.check_circle_outline
                        : Icons.filter_list,
                isActive:
                    filters.showAnsweredOnly || filters.showUnansweredOnly,
                onTap: () => _showStatusFilter(context, ref),
              ),
              // Clear filters button
              if (filters.hasFilters) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ref.read(qaFilterProvider.notifier).clearFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      'Clear',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Questions list
        questionsAsync.when(
          data: (questions) {
            if (questions.isEmpty) {
              return _EmptyState(
                hasFilters: filters.hasFilters,
                onAskQuestion: () => AskQuestionSheet.show(context),
                onClearFilters: () {
                  ref.read(qaFilterProvider.notifier).clearFilters();
                },
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final question = questions[index];
                return QuestionCard(
                  question: question,
                  onTap: () => onQuestionTap?.call(question),
                  onUpvote: () {
                    ref.read(voteQuestionProvider((
                      questionId: question.id,
                      isUpvote: true,
                    )).future);
                  },
                  onDownvote: () {
                    ref.read(voteQuestionProvider((
                      questionId: question.id,
                      isUpvote: false,
                    )).future);
                  },
                );
              },
            );
          },
          loading: () => const _LoadingState(),
          error: (error, stack) => _ErrorState(
            error: error.toString(),
            onRetry: () => ref.invalidate(questionsProvider),
          ),
        ),
      ],
    );
  }

  /// Show sort options bottom sheet.
  void _showSortOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sort By',
                  style: AppTextStyles.headingSmall,
                ),
              ),
              ...QuestionSortOption.values.map((option) {
                final isSelected =
                    ref.read(qaFilterProvider).sortBy == option;
                return ListTile(
                  leading: Icon(
                    option.icon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    option.displayName,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary : null,
                      fontWeight: isSelected ? FontWeight.w600 : null,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    ref.read(qaFilterProvider.notifier).setSortBy(option);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  /// Show subject filter bottom sheet.
  void _showSubjectFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Filter by Subject',
                      style: AppTextStyles.headingSmall,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        // All subjects option
                        ListTile(
                          leading: Icon(
                            Icons.category,
                            color: ref.read(qaFilterProvider).subject == null
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          title: Text(
                            'All Subjects',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: ref.read(qaFilterProvider).subject == null
                                  ? AppColors.primary
                                  : null,
                              fontWeight: ref.read(qaFilterProvider).subject == null
                                  ? FontWeight.w600
                                  : null,
                            ),
                          ),
                          trailing: ref.read(qaFilterProvider).subject == null
                              ? Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () {
                            ref.read(qaFilterProvider.notifier).setSubject(null);
                            Navigator.pop(context);
                          },
                        ),
                        const Divider(),
                        ...ProjectSubject.values.map((subject) {
                          final isSelected =
                              ref.read(qaFilterProvider).subject == subject;
                          return ListTile(
                            leading: Icon(
                              subject.icon,
                              color: isSelected ? subject.color : AppColors.textSecondary,
                            ),
                            title: Text(
                              subject.displayName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isSelected ? subject.color : null,
                                fontWeight: isSelected ? FontWeight.w600 : null,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check, color: subject.color)
                                : null,
                            onTap: () {
                              ref.read(qaFilterProvider.notifier).setSubject(subject);
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Show status filter bottom sheet.
  void _showStatusFilter(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final filters = ref.read(qaFilterProvider);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Filter by Status',
                  style: AppTextStyles.headingSmall,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.filter_list,
                  color: !filters.showAnsweredOnly && !filters.showUnansweredOnly
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                title: Text(
                  'All Questions',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: !filters.showAnsweredOnly && !filters.showUnansweredOnly
                        ? AppColors.primary
                        : null,
                    fontWeight: !filters.showAnsweredOnly && !filters.showUnansweredOnly
                        ? FontWeight.w600
                        : null,
                  ),
                ),
                trailing: !filters.showAnsweredOnly && !filters.showUnansweredOnly
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  ref.read(qaFilterProvider.notifier).setStatusFilter(
                    showAnsweredOnly: false,
                    showUnansweredOnly: false,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: filters.showAnsweredOnly
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
                title: Text(
                  'Answered',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: filters.showAnsweredOnly ? AppColors.success : null,
                    fontWeight: filters.showAnsweredOnly ? FontWeight.w600 : null,
                  ),
                ),
                trailing: filters.showAnsweredOnly
                    ? Icon(Icons.check, color: AppColors.success)
                    : null,
                onTap: () {
                  ref.read(qaFilterProvider.notifier).setStatusFilter(
                    showAnsweredOnly: true,
                    showUnansweredOnly: false,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: filters.showUnansweredOnly
                      ? AppColors.warning
                      : AppColors.textSecondary,
                ),
                title: Text(
                  'Unanswered',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: filters.showUnansweredOnly ? AppColors.warning : null,
                    fontWeight: filters.showUnansweredOnly ? FontWeight.w600 : null,
                  ),
                ),
                trailing: filters.showUnansweredOnly
                    ? Icon(Icons.check, color: AppColors.warning)
                    : null,
                onTap: () {
                  ref.read(qaFilterProvider.notifier).setStatusFilter(
                    showAnsweredOnly: false,
                    showUnansweredOnly: true,
                  );
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Search bar for Q&A section.
class _QASearchBar extends StatefulWidget {
  final void Function(String query) onSearch;

  const _QASearchBar({required this.onSearch});

  @override
  State<_QASearchBar> createState() => _QASearchBarState();
}

class _QASearchBarState extends State<_QASearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search questions...',
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textTertiary,
          size: 20,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _controller.clear();
                  widget.onSearch('');
                },
                icon: Icon(
                  Icons.clear,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      onChanged: (value) {
        setState(() {});
        widget.onSearch(value);
      },
    );
  }
}

/// Filter chip widget.
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withAlpha(20)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onAskQuestion;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onAskQuestion,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            hasFilters ? Icons.search_off : Icons.help_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No questions found' : 'No questions yet',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search query'
                : 'Be the first to ask a question!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (hasFilters)
            TextButton(
              onPressed: onClearFilters,
              child: Text(
                'Clear Filters',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: onAskQuestion,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Ask Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

/// Loading state widget.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.shimmerBase,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

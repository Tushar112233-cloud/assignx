import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../shared/widgets/capsule_tab_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import 'ask_question_sheet.dart';
import 'question_card.dart';

// ============================================================
// PROVIDERS
// ============================================================

/// Status filter for Q&A questions.
enum QaStatusFilter { all, answered, unanswered }

/// State holder for Q&A filter selections.
class QaFilterState {
  final QaStatusFilter status;
  final String? subject;

  const QaFilterState({
    this.status = QaStatusFilter.all,
    this.subject,
  });

  QaFilterState copyWith({
    QaStatusFilter? status,
    String? subject,
    bool clearSubject = false,
  }) {
    return QaFilterState(
      status: status ?? this.status,
      subject: clearSubject ? null : (subject ?? this.subject),
    );
  }
}

/// Notifier for managing Q&A filter state.
class QaFilterNotifier extends StateNotifier<QaFilterState> {
  QaFilterNotifier() : super(const QaFilterState());

  void setStatus(QaStatusFilter status) {
    state = state.copyWith(status: status);
  }

  void setSubject(String? subject) {
    state = state.copyWith(subject: subject, clearSubject: subject == null);
  }

  void clearFilters() {
    state = const QaFilterState();
  }
}

/// Provider for the Q&A filter state.
final qaFilterProvider =
    StateNotifierProvider<QaFilterNotifier, QaFilterState>((ref) {
  return QaFilterNotifier();
});

/// Provider that fetches Q&A questions from the API with filters applied.
///
/// Calls the `/connect/questions` endpoint, applying status and
/// subject filters from [qaFilterProvider]. Falls back to an empty list when
/// the API is unavailable or the query fails.
final connectQuestionsProvider =
    FutureProvider.autoDispose<List<Question>>((ref) async {
  final filters = ref.watch(qaFilterProvider);

  try {
    final queryParams = <String, String>{};
    if (filters.status == QaStatusFilter.answered) {
      queryParams['status'] = 'answered';
    } else if (filters.status == QaStatusFilter.unanswered) {
      queryParams['status'] = 'unanswered';
    }
    if (filters.subject != null) {
      queryParams['subject'] = filters.subject!;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final path = '/connect/questions${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await ApiClient.get(path);
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['questions'] as List? ?? [];

    return list
        .map((json) => Question.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (_) {
    // API unavailable -- return empty list.
    return [];
  }
});

// ============================================================
// QA SECTION WIDGET
// ============================================================

/// Main Q&A tab content widget for the Connect screen.
///
/// Renders a scrollable list of [QuestionCard] widgets filtered by
/// status (all / answered / unanswered) and subject. A floating action
/// button opens the [AskQuestionSheet] for posting new questions.
///
/// Uses Riverpod providers [qaFilterProvider] and [connectQuestionsProvider]
/// for reactive state management and data fetching.
class QaSection extends ConsumerWidget {
  const QaSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionsAsync = ref.watch(connectQuestionsProvider);
    final filters = ref.watch(qaFilterProvider);

    return Stack(
      children: [
        // Main scrollable content
        CustomScrollView(
          slivers: [
            // Status filter chips
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: CapsuleTabBar(
                  tabs: [
                    'All'.tr(context),
                    'Answered'.tr(context),
                    'Unanswered'.tr(context),
                  ],
                  selectedIndex: filters.status.index,
                  onTabChanged: (i) {
                    ref
                        .read(qaFilterProvider.notifier)
                        .setStatus(QaStatusFilter.values[i]);
                  },
                  height: 36,
                  internalPadding: 3,
                ),
              ),
            ),

            // Subject filter dropdown
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: _SubjectFilterChip(
                  currentSubject: filters.subject,
                  onSubjectChanged: (subject) {
                    ref.read(qaFilterProvider.notifier).setSubject(subject);
                  },
                ),
              ),
            ),

            // Questions list
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: questionsAsync.when(
                data: (questions) {
                  if (questions.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _QaEmptyState(
                        hasFilters: filters.status != QaStatusFilter.all ||
                            filters.subject != null,
                        onClearFilters: () {
                          ref.read(qaFilterProvider.notifier).clearFilters();
                        },
                        onAskQuestion: () {
                          AskQuestionSheet.show(
                            context: context,
                            onQuestionPosted: () {
                              ref.invalidate(connectQuestionsProvider);
                            },
                          );
                        },
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final question = questions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: QuestionCard(
                            question: question,
                            onTap: () => _showQuestionDetail(
                              context,
                              question,
                            ),
                          ),
                        );
                      },
                      childCount: questions.length,
                    ),
                  );
                },
                loading: () => SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _QuestionCardSkeleton(),
                    ),
                    childCount: 4,
                  ),
                ),
                error: (error, _) => SliverToBoxAdapter(
                  child: _QaErrorState(
                    error: error.toString(),
                    onRetry: () => ref.invalidate(connectQuestionsProvider),
                  ),
                ),
              ),
            ),

            // Bottom spacing for FAB clearance
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),

        // Floating action button - Ask Question
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'ask_question_fab',
            onPressed: () {
              AskQuestionSheet.show(
                context: context,
                onQuestionPosted: () {
                  ref.invalidate(connectQuestionsProvider);
                },
              );
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: Text(
              'Ask'.tr(context),
              style: AppTextStyles.buttonMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Show a bottom sheet with the full question and its answers.
  void _showQuestionDetail(BuildContext context, Question question) {
    showModalBottomSheet(
      useSafeArea: false,
      context: context,
      useRootNavigator: true,

      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuestionDetailSheet(question: question),
    );
  }
}

// ============================================================
// STATUS FILTER CHIPS
// ============================================================

// _StatusFilterChips replaced by CapsuleTabBar

// ============================================================
// SUBJECT FILTER CHIP
// ============================================================

/// A single chip that opens a subject picker when tapped.
class _SubjectFilterChip extends StatelessWidget {
  final String? currentSubject;
  final ValueChanged<String?> onSubjectChanged;

  /// Available subjects for the filter.
  static const List<String> _subjects = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Computer Science',
    'Data Structures',
    'Machine Learning',
    'Economics',
    'Statistics',
    'English',
    'Biology',
  ];

  const _SubjectFilterChip({
    required this.currentSubject,
    required this.onSubjectChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilter = currentSubject != null;

    return Row(
      children: [
        GestureDetector(
          onTap: () => _showSubjectFilter(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hasFilter
                  ? AppColors.primary.withAlpha(26)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasFilter
                    ? AppColors.primary.withAlpha(80)
                    : AppColors.border.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 14,
                  color:
                      hasFilter ? AppColors.primary : AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  hasFilter
                      ? currentSubject!.tr(context)
                      : 'All Subjects'.tr(context),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: hasFilter
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: hasFilter ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                if (hasFilter) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        ),

        // Clear button when a subject is selected
        if (hasFilter) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onSubjectChanged(null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showSubjectFilter(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: false,
      context: context,
      useRootNavigator: true,

      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter by Subject'.tr(context),
                    style: AppTextStyles.headingSmall,
                  ),
                  if (currentSubject != null)
                    GestureDetector(
                      onTap: () {
                        onSubjectChanged(null);
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Clear'.tr(context),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Subject list
            Expanded(
              child: ListView.builder(
                itemCount: _subjects.length,
                itemBuilder: (context, index) {
                  final subject = _subjects[index];
                  final isSelected = currentSubject == subject;

                  return ListTile(
                    title: Text(
                      subject.tr(context),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 22,
                          )
                        : null,
                    onTap: () {
                      onSubjectChanged(subject);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUESTION DETAIL SHEET
// ============================================================

/// Full-screen bottom sheet showing a question's complete content
/// along with its answers list.
class _QuestionDetailSheet extends StatelessWidget {
  final Question question;

  const _QuestionDetailSheet({required this.question});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Question'.tr(context),
                      style: AppTextStyles.headingSmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    color: AppColors.textSecondary,
                    iconSize: 22,
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: AppColors.border),

            // Scrollable content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Status + Subject row
                  Row(
                    children: [
                      if (question.isAnswered)
                        _buildBadge(
                          context,
                          label: 'Answered'.tr(context),
                          color: AppColors.success,
                          icon: Icons.check_circle_outline,
                        )
                      else
                        _buildBadge(
                          context,
                          label: 'Unanswered'.tr(context),
                          color: AppColors.warning,
                        ),
                      const SizedBox(width: 8),
                      _buildBadge(
                        context,
                        label: question.subject,
                        color: AppColors.primary,
                      ),
                      const Spacer(),
                      Text(
                        question.timeAgo,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    question.title,
                    style: AppTextStyles.headingMedium,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  // Author row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.avatarWarm,
                        child: Text(
                          question.authorInitials,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        question.authorName,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Upvote indicator
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 16,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        question.upvotes.toString(),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Full body text
                  Text(
                    question.body,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: AppSpacing.md),

                  // Answers header
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${question.answerCount} ${'Answers'.tr(context)}',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Answers placeholder
                  GlassCard(
                    blur: 8,
                    opacity: 0.6,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Icon(
                          Icons.question_answer_outlined,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No answers yet'.tr(context),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to help!'.tr(context),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a colored badge chip used in the detail header.
  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

}

// ============================================================
// EMPTY STATE
// ============================================================

/// Empty state shown when no questions match the current filters.
class _QaEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;
  final VoidCallback onAskQuestion;

  const _QaEmptyState({
    required this.hasFilters,
    required this.onClearFilters,
    required this.onAskQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.question_answer_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'No questions found'.tr(context)
                : 'No questions yet'.tr(context),
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters'.tr(context)
                : 'Be the first to ask a question!'.tr(context),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (hasFilters)
            GlassButton(
              label: 'Clear Filters'.tr(context),
              icon: Icons.filter_alt_off,
              onPressed: onClearFilters,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              fullWidth: false,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            )
          else
            GlassButton(
              label: 'Ask a Question'.tr(context),
              icon: Icons.edit_outlined,
              onPressed: onAskQuestion,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              fullWidth: false,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

/// Error state shown when the questions provider fails.
class _QaErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _QaErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong'.tr(context),
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
          const SizedBox(height: 16),
          GlassButton(
            label: 'Retry'.tr(context),
            icon: Icons.refresh,
            onPressed: onRetry,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            fullWidth: false,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SKELETON LOADER
// ============================================================

/// Loading skeleton matching the [QuestionCard] layout.
class _QuestionCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status + subject row
          Row(
            children: const [
              SkeletonLoader(height: 20, width: 70, borderRadius: 4),
              SizedBox(width: 8),
              SkeletonLoader(height: 20, width: 90, borderRadius: 4),
              Spacer(),
              SkeletonLoader(height: 14, width: 50),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          const SkeletonLoader(height: 16, width: double.infinity),
          const SizedBox(height: 6),
          const SkeletonLoader(height: 16, width: 200),
          const SizedBox(height: 10),
          // Body excerpt
          const SkeletonLoader(height: 12, width: double.infinity),
          const SizedBox(height: 4),
          const SkeletonLoader(height: 12, width: 260),
          const SizedBox(height: 12),
          // Divider
          Container(
            height: 1,
            color: AppColors.border.withAlpha(40),
          ),
          const SizedBox(height: 12),
          // Footer
          Row(
            children: const [
              SkeletonLoader.circle(size: 24),
              SizedBox(width: 8),
              SkeletonLoader(height: 12, width: 80),
              Spacer(),
              SkeletonLoader(height: 24, width: 80, borderRadius: 12),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
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
/// Calls the `/community/connect/questions` endpoint, applying status and
/// subject filters from [qaFilterProvider]. Falls back to mock data when
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
    final path = '/community/connect/questions${queryString.isNotEmpty ? '?$queryString' : ''}';

    final response = await ApiClient.get(path);
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['questions'] as List? ?? [];

    return list
        .map((json) => Question.fromJson(json as Map<String, dynamic>))
        .toList();
  } catch (_) {
    // API may not be available -- serve mock data for development.
    await Future.delayed(const Duration(milliseconds: 400));
    return _filterMockQuestions(filters);
  }
});

/// Apply filters against mock data for offline/development use.
List<Question> _filterMockQuestions(QaFilterState filters) {
  var questions = List<Question>.from(_mockQuestions);

  if (filters.status == QaStatusFilter.answered) {
    questions = questions.where((q) => q.isAnswered).toList();
  } else if (filters.status == QaStatusFilter.unanswered) {
    questions = questions.where((q) => !q.isAnswered).toList();
  }

  if (filters.subject != null) {
    questions = questions.where((q) => q.subject == filters.subject).toList();
  }

  return questions;
}

// ============================================================
// MOCK DATA
// ============================================================

final _mockQuestions = [
  Question(
    id: 'q1',
    title: 'How to solve second-order differential equations?',
    body:
        'I am struggling with second-order linear ODEs with constant coefficients. '
        'Can someone explain the characteristic equation method step by step? '
        'Especially when we get complex roots.',
    subject: 'Mathematics',
    authorId: 'u1',
    authorName: 'Priya Sharma',
    answerCount: 3,
    upvotes: 12,
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    isAnswered: true,
  ),
  Question(
    id: 'q2',
    title: 'Best resources for learning dynamic programming?',
    body:
        'I can solve basic DP problems but I find it hard to identify the '
        'substructure in medium/hard problems. What resources or approaches '
        'helped you get better at DP?',
    subject: 'Data Structures',
    authorId: 'u2',
    authorName: 'Rahul Verma',
    answerCount: 5,
    upvotes: 24,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    isAnswered: true,
  ),
  Question(
    id: 'q3',
    title: 'Difference between supervised and unsupervised learning?',
    body:
        'I understand the basic definitions but I get confused about when to '
        'use which approach. Can someone give practical examples from '
        'real-world applications?',
    subject: 'Machine Learning',
    authorId: 'u3',
    authorName: 'Ananya Patel',
    answerCount: 2,
    upvotes: 8,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isAnswered: true,
  ),
  Question(
    id: 'q4',
    title: 'Newton\'s third law in non-inertial frames?',
    body:
        'Does Newton\'s third law still hold in non-inertial (accelerating) '
        'reference frames? How do pseudo forces factor in?',
    subject: 'Physics',
    authorId: 'u4',
    authorName: 'Vikram Singh',
    answerCount: 0,
    upvotes: 5,
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isAnswered: false,
  ),
  Question(
    id: 'q5',
    title: 'How does supply and demand affect cryptocurrency?',
    body:
        'Traditional supply-demand models assume physical goods. How do these '
        'principles apply to digital assets like Bitcoin where supply is '
        'algorithmically capped?',
    subject: 'Economics',
    authorId: 'u5',
    authorName: 'Sneha Gupta',
    answerCount: 1,
    upvotes: 15,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    isAnswered: false,
  ),
  Question(
    id: 'q6',
    title: 'Explain SN1 vs SN2 reaction mechanisms',
    body:
        'I always mix up the conditions that favor SN1 over SN2. Can someone '
        'provide a clear comparison table or mnemonic?',
    subject: 'Chemistry',
    authorId: 'u6',
    authorName: 'Amit Kumar',
    answerCount: 4,
    upvotes: 18,
    createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    isAnswered: true,
  ),
  Question(
    id: 'q7',
    title: 'Tips for improving English academic writing?',
    body:
        'My professor keeps marking my essays for "unclear argumentation". '
        'What strategies or books would help me structure academic '
        'arguments better?',
    subject: 'English',
    authorId: 'u7',
    authorName: 'Meera Joshi',
    answerCount: 0,
    upvotes: 3,
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isAnswered: false,
  ),
];

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
                child: _StatusFilterChips(
                  currentStatus: filters.status,
                  onStatusChanged: (status) {
                    ref.read(qaFilterProvider.notifier).setStatus(status);
                  },
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
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _QuestionDetailSheet(question: question),
    );
  }
}

// ============================================================
// STATUS FILTER CHIPS
// ============================================================

/// Horizontal row of filter chips for question status.
class _StatusFilterChips extends StatelessWidget {
  final QaStatusFilter currentStatus;
  final ValueChanged<QaStatusFilter> onStatusChanged;

  const _StatusFilterChips({
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildChip(
          context,
          label: 'All'.tr(context),
          value: QaStatusFilter.all,
        ),
        const SizedBox(width: 8),
        _buildChip(
          context,
          label: 'Answered'.tr(context),
          value: QaStatusFilter.answered,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 8),
        _buildChip(
          context,
          label: 'Unanswered'.tr(context),
          value: QaStatusFilter.unanswered,
          icon: Icons.help_outline,
        ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required QaStatusFilter value,
    IconData? icon,
  }) {
    final isSelected = currentStatus == value;

    return GestureDetector(
      onTap: () => onStatusChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(26)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withAlpha(80)
                : AppColors.border.withAlpha(60),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
      context: context,
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
                  if (question.answerCount == 0)
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
                    )
                  else
                    // Mock answer cards for demonstration
                    ...List.generate(
                      question.answerCount.clamp(0, 3),
                      (index) => _buildMockAnswer(context, index),
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

  /// Build a placeholder answer card for the detail view.
  Widget _buildMockAnswer(BuildContext context, int index) {
    final mockAuthors = ['Rahul Verma', 'Ananya Patel', 'Dr. Priya Sharma'];
    final mockBodies = [
      'Great question! The characteristic equation method works by assuming a solution of the form e^(rx). Substituting into the ODE gives you a polynomial in r that you can solve.',
      'I found the Khan Academy series on this topic really helpful. They walk through complex roots with clear examples.',
      'For complex roots a +/- bi, the general solution takes the form e^(ax)(C1 cos(bx) + C2 sin(bx)). This comes from Euler\'s formula.',
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        blur: 8,
        opacity: 0.7,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answer author row
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.avatarWarm,
                  child: Text(
                    mockAuthors[index % mockAuthors.length][0],
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  mockAuthors[index % mockAuthors.length],
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${index + 1}d ago',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Answer body
            Text(
              mockBodies[index % mockBodies.length],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
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

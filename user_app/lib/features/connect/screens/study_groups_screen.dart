import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/connect_models.dart';
import '../../../providers/connect_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../widgets/connect_search.dart';
import '../widgets/study_group_card.dart';

/// Screen displaying list of study groups user can join.
///
/// Features:
/// - List of available study groups
/// - Filter by subject
/// - Create group FAB
/// - Join/Leave functionality
class StudyGroupsScreen extends ConsumerStatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  ConsumerState<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends ConsumerState<StudyGroupsScreen> {
  String? _selectedSubject;

  @override
  Widget build(BuildContext context) {
    final studyGroupsAsync = ref.watch(studyGroupsProvider);
    final userGroupsAsync = ref.watch(userStudyGroupsProvider);
    final subjects = ref.watch(connectSubjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topRight,
        opacity: 0.4,
        colors: [
          AppColors.meshPurple,
          AppColors.meshBlue,
          AppColors.meshGreen,
        ],
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App bar
              SliverToBoxAdapter(
                child: _buildAppBar(context),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: ConnectSearchBar(
                    showFilterButton: false,
                    onSearchSubmit: (query) {
                      ref
                          .read(connectFilterProvider.notifier)
                          .setSearchQuery(query);
                    },
                  ),
                ),
              ),

              // Subject filter chips
              SliverToBoxAdapter(
                child: _buildSubjectFilters(subjects),
              ),

              // My Groups section
              SliverToBoxAdapter(
                child: userGroupsAsync.when(
                  data: (groups) {
                    if (groups.isEmpty) return const SizedBox.shrink();
                    return _buildMyGroupsSection(groups);
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // Available groups header
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                  'Available Groups',
                  subtitle: 'Join a group to study together',
                ),
              ),

              // Groups list
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: studyGroupsAsync.when(
                  data: (groups) {
                    // Filter by subject if selected
                    var filteredGroups = groups;
                    if (_selectedSubject != null) {
                      filteredGroups = groups
                          .where((g) => g.subject == _selectedSubject)
                          .toList();
                    }

                    if (filteredGroups.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final group = filteredGroups[index];
                          final userGroups =
                              userGroupsAsync.valueOrNull ?? [];
                          final isJoined =
                              userGroups.any((g) => g.id == group.id);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StudyGroupCard(
                              group: group,
                              isJoined: isJoined,
                              onTap: () => _showGroupDetails(group),
                              onJoinLeave: () =>
                                  _handleJoinLeave(group, isJoined),
                            ),
                          );
                        },
                        childCount: filteredGroups.length,
                      ),
                    );
                  },
                  loading: () => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildLoadingSkeleton(),
                      ),
                      childCount: 4,
                    ),
                  ),
                  error: (error, _) => SliverToBoxAdapter(
                    child: _buildErrorState(error.toString()),
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateGroupFAB(),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          // Back button
          GlassContainer(
            blur: 10,
            opacity: 0.7,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(8),
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Study Groups',
                  style: AppTextStyles.headingMedium,
                ),
                Text(
                  'Learn together with peers',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectFilters(List<String> subjects) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: _selectedSubject == null,
            onTap: () => setState(() => _selectedSubject = null),
          ),
          const SizedBox(width: 8),
          ...subjects.take(6).map((subject) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(
                label: subject,
                isSelected: _selectedSubject == subject,
                onTap: () => setState(() => _selectedSubject = subject),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMyGroupsSection(List<StudyGroup> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('My Groups', showSeeAll: true),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: groups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return CompactStudyGroupCard(
                group: groups[index],
                isJoined: true,
                onTap: () => _showGroupDetails(groups[index]),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? subtitle,
    bool showSeeAll = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          if (showSeeAll)
            TextButton(
              onPressed: () {},
              child: Text(
                'See all',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader.circle(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoader(height: 16, width: 120),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 12, width: double.infinity),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 12, width: 100),
              SkeletonLoader(height: 28, width: 60),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return GlassCard(
      blur: 12,
      opacity: 0.8,
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
              Icons.group_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No groups found',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedSubject != null
                ? 'Try selecting a different subject'
                : 'Be the first to create a study group!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (_selectedSubject != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _selectedSubject = null),
              child: Text(
                'Clear filter',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return GlassCard(
      blur: 12,
      opacity: 0.8,
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
          const SizedBox(height: 16),
          GlassButton(
            label: 'Retry',
            icon: Icons.refresh,
            onPressed: () {
              ref.invalidate(studyGroupsProvider);
            },
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

  Widget _buildCreateGroupFAB() {
    return FloatingActionButton.extended(
      onPressed: _showCreateGroupSheet,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Create Group',
        style: AppTextStyles.buttonSmall.copyWith(color: Colors.white),
      ),
    );
  }

  void _showGroupDetails(StudyGroup group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GroupDetailsSheet(group: group),
    );
  }

  void _handleJoinLeave(StudyGroup group, bool isJoined) {
    final message = isJoined
        ? 'Left ${group.name}'
        : 'Joined ${group.name}!';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isJoined ? AppColors.textSecondary : AppColors.success,
      ),
    );

    // Refresh data
    ref.invalidate(userStudyGroupsProvider);
    ref.invalidate(studyGroupsProvider);
  }

  void _showCreateGroupSheet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create group feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Bottom sheet showing study group details.
class _GroupDetailsSheet extends StatelessWidget {
  final StudyGroup group;

  const _GroupDetailsSheet({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(180),
                              AppColors.primaryDark,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            group.initials,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: AppTextStyles.headingMedium,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                group.subject,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Description
                  if (group.description != null) ...[
                    Text(
                      group.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Stats
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.people,
                        label: 'Members',
                        value: '${group.memberCount}/${group.maxMembers}',
                      ),
                      const SizedBox(width: 24),
                      if (group.nextSessionTime != null)
                        _buildStatItem(
                          icon: Icons.schedule,
                          label: 'Next Session',
                          value: group.nextSessionString ?? 'TBD',
                          valueColor: AppColors.success,
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Creator info
                  Text(
                    'Created by',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryLight.withAlpha(50),
                        child: Text(
                          group.creatorName.isNotEmpty
                              ? group.creatorName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        group.creatorName,
                        style: AppTextStyles.labelMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Join button
                  GlassButton(
                    label: group.isFull ? 'Group is Full' : 'Join Group',
                    icon: group.isFull ? Icons.block : Icons.add,
                    onPressed: group.isFull
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Joined ${group.name}!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          },
                    backgroundColor:
                        group.isFull ? AppColors.surfaceVariant : AppColors.primary,
                    foregroundColor:
                        group.isFull ? AppColors.textTertiary : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

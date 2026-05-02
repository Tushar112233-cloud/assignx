library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/pro_network_post_model.dart';
import '../providers/pro_network_provider.dart';
import '../widgets/pro_filter_tabs_bar.dart';
import '../widgets/pro_network_hero.dart';
import '../widgets/pro_post_card.dart';
import '../widgets/pro_search_bar.dart';

/// Job Portal screen that lists jobs with category, type, and search filters.
class ProNetworkScreen extends ConsumerStatefulWidget {
  const ProNetworkScreen({super.key});

  @override
  ConsumerState<ProNetworkScreen> createState() => _ProNetworkScreenState();
}

class _ProNetworkScreenState extends ConsumerState<ProNetworkScreen> {
  JobCategory? _selectedCategory;
  JobType? _selectedType;
  String _searchQuery = '';

  /// Build the current [JobFilters] from local state.
  JobFilters get _filters => JobFilters(
        category: _selectedCategory,
        type: _selectedType,
        searchQuery: _searchQuery,
      );

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(filteredJobsProvider(_filters));
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Back button (only when navigated directly via route)
          if (canPop)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

          // Hero section
          const SliverToBoxAdapter(child: ProNetworkHero()),

          // Search bar
          SliverToBoxAdapter(
            child: ProSearchBar(
              onChanged: (query) => setState(() => _searchQuery = query),
            ),
          ),

          // Category filter pills
          SliverToBoxAdapter(
            child: ProFilterTabsBar(
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),

          // Job type filter row
          SliverToBoxAdapter(child: _JobTypeFilterRow(
            selectedType: _selectedType,
            onTypeChanged: (type) {
              setState(() => _selectedType = type);
            },
          )),

          // Results count
          SliverToBoxAdapter(
            child: jobsAsync.when(
              data: (jobs) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '${jobs.length} job${jobs.length == 1 ? '' : 's'} found',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),

          // Job list
          jobsAsync.when(
            data: (jobs) {
              if (jobs.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    hasFilters: _selectedCategory != null ||
                        _selectedType != null ||
                        _searchQuery.isNotEmpty,
                    onClearFilters: () {
                      setState(() {
                        _selectedCategory = null;
                        _selectedType = null;
                        _searchQuery = '';
                      });
                    },
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: jobs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return JobCard(
                      job: job,
                      onTap: () {
                        context.push('/pro-network/post/${job.id}');
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.textTertiary),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load jobs',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          ref.invalidate(filteredJobsProvider(_filters)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom padding for nav bar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Job type filter row (All / Full-time / Part-time / Internship / ...)
// ---------------------------------------------------------------------------

class _JobTypeFilterRow extends StatelessWidget {
  final JobType? selectedType;
  final ValueChanged<JobType?> onTypeChanged;

  const _JobTypeFilterRow({
    required this.selectedType,
    required this.onTypeChanged,
  });

  static const _types = JobType.values;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _types.asMap().entries.map((entry) {
          final index = entry.key;
          final type = entry.value;
          final isSelected = selectedType == type ||
              (selectedType == null && type == JobType.all);
          return Padding(
            padding:
                EdgeInsets.only(right: index < _types.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onTypeChanged(
                  type == JobType.all ? null : (selectedType == type ? null : type)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : AppColors.border.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  type.label,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state widget
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.work_off_outlined,
              size: 64,
              color: AppColors.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching jobs' : 'No jobs yet',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query'
                  : 'Check back later for new opportunities!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

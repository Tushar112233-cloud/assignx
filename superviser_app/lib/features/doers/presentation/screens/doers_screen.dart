import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/data/models/doer_model.dart';
import '../providers/doers_provider.dart';

/// Doers list screen.
class DoersScreen extends ConsumerStatefulWidget {
  const DoersScreen({super.key});

  @override
  ConsumerState<DoersScreen> createState() => _DoersScreenState();
}

class _DoersScreenState extends ConsumerState<DoersScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doersProvider.notifier).loadDoers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doersProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search doers...',
                  border: InputBorder.none,
                ),
                onChanged: (query) {
                  ref.read(doersProvider.notifier).search(query);
                },
              )
            : const Text('Doers'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(doersProvider.notifier).search('');
                }
              });
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
          ),
          IconButton(
            onPressed: () => _showFiltersSheet(context, ref),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filters bar
          if (_hasActiveFilters(state)) _ActiveFiltersBar(state: state),

          // Doers list
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.doers.isEmpty
                    ? const _EmptyDoers()
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(doersProvider.notifier).refresh(),
                        child: _DoersList(
                          doers: state.doers,
                          heroSection: _DoersHeroSection(doers: state.doers),
                          topPerformers: _TopPerformers(
                            doers: state.doers,
                            onDoerTap: (doer) {
                              context.pushNamed(
                                RouteNames.doerDetail,
                                pathParameters: {'doerId': doer.id},
                              );
                            },
                          ),
                          onDoerTap: (doer) {
                            context.pushNamed(
                              RouteNames.doerDetail,
                              pathParameters: {'doerId': doer.id},
                            );
                          },
                          onLoadMore: () {
                            ref.read(doersProvider.notifier).loadMore();
                          },
                          isLoadingMore: state.isLoadingMore,
                          hasMore: state.hasMore,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilters(DoersState state) {
    return state.selectedExpertise != null ||
        state.isAvailableOnly ||
        state.minRating != null;
  }

  void _showFiltersSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _DoersFilterSheet(ref: ref),
    );
  }
}

/// Active filters bar.
class _ActiveFiltersBar extends ConsumerWidget {
  const _ActiveFiltersBar({required this.state});

  final DoersState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (state.selectedExpertise != null)
                    _FilterChip(
                      label: state.selectedExpertise!,
                      onRemove: () {
                        ref.read(doersProvider.notifier).setExpertiseFilter(null);
                      },
                    ),
                  if (state.isAvailableOnly)
                    _FilterChip(
                      label: 'Available only',
                      onRemove: () {
                        ref.read(doersProvider.notifier).setAvailableOnly(false);
                      },
                    ),
                  if (state.minRating != null)
                    _FilterChip(
                      label: '${state.minRating}+ stars',
                      onRemove: () {
                        ref.read(doersProvider.notifier).setMinRating(null);
                      },
                    ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(doersProvider.notifier).clearFilters();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        labelStyle: const TextStyle(fontSize: 12),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

/// Doers filter sheet.
class _DoersFilterSheet extends ConsumerStatefulWidget {
  const _DoersFilterSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_DoersFilterSheet> createState() => _DoersFilterSheetState();
}

class _DoersFilterSheetState extends ConsumerState<_DoersFilterSheet> {
  late String? _selectedExpertise;
  late bool _isAvailableOnly;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    final state = widget.ref.read(doersProvider);
    _selectedExpertise = state.selectedExpertise;
    _isAvailableOnly = state.isAvailableOnly;
    _minRating = state.minRating;
  }

  @override
  Widget build(BuildContext context) {
    final expertiseAreas = ref.watch(expertiseAreasProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Filter Doers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedExpertise = null;
                        _isAvailableOnly = false;
                        _minRating = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Filters
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  // Available only
                  SwitchListTile(
                    title: const Text('Available only'),
                    subtitle: const Text('Show only doers ready for work'),
                    value: _isAvailableOnly,
                    onChanged: (value) {
                      setState(() => _isAvailableOnly = value);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Minimum rating
                  Text(
                    'Minimum Rating',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [null, 3.0, 3.5, 4.0, 4.5].map((rating) {
                      final isSelected = _minRating == rating;
                      return ChoiceChip(
                        label: Text(rating == null ? 'Any' : '$rating+'),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() => _minRating = rating);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Expertise
                  Text(
                    'Expertise',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  expertiseAreas.when(
                    data: (areas) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: _selectedExpertise == null,
                          onSelected: (_) {
                            setState(() => _selectedExpertise = null);
                          },
                        ),
                        ...areas.map((area) {
                          final isSelected = _selectedExpertise == area;
                          return ChoiceChip(
                            label: Text(area),
                            selected: isSelected,
                            onSelected: (_) {
                              setState(() => _selectedExpertise = area);
                            },
                          );
                        }),
                      ],
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, _) => const Text('Failed to load'),
                  ),
                ],
              ),
            ),

            // Apply button
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  final notifier = widget.ref.read(doersProvider.notifier);
                  notifier.setExpertiseFilter(_selectedExpertise);
                  notifier.setAvailableOnly(_isAvailableOnly);
                  notifier.setMinRating(_minRating);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Doers list with hero section and top performers.
class _DoersList extends StatelessWidget {
  const _DoersList({
    required this.doers,
    required this.heroSection,
    required this.topPerformers,
    required this.onDoerTap,
    required this.onLoadMore,
    required this.isLoadingMore,
    required this.hasMore,
  });

  final List<DoerModel> doers;
  final Widget heroSection;
  final Widget topPerformers;
  final void Function(DoerModel) onDoerTap;
  final VoidCallback onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    // 2 header items (hero + top performers) + doers + optional loading
    final headerCount = 2;
    final totalCount = headerCount + doers.length + (isLoadingMore ? 1 : 0);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: totalCount,
        itemBuilder: (context, index) {
          if (index == 0) return heroSection;
          if (index == 1) return topPerformers;

          final doerIndex = index - headerCount;
          if (doerIndex == doers.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final doer = doers[doerIndex];
          return DoerCard(
            doer: doer,
            onTap: () => onDoerTap(doer),
          );
        },
      ),
    );
  }
}

/// Doer card widget with action buttons and success rate.
class DoerCard extends StatelessWidget {
  const DoerCard({
    super.key,
    required this.doer,
    required this.onTap,
  });

  final DoerModel doer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Avatar with availability indicator
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        backgroundImage: doer.avatarUrl != null
                            ? NetworkImage(doer.avatarUrl!)
                            : null,
                        child: doer.avatarUrl == null
                            ? Text(
                                doer.initials,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: doer.isAvailable ? AppColors.success : AppColors.textSecondaryLight,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Doer info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                doer.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            // Rating
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  doer.rating.toStringAsFixed(1),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Expertise tags
                        if (doer.expertise.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: doer.expertise.take(3).map((exp) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  exp,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 10,
                                      ),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 8),

                        // Stats row with success rate
                        Row(
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doer.completedProjects} completed',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 11,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            if (doer.activeProjects > 0) ...[
                              Icon(
                                Icons.play_circle_outline,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${doer.activeProjects} active',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
                                      fontSize: 11,
                                    ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            // Success rate
                            Icon(
                              Icons.check_circle_outline,
                              size: 14,
                              color: doer.successRate >= 90
                                  ? AppColors.success
                                  : doer.successRate >= 70
                                      ? AppColors.warning
                                      : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${doer.successRate.toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: doer.successRate >= 90
                                        ? AppColors.success
                                        : doer.successRate >= 70
                                            ? AppColors.warning
                                            : AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),

              // Action buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to assign doer flow
                      },
                      icon: const Icon(Icons.assignment_ind, size: 16),
                      label: const Text('Assign'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to chat with doer
                      },
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(
                          color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hero section showing doer network statistics.
class _DoersHeroSection extends StatelessWidget {
  const _DoersHeroSection({required this.doers});

  final List<DoerModel> doers;

  @override
  Widget build(BuildContext context) {
    final totalDoers = doers.length;
    final available = doers.where((d) => d.isAvailable).length;
    final busy = doers.where((d) => !d.isAvailable).length;
    final topRated = doers.where((d) => d.rating >= 4.0).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accentDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                'Doer Network',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _HeroStat(label: 'Total Doers', value: '$totalDoers'),
              _HeroStat(label: 'Available', value: '$available'),
              _HeroStat(label: 'Busy', value: '$busy'),
              _HeroStat(label: 'Top Rated', value: '$topRated'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Single stat item in the hero section.
class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Top performers horizontal scroll section.
class _TopPerformers extends StatelessWidget {
  const _TopPerformers({
    required this.doers,
    required this.onDoerTap,
  });

  final List<DoerModel> doers;
  final void Function(DoerModel) onDoerTap;

  @override
  Widget build(BuildContext context) {
    // Sort by rating descending, take top 10
    final topDoers = List<DoerModel>.from(doers)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final performers = topDoers.take(10).toList();

    if (performers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Top Performers',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: performers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final doer = performers[index];
              return GestureDetector(
                onTap: () => onDoerTap(doer),
                child: Container(
                  width: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                        backgroundImage: doer.avatarUrl != null
                            ? NetworkImage(doer.avatarUrl!)
                            : null,
                        child: doer.avatarUrl == null
                            ? Text(
                                doer.initials,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        doer.name.split(' ').first,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            doer.rating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Empty doers state.
class _EmptyDoers extends StatelessWidget {
  const _EmptyDoers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No doers found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search criteria',
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

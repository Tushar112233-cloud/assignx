library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/business_hub_post_model.dart';
import '../providers/business_hub_provider.dart';
import '../widgets/business_filter_tabs_bar.dart';
import '../widgets/business_hub_hero.dart';
import '../widgets/business_post_card.dart';
import '../widgets/business_search_bar.dart';

/// Business Hub screen showing investors with funding stage filters.
class BusinessHubScreen extends ConsumerStatefulWidget {
  const BusinessHubScreen({super.key});

  @override
  ConsumerState<BusinessHubScreen> createState() => _BusinessHubScreenState();
}

class _BusinessHubScreenState extends ConsumerState<BusinessHubScreen> {
  FundingStage? _selectedStage;
  String _searchQuery = '';

  List<Investor> _filterInvestors(List<Investor> investors) {
    var filtered = investors;

    if (_selectedStage != null && _selectedStage != FundingStage.all) {
      filtered = filtered
          .where((i) => i.fundingStages.contains(_selectedStage))
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((i) {
        return i.name.toLowerCase().contains(query) ||
            i.firm.toLowerCase().contains(query) ||
            i.sectors.any((s) => s.toLowerCase().contains(query)) ||
            (i.description?.toLowerCase().contains(query) ?? false) ||
            (i.location?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final investorsAsync = ref.watch(investorsProvider);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Back button (only shown when navigated to directly via route)
          if (canPop)
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),

          // Hero section
          const SliverToBoxAdapter(child: BusinessHubHero()),

          // Search bar
          SliverToBoxAdapter(
            child: BusinessSearchBar(
              onChanged: (query) => setState(() => _searchQuery = query),
            ),
          ),

          // Funding stage filter tabs
          SliverToBoxAdapter(
            child: BusinessFilterTabsBar(
              selectedStage: _selectedStage,
              onStageChanged: (stage) {
                setState(() => _selectedStage = stage);
              },
            ),
          ),

          // Investor count
          SliverToBoxAdapter(
            child: investorsAsync.when(
              data: (investors) {
                final filtered = _filterInvestors(investors);
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    '${filtered.length} investor${filtered.length == 1 ? '' : 's'}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Investor list
          investorsAsync.when(
            data: (investors) {
              final filtered = _filterInvestors(investors);

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    hasFilters: _selectedStage != null ||
                        _searchQuery.isNotEmpty,
                    onClearFilters: () {
                      setState(() {
                        _selectedStage = null;
                        _searchQuery = '';
                      });
                    },
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final investor = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InvestorCard(
                          investor: investor,
                          onTap: () {
                            context
                                .push('/business-hub/post/${investor.id}');
                          },
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
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
                      'Failed to load investors',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => ref.invalidate(investorsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

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
              hasFilters
                  ? Icons.filter_list_off
                  : Icons.account_balance_outlined,
              size: 64,
              color: AppColors.textTertiary.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No matching investors' : 'No investors yet',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query'
                  : 'Investor profiles will appear here soon',
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

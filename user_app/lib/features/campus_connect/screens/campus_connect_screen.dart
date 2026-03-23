import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../data/models/user_type.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/marketplace_provider.dart';
import '../widgets/campus_connect_hero.dart';
import '../widgets/college_filter.dart';
import '../widgets/filter_tabs_bar.dart';
import '../widgets/post_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/housing_filters.dart';
import '../widgets/event_filters.dart';
import '../widgets/resource_filters.dart';
import '../widgets/housing_restricted_state.dart';
import '../widgets/campus_connect_filter_sheet.dart';
import '../widgets/quick_categories.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Campus Connect screen — coffee brown theme with colorful icon pops.
///
/// Clean, breathable layout with:
/// - Compact hero banner (coffee brown gradient)
/// - Integrated search with coffee brown focus state
/// - Minimal filter pills with category-colored icons
/// - Refined masonry grid of post cards
class CampusConnectScreen extends ConsumerStatefulWidget {
  const CampusConnectScreen({super.key});

  @override
  ConsumerState<CampusConnectScreen> createState() =>
      _CampusConnectScreenState();
}

class _CampusConnectScreenState extends ConsumerState<CampusConnectScreen> {
  CampusConnectCategory? _selectedCategory;
  String _searchQuery = '';

  // Internal filters for each category
  HousingFilters _housingFilters = HousingFilters.empty;
  EventFilters _eventFilters = EventFilters.empty;
  ResourceFilters _resourceFilters = ResourceFilters.empty;

  bool _isStudent(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profile = authState.valueOrNull?.profile;
    return profile?.userType == UserType.student;
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(marketplaceListingsProvider);
    final isStudent = _isStudent(ref);
    final isHousingRestricted =
        !isStudent && _selectedCategory == CampusConnectCategory.housing;

    return SubtleGradientScaffold.standard(
      body: Stack(
        children: [
          RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              ref.invalidate(marketplaceListingsProvider);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. Hero banner
                SliverToBoxAdapter(
                  child: CampusConnectHero(
                    onVerifyCollege: () {
                      context.push('/settings/college-verification');
                    },
                  ),
                ),

                // 2. Quick category shortcuts — colorful icon pops
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 6),
                    child: QuickCategories(
                      onCategorySelected: (category) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  ),
                ),

                // 3. Search bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: SearchBarWidget(
                      initialValue: _searchQuery,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      onFilterTap: () => _showUnifiedFilterSheet(context),
                    ),
                  ),
                ),

                // 4. Filter tabs + college filter
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterTabsBar(
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (category) {
                          setState(() => _selectedCategory = category);
                        },
                        isStudent: isStudent,
                      ),
                      // College filter + internal filter row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CollegeFilterChip(
                              onFilterChanged: () => setState(() {}),
                            ),
                            if (_selectedCategory != null &&
                                _hasInternalFilters(_selectedCategory!)) ...[
                              const SizedBox(width: 8),
                              _InternalFilterChip(
                                category: _selectedCategory!,
                                filterCount: _getFilterCountForCategory(
                                    _selectedCategory!),
                                onTap: () => _showInternalFilters(
                                    context, _selectedCategory!),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Results header
                SliverToBoxAdapter(
                  child: listingsAsync.when(
                    data: (listings) {
                      final filteredCount = _filterListings(listings).length;
                      return _ResultsHeader(count: filteredCount);
                    },
                    loading: () => const _ResultsHeader(count: 0),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),

                // 6. Post feed
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: isHousingRestricted
                      ? SliverToBoxAdapter(
                          child: HousingRestrictedState(
                            onClearFilters: () {
                              setState(() => _selectedCategory = null);
                            },
                          ),
                        )
                      : listingsAsync.when(
                          data: (listings) {
                            var filteredListings = _filterListings(listings);
                            if (!isStudent) {
                              filteredListings = filteredListings
                                  .where(
                                      (l) => l.type != ListingType.housing)
                                  .toList();
                            }

                            if (filteredListings.isEmpty) {
                              return SliverToBoxAdapter(
                                child: _EmptyState(
                                  hasFilters: _selectedCategory != null ||
                                      _searchQuery.isNotEmpty,
                                  onClearFilters: () {
                                    setState(() {
                                      _selectedCategory = null;
                                      _searchQuery = '';
                                    });
                                  },
                                ),
                              );
                            }

                            return _StaggeredPostsGrid(
                                listings: filteredListings);
                          },
                          loading: () => const SliverToBoxAdapter(
                            child: _LoadingGrid(),
                          ),
                          error: (error, stack) => SliverToBoxAdapter(
                            child: _ErrorState(
                              error: error.toString(),
                              onRetry: () {
                                ref.invalidate(marketplaceListingsProvider);
                              },
                            ),
                          ),
                        ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),

          // FAB
          Positioned(
            bottom: 100,
            right: 20,
            child: _CreatePostFab(
              onTap: () => context.push('/campus-connect/create'),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Filtering logic (unchanged)
  // ─────────────────────────────────────────────────────────

  List<MarketplaceListing> _filterListings(List<MarketplaceListing> listings) {
    var filtered = listings;

    final collegeFilter = ref.read(collegeFilterProvider);
    final filterCollege = collegeFilter.filterCollege;
    if (filterCollege != null) {
      filtered = filtered.where((listing) {
        final listingCollege = listing.collegeName ?? listing.userUniversity;
        if (listingCollege == null) return false;
        return listingCollege
            .toLowerCase()
            .contains(filterCollege.toLowerCase());
      }).toList();
    }

    if (_selectedCategory != null &&
        _selectedCategory != CampusConnectCategory.all) {
      filtered = filtered.where((listing) {
        switch (_selectedCategory!) {
          case CampusConnectCategory.all:
            return true;
          case CampusConnectCategory.questions:
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('?') ||
                    title.contains('help') ||
                    title.contains('how') ||
                    title.contains('what') ||
                    title.contains('why'));
          case CampusConnectCategory.housing:
            return listing.type == ListingType.housing;
          case CampusConnectCategory.opportunities:
            return listing.type == ListingType.opportunity;
          case CampusConnectCategory.events:
            return listing.type == ListingType.event;
          case CampusConnectCategory.marketplace:
            return listing.type == ListingType.product;
          case CampusConnectCategory.resources:
            return listing.type == ListingType.product &&
                (listing.metadata?['resource_type'] != null ||
                    listing.title.toLowerCase().contains('notes') ||
                    listing.title.toLowerCase().contains('book'));
          case CampusConnectCategory.lostFound:
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('lost') ||
                    title.contains('found') ||
                    title.contains('missing'));
          case CampusConnectCategory.rides:
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('ride') ||
                    title.contains('carpool') ||
                    title.contains('lift'));
          case CampusConnectCategory.studyGroups:
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('study group') ||
                    title.contains('study buddy') ||
                    title.contains('group study'));
          case CampusConnectCategory.clubs:
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('club') ||
                    title.contains('society') ||
                    title.contains('team'));
          case CampusConnectCategory.announcements:
            return listing.type == ListingType.poll ||
                (listing.metadata?['is_announcement'] == true);
          case CampusConnectCategory.discussions:
            return listing.type == ListingType.communityPost ||
                listing.type == ListingType.poll;
          case CampusConnectCategory.community:
            return listing.type == ListingType.communityPost ||
                listing.type == ListingType.poll;
          case CampusConnectCategory.products:
            return listing.type == ListingType.product;
          case CampusConnectCategory.saved:
            return false;
        }
      }).toList();

      filtered = _applyInternalFilters(filtered, _selectedCategory!);
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((listing) {
        return listing.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (listing.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    return filtered;
  }

  List<MarketplaceListing> _applyInternalFilters(
    List<MarketplaceListing> listings,
    CampusConnectCategory category,
  ) {
    switch (category) {
      case CampusConnectCategory.housing:
        return _applyHousingFilters(listings);
      case CampusConnectCategory.events:
      case CampusConnectCategory.opportunities:
        return _applyEventFilters(listings);
      case CampusConnectCategory.resources:
      case CampusConnectCategory.products:
      case CampusConnectCategory.marketplace:
        return _applyResourceFilters(listings);
      default:
        return listings;
    }
  }

  List<MarketplaceListing> _applyHousingFilters(
      List<MarketplaceListing> listings) {
    if (!_housingFilters.hasActiveFilters) return listings;
    return listings.where((listing) {
      if (listing.price != null) {
        if (listing.price! < _housingFilters.priceRange.start) return false;
        if (listing.price! > _housingFilters.priceRange.end) return false;
      }
      if (_housingFilters.location != null &&
          _housingFilters.location!.isNotEmpty) {
        if (listing.location == null) return false;
        if (!listing.location!
            .toLowerCase()
            .contains(_housingFilters.location!.toLowerCase())) {
          return false;
        }
      }
      if (_housingFilters.distanceFromCampus != null &&
          listing.distanceKm != null) {
        final maxDistanceKm =
            _getDistanceInKm(_housingFilters.distanceFromCampus!);
        if (listing.distanceKm! > maxDistanceKm) return false;
      }
      if (_housingFilters.propertyType.isNotEmpty) {
        final propertyType = listing.metadata?['property_type'] as String?;
        if (propertyType == null ||
            !_housingFilters.propertyType.contains(propertyType)) {
          return false;
        }
      }
      if (_housingFilters.amenities.isNotEmpty) {
        final listingAmenities =
            (listing.metadata?['amenities'] as List<dynamic>?)
                    ?.cast<String>() ??
                [];
        final hasAllAmenities = _housingFilters.amenities.every(
          (amenity) => listingAmenities.contains(amenity),
        );
        if (!hasAllAmenities) return false;
      }
      return true;
    }).toList();
  }

  double _getDistanceInKm(String distance) {
    switch (distance) {
      case '0-1':
        return 1.0;
      case '1-2':
        return 2.0;
      case '2-5':
        return 5.0;
      case '5-10':
        return 10.0;
      case '10+':
        return double.infinity;
      default:
        return double.infinity;
    }
  }

  List<MarketplaceListing> _applyEventFilters(
      List<MarketplaceListing> listings) {
    if (!_eventFilters.hasActiveFilters) return listings;
    return listings.where((listing) {
      if (_eventFilters.eventType.isNotEmpty) {
        final eventType = listing.metadata?['event_type'] as String?;
        if (eventType == null ||
            !_eventFilters.eventType.contains(eventType)) {
          return false;
        }
      }
      if (_eventFilters.dateFrom != null) {
        final eventDate = listing.metadata?['event_date'] != null
            ? DateTime.tryParse(listing.metadata!['event_date'] as String)
            : null;
        if (eventDate != null) {
          if (eventDate.isBefore(_eventFilters.dateFrom!)) return false;
          if (_eventFilters.dateTo != null &&
              eventDate.isAfter(_eventFilters.dateTo!)) {
            return false;
          }
        }
      }
      if (_eventFilters.isFree == true) {
        if (listing.price != null && listing.price! > 0) return false;
      } else if (_eventFilters.isFree == false) {
        if (listing.price == null || listing.price == 0) return false;
      }
      if (_eventFilters.location != null &&
          _eventFilters.location!.isNotEmpty) {
        if (listing.location == null) return false;
        if (!listing.location!
            .toLowerCase()
            .contains(_eventFilters.location!.toLowerCase())) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  List<MarketplaceListing> _applyResourceFilters(
      List<MarketplaceListing> listings) {
    if (!_resourceFilters.hasActiveFilters) return listings;
    return listings.where((listing) {
      if (_resourceFilters.subject.isNotEmpty) {
        final subject = listing.metadata?['subject'] as String?;
        if (subject == null ||
            !_resourceFilters.subject.contains(subject)) {
          return false;
        }
      }
      if (_resourceFilters.resourceType.isNotEmpty) {
        final resourceType = listing.metadata?['resource_type'] as String?;
        if (resourceType == null ||
            !_resourceFilters.resourceType.contains(resourceType)) {
          return false;
        }
      }
      if (_resourceFilters.difficulty != null) {
        final difficulty = listing.metadata?['difficulty'] as String?;
        if (difficulty == null || difficulty != _resourceFilters.difficulty) {
          return false;
        }
      }
      if (_resourceFilters.minRating != null) {
        final rating = (listing.metadata?['rating'] as num?)?.toDouble();
        if (rating == null || rating < _resourceFilters.minRating!) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int _getFilterCountForCategory(CampusConnectCategory category) {
    switch (category) {
      case CampusConnectCategory.housing:
        return _housingFilters.activeFilterCount;
      case CampusConnectCategory.events:
      case CampusConnectCategory.opportunities:
        return _eventFilters.activeFilterCount;
      case CampusConnectCategory.resources:
      case CampusConnectCategory.products:
      case CampusConnectCategory.marketplace:
        return _resourceFilters.activeFilterCount;
      case CampusConnectCategory.all:
      case CampusConnectCategory.questions:
      case CampusConnectCategory.lostFound:
      case CampusConnectCategory.rides:
      case CampusConnectCategory.studyGroups:
      case CampusConnectCategory.clubs:
      case CampusConnectCategory.announcements:
      case CampusConnectCategory.discussions:
      case CampusConnectCategory.community:
      case CampusConnectCategory.saved:
        return 0;
    }
  }

  Future<void> _showHousingFilters(BuildContext context) async {
    final result = await HousingFiltersSheet.show(
      context,
      initialFilters: _housingFilters,
    );
    if (result != null) setState(() => _housingFilters = result);
  }

  Future<void> _showEventFilters(BuildContext context) async {
    final result = await EventFiltersSheet.show(
      context,
      initialFilters: _eventFilters,
    );
    if (result != null) setState(() => _eventFilters = result);
  }

  Future<void> _showResourceFilters(BuildContext context) async {
    final result = await ResourceFiltersSheet.show(
      context,
      initialFilters: _resourceFilters,
    );
    if (result != null) setState(() => _resourceFilters = result);
  }

  bool _hasInternalFilters(CampusConnectCategory category) {
    switch (category) {
      case CampusConnectCategory.housing:
      case CampusConnectCategory.events:
      case CampusConnectCategory.opportunities:
      case CampusConnectCategory.resources:
      case CampusConnectCategory.products:
      case CampusConnectCategory.marketplace:
        return true;
      case CampusConnectCategory.all:
      case CampusConnectCategory.questions:
      case CampusConnectCategory.lostFound:
      case CampusConnectCategory.rides:
      case CampusConnectCategory.studyGroups:
      case CampusConnectCategory.clubs:
      case CampusConnectCategory.announcements:
      case CampusConnectCategory.discussions:
      case CampusConnectCategory.community:
      case CampusConnectCategory.saved:
        return false;
    }
  }

  Future<void> _showInternalFilters(
      BuildContext context, CampusConnectCategory category) async {
    switch (category) {
      case CampusConnectCategory.housing:
        await _showHousingFilters(context);
        break;
      case CampusConnectCategory.events:
      case CampusConnectCategory.opportunities:
        await _showEventFilters(context);
        break;
      case CampusConnectCategory.resources:
      case CampusConnectCategory.products:
      case CampusConnectCategory.marketplace:
        await _showResourceFilters(context);
        break;
      default:
        break;
    }
  }

  Future<void> _showUnifiedFilterSheet(BuildContext context) async {
    final currentFilters = CampusConnectFilters(
      housing: _housingFilters,
      events: _eventFilters,
      resources: _resourceFilters,
    );

    FilterTab? initialTab;
    if (_selectedCategory == CampusConnectCategory.housing) {
      initialTab = FilterTab.housing;
    } else if (_selectedCategory == CampusConnectCategory.events ||
        _selectedCategory == CampusConnectCategory.opportunities) {
      initialTab = FilterTab.events;
    } else if (_selectedCategory == CampusConnectCategory.resources ||
        _selectedCategory == CampusConnectCategory.products ||
        _selectedCategory == CampusConnectCategory.marketplace) {
      initialTab = FilterTab.resources;
    }

    final result = await CampusConnectFilterSheet.show(
      context,
      initialFilters: currentFilters,
      initialTab: initialTab,
    );

    if (result != null) {
      setState(() {
        _housingFilters = result.housing;
        _eventFilters = result.events;
        _resourceFilters = result.resources;
      });
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Private Widgets
// ─────────────────────────────────────────────────────────────

/// Results header — post count + sort button.
class _ResultsHeader extends StatelessWidget {
  final int count;

  const _ResultsHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$count ',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: 'posts',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              // TODO: Show sort options
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Latest',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Internal filter chip for category-specific advanced filters.
class _InternalFilterChip extends StatelessWidget {
  final CampusConnectCategory category;
  final int filterCount;
  final VoidCallback onTap;

  const _InternalFilterChip({
    required this.category,
    required this.filterCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasActive = filterCount > 0;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: hasActive
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasActive
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded,
                size: 14,
                color:
                    hasActive ? AppColors.primary : AppColors.textTertiary),
            const SizedBox(width: 4),
            Text(
              'Filters',
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                fontWeight: hasActive ? FontWeight.w700 : FontWeight.w500,
                color:
                    hasActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (filterCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$filterCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Teal-accented FAB for creating new posts.
class _CreatePostFab extends StatelessWidget {
  final VoidCallback onTap;

  const _CreatePostFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: AppColors.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 54,
          height: 54,
          alignment: Alignment.center,
          child: const Icon(
            Icons.edit_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Staggered grid of post cards.
class _StaggeredPostsGrid extends StatelessWidget {
  final List<MarketplaceListing> listings;

  const _StaggeredPostsGrid({required this.listings});

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return _buildPostCard(context, listing, index);
      },
    );
  }

  Widget _buildPostCard(
      BuildContext context, MarketplaceListing listing, int index) {
    switch (listing.type) {
      case ListingType.communityPost:
      case ListingType.poll:
        if (_shouldShowAsHelpPost(listing, index)) {
          return HelpPostCard(
            listing: listing,
            onTap: () => _navigateToDetail(context, listing),
            onAnswer: () => _navigateToDetail(context, listing),
          );
        }
        return DiscussionPostCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onLike: () {},
          onComment: () => _navigateToDetail(context, listing),
        );

      case ListingType.event:
        return EventPostCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onRsvp: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('RSVP confirmed!'),
                backgroundColor: AppColors.success,
              ),
            );
          },
        );

      case ListingType.opportunity:
        return OpportunityPostCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
        );

      case ListingType.product:
        return ProductPostCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onLike: () {},
        );

      case ListingType.housing:
        return HousingPostCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onContact: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Opening chat...')),
            );
          },
        );
    }
  }

  bool _shouldShowAsHelpPost(MarketplaceListing listing, int index) {
    final title = listing.title.toLowerCase();
    return title.contains('struggling') ||
        title.contains('help') ||
        title.contains('difficult') ||
        title.contains('problem') ||
        title.contains('issue') ||
        (index % 5 == 1 && listing.commentCount < 3);
  }

  void _navigateToDetail(BuildContext context, MarketplaceListing listing) {
    context.push('/marketplace/${listing.id}');
  }
}

/// Loading skeleton grid — shimmer placeholders.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        final height = index.isEven ? 150.0 : 185.0;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: index.isEven ? 70 : 80,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 70,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Empty state — clean and friendly.
class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.filter_list_off : Icons.inbox_outlined,
              size: 40,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No posts found' : 'No posts yet',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search'
                : 'Be the first to share something!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 20),
            Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onClearFilters,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.filter_alt_off,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Clear Filters',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Material(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.refresh_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Retry',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

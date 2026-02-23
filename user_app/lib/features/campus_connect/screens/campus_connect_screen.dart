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
import '../../../shared/widgets/dashboard_app_bar.dart';
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

/// Campus Connect screen with staggered feed of community content.
///
/// Features a header bar, gradient hero section with chat icon, search functionality,
/// filter tabs, listings count, and a Pinterest-style staggered grid of various post types.
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

  /// Check if current user is a student.
  bool _isStudent(WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profile = authState.valueOrNull?.profile;
    return profile?.userType == UserType.student;
  }

  @override
  Widget build(BuildContext context) {
    final listingsAsync = ref.watch(marketplaceListingsProvider);
    final isStudent = _isStudent(ref);

    // Check if non-student is trying to view housing
    final isHousingRestricted =
        !isStudent && _selectedCategory == CampusConnectCategory.housing;

    return Scaffold(
      // Transparent to show SubtleGradientScaffold from MainShell
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(marketplaceListingsProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Unified Dashboard App Bar (dark theme)
                const SliverToBoxAdapter(
                  child: DashboardAppBar(),
                ),

                // Gradient hero section with chat icon
                const SliverToBoxAdapter(
                  child: CampusConnectHero(),
                ),

                // Search bar
                SliverToBoxAdapter(
                  child: SearchBarWidget(
                    initialValue: _searchQuery,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onFilterTap: () {
                      // Show unified filter sheet (web-style with tabs)
                      _showUnifiedFilterSheet(context);
                    },
                  ),
                ),

                // Filter tabs with college filter - pass isStudent to conditionally show housing
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FilterTabsBar(
                        selectedCategory: _selectedCategory,
                        onCategoryChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        isStudent: isStudent,
                      ),
                      // College filter chip and internal filters row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CollegeFilterChip(
                              onFilterChanged: () {
                                // Refresh listings when filter changes
                                setState(() {});
                              },
                            ),
                            // Internal filter button for filterable categories
                            if (_selectedCategory != null &&
                                _hasInternalFilters(_selectedCategory!)) ...[
                              const SizedBox(width: 8),
                              _InternalFilterChip(
                                category: _selectedCategory!,
                                filterCount: _getFilterCountForCategory(_selectedCategory!),
                                onTap: () => _showInternalFilters(context, _selectedCategory!),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Listings count
                SliverToBoxAdapter(
                  child: listingsAsync.when(
                    data: (listings) {
                      final filteredCount = _filterListings(listings).length;
                      return _ListingsCount(count: filteredCount);
                    },
                    loading: () => const _ListingsCount(count: 0),
                    error: (error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),

                // Staggered posts grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: isHousingRestricted
                      // Show housing restricted state for non-students
                      ? SliverToBoxAdapter(
                          child: HousingRestrictedState(
                            onClearFilters: () {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                          ),
                        )
                      : listingsAsync.when(
                    data: (listings) {
                      // Filter listings based on selected category and search
                      // Also filter out housing for non-students
                      var filteredListings = _filterListings(listings);
                      if (!isStudent) {
                        filteredListings = filteredListings
                            .where((l) => l.type != ListingType.housing)
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

                      return _StaggeredPostsGrid(listings: filteredListings);
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

                // Bottom padding for navigation
                const SliverToBoxAdapter(
                  child: SizedBox(height: 120),
                ),
              ],
            ),
          ),

          // Floating Action Button
          Positioned(
            bottom: 100,
            right: 20,
            child: _FloatingActionButton(
              onTap: () {
                // Handle FAB tap - create new Campus Connect post
                context.push('/campus-connect/create');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Filter listings based on category, search query, college filter, and internal filters.
  /// Updated to match web categories: All, Events, Housing, Resources, Discussions
  List<MarketplaceListing> _filterListings(List<MarketplaceListing> listings) {
    var filtered = listings;

    // Filter by college
    final collegeFilter = ref.read(collegeFilterProvider);
    final filterCollege = collegeFilter.filterCollege;
    if (filterCollege != null) {
      filtered = filtered.where((listing) {
        // Match by collegeName or userUniversity field
        final listingCollege = listing.collegeName ?? listing.userUniversity;
        if (listingCollege == null) return false;
        return listingCollege.toLowerCase().contains(filterCollege.toLowerCase());
      }).toList();
    }

    // Filter by category (web-style categories)
    if (_selectedCategory != null && _selectedCategory != CampusConnectCategory.all) {
      filtered = filtered.where((listing) {
        switch (_selectedCategory!) {
          case CampusConnectCategory.all:
            return true; // Show all
          case CampusConnectCategory.questions:
            // Questions/academic doubts
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
            // Study materials/resources
            return listing.type == ListingType.product &&
                (listing.metadata?['resource_type'] != null ||
                    listing.title.toLowerCase().contains('notes') ||
                    listing.title.toLowerCase().contains('book'));
          case CampusConnectCategory.lostFound:
            // Lost & Found items
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('lost') ||
                    title.contains('found') ||
                    title.contains('missing'));
          case CampusConnectCategory.rides:
            // Carpool/rides
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('ride') ||
                    title.contains('carpool') ||
                    title.contains('lift'));
          case CampusConnectCategory.studyGroups:
            // Study groups
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('study group') ||
                    title.contains('study buddy') ||
                    title.contains('group study'));
          case CampusConnectCategory.clubs:
            // Clubs and societies
            final title = listing.title.toLowerCase();
            return listing.type == ListingType.communityPost &&
                (title.contains('club') ||
                    title.contains('society') ||
                    title.contains('team'));
          case CampusConnectCategory.announcements:
            // Official announcements
            return listing.type == ListingType.poll ||
                (listing.metadata?['is_announcement'] == true);
          case CampusConnectCategory.discussions:
            return listing.type == ListingType.communityPost ||
                listing.type == ListingType.poll;
          // Legacy categories for backwards compatibility
          case CampusConnectCategory.community:
            return listing.type == ListingType.communityPost ||
                listing.type == ListingType.poll;
          case CampusConnectCategory.products:
            return listing.type == ListingType.product;
          case CampusConnectCategory.saved:
            return false; // Saved is handled separately
        }
      }).toList();

      // Apply internal filters based on category
      filtered = _applyInternalFilters(filtered, _selectedCategory!);
    }

    // Filter by search query
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

  /// Apply internal filters based on category type.
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

  /// Apply housing-specific filters.
  List<MarketplaceListing> _applyHousingFilters(List<MarketplaceListing> listings) {
    if (!_housingFilters.hasActiveFilters) return listings;

    return listings.where((listing) {
      // Filter by price range
      if (listing.price != null) {
        if (listing.price! < _housingFilters.priceRange.start) return false;
        if (listing.price! > _housingFilters.priceRange.end) return false;
      }

      // Filter by location
      if (_housingFilters.location != null && _housingFilters.location!.isNotEmpty) {
        if (listing.location == null) return false;
        if (!listing.location!.toLowerCase().contains(_housingFilters.location!.toLowerCase())) {
          return false;
        }
      }

      // Filter by distance from campus
      if (_housingFilters.distanceFromCampus != null && listing.distanceKm != null) {
        final maxDistanceKm = _getDistanceInKm(_housingFilters.distanceFromCampus!);
        if (listing.distanceKm! > maxDistanceKm) return false;
      }

      // Filter by property type (from metadata)
      if (_housingFilters.propertyType.isNotEmpty) {
        final propertyType = listing.metadata?['property_type'] as String?;
        if (propertyType == null || !_housingFilters.propertyType.contains(propertyType)) {
          return false;
        }
      }

      // Filter by amenities (from metadata)
      if (_housingFilters.amenities.isNotEmpty) {
        final listingAmenities = (listing.metadata?['amenities'] as List<dynamic>?)
            ?.cast<String>() ?? [];
        final hasAllAmenities = _housingFilters.amenities.every(
          (amenity) => listingAmenities.contains(amenity),
        );
        if (!hasAllAmenities) return false;
      }

      return true;
    }).toList();
  }

  /// Convert distance string to km.
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

  /// Apply event-specific filters.
  List<MarketplaceListing> _applyEventFilters(List<MarketplaceListing> listings) {
    if (!_eventFilters.hasActiveFilters) return listings;

    return listings.where((listing) {
      // Filter by event type
      if (_eventFilters.eventType.isNotEmpty) {
        final eventType = listing.metadata?['event_type'] as String?;
        if (eventType == null || !_eventFilters.eventType.contains(eventType)) {
          return false;
        }
      }

      // Filter by date range
      if (_eventFilters.dateFrom != null) {
        final eventDate = listing.metadata?['event_date'] != null
            ? DateTime.tryParse(listing.metadata!['event_date'] as String)
            : null;
        if (eventDate != null) {
          if (eventDate.isBefore(_eventFilters.dateFrom!)) return false;
          if (_eventFilters.dateTo != null && eventDate.isAfter(_eventFilters.dateTo!)) {
            return false;
          }
        }
      }

      // Filter by free/paid
      if (_eventFilters.isFree == true) {
        if (listing.price != null && listing.price! > 0) return false;
      } else if (_eventFilters.isFree == false) {
        if (listing.price == null || listing.price == 0) return false;
      }

      // Filter by location
      if (_eventFilters.location != null && _eventFilters.location!.isNotEmpty) {
        if (listing.location == null) return false;
        if (!listing.location!.toLowerCase().contains(_eventFilters.location!.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Apply resource-specific filters.
  List<MarketplaceListing> _applyResourceFilters(List<MarketplaceListing> listings) {
    if (!_resourceFilters.hasActiveFilters) return listings;

    return listings.where((listing) {
      // Filter by subject
      if (_resourceFilters.subject.isNotEmpty) {
        final subject = listing.metadata?['subject'] as String?;
        if (subject == null || !_resourceFilters.subject.contains(subject)) {
          return false;
        }
      }

      // Filter by resource type
      if (_resourceFilters.resourceType.isNotEmpty) {
        final resourceType = listing.metadata?['resource_type'] as String?;
        if (resourceType == null || !_resourceFilters.resourceType.contains(resourceType)) {
          return false;
        }
      }

      // Filter by difficulty
      if (_resourceFilters.difficulty != null) {
        final difficulty = listing.metadata?['difficulty'] as String?;
        if (difficulty == null || difficulty != _resourceFilters.difficulty) {
          return false;
        }
      }

      // Filter by minimum rating
      if (_resourceFilters.minRating != null) {
        final rating = (listing.metadata?['rating'] as num?)?.toDouble();
        if (rating == null || rating < _resourceFilters.minRating!) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Get filter count for a specific category
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

  /// Show housing-specific filters
  Future<void> _showHousingFilters(BuildContext context) async {
    final result = await HousingFiltersSheet.show(
      context,
      initialFilters: _housingFilters,
    );
    if (result != null) {
      setState(() {
        _housingFilters = result;
      });
    }
  }

  /// Show event-specific filters (used for opportunities)
  Future<void> _showEventFilters(BuildContext context) async {
    final result = await EventFiltersSheet.show(
      context,
      initialFilters: _eventFilters,
    );
    if (result != null) {
      setState(() {
        _eventFilters = result;
      });
    }
  }

  /// Show resource-specific filters (used for products)
  Future<void> _showResourceFilters(BuildContext context) async {
    final result = await ResourceFiltersSheet.show(
      context,
      initialFilters: _resourceFilters,
    );
    if (result != null) {
      setState(() {
        _resourceFilters = result;
      });
    }
  }

  /// Check if a category has internal filters
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

  /// Show internal filters based on selected category
  Future<void> _showInternalFilters(BuildContext context, CampusConnectCategory category) async {
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

  /// Show the unified filter sheet with all tabs
  Future<void> _showUnifiedFilterSheet(BuildContext context) async {
    final currentFilters = CampusConnectFilters(
      housing: _housingFilters,
      events: _eventFilters,
      resources: _resourceFilters,
    );

    // Determine initial tab based on selected category
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

/// Production-grade listings count display.
class _ListingsCount extends StatelessWidget {
  final int count;

  const _ListingsCount({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'posts',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          // Sort button
          GestureDetector(
            onTap: () {
              // TODO: Show sort options
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Latest',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
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

/// Production-grade floating action button.
class _FloatingActionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FloatingActionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
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
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return _buildPostCard(context, listing, index);
      },
    );
  }

  /// Build appropriate post card based on listing type.
  Widget _buildPostCard(
      BuildContext context, MarketplaceListing listing, int index) {
    switch (listing.type) {
      case ListingType.communityPost:
      case ListingType.poll:
        // Show help posts for some community posts based on certain criteria
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
          onLike: () {
            // Toggle like
          },
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
          onLike: () {
            // Toggle like
          },
        );

      case ListingType.housing:
        return HousingPostCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onContact: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening chat...'),
              ),
            );
          },
        );
    }
  }

  /// Determine if a community post should be shown as a help post.
  bool _shouldShowAsHelpPost(MarketplaceListing listing, int index) {
    final title = listing.title.toLowerCase();
    // Show as help post if title contains help-related keywords
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

/// Loading skeleton grid.
class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        // Varying heights for masonry effect
        final height = index.isEven ? 160.0 : 200.0;
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon area skeleton
              Container(
                height: index.isEven ? 80 : 100,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8E8),
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

/// Empty state widget.
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.filter_list_off : Icons.inbox_outlined,
              size: 48,
              color: const Color(0xFF9B9B9B),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasFilters ? 'No posts found' : 'No posts yet',
            style: AppTextStyles.headingSmall.copyWith(
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search'
                : 'Be the first to post!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xFF9B9B9B),
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 24),
            Material(
              color: AppColors.darkBrown,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onClearFilters,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.filter_alt_off,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Clear Filters',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Something went wrong',
            style: AppTextStyles.headingSmall.copyWith(
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF9B9B9B),
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          Material(
            color: AppColors.darkBrown,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onRetry,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

/// Internal filter chip button.
///
/// Shows a filter icon with the category-specific label and filter count badge.
/// Matches the design of CollegeFilterChip for visual consistency.
class _InternalFilterChip extends StatelessWidget {
  final CampusConnectCategory category;
  final int filterCount;
  final VoidCallback onTap;

  const _InternalFilterChip({
    required this.category,
    required this.filterCount,
    required this.onTap,
  });

  String get _filterLabel {
    switch (category) {
      case CampusConnectCategory.housing:
        return 'Housing Filters';
      case CampusConnectCategory.events:
      case CampusConnectCategory.opportunities:
        return 'Event Filters';
      case CampusConnectCategory.resources:
      case CampusConnectCategory.products:
        return 'Resource Filters';
      default:
        return 'Filters';
    }
  }

  IconData get _filterIcon {
    switch (category) {
      case CampusConnectCategory.housing:
        return Icons.home_outlined;
      case CampusConnectCategory.events:
      case CampusConnectCategory.opportunities:
        return Icons.event_outlined;
      case CampusConnectCategory.resources:
      case CampusConnectCategory.products:
        return Icons.menu_book_outlined;
      default:
        return Icons.filter_list_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = filterCount > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasActiveFilters
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasActiveFilters
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _filterIcon,
              size: 14,
              color: hasActiveFilters
                  ? AppColors.primary
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              _filterLabel,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 12,
                color: hasActiveFilters
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: hasActiveFilters ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$filterCount',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

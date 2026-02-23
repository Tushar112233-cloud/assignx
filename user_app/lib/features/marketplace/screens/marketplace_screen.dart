import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../data/models/tutor_model.dart';
import '../../../providers/marketplace_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../widgets/banner_card.dart';
import '../widgets/book_session_sheet.dart';
import '../widgets/item_card.dart';
import '../widgets/tutor_card.dart';
import '../widgets/tutor_profile_sheet.dart';

/// Main marketplace/connect screen with Pinterest-style staggered grid.
///
/// Features a curved dome hero section with mesh gradient background,
/// glass-style search bar, and filter pills following the Campus Connect design system.
class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(marketplaceListingsProvider);
    final filters = ref.watch(marketplaceFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.center,
        opacity: 0.5,
        colors: [
          AppColors.meshPink,
          AppColors.meshPeach,
          AppColors.meshOrange,
        ],
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(marketplaceListingsProvider);
          },
          child: CustomScrollView(
            slivers: [
              // Curved dome hero section
              SliverToBoxAdapter(
                child: _CurvedDomeHero(
                  onCreatePressed: () {
                    context.push('/marketplace/create');
                  },
                ),
              ),

              // Filter pills section
              SliverToBoxAdapter(
                child: _GlassFilterPills(),
              ),

              // Featured Tutors Section
              SliverToBoxAdapter(
                child: _FeaturedTutorsSection(),
              ),

              // Active filters display
              if (filters.hasFilters)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: GlassContainer(
                      blur: 10,
                      opacity: 0.6,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filtered results',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              ref
                                  .read(marketplaceFilterProvider.notifier)
                                  .clearFilters();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Clear all',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Listings grid
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: listingsAsync.when(
                  data: (listings) {
                    if (listings.isEmpty) {
                      return SliverToBoxAdapter(
                        child: _EmptyState(
                          hasFilters: filters.hasFilters,
                          onClearFilters: () {
                            ref
                                .read(marketplaceFilterProvider.notifier)
                                .clearFilters();
                          },
                        ),
                      );
                    }

                    return _StaggeredGrid(listings: listings);
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

              // Bottom padding for dock navigation
              const SliverToBoxAdapter(
                child: SizedBox(height: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Curved dome hero section with glass search bar.
///
/// Creates a modern hero section with curved bottom edge,
/// featuring the title, subtitle, and search functionality.
class _CurvedDomeHero extends StatelessWidget {
  final VoidCallback? onCreatePressed;

  const _CurvedDomeHero({this.onCreatePressed});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _CurvedBottomClipper(),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.darkBrown,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and create button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect',
                          style: AppTextStyles.headingLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discover students & services',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                    // Create button
                    GlassButton(
                      icon: Icons.add,
                      onPressed: onCreatePressed,
                      blur: 15,
                      opacity: 0.2,
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.white,
                      borderColor: Colors.white.withAlpha(77),
                      fullWidth: false,
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ],
                ),
                const Spacer(),
                // Glass search bar
                const _GlassSearchBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom clipper for curved bottom edge of hero section.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// Glass-style search bar widget.
class _GlassSearchBar extends ConsumerStatefulWidget {
  const _GlassSearchBar();

  @override
  ConsumerState<_GlassSearchBar> createState() => _GlassSearchBarState();
}

class _GlassSearchBarState extends ConsumerState<_GlassSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(_isFocused ? 51 : 38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(_isFocused ? 77 : 51),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.white.withAlpha(200),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search items, tutors, events...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withAlpha(153),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    ref
                        .read(marketplaceFilterProvider.notifier)
                        .setSearchQuery(value.isEmpty ? null : value);
                    setState(() {});
                  },
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref
                        .read(marketplaceFilterProvider.notifier)
                        .setSearchQuery(null);
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withAlpha(200),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Glass-style filter pills with horizontal scroll.
class _GlassFilterPills extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(marketplaceFilterProvider);

    return Column(
      children: [
        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              // All filter pill
              _GlassFilterPill(
                label: 'All',
                icon: Icons.apps_rounded,
                isSelected: filters.category == null,
                onTap: () {
                  ref.read(marketplaceFilterProvider.notifier).setCategory(null);
                },
              ),
              const SizedBox(width: 8),
              // Category pills
              ...MarketplaceCategory.values.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _GlassFilterPill(
                    label: category.label,
                    icon: category.icon,
                    isSelected: filters.category == category,
                    onTap: () {
                      ref
                          .read(marketplaceFilterProvider.notifier)
                          .setCategory(category);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // City and sort filters row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // City dropdown
              Expanded(
                child: _GlassCityDropdown(
                  selectedCity: filters.city,
                  onChanged: (city) {
                    ref.read(marketplaceFilterProvider.notifier).setCity(city);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Sort button
              _GlassSortButton(
                onTap: () => _showSortOptions(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _GlassSortOptionsSheet(),
    );
  }
}

/// Individual glass filter pill widget.
class _GlassFilterPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassFilterPill({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : Colors.white.withAlpha(179),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withAlpha(128),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass-style city dropdown widget.
class _GlassCityDropdown extends StatelessWidget {
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  const _GlassCityDropdown({
    required this.selectedCity,
    required this.onChanged,
  });

  static const _cities = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.7,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      borderColor: AppColors.border.withAlpha(77),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedCity,
          hint: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select City',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.public,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Cities',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ..._cities.map(
              (city) => DropdownMenuItem(
                value: city,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      city,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Glass-style sort button widget.
class _GlassSortButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GlassSortButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      blur: 10,
      opacity: 0.7,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.all(12),
      borderColor: AppColors.border.withAlpha(77),
      onTap: onTap,
      child: Icon(
        Icons.tune_rounded,
        size: 20,
        color: AppColors.textSecondary,
      ),
    );
  }
}

/// Glass-style sort options bottom sheet.
class _GlassSortOptionsSheet extends StatelessWidget {
  const _GlassSortOptionsSheet();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(242),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withAlpha(51),
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
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
                  const SizedBox(height: 20),

                  // Title
                  Text(
                    'Sort & Filter',
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 20),

                  // Sort options
                  _GlassSortOption(
                    icon: Icons.access_time_rounded,
                    label: 'Most Recent',
                    isSelected: true,
                    onTap: () => Navigator.pop(context),
                  ),
                  _GlassSortOption(
                    icon: Icons.trending_up_rounded,
                    label: 'Most Popular',
                    isSelected: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  _GlassSortOption(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Price: Low to High',
                    isSelected: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  _GlassSortOption(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Price: High to Low',
                    isSelected: false,
                    onTap: () => Navigator.pop(context),
                  ),
                  _GlassSortOption(
                    icon: Icons.near_me_rounded,
                    label: 'Nearest First',
                    isSelected: false,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass-style sort option item.
class _GlassSortOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GlassSortOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withAlpha(51),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withAlpha(26)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Pinterest-style staggered grid of listings.
class _StaggeredGrid extends StatelessWidget {
  final List<MarketplaceListing> listings;

  const _StaggeredGrid({required this.listings});

  @override
  Widget build(BuildContext context) {
    return SliverMasonryGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        return _buildListingCard(context, listing);
      },
    );
  }

  Widget _buildListingCard(BuildContext context, MarketplaceListing listing) {
    // Determine card type based on listing type
    switch (listing.type) {
      case ListingType.product:
      case ListingType.housing:
        return ItemCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onLike: () {
            // Toggle like
          },
        );

      case ListingType.communityPost:
      case ListingType.poll:
        return _GlassTextCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onLike: () {
            // Toggle like
          },
          onComment: () => _navigateToDetail(context, listing),
        );

      case ListingType.event:
      case ListingType.opportunity:
        // Banner cards span full width
        return BannerCard(
          listing: listing,
          onTap: () => _navigateToDetail(context, listing),
          onApply: () {
            // Handle apply/register
          },
        );
    }
  }

  void _navigateToDetail(BuildContext context, MarketplaceListing listing) {
    context.push('/marketplace/${listing.id}');
  }
}

/// Glass-style text card for community posts.
class _GlassTextCard extends StatelessWidget {
  final MarketplaceListing listing;
  final VoidCallback? onTap;
  final VoidCallback? onLike;
  final VoidCallback? onComment;

  const _GlassTextCard({
    required this.listing,
    this.onTap,
    this.onLike,
    this.onComment,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      blur: 12,
      opacity: 0.8,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  listing.userName.isNotEmpty
                      ? listing.userName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.userName,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      listing.timeAgo,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
          Text(
            listing.title,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Action row
          Row(
            children: [
              _ActionButton(
                icon: listing.isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${listing.likeCount}',
                isActive: listing.isLiked,
                onTap: onLike,
              ),
              const SizedBox(width: 16),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: '${listing.commentCount}',
                onTap: onComment,
              ),
              const Spacer(),
              Icon(
                Icons.share_outlined,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action button for text cards.
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? AppColors.error : AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading skeleton grid with shimmer effect.
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
        return GlassCard(
          blur: 8,
          opacity: 0.6,
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              SkeletonLoader(
                height: index.isEven ? 120 : 160,
                borderRadius: 0,
              ),
              // Content skeleton
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoader(height: 14, width: 100),
                    SizedBox(height: 8),
                    SkeletonLoader(height: 12, width: 70),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 10, width: 50),
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

/// Empty state widget with glass styling.
class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 15,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilters ? Icons.filter_list_off : Icons.inbox_outlined,
              size: 48,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            hasFilters ? 'No results found' : 'No listings yet',
            style: AppTextStyles.headingSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try adjusting your filters or search query'
                : 'Be the first to post something!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasFilters) ...[
            const SizedBox(height: 24),
            GlassButton(
              label: 'Clear Filters',
              icon: Icons.filter_alt_off,
              onPressed: onClearFilters,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              fullWidth: false,
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state widget with glass styling.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 15,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.errorLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),
          GlassButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            fullWidth: false,
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
        ],
      ),
    );
  }
}

/// Category header for separated sections.
class CategoryHeader extends StatelessWidget {
  final MarketplaceCategory category;
  final VoidCallback? onSeeAll;

  const CategoryHeader({
    super.key,
    required this.category,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              category.icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: AppTextStyles.labelLarge,
                ),
                Text(
                  category.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
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
}

/// Featured tutors section widget with glass cards.
class _FeaturedTutorsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorsAsync = ref.watch(featuredTutorsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withAlpha(26),
                          AppColors.primaryLight.withAlpha(26),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expert Tutors',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Book 1-on-1 sessions',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GlassContainer(
                blur: 8,
                opacity: 0.6,
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                onTap: () {
                  // Navigate to all tutors screen
                },
                child: Row(
                  children: [
                    Text(
                      'See all',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tutors horizontal list
        SizedBox(
          height: 180,
          child: tutorsAsync.when(
            data: (tutors) {
              if (tutors.isEmpty) {
                return Center(
                  child: Text(
                    'No tutors available',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tutors.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final tutor = tutors[index];
                  return SizedBox(
                    width: 200,
                    child: TutorCard(
                      tutor: tutor,
                      onTap: () => _showTutorProfile(context, tutor),
                      onBook: () => _showBookSession(context, tutor),
                    ),
                  );
                },
              );
            },
            loading: () => ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _TutorCardSkeleton(),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Failed to load tutors',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }

  /// Show tutor profile sheet.
  void _showTutorProfile(BuildContext context, Tutor tutor) {
    TutorProfileSheet.show(
      context: context,
      tutor: tutor,
      onBookSession: () {
        Navigator.of(context).pop();
        _showBookSession(context, tutor);
      },
      onAskQuestion: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ask question feature coming soon!'),
          ),
        );
      },
    );
  }

  /// Show book session sheet.
  void _showBookSession(BuildContext context, Tutor tutor) {
    BookSessionSheet.show(
      context: context,
      tutor: tutor,
      onBookingComplete: (session) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Session booked with ${tutor.name}!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }
}

/// Loading skeleton for tutor card with glass effect.
class _TutorCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      width: 200,
      blur: 12,
      opacity: 0.7,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and info row skeleton
          Row(
            children: [
              const SkeletonLoader.circle(size: 56),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SkeletonLoader(height: 14, width: 80),
                    SizedBox(height: 6),
                    SkeletonLoader(height: 10, width: 60),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Subject tags skeleton
          const SkeletonLoader(height: 22, width: 120),
          const SizedBox(height: 10),
          // Bottom row skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              SkeletonLoader(height: 16, width: 60),
              SkeletonLoader(height: 32, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

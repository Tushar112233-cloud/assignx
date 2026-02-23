import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/expert_model.dart';
import '../../../providers/experts_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../home/widgets/home_app_bar.dart';
import '../widgets/expert_card.dart';

/// Tab types for the experts screen - matching web design
enum ExpertsTabType { doctors, allExperts, bookings }

/// Main experts/consultations screen.
///
/// Features a hero section with search, main tabs (Doctors/All Experts/Bookings),
/// featured doctors carousel, and a list of available experts.
class ExpertsScreen extends ConsumerStatefulWidget {
  const ExpertsScreen({super.key});

  @override
  ConsumerState<ExpertsScreen> createState() => _ExpertsScreenState();
}

class _ExpertsScreenState extends ConsumerState<ExpertsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ExpertSpecialization? _selectedSpecialization;
  ExpertsTabType _activeTab = ExpertsTabType.doctors;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expertsAsync = ref.watch(expertsProvider);
    final featuredAsync = ref.watch(featuredExpertsProvider);

    return Scaffold(
      // Transparent to show SubtleGradientScaffold from MainShell
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(expertsProvider);
          ref.invalidate(featuredExpertsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Unified Dashboard App Bar (dark theme) - matches other pages
            const SliverToBoxAdapter(
              child: HomeAppBar(),
            ),

            // Hero section
            SliverToBoxAdapter(
              child: _ExpertsHero(
                onSearch: (query) {
                  ref.read(expertFilterProvider.notifier).setSearchQuery(query);
                },
                searchController: _searchController,
              ),
            ),

            // Main tabs - Doctors / All Experts / My Bookings (matching web)
            SliverToBoxAdapter(
              child: _MainTabs(
                activeTab: _activeTab,
                onTabChanged: (tab) => setState(() => _activeTab = tab),
              ),
            ),

            // Content based on active tab
            if (_activeTab == ExpertsTabType.doctors) ...[
              // Featured Doctors Carousel
              SliverToBoxAdapter(
                child: featuredAsync.when(
                  data: (featured) {
                    if (featured.isEmpty) return const SizedBox.shrink();
                    return _FeaturedDoctorsCarousel(
                      doctors: featured,
                      onDoctorTap: _navigateToDetail,
                      onBookTap: _navigateToBooking,
                    );
                  },
                  loading: () => const _CarouselSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              // Filter tabs for doctors
              SliverToBoxAdapter(
                child: _FilterTabs(
                  selectedSpecialization: _selectedSpecialization,
                  onSpecializationChanged: (spec) {
                    setState(() => _selectedSpecialization = spec);
                    ref.read(expertFilterProvider.notifier).setSpecialization(spec);
                  },
                ),
              ),

              // Doctors count
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: expertsAsync.when(
                    data: (experts) => Text(
                      '${experts.length} doctor${experts.length != 1 ? 's' : ''} available',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // Doctors list
              _buildExpertsList(expertsAsync),
            ] else if (_activeTab == ExpertsTabType.allExperts) ...[
              // Filter tabs for all experts
              SliverToBoxAdapter(
                child: _FilterTabs(
                  selectedSpecialization: _selectedSpecialization,
                  onSpecializationChanged: (spec) {
                    setState(() => _selectedSpecialization = spec);
                    ref.read(expertFilterProvider.notifier).setSpecialization(spec);
                  },
                ),
              ),

              // All experts header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: expertsAsync.when(
                    data: (experts) => Text(
                      '${experts.length} expert${experts.length != 1 ? 's' : ''} available',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ),
              ),

              // All experts list
              _buildExpertsList(expertsAsync),
            ] else ...[
              // My Bookings tab
              const SliverToBoxAdapter(
                child: _MyBookingsSection(),
              ),
            ],

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
    );
  }

  /// Build experts list sliver
  Widget _buildExpertsList(AsyncValue<List<Expert>> expertsAsync) {
    return expertsAsync.when(
      data: (experts) {
        if (experts.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyState(
              hasFilters: _selectedSpecialization != null ||
                  _searchController.text.isNotEmpty,
              onClearFilters: () {
                setState(() {
                  _selectedSpecialization = null;
                  _searchController.clear();
                });
                ref.read(expertFilterProvider.notifier).clearFilters();
              },
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList.separated(
            itemCount: experts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final expert = experts[index];
              return ExpertCard(
                expert: expert,
                variant: ExpertCardVariant.defaultCard,
                onTap: () => _navigateToDetail(expert),
                onBook: () => _navigateToBooking(expert),
              );
            },
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: 4,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (_, __) => const _ExpertCardSkeleton(),
        ),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: _ErrorState(
          error: error.toString(),
          onRetry: () => ref.invalidate(expertsProvider),
        ),
      ),
    );
  }

  void _navigateToDetail(Expert expert) {
    context.push('/experts/${expert.id}');
  }

  void _navigateToBooking(Expert expert) {
    context.push('/experts/${expert.id}/book');
  }
}

/// Dashboard-inspired hero section for Expert Consultations.
///
/// Clean, minimal design with title, subtitle, Lottie animation,
/// and flat search bar matching the dashboard greeting section style.
class _ExpertsHero extends StatefulWidget {
  final ValueChanged<String> onSearch;
  final TextEditingController searchController;

  const _ExpertsHero({
    required this.onSearch,
    required this.searchController,
  });

  @override
  State<_ExpertsHero> createState() => _ExpertsHeroState();
}

class _ExpertsHeroState extends State<_ExpertsHero> {
  bool _isFocused = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with Lottie
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main title
                    Text(
                      'Expert Consultations',
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Subtitle
                    Text(
                      'Get guidance from verified professionals',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Right: Lottie animation
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                height: 70,
                child: Lottie.asset(
                  'assets/animations/computer.json',
                  fit: BoxFit.contain,
                  repeat: true,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        LucideIcons.stethoscope,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Quick stats row - capsule pills like QuickStatsRow
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatPill(
                icon: LucideIcons.users,
                label: 'Verified',
                value: '500+',
                highlight: true,
              ),
              _StatPill(
                icon: LucideIcons.star,
                label: 'Rating',
                value: '4.9',
                highlight: false,
              ),
              _StatPill(
                icon: LucideIcons.zap,
                label: 'Sessions',
                value: '10K+',
                highlight: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Flat search bar (no capsule)
          Container(
            decoration: BoxDecoration(
              color: _isFocused ? Colors.white : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Search icon
                Padding(
                  padding: const EdgeInsets.only(left: 14),
                  child: Icon(
                    LucideIcons.search,
                    size: 18,
                    color: _isFocused
                        ? AppColors.primary
                        : AppColors.textTertiary,
                  ),
                ),

                // Text input
                Expanded(
                  child: TextField(
                    controller: widget.searchController,
                    focusNode: _focusNode,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search experts, specializations...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      widget.onSearch(value);
                      setState(() {});
                    },
                  ),
                ),

                // Clear button
                if (widget.searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      widget.searchController.clear();
                      widget.onSearch('');
                      setState(() {});
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          LucideIcons.x,
                          size: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Stat pill component matching QuickStatsRow style.
class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = highlight
        ? AppColors.primary.withValues(alpha: 0.08)
        : AppColors.surfaceLight;
    final iconColor = highlight ? AppColors.primary : AppColors.textTertiary;
    final valueColor = highlight ? AppColors.primary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.2)
              : AppColors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Main tabs - Doctors / All Experts / My Bookings (matching web design)
class _MainTabs extends StatelessWidget {
  final ExpertsTabType activeTab;
  final ValueChanged<ExpertsTabType> onTabChanged;

  const _MainTabs({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (type: ExpertsTabType.doctors, icon: LucideIcons.stethoscope, label: 'Doctors'),
      (type: ExpertsTabType.allExperts, icon: LucideIcons.graduationCap, label: 'All Experts'),
      (type: ExpertsTabType.bookings, icon: LucideIcons.calendarCheck, label: 'My Bookings'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: tabs.map((tab) {
            final isSelected = activeTab == tab.type;
            return Expanded(
              child: GestureDetector(
                onTap: () => onTabChanged(tab.type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab.icon,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          tab.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Featured doctors carousel with auto-slide and large doctor cards
class _FeaturedDoctorsCarousel extends StatefulWidget {
  final List<Expert> doctors;
  final void Function(Expert) onDoctorTap;
  final void Function(Expert) onBookTap;

  const _FeaturedDoctorsCarousel({
    required this.doctors,
    required this.onDoctorTap,
    required this.onBookTap,
  });

  @override
  State<_FeaturedDoctorsCarousel> createState() => _FeaturedDoctorsCarouselState();
}

class _FeaturedDoctorsCarouselState extends State<_FeaturedDoctorsCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoSlide();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (widget.doctors.isEmpty) return;
      final nextIndex = (_currentIndex + 1) % widget.doctors.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _pauseAutoSlide() {
    _autoSlideTimer?.cancel();
  }

  void _resumeAutoSlide() {
    _autoSlideTimer?.cancel();
    _startAutoSlide();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doctors.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  LucideIcons.sparkles,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Doctors',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Top-rated medical professionals',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Carousel
        GestureDetector(
          onPanDown: (_) => _pauseAutoSlide(),
          onPanEnd: (_) => _resumeAutoSlide(),
          onPanCancel: () => _resumeAutoSlide(),
          child: SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.doctors.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final doctor = widget.doctors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: _FeaturedDoctorCard(
                    doctor: doctor,
                    onTap: () => widget.onDoctorTap(doctor),
                    onBook: () => widget.onBookTap(doctor),
                  ),
                );
              },
            ),
          ),
        ),

        // Progress dots
        if (widget.doctors.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.doctors.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Featured doctor card - large, prominent, glassmorphic
class _FeaturedDoctorCard extends StatelessWidget {
  final Expert doctor;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const _FeaturedDoctorCard({
    required this.doctor,
    required this.onTap,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFEF7E0).withValues(alpha: 0.9),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE5D9B6).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large avatar - doctor as main focus
                Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryLight.withAlpha(50),
                        backgroundImage: doctor.avatar != null
                            ? NetworkImage(doctor.avatar!)
                            : null,
                        child: doctor.avatar == null
                            ? Text(
                                doctor.initials,
                                style: AppTextStyles.headingMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                    ),
                    // Availability indicator
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getAvailabilityColor(),
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.award, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              'Featured',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Name
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              doctor.name,
                              style: AppTextStyles.headingMedium.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (doctor.verified) ...[
                            const SizedBox(width: 6),
                            Icon(LucideIcons.badgeCheck, size: 18, color: AppColors.success),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Designation
                      Text(
                        doctor.designation,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),

                      // Rating and sessions
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.warning.withAlpha(50)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Text(
                                  doctor.ratingString,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  ' (${doctor.reviewCount})',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(LucideIcons.users, size: 14, color: AppColors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.totalSessions}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Price and book row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.priceString,
                      style: AppTextStyles.headingMedium.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'per session',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                Material(
                  color: AppColors.darkBrown,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onBook,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      child: Text(
                        'Book Consultation',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvailabilityColor() {
    switch (doctor.availability) {
      case ExpertAvailability.available:
        return AppColors.success;
      case ExpertAvailability.busy:
        return AppColors.warning;
      case ExpertAvailability.offline:
        return AppColors.neutralGray;
    }
  }
}

/// Carousel skeleton loader
class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SkeletonLoader(height: 20, width: 180),
        ),
        SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: SkeletonLoader(height: 200, width: double.infinity),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Booking tab types
enum _BookingTabType { upcoming, completed, cancelled }

/// My Bookings section with sub-tabs (Upcoming / Completed / Cancelled)
class _MyBookingsSection extends StatefulWidget {
  const _MyBookingsSection();

  @override
  State<_MyBookingsSection> createState() => _MyBookingsSectionState();
}

class _MyBookingsSectionState extends State<_MyBookingsSection> {
  _BookingTabType _activeTab = _BookingTabType.upcoming;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Sub-tabs - glassmorphic container
          _BookingSubTabs(
            activeTab: _activeTab,
            onTabChanged: (tab) => setState(() => _activeTab = tab),
          ),
          const SizedBox(height: 20),
          // Content based on tab
          _BookingTabContent(activeTab: _activeTab),
        ],
      ),
    );
  }
}

/// Sub-tabs for bookings (Upcoming / Completed / Cancelled)
class _BookingSubTabs extends StatelessWidget {
  final _BookingTabType activeTab;
  final ValueChanged<_BookingTabType> onTabChanged;

  const _BookingSubTabs({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (type: _BookingTabType.upcoming, icon: LucideIcons.calendarClock, label: 'Upcoming'),
      (type: _BookingTabType.completed, icon: LucideIcons.checkCircle2, label: 'Completed'),
      (type: _BookingTabType.cancelled, icon: LucideIcons.xCircle, label: 'Cancelled'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = activeTab == tab.type;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(tab.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        tab.label,
                        style: AppTextStyles.labelSmall.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Content for each booking tab
class _BookingTabContent extends StatelessWidget {
  final _BookingTabType activeTab;

  const _BookingTabContent({required this.activeTab});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to actual bookings provider
    // For now, show empty state
    return _BookingEmptyState(tabType: activeTab);
  }
}

/// Empty state for booking tabs
class _BookingEmptyState extends StatelessWidget {
  final _BookingTabType tabType;

  const _BookingEmptyState({required this.tabType});

  IconData get _icon {
    switch (tabType) {
      case _BookingTabType.upcoming:
        return LucideIcons.calendarClock;
      case _BookingTabType.completed:
        return LucideIcons.checkCircle2;
      case _BookingTabType.cancelled:
        return LucideIcons.xCircle;
    }
  }

  String get _title {
    switch (tabType) {
      case _BookingTabType.upcoming:
        return 'No upcoming bookings';
      case _BookingTabType.completed:
        return 'No completed sessions';
      case _BookingTabType.cancelled:
        return 'No cancelled bookings';
    }
  }

  String get _description {
    switch (tabType) {
      case _BookingTabType.upcoming:
        return 'Book a consultation with a doctor to get started';
      case _BookingTabType.completed:
        return 'Your completed consultations will appear here';
      case _BookingTabType.cancelled:
        return 'Any cancelled sessions will appear here';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 12,
      opacity: 0.7,
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              _icon,
              size: 28,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _title,
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Capsule-style filter tabs for specializations matching Campus Connect.
class _FilterTabs extends StatelessWidget {
  final ExpertSpecialization? selectedSpecialization;
  final ValueChanged<ExpertSpecialization?> onSpecializationChanged;

  const _FilterTabs({
    required this.selectedSpecialization,
    required this.onSpecializationChanged,
  });

  static const _displaySpecializations = [
    null, // All
    ExpertSpecialization.academicWriting,
    ExpertSpecialization.researchMethodology,
    ExpertSpecialization.dataAnalysis,
    ExpertSpecialization.programming,
    ExpertSpecialization.business,
    ExpertSpecialization.careerCounseling,
  ];

  IconData _getIcon(ExpertSpecialization? spec) {
    if (spec == null) return LucideIcons.layoutGrid;
    switch (spec) {
      case ExpertSpecialization.academicWriting:
        return LucideIcons.penTool;
      case ExpertSpecialization.researchMethodology:
        return LucideIcons.microscope;
      case ExpertSpecialization.dataAnalysis:
        return LucideIcons.barChart3;
      case ExpertSpecialization.programming:
        return LucideIcons.code2;
      case ExpertSpecialization.business:
        return LucideIcons.briefcase;
      case ExpertSpecialization.careerCounseling:
        return LucideIcons.compass;
      default:
        return LucideIcons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _displaySpecializations.asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          final isSelected = selectedSpecialization == spec;
          final label = spec?.label ?? 'All';

          final bgColor = isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceLight;
          final borderColor = isSelected
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border.withValues(alpha: 0.5);
          final textColor = isSelected ? AppColors.primary : AppColors.textSecondary;
          final iconColor = isSelected ? AppColors.primary : AppColors.textTertiary;

          return Padding(
            padding: EdgeInsets.only(
              right: index < _displaySpecializations.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onSpecializationChanged(
                selectedSpecialization == spec ? null : spec,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20), // Capsule shape
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIcon(spec),
                      size: 14,
                      color: iconColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Featured experts section.
class _FeaturedSection extends StatelessWidget {
  final List<Expert> experts;

  const _FeaturedSection({required this.experts});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.award,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Featured Experts',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  // See all featured
                },
                child: Text(
                  'See all',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: experts.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final expert = experts[index];
              return SizedBox(
                width: 260,
                child: ExpertCard(
                  expert: expert,
                  variant: ExpertCardVariant.compact,
                  onTap: () => context.push('/experts/${expert.id}'),
                  onBook: () => context.push('/experts/${expert.id}/book'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Featured section skeleton.
class _FeaturedSectionSkeleton extends StatelessWidget {
  const _FeaturedSectionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: SkeletonLoader(height: 20, width: 150),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 3,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (_, __) => const SizedBox(
              width: 260,
              child: _ExpertCardSkeleton(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Expert card skeleton.
class _ExpertCardSkeleton extends StatelessWidget {
  const _ExpertCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      blur: 10,
      opacity: 0.6,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: const Row(
        children: [
          SkeletonLoader.circle(size: 56),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonLoader(height: 16, width: 120),
                SizedBox(height: 6),
                SkeletonLoader(height: 12, width: 80),
                SizedBox(height: 10),
                SkeletonLoader(height: 10, width: 100),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonLoader(height: 18, width: 60),
              SizedBox(height: 8),
              SkeletonLoader(height: 32, width: 60),
            ],
          ),
        ],
      ),
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        blur: 15,
        opacity: 0.8,
        padding: const EdgeInsets.all(32),
        borderRadius: BorderRadius.circular(20),
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
                hasFilters ? LucideIcons.filterX : LucideIcons.graduationCap,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilters ? 'No experts found' : 'No experts available',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query'
                  : 'Check back later for available experts',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
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
                        Icon(
                          LucideIcons.filterX,
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GlassCard(
        blur: 15,
        opacity: 0.8,
        padding: const EdgeInsets.all(32),
        borderRadius: BorderRadius.circular(20),
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
                LucideIcons.alertCircle,
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
                      Icon(
                        LucideIcons.refreshCw,
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
      ),
    );
  }
}

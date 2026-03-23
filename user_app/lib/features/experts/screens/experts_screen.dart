import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/expert_model.dart';
import '../../../providers/experts_provider.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/widgets/capsule_tab_bar.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../home/widgets/home_app_bar.dart';
import '../widgets/expert_card.dart';

// ─── Pop-of-color gradient for icon containers only (teal) ───
// The page's unique accent — used ONLY in icon backgrounds, like wallet does.
const _kTeal1 = Color(0xFF0D9488);
const _kTeal2 = Color(0xFF14B8A6);

/// Tab types for the experts screen.
enum ExpertsTabType { doctors, allExperts, bookings }

/// Experts/consultations screen.
///
/// Coffee brown base theme. Teal pops appear only inside icon gradient
/// containers — following the same pattern as the wallet page.
class ExpertsScreen extends ConsumerStatefulWidget {
  const ExpertsScreen({super.key});

  @override
  ConsumerState<ExpertsScreen> createState() => _ExpertsScreenState();
}

class _ExpertsScreenState extends ConsumerState<ExpertsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  ExpertSpecialization? _selectedSpecialization;
  ExpertsTabType _activeTab = ExpertsTabType.doctors;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expertsAsync = ref.watch(expertsProvider);
    final featuredAsync = ref.watch(featuredExpertsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(expertsProvider);
            ref.invalidate(featuredExpertsProvider);
          },
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
                // ── App bar ──
                SliverToBoxAdapter(
                  child: const HomeAppBar()
                      .fadeInSlideDown(duration: const Duration(milliseconds: 400)),
                ),

                // ── Greeting header ──
                SliverToBoxAdapter(
                  child: _TopBanner()
                      .fadeInSlideUp(delay: const Duration(milliseconds: 50)),
                ),

                // ── Search bar ──
                SliverToBoxAdapter(
                  child: _FloatingSearchBar(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: (q) {
                      ref.read(expertFilterProvider.notifier).setSearchQuery(q);
                      setState(() {});
                    },
                    onClear: () {
                      _searchController.clear();
                      ref.read(expertFilterProvider.notifier).setSearchQuery('');
                      setState(() {});
                    },
                  ).fadeInSlideUp(delay: const Duration(milliseconds: 100)),
                ),

                // ── Main tabs ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    child: CapsuleTabBar(
                      tabs: [
                        'Doctors'.tr(context),
                        'All Experts'.tr(context),
                        'My Bookings'.tr(context),
                      ],
                      selectedIndex: ExpertsTabType.values.indexOf(_activeTab),
                      onTabChanged: (i) =>
                          setState(() => _activeTab = ExpertsTabType.values[i]),
                    ),
                  ).fadeInSlideUp(delay: const Duration(milliseconds: 200)),
                ),

                // ── Tab content ──
                if (_activeTab == ExpertsTabType.doctors) ...[
                  // Featured doctors
                  SliverToBoxAdapter(
                    child: featuredAsync.when(
                      data: (featured) {
                        if (featured.isEmpty) return const SizedBox.shrink();
                        return _FeaturedRow(
                          doctors: featured,
                          onDoctorTap: _navigateToDetail,
                          onBookTap: _navigateToBooking,
                        );
                      },
                      loading: () => const _FeaturedRowSkeleton(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(
                    child: _FilterChips(
                      selected: _selectedSpecialization,
                      onChanged: (spec) {
                        setState(() => _selectedSpecialization = spec);
                        ref.read(expertFilterProvider.notifier).setSpecialization(spec);
                      },
                    ),
                  ),

                  // Count
                  SliverToBoxAdapter(
                    child: _CountLabel(
                      expertsAsync: expertsAsync,
                      noun: 'doctor',
                    ),
                  ),

                  // List
                  _buildExpertsList(expertsAsync),
                ] else if (_activeTab == ExpertsTabType.allExperts) ...[
                  // Filter chips
                  SliverToBoxAdapter(
                    child: _FilterChips(
                      selected: _selectedSpecialization,
                      onChanged: (spec) {
                        setState(() => _selectedSpecialization = spec);
                        ref.read(expertFilterProvider.notifier).setSpecialization(spec);
                      },
                    ),
                  ),

                  // Count
                  SliverToBoxAdapter(
                    child: _CountLabel(
                      expertsAsync: expertsAsync,
                      noun: 'expert',
                    ),
                  ),

                  // List
                  _buildExpertsList(expertsAsync),
                ] else ...[
                  // Bookings
                  const SliverToBoxAdapter(child: _MyBookingsSection()),
                ],

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ),
    );
  }

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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final expert = experts[index];
              return ExpertCard(
                expert: expert,
                variant: ExpertCardVariant.defaultCard,
                onTap: () => _navigateToDetail(expert),
                onBook: () => _navigateToBooking(expert),
              ).fadeInSlideUp(
                delay: Duration(milliseconds: 50 * index),
                duration: const Duration(milliseconds: 350),
              );
            },
          ),
        );
      },
      loading: () => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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

// ═══════════════════════════════════════════════════════════════════════════
// TOP BANNER — dark brown card with decorative accents
// ═══════════════════════════════════════════════════════════════════════════

class _TopBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.darkBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative — thin arc top-right
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 1.5,
                ),
              ),
            ),
          ),
          // Decorative — small filled circle bottom-right
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Decorative — tiny dot top-left area
          Positioned(
            top: 8,
            right: 60,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),

          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Availability pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Experts Online'.tr(context),
                  style: AppTextStyles.labelSmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'Expert Consultations'.tr(context),
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),

              // Subtitle
              Text(
                'Get guidance from verified professionals'.tr(context),
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(height: 16),

              // Stats pills — glass morphed with colorful icons
              Row(
                children: [
                  _BannerStatPill(
                    icon: LucideIcons.shieldCheck,
                    iconColors: [_kTeal1, _kTeal2],
                    value: '500+',
                    label: 'Verified'.tr(context),
                  ),
                  const SizedBox(width: 8),
                  _BannerStatPill(
                    icon: LucideIcons.star,
                    iconColors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                    value: '4.9',
                    label: 'Rating'.tr(context),
                  ),
                  const SizedBox(width: 8),
                  _BannerStatPill(
                    icon: LucideIcons.zap,
                    iconColors: [const Color(0xFF3B82F6), const Color(0xFF6366F1)],
                    value: '10K+',
                    label: 'Sessions'.tr(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH BAR — flat design, surfaceVariant fill, border outline
// ═══════════════════════════════════════════════════════════════════════════

class _FloatingSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _FloatingSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 14),
              child: Icon(
                LucideIcons.search,
                size: 18,
                color: AppColors.textTertiary,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search experts...'.tr(context),
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 13,
                  ),
                  isDense: true,
                ),
                onChanged: onChanged,
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    LucideIcons.x,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BANNER STAT PILL — glass morphed pill for dark banner background
// ═══════════════════════════════════════════════════════════════════════════

class _BannerStatPill extends StatelessWidget {
  final IconData icon;
  final List<Color> iconColors;
  final String value;
  final String label;

  const _BannerStatPill({
    required this.icon,
    required this.iconColors,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            // Colorful gradient icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: iconColors),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: iconColors.first.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 10, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ANIMATED CAPSULE TABS — flat design with sliding indicator
// ═══════════════════════════════════════════════════════════════════════════

// _PillTabs replaced by CapsuleTabBar (used inline above)

// ═══════════════════════════════════════════════════════════════════════════
// FEATURED DOCTORS ROW
// ═══════════════════════════════════════════════════════════════════════════

class _FeaturedRow extends StatefulWidget {
  final List<Expert> doctors;
  final void Function(Expert) onDoctorTap;
  final void Function(Expert) onBookTap;

  const _FeaturedRow({
    required this.doctors,
    required this.onDoctorTap,
    required this.onBookTap,
  });

  @override
  State<_FeaturedRow> createState() => _FeaturedRowState();
}

class _FeaturedRowState extends State<_FeaturedRow> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
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
      final next = (_currentIndex + 1) % widget.doctors.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _pauseAutoSlide() => _autoSlideTimer?.cancel();

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
        // Section title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: Row(
            children: [
              // Teal accent icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_kTeal1, _kTeal2],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: _kTeal1.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(LucideIcons.sparkles, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                'Featured Doctors'.tr(context),
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1}/${widget.doctors.length}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 11,
                ),
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
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.doctors.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (context, index) {
                final doctor = widget.doctors[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
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

        // Dots — brown palette
        if (widget.doctors.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.doctors.length, (i) {
                final isActive = i == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _kTeal1
                        : AppColors.border.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

/// Featured doctor card — warm white card with subtle brown tint.
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
    return GlassCard(
      onTap: onTap,
      blur: 15,
      opacity: 0.8,
      elevation: 3,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      borderColor: _kTeal1.withValues(alpha: 0.12),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.95),
          Color.lerp(Colors.white, _kTeal1, 0.04)!,
          Colors.white.withValues(alpha: 0.9),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with teal ring accent
              Stack(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: _kTeal1.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: _kTeal1.withAlpha(25),
                      backgroundImage: isValidImageUrl(doctor.avatar)
                          ? NetworkImage(doctor.avatar!)
                          : null,
                      child: !isValidImageUrl(doctor.avatar)
                          ? Text(
                              doctor.initials,
                              style: AppTextStyles.headingMedium.copyWith(
                                color: _kTeal1,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _availabilityColor,
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured badge -- teal gradient
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_kTeal1, _kTeal2],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _kTeal1.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.award, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            'Featured'.tr(context),
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Name
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            doctor.name,
                            style: AppTextStyles.headingSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (doctor.verified) ...[
                          const SizedBox(width: 4),
                          const Icon(LucideIcons.badgeCheck, size: 16, color: _kTeal1),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Designation
                    Text(
                      doctor.designation,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(LucideIcons.star, size: 12, color: AppColors.warning),
                              const SizedBox(width: 3),
                              Text(
                                doctor.ratingString,
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                ' (${doctor.reviewCount})',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.users, size: 12, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text(
                          '${doctor.totalSessions}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),

          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  _kTeal1.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Price + book row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.priceString,
                    style: AppTextStyles.headingSmall.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'per session'.tr(context),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              // Book button -- teal gradient
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onBook,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kTeal1, _kTeal2],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _kTeal1.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.calendar, size: 13, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Book Now'.tr(context),
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
        ],
      ),
    );
  }

  Color get _availabilityColor {
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

// ═══════════════════════════════════════════════════════════════════════════
// FILTER CHIPS — coffee brown selected state
// ═══════════════════════════════════════════════════════════════════════════

class _FilterChips extends StatelessWidget {
  final ExpertSpecialization? selected;
  final ValueChanged<ExpertSpecialization?> onChanged;

  const _FilterChips({
    required this.selected,
    required this.onChanged,
  });

  static const _specs = [
    null,
    ExpertSpecialization.academicWriting,
    ExpertSpecialization.researchMethodology,
    ExpertSpecialization.dataAnalysis,
    ExpertSpecialization.programming,
    ExpertSpecialization.business,
    ExpertSpecialization.careerCounseling,
  ];

  IconData _icon(ExpertSpecialization? s) {
    if (s == null) return LucideIcons.layoutGrid;
    switch (s) {
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _specs.asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          final isSelected = selected == spec;
          final label = spec?.label.tr(context) ?? 'All'.tr(context);

          return Padding(
            padding: EdgeInsets.only(
              right: index < _specs.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(selected == spec ? null : spec),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _kTeal1.withValues(alpha: 0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? _kTeal1.withValues(alpha: 0.35)
                        : AppColors.border.withValues(alpha: 0.3),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _kTeal1.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icon(spec),
                      size: 14,
                      color: isSelected ? _kTeal1 : AppColors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? _kTeal1
                            : AppColors.textSecondary,
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

// ═══════════════════════════════════════════════════════════════════════════
// COUNT LABEL
// ═══════════════════════════════════════════════════════════════════════════

class _CountLabel extends StatelessWidget {
  final AsyncValue<List<Expert>> expertsAsync;
  final String noun;

  const _CountLabel({required this.expertsAsync, required this.noun});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
      child: expertsAsync.when(
        data: (experts) => Text(
          '${experts.length} ${noun.tr(context)}${experts.length != 1 ? 's' : ''} ${'available'.tr(context)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// MY BOOKINGS SECTION
// ═══════════════════════════════════════════════════════════════════════════

enum _BookingTabType { upcoming, completed, cancelled }

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
          _BookingSubTabs(
            activeTab: _activeTab,
            onTabChanged: (tab) => setState(() => _activeTab = tab),
          ),
          const SizedBox(height: 20),
          _BookingEmptyState(tabType: _activeTab),
        ],
      ),
    );
  }
}

class _BookingSubTabs extends StatelessWidget {
  final _BookingTabType activeTab;
  final ValueChanged<_BookingTabType> onTabChanged;

  const _BookingSubTabs({
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (type: _BookingTabType.upcoming, icon: LucideIcons.calendarClock, label: 'Upcoming'.tr(context)),
      (type: _BookingTabType.completed, icon: LucideIcons.checkCircle2, label: 'Completed'.tr(context)),
      (type: _BookingTabType.cancelled, icon: LucideIcons.xCircle, label: 'Cancelled'.tr(context)),
    ];

    final selectedIndex = tabs.indexWhere((t) => t.type == activeTab);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final capsuleWidth = constraints.maxWidth / tabs.length;

          return Stack(
            children: [
              // Sliding capsule indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: selectedIndex * capsuleWidth,
                top: 0,
                bottom: 0,
                width: capsuleWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // Tab labels
              Row(
                children: tabs.map((tab) {
                  final isSelected = activeTab == tab.type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTabChanged(tab.type),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              tab.icon,
                              size: 14,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 5),
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
            ],
          );
        },
      ),
    );
  }
}

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

  String _title(BuildContext context) {
    switch (tabType) {
      case _BookingTabType.upcoming:
        return 'No upcoming bookings'.tr(context);
      case _BookingTabType.completed:
        return 'No completed sessions'.tr(context);
      case _BookingTabType.cancelled:
        return 'No cancelled bookings'.tr(context);
    }
  }

  String _description(BuildContext context) {
    switch (tabType) {
      case _BookingTabType.upcoming:
        return 'Book a consultation with a doctor to get started'.tr(context);
      case _BookingTabType.completed:
        return 'Your completed consultations will appear here'.tr(context);
      case _BookingTabType.cancelled:
        return 'Any cancelled sessions will appear here'.tr(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _icon,
              size: 26,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _title(context),
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _description(context),
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

// ═══════════════════════════════════════════════════════════════════════════
// SKELETONS
// ═══════════════════════════════════════════════════════════════════════════

class _FeaturedRowSkeleton extends StatelessWidget {
  const _FeaturedRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
          child: SkeletonLoader(height: 18, width: 160),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            blur: 10,
            opacity: 0.6,
            padding: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(20),
            height: 220,
            child: const Center(
              child: SkeletonLoader(height: 180, width: double.infinity),
            ),
          ),
        ),
      ],
    );
  }
}

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

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY STATE
// ═══════════════════════════════════════════════════════════════════════════

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GlassCard(
        blur: 12,
        opacity: 0.75,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
        borderRadius: BorderRadius.circular(22),
        borderColor: _kTeal1.withValues(alpha: 0.08),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _kTeal1.withValues(alpha: 0.06),
                    _kTeal2.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _kTeal1.withValues(alpha: 0.1),
                ),
              ),
              child: Icon(
                hasFilters ? LucideIcons.filterX : LucideIcons.graduationCap,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              hasFilters
                  ? 'No experts found'.tr(context)
                  : 'No experts available'.tr(context),
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try adjusting your filters or search query'.tr(context)
                  : 'Check back later for available experts'.tr(context),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 24),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onClearFilters,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_kTeal1, _kTeal2],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _kTeal1.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.filterX, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Clear Filters'.tr(context),
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

// ═══════════════════════════════════════════════════════════════════════════
// ERROR STATE
// ═══════════════════════════════════════════════════════════════════════════

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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.alertCircle,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong'.tr(context),
              style: AppTextStyles.headingSmall.copyWith(
                fontSize: 17,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
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
              color: Colors.transparent,
              child: InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_kTeal1, _kTeal2],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _kTeal1.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.refreshCw, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Try Again'.tr(context),
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/banner_model.dart';
import '../../../providers/home_provider.dart';

/// Auto-scrolling promotional banner carousel.
class PromoBannerCarousel extends ConsumerStatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  ConsumerState<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends ConsumerState<PromoBannerCarousel> {
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      final banners = ref.read(bannersProvider).valueOrNull ?? [];
      if (banners.isEmpty) return;

      _currentPage = (_currentPage + 1) % banners.length;
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bannersAsync = ref.watch(bannersProvider);

    return bannersAsync.when(
      data: (banners) {
        if (banners.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  return _BannerCard(banner: banners[index]);
                },
              ),
            ),
            const SizedBox(height: 12),
            SmoothPageIndicator(
              controller: _pageController,
              count: banners.length,
              effect: const WormEffect(
                dotWidth: 8,
                dotHeight: 8,
                spacing: 6,
                activeDotColor: AppColors.primary,
                dotColor: AppColors.border,
              ),
            ),
          ],
        );
      },
      loading: () => _buildShimmer(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 160,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final AppBanner banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleBannerTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(75),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.network(
                  _getImageUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withAlpha(200),
                          ],
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.shimmerBase,
                    );
                  },
                ),
              ),

              // Gradient overlay for text readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(150),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      banner.title,
                      style: AppTextStyles.headingLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    if (banner.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        banner.subtitle!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withAlpha(230),
                        ),
                      ),
                    ],
                    if (banner.ctaText != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          banner.ctaText!,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the appropriate image URL based on device type.
  String _getImageUrl() {
    // Use mobile-optimized image if available
    return banner.imageUrlMobile ?? banner.imageUrl;
  }

  /// Handles banner tap based on ctaAction type.
  void _handleBannerTap(BuildContext context) {
    if (banner.ctaUrl == null) return;

    switch (banner.ctaAction) {
      case 'navigate':
        // Navigate to internal route
        context.push(banner.ctaUrl!);
        break;
      case 'open_url':
        // Open external URL (would use url_launcher)
        debugPrint('Opening URL: ${banner.ctaUrl}');
        break;
      case 'open_modal':
        // Show modal dialog
        debugPrint('Opening modal for: ${banner.ctaUrl}');
        break;
      default:
        // Default to navigation for backwards compatibility
        if (banner.ctaUrl!.startsWith('/')) {
          context.push(banner.ctaUrl!);
        }
    }
  }
}

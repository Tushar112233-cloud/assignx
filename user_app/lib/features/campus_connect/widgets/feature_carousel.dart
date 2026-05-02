import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Data model for a single carousel slide.
class _CarouselSlide {
  final String badge;
  final String heading;
  final String description;
  final List<String> bullets;
  final List<Color> gradientColors;
  final IconData icon;

  const _CarouselSlide({
    required this.badge,
    required this.heading,
    required this.description,
    required this.bullets,
    required this.gradientColors,
    required this.icon,
  });
}

/// Feature carousel with auto-scrolling slides.
///
/// Displays 4 slides showcasing Campus Connect features with gradient cards,
/// badge labels, headings, descriptions, and bullet points.
/// Auto-scrolls every 4 seconds with dot indicators and swipe support.
class FeatureCarousel extends StatefulWidget {
  const FeatureCarousel({super.key});

  @override
  State<FeatureCarousel> createState() => _FeatureCarouselState();
}

class _FeatureCarouselState extends State<FeatureCarousel> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  static const _slides = [
    _CarouselSlide(
      badge: 'Community',
      heading: 'Your Campus Community',
      description: 'Connect, learn, and grow together',
      bullets: [
        'Ask academic doubts',
        'Share study resources',
        'Form study groups',
      ],
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      icon: Icons.school_rounded,
    ),
    _CarouselSlide(
      badge: 'Housing',
      heading: 'Find Your Place',
      description: 'Safe and verified accommodation',
      bullets: [
        'Discover verified PGs',
        'Find roommates',
        'Housing near campus',
      ],
      gradientColors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      icon: Icons.home_rounded,
    ),
    _CarouselSlide(
      badge: 'Careers',
      heading: 'Grab Opportunities',
      description: 'Launch your career early',
      bullets: [
        'Find internships',
        'Get freelance gigs',
        'Job openings',
      ],
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      icon: Icons.work_rounded,
    ),
    _CarouselSlide(
      badge: 'Marketplace',
      heading: 'Buy & Sell',
      description: 'Student-to-student marketplace',
      bullets: [
        'Trade textbooks',
        'Sell gadgets',
        'Services marketplace',
      ],
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      icon: Icons.shopping_bag_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
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
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemCount: _slides.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _SlideCard(slide: _slides[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SmoothPageIndicator(
            controller: _pageController,
            count: _slides.length,
            effect: WormEffect(
              dotHeight: 6,
              dotWidth: 6,
              activeDotColor: AppColors.primary,
              dotColor: AppColors.border,
              spacing: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual carousel slide card with gradient background.
class _SlideCard extends StatelessWidget {
  final _CarouselSlide slide;

  const _SlideCard({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: slide.gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Left content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      slide.badge,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Heading
                  Text(
                    slide.heading,
                    style: AppTextStyles.headingSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    slide.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Bullet points
                  ...slide.bullets.map(
                    (bullet) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              bullet,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                slide.icon,
                size: 28,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

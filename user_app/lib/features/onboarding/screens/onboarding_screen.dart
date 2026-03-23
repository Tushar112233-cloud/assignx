import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/route_names.dart';
import '../../../core/translation/translation_extensions.dart';

/// Onboarding carousel with 3 slides.
///
/// Warm flat design with primary-colored top section, icon per slide,
/// and step indicators.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoScrollTimer;
  bool _userInteracted = false;

  /// Onboarding slides data.
  /// Each slide has an icon, title, and subtitle.
  static const _pages = [
    {
      'icon': Icons.school_rounded,
      'title': 'Expert Help',
      'subtitle': 'Get professional assistance at your fingertips, anytime',
    },
    {
      'icon': Icons.assignment_rounded,
      'title': 'Versatile Projects',
      'subtitle': 'From essays to presentations, we handle it all for you',
    },
    {
      'icon': Icons.rocket_launch_rounded,
      'title': 'Your Journey Starts',
      'subtitle': 'Join thousands of students achieving academic success',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  /// Start auto-scroll timer.
  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // Stop auto-scroll if user has manually interacted
      if (_userInteracted) {
        timer.cancel();
        return;
      }

      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      } else {
        // Loop back to first page
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// Marks onboarding as complete and navigates to login.
  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      context.go(RouteNames.login);
    }
  }

  /// Moves to next page or completes onboarding if on last page.
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topSectionHeight = screenHeight * 0.55;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Top section with primary background and icon carousel
          _TopSection(
            pageController: _pageController,
            pages: _pages,
            currentPage: _currentPage,
            topSectionHeight: topSectionHeight,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _userInteracted = true;
              });
            },
            onSwipeStart: () {
              setState(() => _userInteracted = true);
            },
          ),

          // Bottom section with text content
          Expanded(
            child: _BottomContent(
              currentPage: _currentPage,
              totalPages: _pages.length,
              title: (_pages[_currentPage]['title'] as String).tr(context),
              subtitle:
                  (_pages[_currentPage]['subtitle'] as String).tr(context),
              onNext: _nextPage,
              onSkip: _completeOnboarding,
            ),
          ),
        ],
      ),
    );
  }
}

/// Top section with rounded bottom corners, primary background, and icon.
class _TopSection extends StatelessWidget {
  final PageController pageController;
  final List<Map<String, dynamic>> pages;
  final int currentPage;
  final double topSectionHeight;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onSwipeStart;

  const _TopSection({
    required this.pageController,
    required this.pages,
    required this.currentPage,
    required this.topSectionHeight,
    required this.onPageChanged,
    required this.onSwipeStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: topSectionHeight,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: GestureDetector(
        onHorizontalDragStart: (_) => onSwipeStart(),
        child: PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final icon = pages[index]['icon'] as IconData;
            return SafeArea(
              bottom: false,
              child: Center(
                child: _SlideIcon(
                  icon: icon,
                  isActive: index == currentPage,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Icon displayed inside a translucent white circle, with entrance animation.
class _SlideIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _SlideIcon({
    required this.icon,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.15),
      ),
      child: Icon(
        icon,
        size: 80,
        color: Colors.white,
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.easeOutBack,
        );
  }
}

/// Bottom section with title, subtitle, next button, and dots.
class _BottomContent extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const _BottomContent({
    required this.currentPage,
    required this.totalPages,
    required this.title,
    required this.subtitle,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title - prominent heading
            Text(
              title,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 32,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            )
                .animate(key: ValueKey('title-$currentPage'))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.2, end: 0, duration: 300.ms),

            const SizedBox(height: 12),

            // Subtitle - caption below title
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            )
                .animate(key: ValueKey('subtitle-$currentPage'))
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0, duration: 300.ms),

            const SizedBox(height: 32),

            // Next button
            _NextButton(
              onPressed: onNext,
              isLastPage: isLastPage,
            ).animate().scale(delay: 200.ms, duration: 300.ms),

            const SizedBox(height: 20),

            // Page indicator dots
            _PageDots(
              currentPage: currentPage,
              totalPages: totalPages,
            ).animate().fadeIn(delay: 300.ms, duration: 300.ms),

            // Skip to sign-in link (not shown on last page)
            if (!isLastPage) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => GoRouter.of(context).go(RouteNames.login),
                child: Text(
                  'Already have an account? Sign in'.tr(context),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 300.ms),
            ],
          ],
        ),
      ),
    );
  }
}

/// Next/Get Started button.
class _NextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLastPage;

  const _NextButton({
    required this.onPressed,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLastPage) {
      // "Get Started" pill button for last page
      return GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            'Get Started'.tr(context),
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Circular arrow button for other pages
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_forward,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

/// Page indicator dots.
class _PageDots extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const _PageDots({
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.textPrimary
                : AppColors.textSecondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

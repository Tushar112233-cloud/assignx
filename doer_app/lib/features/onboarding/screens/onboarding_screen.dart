import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/app_button.dart';

/// Onboarding carousel screen with 4 slides.
///
/// Presents the app's value proposition through an animated carousel
/// of feature slides, guiding new users towards registration.
///
/// ## Navigation
/// - Entry: From [SplashScreen] for unauthenticated users
/// - Get Started / Skip: Navigates to [RegisterScreen]
/// - Sign In: Navigates to [LoginScreen] for existing users
///
/// ## Features
/// - 4 animated slides showcasing app benefits
/// - Swipeable page view with smooth transitions
/// - Skip button to bypass onboarding
/// - Expandable dots page indicator
/// - Context-aware button text (Next vs Get Started)
///
/// ## Slides Content
/// 1. Countless Opportunities - Finding work opportunities
/// 2. Small Tasks, Big Rewards - Earning potential
/// 3. Supervisor Support (24x7) - Support availability
/// 4. Learn While You Earn - Educational aspect
///
/// See also:
/// - [RegisterScreen] for new user registration
/// - [LoginScreen] for existing user authentication
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// State class for [OnboardingScreen].
///
/// Manages page navigation, current page index, and slide data.
class _OnboardingScreenState extends State<OnboardingScreen> {
  /// Controller for the page view carousel.
  final PageController _pageController = PageController();

  /// Index of the currently visible page (0-3).
  int _currentPage = 0;

  /// Static list of onboarding slide data.
  ///
  /// Each slide contains an icon, title, subtitle, and accent color.
  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      icon: Icons.work_outline,
      title: 'Countless Opportunities',
      subtitle: 'Find endless opportunities in your field of expertise',
      color: Color(0xFF3B82F6),
    ),
    OnboardingSlide(
      icon: Icons.monetization_on_outlined,
      title: 'Small Tasks, Big Rewards',
      subtitle: 'Complete micro-tasks and earn substantial rewards',
      color: Color(0xFF22C55E),
    ),
    OnboardingSlide(
      icon: Icons.support_agent,
      title: 'Supervisor Support (24x7)',
      subtitle: 'Get round-the-clock guidance from experienced supervisors',
      color: Color(0xFFF59E0B),
    ),
    OnboardingSlide(
      icon: Icons.school_outlined,
      title: 'Learn While You Earn',
      subtitle: 'Practical learning combined with part-time earning opportunities',
      color: Color(0xFF8B5CF6),
    ),
  ];

  /// Disposes of the page controller to prevent memory leaks.
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handles page change events from the page view.
  ///
  /// Updates [_currentPage] to reflect the newly visible slide.
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  /// Advances to the next slide or navigates to registration.
  ///
  /// If not on the last slide, animates to the next page.
  /// If on the last slide, navigates to [RegisterScreen].
  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToRegister();
    }
  }

  /// Navigates directly to the registration screen.
  ///
  /// Called by both the Skip button and the "Get Started" button
  /// on the last slide.
  void _navigateToRegister() {
    context.go(RouteNames.register);
  }

  /// Builds the onboarding screen UI.
  ///
  /// Layout structure:
  /// - Skip button in top right
  /// - Swipeable page view with animated slides
  /// - Page indicator dots
  /// - Next/Get Started button
  /// - Sign In link for existing users
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: AppSpacing.paddingMd,
                child: TextButton(
                  onPressed: _navigateToRegister,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(slide: _slides[index]);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: AppSpacing.paddingLg,
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _slides.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.border,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: _currentPage == _slides.length - 1
                              ? 'Get Started'
                              : 'Next',
                          onPressed: _nextPage,
                          isFullWidth: true,
                          suffixIcon: Icons.arrow_forward,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Already have account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go(RouteNames.login),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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

/// Data model for onboarding slide content.
///
/// Encapsulates all visual and textual data needed to render
/// a single onboarding slide.
class OnboardingSlide {
  /// Icon displayed in the slide's feature circle.
  final IconData icon;

  /// Main heading text for the slide.
  final String title;

  /// Descriptive text below the title.
  final String subtitle;

  /// Accent color used for the icon and its background.
  final Color color;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// Single onboarding page widget with animated content.
///
/// Displays the slide's icon, title, and subtitle with
/// staggered fade and scale animations.
class _OnboardingPage extends StatelessWidget {
  /// The slide data to display.
  final OnboardingSlide slide;

  const _OnboardingPage({required this.slide});

  /// Builds the animated slide content.
  ///
  /// Animation sequence:
  /// 1. Icon fades in and scales (0-400ms)
  /// 2. Title fades in and slides up (200-600ms)
  /// 3. Subtitle fades in (400-800ms)
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingLg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              size: 80,
              color: slide.color,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 400.ms,
              ),

          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            slide.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            slide.subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate(delay: 400.ms)
              .fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

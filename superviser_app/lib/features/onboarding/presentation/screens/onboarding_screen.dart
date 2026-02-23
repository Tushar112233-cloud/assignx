import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_page.dart';
import '../widgets/page_indicator.dart';

/// Onboarding screen with swipeable pages.
///
/// Shows app introduction slides on first launch.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _nextPage() {
    if (_currentPage < defaultOnboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == defaultOnboardingPages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: defaultOnboardingPages.length,
                itemBuilder: (context, index) {
                  final pageData = defaultOnboardingPages[index];
                  return OnboardingPage(
                    icon: pageData.icon,
                    title: pageData.title,
                    description: pageData.description,
                    iconColor: pageData.iconColor,
                    iconBackgroundColor: pageData.backgroundColor,
                  ).animate().fadeIn(duration: 300.ms);
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicators
                  PageIndicator(
                    count: defaultOnboardingPages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: 32),

                  // Action button
                  PrimaryButton(
                    text: isLastPage ? 'Get Started' : 'Next',
                    onPressed: _nextPage,
                    icon: isLastPage ? Icons.arrow_forward : null,
                    iconPosition: IconPosition.right,
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

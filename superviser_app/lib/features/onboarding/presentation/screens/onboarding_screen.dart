import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_page.dart';

/// Mesh gradient colors per onboarding page for visual variety.
const _pageGradientColors = <List<Color>>[
  [AppColors.meshAmber, AppColors.meshGold, AppColors.meshOrange, AppColors.meshPeach],
  [AppColors.meshOrange, AppColors.meshPeach, AppColors.meshAmber, AppColors.meshGold],
  [AppColors.meshLavender, AppColors.meshMint, AppColors.meshGold, AppColors.meshAmber],
  [AppColors.meshGold, AppColors.meshAmber, AppColors.meshOrange, AppColors.meshMint],
];

/// Mesh gradient positions per onboarding page.
const _pagePositions = <MeshPosition>[
  MeshPosition.center,
  MeshPosition.topRight,
  MeshPosition.bottomLeft,
  MeshPosition.topLeft,
];

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
    final pageCount = defaultOnboardingPages.length;

    // Get current page gradient colors (with fallback)
    final gradientColors = _currentPage < _pageGradientColors.length
        ? _pageGradientColors[_currentPage]
        : _pageGradientColors[0];
    final gradientPosition = _currentPage < _pagePositions.length
        ? _pagePositions[_currentPage]
        : MeshPosition.center;

    return Scaffold(
      body: MeshGradientBackground(
        position: gradientPosition,
        colors: gradientColors,
        opacity: 0.5,
        child: SafeArea(
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
                      'Skip'.tr(context),
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
                  itemCount: pageCount,
                  itemBuilder: (context, index) {
                    final pageData = defaultOnboardingPages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassContainer(
                        blur: 12,
                        opacity: 0.75,
                        borderRadius: BorderRadius.circular(24),
                        borderColor: Colors.white.withValues(alpha: 0.3),
                        padding: const EdgeInsets.all(24),
                        child: OnboardingPage(
                          icon: pageData.icon,
                          title: pageData.title,
                          description: pageData.description,
                          iconColor: pageData.iconColor,
                          iconBackgroundColor: pageData.backgroundColor,
                        ),
                      ).animate().fadeIn(duration: 300.ms),
                    );
                  },
                ),
              ),

              // Bottom section
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Pill-shaped page indicators with orange accent
                    _buildPillIndicators(pageCount),
                    const SizedBox(height: 32),

                    // Action button
                    PrimaryButton(
                      text: isLastPage ? 'Get Started'.tr(context) : 'Next'.tr(context),
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
      ),
    );
  }

  /// Builds pill-shaped page indicators with orange accent color.
  Widget _buildPillIndicators(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 32 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.accent
                : AppColors.accent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

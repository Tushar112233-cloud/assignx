import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Animated page indicator dots for onboarding.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.activeWidth = 24,
    this.dotSize = 8,
    this.spacing = 8,
  });

  /// Total number of pages
  final int count;

  /// Current page index
  final int currentIndex;

  /// Color for active dot
  final Color? activeColor;

  /// Color for inactive dots
  final Color? inactiveColor;

  /// Width of active dot
  final double activeWidth;

  /// Size of inactive dots
  final double dotSize;

  /// Spacing between dots
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveColor = inactiveColor ??
        AppColors.primary.withValues(alpha: 0.2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? activeWidth : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? effectiveActiveColor : effectiveInactiveColor,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}

/// Smooth page indicator that follows the page controller
class SmoothPageIndicator extends StatelessWidget {
  const SmoothPageIndicator({
    super.key,
    required this.controller,
    required this.count,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.spacing = 8,
  });

  final PageController controller;
  final int count;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveInactiveColor = inactiveColor ??
        AppColors.primary.withValues(alpha: 0.2);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final page = controller.hasClients
            ? (controller.page ?? controller.initialPage).toDouble()
            : controller.initialPage.toDouble();

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (index) {
            final distance = (page - index).abs();
            final scale = (1 - distance.clamp(0, 1) * 0.3);
            final width = dotSize + (16 * (1 - distance.clamp(0, 1)));

            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.symmetric(horizontal: spacing / 2),
              width: width,
              height: dotSize * scale,
              decoration: BoxDecoration(
                color: Color.lerp(
                  effectiveInactiveColor,
                  effectiveActiveColor,
                  (1 - distance.clamp(0, 1)),
                ),
                borderRadius: BorderRadius.circular(dotSize / 2),
              ),
            );
          }),
        );
      },
    );
  }
}

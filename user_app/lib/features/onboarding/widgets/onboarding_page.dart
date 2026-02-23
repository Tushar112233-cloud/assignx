import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Single page in the onboarding carousel.
///
/// Displays an icon, title, and description in a centered layout.
class OnboardingPage extends StatelessWidget {
  /// Icon to display.
  final IconData icon;

  /// Page title.
  final String title;

  /// Page description.
  final String description;

  /// Optional icon color.
  final Color? iconColor;

  /// Optional background color for icon container.
  final Color? iconBackgroundColor;

  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: iconBackgroundColor ?? AppColors.primary.withAlpha(25), // 0.1 opacity
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 60,
              color: iconColor ?? AppColors.primary,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

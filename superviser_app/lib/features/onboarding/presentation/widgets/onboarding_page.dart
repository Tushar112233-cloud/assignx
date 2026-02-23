import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Single onboarding page content.
///
/// Displays an icon/image, title, and description for each onboarding step.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.iconBackgroundColor,
  });

  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Description text
  final String description;

  /// Icon color (defaults to primary)
  final Color? iconColor;

  /// Icon background color
  final Color? iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveBgColor = iconBackgroundColor ??
        AppColors.primary.withValues(alpha: 0.1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: effectiveBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: effectiveIconColor,
            ),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            title,
            style: AppTypography.headlineMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: AppTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Data model for onboarding page content
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final Color? backgroundColor;
}

/// Default onboarding pages for the supervisor app
const List<OnboardingPageData> defaultOnboardingPages = [
  OnboardingPageData(
    icon: Icons.admin_panel_settings,
    title: 'Welcome to AdminX',
    description:
        'Your professional supervision platform. Manage projects, coordinate with experts, and deliver excellence.',
  ),
  OnboardingPageData(
    icon: Icons.assignment,
    title: 'Manage Projects',
    description:
        'Review requests, create quotes, assign experts, and track progress - all from your mobile device.',
  ),
  OnboardingPageData(
    icon: Icons.chat_bubble_outline,
    title: 'Real-time Communication',
    description:
        'Stay connected with clients and experts through our integrated chat system with instant notifications.',
  ),
  OnboardingPageData(
    icon: Icons.trending_up,
    title: 'Track Your Earnings',
    description:
        'Monitor your commissions, view detailed statistics, and grow your supervision business.',
  ),
];

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/animations/common_animations.dart';
import '../../../shared/widgets/skeleton_loader.dart';

/// Greeting section widget with time-based personalized message.
///
/// Displays "Good Morning/Afternoon/Evening" with user's name
/// and a motivational subtitle.
///
/// Example:
/// ```dart
/// GreetingSection(
///   userName: 'Alice',
///   isLoading: false,
/// )
/// ```
class GreetingSection extends StatelessWidget {
  /// User's name to display in greeting.
  final String? userName;

  /// Whether to show skeleton loader.
  final bool isLoading;

  /// Optional custom subtitle. Defaults to assignment-related message.
  final String? subtitle;

  /// Animation delay for entrance.
  final Duration? animationDelay;

  const GreetingSection({
    super.key,
    this.userName,
    this.isLoading = false,
    this.subtitle,
    this.animationDelay,
  });

  /// Returns time-appropriate greeting based on current hour.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning,';
    } else if (hour < 17) {
      return 'Good Afternoon,';
    } else {
      return 'Good Evening,';
    }
  }

  /// Extracts first name from full name or returns default.
  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Student';
    final parts = fullName.split(' ');
    return parts.first;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildSkeleton();
    }

    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time-based greeting - normal weight, dark gray
          Text(
            _getGreeting(),
            style: AppTextStyles.displayMedium.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          // User's first name - bold, larger, near-black
          Text(
            _getFirstName(userName),
            style: AppTextStyles.displayLarge.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle - medium gray
          Text(
            subtitle ?? 'Ready to optimize your workflow and generate insights.',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    // Apply animation if delay is provided
    if (animationDelay != null) {
      content = content.fadeInSlideUp(
        delay: animationDelay!,
        duration: const Duration(milliseconds: 400),
      );
    }

    return content;
  }

  /// Builds skeleton loader for greeting section.
  Widget _buildSkeleton() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(width: 180, height: 28, borderRadius: 6),
          SizedBox(height: 4),
          SkeletonLoader(width: 120, height: 28, borderRadius: 6),
          SizedBox(height: 12),
          SkeletonLoader(width: 220, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

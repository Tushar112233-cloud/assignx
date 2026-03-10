import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'filter_tabs_bar.dart';

/// Data model for a single feature card in the grid.
class _FeatureCard {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  final CampusConnectCategory category;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientEnd,
    required this.category,
  });
}

/// "What is Campus Connect?" section with a 2x3 grid of tappable feature cards.
///
/// Each card describes a core feature area with a gradient background,
/// distinct icon, and tapping it sets the active category filter on the
/// parent screen.
class FeatureCardsGrid extends StatelessWidget {
  /// Callback invoked when a feature card is tapped.
  /// Passes the [CampusConnectCategory] to set as the active filter.
  final ValueChanged<CampusConnectCategory> onCategorySelected;

  const FeatureCardsGrid({
    super.key,
    required this.onCategorySelected,
  });

  static const _cards = [
    _FeatureCard(
      title: 'Ask & Answer',
      subtitle: 'Get help with academic doubts',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF6366F1),
      gradientEnd: Color(0xFF818CF8),
      category: CampusConnectCategory.questions,
    ),
    _FeatureCard(
      title: 'Find Housing',
      subtitle: 'Discover verified PGs and flats',
      icon: Icons.home_rounded,
      color: Color(0xFFF59E0B),
      gradientEnd: Color(0xFFFBBF24),
      category: CampusConnectCategory.housing,
    ),
    _FeatureCard(
      title: 'Grab Opportunities',
      subtitle: 'Find internships and jobs',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF10B981),
      gradientEnd: Color(0xFF34D399),
      category: CampusConnectCategory.opportunities,
    ),
    _FeatureCard(
      title: 'Join Events',
      subtitle: 'Never miss campus events',
      icon: Icons.celebration_rounded,
      color: Color(0xFFEC4899),
      gradientEnd: Color(0xFFF472B6),
      category: CampusConnectCategory.events,
    ),
    _FeatureCard(
      title: 'Buy & Sell',
      subtitle: 'Trade textbooks and gadgets',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF3B82F6),
      gradientEnd: Color(0xFF60A5FA),
      category: CampusConnectCategory.marketplace,
    ),
    _FeatureCard(
      title: 'Network',
      subtitle: 'Connect with 500+ colleges',
      icon: Icons.people_rounded,
      color: Color(0xFF8B5CF6),
      gradientEnd: Color(0xFFA78BFA),
      category: CampusConnectCategory.discussions,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with accent line
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'What is Campus Connect?',
                style: AppTextStyles.headingSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              'Your all-in-one platform to stay connected with your college community',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // 2x3 grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              return _FeatureCardWidget(
                card: _cards[index],
                onTap: () => onCategorySelected(_cards[index].category),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Individual feature card widget with gradient background, icon, title,
/// and subtitle.
class _FeatureCardWidget extends StatelessWidget {
  final _FeatureCard card;
  final VoidCallback onTap;

  const _FeatureCardWidget({
    required this.card,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card.color.withValues(alpha: 0.08),
                card.gradientEnd.withValues(alpha: 0.04),
              ],
            ),
            border: Border.all(
              color: card.color.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: card.color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with gradient
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [card.color, card.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: card.color.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    card.icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                // Title
                Text(
                  card.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                // Subtitle
                Text(
                  card.subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'filter_tabs_bar.dart';

/// Data model for a quick access action button.
class _QuickAction {
  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final Color gradientEnd;
  final CampusConnectCategory category;

  const _QuickAction({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.gradientEnd,
    required this.category,
  });
}

/// Horizontal scrolling row of quick-access action buttons.
///
/// Each button is a column with a gradient [CircleAvatar] and text label.
/// Tapping a button sets the corresponding category filter on the parent screen.
class QuickAccessRow extends StatelessWidget {
  /// Callback invoked when an action button is tapped.
  /// Passes the [CampusConnectCategory] to set as the active filter.
  final ValueChanged<CampusConnectCategory> onCategorySelected;

  const QuickAccessRow({
    super.key,
    required this.onCategorySelected,
  });

  static const _actions = [
    _QuickAction(
      label: 'Questions',
      sublabel: 'Ask doubts',
      icon: Icons.help_outline_rounded,
      color: Color(0xFF6366F1),
      gradientEnd: Color(0xFF818CF8),
      category: CampusConnectCategory.questions,
    ),
    _QuickAction(
      label: 'Jobs',
      sublabel: 'Internships',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF10B981),
      gradientEnd: Color(0xFF34D399),
      category: CampusConnectCategory.opportunities,
    ),
    _QuickAction(
      label: 'Events',
      sublabel: 'Campus events',
      icon: Icons.celebration_rounded,
      color: Color(0xFFEC4899),
      gradientEnd: Color(0xFFF472B6),
      category: CampusConnectCategory.events,
    ),
    _QuickAction(
      label: 'Market',
      sublabel: 'Buy & sell',
      icon: Icons.shopping_bag_rounded,
      color: Color(0xFF3B82F6),
      gradientEnd: Color(0xFF60A5FA),
      category: CampusConnectCategory.marketplace,
    ),
    _QuickAction(
      label: 'Resources',
      sublabel: 'Study tips',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF59E0B),
      gradientEnd: Color(0xFFFBBF24),
      category: CampusConnectCategory.resources,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return _QuickAccessButton(
            action: _actions[index],
            onTap: () => onCategorySelected(_actions[index].category),
          );
        },
      ),
    );
  }
}

/// Individual quick access button with gradient circle and label.
class _QuickAccessButton extends StatelessWidget {
  final _QuickAction action;
  final VoidCallback onTap;

  const _QuickAccessButton({
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circle avatar with gradient and shadow
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [action.color, action.gradientEnd],
                ),
                boxShadow: [
                  BoxShadow(
                    color: action.color.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Icon(
                action.icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            // Label
            Text(
              action.label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

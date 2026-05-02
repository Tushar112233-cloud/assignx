import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'filter_tabs_bar.dart';

/// Quick category access row — dashboard-style colorful icon tiles.
///
/// Horizontal scrollable row of tappable category shortcuts.
/// Each tile has a gradient icon container (pop of color) with
/// coffee brown label text below — same pattern as dashboard quick actions.
class QuickCategories extends StatelessWidget {
  final Function(CampusConnectCategory) onCategorySelected;

  const QuickCategories({super.key, required this.onCategorySelected});

  static const _items = [
    _QuickCatItem(
      label: 'Questions',
      icon: Icons.help_outline_rounded,
      colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
      category: CampusConnectCategory.questions,
    ),
    _QuickCatItem(
      label: 'Housing',
      icon: Icons.home_rounded,
      colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
      category: CampusConnectCategory.housing,
    ),
    _QuickCatItem(
      label: 'Jobs',
      icon: Icons.rocket_launch_rounded,
      colors: [Color(0xFF10B981), Color(0xFF34D399)],
      category: CampusConnectCategory.opportunities,
    ),
    _QuickCatItem(
      label: 'Events',
      icon: Icons.celebration_rounded,
      colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
      category: CampusConnectCategory.events,
    ),
    _QuickCatItem(
      label: 'Buy & Sell',
      icon: Icons.shopping_bag_rounded,
      colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
      category: CampusConnectCategory.marketplace,
    ),
    _QuickCatItem(
      label: 'Resources',
      icon: Icons.menu_book_rounded,
      colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      category: CampusConnectCategory.resources,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(
                right: index < _items.length - 1 ? 16 : 0),
            child: _QuickCatTile(
              item: item,
              onTap: () => onCategorySelected(item.category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _QuickCatItem {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final CampusConnectCategory category;

  const _QuickCatItem({
    required this.label,
    required this.icon,
    required this.colors,
    required this.category,
  });
}

/// Individual quick category tile — colorful icon box + label.
class _QuickCatTile extends StatelessWidget {
  final _QuickCatItem item;
  final VoidCallback onTap;

  const _QuickCatTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            // Gradient icon container — the pop of color
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: item.colors,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: item.colors.first.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                item.icon,
                size: 22,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            // Label — coffee brown
            Text(
              item.label,
              style: AppTextStyles.labelSmall.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
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

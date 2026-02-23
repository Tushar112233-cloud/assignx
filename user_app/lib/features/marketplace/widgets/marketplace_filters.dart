import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/marketplace_model.dart';
import '../../../providers/marketplace_provider.dart';

/// Filter chips for marketplace listings.
class MarketplaceFilters extends ConsumerWidget {
  const MarketplaceFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(marketplaceFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // All filter chip
              _FilterChip(
                label: 'All',
                icon: Icons.apps,
                isSelected: filters.category == null,
                onTap: () {
                  ref.read(marketplaceFilterProvider.notifier).setCategory(null);
                },
              ),
              const SizedBox(width: 8),
              // Category chips
              ...MarketplaceCategory.values.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: category.label,
                    icon: category.icon,
                    isSelected: filters.category == category,
                    onTap: () {
                      ref
                          .read(marketplaceFilterProvider.notifier)
                          .setCategory(category);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // City and sort filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // City dropdown
              Expanded(
                child: _CityDropdown(
                  selectedCity: filters.city,
                  onChanged: (city) {
                    ref.read(marketplaceFilterProvider.notifier).setCity(city);
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Sort button
              _SortButton(
                onTap: () => _showSortOptions(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _SortOptionsSheet(),
    );
  }
}

/// Filter chip widget.
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// City dropdown widget.
class _CityDropdown extends StatelessWidget {
  final String? selectedCity;
  final ValueChanged<String?> onChanged;

  const _CityDropdown({
    required this.selectedCity,
    required this.onChanged,
  });

  static const _cities = [
    'Delhi',
    'Mumbai',
    'Bangalore',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedCity,
          hint: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select City',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.textSecondary,
          ),
          isExpanded: true,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Cities',
                style: AppTextStyles.bodySmall,
              ),
            ),
            ..._cities.map(
              (city) => DropdownMenuItem(
                value: city,
                child: Row(
                  children: [
                    Icon(
                      Icons.location_city,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      city,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Sort button widget.
class _SortButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SortButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(
          Icons.tune,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Sort options bottom sheet.
class _SortOptionsSheet extends StatelessWidget {
  const _SortOptionsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Sort & Filter',
              style: AppTextStyles.headingSmall,
            ),
            const SizedBox(height: 20),

            // Sort options
            _SortOption(
              icon: Icons.access_time,
              label: 'Most Recent',
              isSelected: true,
              onTap: () => Navigator.pop(context),
            ),
            _SortOption(
              icon: Icons.trending_up,
              label: 'Most Popular',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _SortOption(
              icon: Icons.attach_money,
              label: 'Price: Low to High',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _SortOption(
              icon: Icons.money_off,
              label: 'Price: High to Low',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
            _SortOption(
              icon: Icons.near_me,
              label: 'Nearest First',
              isSelected: false,
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sort option item.
class _SortOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppColors.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Search bar for marketplace.
class MarketplaceSearchBar extends ConsumerStatefulWidget {
  const MarketplaceSearchBar({super.key});

  @override
  ConsumerState<MarketplaceSearchBar> createState() =>
      _MarketplaceSearchBarState();
}

class _MarketplaceSearchBarState extends ConsumerState<MarketplaceSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search items, events, posts...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    _controller.clear();
                    ref
                        .read(marketplaceFilterProvider.notifier)
                        .setSearchQuery(null);
                    setState(() {});
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: (value) {
          ref.read(marketplaceFilterProvider.notifier).setSearchQuery(value);
          setState(() {});
        },
      ),
    );
  }
}

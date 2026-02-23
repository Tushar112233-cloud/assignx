import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/connect_provider.dart';
import '../../../shared/widgets/glass_container.dart';

/// Advanced filter bottom sheet for the Connect module.
///
/// Provides filters for:
/// - Subject dropdown
/// - Rating slider (1-5 stars)
/// - Availability (weekdays/weekends)
/// - Price range slider
/// - Sort by options
class AdvancedFilterSheet extends ConsumerStatefulWidget {
  const AdvancedFilterSheet({super.key});

  /// Show the filter sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdvancedFilterSheet(),
    );
  }

  @override
  ConsumerState<AdvancedFilterSheet> createState() => _AdvancedFilterSheetState();
}

class _AdvancedFilterSheetState extends ConsumerState<AdvancedFilterSheet> {
  late String? _selectedSubject;
  late double _minRating;
  late double _maxPrice;
  late List<String> _selectedAvailability;
  late String? _selectedSort;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(connectFilterProvider);
    _selectedSubject = filters.subject;
    _minRating = filters.minRating ?? 0;
    _maxPrice = filters.maxPrice ?? 2000;
    _selectedAvailability = filters.availability ?? [];
    _selectedSort = filters.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final subjects = ref.watch(connectSubjectsProvider);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(245),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: Colors.white.withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: AppTextStyles.headingMedium,
                    ),
                    GestureDetector(
                      onTap: _resetFilters,
                      child: Text(
                        'Reset',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding + 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Subject dropdown
                      _buildSectionTitle('Subject'),
                      const SizedBox(height: 8),
                      _buildSubjectDropdown(subjects),

                      const SizedBox(height: 24),

                      // Rating slider
                      _buildSectionTitle('Minimum Rating'),
                      const SizedBox(height: 8),
                      _buildRatingSlider(),

                      const SizedBox(height: 24),

                      // Availability
                      _buildSectionTitle('Availability'),
                      const SizedBox(height: 8),
                      _buildAvailabilityChips(),

                      const SizedBox(height: 24),

                      // Price range
                      _buildSectionTitle('Maximum Price (per hour)'),
                      const SizedBox(height: 8),
                      _buildPriceSlider(),

                      const SizedBox(height: 24),

                      // Sort by
                      _buildSectionTitle('Sort By'),
                      const SizedBox(height: 8),
                      _buildSortOptions(),

                      const SizedBox(height: 32),

                      // Apply button
                      _buildApplyButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSubjectDropdown(List<String> subjects) {
    return GlassContainer(
      blur: 10,
      opacity: 0.7,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      borderColor: AppColors.border.withAlpha(77),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedSubject,
          isExpanded: true,
          hint: Text(
            'Select subject',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
          ),
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Subjects',
                style: AppTextStyles.bodyMedium,
              ),
            ),
            ...subjects.map(
              (subject) => DropdownMenuItem(
                value: subject,
                child: Text(
                  subject,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() => _selectedSubject = value);
          },
        ),
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: List.generate(5, (index) {
                final starValue = index + 1;
                return Icon(
                  starValue <= _minRating ? Icons.star : Icons.star_border,
                  size: 20,
                  color: AppColors.warning,
                );
              }),
            ),
            Text(
              _minRating == 0 ? 'Any' : '${_minRating.toStringAsFixed(1)}+',
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(30),
            trackHeight: 4,
          ),
          child: Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (value) {
              setState(() => _minRating = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityChips() {
    final options = ['Weekdays', 'Weekends', 'Mornings', 'Evenings'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _selectedAvailability.contains(option);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAvailability.remove(option);
              } else {
                _selectedAvailability.add(option);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
            child: Text(
              option,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\u20B9100',
              style: AppTextStyles.caption,
            ),
            Text(
              _maxPrice >= 2000 ? 'No limit' : '\u20B9${_maxPrice.toStringAsFixed(0)}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '\u20B92000+',
              style: AppTextStyles.caption,
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withAlpha(30),
            trackHeight: 4,
          ),
          child: Slider(
            value: _maxPrice,
            min: 100,
            max: 2000,
            divisions: 19,
            onChanged: (value) {
              setState(() => _maxPrice = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortOptions() {
    final options = [
      ('rating', 'Highest Rated', Icons.star_outline),
      ('price_low', 'Price: Low to High', Icons.arrow_upward),
      ('price_high', 'Price: High to Low', Icons.arrow_downward),
      ('reviews', 'Most Reviews', Icons.rate_review_outlined),
    ];

    return Column(
      children: options.map((option) {
        final (value, label, icon) = option;
        final isSelected = _selectedSort == value;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedSort = isSelected ? null : value;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withAlpha(51),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(26)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyButton() {
    return GlassButton(
      label: 'Apply Filters',
      onPressed: _applyFilters,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      height: 52,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedSubject = null;
      _minRating = 0;
      _maxPrice = 2000;
      _selectedAvailability = [];
      _selectedSort = null;
    });
  }

  void _applyFilters() {
    final notifier = ref.read(connectFilterProvider.notifier);

    notifier.setSubject(_selectedSubject);
    notifier.setMinRating(_minRating > 0 ? _minRating : null);
    notifier.setMaxPrice(_maxPrice < 2000 ? _maxPrice : null);
    notifier.setAvailability(
        _selectedAvailability.isNotEmpty ? _selectedAvailability : null);
    notifier.setSortBy(_selectedSort);

    Navigator.of(context).pop();
  }
}

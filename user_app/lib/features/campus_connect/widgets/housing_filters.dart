import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Housing filter state model
class HousingFilters {
  final String? location;
  final String? area;
  final String? distanceFromCampus;
  final RangeValues priceRange;
  final List<String> propertyType;
  final List<String> amenities;

  const HousingFilters({
    this.location,
    this.area,
    this.distanceFromCampus,
    this.priceRange = const RangeValues(0, 50000),
    this.propertyType = const [],
    this.amenities = const [],
  });

  HousingFilters copyWith({
    String? location,
    String? area,
    String? distanceFromCampus,
    RangeValues? priceRange,
    List<String>? propertyType,
    List<String>? amenities,
  }) {
    return HousingFilters(
      location: location ?? this.location,
      area: area ?? this.area,
      distanceFromCampus: distanceFromCampus ?? this.distanceFromCampus,
      priceRange: priceRange ?? this.priceRange,
      propertyType: propertyType ?? this.propertyType,
      amenities: amenities ?? this.amenities,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      location != null ||
      area != null ||
      distanceFromCampus != null ||
      priceRange.start > 0 ||
      priceRange.end < 50000 ||
      propertyType.isNotEmpty ||
      amenities.isNotEmpty;

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    if (location != null) count++;
    if (area != null) count++;
    if (distanceFromCampus != null) count++;
    if (priceRange.start > 0 || priceRange.end < 50000) count++;
    count += propertyType.length;
    count += amenities.length;
    return count;
  }

  /// Reset to defaults
  static const HousingFilters empty = HousingFilters();
}

/// Property type configuration
class PropertyTypeOption {
  final String id;
  final String label;
  final IconData icon;

  const PropertyTypeOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Amenity configuration
class AmenityOption {
  final String id;
  final String label;
  final IconData icon;

  const AmenityOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Available property types
const List<PropertyTypeOption> propertyTypes = [
  PropertyTypeOption(id: 'pg', label: 'PG', icon: Icons.apartment),
  PropertyTypeOption(id: 'flat', label: 'Flat', icon: Icons.home),
  PropertyTypeOption(id: 'hostel', label: 'Hostel', icon: Icons.business),
  PropertyTypeOption(id: 'shared', label: 'Shared Room', icon: Icons.people),
  PropertyTypeOption(id: 'studio', label: 'Studio', icon: Icons.room),
  PropertyTypeOption(id: '1bhk', label: '1 BHK', icon: Icons.bed),
  PropertyTypeOption(id: '2bhk', label: '2 BHK', icon: Icons.king_bed),
];

/// Available amenities
const List<AmenityOption> amenities = [
  AmenityOption(id: 'wifi', label: 'WiFi', icon: Icons.wifi),
  AmenityOption(id: 'ac', label: 'AC', icon: Icons.ac_unit),
  AmenityOption(id: 'food', label: 'Food/Mess', icon: Icons.restaurant),
  AmenityOption(id: 'laundry', label: 'Laundry', icon: Icons.local_laundry_service),
  AmenityOption(id: 'parking', label: 'Parking', icon: Icons.local_parking),
  AmenityOption(id: 'security', label: '24/7 Security', icon: Icons.security),
  AmenityOption(id: 'gym', label: 'Gym', icon: Icons.fitness_center),
  AmenityOption(id: 'geyser', label: 'Geyser', icon: Icons.hot_tub),
  AmenityOption(id: 'tv', label: 'TV/Cable', icon: Icons.tv),
];

/// Distance options
const List<Map<String, String>> distanceOptions = [
  {'value': '0-1', 'label': 'Within 1 km'},
  {'value': '1-2', 'label': '1-2 km'},
  {'value': '2-5', 'label': '2-5 km'},
  {'value': '5-10', 'label': '5-10 km'},
  {'value': '10+', 'label': '10+ km'},
];

/// Sample locations
const List<Map<String, String>> locations = [
  {'value': 'delhi', 'label': 'Delhi'},
  {'value': 'mumbai', 'label': 'Mumbai'},
  {'value': 'bangalore', 'label': 'Bangalore'},
  {'value': 'hyderabad', 'label': 'Hyderabad'},
  {'value': 'chennai', 'label': 'Chennai'},
  {'value': 'pune', 'label': 'Pune'},
  {'value': 'kolkata', 'label': 'Kolkata'},
];

/// Housing filters bottom sheet widget
class HousingFiltersSheet extends StatefulWidget {
  final HousingFilters initialFilters;
  final ValueChanged<HousingFilters> onFiltersChanged;

  const HousingFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  /// Show the filters as a bottom sheet
  static Future<HousingFilters?> show(
    BuildContext context, {
    required HousingFilters initialFilters,
  }) {
    return showModalBottomSheet<HousingFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _HousingFiltersContent(
          initialFilters: initialFilters,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<HousingFiltersSheet> createState() => _HousingFiltersSheetState();
}

class _HousingFiltersSheetState extends State<HousingFiltersSheet> {
  late HousingFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return _HousingFiltersContent(
      initialFilters: _filters,
      scrollController: ScrollController(),
    );
  }
}

/// Internal content widget for housing filters
class _HousingFiltersContent extends StatefulWidget {
  final HousingFilters initialFilters;
  final ScrollController scrollController;

  const _HousingFiltersContent({
    required this.initialFilters,
    required this.scrollController,
  });

  @override
  State<_HousingFiltersContent> createState() => _HousingFiltersContentState();
}

class _HousingFiltersContentState extends State<_HousingFiltersContent> {
  late HousingFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilter(HousingFilters Function(HousingFilters) update) {
    setState(() {
      _filters = update(_filters);
    });
  }

  void _togglePropertyType(String typeId) {
    final current = List<String>.from(_filters.propertyType);
    if (current.contains(typeId)) {
      current.remove(typeId);
    } else {
      current.add(typeId);
    }
    _updateFilter((f) => f.copyWith(propertyType: current));
  }

  void _toggleAmenity(String amenityId) {
    final current = List<String>.from(_filters.amenities);
    if (current.contains(amenityId)) {
      current.remove(amenityId);
    } else {
      current.add(amenityId);
    }
    _updateFilter((f) => f.copyWith(amenities: current));
  }

  String _formatPrice(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Handle bar
        Container(
          margin: const EdgeInsets.only(top: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.home_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Housing Filters',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_filters.activeFilterCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_filters.activeFilterCount}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _filters = HousingFilters.empty;
                  });
                },
                child: Text(
                  'Reset',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Content
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Location Section
              _buildSectionHeader('Location', Icons.location_on_outlined),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      value: _filters.location,
                      hint: 'Select city',
                      items: locations,
                      onChanged: (value) =>
                          _updateFilter((f) => f.copyWith(location: value)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      value: _filters.distanceFromCampus,
                      hint: 'Distance',
                      items: distanceOptions,
                      onChanged: (value) => _updateFilter(
                          (f) => f.copyWith(distanceFromCampus: value)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Price Range Section
              _buildSectionHeader('Monthly Rent', Icons.currency_rupee),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. ${_formatPrice(_filters.priceRange.start)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Rs. ${_formatPrice(_filters.priceRange.end)}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
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
                  rangeThumbShape: const RoundRangeSliderThumbShape(
                    enabledThumbRadius: 10,
                  ),
                ),
                child: RangeSlider(
                  values: _filters.priceRange,
                  min: 0,
                  max: 50000,
                  divisions: 50,
                  onChanged: (values) =>
                      _updateFilter((f) => f.copyWith(priceRange: values)),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rs. 0',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  Text(
                    'Rs. 50,000+',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Property Type Section
              _buildSectionHeader('Property Type', Icons.apartment_outlined),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: propertyTypes.map((type) {
                  final isSelected = _filters.propertyType.contains(type.id);
                  return _FilterChip(
                    label: type.label,
                    icon: type.icon,
                    isSelected: isSelected,
                    onTap: () => _togglePropertyType(type.id),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Amenities Section
              _buildSectionHeader('Amenities', Icons.check_circle_outline),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenities.map((amenity) {
                  final isSelected = _filters.amenities.contains(amenity.id);
                  return _FilterChip(
                    label: amenity.label,
                    icon: amenity.icon,
                    isSelected: isSelected,
                    onTap: () => _toggleAmenity(amenity.id),
                  );
                }).toList(),
              ),

              const SizedBox(height: 100), // Space for bottom buttons
            ],
          ),
        ),

        // Bottom buttons
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, _filters),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBrown,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Apply',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_filters.activeFilterCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_filters.activeFilterCount}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<Map<String, String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withAlpha(50)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item['value'],
              child: Text(
                item['label']!,
                style: AppTextStyles.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.darkBrown : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'event_filters.dart';
import 'housing_filters.dart';
import 'resource_filters.dart';

/// Filter tab types
enum FilterTab {
  housing('Housing', Icons.home_outlined),
  events('Events', Icons.event_outlined),
  resources('Resources', Icons.menu_book_outlined);

  final String label;
  final IconData icon;

  const FilterTab(this.label, this.icon);
}

/// Combined filter state for Campus Connect
class CampusConnectFilters {
  final HousingFilters housing;
  final EventFilters events;
  final ResourceFilters resources;

  const CampusConnectFilters({
    this.housing = const HousingFilters(),
    this.events = const EventFilters(),
    this.resources = const ResourceFilters(),
  });

  CampusConnectFilters copyWith({
    HousingFilters? housing,
    EventFilters? events,
    ResourceFilters? resources,
  }) {
    return CampusConnectFilters(
      housing: housing ?? this.housing,
      events: events ?? this.events,
      resources: resources ?? this.resources,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      housing.hasActiveFilters ||
      events.hasActiveFilters ||
      resources.hasActiveFilters;

  /// Count total active filters across all categories
  int get totalActiveFilterCount =>
      housing.activeFilterCount +
      events.activeFilterCount +
      resources.activeFilterCount;

  /// Reset to defaults
  static const CampusConnectFilters empty = CampusConnectFilters();
}

/// Unified filter sheet for Campus Connect.
///
/// Features tabbed interface for Housing, Events, and Resources filters.
/// Matches the web app's FilterSheet component design.
class CampusConnectFilterSheet extends StatefulWidget {
  final CampusConnectFilters initialFilters;
  final FilterTab? initialTab;

  const CampusConnectFilterSheet({
    super.key,
    required this.initialFilters,
    this.initialTab,
  });

  /// Show the filters as a draggable bottom sheet
  static Future<CampusConnectFilters?> show(
    BuildContext context, {
    required CampusConnectFilters initialFilters,
    FilterTab? initialTab,
  }) {
    return showModalBottomSheet<CampusConnectFilters>(
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
        builder: (context, scrollController) => _FilterSheetContent(
          initialFilters: initialFilters,
          initialTab: initialTab,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<CampusConnectFilterSheet> createState() =>
      _CampusConnectFilterSheetState();
}

class _CampusConnectFilterSheetState extends State<CampusConnectFilterSheet> {
  late CampusConnectFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return _FilterSheetContent(
      initialFilters: _filters,
      initialTab: widget.initialTab,
      scrollController: ScrollController(),
    );
  }
}

/// Internal content widget for the filter sheet
class _FilterSheetContent extends StatefulWidget {
  final CampusConnectFilters initialFilters;
  final FilterTab? initialTab;
  final ScrollController scrollController;

  const _FilterSheetContent({
    required this.initialFilters,
    this.initialTab,
    required this.scrollController,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent>
    with SingleTickerProviderStateMixin {
  late CampusConnectFilters _filters;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _tabController = TabController(
      length: FilterTab.values.length,
      vsync: this,
      initialIndex: widget.initialTab?.index ?? 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateHousingFilters(HousingFilters housing) {
    setState(() {
      _filters = _filters.copyWith(housing: housing);
    });
  }

  void _updateEventFilters(EventFilters events) {
    setState(() {
      _filters = _filters.copyWith(events: events);
    });
  }

  void _updateResourceFilters(ResourceFilters resources) {
    setState(() {
      _filters = _filters.copyWith(resources: resources);
    });
  }

  void _resetFilters() {
    setState(() {
      _filters = CampusConnectFilters.empty;
    });
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
                  const Icon(Icons.filter_list_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Filters',
                    style: AppTextStyles.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_filters.totalActiveFilterCount > 0) ...[
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
                        '${_filters.totalActiveFilterCount} active',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppColors.darkBrown,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorPadding: const EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            dividerColor: Colors.transparent,
            tabs: FilterTab.values.map((tab) {
              return Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tab.icon, size: 18),
                    const SizedBox(width: 6),
                    Text(tab.label),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const Divider(height: 24),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Housing tab
              _HousingFilterPanel(
                filters: _filters.housing,
                onFiltersChanged: _updateHousingFilters,
                scrollController: widget.scrollController,
              ),
              // Events tab
              _EventFilterPanel(
                filters: _filters.events,
                onFiltersChanged: _updateEventFilters,
                scrollController: widget.scrollController,
              ),
              // Resources tab
              _ResourceFilterPanel(
                filters: _filters.resources,
                onFiltersChanged: _updateResourceFilters,
                scrollController: widget.scrollController,
              ),
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
                      if (_filters.totalActiveFilterCount > 0) ...[
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
                            '${_filters.totalActiveFilterCount}',
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
}

/// Housing filter panel content
class _HousingFilterPanel extends StatelessWidget {
  final HousingFilters filters;
  final ValueChanged<HousingFilters> onFiltersChanged;
  final ScrollController scrollController;

  const _HousingFilterPanel({
    required this.filters,
    required this.onFiltersChanged,
    required this.scrollController,
  });

  void _togglePropertyType(String typeId) {
    final current = List<String>.from(filters.propertyType);
    if (current.contains(typeId)) {
      current.remove(typeId);
    } else {
      current.add(typeId);
    }
    onFiltersChanged(filters.copyWith(propertyType: current));
  }

  void _toggleAmenity(String amenityId) {
    final current = List<String>.from(filters.amenities);
    if (current.contains(amenityId)) {
      current.remove(amenityId);
    } else {
      current.add(amenityId);
    }
    onFiltersChanged(filters.copyWith(amenities: current));
  }

  String _formatPrice(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Location Section
        _buildSectionHeader('Location', Icons.location_on_outlined),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: filters.location,
                hint: 'Select city',
                items: locations,
                onChanged: (value) =>
                    onFiltersChanged(filters.copyWith(location: value)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: filters.distanceFromCampus,
                hint: 'Distance',
                items: distanceOptions,
                onChanged: (value) =>
                    onFiltersChanged(filters.copyWith(distanceFromCampus: value)),
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
              'Rs. ${_formatPrice(filters.priceRange.start)}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              'Rs. ${_formatPrice(filters.priceRange.end)}',
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
            values: filters.priceRange,
            min: 0,
            max: 50000,
            divisions: 50,
            onChanged: (values) =>
                onFiltersChanged(filters.copyWith(priceRange: values)),
          ),
        ),

        const SizedBox(height: 24),

        // Property Type Section
        _buildSectionHeader('Property Type', Icons.apartment_outlined),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: propertyTypes.map((type) {
            final isSelected = filters.propertyType.contains(type.id);
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
            final isSelected = filters.amenities.contains(amenity.id);
            return _FilterChip(
              label: amenity.label,
              icon: amenity.icon,
              isSelected: isSelected,
              onTap: () => _toggleAmenity(amenity.id),
            );
          }).toList(),
        ),

        const SizedBox(height: 100),
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

/// Event filter panel content
class _EventFilterPanel extends StatelessWidget {
  final EventFilters filters;
  final ValueChanged<EventFilters> onFiltersChanged;
  final ScrollController scrollController;

  const _EventFilterPanel({
    required this.filters,
    required this.onFiltersChanged,
    required this.scrollController,
  });

  void _toggleEventType(String typeId) {
    final current = List<String>.from(filters.eventType);
    if (current.contains(typeId)) {
      current.remove(typeId);
    } else {
      current.add(typeId);
    }
    onFiltersChanged(filters.copyWith(eventType: current));
  }

  void _handleDatePreset(DatePreset preset) {
    onFiltersChanged(EventFilters(
      eventType: filters.eventType,
      dateFrom: preset.getFrom(),
      dateTo: preset.getTo(),
      location: filters.location,
      isFree: filters.isFree,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Event Type Section
        _buildSectionHeader('Event Type', Icons.category_outlined),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: eventTypes.map((type) {
            final isSelected = filters.eventType.contains(type.id);
            return _EventTypeChip(
              label: type.label,
              icon: type.icon,
              color: type.color,
              isSelected: isSelected,
              onTap: () => _toggleEventType(type.id),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Date Range Section
        _buildSectionHeader('When', Icons.calendar_today_outlined),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: datePresets.map((preset) {
            return _DatePresetChip(
              label: preset.label,
              isSelected: false, // We'd need to track selected preset
              onTap: () => _handleDatePreset(preset),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Location Section
        _buildSectionHeader('Location', Icons.location_on_outlined),
        const SizedBox(height: 12),
        _buildDropdown(
          value: filters.location,
          hint: 'Any location',
          items: locationOptions,
          onChanged: (value) =>
              onFiltersChanged(filters.copyWith(location: value)),
        ),

        const SizedBox(height: 24),

        // Free/Paid Section
        _buildSectionHeader('Entry', Icons.currency_rupee),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _EntryToggleButton(
                label: 'Free',
                icon: Icons.check_circle_outline,
                isSelected: filters.isFree == true,
                color: AppColors.success,
                onTap: () => onFiltersChanged(filters.copyWith(
                  isFree: filters.isFree == true ? null : true,
                )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EntryToggleButton(
                label: 'Paid',
                icon: Icons.paid_outlined,
                isSelected: filters.isFree == false,
                color: AppColors.darkBrown,
                onTap: () => onFiltersChanged(filters.copyWith(
                  isFree: filters.isFree == false ? null : false,
                )),
              ),
            ),
          ],
        ),

        const SizedBox(height: 100),
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

/// Resource filter panel content
class _ResourceFilterPanel extends StatelessWidget {
  final ResourceFilters filters;
  final ValueChanged<ResourceFilters> onFiltersChanged;
  final ScrollController scrollController;

  const _ResourceFilterPanel({
    required this.filters,
    required this.onFiltersChanged,
    required this.scrollController,
  });

  void _toggleSubject(String subjectId) {
    final current = List<String>.from(filters.subject);
    if (current.contains(subjectId)) {
      current.remove(subjectId);
    } else {
      current.add(subjectId);
    }
    onFiltersChanged(filters.copyWith(subject: current));
  }

  void _toggleResourceType(String typeId) {
    final current = List<String>.from(filters.resourceType);
    if (current.contains(typeId)) {
      current.remove(typeId);
    } else {
      current.add(typeId);
    }
    onFiltersChanged(filters.copyWith(resourceType: current));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        // Subject Section
        _buildSectionHeader('Subject', Icons.school_outlined),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subjects.map((subject) {
            final isSelected = filters.subject.contains(subject.id);
            return _FilterChip(
              label: subject.label,
              icon: subject.icon,
              isSelected: isSelected,
              onTap: () => _toggleSubject(subject.id),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Resource Type Section
        _buildSectionHeader('Resource Type', Icons.folder_outlined),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemCount: resourceTypes.length,
          itemBuilder: (context, index) {
            final type = resourceTypes[index];
            final isSelected = filters.resourceType.contains(type.id);
            return _ResourceTypeCard(
              type: type,
              isSelected: isSelected,
              onTap: () => _toggleResourceType(type.id),
            );
          },
        ),

        const SizedBox(height: 24),

        // Difficulty Level Section
        _buildSectionHeader('Difficulty Level', Icons.speed_outlined),
        const SizedBox(height: 12),
        Row(
          children: difficultyLevels.map((level) {
            final isSelected = filters.difficulty == level.id;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: level.id != difficultyLevels.last.id ? 8 : 0,
                ),
                child: _DifficultyButton(
                  level: level,
                  isSelected: isSelected,
                  onTap: () => onFiltersChanged(filters.copyWith(
                    difficulty: filters.difficulty == level.id ? null : level.id,
                  )),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Rating Section
        _buildSectionHeader('Minimum Rating', Icons.star_outline),
        const SizedBox(height: 12),
        Row(
          children: ratingOptions.map((option) {
            final isSelected = filters.minRating == option['value'];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: option != ratingOptions.last ? 8 : 0,
                ),
                child: _RatingButton(
                  value: option['value'] as int,
                  label: option['label'] as String,
                  isSelected: isSelected,
                  onTap: () => onFiltersChanged(filters.copyWith(
                    minRating: filters.minRating == option['value']
                        ? null
                        : option['value'] as int,
                  )),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 100),
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
}

// ============================================================================
// SHARED WIDGET COMPONENTS
// ============================================================================

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

/// Event type chip with color
class _EventTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _EventTypeChip({
    required this.label,
    required this.icon,
    required this.color,
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
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
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

/// Date preset chip
class _DatePresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DatePresetChip({
    required this.label,
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
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Entry toggle button (Free/Paid)
class _EntryToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _EntryToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resource type card widget
class _ResourceTypeCard extends StatelessWidget {
  final ResourceTypeOption type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ResourceTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkBrown : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  type.icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type.label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              type.description,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? Colors.white.withAlpha(180)
                    : AppColors.textTertiary,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Difficulty button widget
class _DifficultyButton extends StatelessWidget {
  final DifficultyOption level;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkBrown : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : level.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              level.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rating button widget
class _RatingButton extends StatelessWidget {
  final int value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RatingButton({
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.darkBrown : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFFF59E0B),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

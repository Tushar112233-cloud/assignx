import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Event filter state model
class EventFilters {
  final List<String> eventType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? location;
  final bool? isFree;

  const EventFilters({
    this.eventType = const [],
    this.dateFrom,
    this.dateTo,
    this.location,
    this.isFree,
  });

  EventFilters copyWith({
    List<String>? eventType,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? location,
    bool? isFree,
  }) {
    return EventFilters(
      eventType: eventType ?? this.eventType,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      location: location ?? this.location,
      isFree: isFree ?? this.isFree,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      eventType.isNotEmpty ||
      dateFrom != null ||
      dateTo != null ||
      location != null ||
      isFree != null;

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    count += eventType.length;
    if (dateFrom != null) count++;
    if (location != null) count++;
    if (isFree != null) count++;
    return count;
  }

  /// Reset to defaults
  static const EventFilters empty = EventFilters();
}

/// Event type configuration
class EventTypeOption {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const EventTypeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

/// Available event types
const List<EventTypeOption> eventTypes = [
  EventTypeOption(
    id: 'academic',
    label: 'Academic',
    icon: Icons.school_outlined,
    color: Color(0xFF2196F3),
  ),
  EventTypeOption(
    id: 'social',
    label: 'Social',
    icon: Icons.people_outline,
    color: Color(0xFFE91E63),
  ),
  EventTypeOption(
    id: 'career',
    label: 'Career',
    icon: Icons.work_outline,
    color: Color(0xFF9C27B0),
  ),
  EventTypeOption(
    id: 'sports',
    label: 'Sports',
    icon: Icons.sports_soccer_outlined,
    color: Color(0xFF4CAF50),
  ),
  EventTypeOption(
    id: 'cultural',
    label: 'Cultural',
    icon: Icons.music_note_outlined,
    color: Color(0xFFFF9800),
  ),
  EventTypeOption(
    id: 'workshop',
    label: 'Workshop',
    icon: Icons.build_outlined,
    color: Color(0xFF3F51B5),
  ),
  EventTypeOption(
    id: 'fest',
    label: 'Fest',
    icon: Icons.celebration_outlined,
    color: Color(0xFFF44336),
  ),
  EventTypeOption(
    id: 'seminar',
    label: 'Seminar',
    icon: Icons.mic_outlined,
    color: Color(0xFF00BCD4),
  ),
  EventTypeOption(
    id: 'networking',
    label: 'Networking',
    icon: Icons.handshake_outlined,
    color: Color(0xFF795548),
  ),
];

/// Date range presets
class DatePreset {
  final String id;
  final String label;
  final DateTime Function() getFrom;
  final DateTime Function() getTo;

  const DatePreset({
    required this.id,
    required this.label,
    required this.getFrom,
    required this.getTo,
  });
}

final List<DatePreset> datePresets = [
  DatePreset(
    id: 'today',
    label: 'Today',
    getFrom: () => DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
    getTo: () => DateTime.now().copyWith(hour: 23, minute: 59, second: 59),
  ),
  DatePreset(
    id: 'tomorrow',
    label: 'Tomorrow',
    getFrom: () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.copyWith(hour: 0, minute: 0, second: 0);
    },
    getTo: () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return tomorrow.copyWith(hour: 23, minute: 59, second: 59);
    },
  ),
  DatePreset(
    id: 'this-week',
    label: 'This Week',
    getFrom: () {
      final now = DateTime.now();
      return now.subtract(Duration(days: now.weekday - 1));
    },
    getTo: () {
      final now = DateTime.now();
      return now.add(Duration(days: 7 - now.weekday));
    },
  ),
  DatePreset(
    id: 'this-weekend',
    label: 'This Weekend',
    getFrom: () {
      final now = DateTime.now();
      final daysUntilSaturday = (6 - now.weekday + 7) % 7;
      return now.add(Duration(days: daysUntilSaturday));
    },
    getTo: () {
      final now = DateTime.now();
      final daysUntilSunday = (7 - now.weekday) % 7;
      return now.add(Duration(days: daysUntilSunday));
    },
  ),
  DatePreset(
    id: 'next-week',
    label: 'Next Week',
    getFrom: () {
      final now = DateTime.now();
      return now.add(Duration(days: 7 - now.weekday + 1));
    },
    getTo: () {
      final now = DateTime.now();
      return now.add(Duration(days: 14 - now.weekday));
    },
  ),
  DatePreset(
    id: 'this-month',
    label: 'This Month',
    getFrom: () => DateTime(DateTime.now().year, DateTime.now().month, 1),
    getTo: () => DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
  ),
];

/// Location options
const List<Map<String, String>> locationOptions = [
  {'value': 'on-campus', 'label': 'On Campus'},
  {'value': 'off-campus', 'label': 'Off Campus'},
  {'value': 'online', 'label': 'Online/Virtual'},
  {'value': 'hybrid', 'label': 'Hybrid'},
];

/// Event filters bottom sheet widget
class EventFiltersSheet extends StatefulWidget {
  final EventFilters initialFilters;
  final ValueChanged<EventFilters> onFiltersChanged;

  const EventFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  /// Show the filters as a bottom sheet
  static Future<EventFilters?> show(
    BuildContext context, {
    required EventFilters initialFilters,
  }) {
    return showModalBottomSheet<EventFilters>(
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
        builder: (context, scrollController) => _EventFiltersContent(
          initialFilters: initialFilters,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<EventFiltersSheet> createState() => _EventFiltersSheetState();
}

class _EventFiltersSheetState extends State<EventFiltersSheet> {
  late EventFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return _EventFiltersContent(
      initialFilters: _filters,
      scrollController: ScrollController(),
    );
  }
}

/// Internal content widget for event filters
class _EventFiltersContent extends StatefulWidget {
  final EventFilters initialFilters;
  final ScrollController scrollController;

  const _EventFiltersContent({
    required this.initialFilters,
    required this.scrollController,
  });

  @override
  State<_EventFiltersContent> createState() => _EventFiltersContentState();
}

class _EventFiltersContentState extends State<_EventFiltersContent> {
  late EventFilters _filters;
  String? _selectedDatePreset;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilter(EventFilters Function(EventFilters) update) {
    setState(() {
      _filters = update(_filters);
    });
  }

  void _toggleEventType(String typeId) {
    final current = List<String>.from(_filters.eventType);
    if (current.contains(typeId)) {
      current.remove(typeId);
    } else {
      current.add(typeId);
    }
    _updateFilter((f) => f.copyWith(eventType: current));
  }

  void _handleDatePreset(DatePreset preset) {
    setState(() {
      _selectedDatePreset = preset.id;
    });
    _updateFilter((f) => EventFilters(
          eventType: f.eventType,
          dateFrom: preset.getFrom(),
          dateTo: preset.getTo(),
          location: f.location,
          isFree: f.isFree,
        ));
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
                  const Icon(Icons.event_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Event Filters',
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
                    _filters = EventFilters.empty;
                    _selectedDatePreset = null;
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
              // Event Type Section
              _buildSectionHeader('Event Type', Icons.category_outlined),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: eventTypes.map((type) {
                  final isSelected = _filters.eventType.contains(type.id);
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
                  final isSelected = _selectedDatePreset == preset.id;
                  return _FilterChip(
                    label: preset.label,
                    isSelected: isSelected,
                    onTap: () => _handleDatePreset(preset),
                  );
                }).toList(),
              ),
              if (_filters.dateFrom != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${_formatDate(_filters.dateFrom!)} - ${_formatDate(_filters.dateTo ?? _filters.dateFrom!)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Location Section
              _buildSectionHeader('Location', Icons.location_on_outlined),
              const SizedBox(height: 12),
              _buildDropdown(
                value: _filters.location,
                hint: 'Any location',
                items: locationOptions,
                onChanged: (value) =>
                    _updateFilter((f) => f.copyWith(location: value)),
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
                      isSelected: _filters.isFree == true,
                      color: AppColors.success,
                      onTap: () => _updateFilter((f) => f.copyWith(
                            isFree: f.isFree == true ? null : true,
                          )),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _EntryToggleButton(
                      label: 'Paid',
                      icon: Icons.paid_outlined,
                      isSelected: _filters.isFree == false,
                      color: AppColors.darkBrown,
                      onTap: () => _updateFilter((f) => f.copyWith(
                            isFree: f.isFree == false ? null : false,
                          )),
                    ),
                  ),
                ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

/// Generic filter chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
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

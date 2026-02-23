import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/auth_provider.dart';

/// College filter mode for Campus Connect.
enum CollegeFilterMode {
  /// Show posts from all colleges.
  all('All Colleges', Icons.public),

  /// Show posts only from user's college.
  myCollege('My College Only', Icons.school),

  /// Show posts from a specific college.
  specific('Specific College', Icons.location_city);

  /// Display label for the filter mode.
  final String label;

  /// Icon for the filter mode.
  final IconData icon;

  const CollegeFilterMode(this.label, this.icon);
}

/// Key used to store college filter preference in SharedPreferences.
const String _collegeFilterKey = 'college_filter_mode';
const String _specificCollegeKey = 'college_filter_specific';

/// Provider for college filter state.
final collegeFilterProvider =
    StateNotifierProvider<CollegeFilterNotifier, CollegeFilterState>((ref) {
  return CollegeFilterNotifier(ref);
});

/// State class for college filter.
class CollegeFilterState {
  /// Current filter mode.
  final CollegeFilterMode mode;

  /// Selected specific college (when mode is [CollegeFilterMode.specific]).
  final String? specificCollege;

  /// User's own college name (from profile).
  final String? userCollege;

  /// List of available colleges for selection.
  final List<String> availableColleges;

  const CollegeFilterState({
    this.mode = CollegeFilterMode.all,
    this.specificCollege,
    this.userCollege,
    this.availableColleges = const [],
  });

  /// Get the college name to filter by (null means no filter).
  String? get filterCollege {
    switch (mode) {
      case CollegeFilterMode.all:
        return null;
      case CollegeFilterMode.myCollege:
        return userCollege;
      case CollegeFilterMode.specific:
        return specificCollege;
    }
  }

  /// Get display text for current filter.
  String get displayText {
    switch (mode) {
      case CollegeFilterMode.all:
        return 'All Colleges';
      case CollegeFilterMode.myCollege:
        return userCollege ?? 'My College';
      case CollegeFilterMode.specific:
        return specificCollege ?? 'Select College';
    }
  }

  /// Check if any filter is active.
  bool get hasActiveFilter => mode != CollegeFilterMode.all;

  CollegeFilterState copyWith({
    CollegeFilterMode? mode,
    String? specificCollege,
    String? userCollege,
    List<String>? availableColleges,
  }) {
    return CollegeFilterState(
      mode: mode ?? this.mode,
      specificCollege: specificCollege ?? this.specificCollege,
      userCollege: userCollege ?? this.userCollege,
      availableColleges: availableColleges ?? this.availableColleges,
    );
  }
}

/// Notifier for college filter state.
class CollegeFilterNotifier extends StateNotifier<CollegeFilterState> {
  final Ref _ref;

  CollegeFilterNotifier(this._ref) : super(const CollegeFilterState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Load saved preference
    await _loadPreference();

    // Get user's college from profile
    _loadUserCollege();

    // Load available colleges (mock data for now)
    _loadAvailableColleges();
  }

  Future<void> _loadPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(_collegeFilterKey) ?? 0;
    final specificCollege = prefs.getString(_specificCollegeKey);

    state = state.copyWith(
      mode: CollegeFilterMode.values[modeIndex.clamp(0, CollegeFilterMode.values.length - 1)],
      specificCollege: specificCollege,
    );
  }

  void _loadUserCollege() {
    // Watch auth state to get user's college
    final authState = _ref.read(authStateProvider);
    final profile = authState.valueOrNull?.profile;

    // In a real app, you'd get this from StudentData via a join
    // For now, we'll use city as a proxy or set a default
    String? userCollege;
    if (profile != null) {
      // Try to get university name from student data if available
      // This would come from a joined query in production
      userCollege = profile.city != null
          ? '${profile.city} University'
          : 'Your University';
    }

    state = state.copyWith(userCollege: userCollege);
  }

  void _loadAvailableColleges() {
    // Mock data - in production, this would come from API
    state = state.copyWith(
      availableColleges: [
        'IIT Delhi',
        'IIT Bombay',
        'IIT Madras',
        'IIT Kanpur',
        'NIT Trichy',
        'NIT Warangal',
        'BITS Pilani',
        'VIT Vellore',
        'SRM Chennai',
        'Manipal University',
        'Delhi University',
        'Mumbai University',
        'Pune University',
        'Anna University',
        'Jadavpur University',
      ],
    );
  }

  /// Set the filter mode.
  Future<void> setMode(CollegeFilterMode mode) async {
    state = state.copyWith(mode: mode);
    await _savePreference();
  }

  /// Set a specific college to filter by.
  Future<void> setSpecificCollege(String college) async {
    state = state.copyWith(
      mode: CollegeFilterMode.specific,
      specificCollege: college,
    );
    await _savePreference();
  }

  /// Clear the filter (set to all).
  Future<void> clearFilter() async {
    state = state.copyWith(mode: CollegeFilterMode.all);
    await _savePreference();
  }

  Future<void> _savePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_collegeFilterKey, state.mode.index);
    if (state.specificCollege != null) {
      await prefs.setString(_specificCollegeKey, state.specificCollege!);
    }
  }

  /// Update user's college (call when student data is loaded).
  void updateUserCollege(String? college) {
    state = state.copyWith(userCollege: college);
  }
}

/// College filter chip widget for Campus Connect filter bar.
///
/// Shows current filter state and opens a bottom sheet for selection.
class CollegeFilterChip extends ConsumerWidget {
  /// Callback when filter changes.
  final VoidCallback? onFilterChanged;

  const CollegeFilterChip({
    super.key,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(collegeFilterProvider);
    final hasFilter = filterState.hasActiveFilter;

    return GestureDetector(
      onTap: () => _showCollegeFilterSheet(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasFilter ? AppColors.darkBrown : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: hasFilter
              ? null
              : Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 16,
              color: hasFilter ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 100),
              child: Text(
                filterState.displayText,
                style: AppTextStyles.labelMedium.copyWith(
                  color: hasFilter ? Colors.white : const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: hasFilter ? Colors.white : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCollegeFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => _CollegeFilterBottomSheet(
        onFilterChanged: onFilterChanged,
      ),
    );
  }
}

/// Bottom sheet for college filter selection.
class _CollegeFilterBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onFilterChanged;

  const _CollegeFilterBottomSheet({this.onFilterChanged});

  @override
  ConsumerState<_CollegeFilterBottomSheet> createState() =>
      _CollegeFilterBottomSheetState();
}

class _CollegeFilterBottomSheetState
    extends ConsumerState<_CollegeFilterBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(collegeFilterProvider);
    final notifier = ref.read(collegeFilterProvider.notifier);

    // Filter colleges based on search
    final filteredColleges = filterState.availableColleges
        .where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
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
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'Filter by College',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (filterState.hasActiveFilter)
                  TextButton(
                    onPressed: () {
                      notifier.clearFilter();
                      widget.onFilterChanged?.call();
                    },
                    child: Text(
                      'Clear',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quick filter options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // All Colleges option
                _FilterOptionTile(
                  icon: Icons.public,
                  title: 'All Colleges',
                  subtitle: 'Show posts from everyone',
                  isSelected: filterState.mode == CollegeFilterMode.all,
                  onTap: () {
                    notifier.setMode(CollegeFilterMode.all);
                    widget.onFilterChanged?.call();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 8),

                // My College option
                if (filterState.userCollege != null)
                  _FilterOptionTile(
                    icon: Icons.school,
                    title: 'My College Only',
                    subtitle: filterState.userCollege!,
                    isSelected: filterState.mode == CollegeFilterMode.myCollege,
                    onTap: () {
                      notifier.setMode(CollegeFilterMode.myCollege);
                      widget.onFilterChanged?.call();
                      Navigator.pop(context);
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Divider with label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Or select specific college',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search colleges...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[500],
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // College list
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredColleges.length,
              itemBuilder: (context, index) {
                final college = filteredColleges[index];
                final isSelected = filterState.mode == CollegeFilterMode.specific &&
                    filterState.specificCollege == college;

                return _CollegeListTile(
                  name: college,
                  isSelected: isSelected,
                  onTap: () {
                    notifier.setSpecificCollege(college);
                    widget.onFilterChanged?.call();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter option tile widget.
class _FilterOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.darkBrown.withValues(alpha: 0.08) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.darkBrown : const Color(0xFFE0E0E0),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.darkBrown
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.darkBrown : const Color(0xFF1A1A1A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.darkBrown,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// College list tile widget.
class _CollegeListTile extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CollegeListTile({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_city_outlined,
                size: 20,
                color: isSelected ? AppColors.darkBrown : Colors.grey[500],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.darkBrown : const Color(0xFF1A1A1A),
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check,
                  color: AppColors.darkBrown,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

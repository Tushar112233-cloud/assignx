import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Resource filter state model
class ResourceFilters {
  final List<String> subject;
  final List<String> resourceType;
  final String? difficulty;
  final int? minRating;

  const ResourceFilters({
    this.subject = const [],
    this.resourceType = const [],
    this.difficulty,
    this.minRating,
  });

  ResourceFilters copyWith({
    List<String>? subject,
    List<String>? resourceType,
    String? difficulty,
    int? minRating,
  }) {
    return ResourceFilters(
      subject: subject ?? this.subject,
      resourceType: resourceType ?? this.resourceType,
      difficulty: difficulty ?? this.difficulty,
      minRating: minRating ?? this.minRating,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      subject.isNotEmpty ||
      resourceType.isNotEmpty ||
      difficulty != null ||
      minRating != null;

  /// Count active filters
  int get activeFilterCount {
    int count = 0;
    count += subject.length;
    count += resourceType.length;
    if (difficulty != null) count++;
    if (minRating != null) count++;
    return count;
  }

  /// Reset to defaults
  static const ResourceFilters empty = ResourceFilters();
}

/// Subject configuration
class SubjectOption {
  final String id;
  final String label;
  final IconData icon;

  const SubjectOption({
    required this.id,
    required this.label,
    required this.icon,
  });
}

/// Resource type configuration
class ResourceTypeOption {
  final String id;
  final String label;
  final IconData icon;
  final String description;

  const ResourceTypeOption({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
  });
}

/// Difficulty level configuration
class DifficultyOption {
  final String id;
  final String label;
  final Color color;

  const DifficultyOption({
    required this.id,
    required this.label,
    required this.color,
  });
}

/// Available subjects
const List<SubjectOption> subjects = [
  SubjectOption(id: 'mathematics', label: 'Mathematics', icon: Icons.calculate),
  SubjectOption(id: 'physics', label: 'Physics', icon: Icons.science),
  SubjectOption(id: 'chemistry', label: 'Chemistry', icon: Icons.biotech),
  SubjectOption(id: 'biology', label: 'Biology', icon: Icons.local_hospital),
  SubjectOption(id: 'computer-science', label: 'Computer Science', icon: Icons.code),
  SubjectOption(id: 'english', label: 'English', icon: Icons.translate),
  SubjectOption(id: 'economics', label: 'Economics', icon: Icons.trending_up),
  SubjectOption(id: 'history', label: 'History', icon: Icons.history_edu),
  SubjectOption(id: 'law', label: 'Law', icon: Icons.gavel),
  SubjectOption(id: 'arts', label: 'Arts & Design', icon: Icons.palette),
  SubjectOption(id: 'music', label: 'Music', icon: Icons.music_note),
  SubjectOption(id: 'engineering', label: 'Engineering', icon: Icons.engineering),
];

/// Available resource types
const List<ResourceTypeOption> resourceTypes = [
  ResourceTypeOption(
    id: 'notes',
    label: 'Notes',
    icon: Icons.description_outlined,
    description: 'Class notes & summaries',
  ),
  ResourceTypeOption(
    id: 'books',
    label: 'Books',
    icon: Icons.menu_book_outlined,
    description: 'Textbooks & references',
  ),
  ResourceTypeOption(
    id: 'tools',
    label: 'Tools',
    icon: Icons.build_outlined,
    description: 'Study tools & utilities',
  ),
  ResourceTypeOption(
    id: 'software',
    label: 'Software',
    icon: Icons.laptop_mac_outlined,
    description: 'Apps & programs',
  ),
  ResourceTypeOption(
    id: 'videos',
    label: 'Videos',
    icon: Icons.play_circle_outline,
    description: 'Video tutorials',
  ),
  ResourceTypeOption(
    id: 'papers',
    label: 'Papers',
    icon: Icons.article_outlined,
    description: 'Research papers',
  ),
  ResourceTypeOption(
    id: 'projects',
    label: 'Projects',
    icon: Icons.folder_outlined,
    description: 'Sample projects',
  ),
];

/// Difficulty levels
const List<DifficultyOption> difficultyLevels = [
  DifficultyOption(id: 'beginner', label: 'Beginner', color: Color(0xFF4CAF50)),
  DifficultyOption(id: 'intermediate', label: 'Intermediate', color: Color(0xFFF59E0B)),
  DifficultyOption(id: 'advanced', label: 'Advanced', color: Color(0xFFEF4444)),
];

/// Rating options
const List<Map<String, dynamic>> ratingOptions = [
  {'value': 4, 'label': '4+ Stars'},
  {'value': 3, 'label': '3+ Stars'},
  {'value': 2, 'label': '2+ Stars'},
];

/// Resource filters bottom sheet widget
class ResourceFiltersSheet extends StatefulWidget {
  final ResourceFilters initialFilters;
  final ValueChanged<ResourceFilters> onFiltersChanged;

  const ResourceFiltersSheet({
    super.key,
    required this.initialFilters,
    required this.onFiltersChanged,
  });

  /// Show the filters as a bottom sheet
  static Future<ResourceFilters?> show(
    BuildContext context, {
    required ResourceFilters initialFilters,
  }) {
    return showModalBottomSheet<ResourceFilters>(
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
        builder: (context, scrollController) => _ResourceFiltersContent(
          initialFilters: initialFilters,
          scrollController: scrollController,
        ),
      ),
    );
  }

  @override
  State<ResourceFiltersSheet> createState() => _ResourceFiltersSheetState();
}

class _ResourceFiltersSheetState extends State<ResourceFiltersSheet> {
  late ResourceFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  Widget build(BuildContext context) {
    return _ResourceFiltersContent(
      initialFilters: _filters,
      scrollController: ScrollController(),
    );
  }
}

/// Internal content widget for resource filters
class _ResourceFiltersContent extends StatefulWidget {
  final ResourceFilters initialFilters;
  final ScrollController scrollController;

  const _ResourceFiltersContent({
    required this.initialFilters,
    required this.scrollController,
  });

  @override
  State<_ResourceFiltersContent> createState() => _ResourceFiltersContentState();
}

class _ResourceFiltersContentState extends State<_ResourceFiltersContent> {
  late ResourceFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  void _updateFilter(ResourceFilters Function(ResourceFilters) update) {
    setState(() {
      _filters = update(_filters);
    });
  }

  void _toggleSubject(String subjectId) {
    final current = List<String>.from(_filters.subject);
    if (current.contains(subjectId)) {
      current.remove(subjectId);
    } else {
      current.add(subjectId);
    }
    _updateFilter((f) => f.copyWith(subject: current));
  }

  void _toggleResourceType(String typeId) {
    final current = List<String>.from(_filters.resourceType);
    if (current.contains(typeId)) {
      current.remove(typeId);
    } else {
      current.add(typeId);
    }
    _updateFilter((f) => f.copyWith(resourceType: current));
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
                  const Icon(Icons.menu_book_outlined, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Resource Filters',
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
                    _filters = ResourceFilters.empty;
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
              // Subject Section
              _buildSectionHeader('Subject', Icons.school_outlined),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects.map((subject) {
                  final isSelected = _filters.subject.contains(subject.id);
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
                  final isSelected = _filters.resourceType.contains(type.id);
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
                  final isSelected = _filters.difficulty == level.id;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: level.id != difficultyLevels.last.id ? 8 : 0,
                      ),
                      child: _DifficultyButton(
                        level: level,
                        isSelected: isSelected,
                        onTap: () => _updateFilter((f) => f.copyWith(
                              difficulty: f.difficulty == level.id ? null : level.id,
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
                  final isSelected = _filters.minRating == option['value'];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: option != ratingOptions.last ? 8 : 0,
                      ),
                      child: _RatingButton(
                        value: option['value'] as int,
                        label: option['label'] as String,
                        isSelected: isSelected,
                        onTap: () => _updateFilter((f) => f.copyWith(
                              minRating: f.minRating == option['value']
                                  ? null
                                  : option['value'] as int,
                            )),
                      ),
                    ),
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

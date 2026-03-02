import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Searchable dropdown for selecting project subject.
///
/// Displays a list of 10 subjects matching the web application.
/// Includes a search TextField to filter subjects by name.
class SubjectDropdown extends StatelessWidget {
  final ProjectSubject? value;
  final ValueChanged<ProjectSubject?> onChanged;
  final String? errorText;

  const SubjectDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subject',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showSearchableDropdown(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                if (value != null) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: value!.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      value!.icon,
                      size: 16,
                      color: value!.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value!.displayName,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Text(
                      'Select subject',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  /// Opens a bottom sheet with a searchable subject list.
  void _showSearchableDropdown(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SearchableSubjectSheet(
        selectedValue: value,
        onSelected: (subject) {
          onChanged(subject);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// Bottom sheet with search filtering for subjects.
class _SearchableSubjectSheet extends StatefulWidget {
  final ProjectSubject? selectedValue;
  final ValueChanged<ProjectSubject> onSelected;

  const _SearchableSubjectSheet({
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_SearchableSubjectSheet> createState() =>
      _SearchableSubjectSheetState();
}

class _SearchableSubjectSheetState extends State<_SearchableSubjectSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  /// All subjects available for selection.
  /// Includes the full ProjectSubject enum which covers all 10 web subjects:
  /// Engineering, Business, Medicine, Law, Natural Sciences (Physics/Chemistry/Biology),
  /// Mathematics, Humanities & Literature, Social Sciences, and Other.
  List<ProjectSubject> get _allSubjects => ProjectSubject.values;

  /// Filtered subjects based on search query.
  List<ProjectSubject> get _filteredSubjects {
    if (_searchQuery.isEmpty) return _allSubjects;
    final query = _searchQuery.toLowerCase();
    return _allSubjects
        .where(
          (s) => s.displayName.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Select Subject',
              style: AppTextStyles.headingSmall,
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search subjects...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
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
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Subject list
          Expanded(
            child: _filteredSubjects.isEmpty
                ? Center(
                    child: Text(
                      'No subjects found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: bottomPadding + AppSpacing.md,
                    ),
                    itemCount: _filteredSubjects.length,
                    itemBuilder: (context, index) {
                      final subject = _filteredSubjects[index];
                      final isSelected = widget.selectedValue == subject;

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: subject.color.withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            subject.icon,
                            size: 20,
                            color: subject.color,
                          ),
                        ),
                        title: Text(
                          subject.displayName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 22,
                              )
                            : null,
                        onTap: () => widget.onSelected(subject),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

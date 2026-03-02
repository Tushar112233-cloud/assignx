import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';

/// Available project types for the wizard.
enum ProjectType {
  assignment(
    'Assignment',
    'Academic work, essays, homework',
    Icons.school,
    Color(0xFF8B5CF6), // violet
  ),
  document(
    'Document',
    'Reports, thesis, papers',
    Icons.description,
    Color(0xFF3B82F6), // blue
  ),
  website(
    'Website',
    'Web development projects',
    Icons.language,
    Color(0xFF10B981), // emerald/green
  ),
  app(
    'App',
    'Mobile or web applications',
    Icons.phone_android,
    Color(0xFFF97316), // orange
  ),
  consultancy(
    'Consultancy',
    'Expert consultation',
    Icons.chat_bubble_outline,
    Color(0xFFEC4899), // pink
  ),
  turnitinCheck(
    'Turnitin Check',
    'AI detection & plagiarism reports',
    Icons.verified_user,
    Color(0xFF14B8A6), // teal
  );

  /// Display name for the project type.
  final String displayName;

  /// Short description of the project type.
  final String description;

  /// Icon representing the project type.
  final IconData icon;

  /// Theme color for the project type card.
  final Color color;

  const ProjectType(this.displayName, this.description, this.icon, this.color);
}

/// Premium selectable project type cards displayed in a 2-column grid.
///
/// Each card shows a colored icon, title, and subtitle. The selected card
/// displays a check mark and highlighted border with smooth animation.
class ProjectTypeSelector extends StatelessWidget {
  /// Currently selected project type.
  final ProjectType? selected;

  /// Callback when a project type is selected.
  final ValueChanged<ProjectType> onSelected;

  const ProjectTypeSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 12.0;
        final cardWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: ProjectType.values.map((type) {
            final isSelected = selected == type;
            return SizedBox(
              width: cardWidth,
              child: _ProjectTypeCard(
                type: type,
                isSelected: isSelected,
                onTap: () => onSelected(type),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// A single premium project type card with gradient icon area and selection state.
class _ProjectTypeCard extends StatelessWidget {
  final ProjectType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProjectTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? type.color.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? type.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.color.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container with gradient background
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        type.color.withValues(alpha: 0.15),
                        type.color.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    type.icon,
                    size: 22,
                    color: type.color,
                  ),
                ),
                // Check mark for selected state
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: type.color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              type.displayName.tr(context),
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? type.color : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              type.description.tr(context),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

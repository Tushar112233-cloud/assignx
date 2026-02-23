/// A section card widget with icon and title header.
///
/// This file provides a reusable card component for grouping related
/// content with a consistent header containing an icon and title.
///
/// ## Features
/// - Icon and title header
/// - Customizable colors and styling
/// - Optional trailing widget for actions
/// - Consistent elevation and border styling
///
/// ## Example
/// ```dart
/// SectionCard(
///   icon: Icons.person,
///   title: 'Personal Information',
///   trailing: IconButton(
///     icon: Icon(Icons.edit),
///     onPressed: () => editProfile(),
///   ),
///   child: Column(
///     children: [
///       Text('Name: John Doe'),
///       Text('Email: john@example.com'),
///     ],
///   ),
/// )
/// ```
///
/// See also:
/// - [AppCard] for general purpose cards
/// - [AppColors] for the color scheme
/// - [AppSpacing] for spacing constants
library;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

/// A styled card widget with an icon and title header.
///
/// Commonly used to group related content sections with a
/// descriptive header. The card provides consistent styling
/// with an optional trailing widget for actions.
///
/// ## Usage
/// ```dart
/// SectionCard(
///   icon: Icons.person,
///   title: 'Personal Information',
///   child: ProfileForm(),
/// )
/// ```
///
/// ## Customization
/// - [iconColor]: Changes both icon and title color
/// - [backgroundColor]: Card background color
/// - [borderSide]: Custom border styling
/// - [elevation]: Card shadow depth
/// - [trailing]: Widget displayed on the right side of the header
class SectionCard extends StatelessWidget {
  /// Creates a section card with the specified properties.
  ///
  /// [icon], [title], and [child] are required.
  const SectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.iconColor,
    this.backgroundColor,
    this.borderSide,
    this.elevation = 2,
    this.trailing,
  });

  /// The icon displayed in the header.
  final IconData icon;

  /// The title text displayed next to the icon.
  final String title;

  /// The main content widget of the card.
  final Widget child;

  /// Color for the icon and title text.
  ///
  /// Defaults to [AppColors.primary] for the icon and
  /// [AppColors.textPrimary] for the title.
  final Color? iconColor;

  /// Background color for the card.
  ///
  /// When null, uses the default Material Card color.
  final Color? backgroundColor;

  /// Border side for the card.
  ///
  /// When null, no border is displayed.
  final BorderSide? borderSide;

  /// Elevation (shadow depth) for the card.
  ///
  /// Defaults to 2.
  final double elevation;

  /// Optional widget displayed on the right side of the header.
  ///
  /// Typically an action button like edit or expand.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: borderSide ?? BorderSide.none,
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: iconColor ?? AppColors.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

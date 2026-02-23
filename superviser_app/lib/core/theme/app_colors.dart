/// Color palette for the Superviser App following the AdminX design system.
///
/// This file defines all colors used throughout the application, organized
/// into semantic categories for consistent usage across light and dark themes.
///
/// ## Design Philosophy
///
/// - **Primary (Dark Blue)**: Professional, authoritative, trustworthy
/// - **Secondary (Slate Grey)**: Neutral, sophisticated, balanced
/// - **Status Colors**: Intuitive feedback for user actions and states
///
/// ## Color Categories
///
/// - **Primary/Secondary**: Brand colors for key UI elements
/// - **Status Colors**: Success, warning, error, info indicators
/// - **Project Status**: Specific colors for project workflow states
/// - **Background/Surface**: Canvas and container colors
/// - **Text Colors**: Hierarchical text colors for readability
/// - **Border/Divider**: Subtle separation colors
/// - **Utility**: Overlays, shimmer effects, etc.
///
/// ## Usage
///
/// ```dart
/// // Direct usage
/// Container(color: AppColors.primary);
///
/// // Status-based color
/// final color = AppColors.getStatusColor('in_progress');
///
/// // Theme-aware (prefer this in widgets)
/// final primaryColor = Theme.of(context).colorScheme.primary;
/// ```
///
/// See also:
/// - [AppTheme] for complete theme configurations
/// - [AppTypography] for text styles
library;

import 'package:flutter/material.dart';

/// Defines the color palette for the AdminX design system.
///
/// This abstract class serves as a namespace for color constants.
/// Colors are organized into semantic groups and include variants
/// for both light and dark themes.
///
/// ## Naming Convention
///
/// - Base colors: `colorName` (e.g., `primary`, `success`)
/// - Light variants: `colorNameLight` (e.g., `primaryLight`)
/// - Dark variants: `colorNameDark` (e.g., `primaryDark`)
/// - Theme-specific: `colorNameLight/Dark` suffix (e.g., `backgroundLight`)
///
/// ## Example
///
/// ```dart
/// // Using primary color
/// Container(
///   decoration: BoxDecoration(
///     color: AppColors.primary,
///     borderRadius: BorderRadius.circular(8),
///   ),
/// );
///
/// // Using status color dynamically
/// Icon(
///   Icons.circle,
///   color: AppColors.getStatusColor(project.status),
/// );
/// ```
abstract class AppColors {
  // ============ Accent Color ============

  /// Accent color - Vibrant Orange.
  ///
  /// Use for CTAs, highlights, and brand emphasis.
  /// Matches web app's orange accent. Hex: #F97316
  static const accent = Color(0xFFF97316);

  /// Lighter variant of accent color.
  static const accentLight = Color(0xFFFB923C);

  /// Darker variant of accent color (hover state).
  static const accentDark = Color(0xFFEA580C);

  // ============ Primary Colors ============

  /// Primary brand color - Deep Charcoal.
  ///
  /// Use for primary actions, active states, and brand emphasis.
  /// Hex: #1C1C1C
  static const primary = Color(0xFF1C1C1C);

  /// Lighter variant of primary color.
  ///
  /// Use for hover states, backgrounds, and secondary emphasis.
  /// Hex: #2D3A4F
  static const primaryLight = Color(0xFF2D3A4F);

  /// Darker variant of primary color.
  ///
  /// Use for pressed states and high-contrast scenarios.
  /// Hex: #0F172A
  static const primaryDark = Color(0xFF0F172A);

  // ============ Secondary Colors ============

  /// Secondary color - Slate Grey.
  ///
  /// Use for secondary actions, less prominent UI elements.
  /// Hex: #64748B
  static const secondary = Color(0xFF64748B);

  /// Lighter variant of secondary color.
  ///
  /// Use for disabled states, subtle backgrounds.
  /// Hex: #94A3B8
  static const secondaryLight = Color(0xFF94A3B8);

  /// Darker variant of secondary color.
  ///
  /// Use for emphasized secondary elements.
  /// Hex: #475569
  static const secondaryDark = Color(0xFF475569);

  // ============ Status Colors ============

  /// Success color - Green.
  ///
  /// Use for success states, confirmations, positive actions.
  /// Hex: #22C55E
  static const success = Color(0xFF22C55E);

  /// Light success color for backgrounds.
  static const successLight = Color(0xFF4ADE80);

  /// Dark success color for emphasis.
  static const successDark = Color(0xFF16A34A);

  /// Warning color - Amber/Orange.
  ///
  /// Use for warnings, cautions, pending states.
  /// Hex: #F59E0B
  static const warning = Color(0xFFF59E0B);

  /// Light warning color for backgrounds.
  static const warningLight = Color(0xFFFBBF24);

  /// Dark warning color for emphasis.
  static const warningDark = Color(0xFFD97706);

  /// Error color - Red.
  ///
  /// Use for errors, destructive actions, critical alerts.
  /// Hex: #EF4444
  static const error = Color(0xFFEF4444);

  /// Light error color for backgrounds and dark theme.
  static const errorLight = Color(0xFFF87171);

  /// Dark error color for emphasis.
  static const errorDark = Color(0xFFDC2626);

  /// Info color - Blue.
  ///
  /// Use for informational messages, help text, links.
  /// Hex: #3B82F6
  static const info = Color(0xFF3B82F6);

  /// Light info color for backgrounds and dark theme.
  static const infoLight = Color(0xFF60A5FA);

  /// Dark info color for emphasis.
  static const infoDark = Color(0xFF2563EB);

  // ============ Project Status Colors ============

  /// Color for "analyzing" or "quoted" project status.
  ///
  /// Yellow/amber indicates work in preliminary stages.
  static const statusAnalyzing = Color(0xFFFBBF24);

  /// Color for "pending" or "payment_pending" project status.
  ///
  /// Orange indicates awaiting action.
  static const statusPending = Color(0xFFF97316);

  /// Color for "in_progress" or "assigned" project status.
  ///
  /// Blue indicates active work.
  static const statusInProgress = Color(0xFF3B82F6);

  /// Color for "for_review" or "submitted" project status.
  ///
  /// Green indicates ready for review.
  static const statusForReview = Color(0xFF22C55E);

  /// Color for "completed" or "delivered" project status.
  ///
  /// Grey indicates finished work.
  static const statusCompleted = Color(0xFF6B7280);

  /// Color for "urgent" or "revision" project status.
  ///
  /// Red indicates immediate attention required.
  static const statusUrgent = Color(0xFFEF4444);

  // ============ Background Colors (Light Theme) ============

  /// Main background color for light theme.
  ///
  /// Use for scaffold and page backgrounds.
  static const backgroundLight = Color(0xFFF8FAFC);

  /// Surface color for light theme.
  ///
  /// Use for cards, dialogs, and elevated surfaces.
  static const surfaceLight = Color(0xFFFFFFFF);

  /// Surface variant for light theme.
  ///
  /// Use for input fields, chips, and subtle containers.
  static const surfaceVariantLight = Color(0xFFF1F5F9);

  /// Card background color for light theme.
  static const cardLight = Color(0xFFFFFFFF);

  // ============ Background Colors (Dark Theme) ============

  /// Main background color for dark theme.
  ///
  /// Use for scaffold and page backgrounds.
  static const backgroundDark = Color(0xFF0F172A);

  /// Surface color for dark theme.
  ///
  /// Use for cards, dialogs, and elevated surfaces.
  static const surfaceDark = Color(0xFF1E293B);

  /// Surface variant for dark theme.
  ///
  /// Use for input fields, chips, and subtle containers.
  static const surfaceVariantDark = Color(0xFF334155);

  /// Card background color for dark theme.
  static const cardDark = Color(0xFF1E293B);

  // ============ Text Colors ============

  /// Primary text color for light theme.
  ///
  /// Use for headings, body text, important content.
  static const textPrimaryLight = Color(0xFF0F172A);

  /// Secondary text color for light theme.
  ///
  /// Use for descriptions, labels, less prominent text.
  static const textSecondaryLight = Color(0xFF475569);

  /// Tertiary text color for light theme.
  ///
  /// Use for hints, placeholders, disabled text.
  static const textTertiaryLight = Color(0xFF94A3B8);

  /// Disabled text color for light theme.
  static const textDisabledLight = Color(0xFFCBD5E1);

  /// Primary text color for dark theme.
  static const textPrimaryDark = Color(0xFFF8FAFC);

  /// Secondary text color for dark theme.
  static const textSecondaryDark = Color(0xFFCBD5E1);

  /// Tertiary text color for dark theme.
  static const textTertiaryDark = Color(0xFF94A3B8);

  /// Disabled text color for dark theme.
  static const textDisabledDark = Color(0xFF475569);

  // ============ Border Colors ============

  /// Border color for light theme.
  ///
  /// Use for card borders, input outlines, dividers.
  static const borderLight = Color(0xFFE2E8F0);

  /// Border color for dark theme.
  static const borderDark = Color(0xFF334155);

  // ============ Divider Colors ============

  /// Divider color for light theme.
  static const dividerLight = Color(0xFFE2E8F0);

  /// Divider color for dark theme.
  static const dividerDark = Color(0xFF334155);

  // ============ Overlay Colors ============

  /// Semi-transparent overlay for light theme modals.
  static const overlayLight = Color(0x80000000);

  /// Semi-transparent overlay for dark theme modals.
  static const overlayDark = Color(0x80000000);

  // ============ Shimmer Colors ============

  /// Base shimmer color for light theme loading states.
  static const shimmerBaseLight = Color(0xFFE2E8F0);

  /// Highlight shimmer color for light theme loading states.
  static const shimmerHighlightLight = Color(0xFFF8FAFC);

  /// Base shimmer color for dark theme loading states.
  static const shimmerBaseDark = Color(0xFF334155);

  /// Highlight shimmer color for dark theme loading states.
  static const shimmerHighlightDark = Color(0xFF475569);

  // ============ Convenience Aliases (Light Theme Defaults) ============

  /// Default surface color (light theme).
  ///
  /// Alias for [surfaceLight] for convenience.
  static const surface = surfaceLight;

  /// Default text primary color (light theme).
  ///
  /// Alias for [textPrimaryLight] for convenience.
  static const textPrimary = textPrimaryLight;

  /// Default text secondary color (light theme).
  ///
  /// Alias for [textSecondaryLight] for convenience.
  static const textSecondary = textSecondaryLight;

  /// Default background color (light theme).
  ///
  /// Alias for [backgroundLight] for convenience.
  static const background = backgroundLight;

  /// Default card color (light theme).
  ///
  /// Alias for [cardLight] for convenience.
  static const card = cardLight;

  /// Default border color (light theme).
  ///
  /// Alias for [borderLight] for convenience.
  static const border = borderLight;

  /// Returns the appropriate color for a given project status.
  ///
  /// This method maps status strings (typically from the backend) to
  /// their corresponding status colors for consistent visual feedback.
  ///
  /// ## Parameters
  ///
  /// - [status]: The project status string (case-insensitive)
  ///
  /// ## Returns
  ///
  /// A [Color] corresponding to the status:
  /// - analyzing, quoted -> [statusAnalyzing] (yellow)
  /// - payment_pending, pending -> [statusPending] (orange)
  /// - in_progress, assigned -> [statusInProgress] (blue)
  /// - for_review, submitted -> [statusForReview] (green)
  /// - completed, delivered -> [statusCompleted] (grey)
  /// - urgent, revision -> [statusUrgent] (red)
  /// - default -> [secondary] (grey)
  ///
  /// ## Example
  ///
  /// ```dart
  /// Container(
  ///   padding: const EdgeInsets.all(8),
  ///   decoration: BoxDecoration(
  ///     color: AppColors.getStatusColor(project.status).withOpacity(0.1),
  ///     borderRadius: BorderRadius.circular(4),
  ///   ),
  ///   child: Text(
  ///     project.status.toUpperCase(),
  ///     style: TextStyle(
  ///       color: AppColors.getStatusColor(project.status),
  ///     ),
  ///   ),
  /// );
  /// ```
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'analyzing':
      case 'quoted':
        return statusAnalyzing;
      case 'payment_pending':
      case 'pending':
        return statusPending;
      case 'in_progress':
      case 'assigned':
        return statusInProgress;
      case 'for_review':
      case 'submitted':
        return statusForReview;
      case 'completed':
      case 'delivered':
        return statusCompleted;
      case 'urgent':
      case 'revision':
        return statusUrgent;
      default:
        return secondary;
    }
  }
}

/// Empty state widgets for displaying when no content is available.
///
/// This file provides reusable components for showing helpful messages
/// and actions when lists or sections have no data to display.
///
/// ## Features
/// - Illustrated empty states with icons
/// - Customizable title and description text
/// - Optional action button for primary actions
/// - Error state variant for error handling
///
/// ## Example
/// ```dart
/// EmptyState(
///   icon: Icons.folder_open,
///   title: 'No Projects Yet',
///   description: 'Start by creating your first project',
///   actionText: 'Create Project',
///   onAction: () => createProject(),
/// )
/// ```
///
/// See also:
/// - [ErrorState] for error display
/// - [LoadingIndicator] for loading states
/// - [AppColors] for the color scheme
library;

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import 'app_button.dart';

/// A reusable empty state widget for displaying when content is unavailable.
///
/// Use when a list or page has no content to display. Provides visual
/// feedback and guidance to help users understand what actions to take.
///
/// ## Usage
/// ```dart
/// EmptyState(
///   icon: Icons.folder_open,
///   title: 'No Projects Yet',
///   description: 'Start by creating your first project',
///   actionText: 'Create Project',
///   onAction: () => createProject(),
/// )
/// ```
///
/// ## Action Button
/// When both [actionText] and [onAction] are provided, displays a primary
/// action button below the description.
///
/// See also:
/// - [ErrorState] for error-specific empty states
class EmptyState extends StatelessWidget {
  /// Creates an empty state with the specified properties.
  ///
  /// [icon] and [title] are required.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
  });

  /// The icon displayed prominently in a circular container.
  final IconData icon;

  /// The main title text displayed below the icon.
  final String title;

  /// Optional descriptive text displayed below the title.
  ///
  /// Use to provide additional context or guidance.
  final String? description;

  /// Label for the action button.
  ///
  /// When provided along with [onAction], shows an action button.
  final String? actionText;

  /// Callback for the action button.
  ///
  /// Required when [actionText] is provided.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                variant: AppButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An error state widget for displaying error messages.
///
/// A specialized empty state with an error icon and optional retry action.
/// Use when an operation fails and you want to give users a way to recover.
///
/// ## Usage
/// ```dart
/// ErrorState(
///   message: 'Failed to load projects',
///   onRetry: () => loadProjects(),
/// )
/// ```
///
/// ## Retry Action
/// When [onRetry] is provided, displays a "Try Again" button.
///
/// See also:
/// - [EmptyState] for general empty states
class ErrorState extends StatelessWidget {
  /// Creates an error state with the specified properties.
  const ErrorState({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  /// The error message to display.
  ///
  /// Defaults to 'Something went wrong'.
  final String message;

  /// Callback for the retry button.
  ///
  /// When provided, displays a "Try Again" button.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'Oops!',
      description: message,
      actionText: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }
}

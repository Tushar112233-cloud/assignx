import 'package:flutter/material.dart';

/// {@template confirm_dialog}
/// A confirmation dialog for destructive or important actions.
///
/// Presents the user with a choice to confirm or cancel an action.
/// Supports both regular confirmations and destructive actions
/// with appropriate visual styling.
///
/// ## Appearance
/// - Optional icon at the top (48px, colored based on [isDestructive])
/// - Title in dialog title style
/// - Message content describing the action
/// - Two action buttons: Cancel (text) and Confirm (elevated)
/// - Destructive actions show confirm button in error color
///
/// ## Returns
/// - `true` if the user confirms
/// - `false` if the user cancels or dismisses the dialog
///
/// ## Usage
///
/// Using static methods (recommended):
/// ```dart
/// final confirmed = await ConfirmDialog.show(
///   context,
///   title: 'Delete Item',
///   message: 'Are you sure you want to delete this item?',
///   confirmLabel: 'Delete',
///   isDestructive: true,
///   icon: Icons.delete_outline,
/// );
///
/// if (confirmed) {
///   deleteItem();
/// }
/// ```
///
/// Using pre-built dialogs:
/// ```dart
/// // Delete confirmation
/// final shouldDelete = await ConfirmDialog.showDelete(context, itemName: 'Task');
///
/// // Logout confirmation
/// final shouldLogout = await ConfirmDialog.showLogout(context);
///
/// // Discard changes confirmation
/// final shouldDiscard = await ConfirmDialog.showDiscardChanges(context);
/// ```
///
/// As a widget (less common):
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => ConfirmDialog(
///     title: 'Confirm Action',
///     message: 'This will modify your settings.',
///   ),
/// );
/// ```
///
/// See also:
/// - [AlertDialog] for the underlying Material dialog
/// {@endtemplate}
class ConfirmDialog extends StatelessWidget {
  /// Creates a confirmation dialog.
  ///
  /// The [title] and [message] parameters are required.
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  /// The dialog title.
  ///
  /// Displayed prominently at the top of the dialog.
  final String title;

  /// The dialog message.
  ///
  /// Provides context about the action being confirmed.
  final String message;

  /// Label for the confirm button.
  ///
  /// Defaults to 'Confirm'.
  final String confirmLabel;

  /// Label for the cancel button.
  ///
  /// Defaults to 'Cancel'.
  final String cancelLabel;

  /// Whether the action is destructive.
  ///
  /// When true, the confirm button uses error color styling
  /// and the icon (if provided) uses error color.
  final bool isDestructive;

  /// Optional icon to display above the title.
  ///
  /// Displayed at 48px size. Uses primary color for normal
  /// actions and error color for destructive actions.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: icon != null
          ? Icon(
              icon,
              size: 48,
              color: isDestructive
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            )
          : null,
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: isDestructive
              ? ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }

  /// Shows a confirmation dialog and returns true if confirmed.
  ///
  /// This is the primary way to show a [ConfirmDialog].
  /// Returns `false` if the dialog is dismissed without confirming.
  ///
  /// Example:
  /// ```dart
  /// final confirmed = await ConfirmDialog.show(
  ///   context,
  ///   title: 'Save Changes?',
  ///   message: 'Your changes will be saved to the server.',
  /// );
  /// ```
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  /// Shows a delete confirmation dialog.
  ///
  /// Pre-configured with delete icon, destructive styling,
  /// and appropriate messaging.
  ///
  /// Example:
  /// ```dart
  /// final shouldDelete = await ConfirmDialog.showDelete(
  ///   context,
  ///   itemName: 'this task',
  /// );
  /// ```
  static Future<bool> showDelete(
    BuildContext context, {
    String itemName = 'this item',
  }) {
    return show(
      context,
      title: 'Delete $itemName?',
      message: 'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  /// Shows a logout confirmation dialog.
  ///
  /// Pre-configured with logout icon and appropriate messaging.
  ///
  /// Example:
  /// ```dart
  /// final shouldLogout = await ConfirmDialog.showLogout(context);
  /// if (shouldLogout) {
  ///   await authService.logout();
  /// }
  /// ```
  static Future<bool> showLogout(BuildContext context) {
    return show(
      context,
      title: 'Log Out?',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      icon: Icons.logout,
    );
  }

  /// Shows a discard changes confirmation dialog.
  ///
  /// Pre-configured with warning icon, destructive styling,
  /// and appropriate messaging for unsaved changes.
  ///
  /// Example:
  /// ```dart
  /// Future<bool> onWillPop() async {
  ///   if (hasUnsavedChanges) {
  ///     return await ConfirmDialog.showDiscardChanges(context);
  ///   }
  ///   return true;
  /// }
  /// ```
  static Future<bool> showDiscardChanges(BuildContext context) {
    return show(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Are you sure you want to discard them?',
      confirmLabel: 'Discard',
      isDestructive: true,
      icon: Icons.warning_amber_outlined,
    );
  }
}

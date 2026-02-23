import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';

/// {@template empty_state}
/// A widget for displaying empty state UI when no data is available.
///
/// Provides a consistent empty state pattern across the app with an icon,
/// title, description, and optional action button.
///
/// ## Appearance
/// - Centered content with generous padding (32px)
/// - Large icon (80px by default) with reduced opacity
/// - Title text in titleLarge style
/// - Optional description in bodyMedium with muted color
/// - Optional action button at the bottom
///
/// ## Usage
///
/// Basic empty state:
/// ```dart
/// EmptyState(
///   title: 'No notifications',
///   icon: Icons.notifications_none,
/// )
/// ```
///
/// With description and action:
/// ```dart
/// EmptyState(
///   title: 'No tasks yet',
///   description: 'Create your first task to get started',
///   icon: Icons.task_alt,
///   actionLabel: 'Create Task',
///   onAction: () => showCreateTaskDialog(context),
/// )
/// ```
///
/// See also:
/// - [EmptyListState] for empty list-specific states
/// - [EmptySearchState] for empty search results
/// - [ErrorState] for error feedback
/// {@endtemplate}
class EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  ///
  /// The [title] parameter is required.
  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon,
    this.iconSize = 80,
    this.actionLabel,
    this.onAction,
  });

  /// The main title text describing the empty state.
  ///
  /// Displayed in titleLarge style with centered alignment.
  final String title;

  /// Optional description providing additional context.
  ///
  /// Displayed below the title in bodyMedium style with muted color.
  final String? description;

  /// Icon to display above the title.
  ///
  /// Displayed at 50% opacity for a subtle appearance.
  /// If null, no icon is shown.
  final IconData? icon;

  /// The size of the [icon].
  ///
  /// Defaults to 80 pixels.
  final double iconSize;

  /// Label for the action button.
  ///
  /// If both [actionLabel] and [onAction] are provided,
  /// a primary button is displayed.
  final String? actionLabel;

  /// Callback when the action button is pressed.
  ///
  /// If both [actionLabel] and [onAction] are provided,
  /// a primary button is displayed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: iconSize,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
            ],
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                text: actionLabel!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// {@template empty_list_state}
/// A pre-configured empty state for empty lists.
///
/// Provides default styling optimized for list views with
/// an inbox icon and "No items found" message.
///
/// ## Appearance
/// - Inbox outline icon
/// - "No items found" default title
/// - Optional description
///
/// ## Usage
/// ```dart
/// if (items.isEmpty) {
///   return EmptyListState(
///     description: 'Add items to see them here',
///   );
/// }
/// ```
///
/// See also:
/// - [EmptyState] for fully customizable empty states
/// - [EmptySearchState] for empty search results
/// {@endtemplate}
class EmptyListState extends StatelessWidget {
  /// Creates an empty list state.
  const EmptyListState({
    super.key,
    this.title = 'No items found',
    this.description,
    this.icon = Icons.inbox_outlined,
  });

  /// The main title text.
  ///
  /// Defaults to 'No items found'.
  final String title;

  /// Optional description text.
  final String? description;

  /// The icon to display.
  ///
  /// Defaults to [Icons.inbox_outlined].
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: title,
      description: description,
      icon: icon,
    );
  }
}

/// {@template empty_search_state}
/// A pre-configured empty state for empty search results.
///
/// Displays a search-off icon with contextual messaging based on
/// whether a search query was provided.
///
/// ## Appearance
/// - Search-off icon
/// - "No results found" title
/// - Contextual description mentioning the search query
///
/// ## Usage
/// ```dart
/// if (searchResults.isEmpty) {
///   return EmptySearchState(query: searchQuery);
/// }
/// ```
///
/// Without query:
/// ```dart
/// EmptySearchState()
/// // Shows: "Try adjusting your search or filters"
/// ```
///
/// With query:
/// ```dart
/// EmptySearchState(query: 'flutter widgets')
/// // Shows: "No results found for "flutter widgets""
/// ```
///
/// See also:
/// - [EmptyState] for fully customizable empty states
/// - [EmptyListState] for empty lists without search
/// {@endtemplate}
class EmptySearchState extends StatelessWidget {
  /// Creates an empty search state.
  const EmptySearchState({
    super.key,
    this.query = '',
  });

  /// The search query that yielded no results.
  ///
  /// If not empty, displayed in the description:
  /// "No results found for "{query}"".
  final String query;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      title: 'No results found',
      description: query.isNotEmpty
          ? 'No results found for "$query"'
          : 'Try adjusting your search or filters',
      icon: Icons.search_off_outlined,
    );
  }
}

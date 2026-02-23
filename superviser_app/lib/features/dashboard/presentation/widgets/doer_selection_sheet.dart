/// Doer selection bottom sheet for assigning writers to projects.
///
/// This file contains:
/// - [DoerSelectionSheet]: Modal bottom sheet for doer selection
/// - [DoerCard]: Card widget displaying doer information
/// - [_EmptyState]: Empty state when no doers match criteria
///
/// The sheet provides an interface for supervisors to browse available
/// doers and assign one to a paid project request.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/doer_model.dart';
import '../../data/models/request_model.dart';
import '../providers/dashboard_provider.dart';
import 'field_filter.dart';

/// A modal bottom sheet for selecting and assigning a doer to a project.
///
/// Provides a comprehensive interface for supervisors to:
/// - Search doers by name using a text field
/// - Filter doers by expertise/subject using chips
/// - View detailed doer information (rating, experience, completed projects)
/// - Select a doer from the list
/// - Confirm and assign the selected doer to the project
///
/// ## Usage
///
/// Use the static [show] method to display the sheet:
/// ```dart
/// final selectedDoer = await DoerSelectionSheet.show(context, request);
/// if (selectedDoer != null) {
///   // Doer was assigned successfully
///   showSnackBar('${selectedDoer.name} assigned to project!');
/// }
/// ```
///
/// ## State Management
///
/// Uses [doerSelectionProvider] for state management.
/// The doers are loaded automatically when the sheet opens,
/// filtered by the request's subject for relevance.
///
/// ## Selection Flow
///
/// 1. Sheet opens and loads available doers
/// 2. User can search/filter to find suitable doers
/// 3. User taps a doer card to select them
/// 4. Selected doer info appears in the bottom action bar
/// 5. User taps "Assign" to confirm the assignment
/// 6. Assignment is saved and sheet closes with the selected doer
///
/// See also:
/// - [DoerSelectionState] for the state structure
/// - [DoerSelectionNotifier] for actions
/// - [DoerModel] for the doer data model
/// - [DoerCard] for individual doer display
class DoerSelectionSheet extends ConsumerStatefulWidget {
  /// Creates a new [DoerSelectionSheet] instance.
  ///
  /// Parameters:
  /// - [request]: The project request to assign a doer to
  const DoerSelectionSheet({
    super.key,
    required this.request,
  });

  /// The project request to assign a doer to.
  ///
  /// Used to filter doers by expertise matching the request's subject.
  final RequestModel request;

  /// Shows the doer selection sheet as a modal bottom sheet.
  ///
  /// Returns the selected [DoerModel] if assignment was successful,
  /// or `null` if cancelled or an error occurred.
  ///
  /// Parameters:
  /// - [context]: The build context for showing the modal
  /// - [request]: The request to assign a doer to
  ///
  /// Example:
  /// ```dart
  /// final doer = await DoerSelectionSheet.show(context, myRequest);
  /// if (doer != null) {
  ///   print('Assigned: ${doer.name}');
  /// }
  /// ```
  static Future<DoerModel?> show(BuildContext context, RequestModel request) {
    return showModalBottomSheet<DoerModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoerSelectionSheet(request: request),
    );
  }

  @override
  ConsumerState<DoerSelectionSheet> createState() => _DoerSelectionSheetState();
}

/// State class for [DoerSelectionSheet].
///
/// Manages the search controller, selected doer state, and
/// handles loading/assignment logic.
class _DoerSelectionSheetState extends ConsumerState<DoerSelectionSheet> {
  /// Controller for the search text field.
  final _searchController = TextEditingController();

  /// Currently selected doer, or null if none selected.
  DoerModel? _selectedDoer;

  @override
  void initState() {
    super.initState();
    // Load available doers filtered by the request's subject
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doerSelectionProvider.notifier).loadDoers(
            expertise: widget.request.subject,
          );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doerState = ref.watch(doerSelectionProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Drag handle indicator
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header with title and request info
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Select Doer',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'For: ${widget.request.title}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Search bar for filtering by name
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AppTextField(
                  controller: _searchController,
                  hint: 'Search by name...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    ref.read(doerSelectionProvider.notifier).search(value);
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Expertise filter chips
              ExpertiseFilter(
                selectedExpertise: doerState.selectedExpertise,
                onExpertiseSelected: (expertise) {
                  ref
                      .read(doerSelectionProvider.notifier)
                      .filterByExpertise(expertise);
                },
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              // Doers list with loading/empty states
              Expanded(
                child: doerState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : doerState.filteredDoers.isEmpty
                        ? _EmptyState(
                            message: doerState.searchQuery.isNotEmpty
                                ? 'No doers match your search'
                                : 'No available doers found',
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: doerState.filteredDoers.length,
                            separatorBuilder: (_, __) => const Divider(
                              height: 1,
                              indent: 72,
                            ),
                            itemBuilder: (context, index) {
                              final doer = doerState.filteredDoers[index];
                              final isSelected = _selectedDoer?.id == doer.id;

                              return DoerCard(
                                doer: doer,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedDoer =
                                        isSelected ? null : doer;
                                  });
                                },
                              );
                            },
                          ),
              ),
              // Bottom action bar with selection info and assign button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Selected doer info or placeholder text
                    if (_selectedDoer != null)
                      Expanded(
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.1),
                              child: Text(
                                _selectedDoer!.initials,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _selectedDoer!.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          size: 14, color: Colors.amber),
                                      const SizedBox(width: 2),
                                      Text(
                                        _selectedDoer!.rating.toStringAsFixed(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          'Select a doer to assign',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                        ),
                      ),
                    const SizedBox(width: 16),
                    // Assign button (disabled if no doer selected)
                    PrimaryButton(
                      text: 'Assign',
                      onPressed:
                          _selectedDoer != null ? _assignDoer : null,
                      width: 120,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Handles the doer assignment.
  ///
  /// Calls the provider to assign the selected doer to the project,
  /// then refreshes the dashboard and closes the sheet with the
  /// selected doer on success.
  Future<void> _assignDoer() async {
    if (_selectedDoer == null) return;

    final success = await ref
        .read(doerSelectionProvider.notifier)
        .assignDoer(widget.request.id, _selectedDoer!.id);

    if (success && mounted) {
      // Refresh dashboard to show updated status
      ref.read(dashboardProvider.notifier).refresh();
      Navigator.pop(context, _selectedDoer);
    }
  }
}

/// Card widget displaying doer information.
///
/// Shows comprehensive doer details including:
/// - Avatar with initials and availability indicator
/// - Name and rating
/// - Expertise tags (up to 3)
/// - Statistics (completed projects, active projects)
/// - Selection indicator
///
/// ## Usage
///
/// ```dart
/// DoerCard(
///   doer: myDoer,
///   isSelected: selectedDoer?.id == myDoer.id,
///   onTap: () => selectDoer(myDoer),
/// )
/// ```
///
/// See also:
/// - [DoerModel] for the data model
/// - [DoerSelectionSheet] for the containing sheet
class DoerCard extends StatelessWidget {
  /// Creates a new [DoerCard] instance.
  ///
  /// Parameters:
  /// - [doer]: The doer data to display
  /// - [isSelected]: Whether this card is currently selected (default: false)
  /// - [onTap]: Callback when the card is tapped
  /// - [showDetails]: Whether to show expertise and stats (default: true)
  const DoerCard({
    super.key,
    required this.doer,
    this.isSelected = false,
    this.onTap,
    this.showDetails = true,
  });

  /// The doer data to display.
  final DoerModel doer;

  /// Whether this card is currently selected.
  ///
  /// When selected, the card has a highlight background,
  /// left border accent, and filled check icon.
  final bool isSelected;

  /// Callback invoked when the card is tapped.
  ///
  /// Typically used to toggle selection state.
  final VoidCallback? onTap;

  /// Whether to show expertise tags and statistics.
  ///
  /// Set to `false` for a more compact display showing
  /// only name and rating.
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : null,
          border: isSelected
              ? Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            // Avatar with availability indicator
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: doer.avatarUrl != null
                      ? NetworkImage(doer.avatarUrl!)
                      : null,
                  child: doer.avatarUrl == null
                      ? Text(
                          doer.initials,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                // Green/gray dot indicating availability
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: doer.isAvailable
                          ? AppColors.success
                          : AppColors.textSecondaryLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Doer info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and rating row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          doer.name,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Rating badge with star icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            doer.rating.toStringAsFixed(1),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (showDetails) ...[
                    const SizedBox(height: 4),
                    // Expertise chips (show first 3)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: doer.expertise.take(3).map((e) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            e,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    // Statistics row
                    Row(
                      children: [
                        Icon(Icons.task_alt,
                            size: 14, color: AppColors.textSecondaryLight),
                        const SizedBox(width: 4),
                        Text(
                          '${doer.completedProjects} completed',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Selection indicator (check circle or empty circle)
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary)
            else
              Icon(Icons.circle_outlined,
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget shown when no doers match the search/filter criteria.
///
/// Displays an icon and message indicating no results were found,
/// prompting the user to adjust their search or filters.
class _EmptyState extends StatelessWidget {
  /// Creates a new [_EmptyState] instance.
  ///
  /// Parameters:
  /// - [message]: The message to display
  const _EmptyState({required this.message});

  /// The message to display.
  ///
  /// Should explain why no results are shown (e.g., "No doers match your search").
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

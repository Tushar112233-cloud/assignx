/// Quote form bottom sheet for creating project quotes.
///
/// This file contains:
/// - [QuoteFormSheet]: Modal bottom sheet for quote creation
/// - [_RequestSummary]: Widget displaying request details
/// - [_QuoteItemCard]: Widget for individual quote line items
/// - [_TotalRow]: Widget displaying the quote total
/// - Supporting widgets for empty states and section headers
///
/// The sheet provides a form interface for supervisors to create
/// price quotes for client project requests.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/request_model.dart';
import '../providers/dashboard_provider.dart';

/// A modal bottom sheet for creating project quotes.
///
/// Provides a comprehensive form interface for supervisors to:
/// - View request details and requirements
/// - Add quote line items with descriptions and amounts
/// - Remove unwanted items
/// - Add optional notes for the client
/// - See the running total
/// - Submit the completed quote
///
/// ## Usage
///
/// Use the static [show] method to display the sheet:
/// ```dart
/// final submitted = await QuoteFormSheet.show(context, request);
/// if (submitted == true) {
///   // Quote was submitted successfully
///   showSnackBar('Quote submitted!');
/// }
/// ```
///
/// ## State Management
///
/// Uses [quoteFormProvider] for form state management.
/// The form is initialized with default items based on the request's
/// word count and page count via [createDefaultQuoteItems].
///
/// ## Form Flow
///
/// 1. Sheet opens with request summary displayed
/// 2. Default quote items are generated based on request requirements
/// 3. User can add/remove items and add notes
/// 4. User submits quote which:
///    - Creates a quote record in the database
///    - Updates the project status to "quoted"
///    - Closes the sheet and refreshes the dashboard
///
/// See also:
/// - [QuoteFormState] for the form state structure
/// - [QuoteFormNotifier] for form actions
/// - [QuoteModel] for the quote data model
/// - [QuoteItem] for individual line items
class QuoteFormSheet extends ConsumerStatefulWidget {
  /// Creates a new [QuoteFormSheet] instance.
  ///
  /// Parameters:
  /// - [request]: The project request to create a quote for
  const QuoteFormSheet({
    super.key,
    required this.request,
  });

  /// The project request to create a quote for.
  ///
  /// Used to display request details and initialize default quote items.
  final RequestModel request;

  /// Shows the quote form sheet as a modal bottom sheet.
  ///
  /// Returns `true` if the quote was submitted successfully,
  /// `false` or `null` if cancelled or an error occurred.
  ///
  /// Parameters:
  /// - [context]: The build context for showing the modal
  /// - [request]: The request to create a quote for
  ///
  /// Example:
  /// ```dart
  /// final submitted = await QuoteFormSheet.show(context, myRequest);
  /// ```
  static Future<bool?> show(BuildContext context, RequestModel request) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuoteFormSheet(request: request),
    );
  }

  @override
  ConsumerState<QuoteFormSheet> createState() => _QuoteFormSheetState();
}

/// State class for [QuoteFormSheet].
///
/// Manages text controllers for the notes and add item dialog,
/// and handles form initialization and submission.
class _QuoteFormSheetState extends ConsumerState<QuoteFormSheet> {
  /// Controller for the notes text field.
  final _notesController = TextEditingController();

  /// Controller for item description in the add item dialog.
  final _descriptionController = TextEditingController();

  /// Controller for item amount in the add item dialog.
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize form with default items based on request requirements
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quoteFormProvider.notifier).initialize(widget.request);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(quoteFormProvider);

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
              // Header with title and close button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  children: [
                    Text(
                      'Create Quote'.tr(context),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              ),
              const Divider(height: 1),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  children: [
                    // Request summary card
                    _RequestSummary(request: widget.request),
                    const SizedBox(height: 24),
                    // Price breakdown section
                    _SectionHeader(
                      title: 'Price Breakdown'.tr(context),
                      action: TextButton.icon(
                        onPressed: _showAddItemDialog,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('Add Item'.tr(context)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Quote items list or empty state
                    if (formState.items.isEmpty)
                      _EmptyState(onAddItem: _showAddItemDialog)
                    else
                      ...formState.items.asMap().entries.map((entry) {
                        return _QuoteItemCard(
                          item: entry.value,
                          onRemove: () => ref
                              .read(quoteFormProvider.notifier)
                              .removeItem(entry.key),
                        );
                      }),
                    const SizedBox(height: 16),
                    // Total display
                    _TotalRow(total: formState.totalPrice),
                    const SizedBox(height: 24),
                    // Notes section
                    _SectionHeader(title: 'Notes (Optional)'.tr(context)),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _notesController,
                      hint: 'Add any notes for the client...'.tr(context),
                      maxLines: 3,
                      onChanged: (value) {
                        ref.read(quoteFormProvider.notifier).updateNotes(value);
                      },
                    ),
                  ],
                ),
              ),
              // Pinned submit button at bottom
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error message display
                    if (formState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                formState.error!,
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      ),
                    PrimaryButton(
                      text: 'Submit Quote'.tr(context),
                      isLoading: formState.isSubmitting,
                      onPressed: _submitQuote,
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

  /// Shows a dialog to add a new quote item.
  ///
  /// Opens an [AlertDialog] with fields for item description and amount.
  /// Validates that both fields are filled and amount is positive before
  /// adding the item to the quote.
  void _showAddItemDialog() {
    _descriptionController.clear();
    _amountController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item'.tr(context)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _descriptionController,
              label: 'Description'.tr(context),
              hint: 'e.g., Research work'.tr(context),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _amountController,
              label: 'Amount (₹)'.tr(context),
              hint: '0.00',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'.tr(context)),
          ),
          FilledButton(
            onPressed: () {
              final description = _descriptionController.text.trim();
              final amount = double.tryParse(_amountController.text) ?? 0;

              if (description.isNotEmpty && amount > 0) {
                ref.read(quoteFormProvider.notifier).addItem(
                      QuoteItem(description: description, amount: amount),
                    );
                Navigator.pop(context);
              }
            },
            child: Text('Add'.tr(context)),
          ),
        ],
      ),
    );
  }

  /// Submits the quote to the database.
  ///
  /// Calls the provider to submit the quote, then:
  /// - Refreshes the dashboard to reflect the status change
  /// - Closes the sheet with a `true` result
  Future<void> _submitQuote() async {
    final success = await ref
        .read(quoteFormProvider.notifier)
        .submit(widget.request.id);

    if (success && mounted) {
      // Refresh dashboard to show updated status
      ref.read(dashboardProvider.notifier).refresh();
      Navigator.pop(context, true);
    }
  }
}

/// Widget displaying a summary of the request being quoted.
///
/// Shows the request title, description, and key details like
/// client name, deadline, word count, and page count in a
/// styled card format.
class _RequestSummary extends StatelessWidget {
  /// Creates a new [_RequestSummary] instance.
  ///
  /// Parameters:
  /// - [request]: The request to display
  const _RequestSummary({required this.request});

  /// The request to display.
  final RequestModel request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          // Info chips showing request details
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.person_outline,
                label: request.clientName,
              ),
              _InfoChip(
                icon: Icons.schedule,
                label: request.formattedDeadline,
              ),
              if (request.wordCount != null)
                _InfoChip(
                  icon: Icons.text_fields,
                  label: '${request.wordCount} ${'words'.tr(context)}',
                ),
              if (request.pageCount != null)
                _InfoChip(
                  icon: Icons.description_outlined,
                  label: '${request.pageCount} ${'pages'.tr(context)}',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small info chip displaying an icon and label.
///
/// Used in [_RequestSummary] to show request details like
/// client name, deadline, word count, and page count.
class _InfoChip extends StatelessWidget {
  /// Creates a new [_InfoChip] instance.
  ///
  /// Parameters:
  /// - [icon]: Icon to display
  /// - [label]: Label text
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  /// Icon to display.
  final IconData icon;

  /// Label text.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryLight),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
        ),
      ],
    );
  }
}

/// Section header with title and optional action widget.
///
/// Used to introduce sections in the quote form like
/// "Price Breakdown" and "Notes".
class _SectionHeader extends StatelessWidget {
  /// Creates a new [_SectionHeader] instance.
  ///
  /// Parameters:
  /// - [title]: The section title text
  /// - [action]: Optional action widget displayed on the right
  const _SectionHeader({
    required this.title,
    this.action,
  });

  /// The section title text.
  final String title;

  /// Optional action widget displayed on the right.
  ///
  /// Typically a [TextButton] for adding items or other actions.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const Spacer(),
        if (action != null) action!,
      ],
    );
  }
}

/// Card displaying a single quote line item.
///
/// Shows the item description, unit price breakdown (if applicable),
/// total amount, and a remove button.
class _QuoteItemCard extends StatelessWidget {
  /// Creates a new [_QuoteItemCard] instance.
  ///
  /// Parameters:
  /// - [item]: The quote item to display
  /// - [onRemove]: Callback when the remove button is pressed
  const _QuoteItemCard({
    required this.item,
    required this.onRemove,
  });

  /// The quote item to display.
  final QuoteItem item;

  /// Callback when the remove button is pressed.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondaryLight.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                // Show unit price breakdown for quantity > 1
                if (item.quantity > 1 && item.unitPrice != null)
                  Text(
                    '${item.quantity} x ₹${item.unitPrice!.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
              ],
            ),
          ),
          // Total amount
          Text(
            '₹${item.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: Icon(Icons.remove_circle_outline, color: AppColors.error),
            iconSize: 20,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

/// Empty state widget shown when no quote items exist.
///
/// Displays an icon and message prompting the user to add
/// their first quote item.
class _EmptyState extends StatelessWidget {
  /// Creates a new [_EmptyState] instance.
  ///
  /// Parameters:
  /// - [onAddItem]: Callback when the "Add first item" button is pressed
  const _EmptyState({required this.onAddItem});

  /// Callback when the "Add first item" button is pressed.
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No items added yet'.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAddItem,
            icon: const Icon(Icons.add),
            label: Text('Add first item'.tr(context)),
          ),
        ],
      ),
    );
  }
}

/// Widget displaying the quote total amount.
///
/// Renders a styled container with "Total" label and the
/// calculated total price in primary color.
class _TotalRow extends StatelessWidget {
  /// Creates a new [_TotalRow] instance.
  ///
  /// Parameters:
  /// - [total]: The total amount to display
  const _TotalRow({required this.total});

  /// The total amount to display.
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            'Total'.tr(context),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const Spacer(),
          Text(
            '₹${total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
          ),
        ],
      ),
    );
  }
}

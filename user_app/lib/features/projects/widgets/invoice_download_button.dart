import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/invoice_service.dart';
import '../../../data/models/invoice_model.dart';
import '../../../data/models/project.dart';
import '../../../data/models/user_profile.dart';

/// Invoice Download Button Widget.
///
/// Displays download and share options for project invoices.
/// Supports both direct invoice data and fetching from project ID.
///
/// ## Usage
///
/// ```dart
/// // With invoice model
/// InvoiceDownloadButton(
///   invoiceModel: invoice,
/// )
///
/// // With project ID (will fetch invoice data)
/// InvoiceDownloadButton(
///   projectId: 'project-uuid',
/// )
///
/// // Compact mode for list items
/// InvoiceDownloadButton(
///   projectId: 'project-uuid',
///   compact: true,
/// )
/// ```
///
/// Implements U37 from feature specification.
class InvoiceDownloadButton extends ConsumerStatefulWidget {
  /// Invoice data (new format).
  final InvoiceModel? invoiceModel;

  /// Legacy invoice data (for backward compatibility).
  final InvoiceData? invoice;

  /// Project ID to fetch invoice for.
  final String? projectId;

  /// Project data (optional, to avoid additional fetch).
  final Project? project;

  /// Whether to use compact display mode.
  final bool compact;

  /// Callback when download completes.
  final VoidCallback? onDownloadComplete;

  const InvoiceDownloadButton({
    super.key,
    this.invoiceModel,
    this.invoice,
    this.projectId,
    this.project,
    this.compact = false,
    this.onDownloadComplete,
  });

  @override
  ConsumerState<InvoiceDownloadButton> createState() =>
      _InvoiceDownloadButtonState();
}

class _InvoiceDownloadButtonState extends ConsumerState<InvoiceDownloadButton> {
  bool _isLoading = false;
  InvoiceModel? _invoice;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeInvoice();
  }

  @override
  void didUpdateWidget(InvoiceDownloadButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize if project or invoice changed
    if (widget.projectId != oldWidget.projectId ||
        widget.project?.id != oldWidget.project?.id) {
      _initializeInvoice();
    }
  }

  /// Initializes the invoice data.
  void _initializeInvoice() {
    // Priority: invoiceModel > invoice > project > projectId
    if (widget.invoiceModel != null) {
      _invoice = widget.invoiceModel;
    } else if (widget.invoice != null) {
      _invoice = widget.invoice!.toInvoiceModel();
    } else if (widget.project != null) {
      _loadInvoiceFromProject(widget.project!);
    } else if (widget.projectId != null) {
      _loadInvoiceFromProjectId();
    }
  }

  /// Loads invoice data from a Project model.
  Future<void> _loadInvoiceFromProject(Project project) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch user profile
      final profileResponse = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(profileResponse);

      // Create invoice from project and profile
      _invoice = InvoiceModel.fromProjectAndProfile(project, profile);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading invoice from project: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load invoice';
        });
      }
    }
  }

  /// Loads invoice data from project ID.
  Future<void> _loadInvoiceFromProjectId() async {
    if (widget.projectId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final invoice = await InvoiceService.getInvoiceForProject(widget.projectId!);

      if (invoice == null) {
        throw Exception('Invoice not found');
      }

      if (mounted) {
        setState(() {
          _invoice = invoice;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading invoice: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load invoice';
        });
      }
    }
  }

  /// Handles the download action.
  Future<void> _handleDownload() async {
    if (_invoice == null) return;

    setState(() => _isLoading = true);

    try {
      await InvoiceService.downloadInvoiceFromModel(context, _invoice!);
      widget.onDownloadComplete?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Handles the share action.
  Future<void> _handleShare() async {
    if (_invoice == null) return;

    setState(() => _isLoading = true);

    try {
      await InvoiceService.shareInvoiceFromModel(_invoice!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Handles save to device action.
  Future<void> _handleSaveToDevice() async {
    if (_invoice == null) return;

    setState(() => _isLoading = true);

    try {
      final path = await InvoiceService.saveInvoiceToDevice(_invoice!);

      if (mounted) {
        if (path != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to: $path'),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () => _handleDownload(),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not save to device. Try sharing instead.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Shows the options bottom sheet.
  void _showOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildOptionsSheet(),
    );
  }

  /// Builds the options bottom sheet.
  Widget _buildOptionsSheet() {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewPadding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice',
                      style: AppTextStyles.headingSmall.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_invoice != null)
                      Text(
                        _invoice!.invoiceNumber,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              // Status badge
              if (_invoice != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _invoice!.isPaid
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _invoice!.paymentStatus.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _invoice!.isPaid ? AppColors.success : AppColors.warning,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Invoice Summary
          if (_invoice != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Project', _invoice!.projectNumber),
                  _buildSummaryRow('Service', _invoice!.serviceType),
                  const Divider(height: 16),
                  _buildSummaryRow('Subtotal', _invoice!.formattedSubtotal),
                  _buildSummaryRow('GST (18%)', _invoice!.formattedGst),
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Total',
                    _invoice!.formattedTotal,
                    isTotal: true,
                  ),
                  if (_invoice!.paidAt != null) ...[
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Paid On',
                      _formatDate(_invoice!.paidAt!),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              // Share button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleShare();
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Download button
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleDownload();
                  },
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Save to Device option
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _handleSaveToDevice();
            },
            icon: const Icon(Icons.save_alt, size: 18),
            label: const Text('Save to Device'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a summary row for the bottom sheet.
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a date for display.
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // Don't show if no invoice data and not loading
    if (_invoice == null && !_isLoading && _error == null) {
      return const SizedBox.shrink();
    }

    // Show error state
    if (_error != null && !_isLoading) {
      return widget.compact
          ? IconButton(
              onPressed: _initializeInvoice,
              icon: Icon(Icons.error_outline, color: Colors.red[400]),
              tooltip: 'Retry loading invoice',
            )
          : TextButton.icon(
              onPressed: _initializeInvoice,
              icon: Icon(Icons.refresh, color: Colors.red[400], size: 18),
              label: Text('Retry', style: AppTextStyles.labelSmall.copyWith(color: Colors.red[400])),
            );
    }

    // Compact mode (for list items)
    if (widget.compact) {
      return IconButton(
        onPressed: _isLoading ? null : _showOptions,
        icon: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.receipt_long),
        tooltip: 'View Invoice',
      );
    }

    // Full button mode
    return OutlinedButton.icon(
      onPressed: _isLoading ? null : _showOptions,
      icon: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.receipt_long, size: 18),
      label: const Text('Invoice'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

/// Quick invoice download button for lists.
///
/// A simpler widget that takes a project and displays a compact
/// invoice button.
class InvoiceQuickButton extends StatelessWidget {
  /// The invoice data to display.
  final InvoiceData? invoice;

  /// The invoice model to display.
  final InvoiceModel? invoiceModel;

  /// The project to generate invoice from.
  final Project? project;

  const InvoiceQuickButton({
    super.key,
    this.invoice,
    this.invoiceModel,
    this.project,
  });

  @override
  Widget build(BuildContext context) {
    return InvoiceDownloadButton(
      invoice: invoice,
      invoiceModel: invoiceModel,
      project: project,
      compact: true,
    );
  }
}

/// Invoice button with project data.
///
/// A convenience widget that creates an invoice button from a project.
class ProjectInvoiceButton extends StatelessWidget {
  /// The project to generate invoice for.
  final Project project;

  /// Whether to use compact mode.
  final bool compact;

  /// Callback when download completes.
  final VoidCallback? onDownloadComplete;

  const ProjectInvoiceButton({
    super.key,
    required this.project,
    this.compact = false,
    this.onDownloadComplete,
  });

  @override
  Widget build(BuildContext context) {
    // Only show for paid projects
    if (!project.isPaid) {
      return const SizedBox.shrink();
    }

    return InvoiceDownloadButton(
      project: project,
      compact: compact,
      onDownloadComplete: onDownloadComplete,
    );
  }
}

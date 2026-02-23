import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/budget_display.dart';
import '../widgets/file_attachment.dart';
import '../widgets/success_popup.dart';

/// Report type options.
enum ReportType {
  plagiarism('Plagiarism Check', 'Detect copied content', Icons.content_copy, 99),
  aiDetection('AI Detection', 'Check for AI-generated content', Icons.smart_toy_outlined, 149),
  both('Both Reports', 'Complete analysis', Icons.analytics_outlined, 199);

  final String title;
  final String description;
  final IconData icon;
  final double price;

  const ReportType(this.title, this.description, this.icon, this.price);
}

/// Report format options.
enum ReportFormat {
  turnitin('Turnitin Style', 'Industry standard format'),
  detailed('Detailed Report', 'Comprehensive breakdown'),
  certificate('Certificate', 'Official verification certificate');

  final String title;
  final String description;

  const ReportFormat(this.title, this.description);
}

/// Report request form for plagiarism/AI detection with beautiful design.
class ReportRequestForm extends ConsumerStatefulWidget {
  const ReportRequestForm({super.key});

  @override
  ConsumerState<ReportRequestForm> createState() => _ReportRequestFormState();
}

class _ReportRequestFormState extends ConsumerState<ReportRequestForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form data
  ReportType? _reportType;
  final Set<ReportFormat> _formats = {ReportFormat.detailed};
  List<AttachmentFile> _attachments = [];
  bool _urgentDelivery = false;

  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Submits the report request.
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_reportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a report type'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_attachments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload at least one document'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final serviceType = _reportType == ReportType.aiDetection
          ? ServiceType.aiDetection
          : ServiceType.plagiarismCheck;

      final project = await ref.read(projectNotifierProvider.notifier).createProject(
        title: '${_reportType?.title ?? 'Report'} Request',
        description: 'Report type: ${_reportType?.title}. '
            'Formats: ${_formats.map((f) => f.title).join(', ')}. '
            '${_urgentDelivery ? 'Urgent delivery requested.' : ''}',
        serviceType: serviceType,
        deadline: _urgentDelivery
            ? DateTime.now().add(const Duration(hours: 2))
            : DateTime.now().add(const Duration(hours: 24)),
        specificInstructions: _emailController.text.trim().isNotEmpty
            ? 'Deliver report to: ${_emailController.text.trim()}'
            : null,
      );

      if (!mounted) return;

      final projectId = project?.id ?? '';

      await SuccessPopup.show(
        context,
        title: 'Report Requested!',
        message: 'Your report request has been submitted. You\'ll receive the report within ${_urgentDelivery ? '2 hours' : '24 hours'}.',
        projectId: projectId,
        onViewProject: () {
          context.go('/projects/$projectId');
        },
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Plag/AI Report',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.orange.shade600,
                  Colors.orange.shade400,
                  Colors.amber.shade400,
                ],
              ),
            ),
          ),

          // Content with glass morphism
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header with icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade50,
                            Colors.amber.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange.shade600, Colors.amber.shade400],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.document_scanner_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plagiarism & AI Detection',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get comprehensive authenticity reports',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Report type selection
                    _buildSectionLabel('Select Report Type', Icons.analytics_outlined),
                    const SizedBox(height: 12),
                    ...ReportType.values.map(
                      (type) => _ReportTypeCard(
                        type: type,
                        isSelected: _reportType == type,
                        onTap: () => setState(() => _reportType = type),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Upload document
                    _buildSectionLabel('Upload Document', Icons.cloud_upload_outlined),
                    const SizedBox(height: 8),
                    FileAttachment(
                      files: _attachments,
                      onChanged: (files) => setState(() => _attachments = files),
                      label: 'Upload Document',
                      hint: 'Upload the document to analyze',
                      maxFiles: 1,
                      maxSizeMB: 50,
                      allowedExtensions: ['doc', 'docx', 'pdf', 'txt'],
                    ),
                    const SizedBox(height: 24),

                    // Report format
                    _buildSectionLabel('Report Format', Icons.description_outlined),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReportFormat.values.map((format) {
                        final isSelected = _formats.contains(format);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _formats.remove(format);
                              } else {
                                _formats.add(format);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [Colors.orange.shade600, Colors.amber.shade400],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.orange.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                if (isSelected) const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      format.title,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      format.description,
                                      style: AppTextStyles.caption.copyWith(
                                        color: isSelected
                                            ? Colors.white.withValues(alpha: 0.9)
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Urgent delivery toggle
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade50,
                            Colors.white,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _urgentDelivery ? Colors.orange.shade600 : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flash_on,
                            color: _urgentDelivery ? Colors.orange.shade600 : Colors.grey.shade400,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Urgent Delivery',
                                  style: AppTextStyles.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _urgentDelivery
                                      ? 'Get report in 2 hours (+₹100)'
                                      : 'Standard delivery (24 hours)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _urgentDelivery,
                            onChanged: (value) => setState(() => _urgentDelivery = value),
                            activeTrackColor: Colors.orange.shade600,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email for delivery
                    _buildSectionLabel('Email for Report Delivery', Icons.email_outlined),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.orange.shade600,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Price summary
                    BudgetCard(
                      price: _calculateTotalPrice(),
                      subtitle: 'Total Price',
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade600, Colors.amber.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Request Report',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  double? _calculateTotalPrice() {
    if (_reportType == null) return null;
    double total = _reportType!.price;
    if (_urgentDelivery) total += 100;
    if (_formats.contains(ReportFormat.certificate)) total += 50;
    return total;
  }
}

class _ReportTypeCard extends StatelessWidget {
  final ReportType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ReportTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.orange.shade50,
                    Colors.white,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.orange.shade600, Colors.amber.shade400],
                      )
                    : null,
                color: isSelected ? null : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isSelected ? Colors.orange.shade700 : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    type.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${type.price.toInt()}',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: isSelected ? Colors.orange.shade700 : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.orange.shade600,
                    size: 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

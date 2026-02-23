import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/budget_display.dart';
import '../widgets/deadline_picker.dart';
import '../widgets/file_attachment.dart';
import '../widgets/focus_area_chips.dart';
import '../widgets/success_popup.dart';
import '../widgets/word_count_input.dart';

/// Document type for proofreading.
enum DocumentType {
  essay('Essay', Icons.article_outlined),
  thesis('Thesis/Dissertation', Icons.school_outlined),
  report('Report', Icons.summarize_outlined),
  proposal('Proposal', Icons.description_outlined),
  article('Article', Icons.newspaper),
  resume('Resume/CV', Icons.person_outline),
  letter('Cover Letter', Icons.mail_outline),
  other('Other', Icons.folder_outlined);

  final String displayName;
  final IconData icon;

  const DocumentType(this.displayName, this.icon);
}

/// Proofreading service form with beautiful gradient design.
class ProofreadingForm extends ConsumerStatefulWidget {
  const ProofreadingForm({super.key});

  @override
  ConsumerState<ProofreadingForm> createState() => _ProofreadingFormState();
}

class _ProofreadingFormState extends ConsumerState<ProofreadingForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form data
  DocumentType? _documentType;
  int? _wordCount;
  DateTime? _deadline;
  Set<FocusArea> _focusAreas = {};
  List<AttachmentFile> _attachments = [];

  final _instructionsController = TextEditingController();

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  /// Submits the proofreading request.
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

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
      final project = await ref.read(projectNotifierProvider.notifier).createProject(
        title: 'Proofreading: ${_documentType?.displayName ?? 'Document'}',
        description: _instructionsController.text.trim().isNotEmpty
            ? _instructionsController.text.trim()
            : null,
        serviceType: ServiceType.proofreading,
        deadline: _deadline ?? DateTime.now().add(const Duration(days: 3)),
        wordCount: _wordCount,
        focusAreas: _focusAreas.map((a) => a.name).toList(),
        specificInstructions: _documentType != null
            ? 'Document type: ${_documentType!.displayName}'
            : null,
      );

      if (!mounted) return;

      final projectId = project?.id ?? '';

      await SuccessPopup.show(
        context,
        title: 'Request Submitted!',
        message: 'Your proofreading request has been submitted. Our experts will review it shortly.',
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
          'Proofreading Service',
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
                  Colors.blue.shade600,
                  Colors.blue.shade400,
                  Colors.cyan.shade400,
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
                            Colors.blue.shade50,
                            Colors.cyan.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue.shade600, Colors.cyan.shade400],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.spellcheck,
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
                                  'Professional Proofreading',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get your document polished by experts',
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

                    // Document type
                    _buildSectionLabel('Document Type', Icons.description_outlined),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DocumentType.values.map((type) {
                        final isSelected = _documentType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _documentType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [Colors.blue.shade600, Colors.cyan.shade400],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade300,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withValues(alpha: 0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 16,
                                  color: isSelected ? Colors.white : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type.displayName,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Upload document
                    _buildSectionLabel('Upload Document', Icons.cloud_upload_outlined),
                    const SizedBox(height: 8),
                    FileAttachment(
                      files: _attachments,
                      onChanged: (files) => setState(() => _attachments = files),
                      label: 'Upload Document',
                      hint: 'Upload the document you want proofread',
                      maxFiles: 3,
                      maxSizeMB: 20,
                      allowedExtensions: ['doc', 'docx', 'pdf', 'txt', 'rtf'],
                      errorText: _attachments.isEmpty ? 'Document is required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Word count
                    _buildSectionLabel('Word Count', Icons.format_size),
                    const SizedBox(height: 8),
                    WordCountInput(
                      value: _wordCount,
                      onChanged: (value) => setState(() => _wordCount = value),
                    ),
                    const SizedBox(height: 24),

                    // Focus areas
                    _buildSectionLabel('Focus Areas', Icons.flag_outlined),
                    const SizedBox(height: 8),
                    FocusAreaChips(
                      selectedAreas: _focusAreas,
                      onChanged: (areas) => setState(() => _focusAreas = areas),
                    ),
                    const SizedBox(height: 24),

                    // Deadline
                    _buildSectionLabel('Deadline', Icons.calendar_today),
                    const SizedBox(height: 8),
                    DeadlinePicker(
                      value: _deadline,
                      onChanged: (value) => setState(() => _deadline = value),
                    ),
                    const SizedBox(height: 24),

                    // Special instructions
                    _buildSectionLabel('Special Instructions', Icons.notes),
                    const SizedBox(height: 4),
                    Text(
                      'Any specific guidelines or preferences (optional)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _instructionsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g., Focus on academic tone, British English spelling...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
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
                          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Price estimate
                    BudgetDisplay(
                      basePrice: _calculatePrice(),
                      urgencyTier: _getUrgencyTier(),
                      wordCount: _wordCount,
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.cyan.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
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
                                'Submit Request',
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
        Icon(icon, size: 18, color: Colors.blue.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  double? _calculatePrice() {
    if (_wordCount == null) return null;
    double base = _wordCount! * 0.2;
    base += _focusAreas.length * 50;
    return base;
  }

  UrgencyTier _getUrgencyTier() {
    if (_deadline == null) return UrgencyTier.standard;
    final daysUntil = _deadline!.difference(DateTime.now()).inDays;
    if (daysUntil < 1) return UrgencyTier.urgent;
    if (daysUntil <= 3) return UrgencyTier.express;
    if (daysUntil <= 7) return UrgencyTier.standard;
    return UrgencyTier.relaxed;
  }
}

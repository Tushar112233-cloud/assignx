import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/file_attachment.dart';
import '../../../core/translation/translation_extensions.dart';
import '../widgets/success_popup.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Report type options with web-matching prices.
enum ReportType {
  aiDetection(
    'AI Detection',
    'Detect AI-generated content using advanced algorithms',
    Icons.smart_toy_outlined,
    49,
  ),
  plagiarism(
    'Plagiarism Check',
    'Compare against billions of web pages & academic papers',
    Icons.content_copy,
    99,
  ),
  both(
    'Complete Report',
    'Full AI detection + plagiarism check in one report',
    Icons.analytics_outlined,
    129,
  );

  final String title;
  final String description;
  final IconData icon;
  final double price;

  const ReportType(this.title, this.description, this.icon, this.price);
}

/// 3-step report request form matching the web wizard design,
/// built with the Coffee Bean flat design system.
class ReportRequestForm extends ConsumerStatefulWidget {
  const ReportRequestForm({super.key});

  @override
  ConsumerState<ReportRequestForm> createState() => _ReportRequestFormState();
}

class _ReportRequestFormState extends ConsumerState<ReportRequestForm> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Step 1
  ReportType? _reportType;

  // Step 2
  final _formKey = GlobalKey<FormState>();
  final _docCountController = TextEditingController(text: '1');
  final _wordCountController = TextEditingController();
  List<AttachmentFile> _attachments = [];

  @override
  void dispose() {
    _docCountController.dispose();
    _wordCountController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _nextStep() {
    if (_currentStep == 0 && _reportType == null) {
      _showError('Please select a report type'.tr(context));
      return;
    }
    if (_currentStep == 1) {
      if (!_formKey.currentState!.validate()) return;
      if (_attachments.isEmpty) {
        _showError('Please upload at least one document'.tr(context));
        return;
      }
    }
    setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  // ---------------------------------------------------------------------------
  // Pricing helpers
  // ---------------------------------------------------------------------------

  int get _docCount => int.tryParse(_docCountController.text) ?? 1;

  double get _basePrice => (_reportType?.price ?? 0) * _docCount;

  double get _gst => _basePrice * 0.18;

  double get _totalPrice => _basePrice + _gst;

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> _submitRequest() async {
    setState(() => _isSubmitting = true);

    try {
      final serviceType = _reportType == ReportType.aiDetection
          ? ServiceType.aiDetection
          : ServiceType.plagiarismCheck;

      final wordCount = int.tryParse(_wordCountController.text) ?? 0;

      final project =
          await ref.read(projectNotifierProvider.notifier).createProject(
                title: '${_reportType?.title ?? 'Report'} Request',
                description: 'Report type: ${_reportType?.title}. '
                    'Documents: $_docCount. '
                    'Approx words: $wordCount.',
                serviceType: serviceType,
                deadline: DateTime.now().add(const Duration(hours: 24)),
              );

      if (!mounted) return;

      final projectId = project?.id ?? '';

      await SuccessPopup.show(
        context,
        title: 'Report Requested!',
        message:
            'Your report request has been submitted. You\'ll receive the report within 24 hours.',
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
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SubtleGradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Plagiarism & AI Check'.tr(context),
          style: AppTextStyles.headingSmall,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          _StepIndicator(currentStep: _currentStep),

          // Step content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: _buildStepContent(),
            ),
          ),

          // Bottom navigation buttons
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1SelectType();
      case 1:
        return _buildStep2Upload();
      case 2:
        return _buildStep3Review();
      default:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Step 1 — Select Report Type
  // ---------------------------------------------------------------------------

  Widget _buildStep1SelectType() {
    return ListView(
      key: const ValueKey(0),
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Choose Your Report'.tr(context),
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Select the type of analysis you need'.tr(context),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        ...ReportType.values.map(
          (type) => _ReportTypeCard(
            type: type,
            isSelected: _reportType == type,
            showBestValue: type == ReportType.both,
            onTap: () => setState(() => _reportType = type),
          ),
        ),
        const SizedBox(height: 16),
        // Features row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildFeatureChip(Icons.schedule_outlined, 'Within 24h'),
              const SizedBox(width: 12),
              _buildFeatureChip(Icons.verified_outlined, 'Detailed Report'),
              const SizedBox(width: 12),
              _buildFeatureChip(Icons.lock_outlined, 'Secure'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — Upload Documents
  // ---------------------------------------------------------------------------

  Widget _buildStep2Upload() {
    return Form(
      key: _formKey,
      child: ListView(
        key: const ValueKey(1),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Upload Documents'.tr(context),
            style: AppTextStyles.headingMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Provide details about the documents to analyze'.tr(context),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Document count
          Text(
            'Number of Documents'.tr(context),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _docCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              hint: '1',
              prefixIcon: Icons.description_outlined,
            ),
            validator: (value) {
              final n = int.tryParse(value ?? '');
              if (n == null || n < 1) {
                return 'Enter at least 1 document'.tr(context);
              }
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),

          // Word count
          Text(
            'Approximate Word Count'.tr(context),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _wordCountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _inputDecoration(
              hint: 'e.g. 5000',
              prefixIcon: Icons.text_fields_outlined,
            ),
            validator: (value) {
              final n = int.tryParse(value ?? '');
              if (n == null || n < 1) {
                return 'Enter approximate word count'.tr(context);
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // File upload
          Text(
            'Upload Files'.tr(context),
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          FileAttachment(
            files: _attachments,
            onChanged: (files) => setState(() => _attachments = files),
            label: 'Upload Document'.tr(context),
            hint: 'Upload the document to analyze'.tr(context),
            maxFiles: 5,
            maxSizeMB: 50,
            allowedExtensions: ['doc', 'docx', 'pdf', 'txt'],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textTertiary,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 3 — Review & Submit
  // ---------------------------------------------------------------------------

  Widget _buildStep3Review() {
    return ListView(
      key: const ValueKey(2),
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Review & Submit'.tr(context),
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Confirm your order details before submitting'.tr(context),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Order summary card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'Order Summary'.tr(context),
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),

              // Details grid
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _summaryRow(
                      'Report Type'.tr(context),
                      _reportType?.title ?? '-',
                    ),
                    _summaryRow(
                      'Documents'.tr(context),
                      '$_docCount',
                    ),
                    _summaryRow(
                      'Word Count'.tr(context),
                      _wordCountController.text.isNotEmpty
                          ? _wordCountController.text
                          : '-',
                    ),
                    _summaryRow(
                      'Files Uploaded'.tr(context),
                      '${_attachments.length}',
                    ),
                  ],
                ),
              ),

              // Divider
              Container(height: 1, color: AppColors.border),

              // Price breakdown
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _priceRow(
                      '${_reportType?.title ?? 'Report'} x $_docCount',
                      _basePrice,
                    ),
                    const SizedBox(height: 8),
                    _priceRow('GST (18%)', _gst),
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total'.tr(context),
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '\u20B9${_totalPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          '\u20B9${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom bar with navigation buttons
  // ---------------------------------------------------------------------------

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    minimumSize: const Size(0, 48),
                  ),
                  child: Text(
                    'Back'.tr(context),
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (_currentStep < 2 ? _nextStep : _submitRequest),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      AppColors.primary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  minimumSize: const Size(0, 48),
                  elevation: 0,
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
                        (_currentStep < 2
                                ? 'Continue'
                                : 'Submit Request')
                            .tr(context),
                        style: AppTextStyles.buttonMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Step Indicator
// =============================================================================

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  static const _labels = ['Report Type', 'Upload', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= currentStep;
          final isCurrent = index == currentStep;
          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: index <= currentStep
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary : Colors.white,
                    border: Border.all(
                      color:
                          isActive ? AppColors.primary : AppColors.border,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: index < currentStep
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isActive
                                ? Colors.white
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    _labels[index],
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// =============================================================================
// Report Type Card
// =============================================================================

class _ReportTypeCard extends StatelessWidget {
  final ReportType type;
  final bool isSelected;
  final bool showBestValue;
  final VoidCallback onTap;

  const _ReportTypeCard({
    required this.type,
    required this.isSelected,
    this.showBestValue = false,
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
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon in tinted circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? AppColors.primary : AppColors.textTertiary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Title + description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          type.title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (showBestValue) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'BEST VALUE',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Price + selection indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\u20B9${type.price.toInt()}',
                  style: AppTextStyles.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color:
                      isSelected ? AppColors.primary : AppColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

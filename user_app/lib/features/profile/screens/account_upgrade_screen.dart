import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../widgets/account_upgrade_card.dart';

/// Upgrade step in the multi-step flow.
enum UpgradeStep {
  select,
  verify,
  confirm,
  success,
}

/// Verification document types.
enum VerificationDocType {
  graduationCertificate,
  degreeCertificate,
  idCard,
  businessRegistration,
  taxCertificate,
  professionalLicense,
}

/// Verification requirement model.
class VerificationRequirement {
  final String id;
  final VerificationDocType type;
  final String label;
  final String description;
  final bool required;
  bool accepted;
  String? filePath;
  String? fileName;

  VerificationRequirement({
    required this.id,
    required this.type,
    required this.label,
    required this.description,
    required this.required,
    this.accepted = false,
    this.filePath,
    this.fileName,
  });
}

/// Colors used in the upgrade screen.
class _UpgradeScreenColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const borderColor = Color(0xFFE5E5E5);
  static const infoBg = Color(0xFFF0F9FF);
  static const infoBorder = Color(0xFFBAE6FD);
  static const warningBg = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const successBg = Color(0xFFECFDF5);
}

/// Account upgrade screen with multi-step flow.
///
/// Guides users through:
/// - Step 1: Select account type
/// - Step 2: Upload verification documents
/// - Step 3: Review and confirm
/// - Step 4: Success animation
class AccountUpgradeScreen extends ConsumerStatefulWidget {
  /// The current account type of the user.
  final AccountType currentType;

  /// Optional pre-selected target type.
  final AccountType? preSelectedType;

  const AccountUpgradeScreen({
    super.key,
    required this.currentType,
    this.preSelectedType,
  });

  @override
  ConsumerState<AccountUpgradeScreen> createState() =>
      _AccountUpgradeScreenState();
}

class _AccountUpgradeScreenState extends ConsumerState<AccountUpgradeScreen>
    with SingleTickerProviderStateMixin {
  late UpgradeStep _currentStep;
  AccountType? _selectedType;
  List<VerificationRequirement> _documents = [];
  bool _isSubmitting = false;

  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.preSelectedType != null
        ? UpgradeStep.verify
        : UpgradeStep.select;
    _selectedType = widget.preSelectedType;

    if (_selectedType != null) {
      _documents = _getVerificationRequirements(
        widget.currentType,
        _selectedType!,
      );
    }

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  /// Get verification requirements based on upgrade path.
  List<VerificationRequirement> _getVerificationRequirements(
    AccountType from,
    AccountType to,
  ) {
    if (from == AccountType.student && to == AccountType.professional) {
      return [
        VerificationRequirement(
          id: 'graduation_proof',
          type: VerificationDocType.graduationCertificate,
          label: 'Graduation Proof',
          description:
              'Degree certificate, transcript, or graduation letter',
          required: true,
        ),
        VerificationRequirement(
          id: 'id_verification',
          type: VerificationDocType.idCard,
          label: 'ID Verification',
          description:
              'Government-issued ID (passport, driver\'s license, or national ID)',
          required: true,
        ),
      ];
    }

    if (from == AccountType.student && to == AccountType.businessOwner) {
      return [
        VerificationRequirement(
          id: 'business_registration',
          type: VerificationDocType.businessRegistration,
          label: 'Business Registration',
          description: 'Certificate of incorporation or business license',
          required: true,
        ),
        VerificationRequirement(
          id: 'tax_certificate',
          type: VerificationDocType.taxCertificate,
          label: 'Tax Certificate',
          description: 'Tax registration certificate or business tax ID',
          required: false,
        ),
        VerificationRequirement(
          id: 'id_verification',
          type: VerificationDocType.idCard,
          label: 'ID Verification',
          description: 'Government-issued ID of the business owner',
          required: true,
        ),
      ];
    }

    if (from == AccountType.professional && to == AccountType.businessOwner) {
      return [
        VerificationRequirement(
          id: 'business_registration',
          type: VerificationDocType.businessRegistration,
          label: 'Business Registration',
          description: 'Certificate of incorporation or business license',
          required: true,
        ),
        VerificationRequirement(
          id: 'tax_certificate',
          type: VerificationDocType.taxCertificate,
          label: 'Tax Certificate',
          description: 'Tax registration certificate or business tax ID',
          required: false,
        ),
      ];
    }

    return [];
  }

  /// Get estimated processing time.
  String _getProcessingTime(AccountType type) {
    switch (type) {
      case AccountType.professional:
        return '1-2 business days';
      case AccountType.businessOwner:
        return '2-3 business days';
      default:
        return 'Instant';
    }
  }

  /// Check if all required documents are uploaded.
  bool get _allRequiredUploaded {
    return _documents
        .where((doc) => doc.required)
        .every((doc) => doc.accepted);
  }

  /// Handle type selection.
  void _selectType(AccountType type) {
    setState(() {
      _selectedType = type;
      _documents = _getVerificationRequirements(widget.currentType, type);
      _currentStep = UpgradeStep.verify;
    });
  }

  /// Handle file upload.
  Future<void> _pickFile(int documentIndex) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _documents[documentIndex].filePath = file.path;
        _documents[documentIndex].fileName = file.name;
        _documents[documentIndex].accepted = true;
      });
    }
  }

  /// Remove uploaded file.
  void _removeFile(int documentIndex) {
    setState(() {
      _documents[documentIndex].filePath = null;
      _documents[documentIndex].fileName = null;
      _documents[documentIndex].accepted = false;
    });
  }

  /// Handle form submission.
  Future<void> _submitUpgrade() async {
    if (_selectedType == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _currentStep = UpgradeStep.success;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit upgrade request: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: _currentStep == UpgradeStep.success
              ? () => context.pop()
              : () {
                  if (_currentStep == UpgradeStep.select) {
                    context.pop();
                  } else if (_currentStep == UpgradeStep.verify) {
                    setState(() => _currentStep = UpgradeStep.select);
                  } else if (_currentStep == UpgradeStep.confirm) {
                    setState(() => _currentStep = UpgradeStep.verify);
                  }
                },
          icon: Icon(
            _currentStep == UpgradeStep.success
                ? Icons.close
                : Icons.arrow_back,
            color: _UpgradeScreenColors.primaryText,
          ),
        ),
        title: Text(
          _getTitle(),
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _UpgradeScreenColors.primaryText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          if (_currentStep != UpgradeStep.success) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildProgressDot(1, _currentStep.index >= 0),
                      _buildProgressLine(_currentStep.index >= 1),
                      _buildProgressDot(2, _currentStep.index >= 1),
                      _buildProgressLine(_currentStep.index >= 2),
                      _buildProgressDot(3, _currentStep.index >= 2),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: _currentStep.index >= 0
                              ? AppColors.primary
                              : _UpgradeScreenColors.mutedText,
                        ),
                      ),
                      Text(
                        'Verify',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: _currentStep.index >= 1
                              ? AppColors.primary
                              : _UpgradeScreenColors.mutedText,
                        ),
                      ),
                      Text(
                        'Confirm',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11,
                          color: _currentStep.index >= 2
                              ? AppColors.primary
                              : _UpgradeScreenColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom action button
          if (_currentStep != UpgradeStep.success) _buildBottomAction(),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case UpgradeStep.select:
        return 'Choose Account Type';
      case UpgradeStep.verify:
        return 'Verification';
      case UpgradeStep.confirm:
        return 'Confirm Upgrade';
      case UpgradeStep.success:
        return 'Request Submitted';
    }
  }

  Widget _buildProgressDot(int step, bool isActive) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : _UpgradeScreenColors.borderColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isActive
            ? Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              )
            : Text(
                step.toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  fontSize: 12,
                  color: _UpgradeScreenColors.mutedText,
                ),
              ),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive
            ? AppColors.primary
            : _UpgradeScreenColors.borderColor,
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case UpgradeStep.select:
        return _buildSelectStep();
      case UpgradeStep.verify:
        return _buildVerifyStep();
      case UpgradeStep.confirm:
        return _buildConfirmStep();
      case UpgradeStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildSelectStep() {
    final availableUpgrades = widget.currentType.canUpgradeTo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select the account type you want to upgrade to',
          style: AppTextStyles.bodyMedium.copyWith(
            color: _UpgradeScreenColors.secondaryText,
          ),
        ),
        const SizedBox(height: 20),
        ...availableUpgrades.map((type) {
          final isSelected = _selectedType == type;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _UpgradeScreenColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? type.color
                        : _UpgradeScreenColors.borderColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: type.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        type.icon,
                        size: 24,
                        color: type.color,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                type.displayName,
                                style: AppTextStyles.labelLarge.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _UpgradeScreenColors.primaryText,
                                ),
                              ),
                              if (type == AccountType.businessOwner) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Premium',
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type.description,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 13,
                              color: _UpgradeScreenColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ...type.benefits.take(3).map((benefit) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    benefit,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 12,
                                      color: _UpgradeScreenColors.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? type.color
                              : _UpgradeScreenColors.borderColor,
                          width: 2,
                        ),
                        color: isSelected ? type.color : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildVerifyStep() {
    if (_selectedType == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _UpgradeScreenColors.infoBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _UpgradeScreenColors.infoBorder,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 20,
                color: const Color(0xFF0284C7),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Verification',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0369A1),
                      ),
                    ),
                    Text(
                      'Your documents are encrypted and reviewed by our team',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Upload Required Documents',
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _UpgradeScreenColors.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        ..._documents.asMap().entries.map((entry) {
          final index = entry.key;
          final doc = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _UpgradeScreenColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: doc.accepted
                      ? AppColors.success.withAlpha(100)
                      : _UpgradeScreenColors.borderColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            doc.label,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _UpgradeScreenColors.primaryText,
                            ),
                          ),
                          if (doc.required)
                            Text(
                              ' *',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      if (doc.accepted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _UpgradeScreenColors.successBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check,
                                size: 12,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Uploaded',
                                style: AppTextStyles.caption.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    doc.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: _UpgradeScreenColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (doc.accepted && doc.fileName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.insert_drive_file_outlined,
                            size: 18,
                            color: _UpgradeScreenColors.secondaryText,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              doc.fileName!,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 13,
                                color: _UpgradeScreenColors.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _removeFile(index),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: _UpgradeScreenColors.mutedText,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: () => _pickFile(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _UpgradeScreenColors.borderColor,
                            width: 1,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_outlined,
                              size: 20,
                              color: _UpgradeScreenColors.secondaryText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Tap to upload (PDF, JPG, PNG)',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 13,
                                color: _UpgradeScreenColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildConfirmStep() {
    if (_selectedType == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upgrade path visualization
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.currentType.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.currentType.icon,
                  size: 22,
                  color: widget.currentType.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.currentType.displayName,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _UpgradeScreenColors.primaryText,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                size: 20,
                color: _UpgradeScreenColors.mutedText,
              ),
              const Spacer(),
              Text(
                _selectedType!.displayName,
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _selectedType!.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _selectedType!.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _selectedType!.icon,
                  size: 22,
                  color: _selectedType!.color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Summary cards
        _buildSummaryCard(
          icon: Icons.insert_drive_file_outlined,
          title: 'Documents Uploaded',
          value:
              '${_documents.where((d) => d.accepted).length} of ${_documents.length}',
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          icon: Icons.access_time,
          title: 'Estimated Processing',
          value: _getProcessingTime(_selectedType!),
        ),
        const SizedBox(height: 20),

        // Warning note
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _UpgradeScreenColors.warningBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _UpgradeScreenColors.warningBorder,
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: const Color(0xFFB45309),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your upgrade request will be reviewed by our team. You will receive an email notification once approved.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _UpgradeScreenColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _UpgradeScreenColors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: _UpgradeScreenColors.secondaryText,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    color: _UpgradeScreenColors.secondaryText,
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _UpgradeScreenColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            size: 20,
            color: AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        // Success animation
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: _UpgradeScreenColors.successBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Request Submitted!',
          style: AppTextStyles.headingMedium.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _UpgradeScreenColors.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your upgrade to ${_selectedType?.displayName ?? ''} is being processed.',
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 15,
            color: _UpgradeScreenColors.secondaryText,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // What happens next
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What happens next?',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _UpgradeScreenColors.primaryText,
                ),
              ),
              const SizedBox(height: 12),
              _buildNextStepItem(1, 'Our team will review your documents'),
              const SizedBox(height: 8),
              _buildNextStepItem(2, 'You will receive an email with the decision'),
              const SizedBox(height: 8),
              _buildNextStepItem(
                  3, 'If approved, your account will be upgraded automatically'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Done',
              style: AppTextStyles.buttonMedium.copyWith(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNextStepItem(int number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 13,
              color: _UpgradeScreenColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(
            color: _UpgradeScreenColors.borderColor,
            width: 1,
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _getActionEnabled()
              ? () {
                  if (_currentStep == UpgradeStep.select && _selectedType != null) {
                    _selectType(_selectedType!);
                  } else if (_currentStep == UpgradeStep.verify) {
                    setState(() => _currentStep = UpgradeStep.confirm);
                  } else if (_currentStep == UpgradeStep.confirm) {
                    _submitUpgrade();
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _UpgradeScreenColors.borderColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSubmitting
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getActionText(),
                      style: AppTextStyles.buttonMedium.copyWith(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentStep == UpgradeStep.confirm
                          ? Icons.check
                          : Icons.arrow_forward,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _getActionText() {
    switch (_currentStep) {
      case UpgradeStep.select:
        return 'Continue';
      case UpgradeStep.verify:
        return 'Continue';
      case UpgradeStep.confirm:
        return 'Submit Request';
      case UpgradeStep.success:
        return 'Done';
    }
  }

  bool _getActionEnabled() {
    switch (_currentStep) {
      case UpgradeStep.select:
        return _selectedType != null;
      case UpgradeStep.verify:
        return _allRequiredUploaded;
      case UpgradeStep.confirm:
        return !_isSubmitting;
      case UpgradeStep.success:
        return true;
    }
  }
}

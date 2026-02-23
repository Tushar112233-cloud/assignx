import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../data/models/registration_model.dart';
import '../../providers/registration_provider.dart';
import '../../widgets/file_upload_card.dart';

/// Step 2: Education & Experience
///
/// Collects education, expertise areas, and CV upload.
class ExperienceStep extends ConsumerStatefulWidget {
  const ExperienceStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  ConsumerState<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends ConsumerState<ExperienceStep> {
  final _formKey = GlobalKey<FormState>();
  final _fieldOfStudyController = TextEditingController();
  final _yearsExpController = TextEditingController();

  String? _selectedEducation;
  List<String> _selectedExpertise = [];
  String? _uploadedCvName;
  bool _isUploadingCv = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = ref.read(registrationProvider).data;
    _selectedEducation = data.highestEducation;
    _fieldOfStudyController.text = data.fieldOfStudy ?? '';
    _yearsExpController.text = data.yearsOfExperience?.toString() ?? '';
    _selectedExpertise = List.from(data.expertiseAreas);
    if (data.cvUrl != null) {
      _uploadedCvName = data.cvUrl!.split('/').last;
    }
  }

  @override
  void dispose() {
    _fieldOfStudyController.dispose();
    _yearsExpController.dispose();
    super.dispose();
  }

  void _toggleExpertise(String expertise) {
    setState(() {
      if (_selectedExpertise.contains(expertise)) {
        _selectedExpertise.remove(expertise);
      } else {
        if (_selectedExpertise.length < 5) {
          _selectedExpertise.add(expertise);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 5 expertise areas'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _uploadCV() async {
    // Simulate file upload - in production use file_picker package
    setState(() {
      _isUploadingCv = true;
    });

    // Simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isUploadingCv = false;
      _uploadedCvName = 'resume_supervisor.pdf';
    });

    // In production, call the provider to upload
    // final notifier = ref.read(registrationProvider.notifier);
    // await notifier.uploadCV(filePath, fileName);
  }

  void _removeCV() {
    setState(() {
      _uploadedCvName = null;
    });
    ref.read(registrationProvider.notifier).updateData(
          (data) => data.copyWith(cvUrl: null),
        );
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      if (_selectedExpertise.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one expertise area'),
          ),
        );
        return;
      }

      final notifier = ref.read(registrationProvider.notifier);
      notifier.updateData((data) => data.copyWith(
            highestEducation: _selectedEducation,
            fieldOfStudy: _fieldOfStudyController.text.trim(),
            yearsOfExperience: int.tryParse(_yearsExpController.text.trim()),
            expertiseAreas: _selectedExpertise,
            cvUrl: _uploadedCvName != null ? 'cvs/$_uploadedCvName' : null,
          ));
      widget.onNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Education & Experience',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your academic background and expertise',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Highest Education
            DropdownButtonFormField<String>(
              initialValue: _selectedEducation,
              decoration: InputDecoration(
                labelText: 'Highest Education *',
                prefixIcon: const Icon(Icons.school_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: educationLevels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEducation = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your education level';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Field of Study
            AppTextField(
              controller: _fieldOfStudyController,
              label: 'Field of Study',
              hint: 'e.g., Computer Science, Business Administration',
              prefixIcon: Icons.menu_book_outlined,
            ),
            const SizedBox(height: 16),

            // Years of Experience
            AppTextField(
              controller: _yearsExpController,
              label: 'Years of Experience',
              hint: '5',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.work_history_outlined,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final years = int.tryParse(value);
                  if (years == null || years < 0 || years > 50) {
                    return 'Enter valid years (0-50)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Expertise Areas
            Text(
              'Areas of Expertise *',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select up to 5 areas (${_selectedExpertise.length}/5 selected)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: expertiseAreaOptions.map((expertise) {
                final isSelected = _selectedExpertise.contains(expertise);
                return FilterChip(
                  label: Text(expertise),
                  selected: isSelected,
                  onSelected: (_) => _toggleExpertise(expertise),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondaryLight,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // CV Upload
            Text(
              'Upload CV (Optional)',
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),

            FileUploadCard(
              title: 'Upload your CV',
              subtitle: 'Help us understand your background better',
              onTap: _uploadCV,
              isLoading: _isUploadingCv,
              isUploaded: _uploadedCvName != null,
              fileName: _uploadedCvName,
              fileSize: _uploadedCvName != null ? '245 KB' : null,
              onRemove: _removeCV,
            ),
            const SizedBox(height: 32),

            // Navigation Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Back',
                    onPressed: widget.onBack,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    text: 'Continue',
                    onPressed: _saveAndContinue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

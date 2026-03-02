import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/translation/translation_extensions.dart';
import '../../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../data/models/registration_model.dart';
import '../../providers/registration_provider.dart';

/// Step 1: Personal Information
///
/// Collects basic profile information like phone, location, and bio.
class PersonalInfoStep extends ConsumerStatefulWidget {
  const PersonalInfoStep({
    super.key,
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  ConsumerState<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends ConsumerState<PersonalInfoStep> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _bioController = TextEditingController();
  final _linkedInController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final data = ref.read(registrationProvider).data;
    _phoneController.text = data.phone ?? '';
    _cityController.text = data.city ?? '';
    _stateController.text = data.state ?? '';
    _countryController.text = data.country ?? 'India';
    _bioController.text = data.bio ?? '';
    _linkedInController.text = data.linkedInUrl ?? '';
    _selectedGender = data.gender;
    _selectedDateOfBirth = data.dateOfBirth;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _linkedInController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year - 18), // Must be at least 18
      helpText: 'Select your date of birth'.tr(context),
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(registrationProvider.notifier);
      notifier.updateData((data) => data.copyWith(
            phone: _phoneController.text.trim(),
            dateOfBirth: _selectedDateOfBirth,
            gender: _selectedGender,
            city: _cityController.text.trim(),
            state: _stateController.text.trim(),
            country: _countryController.text.trim(),
            bio: _bioController.text.trim(),
            linkedInUrl: _linkedInController.text.trim().isNotEmpty
                ? _linkedInController.text.trim()
                : null,
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
              'Personal Information'.tr(context),
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell us a bit about yourself'.tr(context),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),

            // Phone Number
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number'.tr(context),
              hint: '+91 9876543210',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required'.tr(context);
                }
                if (value.length < 10) {
                  return 'Enter a valid phone number'.tr(context);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Date of Birth
            InkWell(
              onTap: _selectDateOfBirth,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date of Birth'.tr(context),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _selectedDateOfBirth != null
                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                      : 'Select date'.tr(context),
                  style: AppTypography.bodyMedium.copyWith(
                    color: _selectedDateOfBirth != null
                        ? AppColors.textPrimaryLight
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender
            DropdownButtonFormField<String>(
              initialValue: _selectedGender,
              decoration: InputDecoration(
                labelText: 'Gender'.tr(context),
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: genderOptions.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // City and State
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _cityController,
                    label: 'City'.tr(context),
                    hint: 'Mumbai',
                    prefixIcon: Icons.location_city_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'City is required'.tr(context);
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AppTextField(
                    controller: _stateController,
                    label: 'State'.tr(context),
                    hint: 'Maharashtra',
                    prefixIcon: Icons.map_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Country
            AppTextField(
              controller: _countryController,
              label: 'Country'.tr(context),
              hint: 'India',
              prefixIcon: Icons.public_outlined,
            ),
            const SizedBox(height: 16),

            // Bio
            AppTextField(
              controller: _bioController,
              label: 'Short Bio (Optional)'.tr(context),
              hint: 'Tell us about yourself in a few sentences...'.tr(context),
              maxLines: 3,
              maxLength: 300,
              prefixIcon: Icons.edit_note_outlined,
            ),
            const SizedBox(height: 16),

            // LinkedIn URL
            AppTextField(
              controller: _linkedInController,
              label: 'LinkedIn Profile (Optional)'.tr(context),
              hint: 'https://linkedin.com/in/yourprofile',
              keyboardType: TextInputType.url,
              prefixIcon: Icons.link_outlined,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('linkedin.com')) {
                    return 'Enter a valid LinkedIn URL'.tr(context);
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Continue Button
            PrimaryButton(
              text: 'Continue'.tr(context),
              onPressed: _saveAndContinue,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

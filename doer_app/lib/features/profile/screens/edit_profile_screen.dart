import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../dashboard/widgets/app_header.dart';

/// Edit profile screen for updating user information.
///
/// Provides a form for editing profile details including name,
/// phone, bio, education, and skills.
///
/// ## Navigation
/// - Entry: From [ProfileScreen] via "Edit Profile" button
/// - Success: Returns to [ProfileScreen] with success message
/// - Back: Returns to [ProfileScreen] without saving
///
/// ## Features
/// - Avatar display with change photo option (TODO)
/// - Form validation for all fields
/// - Skill suggestions with toggle selection
/// - Skills as comma-separated input
/// - Character limits per field
/// - Save button with loading state
///
/// ## Form Fields
/// - Full Name: Required, letters/spaces/hyphens only
/// - Phone: Optional, numbers/plus/hyphen only
/// - Education: Optional, max 200 chars
/// - Bio: Optional, max 500 chars
/// - Skills: Comma-separated list
///
/// See also:
/// - [ProfileProvider] for profile updates
/// - [Validators] for form validation
/// - [ProfileScreen] for profile display
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _educationController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).profile;
    _nameController = TextEditingController(text: profile?.fullName);
    _phoneController = TextEditingController(text: profile?.phone);
    _bioController = TextEditingController(text: profile?.bio);
    _educationController = TextEditingController(text: profile?.education);
    _skillsController = TextEditingController(text: profile?.skills.join(', '));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          InnerHeader(
            title: 'Edit Profile',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar section
                    _buildAvatarSection(profile),

                    const SizedBox(height: AppSpacing.lg),

                    // Personal info section
                    _buildSectionTitle('Personal Information'),
                    const SizedBox(height: AppSpacing.md),

                    _buildFormField(
                      label: 'Full Name',
                      controller: _nameController,
                      hint: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                      validator: Validators.name,
                      maxLength: 100,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\-\.]')),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildFormField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: Validators.optionalPhone,
                      maxLength: 15,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s]')),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    _buildFormField(
                      label: 'Education',
                      controller: _educationController,
                      hint: 'e.g., M.A. in English Literature',
                      prefixIcon: Icons.school_outlined,
                      validator: Validators.education,
                      maxLength: 200,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Bio section
                    _buildSectionTitle('About You'),
                    const SizedBox(height: AppSpacing.md),

                    _buildFormField(
                      label: 'Bio',
                      controller: _bioController,
                      hint: 'Tell us about yourself and your expertise...',
                      maxLines: 4,
                      validator: Validators.bio,
                      maxLength: 500,
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Skills section
                    _buildSectionTitle('Skills & Expertise'),
                    const SizedBox(height: AppSpacing.md),

                    _buildFormField(
                      label: 'Skills',
                      controller: _skillsController,
                      hint: 'Enter skills separated by commas',
                      prefixIcon: Icons.psychology_outlined,
                      helperText: 'e.g., Research Papers, Essays, APA Format',
                      validator: Validators.skills,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Skill suggestions
                    _buildSkillSuggestions(),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),

          // Save button
          _buildBottomBar(profileState.isSaving),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(UserProfile? profile) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: profile?.avatarUrl != null
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: profile!.avatarUrl!,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildAvatarText(profile),
                        ),
                      )
                    : _buildAvatarText(profile),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: _changeAvatar,
            child: const Text('Change Photo'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarText(UserProfile? profile) {
    return Text(
      profile?.fullName.isNotEmpty == true
          ? profile!.fullName[0].toUpperCase()
          : 'U',
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? helperText,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            counterText: '', // Hide the counter
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textTertiary),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            border: const OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: AppSpacing.borderRadiusSm,
              borderSide: BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
        if (helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              helperText,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSkillSuggestions() {
    final suggestions = [
      'Research Papers',
      'Essays',
      'Case Studies',
      'Literature Review',
      'Technical Writing',
      'APA Format',
      'MLA Format',
      'Harvard Format',
      'Data Analysis',
      'Proofreading',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((skill) {
        final currentSkills = _skillsController.text
            .split(',')
            .map((s) => s.trim().toLowerCase())
            .toList();
        final isSelected = currentSkills.contains(skill.toLowerCase());

        return GestureDetector(
          onTap: () => _toggleSkill(skill),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.border,
              ),
            ),
            child: Text(
              skill,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleSkill(String skill) {
    final currentSkills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final lowercaseSkill = skill.toLowerCase();
    final existingIndex = currentSkills.indexWhere(
      (s) => s.toLowerCase() == lowercaseSkill,
    );

    if (existingIndex != -1) {
      currentSkills.removeAt(existingIndex);
    } else {
      currentSkills.add(skill);
    }

    setState(() {
      _skillsController.text = currentSkills.join(', ');
    });
  }

  Widget _buildBottomBar(bool isSaving) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          text: isSaving ? 'Saving...' : 'Save Changes',
          onPressed: isSaving ? null : _saveProfile,
          isFullWidth: true,
          isLoading: isSaving,
          icon: Icons.save,
        ),
      ),
    );
  }

  /// Shows a bottom sheet with image source options and handles avatar upload.
  Future<void> _changeAvatar() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Photo Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image == null || !mounted) return;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  Text('Uploading photo...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Upload avatar
      final success = await ref.read(profileProvider.notifier).uploadAvatar(
            File(image.path),
          );

      if (!mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      // Show result message
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile photo updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final errorMessage = ref.read(profileProvider).errorMessage ?? 'Failed to upload photo';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final success = await ref.read(profileProvider.notifier).updateProfile(
          fullName: _nameController.text,
          phone: _phoneController.text,
          bio: _bioController.text,
          education: _educationController.text,
          skills: skills,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

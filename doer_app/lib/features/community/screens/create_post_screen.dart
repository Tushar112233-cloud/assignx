/// Create post screen for the Pro Network feature.
///
/// A multi-step wizard for creating community posts with
/// category selection, content details, and media upload.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../data/models/community_post_model.dart';
import '../../../providers/community_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';

/// Create post screen with step-by-step wizard.
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() =>
      _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  int _currentStep = 0;
  ProfessionalCategory? _selectedCategory;
  ProfessionalPostType? _selectedType;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_selectedCategory == null ||
        _selectedType == null ||
        _titleController.text.trim().isEmpty) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(communityRepositoryProvider).createPost(
            category: _selectedCategory!,
            type: _selectedType!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim().isNotEmpty
                ? _descriptionController.text.trim()
                : null,
            location: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
          );

      ref.invalidate(communityPostsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Post created successfully!'.tr(context)),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post'.tr(context)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Post'.tr(context)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: MeshGradientBackgroundPresets.subtleModern(
        child: Column(
          children: [
            // Step indicator
            _StepIndicator(
              currentStep: _currentStep,
              totalSteps: 3,
            ),

            // Step content
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingMd,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildCurrentStep(),
                ),
              ),
            ),

            // Navigation buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _CategorySelectionStep(
          key: const ValueKey('step0'),
          selectedCategory: _selectedCategory,
          selectedType: _selectedType,
          onCategorySelected: (category) {
            setState(() => _selectedCategory = category);
          },
          onTypeSelected: (type) {
            setState(() => _selectedType = type);
          },
        );
      case 1:
        return _DetailsStep(
          key: const ValueKey('step1'),
          titleController: _titleController,
          descriptionController: _descriptionController,
          locationController: _locationController,
        );
      case 2:
        return _MediaStep(
          key: const ValueKey('step2'),
          images: _selectedImages,
          onPickImages: _pickImages,
          onRemoveImage: (index) {
            setState(() => _selectedImages.removeAt(index));
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _currentStep--);
                  },
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Back'.tr(context)),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _canProceed() ? _handleNext : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
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
                        _currentStep == 2
                            ? 'Post'.tr(context)
                            : 'Next'.tr(context),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_isSubmitting) return false;
    switch (_currentStep) {
      case 0:
        return _selectedCategory != null && _selectedType != null;
      case 1:
        return _titleController.text.trim().isNotEmpty;
      case 2:
        return true;
      default:
        return false;
    }
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _submitPost();
    }
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? 4 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CategorySelectionStep extends StatelessWidget {
  final ProfessionalCategory? selectedCategory;
  final ProfessionalPostType? selectedType;
  final ValueChanged<ProfessionalCategory> onCategorySelected;
  final ValueChanged<ProfessionalPostType> onTypeSelected;

  const _CategorySelectionStep({
    super.key,
    this.selectedCategory,
    this.selectedType,
    required this.onCategorySelected,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Exclude "all" from category selection
    final categories = ProfessionalCategory.values
        .where((c) => c != ProfessionalCategory.all)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a category'.tr(context),
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Select the category that best fits your post'.tr(context),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () => onCategorySelected(category),
              child: GlassCard(
                elevation: isSelected ? 3 : 1,
                borderColor: isSelected
                    ? category.color
                    : AppColors.border.withAlpha(51),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: isSelected
                          ? category.color
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.displayName,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? category.color
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (selectedCategory != null) ...[
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Post type'.tr(context),
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...ProfessionalPostType.values.map((type) {
            final isSelected = selectedType == type;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => onTypeSelected(type),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(20)
                        : AppColors.surface,
                    borderRadius: AppSpacing.borderRadiusSm,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        type.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        type.displayName,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;

  const _DetailsStep({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Post details'.tr(context),
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Title'.tr(context), style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Give your post a title...'.tr(context),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Description'.tr(context),
            style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: descriptionController,
          maxLines: 6,
          maxLength: 2000,
          decoration: InputDecoration(
            hintText:
                'Describe your post in detail...'.tr(context),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Location (optional)'.tr(context),
            style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: locationController,
          decoration: InputDecoration(
            hintText: 'Add location...'.tr(context),
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            prefixIcon: const Icon(Icons.location_on_outlined,
                color: AppColors.textTertiary),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}

class _MediaStep extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveImage;

  const _MediaStep({
    super.key,
    required this.images,
    required this.onPickImages,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add media (optional)'.tr(context),
          style: AppTextStyles.headingMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Add photos to make your post more engaging'.tr(context),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: AppColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: 32, color: AppColors.textTertiary),
                const SizedBox(height: 8),
                Text(
                  'Tap to add photos'.tr(context),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (images.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: AppSpacing.borderRadiusSm,
                      child: Image.file(
                        File(images[index].path),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemoveImage(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(128),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

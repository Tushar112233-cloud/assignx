library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../data/models/pro_network_post_model.dart';
import '../providers/pro_network_provider.dart';

/// Post category options for Pro Network.
enum ProPostCategory {
  discussion('Discussion', Icons.chat_bubble_outline, 'Start a professional discussion'),
  portfolio('Portfolio', Icons.photo_library_outlined, 'Showcase your work'),
  skillExchange('Skill Exchange', Icons.swap_horiz, 'Offer or seek skills'),
  freelanceGig('Freelance Gig', Icons.rocket_launch_outlined, 'Post a freelance opportunity'),
  event('Event', Icons.event_outlined, 'Share a professional event'),
  resource('Resource', Icons.build_outlined, 'Share tools & resources');

  final String label;
  final IconData icon;
  final String description;

  const ProPostCategory(this.label, this.icon, this.description);
}

/// Screen to create new Pro Network posts.
class ProCreatePostScreen extends ConsumerStatefulWidget {
  const ProCreatePostScreen({super.key});

  @override
  ConsumerState<ProCreatePostScreen> createState() =>
      _ProCreatePostScreenState();
}

class _ProCreatePostScreenState extends ConsumerState<ProCreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  ProPostCategory _selectedCategory = ProPostCategory.discussion;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _selectedImages = [];
  final List<String> _tags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        opacity: 0.4,
        colors: [
          AppColors.meshPink,
          AppColors.meshPeach,
          AppColors.meshOrange,
        ],
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              _buildProgressIndicator(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildCategoryStep(),
                      _buildDetailsStep(),
                      _buildMediaStep(),
                    ],
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(204),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withAlpha(128), width: 1),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.close, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create Pro Post',
                        style: AppTextStyles.labelLarge
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Step ${_currentStep + 1} of 3',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (_currentStep == 2)
                  GlassButton(
                    label: 'Post',
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    isLoading: _isSubmitting,
                    blur: 10,
                    opacity: 0.9,
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    fullWidth: false,
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    fontSize: 14,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.border.withAlpha(77),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('What would you like to post?',
              style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text(
            'Choose a category for your professional post',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ...ProPostCategory.values.map((category) {
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                blur: isSelected ? 15 : 10,
                opacity: isSelected ? 0.9 : 0.7,
                elevation: isSelected ? 3 : 1,
                onTap: () => setState(() => _selectedCategory = category),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(colors: [
                            AppColors.primary.withAlpha(26),
                            AppColors.primaryLight.withAlpha(13),
                          ])
                        : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          category.icon,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.label,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? AppColors.primary : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.description,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 16),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Tell us more', style: AppTextStyles.headingSmall),
          const SizedBox(height: 24),
          _buildGlassTextField(
            controller: _titleController,
            label: 'Title',
            hint: _getTitleHint(),
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter a title';
              if (value.length < 5) {
                return 'Title must be at least 5 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _descriptionController,
            label: 'Description',
            hint: 'Share more details about your post...',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'e.g., Remote, Bangalore, Delhi',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),
          _buildGlassTextField(
            controller: _tagsController,
            label: 'Tags (optional)',
            hint: 'Add tags to help others find your post',
            icon: Icons.tag,
            onSubmitted: (value) {
              if (value.isNotEmpty && _tags.length < 5) {
                setState(() {
                  _tags.add(value);
                  _tagsController.clear();
                });
              }
            },
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(77),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _tags.remove(tag)),
                        child:
                            Icon(Icons.close, size: 14, color: AppColors.primary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text('Add photos', style: AppTextStyles.headingSmall),
          const SizedBox(height: 8),
          Text(
            'Upload up to 5 photos to make your post stand out',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount:
                _selectedImages.length < 5 ? _selectedImages.length + 1 : 5,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length &&
                  _selectedImages.length < 5) {
                return GlassCard(
                  blur: 10,
                  opacity: 0.7,
                  padding: EdgeInsets.zero,
                  onTap: _pickImage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 32, color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return GlassCard(
                blur: 8,
                opacity: 0.6,
                padding: EdgeInsets.zero,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        _selectedImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceVariant,
                          child: Icon(Icons.broken_image,
                              color: AppColors.textTertiary),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedImages.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          GlassCard(
            blur: 12,
            opacity: 0.8,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'Professional Guidelines',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...[
                  'Keep it professional and constructive',
                  'No spam or misleading content',
                  'Respect intellectual property',
                  'Follow community guidelines',
                ].map((text) => _buildGuidelineItem(text)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return GlassCard(
      blur: 12,
      opacity: 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.labelMedium
                      .copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
            onFieldSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 18, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: GlassButton(
                label: 'Back',
                icon: Icons.arrow_back,
                onPressed: () {
                  setState(() => _currentStep--);
                  _pageController.animateToPage(
                    _currentStep,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                blur: 12,
                opacity: 0.8,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                height: 52,
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: GlassButton(
              label: _currentStep < 2 ? 'Continue' : 'Post',
              icon: _currentStep < 2 ? Icons.arrow_forward : Icons.check,
              onPressed: _currentStep < 2 ? _handleNext : _handleSubmit,
              isLoading: _isSubmitting,
              blur: 12,
              opacity: 0.9,
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              height: 52,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) return;
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImages.add(
            'https://picsum.photos/400/400?random=${_selectedImages.length}');
      });
    }
  }

  void _handleNext() {
    if (_currentStep == 1 && !_formKey.currentState!.validate()) return;
    setState(() => _currentStep++);
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(proNetworkRepositoryProvider);
      final (category, postType) = _mapCategory();

      await repository.createPost(
        category: category,
        postType: postType,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
        tags: _tags.isNotEmpty ? _tags : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Post created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(proNetworkPostsProvider);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  (ProfessionalCategory, ProfessionalPostType) _mapCategory() {
    switch (_selectedCategory) {
      case ProPostCategory.discussion:
        return (
          ProfessionalCategory.jobDiscussions,
          ProfessionalPostType.discussion
        );
      case ProPostCategory.portfolio:
        return (
          ProfessionalCategory.portfolioShowcase,
          ProfessionalPostType.portfolioItem
        );
      case ProPostCategory.skillExchange:
        return (
          ProfessionalCategory.skillExchange,
          ProfessionalPostType.skillOffer
        );
      case ProPostCategory.freelanceGig:
        return (
          ProfessionalCategory.freelanceOpportunities,
          ProfessionalPostType.freelanceGig
        );
      case ProPostCategory.event:
        return (ProfessionalCategory.events, ProfessionalPostType.event);
      case ProPostCategory.resource:
        return (ProfessionalCategory.tools, ProfessionalPostType.resource);
    }
  }

  String _getTitleHint() {
    switch (_selectedCategory) {
      case ProPostCategory.discussion:
        return 'e.g., Best practices for remote team management?';
      case ProPostCategory.portfolio:
        return 'e.g., Redesigned checkout flow - 23% conversion boost';
      case ProPostCategory.skillExchange:
        return 'e.g., Offering Python coaching, seeking Flutter mentoring';
      case ProPostCategory.freelanceGig:
        return 'e.g., Looking for React Native developers';
      case ProPostCategory.event:
        return 'e.g., Tech Meetup: Building Scalable Systems';
      case ProPostCategory.resource:
        return 'e.g., Top 10 productivity tools for developers';
    }
  }
}

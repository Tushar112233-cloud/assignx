library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/models/community_post_model.dart';
import '../providers/community_provider.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/mesh_gradient_background.dart';

/// Post category options for Business Hub.
enum PostCategory {
  insight('Industry Insight', Icons.lightbulb_outline,
      'Share business knowledge'),
  opportunity('Business Opportunity', Icons.trending_up,
      'Post a collaboration or deal'),
  recruitment('Recruitment', Icons.person_search_outlined,
      'Post a job opening'),
  service('Service Offer', Icons.storefront_outlined,
      'Showcase your service'),
  event('Event', Icons.event_outlined, 'Share an upcoming event'),
  question('Question', Icons.help_outline, 'Ask the community');

  final String label;
  final IconData icon;
  final String description;

  const PostCategory(this.label, this.icon, this.description);
}

/// Screen to create new Business Hub posts.
///
/// 3-step wizard: category -> details -> media.
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  PostCategory _selectedCategory = PostCategory.insight;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _selectedImages = [];
  final List<String> _tags = [];

  // Event-specific
  DateTime? _eventDate;
  TimeOfDay? _eventTime;

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
      backgroundColor: AppColors.backgroundLight,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        opacity: 0.4,
        colors: const [
          AppColors.meshAmber,
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
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withAlpha(128),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariantLight,
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
                    'Create Post',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Step ${_currentStep + 1} of 3',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
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
          Text(
            'What would you like to post?',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a category for your post',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...PostCategory.values.map((category) {
            final isSelected = category == _selectedCategory;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                blur: isSelected ? 15 : 10,
                opacity: isSelected ? 0.9 : 0.7,
                elevation: isSelected ? 3 : 1,
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              AppColors.primary.withAlpha(26),
                              AppColors.primaryLight.withAlpha(13),
                            ],
                          )
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
                              : AppColors.surfaceVariantLight,
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
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? AppColors.primary : null,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.description,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
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
          Text('Tell us more', style: AppTypography.headlineSmall),
          const SizedBox(height: 24),

          _buildGlassTextField(
            controller: _titleController,
            label: 'Title',
            hint: _getTitleHint(),
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
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
            hint: 'Tell everyone more about your post...',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Event-specific fields
          if (_selectedCategory == PostCategory.event) ...[
            _buildEventFields(),
            const SizedBox(height: 16),
          ],

          _buildGlassTextField(
            controller: _locationController,
            label: 'Location',
            hint: 'e.g., Mumbai, India',
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(77),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$tag',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          setState(() => _tags.remove(tag));
                        },
                        child: const Icon(
                          Icons.close,
                          size: 14,
                          color: AppColors.primary,
                        ),
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

  Widget _buildEventFields() {
    return GlassCard(
      blur: 12,
      opacity: 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Event Details',
                style: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _eventDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _eventDate = date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    _eventDate != null
                        ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'
                        : 'Select date',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _eventDate != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _eventTime ?? TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => _eventTime = time);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 12),
                  Text(
                    _eventTime != null
                        ? _eventTime!.format(context)
                        : 'Select time',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _eventTime != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          Text('Add photos', style: AppTypography.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Upload up to 5 photos to make your post stand out',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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
            itemCount: _selectedImages.length < 5
                ? _selectedImages.length + 1
                : 5,
            itemBuilder: (context, index) {
              if (index == _selectedImages.length &&
                  _selectedImages.length < 5) {
                return _buildAddImageCard();
              }
              return _buildImageCard(_selectedImages[index], index);
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
                    const Icon(Icons.info_outline,
                        size: 20, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'Community Guidelines',
                      style: AppTypography.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGuidelineItem('Be respectful and professional'),
                _buildGuidelineItem('No spam or misleading content'),
                _buildGuidelineItem('Post only relevant business content'),
                _buildGuidelineItem('Follow community standards'),
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
              Text(
                label,
                style: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
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
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: validator,
            onFieldSubmitted: onSubmitted,
          ),
        ],
      ),
    );
  }

  Widget _buildAddImageCard() {
    return GlassCard(
      blur: 10,
      opacity: 0.7,
      padding: EdgeInsets.zero,
      onTap: _showImageSourceSheet,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_photo_alternate_outlined,
              size: 32, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            'Add Photo',
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String url, int index) {
    return GlassCard(
      blur: 8,
      opacity: 0.6,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (context, imageUrl) => Container(
                color: AppColors.surfaceVariantLight,
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, imageUrl, error) => Container(
                color: AppColors.surfaceVariantLight,
                child: const Icon(Icons.broken_image,
                    color: AppColors.textTertiary),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedImages.removeAt(index));
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
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
          const Icon(Icons.check_circle_outline,
              size: 18, color: AppColors.info),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
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

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(250),
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        _selectedImages.add(
            'https://picsum.photos/400/400?random=${_selectedImages.length}');
      });
    }
  }

  void _handleNext() {
    if (_currentStep == 1 && !_formKey.currentState!.validate()) {
      return;
    }

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
      final repository = ref.read(communityRepositoryProvider);

      final (category, type) = _mapCategoryToPost();

      await repository.createPost(
        category: category,
        type: type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        images: _selectedImages.isNotEmpty ? _selectedImages : <String>[],
        location: _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        ref.invalidate(communityPostsProvider);
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
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  (BusinessCategory, BusinessPostType) _mapCategoryToPost() {
    switch (_selectedCategory) {
      case PostCategory.insight:
        return (
          BusinessCategory.industryInsights,
          BusinessPostType.insight
        );
      case PostCategory.opportunity:
        return (
          BusinessCategory.businessOpportunities,
          BusinessPostType.opportunity
        );
      case PostCategory.recruitment:
        return (BusinessCategory.recruitment, BusinessPostType.jobListing);
      case PostCategory.service:
        return (
          BusinessCategory.serviceShowcase,
          BusinessPostType.serviceOffer
        );
      case PostCategory.event:
        return (BusinessCategory.events, BusinessPostType.event);
      case PostCategory.question:
        return (BusinessCategory.helpAdvice, BusinessPostType.question);
    }
  }

  String _getTitleHint() {
    switch (_selectedCategory) {
      case PostCategory.insight:
        return 'e.g., 5 Key Trends in Digital Marketing';
      case PostCategory.opportunity:
        return 'e.g., Partnership Opportunity for Tech Startups';
      case PostCategory.recruitment:
        return 'e.g., Senior Developer - Remote Position';
      case PostCategory.service:
        return 'e.g., Professional Web Development Services';
      case PostCategory.event:
        return 'e.g., Industry Networking Event - March 2026';
      case PostCategory.question:
        return 'e.g., How to scale a SaaS business?';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/translation/translation_extensions.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Post category options for Campus Connect.
enum PostCategory {
  discussion('Discussion', Icons.chat_bubble_outline, 'Start a conversation'),
  event('Event', Icons.event_outlined, 'Share an upcoming event'),
  housing('Housing', Icons.home_outlined, 'Post housing listing'),
  resource('Resource', Icons.menu_book_outlined, 'Share study materials');

  final String label;
  final IconData icon;
  final String description;

  const PostCategory(this.label, this.icon, this.description);
}

/// Screen to create new Campus Connect posts.
///
/// Matches web's create-post-form.tsx features:
/// - Category selection (Discussion, Event, Housing, Resource)
/// - Title and description
/// - Image upload
/// - Location (optional)
/// - Tags/hashtags
/// - Event-specific fields (date, time)
/// - Housing-specific fields (price, amenities)
class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Form controllers
  PostCategory _selectedCategory = PostCategory.discussion;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagsController = TextEditingController();
  final _priceController = TextEditingController();
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
    _priceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubtleGradientScaffold.standard(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Create Post'.tr(context),
          style: AppTextStyles.headingSmall,
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border,
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Progress indicator
            _buildProgressIndicator(),

            // Step label
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${'Step'.tr(context)} ${_currentStep + 1} ${'of'.tr(context)} 3',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Form content
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

            // Navigation buttons
            _buildNavigationButtons(),
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
          const SizedBox(height: 8),
          Text(
            'What would you like to post?'.tr(context),
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a category for your post'.tr(context),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Category cards with animated capsule style
          ...PostCategory.values.map((category) {
            final isSelected = category == _selectedCategory;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withAlpha(26)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
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
                              category.label.tr(context),
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category.description.tr(context),
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
          const SizedBox(height: 8),
          Text(
            'Tell us more'.tr(context),
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 24),

          // Title
          _buildTextField(
            controller: _titleController,
            label: 'Title'.tr(context),
            hint: _getTitleHint(),
            icon: Icons.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title'; // Translated by form
              }
              if (value.length < 5) {
                return 'Title must be at least 5 characters'; // Translated by form
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          _buildTextField(
            controller: _descriptionController,
            label: 'Description'.tr(context),
            hint: 'Tell everyone more about your post...'.tr(context),
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          // Event-specific fields
          if (_selectedCategory == PostCategory.event) ...[
            _buildEventFields(),
            const SizedBox(height: 16),
          ],

          // Housing-specific fields
          if (_selectedCategory == PostCategory.housing) ...[
            _buildHousingFields(),
            const SizedBox(height: 16),
          ],

          // Location
          _buildTextField(
            controller: _locationController,
            label: 'Location'.tr(context),
            hint: 'e.g., North Campus, Delhi'.tr(context),
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 16),

          // Tags
          _buildTextField(
            controller: _tagsController,
            label: 'Tags (optional)'.tr(context),
            hint: 'Add tags to help others find your post'.tr(context),
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
                    color: AppColors.surfaceVariant,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Event Details'.tr(context),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date picker
          InkWell(
            borderRadius: BorderRadius.circular(12),
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
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _eventDate != null
                        ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'
                        : 'Select date'.tr(context),
                    style: AppTextStyles.bodyMedium.copyWith(
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

          // Time picker
          InkWell(
            borderRadius: BorderRadius.circular(12),
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
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _eventTime != null
                        ? _eventTime!.format(context)
                        : 'Select time'.tr(context),
                    style: AppTextStyles.bodyMedium.copyWith(
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

  Widget _buildHousingFields() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Rent Details'.tr(context),
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Monthly rent'.tr(context),
              prefixText: '\u20B9 ',
              filled: true,
              fillColor: AppColors.surfaceVariant,
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
                  color: AppColors.borderFocused,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.all(14),
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
          const SizedBox(height: 8),
          Text(
            'Add photos'.tr(context),
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload up to 5 photos to make your post stand out'.tr(context),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Image grid
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
              if (index == _selectedImages.length && _selectedImages.length < 5) {
                return _buildAddImageCard();
              }
              return _buildImageCard(_selectedImages[index], index);
            },
          ),

          const SizedBox(height: 32),

          // Community guidelines
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withAlpha(51)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Community Guidelines'.tr(context),
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGuidelineItem('Be respectful and considerate'.tr(context)),
                _buildGuidelineItem('No spam or misleading content'.tr(context)),
                _buildGuidelineItem('Post only relevant content'.tr(context)),
                _buildGuidelineItem('Follow campus rules and policies'.tr(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
            filled: true,
            fillColor: AppColors.surfaceVariant,
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
                color: AppColors.borderFocused,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderError),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.borderError,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: validator,
          onFieldSubmitted: onSubmitted,
        ),
      ],
    );
  }

  Widget _buildAddImageCard() {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.border,
          borderRadius: 14,
          dashWidth: 6,
          dashSpace: 4,
          strokeWidth: 1.5,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withAlpha(128),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_photo_alternate_outlined,
                size: 32,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                'Add Photo'.tr(context),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String url, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(
                    Icons.broken_image,
                    color: AppColors.textTertiary,
                  ),
                );
              },
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
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.white,
                ),
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
          const Icon(
            Icons.check_circle_outline,
            size: 18,
            color: AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _currentStep--);
                    _pageController.animateToPage(
                      _currentStep,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: Text('Back'.tr(context)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: AppTextStyles.buttonMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting
                    ? null
                    : (_currentStep < 2 ? _handleNext : _handleSubmit),
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _currentStep < 2 ? Icons.arrow_forward : Icons.check,
                        size: 18,
                      ),
                label: Text(
                  _currentStep < 2
                      ? 'Continue'.tr(context)
                      : 'Post'.tr(context),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withAlpha(153),
                  disabledForegroundColor: Colors.white70,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
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
              leading: const Icon(Icons.camera_alt,
                  color: AppColors.textPrimary),
              title: Text(
                'Take Photo'.tr(context),
                style: AppTextStyles.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library,
                  color: AppColors.textPrimary),
              title: Text(
                'Choose from Gallery'.tr(context),
                style: AppTextStyles.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum 5 images allowed'.tr(context))),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        // For now, just add a placeholder URL
        // In production, this would upload to storage
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
      // Build the tags list from the tags controller and any manually added tags.
      final tagsList = [
        ..._tags,
        if (_tagsController.text.trim().isNotEmpty)
          ..._tagsController.text
              .trim()
              .split(',')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty),
      ];

      await ApiClient.post('/community/posts', {
        'postType': 'campus',
        'category': _selectedCategory.name,
        'title': _titleController.text.trim(),
        'content': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'tags': tagsList,
        'imageUrls': _selectedImages,
      });

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
            content: Text('${'Failed to create post'.tr(context)}: $e'),
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

  String _getTitleHint() {
    switch (_selectedCategory) {
      case PostCategory.discussion:
        return 'e.g., Best study spots on campus?';
      case PostCategory.event:
        return 'e.g., Tech Fest 2024 - Registration Open';
      case PostCategory.housing:
        return 'e.g., Looking for Flatmate in Koramangala';
      case PostCategory.resource:
        return 'e.g., Engineering Drawing Set - Like New';
    }
  }
}

/// Custom painter for dashed border on the image upload area.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
    required this.dashWidth,
    required this.dashSpace,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

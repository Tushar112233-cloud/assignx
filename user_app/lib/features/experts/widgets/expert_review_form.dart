import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';

/// Expert review form widget with 5-star rating and tag chips.
///
/// Features:
/// - Animated 5-star rating system
/// - Multiline text review field (500 char max)
/// - Selectable tag chips for quick feedback
/// - Submit button with loading state
/// - Glassmorphic dark theme design
class ExpertReviewForm extends ConsumerStatefulWidget {
  /// Expert ID to review.
  final String expertId;

  /// Booking ID associated with the review.
  final String bookingId;

  /// Expert name for display.
  final String expertName;

  /// Called when review is submitted successfully.
  final VoidCallback? onSubmitted;

  /// Called when form is cancelled.
  final VoidCallback? onCancel;

  const ExpertReviewForm({
    super.key,
    required this.expertId,
    required this.bookingId,
    required this.expertName,
    this.onSubmitted,
    this.onCancel,
  });

  @override
  ConsumerState<ExpertReviewForm> createState() => _ExpertReviewFormState();
}

class _ExpertReviewFormState extends ConsumerState<ExpertReviewForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reviewController = TextEditingController();

  int _rating = 0;
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  late AnimationController _starAnimationController;
  late List<Animation<double>> _starAnimations;

  /// Available review tags.
  static const List<String> _reviewTags = [
    'Helpful',
    'Knowledgeable',
    'Patient',
    'Clear Explanation',
    'Would Recommend',
  ];

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create staggered animations for each star
    _starAnimations = List.generate(5, (index) {
      final start = index * 0.1;
      final end = start + 0.4;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _starAnimationController,
          curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
              curve: Curves.elasticOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _starAnimationController.dispose();
    super.dispose();
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
    _starAnimationController.forward(from: 0);
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Save review to Supabase expert_reviews table
      // final supabase = Supabase.instance.client;
      // await supabase.from('expert_reviews').insert({
      //   'expert_id': widget.expertId,
      //   'booking_id': widget.bookingId,
      //   'user_id': supabase.auth.currentUser!.id,
      //   'rating': _rating,
      //   'comment': _reviewController.text.trim(),
      //   'tags': _selectedTags.toList(),
      //   'created_at': DateTime.now().toIso8601String(),
      // });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        widget.onSubmitted?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit review: $e'),
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
    return GlassContainerVariants.dark(
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rate Your Experience',
                        style: AppTextStyles.headingSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'How was your session with ${widget.expertName}?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.onCancel != null)
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close, color: Colors.white70),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Star Rating
            _buildStarRating(),
            const SizedBox(height: 20),

            // Tag Chips
            _buildTagChips(),
            const SizedBox(height: 20),

            // Review Text Field
            _buildReviewTextField(),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rating',
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starIndex = index + 1;
            final isSelected = starIndex <= _rating;

            return AnimatedBuilder(
              animation: _starAnimations[index],
              builder: (context, child) {
                final scale = isSelected
                    ? 1.0 + (_starAnimations[index].value * 0.2)
                    : 1.0;

                return GestureDetector(
                  onTap: () => _setRating(starIndex),
                  child: Transform.scale(
                    scale: scale,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 44,
                        color: isSelected
                            ? AppColors.warning
                            : Colors.white.withAlpha(100),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        if (_rating > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text(
                _getRatingText(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent!';
      default:
        return '';
    }
  }

  Widget _buildTagChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What did you like?',
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _reviewTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);

            return GestureDetector(
              onTap: () => _toggleTag(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withAlpha(40),
                  ),
                ),
                child: Text(
                  tag,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewTextField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Review (Optional)',
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_reviewController.text.length}/500',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(30),
            ),
          ),
          child: TextFormField(
            controller: _reviewController,
            maxLines: 4,
            maxLength: 500,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: 'Share your experience with this expert...',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white38,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              counterText: '',
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'Review must be 500 characters or less';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _isSubmitting || _rating == 0
            ? AppColors.neutralGray
            : AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: _isSubmitting || _rating == 0 ? null : _submitReview,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Submit Review',
                    style: AppTextStyles.buttonMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

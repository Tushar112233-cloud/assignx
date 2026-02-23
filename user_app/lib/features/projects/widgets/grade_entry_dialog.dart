import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Grade entry dialog widget
/// Allows users to enter their received grade after project completion
/// Implements U38 from feature spec
class GradeEntryDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String projectNumber;
  final String? existingGrade;
  final double? existingRating;
  final Function(String grade, double rating, String? feedback)? onSubmit;

  const GradeEntryDialog({
    super.key,
    required this.projectId,
    required this.projectNumber,
    this.existingGrade,
    this.existingRating,
    this.onSubmit,
  });

  @override
  ConsumerState<GradeEntryDialog> createState() => _GradeEntryDialogState();
}

class _GradeEntryDialogState extends ConsumerState<GradeEntryDialog> {
  late String _selectedGrade;
  late double _rating;
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  /// Available grade options
  final List<String> _gradeOptions = [
    'A+',
    'A',
    'A-',
    'B+',
    'B',
    'B-',
    'C+',
    'C',
    'C-',
    'D',
    'F',
    'Pass',
    'Distinction',
    'Credit',
    'Pending',
  ];

  @override
  void initState() {
    super.initState();
    _selectedGrade = widget.existingGrade ?? 'A';
    _rating = widget.existingRating ?? 5.0;
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  /// Handle form submission
  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      // In production: POST to API to save grade
      await Future.delayed(const Duration(milliseconds: 500));

      widget.onSubmit?.call(
        _selectedGrade,
        _rating,
        _feedbackController.text.isNotEmpty ? _feedbackController.text : null,
      );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Grade saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save grade: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Build star rating widget
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isHalf = _rating - index > 0 && _rating - index < 1;
        final isFilled = _rating >= starValue;

        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = starValue.toDouble();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isHalf
                  ? Icons.star_half
                  : (isFilled ? Icons.star : Icons.star_border),
              size: 36,
              color: isFilled || isHalf ? Colors.amber : Colors.grey[400],
            ),
          ),
        );
      }),
    );
  }

  /// Build grade chip
  Widget _buildGradeChip(String grade) {
    final isSelected = _selectedGrade == grade;
    return GestureDetector(
      onTap: () => setState(() => _selectedGrade = grade),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[300]!,
          ),
        ),
        child: Text(
          grade,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.school,
                      color: Colors.green[700],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Your Grade',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.projectNumber,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Grade Selection
              Text(
                'What grade did you receive?',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gradeOptions.map(_buildGradeChip).toList(),
              ),
              const SizedBox(height: 24),

              // Rating
              Text(
                'Rate your experience',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildStarRating(),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _getRatingLabel(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Feedback (optional)
              Text(
                'Feedback (optional)',
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Share your experience with the expert...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your grade and feedback help improve our services',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save Grade'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get rating label
  String _getRatingLabel() {
    if (_rating >= 5) return 'Excellent';
    if (_rating >= 4) return 'Very Good';
    if (_rating >= 3) return 'Good';
    if (_rating >= 2) return 'Fair';
    return 'Poor';
  }
}

/// Show grade entry dialog
Future<bool?> showGradeEntryDialog(
  BuildContext context, {
  required String projectId,
  required String projectNumber,
  String? existingGrade,
  double? existingRating,
  Function(String grade, double rating, String? feedback)? onSubmit,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => GradeEntryDialog(
      projectId: projectId,
      projectNumber: projectNumber,
      existingGrade: existingGrade,
      existingRating: existingRating,
      onSubmit: onSubmit,
    ),
  );
}

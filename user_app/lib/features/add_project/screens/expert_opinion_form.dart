import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/project_provider.dart';
import '../widgets/budget_display.dart';
import '../widgets/file_attachment.dart';
import '../widgets/subject_dropdown.dart';
import '../widgets/success_popup.dart';

/// Expertise level required.
enum ExpertiseLevel {
  basic('Basic Review', 'General feedback and suggestions', 299),
  intermediate('Detailed Analysis', 'In-depth review with recommendations', 499),
  expert('Expert Consultation', 'Comprehensive expert evaluation', 799);

  final String title;
  final String description;
  final double price;

  const ExpertiseLevel(this.title, this.description, this.price);
}

/// Feedback type options.
enum FeedbackType {
  written('Written Feedback', Icons.description_outlined),
  videoCall('Video Call (30 min)', Icons.video_call_outlined),
  both('Written + Video Call', Icons.forum_outlined);

  final String title;
  final IconData icon;

  const FeedbackType(this.title, this.icon);
}

/// Expert opinion request form with beautiful gradient design.
class ExpertOpinionForm extends ConsumerStatefulWidget {
  const ExpertOpinionForm({super.key});

  @override
  ConsumerState<ExpertOpinionForm> createState() => _ExpertOpinionFormState();
}

class _ExpertOpinionFormState extends ConsumerState<ExpertOpinionForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form data
  ProjectSubject? _subject;
  ExpertiseLevel? _expertiseLevel;
  FeedbackType _feedbackType = FeedbackType.written;
  List<AttachmentFile> _attachments = [];

  final _questionController = TextEditingController();
  final _contextController = TextEditingController();

  @override
  void dispose() {
    _questionController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  /// Submits the expert opinion request.
  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_expertiseLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an expertise level'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final project = await ref.read(projectNotifierProvider.notifier).createProject(
        title: 'Expert Consultation: ${_questionController.text.trim().length > 50 ? '${_questionController.text.trim().substring(0, 50)}...' : _questionController.text.trim()}',
        description: _contextController.text.trim().isNotEmpty
            ? _contextController.text.trim()
            : null,
        serviceType: ServiceType.expertOpinion,
        subjectId: _subject?.id,
        deadline: DateTime.now().add(const Duration(days: 3)),
        specificInstructions: 'Question: ${_questionController.text.trim()}\n'
            'Expertise Level: ${_expertiseLevel?.title ?? 'Not selected'}\n'
            'Feedback Type: ${_feedbackType.title}',
      );

      if (!mounted) return;

      final projectId = project?.id ?? '';

      await SuccessPopup.show(
        context,
        title: 'Request Submitted!',
        message: 'Your expert consultation request has been submitted. An expert will be assigned within 24 hours.',
        projectId: projectId,
        onViewProject: () {
          context.go('/projects/$projectId');
        },
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Ask Expert',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.shade600,
                  Colors.purple.shade400,
                  Colors.deepPurple.shade400,
                ],
              ),
            ),
          ),

          // Content with glass morphism
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header with icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade50,
                            Colors.deepPurple.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.purple.shade600, Colors.deepPurple.shade400],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.psychology_outlined,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expert Consultation',
                                  style: AppTextStyles.labelLarge.copyWith(
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get personalized guidance from subject experts',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Subject
                    _buildSectionLabel('Subject Area', Icons.school_outlined),
                    const SizedBox(height: 8),
                    SubjectDropdown(
                      value: _subject,
                      onChanged: (value) => setState(() => _subject = value),
                    ),
                    const SizedBox(height: 24),

                    // Your question
                    _buildSectionLabel('Your Question', Icons.help_outline),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _questionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'What would you like expert guidance on?',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 10) {
                          return 'Please describe your question (min 10 characters)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Context/background
                    _buildSectionLabel('Context & Background', Icons.notes),
                    const SizedBox(height: 4),
                    Text(
                      'Help the expert understand your situation better',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _contextController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'e.g., I\'m working on my thesis about... My current approach is...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Attachments
                    _buildSectionLabel('Reference Documents', Icons.attach_file),
                    const SizedBox(height: 8),
                    FileAttachment(
                      files: _attachments,
                      onChanged: (files) => setState(() => _attachments = files),
                      label: 'Reference Documents',
                      hint: 'Upload relevant documents for the expert to review (optional)',
                      maxFiles: 3,
                      maxSizeMB: 20,
                    ),
                    const SizedBox(height: 24),

                    // Expertise level
                    _buildSectionLabel('Expertise Level', Icons.star_outline),
                    const SizedBox(height: 12),
                    ...ExpertiseLevel.values.map(
                      (level) => _ExpertiseLevelCard(
                        level: level,
                        isSelected: _expertiseLevel == level,
                        onTap: () => setState(() => _expertiseLevel = level),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feedback type
                    _buildSectionLabel('Preferred Feedback', Icons.message_outlined),
                    const SizedBox(height: 12),
                    Row(
                      children: FeedbackType.values.map((type) {
                        final isSelected = _feedbackType == type;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _feedbackType = type),
                            child: Container(
                              margin: EdgeInsets.only(
                                right: type != FeedbackType.both ? 8 : 0,
                              ),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Colors.purple.shade50,
                                          Colors.white,
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? Colors.purple.shade600 : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    type.icon,
                                    color: isSelected
                                        ? Colors.purple.shade600
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    type.title,
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected
                                          ? Colors.purple.shade700
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Price summary
                    BudgetCard(
                      price: _calculateTotalPrice(),
                      subtitle: 'Total Price',
                    ),
                    const SizedBox(height: 16),

                    // Submit button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple.shade600, Colors.deepPurple.shade400],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                'Submit Request',
                                style: AppTextStyles.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.purple.shade700),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  double? _calculateTotalPrice() {
    if (_expertiseLevel == null) return null;
    double total = _expertiseLevel!.price;

    switch (_feedbackType) {
      case FeedbackType.written:
        break;
      case FeedbackType.videoCall:
        total += 200;
        break;
      case FeedbackType.both:
        total += 300;
        break;
    }

    return total;
  }
}

class _ExpertiseLevelCard extends StatelessWidget {
  final ExpertiseLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpertiseLevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    Colors.purple.shade50,
                    Colors.white,
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.purple.shade600 : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    )
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected ? Colors.purple.shade700 : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    level.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${level.price.toInt()}',
              style: AppTextStyles.headingSmall.copyWith(
                color: isSelected ? Colors.purple.shade700 : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

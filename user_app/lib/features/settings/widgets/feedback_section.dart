import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

import '../../../core/constants/app_text_styles.dart';

// ============================================================
// DESIGN CONSTANTS
// ============================================================

class _FeedbackColors {
  static const cardBackground = Color(0xFFFFFFFF);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF6B6B6B);
  static const mutedText = Color(0xFF8B8B8B);
  static const actionBlue = Color(0xFF2196F3);
  static const iconBackground = Color(0xFFE0F2FE);
  static const chipBackground = Color(0xFFF5F5F5);
}

// ============================================================
// WIDGET
// ============================================================

/// Send Feedback section card for the settings screen.
/// Provides a form to submit bug reports, feature requests, or general feedback.
class FeedbackSection extends ConsumerStatefulWidget {
  const FeedbackSection({super.key});

  @override
  ConsumerState<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends ConsumerState<FeedbackSection> {
  final _feedbackController = TextEditingController();
  String _selectedType = 'general';
  bool _isSending = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _FeedbackColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _FeedbackColors.iconBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.feedback_outlined,
                    size: 20,
                    color: _FeedbackColors.secondaryText,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Feedback',
                        style: AppTextStyles.headingSmall.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: _FeedbackColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Help us improve',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 13,
                          color: _FeedbackColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Feedback Type Chips
            Row(
              children: [
                _FeedbackTypeChip(
                  label: 'Bug',
                  icon: Icons.bug_report_outlined,
                  isSelected: _selectedType == 'bug',
                  onTap: () => setState(() => _selectedType = 'bug'),
                ),
                const SizedBox(width: 8),
                _FeedbackTypeChip(
                  label: 'Feature',
                  icon: Icons.lightbulb_outline,
                  isSelected: _selectedType == 'feature',
                  onTap: () => setState(() => _selectedType = 'feature'),
                ),
                const SizedBox(width: 8),
                _FeedbackTypeChip(
                  label: 'General',
                  icon: Icons.chat_bubble_outline,
                  isSelected: _selectedType == 'general',
                  onTap: () => setState(() => _selectedType = 'general'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Feedback Text Field
            TextFormField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: _FeedbackColors.mutedText,
                ),
                filled: true,
                fillColor: _FeedbackColors.chipBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSending ? null : _handleSendFeedback,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _FeedbackColors.actionBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor:
                      _FeedbackColors.actionBlue.withValues(alpha: 0.5),
                ),
                icon: _isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, size: 18),
                label: Text(
                  _isSending ? 'Sending...' : 'Send Feedback',
                  style: AppTextStyles.buttonMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles sending feedback via the API.
  Future<void> _handleSendFeedback() async {
    final message = _feedbackController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      await ApiClient.post('/feedback', {
        'feedback_type': _selectedType,
        'message': message,
      });

      if (mounted) {
        _feedbackController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thank you for your feedback!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }
}

// ============================================================
// PRIVATE WIDGETS
// ============================================================

/// Feedback type selection chip.
class _FeedbackTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FeedbackTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _FeedbackColors.actionBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? _FeedbackColors.actionBlue
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color:
                  isSelected ? Colors.white : _FeedbackColors.secondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : _FeedbackColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

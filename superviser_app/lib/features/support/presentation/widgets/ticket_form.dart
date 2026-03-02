import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/translation/translation_extensions.dart';
import '../../data/models/ticket_model.dart';

/// Ticket creation form widget.
class TicketForm extends StatefulWidget {
  const TicketForm({
    super.key,
    this.onSubmit,
    this.isSubmitting = false,
  });

  final Future<void> Function({
    required String subject,
    required String description,
    required TicketCategory category,
    required TicketPriority priority,
  })? onSubmit;
  final bool isSubmitting;

  @override
  State<TicketForm> createState() => _TicketFormState();
}

class _TicketFormState extends State<TicketForm> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  TicketCategory _selectedCategory = TicketCategory.general;
  TicketPriority _selectedPriority = TicketPriority.normal;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      await widget.onSubmit?.call(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        priority: _selectedPriority,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Category selection
          Text(
            'Category'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TicketCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(category.displayName),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _selectedCategory = category);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Subject field
          TextFormField(
            controller: _subjectController,
            decoration: InputDecoration(
              labelText: 'Subject'.tr(context),
              hintText: 'Brief description of your issue'.tr(context),
              prefixIcon: const Icon(Icons.subject),
            ),
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a subject'.tr(context);
              }
              if (value.trim().length < 5) {
                return 'Subject must be at least 5 characters'.tr(context);
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description'.tr(context),
              hintText: 'Provide details about your issue...'.tr(context),
              alignLabelWithHint: true,
            ),
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a description'.tr(context);
              }
              if (value.trim().length < 20) {
                return 'Description must be at least 20 characters'.tr(context);
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Priority selection
          Text(
            'Priority'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: TicketPriority.values.map((priority) {
              final isSelected = _selectedPriority == priority;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flag,
                          size: 14,
                          color: isSelected
                              ? priority.color
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          priority.displayName,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedPriority = priority);
                    },
                    selectedColor: priority.color.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? priority.color
                          : AppColors.textSecondaryLight,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Submit button
          FilledButton(
            onPressed: widget.isSubmitting ? null : _handleSubmit,
            child: widget.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text('Submit Ticket'.tr(context)),
          ),

          const SizedBox(height: 16),

          // Info text
          Text(
            'Our support team typically responds within 24 hours.'.tr(context),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Message input widget for ticket detail.
class TicketMessageInput extends StatefulWidget {
  const TicketMessageInput({
    super.key,
    required this.onSend,
    this.isSending = false,
    this.enabled = true,
  });

  final void Function(String message) onSend;
  final bool isSending;
  final bool enabled;

  @override
  State<TicketMessageInput> createState() => _TicketMessageInputState();
}

class _TicketMessageInputState extends State<TicketMessageInput> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() => _hasText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSend(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          IconButton(
            onPressed: widget.enabled ? () {} : null,
            icon: const Icon(Icons.attach_file),
            color: AppColors.textSecondaryLight,
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              decoration: InputDecoration(
                hintText: 'Type a message...'.tr(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              onSubmitted: widget.enabled ? (_) => _handleSend() : null,
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: widget.isSending
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    onPressed: widget.enabled && _hasText ? _handleSend : null,
                    icon: Icon(
                      Icons.send,
                      color: _hasText && widget.enabled
                          ? AppColors.primary
                          : AppColors.textSecondaryLight,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget.
class TicketMessageBubble extends StatelessWidget {
  const TicketMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  final TicketMessage message;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppColors.primary
              : AppColors.textSecondaryLight.withValues(alpha: 0.1),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isCurrentUser
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isCurrentUser
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender name (for support messages)
            if (!isCurrentUser && message.senderName != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.support_agent,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    message.senderName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],

            // Message text
            Text(
              message.message,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),

            // Time
            const SizedBox(height: 4),
            Text(
              message.timeString,
              style: TextStyle(
                fontSize: 10,
                color: isCurrentUser
                    ? Colors.white.withValues(alpha: 0.7)
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Close ticket dialog.
class CloseTicketDialog extends StatefulWidget {
  const CloseTicketDialog({
    super.key,
    required this.onClose,
  });

  final void Function({int? rating, String? feedback}) onClose;

  @override
  State<CloseTicketDialog> createState() => _CloseTicketDialogState();
}

class _CloseTicketDialogState extends State<CloseTicketDialog> {
  int? _rating;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Close Ticket'.tr(context)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How was your support experience?'.tr(context)),
          const SizedBox(height: 16),

          // Star rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                onPressed: () => setState(() => _rating = star),
                icon: Icon(
                  star <= (_rating ?? 0) ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Feedback
          TextField(
            controller: _feedbackController,
            decoration: InputDecoration(
              labelText: 'Feedback (optional)'.tr(context),
              hintText: 'Any additional comments...'.tr(context),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'.tr(context)),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onClose(
              rating: _rating,
              feedback: _feedbackController.text.trim().isEmpty
                  ? null
                  : _feedbackController.text.trim(),
            );
          },
          child: Text('Close Ticket'.tr(context)),
        ),
      ],
    );
  }
}

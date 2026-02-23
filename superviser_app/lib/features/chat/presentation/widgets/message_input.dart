import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../data/models/message_model.dart';

/// Text input widget for composing messages.
///
/// Supports text input, file attachments, replies, and contact info detection.
/// Implements S39 - Contact Sharing Prevention feature.
class MessageInput extends StatefulWidget {
  const MessageInput({
    super.key,
    required this.onSend,
    this.onAttachment,
    this.replyTo,
    this.onCancelReply,
    this.enabled = true,
    this.isSending = false,
    this.disabledMessage,
  });

  /// Called when a message is sent
  final Future<void> Function(String message) onSend;

  /// Called when attachment button is tapped
  final VoidCallback? onAttachment;

  /// Message being replied to
  final MessageModel? replyTo;

  /// Called when reply is cancelled
  final VoidCallback? onCancelReply;

  /// Whether input is enabled
  final bool enabled;

  /// Whether a message is being sent
  final bool isSending;

  /// Message to show when disabled
  final String? disabledMessage;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  ContactDetectionResult? _contactWarning;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    final hasText = text.trim().isNotEmpty;

    // Detect contact information
    final detection = ContactDetector.detect(text);

    setState(() {
      _hasText = hasText;
      _contactWarning = detection.detected ? detection : null;
    });
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // If contact info detected, show warning dialog
    if (_contactWarning?.detected == true) {
      final proceed = await _showContactWarningDialog();
      if (!proceed) return;
    }

    _controller.clear();
    _contactWarning = null;
    await widget.onSend(text);
  }

  Future<bool> _showContactWarningDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Contact Information Detected'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your message appears to contain a ${ContactDetector.getTypeLabel(_contactWarning!.type!)}.',
            ),
            const SizedBox(height: 12),
            const Text(
              'Sharing personal contact details is against our policies and may result in account suspension.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text(
              'If you send this message, it will be flagged for review.',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Edit Message'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Send Anyway'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview
            if (widget.replyTo != null) _ReplyPreview(
              message: widget.replyTo!,
              onCancel: widget.onCancelReply,
            ),
            // Disabled message
            if (!widget.enabled && widget.disabledMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: Colors.orange.withValues(alpha: 0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.disabledMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange.shade800,
                          ),
                    ),
                  ],
                ),
              ),
            // Contact warning banner (S39 - Contact Sharing Prevention)
            if (_contactWarning?.detected == true)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: Colors.red.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Contact information detected',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'Sharing ${ContactDetector.getTypeLabel(_contactWarning!.type!)} is not allowed',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.red.shade600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Input row
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Attachment button
                  if (widget.onAttachment != null)
                    IconButton(
                      onPressed: widget.enabled ? widget.onAttachment : null,
                      icon: const Icon(Icons.attach_file),
                      color: AppColors.textSecondaryLight,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  const SizedBox(width: 8),
                  // Text field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(24),
                        border: _contactWarning?.detected == true
                            ? Border.all(color: Colors.red, width: 1.5)
                            : null,
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: widget.enabled
                              ? 'Type a message...'
                              : 'Messaging disabled',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondaryLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: widget.isSending
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : IconButton(
                            onPressed:
                                widget.enabled && _hasText ? _handleSend : null,
                            icon: Icon(
                              Icons.send_rounded,
                              color: _hasText && widget.enabled
                                  ? AppColors.primary
                                  : AppColors.textSecondaryLight,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: _hasText && widget.enabled
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : null,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reply preview widget.
class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({
    required this.message,
    this.onCancel,
  });

  final MessageModel message;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.senderName ?? 'Unknown',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  message.displayContent,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textSecondaryLight,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

/// Typing indicator widget.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final offset = (index * 0.2) + (_controller.value * 2);
                    final y = (offset % 1) < 0.5
                        ? (offset % 1) * -8
                        : (1 - (offset % 1)) * -8;
                    return Transform.translate(
                      offset: Offset(0, y),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.only(left: index == 0 ? 0 : 4),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondaryLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/glass_container.dart';

/// Types of policy violations that can be detected in chat messages.
enum ViolationType {
  /// Phone number detected
  phone,

  /// Email address detected
  email,

  /// Social media handle detected
  socialMedia,
}

/// Extension to provide display information for violation types.
extension ViolationTypeExtension on ViolationType {
  /// Icon data for the violation type.
  IconData get icon {
    switch (this) {
      case ViolationType.phone:
        return Icons.phone_outlined;
      case ViolationType.email:
        return Icons.email_outlined;
      case ViolationType.socialMedia:
        return Icons.alternate_email;
    }
  }

  /// Detection message for the violation type.
  String get detectedText {
    switch (this) {
      case ViolationType.phone:
        return 'We detected a phone number in your message.';
      case ViolationType.email:
        return 'We detected an email address in your message.';
      case ViolationType.socialMedia:
        return 'We detected a social media handle in your message.';
    }
  }
}

/// A professional, glassmorphic bottom sheet dialog that appears when users
/// attempt to share personal contact information in project chats.
///
/// Features:
/// - Educational, non-accusatory messaging
/// - Clear explanation of why the message was blocked
/// - Options to edit or cancel
/// - Coffee Bean themed design with glass morphism
/// - Animated entrance
///
/// Example usage:
/// ```dart
/// await showViolationPopup(
///   context: context,
///   violationType: ViolationType.phone,
///   onEdit: () {
///     // Focus back on the input field
///     _messageController.clear();
///     _focusNode.requestFocus();
///   },
/// );
/// ```
class ViolationPopup extends StatefulWidget {
  /// The type of violation detected.
  final ViolationType violationType;

  /// Callback when the user wants to edit their message.
  final VoidCallback? onEdit;

  /// Callback when the dialog is dismissed.
  final VoidCallback? onDismiss;

  const ViolationPopup({
    super.key,
    required this.violationType,
    this.onEdit,
    this.onDismiss,
  });

  @override
  State<ViolationPopup> createState() => _ViolationPopupState();
}

class _ViolationPopupState extends State<ViolationPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Haptic feedback on show
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _animationController.reverse().then((_) {
      widget.onDismiss?.call();
      Navigator.of(context).pop();
    });
  }

  void _handleEdit() {
    HapticFeedback.lightImpact();
    widget.onEdit?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: bottomPadding + AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 40,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  _buildHandle(),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Shield icon
                        _buildShieldIcon(),

                        const SizedBox(height: AppSpacing.md),

                        // Title
                        Text(
                          'Message Not Sent',
                          style: AppTextStyles.headlineSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Main description
                        Text(
                          'For your protection and privacy, sharing personal contact information is not allowed in project chats. All communication should remain within the AssignX platform.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // Detection badge
                        _buildDetectionBadge(),

                        const SizedBox(height: AppSpacing.md),

                        // Privacy note
                        _buildPrivacyNote(),

                        const SizedBox(height: AppSpacing.lg),

                        // Action buttons
                        _buildActionButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: _handleDismiss,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildShieldIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.warning.withValues(alpha: 0.15),
              AppColors.warning.withValues(alpha: 0.08),
            ],
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.2),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          Icons.shield_outlined,
          size: 36,
          color: AppColors.warning,
        ),
      ),
    );
  }

  Widget _buildDetectionBadge() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withValues(alpha: 0.12),
            AppColors.warning.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(
              widget.violationType.icon,
              size: 22,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              widget.violationType.detectedText,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.warning.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'This policy helps protect both you and your assigned expert from potential risks associated with sharing personal information outside the platform.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textTertiary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel button
        Expanded(
          child: OutlinedButton(
            onPressed: _handleDismiss,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              side: BorderSide(
                color: AppColors.border,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Cancel',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.md),

        // Edit button
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.accent,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _handleEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.textOnPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Edit Message',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shows the violation popup as a modal bottom sheet.
///
/// Returns a [Future] that completes when the popup is dismissed.
///
/// Example:
/// ```dart
/// await showViolationPopup(
///   context: context,
///   violationType: ViolationType.email,
///   onEdit: () {
///     // Handle edit action
///   },
/// );
/// ```
Future<void> showViolationPopup({
  required BuildContext context,
  required ViolationType violationType,
  VoidCallback? onEdit,
  VoidCallback? onDismiss,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => ViolationPopup(
      violationType: violationType,
      onEdit: onEdit,
      onDismiss: onDismiss,
    ),
  );
}

/// Utility function to detect personal information in a message.
///
/// Returns the [ViolationType] if a violation is detected, or null otherwise.
///
/// Checks for:
/// - Phone numbers (various international formats)
/// - Email addresses
/// - Social media handles and links
ViolationType? detectViolation(String message) {
  // Phone number patterns
  final phonePatterns = [
    RegExp(r'\+?\d{1,4}[-.\s]?\(?\d{1,3}\)?[-.\s]?\d{1,4}[-.\s]?\d{1,4}[-.\s]?\d{1,9}'),
    RegExp(r'\b\d{10,12}\b'),
    RegExp(r'\(\d{3}\)\s*\d{3}[-.\s]?\d{4}'),
  ];

  // Email pattern
  final emailPattern = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');

  // Social media patterns
  final socialMediaPatterns = [
    RegExp(r'@[a-zA-Z0-9_]{3,}'),
    RegExp(r'instagram\.com/[a-zA-Z0-9_.]+', caseSensitive: false),
    RegExp(r'twitter\.com/[a-zA-Z0-9_]+', caseSensitive: false),
    RegExp(r'x\.com/[a-zA-Z0-9_]+', caseSensitive: false),
    RegExp(r'facebook\.com/[a-zA-Z0-9.]+', caseSensitive: false),
    RegExp(r'linkedin\.com/in/[a-zA-Z0-9-]+', caseSensitive: false),
    RegExp(r'wa\.me/\d+', caseSensitive: false),
    RegExp(r't\.me/[a-zA-Z0-9_]+', caseSensitive: false),
    RegExp(r'telegram\.me/[a-zA-Z0-9_]+', caseSensitive: false),
  ];

  // Check for phone numbers
  for (final pattern in phonePatterns) {
    if (pattern.hasMatch(message)) {
      return ViolationType.phone;
    }
  }

  // Check for email
  if (emailPattern.hasMatch(message)) {
    return ViolationType.email;
  }

  // Check for social media
  for (final pattern in socialMediaPatterns) {
    if (pattern.hasMatch(message)) {
      return ViolationType.socialMedia;
    }
  }

  return null;
}

/// A simple dialog version of the violation popup for contexts
/// where a bottom sheet is not appropriate.
class ViolationDialog extends StatelessWidget {
  /// The type of violation detected.
  final ViolationType violationType;

  /// Callback when the user wants to edit their message.
  final VoidCallback? onEdit;

  const ViolationDialog({
    super.key,
    required this.violationType,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.95),
                  Colors.white.withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Shield icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.warning.withValues(alpha: 0.15),
                        AppColors.warning.withValues(alpha: 0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 32,
                    color: AppColors.warning,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                Text(
                  'Message Not Sent',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'For your protection and privacy, sharing personal contact information is not allowed in project chats.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                // Detection info
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        violationType.icon,
                        size: 18,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          violationType.detectedText,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onEdit?.call();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Edit Message'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the violation dialog as a centered dialog.
///
/// Use this when a bottom sheet is not appropriate (e.g., on tablets or web).
Future<void> showViolationDialog({
  required BuildContext context,
  required ViolationType violationType,
  VoidCallback? onEdit,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.4),
    builder: (context) => ViolationDialog(
      violationType: violationType,
      onEdit: onEdit,
    ),
  );
}

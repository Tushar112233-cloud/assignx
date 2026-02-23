import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/message_templates.dart';
import '../../../shared/widgets/glass_container.dart';

/// Flutter widget for displaying unavailability messages with
/// glass morphism styling and interactive elements.
///
/// Supports various unavailability scenarios including:
/// - Service at capacity
/// - Expert unavailable
/// - Outside service hours (with countdown)
/// - Maintenance mode
/// - Region not supported
///
/// Example:
/// ```dart
/// UnavailabilityMessage(
///   template: UnavailabilityTemplate.expertUnavailable(
///     expertName: 'Dr. Sarah Johnson',
///     estimatedDate: 'February 1, 2026',
///   ),
///   onAction: (action) {
///     if (action == 'find_similar') {
///       context.push('/experts');
///     }
///   },
/// )
/// ```
class UnavailabilityMessage extends StatefulWidget {
  /// The unavailability template configuration.
  final UnavailabilityTemplate template;

  /// Callback when an action button is pressed.
  final void Function(String action)? onAction;

  /// Callback when email is submitted.
  final Future<void> Function(String email)? onEmailSubmit;

  /// Whether to use compact layout.
  final bool compact;

  /// Optional padding around the widget.
  final EdgeInsetsGeometry? padding;

  /// Optional margin around the widget.
  final EdgeInsetsGeometry? margin;

  const UnavailabilityMessage({
    super.key,
    required this.template,
    this.onAction,
    this.onEmailSubmit,
    this.compact = false,
    this.padding,
    this.margin,
  });

  @override
  State<UnavailabilityMessage> createState() => _UnavailabilityMessageState();
}

class _UnavailabilityMessageState extends State<UnavailabilityMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconAnimationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _iconAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _iconScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _iconRotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _iconAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _iconAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding ?? const EdgeInsets.all(16),
      margin: widget.margin,
      constraints: BoxConstraints(
        maxWidth: widget.compact ? 320 : 400,
      ),
      child: GlassCard(
        blur: 15,
        opacity: 0.85,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        elevation: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildMessage(),
            if (widget.template.serviceHours != null) ...[
              const SizedBox(height: 16),
              _buildServiceHoursBadge(),
            ],
            if (widget.template.showCountdown) ...[
              const SizedBox(height: 16),
              _CountdownTimer(
                targetTime: widget.template.estimatedTime,
                useServiceHours: widget.template.serviceHours != null &&
                    widget.template.estimatedTime == null,
              ),
            ],
            if (widget.template.showEmailInput) ...[
              const SizedBox(height: 20),
              _EmailSignupForm(
                onSubmit: widget.onEmailSubmit,
                buttonText: widget.template.actionText,
              ),
            ] else ...[
              const SizedBox(height: 20),
              _buildActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return AnimatedBuilder(
      animation: _iconAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _iconScaleAnimation.value,
          child: Transform.rotate(
            angle: _iconRotationAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.template.getIconBackgroundColor(),
              widget.template.getIconBackgroundColor().withAlpha(180),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: widget.template.getIconColor().withAlpha(51),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          widget.template.iconData,
          size: 36,
          color: widget.template.getIconColor(),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.template.title,
      style: AppTextStyles.headingSmall.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildMessage() {
    final message = widget.template.message;
    final lines = message.split('\n').where((line) => line.trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final trimmed = line.trim();

        // Check for bullet points
        if (trimmed.startsWith('-') || trimmed.startsWith('*')) {
          final bulletText = trimmed.substring(1).trim();
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    bulletText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            trimmed,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildServiceHoursBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Service Hours: ${widget.template.serviceHours}',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions() {
    final template = widget.template;

    // Multiple actions
    if (template.actions != null && template.actions!.isNotEmpty) {
      return Column(
        children: template.actions!.asMap().entries.map((entry) {
          final index = entry.key;
          final action = entry.value;

          return Padding(
            padding: EdgeInsets.only(top: index > 0 ? 8 : 0),
            child: _ActionButton(
              text: action.text,
              variant: action.variant,
              onPressed: () => widget.onAction?.call(action.action),
              showArrow: index == 0,
            ),
          );
        }).toList(),
      );
    }

    // Single action
    if (template.actionText != null) {
      return _ActionButton(
        text: template.actionText!,
        variant: TemplateActionVariant.primary,
        onPressed: () {
          if (template.actionRoute != null) {
            widget.onAction?.call('navigate:${template.actionRoute}');
          } else {
            widget.onAction?.call('primary_action');
          }
        },
        showArrow: true,
      );
    }

    return const SizedBox.shrink();
  }
}

/// Countdown timer widget.
class _CountdownTimer extends StatefulWidget {
  final DateTime? targetTime;
  final bool useServiceHours;

  const _CountdownTimer({
    this.targetTime,
    this.useServiceHours = false,
  });

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    if (widget.useServiceHours) {
      final result = CountdownUtils.getTimeToServiceStart();
      if (!result.isWithinServiceHours) {
        setState(() {
          _hours = result.hours;
          _minutes = result.minutes;
          _seconds = 0;
        });
      }
    } else if (widget.targetTime != null) {
      final result = CountdownUtils.calculateCountdown(widget.targetTime!);
      if (!result.isExpired) {
        setState(() {
          _hours = result.hours;
          _minutes = result.minutes;
          _seconds = result.seconds;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TimeUnit(value: _hours, label: 'Hours'),
        _TimeSeparator(),
        _TimeUnit(value: _minutes, label: 'Minutes'),
        if (widget.targetTime != null) ...[
          _TimeSeparator(),
          _TimeUnit(value: _seconds, label: 'Seconds'),
        ],
      ],
    );
  }
}

class _TimeUnit extends StatelessWidget {
  final int value;
  final String label;

  const _TimeUnit({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(200),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _TimeSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            ':',
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// Email signup form widget.
class _EmailSignupForm extends StatefulWidget {
  final Future<void> Function(String email)? onSubmit;
  final String? buttonText;

  const _EmailSignupForm({
    this.onSubmit,
    this.buttonText,
  });

  @override
  State<_EmailSignupForm> createState() => _EmailSignupFormState();
}

class _EmailSignupFormState extends State<_EmailSignupForm> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _controller.text.trim();

    // Basic email validation
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _error = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await widget.onSubmit?.call(email);
      setState(() {
        _isSubmitted = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to subscribe. Please try again.';
      });
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withAlpha(51)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "You'll be notified when this becomes available!",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.mail_outline,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isSubmitting,
                  decoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: Material(
                  color: _isSubmitting || _controller.text.isEmpty
                      ? AppColors.primary.withAlpha(128)
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _isSubmitting ? null : _handleSubmit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              widget.buttonText ?? 'Notify Me',
                              style: AppTextStyles.buttonSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

/// Action button widget.
class _ActionButton extends StatelessWidget {
  final String text;
  final TemplateActionVariant variant;
  final VoidCallback? onPressed;
  final bool showArrow;

  const _ActionButton({
    required this.text,
    required this.variant,
    this.onPressed,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == TemplateActionVariant.primary;
    final isOutline = variant == TemplateActionVariant.outline;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: isPrimary
            ? AppColors.primary
            : isOutline
                ? Colors.transparent
                : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: isOutline
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  )
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: AppTextStyles.buttonMedium.copyWith(
                    color: isPrimary
                        ? Colors.white
                        : isOutline
                            ? AppColors.textPrimary
                            : AppColors.textPrimary,
                  ),
                ),
                if (showArrow) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: isPrimary ? Colors.white : AppColors.textPrimary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Inline banner variant of the unavailability message.
/// Useful for displaying in lists or cards.
class UnavailabilityBanner extends StatelessWidget {
  /// The unavailability template configuration.
  final UnavailabilityTemplate template;

  /// Callback when an action is pressed.
  final void Function(String action)? onAction;

  /// Optional padding.
  final EdgeInsetsGeometry? padding;

  const UnavailabilityBanner({
    super.key,
    required this.template,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    // Get first paragraph only for banner
    final shortMessage = template.message.split('\n').first;

    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(51)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: template.getIconBackgroundColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              template.iconData,
              size: 20,
              color: template.getIconColor(),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shortMessage,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action
          if (template.actionText != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => onAction?.call('primary_action'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 36),
              ),
              child: Text(
                template.actionText!,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

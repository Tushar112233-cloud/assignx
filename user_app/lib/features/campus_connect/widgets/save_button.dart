import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Animated save/bookmark button for listings.
///
/// Features:
/// - Animated heart/bookmark icon
/// - Toggle save state with haptic feedback
/// - Multiple size variants
class SaveButton extends StatefulWidget {
  /// Whether the item is currently saved.
  final bool isSaved;

  /// Callback when the save state is toggled.
  final VoidCallback? onToggle;

  /// Size variant (small, medium, large).
  final SaveButtonSize size;

  /// Whether to show the label text.
  final bool showLabel;

  const SaveButton({
    super.key,
    required this.isSaved,
    this.onToggle,
    this.size = SaveButtonSize.medium,
    this.showLabel = false,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -3.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -3.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Play animation
    _animationController.forward(from: 0);

    // Trigger callback
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getSizeConfig(widget.size);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(config.padding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bounceAnimation.value),
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Icon(
                        widget.isSaved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        size: config.iconSize,
                        color: widget.isSaved
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
              if (widget.showLabel) ...[
                const SizedBox(width: 6),
                Text(
                  widget.isSaved ? 'Saved' : 'Save',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: config.fontSize,
                    fontWeight: FontWeight.w500,
                    color: widget.isSaved
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _SaveButtonSizeConfig _getSizeConfig(SaveButtonSize size) {
    switch (size) {
      case SaveButtonSize.small:
        return const _SaveButtonSizeConfig(
          iconSize: 18,
          fontSize: 11,
          padding: 6,
        );
      case SaveButtonSize.medium:
        return const _SaveButtonSizeConfig(
          iconSize: 22,
          fontSize: 13,
          padding: 8,
        );
      case SaveButtonSize.large:
        return const _SaveButtonSizeConfig(
          iconSize: 26,
          fontSize: 15,
          padding: 10,
        );
    }
  }
}

/// Size variants for the save button.
enum SaveButtonSize { small, medium, large }

/// Configuration for button sizes.
class _SaveButtonSizeConfig {
  final double iconSize;
  final double fontSize;
  final double padding;

  const _SaveButtonSizeConfig({
    required this.iconSize,
    required this.fontSize,
    required this.padding,
  });
}

/// Outlined version of the save button with a border.
class SaveButtonOutline extends StatefulWidget {
  /// Whether the item is currently saved.
  final bool isSaved;

  /// Callback when the save state is toggled.
  final VoidCallback? onToggle;

  const SaveButtonOutline({
    super.key,
    required this.isSaved,
    this.onToggle,
  });

  @override
  State<SaveButtonOutline> createState() => _SaveButtonOutlineState();
}

class _SaveButtonOutlineState extends State<SaveButtonOutline>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _animationController.forward(from: 0);
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: widget.isSaved
                ? AppColors.primary.withAlpha(26)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _handleTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.isSaved
                        ? AppColors.primary.withAlpha(77)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 20,
                      color: widget.isSaved
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isSaved ? 'Saved' : 'Save',
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: widget.isSaved
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Floating save button for overlaying on images.
class FloatingSaveButton extends StatefulWidget {
  /// Whether the item is currently saved.
  final bool isSaved;

  /// Callback when the save state is toggled.
  final VoidCallback? onToggle;

  const FloatingSaveButton({
    super.key,
    required this.isSaved,
    this.onToggle,
  });

  @override
  State<FloatingSaveButton> createState() => _FloatingSaveButtonState();
}

class _FloatingSaveButtonState extends State<FloatingSaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    _animationController.forward(from: 0);
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.white.withAlpha(242),
            shape: const CircleBorder(),
            elevation: 4,
            shadowColor: Colors.black.withAlpha(51),
            child: InkWell(
              onTap: _handleTap,
              customBorder: const CircleBorder(),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Icon(
                  widget.isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  size: 22,
                  color: widget.isSaved
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

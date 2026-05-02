library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Animated save/bookmark button for posts.
class SaveButton extends StatefulWidget {
  final bool isSaved;
  final VoidCallback? onToggle;
  final SaveButtonSize size;
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
    HapticFeedback.mediumImpact();
    _animationController.forward(from: 0);
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
                  style: AppTypography.labelMedium.copyWith(
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
            iconSize: 18, fontSize: 11, padding: 6);
      case SaveButtonSize.medium:
        return const _SaveButtonSizeConfig(
            iconSize: 22, fontSize: 13, padding: 8);
      case SaveButtonSize.large:
        return const _SaveButtonSizeConfig(
            iconSize: 26, fontSize: 15, padding: 10);
    }
  }
}

enum SaveButtonSize { small, medium, large }

class _SaveButtonSizeConfig {
  final double iconSize;
  final double fontSize;
  final double padding;
  const _SaveButtonSizeConfig(
      {required this.iconSize, required this.fontSize, required this.padding});
}

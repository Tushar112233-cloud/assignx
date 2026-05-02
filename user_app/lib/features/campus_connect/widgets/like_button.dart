import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Animated like/heart button for posts.
///
/// Features:
/// - Animated heart icon with scale and bounce effects
/// - Toggle like state with haptic feedback
/// - Multiple size variants
/// - Optional like count display
class LikeButton extends StatefulWidget {
  /// Whether the item is currently liked.
  final bool isLiked;

  /// The current like count.
  final int likeCount;

  /// Callback when the like state is toggled.
  final VoidCallback? onToggle;

  /// Size variant (small, medium, large).
  final LikeButtonSize size;

  /// Whether to show the like count.
  final bool showCount;

  const LikeButton({
    super.key,
    required this.isLiked,
    this.likeCount = 0,
    this.onToggle,
    this.size = LikeButtonSize.medium,
    this.showCount = true,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
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
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_animationController);

    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -4.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -4.0, end: 0.0)
            .chain(CurveTween(curve: Curves.bounceOut)),
        weight: 60,
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
                        widget.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: config.iconSize,
                        color: widget.isLiked
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
              if (widget.showCount && widget.likeCount > 0) ...[
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: Text(
                    _formatCount(widget.likeCount),
                    key: ValueKey(widget.likeCount),
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: config.fontSize,
                      fontWeight: FontWeight.w500,
                      color: widget.isLiked
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  _LikeButtonSizeConfig _getSizeConfig(LikeButtonSize size) {
    switch (size) {
      case LikeButtonSize.small:
        return const _LikeButtonSizeConfig(
          iconSize: 18,
          fontSize: 11,
          padding: 6,
        );
      case LikeButtonSize.medium:
        return const _LikeButtonSizeConfig(
          iconSize: 22,
          fontSize: 13,
          padding: 8,
        );
      case LikeButtonSize.large:
        return const _LikeButtonSizeConfig(
          iconSize: 26,
          fontSize: 15,
          padding: 10,
        );
    }
  }
}

/// Size variants for the like button.
enum LikeButtonSize { small, medium, large }

/// Configuration for button sizes.
class _LikeButtonSizeConfig {
  final double iconSize;
  final double fontSize;
  final double padding;

  const _LikeButtonSizeConfig({
    required this.iconSize,
    required this.fontSize,
    required this.padding,
  });
}

/// Compact like button for use in cards.
class CompactLikeButton extends StatefulWidget {
  /// Whether the item is currently liked.
  final bool isLiked;

  /// The current like count.
  final int likeCount;

  /// Callback when the like state is toggled.
  final VoidCallback? onToggle;

  const CompactLikeButton({
    super.key,
    required this.isLiked,
    this.likeCount = 0,
    this.onToggle,
  });

  @override
  State<CompactLikeButton> createState() => _CompactLikeButtonState();
}

class _CompactLikeButtonState extends State<CompactLikeButton>
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
        tween: Tween<double>(begin: 1.0, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0)
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
    HapticFeedback.lightImpact();
    _animationController.forward(from: 0);
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Icon(
                  widget.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 16,
                  color:
                      widget.isLiked ? AppColors.error : AppColors.textTertiary,
                ),
              );
            },
          ),
          if (widget.likeCount > 0) ...[
            const SizedBox(width: 4),
            Text(
              widget.likeCount.toString(),
              style: AppTextStyles.caption.copyWith(
                color:
                    widget.isLiked ? AppColors.error : AppColors.textTertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating like button for overlaying on images.
class FloatingLikeButton extends StatefulWidget {
  /// Whether the item is currently liked.
  final bool isLiked;

  /// Callback when the like state is toggled.
  final VoidCallback? onToggle;

  const FloatingLikeButton({
    super.key,
    required this.isLiked,
    this.onToggle,
  });

  @override
  State<FloatingLikeButton> createState() => _FloatingLikeButtonState();
}

class _FloatingLikeButtonState extends State<FloatingLikeButton>
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
                  widget.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 22,
                  color:
                      widget.isLiked ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

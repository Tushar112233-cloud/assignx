import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';

/// Extension on Widget providing common reusable animations.
///
/// These animations use flutter_animate package and can be chained
/// together for complex animation sequences.
///
/// Example:
/// ```dart
/// Container(
///   child: Text('Hello'),
/// ).fadeInSlideUp()
///  .springScale()
/// ```
extension CommonAnimations on Widget {
  /// Fade in with upward slide animation.
  ///
  /// Classic entrance animation for content appearing on screen.
  /// [delay] - Optional delay before animation starts.
  /// [duration] - Animation duration. Default is 400ms.
  /// [offset] - Vertical offset to slide from. Default is 20.
  /// [curve] - Animation curve. Default is easeOut.
  Widget fadeInSlideUp({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double offset = 20,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(
          begin: offset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade in with downward slide animation.
  ///
  /// Entrance animation for dropdown menus or top notifications.
  Widget fadeInSlideDown({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double offset = 20,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideY(
          begin: -offset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade in with left-to-right slide animation.
  Widget fadeInSlideRight({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double offset = 20,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideX(
          begin: -offset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Fade in with right-to-left slide animation.
  Widget fadeInSlideLeft({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double offset = 20,
    Curve curve = Curves.easeOut,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: curve)
        .slideX(
          begin: offset / 100,
          end: 0,
          duration: duration,
          curve: curve,
        );
  }

  /// Spring scale animation with bounce effect.
  ///
  /// Creates an elastic scale effect commonly used for buttons
  /// and interactive elements.
  /// [delay] - Optional delay before animation starts.
  /// [duration] - Animation duration. Default is 500ms.
  /// [begin] - Starting scale. Default is 0.8.
  Widget springScale({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 500),
    double begin = 0.8,
  }) {
    return animate(delay: delay).scale(
      begin: Offset(begin, begin),
      end: const Offset(1, 1),
      duration: duration,
      curve: Curves.elasticOut,
    );
  }

  /// Bounce scale animation with overshoot.
  ///
  /// More pronounced bounce effect for attention-grabbing elements.
  Widget bounceScale({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 600),
    double begin = 0.5,
  }) {
    return animate(delay: delay)
        .scale(
          begin: Offset(begin, begin),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.bounceOut,
        )
        .fadeIn(duration: duration ~/ 2);
  }

  /// Shimmer loading effect animation.
  ///
  /// Creates a subtle shimmer effect for loading states.
  /// [color] - Shimmer highlight color. Default is white with 50% opacity.
  /// [duration] - One shimmer cycle duration. Default is 1.5s.
  Widget shimmer({
    Color? color,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return animate(onPlay: (controller) => controller.repeat()).shimmer(
      duration: duration,
      color: color ?? Colors.white.withAlpha(128),
    );
  }

  /// Pulse glow effect animation.
  ///
  /// Creates a pulsing glow effect for highlighted elements.
  /// [color] - Glow color. Default is primary color.
  /// [duration] - One pulse cycle duration. Default is 1.5s.
  Widget pulseGlow({
    Color? color,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final glowColor = color ?? AppColors.primary;
    return animate(onPlay: (controller) => controller.repeat(reverse: true))
        .boxShadow(
          begin: BoxShadow(
            color: glowColor.withAlpha(0),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          end: BoxShadow(
            color: glowColor.withAlpha(64),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          duration: duration,
          curve: Curves.easeInOut,
        );
  }

  /// Subtle pulse scale animation.
  ///
  /// Creates a gentle pulsing scale effect for attention.
  Widget pulse({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 1000),
    double scale = 1.05,
  }) {
    return animate(
      delay: delay,
      onPlay: (controller) => controller.repeat(reverse: true),
    ).scale(
      begin: const Offset(1, 1),
      end: Offset(scale, scale),
      duration: duration,
      curve: Curves.easeInOut,
    );
  }

  /// Shake animation for error feedback.
  ///
  /// Horizontal shake effect to indicate invalid input.
  Widget shake({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double offset = 10,
  }) {
    return animate(delay: delay).shake(
      duration: duration,
      hz: 4,
      offset: Offset(offset, 0),
    );
  }

  /// Rotate animation.
  ///
  /// Continuous rotation for loading spinners.
  Widget rotate({
    Duration duration = const Duration(milliseconds: 1000),
    double turns = 1,
    bool repeat = true,
  }) {
    final anim = animate(
      onPlay: repeat ? (controller) => controller.repeat() : null,
    ).rotate(
      begin: 0,
      end: turns,
      duration: duration,
      curve: Curves.linear,
    );
    return anim;
  }

  /// Flip animation.
  ///
  /// 3D flip effect for card reveals.
  Widget flip({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 500),
    Axis axis = Axis.vertical,
  }) {
    if (axis == Axis.vertical) {
      return animate(delay: delay).flipV(
        begin: 0.25,
        end: 0,
        duration: duration,
        curve: Curves.easeOut,
      );
    }
    return animate(delay: delay).flipH(
      begin: 0.25,
      end: 0,
      duration: duration,
      curve: Curves.easeOut,
    );
  }

  /// Blur in animation.
  ///
  /// Fade in with blur effect for smooth reveals.
  Widget blurIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 400),
    double beginBlur = 10,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .blur(
          begin: Offset(beginBlur, beginBlur),
          end: Offset.zero,
          duration: duration,
        );
  }

  /// Pop in animation.
  ///
  /// Scale from larger to normal with fade for modal-like entrances.
  Widget popIn({
    Duration? delay,
    Duration duration = const Duration(milliseconds: 300),
    double beginScale = 1.2,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration)
        .scale(
          begin: Offset(beginScale, beginScale),
          end: const Offset(1, 1),
          duration: duration,
          curve: Curves.easeOut,
        );
  }

  /// Staggered list item animation.
  ///
  /// Use with index for staggered list animations.
  Widget staggeredListItem({
    required int index,
    Duration itemDuration = const Duration(milliseconds: 400),
    Duration staggerDelay = const Duration(milliseconds: 50),
  }) {
    return fadeInSlideUp(
      delay: staggerDelay * index,
      duration: itemDuration,
    );
  }

  /// Tap feedback animation.
  ///
  /// Scale down on tap for button feedback. Use with GestureDetector.
  Widget tapScale({
    double pressedScale = 0.95,
    Duration duration = const Duration(milliseconds: 100),
  }) {
    // This is a static animation, for interactive use TapScaleContainer
    return this;
  }
}

/// Container widget with tap scale feedback animation.
///
/// Wraps child widget and provides scale animation on tap.
class TapScaleContainer extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// Scale when pressed. Default is 0.95.
  final double pressedScale;

  /// Animation duration. Default is 100ms.
  final Duration duration;

  /// Callback on tap.
  final VoidCallback? onTap;

  /// Callback on long press.
  final VoidCallback? onLongPress;

  const TapScaleContainer({
    super.key,
    required this.child,
    this.pressedScale = 0.95,
    this.duration = const Duration(milliseconds: 100),
    this.onTap,
    this.onLongPress,
  });

  @override
  State<TapScaleContainer> createState() => _TapScaleContainerState();
}

class _TapScaleContainerState extends State<TapScaleContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

/// Staggered animation controller for list/grid items.
///
/// Provides utilities for creating staggered entrance animations.
class StaggeredAnimationBuilder extends StatelessWidget {
  /// Child widget to animate.
  final Widget child;

  /// Item index in the list.
  final int index;

  /// Base duration for each item. Default is 400ms.
  final Duration itemDuration;

  /// Delay between items. Default is 50ms.
  final Duration staggerDelay;

  /// Maximum delay cap. Default is 500ms.
  final Duration maxDelay;

  /// Animation type.
  final StaggeredAnimationType type;

  const StaggeredAnimationBuilder({
    super.key,
    required this.child,
    required this.index,
    this.itemDuration = const Duration(milliseconds: 400),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.maxDelay = const Duration(milliseconds: 500),
    this.type = StaggeredAnimationType.fadeSlideUp,
  });

  @override
  Widget build(BuildContext context) {
    final delay = Duration(
      milliseconds: (staggerDelay.inMilliseconds * index)
          .clamp(0, maxDelay.inMilliseconds),
    );

    switch (type) {
      case StaggeredAnimationType.fadeSlideUp:
        return child.fadeInSlideUp(delay: delay, duration: itemDuration);
      case StaggeredAnimationType.fadeSlideRight:
        return child.fadeInSlideRight(delay: delay, duration: itemDuration);
      case StaggeredAnimationType.scale:
        return child.springScale(delay: delay, duration: itemDuration);
      case StaggeredAnimationType.fade:
        return child
            .animate(delay: delay)
            .fadeIn(duration: itemDuration);
    }
  }
}

/// Types of staggered animations.
enum StaggeredAnimationType {
  fadeSlideUp,
  fadeSlideRight,
  scale,
  fade,
}

/// Page transition animations.
class PageTransitions {
  PageTransitions._();

  /// Slide from right transition.
  static Widget slideFromRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }

  /// Slide from bottom transition.
  static Widget slideFromBottom(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }

  /// Fade transition.
  static Widget fade(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Scale fade transition.
  static Widget scaleFade(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );
  }
}

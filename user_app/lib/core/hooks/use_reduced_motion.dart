import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/accessibility_provider.dart';

/// Helper function to get animation duration respecting reduced motion preference.
///
/// Returns [Duration.zero] if reduced motion is enabled, otherwise returns [normal].
///
/// Usage:
/// ```dart
/// final duration = getAnimationDuration(reducedMotion, Duration(milliseconds: 300));
/// AnimatedContainer(
///   duration: duration,
///   // ...
/// )
/// ```
Duration getAnimationDuration(bool reducedMotion, Duration normal) {
  return reducedMotion ? Duration.zero : normal;
}

/// Helper function to get animation curve respecting reduced motion preference.
///
/// Returns [Curves.linear] if reduced motion is enabled, otherwise returns [normal].
Curve getAnimationCurve(bool reducedMotion, Curve normal) {
  return reducedMotion ? Curves.linear : normal;
}

/// Extension on BuildContext for reduced motion utilities.
///
/// Provides convenient access to reduced motion settings without
/// requiring direct provider access.
extension ReducedMotionContextExtension on BuildContext {
  /// Check if the system prefers reduced motion.
  ///
  /// This only checks the system MediaQuery setting.
  /// For user preference + system, use [ReducedMotionRefExtension].
  bool get prefersReducedMotion {
    return MediaQuery.of(this).disableAnimations;
  }

  /// Get animation duration respecting system reduced motion preference.
  ///
  /// Returns [Duration.zero] if system prefers reduced motion.
  Duration animationDuration(Duration normalDuration) {
    return prefersReducedMotion ? Duration.zero : normalDuration;
  }

  /// Get animation curve respecting system reduced motion preference.
  ///
  /// Returns [Curves.linear] if system prefers reduced motion.
  Curve animationCurve(Curve normalCurve) {
    return prefersReducedMotion ? Curves.linear : normalCurve;
  }
}

/// Mixin for StatefulWidget states that need reduced motion awareness.
///
/// Provides convenient methods for animation properties that respect
/// the user's reduced motion preference.
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> with ReducedMotionMixin {
///   @override
///   Widget build(BuildContext context) {
///     return AnimatedContainer(
///       duration: getAnimDuration(Duration(milliseconds: 300)),
///       curve: getAnimCurve(Curves.easeOut),
///       // ...
///     );
///   }
/// }
/// ```
mixin ReducedMotionMixin<T extends StatefulWidget> on State<T> {
  /// Whether animations should be reduced based on system settings.
  bool get shouldReduceMotion => context.prefersReducedMotion;

  /// Get animation duration respecting reduced motion preference.
  Duration getAnimDuration(Duration normal) {
    return shouldReduceMotion ? Duration.zero : normal;
  }

  /// Get animation curve respecting reduced motion preference.
  Curve getAnimCurve(Curve normal) {
    return shouldReduceMotion ? Curves.linear : normal;
  }

  /// Get opacity for fade animations.
  ///
  /// Returns 1.0 immediately if reduced motion is enabled.
  double getAnimatedOpacity(Animation<double> animation) {
    return shouldReduceMotion ? 1.0 : animation.value;
  }

  /// Get scale for scale animations.
  ///
  /// Returns 1.0 immediately if reduced motion is enabled.
  double getAnimatedScale(Animation<double> animation) {
    return shouldReduceMotion ? 1.0 : animation.value;
  }

  /// Get offset for slide animations.
  ///
  /// Returns [Offset.zero] immediately if reduced motion is enabled.
  Offset getAnimatedOffset(Animation<Offset> animation) {
    return shouldReduceMotion ? Offset.zero : animation.value;
  }
}

/// Mixin for ConsumerStatefulWidget states that need reduced motion awareness.
///
/// Uses the [reducedMotionProvider] for combined system + user preference.
///
/// Usage:
/// ```dart
/// class _MyWidgetState extends ConsumerState<MyWidget>
///     with ReducedMotionConsumerMixin {
///   @override
///   Widget build(BuildContext context) {
///     return AnimatedContainer(
///       duration: getAnimDuration(Duration(milliseconds: 300)),
///       // ...
///     );
///   }
/// }
/// ```
mixin ReducedMotionConsumerMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  /// Whether animations should be reduced based on user preference + system.
  bool get shouldReduceMotion => ref.watch(reducedMotionProvider);

  /// Get animation duration respecting reduced motion preference.
  Duration getAnimDuration(Duration normal) {
    return shouldReduceMotion ? Duration.zero : normal;
  }

  /// Get animation curve respecting reduced motion preference.
  Curve getAnimCurve(Curve normal) {
    return shouldReduceMotion ? Curves.linear : normal;
  }
}

/// Widget that listens to reduced motion changes and rebuilds.
///
/// Useful when you need to conditionally render based on reduced motion
/// without wrapping the entire widget tree.
///
/// Usage:
/// ```dart
/// ReducedMotionBuilder(
///   builder: (context, reducedMotion) {
///     return reducedMotion
///         ? StaticWidget()
///         : AnimatedWidget();
///   },
/// )
/// ```
class ReducedMotionBuilder extends ConsumerWidget {
  /// Builder function that receives the reduced motion state.
  final Widget Function(BuildContext context, bool reducedMotion) builder;

  /// Creates a [ReducedMotionBuilder].
  const ReducedMotionBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);
    return builder(context, reducedMotion);
  }
}

/// Widget wrapper that conditionally applies animations.
///
/// Shows [child] directly if reduced motion is enabled,
/// otherwise applies the specified animation.
///
/// Usage:
/// ```dart
/// ReducedMotionAnimatedOpacity(
///   opacity: _animation.value,
///   duration: Duration(milliseconds: 300),
///   child: MyWidget(),
/// )
/// ```
class ReducedMotionAnimatedOpacity extends ConsumerWidget {
  /// The child widget to display.
  final Widget child;

  /// The opacity value (ignored if reduced motion is enabled).
  final double opacity;

  /// Animation duration (ignored if reduced motion is enabled).
  final Duration duration;

  /// Animation curve (ignored if reduced motion is enabled).
  final Curve curve;

  /// Creates a [ReducedMotionAnimatedOpacity].
  const ReducedMotionAnimatedOpacity({
    super.key,
    required this.child,
    required this.opacity,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);

    if (reducedMotion) {
      return child;
    }

    return AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// Widget wrapper that conditionally applies scale animations.
class ReducedMotionAnimatedScale extends ConsumerWidget {
  /// The child widget to display.
  final Widget child;

  /// The scale value (ignored if reduced motion is enabled).
  final double scale;

  /// Animation duration (ignored if reduced motion is enabled).
  final Duration duration;

  /// Animation curve (ignored if reduced motion is enabled).
  final Curve curve;

  /// Creates a [ReducedMotionAnimatedScale].
  const ReducedMotionAnimatedScale({
    super.key,
    required this.child,
    required this.scale,
    this.duration = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reducedMotion = ref.watch(reducedMotionProvider);

    if (reducedMotion) {
      return child;
    }

    return AnimatedScale(
      scale: scale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

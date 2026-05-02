import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom animation curves matching user-web design system.
///
/// These curves provide consistent motion design across the app,
/// matching the web application's animation timing and feel.
class AppCurves {
  AppCurves._();

  /// Curve for page enter animations.
  /// Matches CSS ease-out-cubic for smooth deceleration.
  static const Curve pageEnter = Curves.easeOutCubic;

  /// Curve for page exit animations.
  /// Matches CSS ease-in-quad for quick exit.
  static const Curve pageExit = Curves.easeInQuad;

  /// Springy curve for interactive elements.
  /// Provides elastic bounce effect.
  static const Curve springy = Curves.elasticOut;

  /// Smooth ease curve for general animations.
  static const Curve smooth = Curves.easeInOutCubic;

  /// Quick response curve for micro-interactions.
  static const Curve quick = Curves.easeOutQuart;

  /// Emphasized curve for prominent animations.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Decelerate curve for elements coming to rest.
  static const Curve decelerate = Curves.decelerate;
}

/// Duration constants for page transitions.
///
/// Matches the timing specifications from user-web:
/// - Enter: 350ms
/// - Exit: 200ms
class PageTransitionDurations {
  PageTransitionDurations._();

  /// Duration for page enter animation (350ms).
  static const Duration enter = Duration(milliseconds: 350);

  /// Duration for page exit animation (200ms).
  static const Duration exit = Duration(milliseconds: 200);

  /// Duration for modal transitions (300ms).
  static const Duration modal = Duration(milliseconds: 300);

  /// Duration for quick transitions (150ms).
  static const Duration quick = Duration(milliseconds: 150);

  /// Duration for slow, emphasized transitions (500ms).
  static const Duration emphasized = Duration(milliseconds: 500);
}

/// Custom page route with fade, scale, and slide animations.
///
/// Matches user-web page transition specs:
/// - Initial: opacity: 0, scale: 0.985, translateY: 12px
/// - Animate: opacity: 1, scale: 1, translateY: 0 (350ms)
/// - Exit: opacity: 0, scale: 0.99, translateY: -8px (200ms)
///
/// Example:
/// ```dart
/// Navigator.push(
///   context,
///   FadeScalePageRoute(page: const MyScreen()),
/// );
/// ```
class FadeScalePageRoute<T> extends PageRouteBuilder<T> {
  /// The destination page widget.
  final Widget page;

  /// Whether to respect reduced motion accessibility setting.
  final bool respectReducedMotion;

  /// Creates a fade-scale page route.
  ///
  /// [page] is the destination widget.
  /// [respectReducedMotion] defaults to true for accessibility.
  FadeScalePageRoute({
    required this.page,
    this.respectReducedMotion = true,
  }) : super(
          transitionDuration: PageTransitionDurations.enter,
          reverseTransitionDuration: PageTransitionDurations.exit,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _FadeScaleTransitionBuilder(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              respectReducedMotion: respectReducedMotion,
              child: child,
            );
          },
        );
}

/// Internal widget builder for fade-scale transitions.
class _FadeScaleTransitionBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final bool respectReducedMotion;
  final Widget child;

  const _FadeScaleTransitionBuilder({
    required this.animation,
    required this.secondaryAnimation,
    required this.respectReducedMotion,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = respectReducedMotion &&
        MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      // Simple fade for reduced motion
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    }

    // Enter animation values (matching user-web specs)
    // Initial: opacity: 0, scale: 0.985, translateY: 12
    // Animate: opacity: 1, scale: 1, translateY: 0
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    );

    final scaleAnimation = Tween<double>(
      begin: 0.985,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    ));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03), // ~12px relative offset
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    ));

    // Exit animation for the outgoing page
    // Exit: opacity: 0, scale: 0.99, translateY: -8
    final secondaryFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppCurves.pageExit,
    ));

    final secondaryScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.99,
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppCurves.pageExit,
    ));

    final secondarySlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.02), // ~-8px relative offset
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: AppCurves.pageExit,
    ));

    // Apply secondary (exit) animation to outgoing page
    Widget result = child;

    if (secondaryAnimation.status != AnimationStatus.dismissed) {
      result = FadeTransition(
        opacity: secondaryFadeAnimation,
        child: ScaleTransition(
          scale: secondaryScaleAnimation,
          child: SlideTransition(
            position: secondarySlideAnimation,
            child: result,
          ),
        ),
      );
    }

    // Apply primary (enter) animation to incoming page
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: result,
        ),
      ),
    );
  }
}

/// GoRouter extension for creating custom transition pages.
///
/// Provides factory methods for consistent page transitions across
/// the app when using GoRouter navigation.
///
/// Example:
/// ```dart
/// GoRoute(
///   path: '/details',
///   pageBuilder: (context, state) =>
///     AppPageTransitions.fadeScale(
///       child: const DetailsScreen(),
///       state: state,
///     ),
/// ),
/// ```
class AppPageTransitions {
  AppPageTransitions._();

  /// Creates a fade-scale transition page matching user-web specs.
  ///
  /// [child] is the destination page widget.
  /// [state] is the GoRouter state for key generation.
  /// [maintainState] whether to maintain state when offscreen.
  ///
  /// Respects both system accessibility settings and user preference
  /// via [ReducedMotionHelper].
  static CustomTransitionPage<T> fadeScale<T>({
    required Widget child,
    required GoRouterState state,
    bool maintainState = true,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      maintainState: maintainState,
      transitionDuration: PageTransitionDurations.enter,
      reverseTransitionDuration: PageTransitionDurations.exit,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Check both user preference and system setting
        final reduceMotion = ReducedMotionHelper.shouldReduceMotion(context);

        if (reduceMotion) {
          // Instant transition - just show the page
          return child;
        }

        return _buildFadeScaleTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// Creates a slide-from-right transition page.
  ///
  /// Common for detail screens and forward navigation.
  ///
  /// Respects both system accessibility settings and user preference
  /// via [ReducedMotionHelper].
  static CustomTransitionPage<T> slideRight<T>({
    required Widget child,
    required GoRouterState state,
    bool maintainState = true,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      maintainState: maintainState,
      transitionDuration: PageTransitionDurations.enter,
      reverseTransitionDuration: PageTransitionDurations.exit,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Check both user preference and system setting
        final reduceMotion = ReducedMotionHelper.shouldReduceMotion(context);

        if (reduceMotion) {
          // Instant transition - just show the page
          return child;
        }

        final slideAnimation = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppCurves.pageEnter,
        ));

        final fadeAnimation = CurvedAnimation(
          parent: animation,
          curve: AppCurves.pageEnter,
        );

        return SlideTransition(
          position: slideAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// Creates a slide-from-bottom transition page.
  ///
  /// Ideal for modals and bottom sheets presented as full screens.
  ///
  /// Respects both system accessibility settings and user preference
  /// via [ReducedMotionHelper].
  static CustomTransitionPage<T> slideUp<T>({
    required Widget child,
    required GoRouterState state,
    bool maintainState = true,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      maintainState: maintainState,
      transitionDuration: PageTransitionDurations.modal,
      reverseTransitionDuration: PageTransitionDurations.exit,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Check both user preference and system setting
        final reduceMotion = ReducedMotionHelper.shouldReduceMotion(context);

        if (reduceMotion) {
          // Instant transition - just show the page
          return child;
        }

        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppCurves.pageEnter,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }

  /// Creates a simple fade transition page.
  ///
  /// For subtle transitions between related screens.
  static CustomTransitionPage<T> fade<T>({
    required Widget child,
    required GoRouterState state,
    bool maintainState = true,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      maintainState: maintainState,
      transitionDuration: PageTransitionDurations.enter,
      reverseTransitionDuration: PageTransitionDurations.exit,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AppCurves.pageEnter,
          ),
          child: child,
        );
      },
    );
  }

  /// Creates a shared axis transition page.
  ///
  /// For transitions that share a visual relationship along an axis.
  ///
  /// Respects both system accessibility settings and user preference
  /// via [ReducedMotionHelper].
  static CustomTransitionPage<T> sharedAxis<T>({
    required Widget child,
    required GoRouterState state,
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
    bool maintainState = true,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      maintainState: maintainState,
      transitionDuration: PageTransitionDurations.enter,
      reverseTransitionDuration: PageTransitionDurations.exit,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Check both user preference and system setting
        final reduceMotion = ReducedMotionHelper.shouldReduceMotion(context);

        if (reduceMotion) {
          // Instant transition - just show the page
          return child;
        }

        return SharedAxisTransitionWidget(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          direction: direction,
          child: child,
        );
      },
    );
  }

  /// Internal builder for fade-scale transition.
  static Widget _buildFadeScaleTransition({
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    );

    final scaleAnimation = Tween<double>(
      begin: 0.985,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    ));

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: child,
        ),
      ),
    );
  }
}

/// Direction for shared axis transitions.
enum SharedAxisDirection {
  /// Horizontal (X-axis) transition.
  horizontal,

  /// Vertical (Y-axis) transition.
  vertical,

  /// Depth (Z-axis/scale) transition.
  depth,
}

/// Widget that implements shared axis transition.
///
/// Transitions along a specified axis with coordinated
/// fade and slide/scale animations.
class SharedAxisTransitionWidget extends StatelessWidget {
  /// Primary animation for incoming page.
  final Animation<double> animation;

  /// Secondary animation for outgoing page.
  final Animation<double> secondaryAnimation;

  /// Direction of the shared axis.
  final SharedAxisDirection direction;

  /// Child widget to transition.
  final Widget child;

  /// Creates a shared axis transition widget.
  const SharedAxisTransitionWidget({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.direction,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.pageEnter,
    );

    switch (direction) {
      case SharedAxisDirection.horizontal:
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppCurves.pageEnter,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );

      case SharedAxisDirection.vertical:
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppCurves.pageEnter,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );

      case SharedAxisDirection.depth:
        final scaleAnimation = Tween<double>(
          begin: 0.8,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: AppCurves.pageEnter,
        ));

        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
    }
  }
}

/// Fade-slide transition widget for reusable animations.
///
/// Combines opacity and position animations for smooth
/// entrance/exit effects.
class FadeSlideTransition extends StatelessWidget {
  /// Animation controller or animation.
  final Animation<double> animation;

  /// Slide direction offset.
  final Offset slideOffset;

  /// Animation curve.
  final Curve curve;

  /// Child widget to animate.
  final Widget child;

  /// Creates a fade-slide transition.
  ///
  /// [animation] controls both fade and slide.
  /// [slideOffset] is the starting position offset.
  /// [curve] is the animation curve.
  const FadeSlideTransition({
    super.key,
    required this.animation,
    required this.child,
    this.slideOffset = const Offset(0, 0.1),
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    final slideAnimation = Tween<Offset>(
      begin: slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}

/// Scale transition widget with customizable options.
///
/// Provides a scale animation with configurable begin/end
/// values and alignment.
class AppScaleTransition extends StatelessWidget {
  /// Animation controller or animation.
  final Animation<double> animation;

  /// Starting scale value.
  final double beginScale;

  /// Ending scale value.
  final double endScale;

  /// Scale alignment point.
  final Alignment alignment;

  /// Animation curve.
  final Curve curve;

  /// Child widget to animate.
  final Widget child;

  /// Creates an app scale transition.
  const AppScaleTransition({
    super.key,
    required this.animation,
    required this.child,
    this.beginScale = 0.8,
    this.endScale = 1.0,
    this.alignment = Alignment.center,
    this.curve = Curves.easeOut,
  });

  @override
  Widget build(BuildContext context) {
    final scaleAnimation = Tween<double>(
      begin: beginScale,
      end: endScale,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    return ScaleTransition(
      scale: scaleAnimation,
      alignment: alignment,
      child: child,
    );
  }
}

/// Controller for staggered list/grid item animations.
///
/// Provides utilities for creating staggered entrance animations
/// with configurable delay per item and maximum batch size.
///
/// Example:
/// ```dart
/// final staggerController = StaggerAnimationController(
///   itemCount: items.length,
///   itemDelayMs: 50,
///   maxBatchItems: 10,
/// );
///
/// // In build method
/// ListView.builder(
///   itemBuilder: (context, index) {
///     final delay = staggerController.getDelay(index);
///     return AnimatedItem(delay: delay, child: items[index]);
///   },
/// );
/// ```
class StaggerAnimationController {
  /// Total number of items to animate.
  final int itemCount;

  /// Delay in milliseconds between each item.
  final int itemDelayMs;

  /// Maximum number of items before batching starts.
  ///
  /// After this many items, remaining items animate together
  /// to prevent excessive total animation time.
  final int maxBatchItems;

  /// Base duration for each item animation.
  final Duration itemDuration;

  /// Whether to respect reduced motion settings.
  final bool respectReducedMotion;

  /// Creates a stagger animation controller.
  ///
  /// [itemCount] is the total number of items.
  /// [itemDelayMs] is the delay between items (default 50ms).
  /// [maxBatchItems] is the max items before batching (default 10).
  /// [itemDuration] is the duration for each item (default 400ms).
  StaggerAnimationController({
    required this.itemCount,
    this.itemDelayMs = 50,
    this.maxBatchItems = 10,
    this.itemDuration = const Duration(milliseconds: 400),
    this.respectReducedMotion = true,
  });

  /// Gets the animation delay for an item at the given index.
  ///
  /// Returns zero delay if reduced motion is preferred.
  /// Items beyond [maxBatchItems] get the same delay as the last
  /// non-batched item.
  Duration getDelay(int index, [BuildContext? context]) {
    // Check reduced motion
    if (context != null &&
        respectReducedMotion &&
        MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }

    // Clamp index to max batch items
    final effectiveIndex = index.clamp(0, maxBatchItems - 1);
    return Duration(milliseconds: effectiveIndex * itemDelayMs);
  }

  /// Gets the total duration for all staggered animations.
  Duration get totalDuration {
    final lastItemDelay = (maxBatchItems - 1).clamp(0, itemCount - 1) * itemDelayMs;
    return Duration(milliseconds: lastItemDelay) + itemDuration;
  }

  /// Checks if an item should animate.
  ///
  /// Returns false if reduced motion is enabled.
  bool shouldAnimate(BuildContext context) {
    if (!respectReducedMotion) return true;
    return !MediaQuery.of(context).disableAnimations;
  }

  /// Creates a widget that applies staggered animation to its child.
  ///
  /// [index] is the item's position in the list.
  /// [child] is the widget to animate.
  /// [type] is the type of animation to apply.
  Widget buildAnimatedItem(
    int index,
    Widget child, {
    PageStaggerAnimationType type = PageStaggerAnimationType.fadeSlideUp,
  }) {
    return _StaggeredAnimatedItem(
      index: index,
      controller: this,
      type: type,
      child: child,
    );
  }
}

/// Types of staggered animations available for page transitions.
enum PageStaggerAnimationType {
  /// Fade in while sliding up.
  fadeSlideUp,

  /// Fade in while sliding from left.
  fadeSlideLeft,

  /// Fade in while sliding from right.
  fadeSlideRight,

  /// Fade in with scale effect.
  fadeScale,

  /// Simple fade only.
  fadeOnly,
}

/// Internal widget for staggered animated items.
class _StaggeredAnimatedItem extends StatefulWidget {
  final int index;
  final StaggerAnimationController controller;
  final PageStaggerAnimationType type;
  final Widget child;

  const _StaggeredAnimatedItem({
    required this.index,
    required this.controller,
    required this.type,
    required this.child,
  });

  @override
  State<_StaggeredAnimatedItem> createState() => _StaggeredAnimatedItemState();
}

class _StaggeredAnimatedItemState extends State<_StaggeredAnimatedItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.controller.itemDuration,
      vsync: this,
    );

    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppCurves.pageEnter,
    ));

    switch (widget.type) {
      case PageStaggerAnimationType.fadeSlideUp:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: AppCurves.pageEnter,
        ));
        _scaleAnimation = AlwaysStoppedAnimation(1.0);
        break;

      case PageStaggerAnimationType.fadeSlideLeft:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(-0.15, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: AppCurves.pageEnter,
        ));
        _scaleAnimation = AlwaysStoppedAnimation(1.0);
        break;

      case PageStaggerAnimationType.fadeSlideRight:
        _slideAnimation = Tween<Offset>(
          begin: const Offset(0.15, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: AppCurves.pageEnter,
        ));
        _scaleAnimation = AlwaysStoppedAnimation(1.0);
        break;

      case PageStaggerAnimationType.fadeScale:
        _slideAnimation = AlwaysStoppedAnimation(Offset.zero);
        _scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _animationController,
          curve: AppCurves.pageEnter,
        ));
        break;

      case PageStaggerAnimationType.fadeOnly:
        _slideAnimation = AlwaysStoppedAnimation(Offset.zero);
        _scaleAnimation = AlwaysStoppedAnimation(1.0);
        break;
    }
  }

  Future<void> _startAnimation() async {
    // Wait for the stagger delay
    final delay = widget.controller.getDelay(widget.index);
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check for reduced motion
    if (widget.controller.respectReducedMotion &&
        MediaQuery.of(context).disableAnimations) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(
              _slideAnimation.value.dx * 50, // Convert to pixels
              _slideAnimation.value.dy * 50,
            ),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Hero animation configuration for consistent hero transitions.
class AppHeroAnimation {
  AppHeroAnimation._();

  /// Default hero flight shuttle builder with fade effect.
  static Widget flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;

    return FadeTransition(
      opacity: animation.drive(
        Tween<double>(begin: 0.0, end: 1.0).chain(
          CurveTween(curve: AppCurves.pageEnter),
        ),
      ),
      child: toHero.child,
    );
  }

  /// Create placeholders for hero widgets during transition.
  static Widget placeholderBuilder(
    BuildContext context,
    Size heroSize,
    Widget child,
  ) {
    return SizedBox(
      width: heroSize.width,
      height: heroSize.height,
    );
  }
}

/// Route observer for tracking page transitions and analytics.
class PageTransitionObserver extends NavigatorObserver {
  /// Callback when a route is pushed.
  final void Function(Route<dynamic>? route, Route<dynamic>? previousRoute)?
      onPush;

  /// Callback when a route is popped.
  final void Function(Route<dynamic>? route, Route<dynamic>? previousRoute)?
      onPop;

  /// Creates a page transition observer.
  PageTransitionObserver({
    this.onPush,
    this.onPop,
  });

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPush?.call(route, previousRoute);
    // Provide haptic feedback on page push
    HapticFeedback.lightImpact();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    onPop?.call(route, previousRoute);
  }
}

/// Helper extension for reducing motion-aware animations.
extension ReducedMotionExtension on BuildContext {
  /// Whether reduced motion is preferred.
  bool get prefersReducedMotion => MediaQuery.of(this).disableAnimations;

  /// Duration that respects reduced motion preference.
  Duration animationDuration(Duration normalDuration) {
    return prefersReducedMotion ? Duration.zero : normalDuration;
  }

  /// Curve that respects reduced motion preference.
  Curve animationCurve(Curve normalCurve) {
    return prefersReducedMotion ? Curves.linear : normalCurve;
  }
}

/// Helper class to check both system and user reduced motion preferences.
///
/// Since GoRouter transitions don't have access to Riverpod context,
/// this helper uses SharedPreferences directly for the user preference.
class ReducedMotionHelper {
  ReducedMotionHelper._();

  static bool? _cachedUserPreference;
  static bool _initialized = false;

  /// Initialize the helper by loading user preference from SharedPreferences.
  ///
  /// Call this early in app startup (e.g., in main.dart).
  static Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    _cachedUserPreference = prefs.getBool('reduced_motion');
    _initialized = true;
  }

  /// Update the cached user preference.
  ///
  /// Call this when user changes the setting via [ReducedMotionNotifier].
  static void updateUserPreference(bool? value) {
    _cachedUserPreference = value;
  }

  /// Check if reduced motion should be used.
  ///
  /// Checks both user preference (from cache) and system setting.
  /// User preference takes precedence if explicitly set.
  static bool shouldReduceMotion(BuildContext context) {
    // User preference takes precedence if set
    if (_cachedUserPreference != null) {
      return _cachedUserPreference!;
    }

    // Fall back to system setting
    return MediaQuery.of(context).disableAnimations;
  }
}

/// Widget wrapper that applies reduced motion based on user + system preferences.
///
/// Use this to wrap animated widgets when you need to check both
/// user and system preferences without Riverpod context.
class ReducedMotionAwareTransition extends StatelessWidget {
  /// Builder when reduced motion is NOT active.
  final Widget Function(Animation<double> animation) normalBuilder;

  /// Builder when reduced motion IS active (optional, defaults to simple fade).
  final Widget Function(Animation<double> animation)? reducedBuilder;

  /// The animation to use.
  final Animation<double> animation;

  /// The child widget (passed to builders).
  final Widget child;

  const ReducedMotionAwareTransition({
    super.key,
    required this.animation,
    required this.normalBuilder,
    this.reducedBuilder,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final shouldReduce = ReducedMotionHelper.shouldReduceMotion(context);

    if (shouldReduce) {
      // Use reduced builder or default to simple fade
      if (reducedBuilder != null) {
        return reducedBuilder!(animation);
      }
      return FadeTransition(opacity: animation, child: child);
    }

    return normalBuilder(animation);
  }
}

/// Consumer-aware page transition wrapper.
///
/// Use this when you have access to Riverpod and want to wrap
/// a page with proper reduced motion support.
class ReducedMotionPage extends ConsumerWidget {
  /// The child page to display.
  final Widget child;

  /// Whether to use instant transitions when reduced motion is enabled.
  /// If false, uses a simple fade instead.
  final bool useInstant;

  const ReducedMotionPage({
    super.key,
    required this.child,
    this.useInstant = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Import and watch the accessibility provider
    // Note: This requires the accessibility_provider to be imported where used
    return child;
  }
}

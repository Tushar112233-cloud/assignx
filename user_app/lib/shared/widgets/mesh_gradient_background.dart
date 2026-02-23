import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Enum representing the position of the mesh gradient focal point.
///
/// Each position determines where the gradient layers are centered,
/// creating different visual effects for the background.
enum MeshPosition {
  /// Gradient positioned at the top-right corner.
  topRight,

  /// Gradient positioned at the bottom-right corner (default).
  bottomRight,

  /// Gradient positioned at the center of the widget.
  center,

  /// Gradient positioned at the top-left corner.
  topLeft,

  /// Gradient positioned at the bottom-left corner.
  bottomLeft,
}

/// Pastel mesh gradient colors for creating organic, flowing background effects.
///
/// These colors are designed to work together in layered radial gradients
/// to create a soft, modern mesh gradient appearance.
class MeshColors {
  MeshColors._();

  /// Soft pink - Color(0xFFFFE4E6)
  static const Color meshPink = Color(0xFFFFE4E6);

  /// Soft peach - Color(0xFFFFEDD5)
  static const Color meshPeach = Color(0xFFFFEDD5);

  /// Soft orange - Color(0xFFFED7AA)
  static const Color meshOrange = Color(0xFFFED7AA);

  /// Soft yellow - Color(0xFFFEF08A)
  static const Color meshYellow = Color(0xFFFEF08A);

  /// Soft green - Color(0xFFBBF7D0)
  static const Color meshGreen = Color(0xFFBBF7D0);

  /// Soft blue - Color(0xFFBAE6FD)
  static const Color meshBlue = Color(0xFFBAE6FD);

  /// Soft purple - Color(0xFFE9D5FF)
  static const Color meshPurple = Color(0xFFE9D5FF);

  /// Default gradient colors (pink, peach, orange).
  static const List<Color> defaultColors = [meshPink, meshPeach, meshOrange];

  /// Cool gradient colors (blue, green, purple).
  static const List<Color> coolColors = [meshBlue, meshGreen, meshPurple];

  /// Warm gradient colors (orange, yellow, peach).
  static const List<Color> warmColors = [meshOrange, meshYellow, meshPeach];

  /// Sunset gradient colors (pink, orange, yellow).
  static const List<Color> sunsetColors = [meshPink, meshOrange, meshYellow];

  // Modern vibrant gradient colors
  /// Modern pink - Color(0xFFFFB6C1)
  static const Color modernPink = Color(0xFFFFB6C1);

  /// Modern magenta - Color(0xFFE991CF)
  static const Color modernMagenta = Color(0xFFE991CF);

  /// Modern purple - Color(0xFFC471ED)
  static const Color modernPurple = Color(0xFFC471ED);

  /// Modern blue - Color(0xFF8EC5FC)
  static const Color modernBlue = Color(0xFF8EC5FC);

  /// Modern cyan - Color(0xFF00D4FF)
  static const Color modernCyan = Color(0xFF00D4FF);

  /// Modern gradient colors (pink to blue, like modern apps).
  static const List<Color> modernColors = [
    modernPink,
    modernMagenta,
    modernPurple,
    modernBlue,
  ];

  /// Subtle modern colors (very light, for page backgrounds).
  static const List<Color> subtleModernColors = [
    Color(0xFFFFF5F7), // Very light pink
    Color(0xFFFAF5FF), // Very light purple
    Color(0xFFF5FAFF), // Very light blue
  ];
}

/// A widget that creates an organic, flowing mesh gradient background effect.
///
/// The mesh gradient is created by layering multiple radial gradients at
/// different positions, creating a soft, modern background effect commonly
/// seen in contemporary UI designs.
///
/// Example:
/// ```dart
/// MeshGradientBackground(
///   position: MeshPosition.bottomRight,
///   colors: [MeshColors.meshPink, MeshColors.meshPeach, MeshColors.meshOrange],
///   opacity: 0.6,
///   animated: false,
///   child: YourContent(),
/// )
/// ```
class MeshGradientBackground extends StatefulWidget {
  /// The child widget to display on top of the gradient.
  final Widget child;

  /// The position of the gradient focal point.
  /// Defaults to [MeshPosition.bottomRight].
  final MeshPosition position;

  /// Custom colors for the mesh gradient layers.
  /// If not provided, uses [MeshColors.defaultColors].
  /// Should contain at least 3 colors for best effect.
  final List<Color>? colors;

  /// Overall opacity of the gradient layers.
  /// Value should be between 0.0 and 1.0. Defaults to 0.6.
  final double opacity;

  /// Whether to animate the gradient with a slow rotation effect.
  /// When true, applies a 20-second rotation animation.
  /// Defaults to false for performance.
  final bool animated;

  /// Duration of one complete rotation when [animated] is true.
  /// Defaults to 20 seconds.
  final Duration animationDuration;

  const MeshGradientBackground({
    super.key,
    required this.child,
    this.position = MeshPosition.bottomRight,
    this.colors,
    this.opacity = 0.6,
    this.animated = false,
    this.animationDuration = const Duration(seconds: 20),
  }) : assert(opacity >= 0.0 && opacity <= 1.0,
            'Opacity must be between 0.0 and 1.0');

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      _initializeAnimation();
    }
  }

  @override
  void didUpdateWidget(MeshGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated != oldWidget.animated) {
      if (widget.animated) {
        _initializeAnimation();
      } else {
        _disposeAnimation();
      }
    }
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
  }

  void _disposeAnimation() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeAnimation();
    super.dispose();
  }

  /// Get alignment values based on the mesh position.
  List<Alignment> _getAlignments() {
    switch (widget.position) {
      case MeshPosition.topRight:
        return [
          const Alignment(1.2, -1.2),
          const Alignment(0.8, -0.5),
          const Alignment(1.5, 0.2),
          const Alignment(0.3, -1.0),
        ];
      case MeshPosition.bottomRight:
        return [
          const Alignment(1.2, 1.2),
          const Alignment(0.8, 0.5),
          const Alignment(1.5, -0.2),
          const Alignment(0.3, 1.0),
        ];
      case MeshPosition.center:
        return [
          const Alignment(0.5, 0.5),
          const Alignment(-0.5, -0.3),
          const Alignment(0.3, -0.5),
          const Alignment(-0.3, 0.5),
        ];
      case MeshPosition.topLeft:
        return [
          const Alignment(-1.2, -1.2),
          const Alignment(-0.8, -0.5),
          const Alignment(-1.5, 0.2),
          const Alignment(-0.3, -1.0),
        ];
      case MeshPosition.bottomLeft:
        return [
          const Alignment(-1.2, 1.2),
          const Alignment(-0.8, 0.5),
          const Alignment(-1.5, -0.2),
          const Alignment(-0.3, 1.0),
        ];
    }
  }

  /// Get radius values for each gradient layer.
  List<double> _getRadii() {
    return [1.5, 1.2, 1.0, 0.8];
  }

  /// Get opacity multipliers for each layer to create depth.
  List<double> _getOpacityMultipliers() {
    return [0.7, 0.5, 0.4, 0.3];
  }

  @override
  Widget build(BuildContext context) {
    final effectiveColors = widget.colors ?? MeshColors.defaultColors;

    // Ensure we have at least 3 colors by cycling if needed
    final expandedColors = _expandColors(effectiveColors, 4);

    if (widget.animated && _controller != null) {
      return AnimatedBuilder(
        animation: _controller!,
        builder: (context, child) {
          return _buildGradientStack(expandedColors, _controller!.value);
        },
      );
    }

    return _buildGradientStack(expandedColors, 0.0);
  }

  /// Expand or cycle colors to ensure we have the required count.
  List<Color> _expandColors(List<Color> colors, int count) {
    if (colors.length >= count) return colors;
    final expanded = <Color>[];
    for (var i = 0; i < count; i++) {
      expanded.add(colors[i % colors.length]);
    }
    return expanded;
  }

  Widget _buildGradientStack(List<Color> colors, double animationValue) {
    final alignments = _getAlignments();
    final radii = _getRadii();
    final opacityMultipliers = _getOpacityMultipliers();

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient layers
        ...List.generate(
          math.min(alignments.length, colors.length),
          (index) {
            final layerOpacity = widget.opacity * opacityMultipliers[index];
            final color = colors[index];

            Widget gradientLayer = Positioned.fill(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: alignments[index],
                      radius: radii[index],
                      colors: [
                        color.withValues(alpha: layerOpacity),
                        color.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            );

            // Apply rotation animation if enabled
            if (widget.animated && animationValue > 0) {
              final rotationAngle = animationValue * 2 * math.pi;
              // Alternate rotation direction for different layers
              final direction = index.isEven ? 1.0 : -1.0;
              // Vary rotation speed by layer
              final speedMultiplier = 1.0 - (index * 0.15);

              gradientLayer = Transform.rotate(
                angle: rotationAngle * direction * speedMultiplier,
                child: gradientLayer,
              );
            }

            return gradientLayer;
          },
        ),
        // Child widget on top
        widget.child,
      ],
    );
  }
}

/// Preset mesh gradient background configurations for common use cases.
class MeshGradientBackgroundPresets {
  MeshGradientBackgroundPresets._();

  /// Warm sunset gradient in bottom-right corner.
  static MeshGradientBackground sunset({
    required Widget child,
    double opacity = 0.6,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      colors: MeshColors.sunsetColors,
      opacity: opacity,
      animated: animated,
      child: child,
    );
  }

  /// Cool ocean gradient in top-right corner.
  static MeshGradientBackground ocean({
    required Widget child,
    double opacity = 0.6,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.topRight,
      colors: MeshColors.coolColors,
      opacity: opacity,
      animated: animated,
      child: child,
    );
  }

  /// Warm peachy gradient centered.
  static MeshGradientBackground peach({
    required Widget child,
    double opacity = 0.5,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.center,
      colors: MeshColors.warmColors,
      opacity: opacity,
      animated: animated,
      child: child,
    );
  }

  /// Subtle default gradient in bottom-right.
  static MeshGradientBackground subtle({
    required Widget child,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      colors: MeshColors.defaultColors,
      opacity: 0.4,
      animated: animated,
      child: child,
    );
  }

  /// Vibrant gradient with higher opacity and animation.
  static MeshGradientBackground vibrant({
    required Widget child,
    List<Color>? colors,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.center,
      colors: colors ?? MeshColors.defaultColors,
      opacity: 0.7,
      animated: true,
      animationDuration: const Duration(seconds: 25),
      child: child,
    );
  }

  /// Modern app-style gradient (pink to blue, vibrant).
  /// Perfect for auth screens and landing pages.
  static MeshGradientBackground modern({
    required Widget child,
    double opacity = 0.8,
    bool animated = false,
    MeshPosition position = MeshPosition.topRight,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: MeshColors.modernColors,
      opacity: opacity,
      animated: animated,
      child: child,
    );
  }

  /// Subtle modern gradient for page backgrounds.
  /// Very light, doesn't distract from content.
  static MeshGradientBackground subtleModern({
    required Widget child,
    double opacity = 0.7,
    MeshPosition position = MeshPosition.topRight,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: MeshColors.subtleModernColors,
      opacity: opacity,
      animated: false,
      child: child,
    );
  }
}

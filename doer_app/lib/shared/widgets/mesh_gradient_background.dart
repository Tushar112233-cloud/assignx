/// Mesh gradient background widget.
///
/// Creates organic, flowing gradient backgrounds using layered
/// radial gradients with configurable positions and colors.
/// Uses teal/cyan/mint pastel palette from [AppColors].
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Position of the mesh gradient focal point.
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

/// Teal/cyan/mint mesh gradient color presets.
///
/// Colors reference [AppColors] mesh constants for consistency
/// across the doer app design system.
class MeshColors {
  MeshColors._();

  /// Soft pastel teal - references [AppColors.meshTeal].
  static const Color meshTeal = AppColors.meshTeal;

  /// Soft pastel cyan - references [AppColors.meshCyan].
  static const Color meshCyan = AppColors.meshCyan;

  /// Soft pastel mint green - references [AppColors.meshMint].
  static const Color meshMint = AppColors.meshMint;

  /// Soft pastel lavender - references [AppColors.meshLavender].
  static const Color meshLavender = AppColors.meshLavender;

  /// Default gradient colors (teal, cyan, mint, lavender).
  static const List<Color> defaultColors = [
    meshTeal,
    meshCyan,
    meshMint,
    meshLavender,
  ];

  /// Cool gradient colors (cyan, teal, lavender).
  static const List<Color> coolColors = [meshCyan, meshTeal, meshLavender];

  /// Fresh gradient colors (mint, teal, cyan).
  static const List<Color> freshColors = [meshMint, meshTeal, meshCyan];

  /// Subtle gradient colors - very light tints for page backgrounds.
  static const List<Color> subtleColors = [
    Color(0xFFF0FDFA), // Very light teal
    Color(0xFFECFEFF), // Very light cyan
    Color(0xFFF0FDF4), // Very light mint
  ];
}

/// A widget that creates an organic, flowing mesh gradient background.
///
/// The mesh gradient is created by layering multiple radial gradients at
/// different positions, creating a soft, modern "colored glow from corners"
/// effect using teal/cyan/mint pastels.
///
/// Example:
/// ```dart
/// MeshGradientBackground(
///   position: MeshPosition.bottomRight,
///   colors: MeshColors.defaultColors,
///   opacity: 0.6,
///   animated: true,
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

  /// Whether to animate the gradient with a subtle breathing effect.
  /// When true, applies a slow opacity/position animation.
  /// Defaults to false for performance.
  final bool animated;

  /// Duration of one complete animation cycle when [animated] is true.
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
  }) : assert(
         opacity >= 0.0 && opacity <= 1.0,
         'Opacity must be between 0.0 and 1.0',
       );

  @override
  State<MeshGradientBackground> createState() =>
      _MeshGradientBackgroundState();
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
    )..repeat(reverse: true);
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
        ...List.generate(
          math.min(alignments.length, colors.length),
          (index) {
            // Subtle breathing effect: modulate opacity slightly with animation.
            final breathFactor =
                widget.animated ? 0.85 + 0.15 * animationValue : 1.0;
            final layerOpacity =
                widget.opacity * opacityMultipliers[index] * breathFactor;
            final color = colors[index];

            // Subtle position shift for breathing effect.
            final positionShift =
                widget.animated ? 0.05 * math.sin(animationValue * math.pi + index) : 0.0;
            final animatedAlignment = Alignment(
              alignments[index].x + positionShift,
              alignments[index].y + positionShift * 0.5,
            );

            final Widget gradientLayer = Positioned.fill(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: animatedAlignment,
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

            return gradientLayer;
          },
        ),
        widget.child,
      ],
    );
  }
}

/// Preset mesh gradient background configurations.
///
/// All presets use teal/cyan/mint pastels from the doer app palette.
class MeshGradientBackgroundPresets {
  MeshGradientBackgroundPresets._();

  /// Fresh teal gradient in bottom-right corner.
  static MeshGradientBackground fresh({
    required Widget child,
    double opacity = 0.6,
    bool animated = false,
  }) {
    return MeshGradientBackground(
      position: MeshPosition.bottomRight,
      colors: MeshColors.freshColors,
      opacity: opacity,
      animated: animated,
      child: child,
    );
  }

  /// Cool cyan/teal gradient in top-right corner.
  static MeshGradientBackground cool({
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

  /// Subtle teal gradient for page backgrounds.
  ///
  /// Very light, does not distract from content.
  static MeshGradientBackground subtle({
    required Widget child,
    bool animated = false,
    MeshPosition position = MeshPosition.bottomRight,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: MeshColors.subtleColors,
      opacity: 0.7,
      animated: animated,
      child: child,
    );
  }

  /// Default teal/cyan/mint gradient with all four corners.
  static MeshGradientBackground tealMesh({
    required Widget child,
    double opacity = 0.6,
    bool animated = false,
    MeshPosition position = MeshPosition.topRight,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: MeshColors.defaultColors,
      opacity: opacity,
      animated: animated,
      child: child,
    );
  }

  /// Animated breathing gradient for auth and activation screens.
  static MeshGradientBackground breathing({
    required Widget child,
    List<Color>? colors,
    MeshPosition position = MeshPosition.center,
  }) {
    return MeshGradientBackground(
      position: position,
      colors: colors ?? MeshColors.defaultColors,
      opacity: 0.7,
      animated: true,
      animationDuration: const Duration(seconds: 25),
      child: child,
    );
  }
}

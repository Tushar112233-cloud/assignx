/// Mesh gradient background widget.
///
/// Creates organic, flowing gradient backgrounds using layered
/// radial gradients with configurable positions and colors.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Position of the mesh gradient focal point.
enum MeshPosition {
  topRight,
  bottomRight,
  center,
  topLeft,
  bottomLeft,
}

/// Pastel mesh gradient colors for background effects.
class MeshColors {
  MeshColors._();

  static const Color meshPink = Color(0xFFFFE4E6);
  static const Color meshPeach = Color(0xFFFFEDD5);
  static const Color meshOrange = Color(0xFFFED7AA);
  static const Color meshYellow = Color(0xFFFEF08A);
  static const Color meshGreen = Color(0xFFBBF7D0);
  static const Color meshBlue = Color(0xFFBAE6FD);
  static const Color meshPurple = Color(0xFFE9D5FF);

  static const List<Color> defaultColors = [meshPink, meshPeach, meshOrange];
  static const List<Color> coolColors = [meshBlue, meshGreen, meshPurple];
  static const List<Color> warmColors = [meshOrange, meshYellow, meshPeach];
  static const List<Color> sunsetColors = [meshPink, meshOrange, meshYellow];

  static const Color modernPink = Color(0xFFFFB6C1);
  static const Color modernMagenta = Color(0xFFE991CF);
  static const Color modernPurple = Color(0xFFC471ED);
  static const Color modernBlue = Color(0xFF8EC5FC);
  static const Color modernCyan = Color(0xFF00D4FF);

  static const List<Color> modernColors = [
    modernPink,
    modernMagenta,
    modernPurple,
    modernBlue,
  ];

  static const List<Color> subtleModernColors = [
    Color(0xFFFFF5F7),
    Color(0xFFFAF5FF),
    Color(0xFFF5FAFF),
  ];
}

/// A widget that creates an organic, flowing mesh gradient background.
class MeshGradientBackground extends StatefulWidget {
  final Widget child;
  final MeshPosition position;
  final List<Color>? colors;
  final double opacity;
  final bool animated;
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

  List<double> _getRadii() {
    return [1.5, 1.2, 1.0, 0.8];
  }

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
            final layerOpacity =
                widget.opacity * opacityMultipliers[index];
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

            if (widget.animated && animationValue > 0) {
              final rotationAngle = animationValue * 2 * math.pi;
              final direction = index.isEven ? 1.0 : -1.0;
              final speedMultiplier = 1.0 - (index * 0.15);

              gradientLayer = Transform.rotate(
                angle: rotationAngle * direction * speedMultiplier,
                child: gradientLayer,
              );
            }

            return gradientLayer;
          },
        ),
        widget.child,
      ],
    );
  }
}

/// Preset mesh gradient background configurations.
class MeshGradientBackgroundPresets {
  MeshGradientBackgroundPresets._();

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

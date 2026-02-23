import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// App gradient definitions and utilities.
///
/// Provides consistent gradient decorations throughout the app
/// following the design system.
class AppGradients {
  AppGradients._();

  // ==========================================================================
  // Primary Gradients
  // ==========================================================================

  /// Primary gradient - dark to light blue.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryDark,
      AppColors.primary,
      AppColors.primaryLight,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Primary vertical gradient.
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primary,
      AppColors.primaryDark,
    ],
  );

  /// Subtle primary gradient for backgrounds.
  static LinearGradient get primarySubtle => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withAlpha(25),
          AppColors.primaryLight.withAlpha(13),
        ],
      );

  // ==========================================================================
  // Earthy Gradients (Professional theme)
  // ==========================================================================

  /// Earthy gradient - warm, professional tones.
  static const LinearGradient earthy = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2C3E50), // Dark slate
      Color(0xFF3498DB), // Blue
      Color(0xFF1ABC9C), // Teal
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Professional dark gradient.
  static const LinearGradient professional = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1A2E),
      Color(0xFF16213E),
      Color(0xFF0F3460),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Warm accent gradient.
  static const LinearGradient warmAccent = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE74C3C),
      Color(0xFFF39C12),
    ],
  );

  // ==========================================================================
  // Status Gradients
  // ==========================================================================

  /// Success gradient.
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF22C55E),
      Color(0xFF16A34A),
    ],
  );

  /// Warning gradient.
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B),
      Color(0xFFD97706),
    ],
  );

  /// Error gradient.
  static const LinearGradient error = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444),
      Color(0xFFDC2626),
    ],
  );

  // ==========================================================================
  // Background Gradients
  // ==========================================================================

  /// Light background gradient.
  static const LinearGradient lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFE2E8F0),
    ],
  );

  /// Dark background gradient.
  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );

  /// Card overlay gradient (for images with text).
  static LinearGradient get cardOverlay => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.black.withAlpha(179),
        ],
        stops: const [0.3, 1.0],
      );

  // ==========================================================================
  // Mesh Gradients
  // ==========================================================================

  /// Creates a mesh gradient decoration.
  ///
  /// Mesh gradients provide a modern, dynamic background effect
  /// by blending multiple radial gradients.
  static BoxDecoration meshGradient({
    List<Color>? colors,
    double opacity = 0.6,
  }) {
    final meshColors = colors ??
        [
          AppColors.primary,
          AppColors.primaryLight,
          const Color(0xFF8B5CF6), // Purple
          const Color(0xFF06B6D4), // Cyan
        ];

    // True mesh gradients require custom painting
    // This provides a blended approximation using the first two colors
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          meshColors[0].withAlpha((opacity * 100).round()),
          meshColors.length > 1
              ? meshColors[1].withAlpha((opacity * 100).round())
              : meshColors[0].withAlpha((opacity * 50).round()),
        ],
      ),
    );
  }

  /// Creates radial gradient spots for mesh effect.
  static List<BoxDecoration> meshSpots({
    required List<Color> colors,
    double opacity = 0.3,
  }) {
    return colors.map((color) {
      return BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color.withAlpha((opacity * 255).round()),
            color.withAlpha(0),
          ],
          stops: const [0.0, 1.0],
        ),
      );
    }).toList();
  }
}

/// Animated mesh background widget.
///
/// Creates a dynamic, animated gradient background with
/// floating color blobs for modern UI designs.
class AnimatedMeshBackground extends StatefulWidget {
  /// Child widget to display over the background.
  final Widget child;

  /// Colors for the mesh gradient.
  final List<Color>? colors;

  /// Animation duration for color movement.
  final Duration duration;

  /// Background base color.
  final Color? backgroundColor;

  /// Blur amount for the gradient blobs.
  final double blur;

  const AnimatedMeshBackground({
    super.key,
    required this.child,
    this.colors,
    this.duration = const Duration(seconds: 10),
    this.backgroundColor,
    this.blur = 100,
  });

  @override
  State<AnimatedMeshBackground> createState() => _AnimatedMeshBackgroundState();
}

class _AnimatedMeshBackgroundState extends State<AnimatedMeshBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          AppColors.primary.withAlpha(77),
          AppColors.primaryLight.withAlpha(77),
          const Color(0xFF8B5CF6).withAlpha(77),
          const Color(0xFF06B6D4).withAlpha(77),
        ];

    return Stack(
      children: [
        // Base background
        Container(
          color: widget.backgroundColor ?? AppColors.background,
        ),
        // Animated gradient blobs
        ...List.generate(colors.length, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final angle = (_controller.value * 2 * math.pi) +
                  (index * math.pi / colors.length);
              final offset = Offset(
                math.cos(angle) * 50,
                math.sin(angle) * 50,
              );

              return Positioned(
                left: _getBlobPosition(index, true) + offset.dx,
                top: _getBlobPosition(index, false) + offset.dy,
                child: Container(
                  width: widget.blur * 2,
                  height: widget.blur * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors[index],
                        colors[index].withAlpha(0),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
        // Child content
        widget.child,
      ],
    );
  }

  double _getBlobPosition(int index, bool isHorizontal) {
    final positions = isHorizontal
        ? [50.0, 200.0, 100.0, 250.0]
        : [100.0, 50.0, 300.0, 200.0];
    return positions[index % positions.length];
  }
}

/// Gradient text widget.
///
/// Displays text with a gradient fill instead of solid color.
///
/// Example:
/// ```dart
/// GradientText(
///   'Hello World',
///   gradient: AppGradients.primary,
///   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
/// )
/// ```
class GradientText extends StatelessWidget {
  /// Text to display.
  final String text;

  /// Gradient to apply to the text.
  final Gradient gradient;

  /// Text style (color will be overridden by gradient).
  final TextStyle? style;

  /// Text alignment.
  final TextAlign? textAlign;

  /// Maximum lines.
  final int? maxLines;

  /// Overflow behavior.
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  /// Creates a gradient text with primary gradient.
  factory GradientText.primary(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
  }) {
    return GradientText(
      text,
      gradient: AppGradients.primary,
      style: style,
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Gradient icon widget.
///
/// Displays an icon with a gradient fill.
class GradientIcon extends StatelessWidget {
  /// Icon to display.
  final IconData icon;

  /// Gradient to apply.
  final Gradient gradient;

  /// Icon size.
  final double size;

  const GradientIcon({
    super.key,
    required this.icon,
    required this.gradient,
    this.size = 24,
  });

  /// Creates a gradient icon with primary gradient.
  factory GradientIcon.primary(IconData icon, {double size = 24}) {
    return GradientIcon(
      icon: icon,
      gradient: AppGradients.primary,
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Icon(
        icon,
        size: size,
        color: Colors.white, // Will be masked by gradient
      ),
    );
  }
}

/// Gradient border container.
///
/// Creates a container with a gradient border.
class GradientBorderContainer extends StatelessWidget {
  /// Child widget.
  final Widget child;

  /// Border gradient.
  final Gradient gradient;

  /// Border width.
  final double borderWidth;

  /// Border radius.
  final double borderRadius;

  /// Background color.
  final Color? backgroundColor;

  /// Padding inside the container.
  final EdgeInsetsGeometry? padding;

  const GradientBorderContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.borderWidth = 2,
    this.borderRadius = 12,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surface,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// Animated gradient container.
///
/// Container with smoothly animating gradient colors.
class AnimatedGradientContainer extends StatefulWidget {
  /// Child widget.
  final Widget child;

  /// List of gradient color sets to animate between.
  final List<List<Color>> gradients;

  /// Animation duration for each gradient.
  final Duration duration;

  /// Border radius.
  final double borderRadius;

  /// Padding inside container.
  final EdgeInsetsGeometry? padding;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    required this.gradients,
    this.duration = const Duration(seconds: 3),
    this.borderRadius = 16,
    this.padding,
  });

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.gradients.length;
          });
          _controller.forward(from: 0);
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextIndex = (_currentIndex + 1) % widget.gradients.length;
    final currentColors = widget.gradients[_currentIndex];
    final nextColors = widget.gradients[nextIndex];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: List.generate(currentColors.length, (i) {
                return Color.lerp(
                  currentColors[i],
                  nextColors[i],
                  _controller.value,
                )!;
              }),
            ),
          ),
          padding: widget.padding,
          child: widget.child,
        );
      },
    );
  }
}

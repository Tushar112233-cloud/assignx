import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern gradient colors - vibrant and aesthetic.
class GradientColors {
  GradientColors._();

  /// Vibrant purple
  static const Color purple = Color(0xFFB794F6);

  /// Soft pink
  static const Color pink = Color(0xFFFBB6CE);

  /// Warm orange
  static const Color orange = Color(0xFFFBD38D);

  /// Soft coral
  static const Color coral = Color(0xFFFEB2B2);

  /// Light blue
  static const Color blue = Color(0xFF90CDF4);

  /// Mint green
  static const Color mint = Color(0xFF9AE6B4);

  /// Deep violet
  static const Color violet = Color(0xFFA78BFA);

  /// Peach
  static const Color peach = Color(0xFFFFD4A3);

  /// Base background - clean white
  static const Color background = Color(0xFFFAFAFA);
}

/// Gradient blob position on screen.
enum BlobPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  centerRight,
  centerLeft,
  center,
}

/// A vibrant gradient orb that creates a glowing effect.
///
/// Uses radial gradients with actual color fills for visibility.
class GradientOrb extends StatelessWidget {
  final BlobPosition position;
  final Color color;
  final double size;
  final double opacity;

  const GradientOrb({
    super.key,
    required this.position,
    required this.color,
    this.size = 300,
    this.opacity = 0.4,
  });

  /// Purple orb - vibrant and modern
  factory GradientOrb.purple({
    BlobPosition position = BlobPosition.topRight,
    double opacity = 0.35,
    double size = 350,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.purple,
      opacity: opacity,
      size: size,
    );
  }

  /// Pink orb - soft and aesthetic
  factory GradientOrb.pink({
    BlobPosition position = BlobPosition.bottomLeft,
    double opacity = 0.3,
    double size = 320,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.pink,
      opacity: opacity,
      size: size,
    );
  }

  /// Orange orb - warm accent
  factory GradientOrb.orange({
    BlobPosition position = BlobPosition.bottomRight,
    double opacity = 0.3,
    double size = 280,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.orange,
      opacity: opacity,
      size: size,
    );
  }

  /// Blue orb - cool and fresh
  factory GradientOrb.blue({
    BlobPosition position = BlobPosition.topLeft,
    double opacity = 0.25,
    double size = 300,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.blue,
      opacity: opacity,
      size: size,
    );
  }

  /// Coral orb - soft warm
  factory GradientOrb.coral({
    BlobPosition position = BlobPosition.centerRight,
    double opacity = 0.3,
    double size = 260,
  }) {
    return GradientOrb(
      position: position,
      color: GradientColors.coral,
      opacity: opacity,
      size: size,
    );
  }

  Alignment get _alignment {
    switch (position) {
      case BlobPosition.topLeft:
        return const Alignment(-0.9, -0.9);
      case BlobPosition.topRight:
        return const Alignment(0.9, -0.8);
      case BlobPosition.bottomLeft:
        return const Alignment(-0.9, 0.9);
      case BlobPosition.bottomRight:
        return const Alignment(0.9, 0.9);
      case BlobPosition.centerRight:
        return const Alignment(1.0, 0.3);
      case BlobPosition.centerLeft:
        return const Alignment(-1.0, 0.0);
      case BlobPosition.center:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: _alignment,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: opacity * 0.5),
                  color.withValues(alpha: 0.0),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern mesh gradient background with multiple colorful orbs.
class ModernGradientBackground extends StatelessWidget {
  final List<GradientOrb>? customOrbs;
  final bool useBlur;

  const ModernGradientBackground({
    super.key,
    this.customOrbs,
    this.useBlur = true,
  });

  /// Default vibrant gradient pattern
  static List<GradientOrb> get defaultOrbs => [
        // Large purple orb at top-right
        GradientOrb.purple(
          position: BlobPosition.topRight,
          opacity: 0.35,
          size: 400,
        ),
        // Pink orb at bottom-left
        GradientOrb.pink(
          position: BlobPosition.bottomLeft,
          opacity: 0.3,
          size: 350,
        ),
        // Orange accent at bottom-right
        GradientOrb.orange(
          position: BlobPosition.bottomRight,
          opacity: 0.25,
          size: 300,
        ),
      ];

  /// Alternative pattern with blue tones
  static List<GradientOrb> get bluePattern => [
        GradientOrb.blue(
          position: BlobPosition.topRight,
          opacity: 0.3,
          size: 380,
        ),
        GradientOrb.purple(
          position: BlobPosition.bottomLeft,
          opacity: 0.25,
          size: 320,
        ),
        GradientOrb.pink(
          position: BlobPosition.centerRight,
          opacity: 0.2,
          size: 260,
        ),
      ];

  /// Warm sunset pattern
  static List<GradientOrb> get sunsetPattern => [
        GradientOrb.orange(
          position: BlobPosition.topRight,
          opacity: 0.35,
          size: 400,
        ),
        GradientOrb.pink(
          position: BlobPosition.bottomRight,
          opacity: 0.3,
          size: 350,
        ),
        GradientOrb.coral(
          position: BlobPosition.bottomLeft,
          opacity: 0.25,
          size: 300,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final orbs = customOrbs ?? defaultOrbs;

    Widget content = Stack(children: orbs);

    if (useBlur) {
      content = Stack(
        children: [
          ...orbs,
          // Apply blur for smoother blending
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      );
    }

    return content;
  }
}

/// A scaffold with modern gradient background.
///
/// Provides vibrant, aesthetic gradients across the app.
class SubtleGradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final Color? backgroundColor;
  final List<GradientOrb>? orbs;
  final bool showGradients;

  const SubtleGradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = true,
    this.extendBodyBehindAppBar = true,
    this.backgroundColor,
    this.orbs,
    this.showGradients = true,
  });

  /// Standard preset with vibrant purple, pink, and orange
  factory SubtleGradientScaffold.standard({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      orbs: ModernGradientBackground.defaultOrbs,
    );
  }

  /// Blue-toned gradient preset
  factory SubtleGradientScaffold.blue({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: ModernGradientBackground.bluePattern,
    );
  }

  /// Warm sunset gradient preset
  factory SubtleGradientScaffold.sunset({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: ModernGradientBackground.sunsetPattern,
    );
  }

  /// Time-based gradient (morning/afternoon/evening)
  factory SubtleGradientScaffold.timeBased({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    final hour = DateTime.now().hour;
    List<GradientOrb> orbs;

    if (hour >= 5 && hour < 12) {
      // Morning: warm oranges and pinks
      orbs = [
        GradientOrb.orange(position: BlobPosition.topRight, opacity: 0.35, size: 400),
        GradientOrb.pink(position: BlobPosition.bottomLeft, opacity: 0.25, size: 320),
        GradientOrb.coral(position: BlobPosition.centerRight, opacity: 0.2, size: 260),
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon: purple and blue
      orbs = [
        GradientOrb.purple(position: BlobPosition.topRight, opacity: 0.35, size: 400),
        GradientOrb.blue(position: BlobPosition.bottomLeft, opacity: 0.25, size: 350),
        GradientOrb.pink(position: BlobPosition.bottomRight, opacity: 0.2, size: 280),
      ];
    } else {
      // Evening: deep purples and pinks
      orbs = [
        GradientOrb(
          position: BlobPosition.topRight,
          color: GradientColors.violet,
          opacity: 0.4,
          size: 420,
        ),
        GradientOrb.pink(position: BlobPosition.bottomLeft, opacity: 0.3, size: 350),
        GradientOrb.purple(position: BlobPosition.centerRight, opacity: 0.25, size: 280),
      ];
    }

    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      orbs: orbs,
    );
  }

  /// Minimal with single orb
  factory SubtleGradientScaffold.minimal({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
  }) {
    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: [
        GradientOrb.purple(position: BlobPosition.bottomRight, opacity: 0.35, size: 400),
      ],
    );
  }

  /// Random gradient based on seed
  factory SubtleGradientScaffold.random({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? bottomNavigationBar,
    int? seed,
  }) {
    final random = math.Random(seed ?? DateTime.now().millisecondsSinceEpoch);
    final positions = BlobPosition.values.toList()..shuffle(random);

    final colors = [
      GradientColors.purple,
      GradientColors.pink,
      GradientColors.orange,
      GradientColors.blue,
      GradientColors.coral,
      GradientColors.violet,
    ];

    final orbs = <GradientOrb>[];
    final orbCount = 2 + random.nextInt(2);

    for (int i = 0; i < orbCount; i++) {
      orbs.add(GradientOrb(
        position: positions[i],
        color: colors[random.nextInt(colors.length)],
        opacity: 0.25 + random.nextDouble() * 0.15,
        size: 280 + random.nextDouble() * 120,
      ));
    }

    return SubtleGradientScaffold(
      body: body,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      orbs: orbs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientOrbs = orbs ?? ModernGradientBackground.defaultOrbs;

    return Scaffold(
      backgroundColor: backgroundColor ?? GradientColors.background,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Gradient orbs with blur for smooth blending
          if (showGradients) ...[
            ...gradientOrbs,
            // Blur layer for smooth blending
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],

          // Actual content
          Positioned.fill(
            child: body,
          ),
        ],
      ),
    );
  }
}

/// Simple gradient background wrapper for any widget.
class SubtleGradientBackground extends StatelessWidget {
  final Widget child;
  final List<GradientOrb>? orbs;
  final Color? backgroundColor;
  final bool useBlur;

  const SubtleGradientBackground({
    super.key,
    required this.child,
    this.orbs,
    this.backgroundColor,
    this.useBlur = true,
  });

  factory SubtleGradientBackground.standard({required Widget child}) {
    return SubtleGradientBackground(
      orbs: ModernGradientBackground.defaultOrbs,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradientOrbs = orbs ?? ModernGradientBackground.defaultOrbs;

    return Container(
      color: backgroundColor ?? GradientColors.background,
      child: Stack(
        children: [
          ...gradientOrbs,
          if (useBlur)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: Colors.transparent),
              ),
            ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

// Backward compatibility aliases
typedef GradientBlob = GradientOrb;
typedef GradientPatch = GradientOrb;
typedef GradientPatchPosition = BlobPosition;
typedef OrganicGradientBlob = GradientOrb;
typedef GradientDirection = BlobPosition;
typedef SubtleGradientColors = GradientColors;
typedef MeshGradientBackground = ModernGradientBackground;
typedef RandomGradientBackground = ModernGradientBackground;

// Helper for TimeTheme compatibility
enum TimeTheme { morning, afternoon, evening }

TimeTheme getTimeTheme() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return TimeTheme.morning;
  if (hour >= 12 && hour < 17) return TimeTheme.afternoon;
  return TimeTheme.evening;
}

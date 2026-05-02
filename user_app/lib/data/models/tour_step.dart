import 'package:flutter/material.dart';

/// Position of the tour tooltip relative to the target widget.
enum TourPosition {
  /// Tooltip appears above the target widget.
  above,

  /// Tooltip appears below the target widget.
  below,

  /// Tooltip appears to the left of the target widget.
  left,

  /// Tooltip appears to the right of the target widget.
  right,

  /// Tooltip appears centered on screen (for fullscreen or welcome steps).
  center,
}

/// Represents a single step in an onboarding tour.
///
/// Each step highlights a specific widget and displays
/// informational content to guide the user.
///
/// Example:
/// ```dart
/// TourStep(
///   id: 'services',
///   title: 'Quick Actions',
///   description: 'Choose from various services to get help.',
///   targetKey: servicesKey,
///   position: TourPosition.above,
/// )
/// ```
class TourStep {
  /// Unique identifier for this step.
  final String id;

  /// Title displayed in the tooltip.
  final String title;

  /// Description text displayed in the tooltip.
  final String description;

  /// GlobalKey of the widget to highlight.
  /// If null, the tooltip will be centered on screen.
  final GlobalKey? targetKey;

  /// Position of the tooltip relative to the target.
  final TourPosition position;

  /// Whether this is the last step in the tour.
  final bool isLast;

  /// Optional icon to display in the tooltip.
  final IconData? icon;

  /// Optional custom padding around the cutout.
  final EdgeInsets? cutoutPadding;

  /// Optional custom border radius for the cutout.
  final double? cutoutBorderRadius;

  /// Whether to pulse/animate the cutout for attention.
  final bool pulseAnimation;

  const TourStep({
    required this.id,
    required this.title,
    required this.description,
    this.targetKey,
    this.position = TourPosition.below,
    this.isLast = false,
    this.icon,
    this.cutoutPadding,
    this.cutoutBorderRadius,
    this.pulseAnimation = false,
  });

  /// Creates a copy of this step with updated fields.
  TourStep copyWith({
    String? id,
    String? title,
    String? description,
    GlobalKey? targetKey,
    TourPosition? position,
    bool? isLast,
    IconData? icon,
    EdgeInsets? cutoutPadding,
    double? cutoutBorderRadius,
    bool? pulseAnimation,
  }) {
    return TourStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetKey: targetKey ?? this.targetKey,
      position: position ?? this.position,
      isLast: isLast ?? this.isLast,
      icon: icon ?? this.icon,
      cutoutPadding: cutoutPadding ?? this.cutoutPadding,
      cutoutBorderRadius: cutoutBorderRadius ?? this.cutoutBorderRadius,
      pulseAnimation: pulseAnimation ?? this.pulseAnimation,
    );
  }

  @override
  String toString() => 'TourStep(id: $id, title: $title, isLast: $isLast)';
}

/// Configuration for a complete tour.
class TourConfig {
  /// Unique identifier for this tour.
  final String tourId;

  /// List of steps in this tour.
  final List<TourStep> steps;

  /// Whether to show step indicators (1/5, 2/5, etc.).
  final bool showStepIndicator;

  /// Whether to allow skipping the tour.
  final bool allowSkip;

  /// Whether to show "Don't show again" checkbox.
  final bool showDontShowAgain;

  /// Overlay opacity (0.0 to 1.0).
  final double overlayOpacity;

  /// Animation duration in milliseconds.
  final int animationDurationMs;

  const TourConfig({
    required this.tourId,
    required this.steps,
    this.showStepIndicator = true,
    this.allowSkip = true,
    this.showDontShowAgain = true,
    this.overlayOpacity = 0.7,
    this.animationDurationMs = 350,
  });

  /// Gets a step by its index.
  TourStep? getStep(int index) {
    if (index < 0 || index >= steps.length) return null;
    return steps[index];
  }

  /// Total number of steps.
  int get totalSteps => steps.length;
}

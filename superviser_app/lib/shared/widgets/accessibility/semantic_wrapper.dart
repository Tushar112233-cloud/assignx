import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Semantic wrapper for improved accessibility.
///
/// Wraps widgets with proper semantics for screen readers.
class SemanticWrapper extends StatelessWidget {
  const SemanticWrapper({
    super.key,
    required this.child,
    this.label,
    this.hint,
    this.value,
    this.isButton = false,
    this.isHeader = false,
    this.isLink = false,
    this.isImage = false,
    this.isTextField = false,
    this.isSlider = false,
    this.isToggled,
    this.isChecked,
    this.isSelected,
    this.isEnabled = true,
    this.isHidden = false,
    this.isFocusable = true,
    this.isLiveRegion = false,
    this.excludeSemantics = false,
    this.onTap,
    this.onLongPress,
    this.sortKey,
  });

  final Widget child;
  final String? label;
  final String? hint;
  final String? value;
  final bool isButton;
  final bool isHeader;
  final bool isLink;
  final bool isImage;
  final bool isTextField;
  final bool isSlider;
  final bool? isToggled;
  final bool? isChecked;
  final bool? isSelected;
  final bool isEnabled;
  final bool isHidden;
  final bool isFocusable;
  final bool isLiveRegion;
  final bool excludeSemantics;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final SemanticsSortKey? sortKey;

  @override
  Widget build(BuildContext context) {
    if (excludeSemantics) {
      return ExcludeSemantics(child: child);
    }

    if (isHidden) {
      return ExcludeSemantics(excluding: true, child: child);
    }

    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      link: isLink,
      image: isImage,
      textField: isTextField,
      slider: isSlider,
      toggled: isToggled,
      checked: isChecked,
      selected: isSelected,
      enabled: isEnabled,
      focusable: isFocusable,
      liveRegion: isLiveRegion,
      onTap: onTap,
      onLongPress: onLongPress,
      sortKey: sortKey,
      child: child,
    );
  }
}

/// Semantic button wrapper.
class SemanticButton extends StatelessWidget {
  const SemanticButton({
    super.key,
    required this.child,
    required this.label,
    this.hint,
    this.isEnabled = true,
    this.onTap,
  });

  final Widget child;
  final String label;
  final String? hint;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      hint: hint,
      enabled: isEnabled,
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic heading wrapper.
class SemanticHeading extends StatelessWidget {
  const SemanticHeading({
    super.key,
    required this.child,
    this.level = 1,
  });

  final Widget child;
  final int level;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: child,
    );
  }
}

/// Semantic image wrapper.
class SemanticImage extends StatelessWidget {
  const SemanticImage({
    super.key,
    required this.child,
    required this.label,
  });

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: label,
      child: child,
    );
  }
}

/// Semantic list item wrapper.
class SemanticListItem extends StatelessWidget {
  const SemanticListItem({
    super.key,
    required this.child,
    required this.index,
    required this.total,
    this.label,
  });

  final Widget child;
  final int index;
  final int total;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label != null ? '$label, item ${index + 1} of $total' : 'Item ${index + 1} of $total',
      child: child,
    );
  }
}

/// Semantic live region for dynamic content updates.
class SemanticLiveRegion extends StatelessWidget {
  const SemanticLiveRegion({
    super.key,
    required this.child,
    this.label,
  });

  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: label,
      child: child,
    );
  }
}

/// Semantic toggle wrapper.
class SemanticToggle extends StatelessWidget {
  const SemanticToggle({
    super.key,
    required this.child,
    required this.label,
    required this.isOn,
    this.hint,
    this.onTap,
  });

  final Widget child;
  final String label;
  final bool isOn;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: isOn,
      label: label,
      hint: hint ?? (isOn ? 'Double tap to turn off' : 'Double tap to turn on'),
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic selection wrapper.
class SemanticSelection extends StatelessWidget {
  const SemanticSelection({
    super.key,
    required this.child,
    required this.label,
    required this.isSelected,
    this.hint,
    this.onTap,
  });

  final Widget child;
  final String label;
  final bool isSelected;
  final String? hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      label: label,
      hint: hint ?? (isSelected ? 'Selected' : 'Double tap to select'),
      onTap: onTap,
      child: child,
    );
  }
}

/// Semantic status indicator.
class SemanticStatus extends StatelessWidget {
  const SemanticStatus({
    super.key,
    required this.child,
    required this.status,
    this.description,
  });

  final Widget child;
  final String status;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: description != null ? '$status: $description' : 'Status: $status',
      child: child,
    );
  }
}

/// Extension methods for adding semantics to widgets.
extension SemanticsExtension on Widget {
  /// Add button semantics.
  Widget semanticButton(String label, {String? hint, VoidCallback? onTap}) {
    return SemanticButton(
      label: label,
      hint: hint,
      onTap: onTap,
      child: this,
    );
  }

  /// Add heading semantics.
  Widget semanticHeading({int level = 1}) {
    return SemanticHeading(level: level, child: this);
  }

  /// Add image semantics.
  Widget semanticImage(String label) {
    return SemanticImage(label: label, child: this);
  }

  /// Exclude from semantics tree.
  Widget excludeSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Add generic semantics.
  Widget withSemantics({
    String? label,
    String? hint,
    String? value,
    bool? isButton,
    bool? isHeader,
    bool? isToggled,
    bool? isChecked,
    bool? isSelected,
    bool? isEnabled,
    bool? isFocusable,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: isButton,
      header: isHeader,
      toggled: isToggled,
      checked: isChecked,
      selected: isSelected,
      enabled: isEnabled,
      focusable: isFocusable,
      onTap: onTap,
      child: this,
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Animated capsule tab bar with a sliding indicator.
///
/// Selected tab has [AppColors.primary] background with white text.
/// Unselected tabs have a transparent background with secondary text.
/// The capsule slides smoothly between tabs using [AnimatedPositioned].
///
/// ```dart
/// CapsuleTabBar(
///   tabs: ['All', 'Active', 'Completed'],
///   selectedIndex: _selected,
///   onTabChanged: (i) => setState(() => _selected = i),
/// )
/// ```
class CapsuleTabBar extends StatelessWidget {
  /// The list of tab labels to display.
  final List<String> tabs;

  /// The currently selected tab index.
  final int selectedIndex;

  /// Callback fired when a tab is tapped.
  final ValueChanged<int> onTabChanged;

  /// Optional background color for the outer container.
  /// Defaults to [AppColors.surfaceVariant].
  final Color? backgroundColor;

  /// Optional color for the selected capsule.
  /// Defaults to [AppColors.primary].
  final Color? selectedColor;

  /// Optional text color for the selected tab.
  /// Defaults to white.
  final Color? selectedTextColor;

  /// Optional text color for unselected tabs.
  /// Defaults to [AppColors.textSecondary].
  final Color? unselectedTextColor;

  /// Overall height of the tab bar.
  /// Defaults to 40.
  final double height;

  /// Internal padding between the outer container and the capsule track.
  /// Defaults to 4.
  final double internalPadding;

  /// Whether tabs should expand equally. When false, tabs size to content.
  /// Defaults to true.
  final bool expand;

  const CapsuleTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.backgroundColor,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.height = 40,
    this.internalPadding = 4,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.surfaceVariant;
    final capsuleColor = selectedColor ?? AppColors.primary;
    final selTextColor = selectedTextColor ?? Colors.white;
    final unselTextColor = unselectedTextColor ?? AppColors.textSecondary;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      padding: EdgeInsets.all(internalPadding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackHeight = height - (internalPadding * 2);
          final tabWidth = constraints.maxWidth / tabs.length;

          return Stack(
            children: [
              // Sliding capsule indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                left: expand ? tabWidth * selectedIndex : null,
                top: 0,
                bottom: 0,
                width: expand ? tabWidth : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: capsuleColor,
                    borderRadius: BorderRadius.circular(trackHeight / 2),
                    boxShadow: [
                      BoxShadow(
                        color: capsuleColor.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab labels
              Row(
                children: List.generate(tabs.length, (index) {
                  final isSelected = index == selectedIndex;

                  final child = GestureDetector(
                    onTap: () => onTabChanged(index),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      height: trackHeight,
                      child: Center(
                        child: Padding(
                          padding: expand
                              ? EdgeInsets.zero
                              : const EdgeInsets.symmetric(horizontal: 16),
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color:
                                  isSelected ? selTextColor : unselTextColor,
                            ),
                            child: Text(
                              tabs[index],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );

                  return expand ? Expanded(child: child) : child;
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

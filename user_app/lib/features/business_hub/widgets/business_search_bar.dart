library;

import 'package:flutter/material.dart';

import '../../campus_connect/widgets/search_bar_widget.dart';

/// Search bar for Business Hub.
///
/// Reuses [SearchBarWidget] with business-specific placeholder.
class BusinessSearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final String? initialValue;
  final VoidCallback? onFilterTap;

  const BusinessSearchBar({
    super.key,
    this.onChanged,
    this.initialValue,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBarWidget(
      onChanged: onChanged,
      initialValue: initialValue,
      onFilterTap: onFilterTap,
      placeholder: 'Search insights, opportunities, recruitment...',
    );
  }
}

library;

import 'package:flutter/material.dart';

import '../../campus_connect/widgets/search_bar_widget.dart';

/// Search bar for Pro Network.
///
/// Reuses [SearchBarWidget] with professional-specific placeholder.
class ProSearchBar extends StatelessWidget {
  final Function(String)? onChanged;
  final String? initialValue;
  final VoidCallback? onFilterTap;

  const ProSearchBar({
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
      placeholder: 'Search gigs, portfolios, discussions...',
    );
  }
}

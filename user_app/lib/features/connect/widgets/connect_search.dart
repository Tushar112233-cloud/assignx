import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../providers/connect_provider.dart';
import '../../../shared/widgets/glass_container.dart';

/// Search widget for the Connect module.
///
/// Features:
/// - Search bar with voice input icon
/// - Recent searches
/// - Search suggestions as user types
/// - Searches tutors, groups, and resources
class ConnectSearchBar extends ConsumerStatefulWidget {
  /// Optional callback when search is submitted.
  final ValueChanged<String>? onSearchSubmit;

  /// Optional callback when filter button is tapped.
  final VoidCallback? onFilterTap;

  /// Whether to show the filter button.
  final bool showFilterButton;

  /// Number of active filters (shows badge).
  final int activeFilterCount;

  const ConnectSearchBar({
    super.key,
    this.onSearchSubmit,
    this.onFilterTap,
    this.showFilterButton = true,
    this.activeFilterCount = 0,
  });

  @override
  ConsumerState<ConnectSearchBar> createState() => _ConnectSearchBarState();
}

class _ConnectSearchBarState extends ConsumerState<ConnectSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _controller.addListener(_onTextChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    final query = _controller.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    // Generate suggestions based on query
    final allSuggestions = [
      'Mathematics tutors',
      'Physics study group',
      'Data Structures notes',
      'Machine Learning resources',
      'Calculus help',
      'Chemistry past papers',
      'Economics video lectures',
      'Programming tutorials',
    ];

    setState(() {
      _suggestions = allSuggestions
          .where((s) => s.toLowerCase().contains(query))
          .take(5)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to stay reactive (filter count handled by parent)
    ref.watch(connectFilterProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Search field
              Expanded(
                child: GlassContainer(
                  blur: 10,
                  opacity: 0.7,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  borderColor: _focusNode.hasFocus
                      ? AppColors.primary.withAlpha(128)
                      : AppColors.border.withAlpha(77),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'Search tutors, groups, resources...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textTertiary,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (value) {
                            _handleSearch(value);
                          },
                          onChanged: (value) {
                            ref.read(connectFilterProvider.notifier).setSearchQuery(
                                  value.isEmpty ? null : value,
                                );
                          },
                        ),
                      ),
                      if (_controller.text.isNotEmpty) ...[
                        GestureDetector(
                          onTap: _clearSearch,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      // Voice input icon
                      GestureDetector(
                        onTap: _handleVoiceInput,
                        child: Icon(
                          Icons.mic_outlined,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter button
              if (widget.showFilterButton) ...[
                const SizedBox(width: 12),
                _buildFilterButton(),
              ],
            ],
          ),
        ),

        // Suggestions dropdown
        if (_showSuggestions && (_suggestions.isNotEmpty || _controller.text.isEmpty))
          _buildSuggestionsDropdown(),
      ],
    );
  }

  Widget _buildFilterButton() {
    final hasFilters = widget.activeFilterCount > 0;

    return GestureDetector(
      onTap: widget.onFilterTap,
      child: Stack(
        children: [
          GlassContainer(
            blur: 10,
            opacity: hasFilters ? 0.9 : 0.7,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(12),
            borderColor: hasFilters
                ? AppColors.primary.withAlpha(128)
                : AppColors.border.withAlpha(77),
            backgroundColor: hasFilters ? AppColors.primary.withAlpha(26) : null,
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: hasFilters ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          if (hasFilters)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${widget.activeFilterCount}',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown() {
    final recentSearches = ref.watch(recentSearchesProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: GlassContainer(
        blur: 15,
        opacity: 0.95,
        borderRadius: BorderRadius.circular(12),
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderColor: AppColors.border.withAlpha(77),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Show suggestions if typing, otherwise show recent
            if (_suggestions.isNotEmpty)
              ..._suggestions.map((suggestion) => _buildSuggestionItem(
                    suggestion,
                    icon: Icons.search,
                    onTap: () => _selectSuggestion(suggestion),
                  ))
            else if (_controller.text.isEmpty) ...[
              // Recent searches header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Searches',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _clearRecentSearches,
                      child: Text(
                        'Clear',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ...recentSearches.take(5).map((search) => _buildSuggestionItem(
                    search,
                    icon: Icons.history,
                    onTap: () => _selectSuggestion(search),
                    onRemove: () => _removeRecentSearch(search),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(
    String text, {
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onRemove,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onRemove != null)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                )
              else
                Icon(
                  Icons.north_west,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSearch(String query) {
    if (query.isEmpty) return;

    // Add to recent searches
    final recentSearches = ref.read(recentSearchesProvider);
    if (!recentSearches.contains(query)) {
      ref.read(recentSearchesProvider.notifier).state = [
        query,
        ...recentSearches.take(9),
      ];
    }

    // Update filter
    ref.read(connectFilterProvider.notifier).setSearchQuery(query);

    // Dismiss suggestions
    _focusNode.unfocus();
    setState(() => _showSuggestions = false);

    // Callback
    widget.onSearchSubmit?.call(query);
  }

  void _selectSuggestion(String suggestion) {
    _controller.text = suggestion;
    _handleSearch(suggestion);
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(connectFilterProvider.notifier).setSearchQuery(null);
    setState(() => _suggestions = []);
  }

  void _clearRecentSearches() {
    ref.read(recentSearchesProvider.notifier).state = [];
    setState(() {});
  }

  void _removeRecentSearch(String search) {
    final recentSearches = ref.read(recentSearchesProvider);
    ref.read(recentSearchesProvider.notifier).state =
        recentSearches.where((s) => s != search).toList();
    setState(() {});
  }

  void _handleVoiceInput() {
    // TODO: Implement voice input
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice search coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Hero search bar for the Connect screen header.
class ConnectHeroSearchBar extends ConsumerStatefulWidget {
  final ValueChanged<String>? onSearchSubmit;

  const ConnectHeroSearchBar({
    super.key,
    this.onSearchSubmit,
  });

  @override
  ConsumerState<ConnectHeroSearchBar> createState() =>
      _ConnectHeroSearchBarState();
}

class _ConnectHeroSearchBarState extends ConsumerState<ConnectHeroSearchBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(_isFocused ? 51 : 38),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withAlpha(_isFocused ? 77 : 51),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Colors.white.withAlpha(200),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search tutors, groups, resources...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withAlpha(153),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      ref
                          .read(connectFilterProvider.notifier)
                          .setSearchQuery(value);
                      widget.onSearchSubmit?.call(value);
                    }
                  },
                  onChanged: (value) {
                    ref.read(connectFilterProvider.notifier).setSearchQuery(
                          value.isEmpty ? null : value,
                        );
                  },
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    ref.read(connectFilterProvider.notifier).setSearchQuery(null);
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(38),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withAlpha(200),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

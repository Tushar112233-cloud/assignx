import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';

/// Reusable dropdown field with search functionality.
///
/// Supports both simple string lists and key-value maps.
class AppDropdown<T> extends StatelessWidget {
  /// Field label.
  final String? label;

  /// Hint text when no value selected.
  final String? hint;

  /// Currently selected value.
  final T? value;

  /// List of items.
  final List<T> items;

  /// Function to get display string from item.
  final String Function(T) itemLabel;

  /// Callback when value changes.
  final void Function(T?)? onChanged;

  /// Whether dropdown is enabled.
  final bool enabled;

  /// Error text.
  final String? errorText;

  /// Whether to show search field.
  final bool searchable;

  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.enabled = true,
    this.errorText,
    this.searchable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (searchable)
          _SearchableDropdown<T>(
            value: value,
            items: items,
            itemLabel: itemLabel,
            onChanged: onChanged,
            enabled: enabled,
            hint: hint,
            errorText: errorText,
          )
        else
          _SimpleDropdown<T>(
            value: value,
            items: items,
            itemLabel: itemLabel,
            onChanged: onChanged,
            enabled: enabled,
            hint: hint,
            errorText: errorText,
          ),
      ],
    );
  }
}

class _SimpleDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final bool enabled;
  final String? hint;
  final String? errorText;

  const _SimpleDropdown({
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.enabled = true,
    this.hint,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabel(item),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: enabled ? AppColors.surfaceVariant : AppColors.border,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down),
    );
  }
}

class _SearchableDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?)? onChanged;
  final bool enabled;
  final String? hint;
  final String? errorText;

  const _SearchableDropdown({
    this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.enabled = true,
    this.hint,
    this.errorText,
  });

  @override
  State<_SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<_SearchableDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    final displayText = widget.value != null
        ? widget.itemLabel(widget.value as T)
        : widget.hint ?? 'Select';

    return InkWell(
      onTap: widget.enabled ? () => _showSearchDialog(context) : null,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: widget.enabled ? AppColors.surfaceVariant : AppColors.border,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: widget.errorText != null
                ? AppColors.error
                : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16,
                  color: widget.value != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (context) => _SearchBottomSheet<T>(
        items: widget.items,
        itemLabel: widget.itemLabel,
        onSelected: (item) {
          widget.onChanged?.call(item);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchBottomSheet<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T) onSelected;

  const _SearchBottomSheet({
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  State<_SearchBottomSheet<T>> createState() => _SearchBottomSheetState<T>();
}

class _SearchBottomSheetState<T> extends State<_SearchBottomSheet<T>> {
  final _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          return widget.itemLabel(item).toLowerCase().contains(
                query.toLowerCase(),
              );
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Search field
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // Items list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(widget.itemLabel(item)),
                    onTap: () => widget.onSelected(item),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

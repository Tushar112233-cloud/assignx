import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Country data for phone input.
class _Country {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const _Country(this.name, this.code, this.dialCode, this.flag);
}

const _countries = [
  _Country('India', 'IN', '+91', '\u{1F1EE}\u{1F1F3}'),
  _Country('United States', 'US', '+1', '\u{1F1FA}\u{1F1F8}'),
  _Country('United Kingdom', 'UK', '+44', '\u{1F1EC}\u{1F1E7}'),
  _Country('Canada', 'CA', '+1', '\u{1F1E8}\u{1F1E6}'),
  _Country('Australia', 'AU', '+61', '\u{1F1E6}\u{1F1FA}'),
  _Country('Germany', 'DE', '+49', '\u{1F1E9}\u{1F1EA}'),
  _Country('France', 'FR', '+33', '\u{1F1EB}\u{1F1F7}'),
  _Country('China', 'CN', '+86', '\u{1F1E8}\u{1F1F3}'),
  _Country('Japan', 'JP', '+81', '\u{1F1EF}\u{1F1F5}'),
  _Country('South Korea', 'KR', '+82', '\u{1F1F0}\u{1F1F7}'),
  _Country('Brazil', 'BR', '+55', '\u{1F1E7}\u{1F1F7}'),
  _Country('Mexico', 'MX', '+52', '\u{1F1F2}\u{1F1FD}'),
  _Country('Singapore', 'SG', '+65', '\u{1F1F8}\u{1F1EC}'),
  _Country('UAE', 'AE', '+971', '\u{1F1E6}\u{1F1EA}'),
  _Country('Saudi Arabia', 'SA', '+966', '\u{1F1F8}\u{1F1E6}'),
  _Country('South Africa', 'ZA', '+27', '\u{1F1FF}\u{1F1E6}'),
  _Country('Nigeria', 'NG', '+234', '\u{1F1F3}\u{1F1EC}'),
  _Country('Pakistan', 'PK', '+92', '\u{1F1F5}\u{1F1F0}'),
  _Country('Bangladesh', 'BD', '+880', '\u{1F1E7}\u{1F1E9}'),
  _Country('Nepal', 'NP', '+977', '\u{1F1F3}\u{1F1F5}'),
  _Country('Sri Lanka', 'LK', '+94', '\u{1F1F1}\u{1F1F0}'),
  _Country('Indonesia', 'ID', '+62', '\u{1F1EE}\u{1F1E9}'),
  _Country('Malaysia', 'MY', '+60', '\u{1F1F2}\u{1F1FE}'),
  _Country('Thailand', 'TH', '+66', '\u{1F1F9}\u{1F1ED}'),
  _Country('Philippines', 'PH', '+63', '\u{1F1F5}\u{1F1ED}'),
  _Country('Vietnam', 'VN', '+84', '\u{1F1FB}\u{1F1F3}'),
  _Country('Italy', 'IT', '+39', '\u{1F1EE}\u{1F1F9}'),
  _Country('Spain', 'ES', '+34', '\u{1F1EA}\u{1F1F8}'),
  _Country('Netherlands', 'NL', '+31', '\u{1F1F3}\u{1F1F1}'),
  _Country('Russia', 'RU', '+7', '\u{1F1F7}\u{1F1FA}'),
  _Country('Egypt', 'EG', '+20', '\u{1F1EA}\u{1F1EC}'),
  _Country('Kenya', 'KE', '+254', '\u{1F1F0}\u{1F1EA}'),
  _Country('Argentina', 'AR', '+54', '\u{1F1E6}\u{1F1F7}'),
  _Country('Colombia', 'CO', '+57', '\u{1F1E8}\u{1F1F4}'),
  _Country('Turkey', 'TR', '+90', '\u{1F1F9}\u{1F1F7}'),
  _Country('Israel', 'IL', '+972', '\u{1F1EE}\u{1F1F1}'),
  _Country('New Zealand', 'NZ', '+64', '\u{1F1F3}\u{1F1FF}'),
  _Country('Ireland', 'IE', '+353', '\u{1F1EE}\u{1F1EA}'),
  _Country('Sweden', 'SE', '+46', '\u{1F1F8}\u{1F1EA}'),
  _Country('Switzerland', 'CH', '+41', '\u{1F1E8}\u{1F1ED}'),
];

/// Phone input widget with country code selector.
///
/// Shows a dropdown for country selection and a text field for the phone number.
/// Returns the full phone number including country code via [onChanged].
class PhoneInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final String initialCountryCode;

  const PhoneInput({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.initialCountryCode = 'IN',
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  late _Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.firstWhere(
      (c) => c.code == widget.initialCountryCode,
      orElse: () => _countries.first,
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _CountryPickerSheet(
        countries: _countries,
        selected: _selectedCountry,
        onSelected: (country) {
          setState(() => _selectedCountry = country);
          Navigator.pop(context);
          widget.onChanged?.call('${country.dialCode} ${widget.controller?.text ?? ''}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Row(
          children: [
            // Country code button
            GestureDetector(
              onTap: _showCountryPicker,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _selectedCountry.dialCode,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Phone number field
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => widget.onSubmitted?.call(),
                  onChanged: (value) {
                    widget.onChanged?.call('${_selectedCountry.dialCode} $value');
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]')),
                    LengthLimitingTextInputFormatter(14),
                  ],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? 'Phone number',
                    hintStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final List<_Country> countries;
  final _Country selected;
  final ValueChanged<_Country> onSelected;

  const _CountryPickerSheet({
    required this.countries,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchController = TextEditingController();
  List<_Country> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filtered = widget.countries.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.dialCode.contains(q) ||
            c.code.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              'Select Country',
              style: AppTextStyles.headingSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: _filter,
                decoration: InputDecoration(
                  hintText: 'Search country...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final country = _filtered[index];
                  final isSelected = country.code == widget.selected.code;
                  return ListTile(
                    leading: Text(
                      country.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      country.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    trailing: Text(
                      country.dialCode,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => widget.onSelected(country),
                    selected: isSelected,
                    selectedTileColor: AppColors.primary.withValues(alpha: 0.04),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

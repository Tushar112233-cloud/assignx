import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Word count input with presets and custom input.
class WordCountInput extends StatefulWidget {
  final int? value;
  final ValueChanged<int?> onChanged;
  final String? errorText;
  final int minWords;
  final int maxWords;

  const WordCountInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
    this.minWords = 500,
    this.maxWords = 50000,
  });

  @override
  State<WordCountInput> createState() => _WordCountInputState();
}

class _WordCountInputState extends State<WordCountInput> {
  final _controller = TextEditingController();
  bool _showCustomInput = false;

  // Common word count presets
  static const _presets = [1000, 2000, 3000, 5000, 10000];

  @override
  void initState() {
    super.initState();
    if (widget.value != null && !_presets.contains(widget.value)) {
      _showCustomInput = true;
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Word Count',
          style: AppTextStyles.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Approximate number of words in your document',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 12),

        // Preset chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._presets.map((count) {
              final isSelected = widget.value == count && !_showCustomInput;
              return _PresetChip(
                label: _formatWordCount(count),
                isSelected: isSelected,
                onTap: () {
                  setState(() => _showCustomInput = false);
                  widget.onChanged(count);
                },
              );
            }),
            _PresetChip(
              label: 'Custom',
              isSelected: _showCustomInput,
              onTap: () {
                setState(() => _showCustomInput = true);
                if (_controller.text.isNotEmpty) {
                  widget.onChanged(int.tryParse(_controller.text));
                }
              },
            ),
          ],
        ),

        // Custom input
        if (_showCustomInput) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: widget.errorText != null
                    ? AppColors.error
                    : AppColors.border,
              ),
            ),
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              decoration: InputDecoration(
                hintText: 'Enter word count',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                suffixText: 'words',
                suffixStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              onChanged: (value) {
                final count = int.tryParse(value);
                widget.onChanged(count);
              },
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Min: ${_formatWordCount(widget.minWords)} • Max: ${_formatWordCount(widget.maxWords)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],

        // Error text
        if (widget.errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],

        // Page estimate
        if (widget.value != null && widget.value! > 0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withAlpha(30)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 18,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Approximately ${_estimatePages(widget.value!)} pages (250 words/page)',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _formatWordCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count % 1000 == 0 ? 0 : 1)}k';
    }
    return count.toString();
  }

  int _estimatePages(int wordCount) {
    return (wordCount / 250).ceil();
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

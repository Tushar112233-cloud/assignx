/// FAQ list widget for the support screen.
///
/// Displays a list of expandable FAQ items loaded from the support
/// provider, grouped by category.
///
/// ## Usage
/// ```dart
/// FaqList(faqs: supportState.faqs)
/// ```
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/support_provider.dart';

/// A widget that displays a list of expandable FAQ items.
///
/// Each FAQ item can be tapped to expand and show its answer.
/// Items are displayed in a card container with dividers.
class FaqList extends StatefulWidget {
  /// Creates a FAQ list with the specified items.
  const FaqList({
    super.key,
    required this.faqs,
  });

  /// The list of FAQ items to display.
  final List<FAQ> faqs;

  @override
  State<FaqList> createState() => _FaqListState();
}

class _FaqListState extends State<FaqList> {
  /// Tracks which FAQ items are expanded.
  final Set<String> _expandedIds = {};

  void _toggleExpanded(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.faqs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: Text(
            'No FAQs available at the moment.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderRadiusMd,
        child: Column(
          children: [
            for (int i = 0; i < widget.faqs.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: AppColors.borderLight),
              _FaqItem(
                faq: widget.faqs[i],
                isExpanded: _expandedIds.contains(widget.faqs[i].id),
                onTap: () => _toggleExpanded(widget.faqs[i].id),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A single expandable FAQ item.
class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.faq,
    required this.isExpanded,
    required this.onTap,
  });

  /// The FAQ data to display.
  final FAQ faq;

  /// Whether this item is currently expanded.
  final bool isExpanded;

  /// Callback invoked when the item is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.help_outline,
                    color: AppColors.accent,
                    size: 14,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    faq.question,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    faq.answer,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (faq.category.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      faq.category,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

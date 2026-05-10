import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_shadows.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/faq_model.dart';
import '../../../data/models/support_ticket_model.dart';
import '../../../providers/profile_provider.dart';
import '../widgets/ticket_history_section.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';

/// Help and support screen with FAQ, contact options, and ticket submission.
///
/// Uses Coffee Bean flat design system -- no glass morphism, no gradients.
class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final _issueController = TextEditingController();
  final _subjectController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _issueController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SubtleGradientScaffold.standard(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & Support',
          style: AppTextStyles.headingSmall,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.border,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(supportTicketsProvider);
          ref.invalidate(filteredFAQsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Quick contact options
              _QuickContactSection(
                onWhatsAppTap: _openWhatsApp,
                onEmailTap: _openEmail,
                onCallTap: _openPhone,
              ),
              const SizedBox(height: 24),

              // Raise a ticket
              _RaiseTicketSection(
                subjectController: _subjectController,
                issueController: _issueController,
                selectedCategory: _selectedCategory,
                isSubmitting: _isSubmitting,
                onCategoryChanged: (value) =>
                    setState(() => _selectedCategory = value),
                onSubmit: _submitTicket,
              ),
              const SizedBox(height: 24),

              // Ticket History Section
              const TicketHistorySection(),
              const SizedBox(height: 24),

              // FAQ Section
              const _FAQSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    const phone = '918558873318';
    const message = 'Hi, I need help with AssignX app';
    final url = Uri.parse(
        'https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  Future<void> _openEmail() async {
    final url =
        Uri.parse('mailto:support@assignx.com?subject=Support Request');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open email app')),
        );
      }
    }
  }

  Future<void> _openPhone() async {
    final url = Uri.parse('tel:+918558873318');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _submitTicket() async {
    final subject = _subjectController.text.trim();
    final description = _issueController.text.trim();

    if (_selectedCategory == null || subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final category = _getCategoryFromString(_selectedCategory!);
      final notifier = ref.read(supportTicketNotifierProvider.notifier);
      final ticket = await notifier.createTicket(
        subject: subject,
        description: description,
        category: category,
      );

      if (mounted) {
        setState(() => _isSubmitting = false);

        if (ticket != null) {
          _issueController.clear();
          _subjectController.clear();
          setState(() => _selectedCategory = null);

          ref.invalidate(supportTicketsProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Ticket ${ticket.displayId} submitted!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to submit ticket. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  TicketCategory _getCategoryFromString(String category) {
    switch (category) {
      case 'Payment Issue':
        return TicketCategory.paymentIssue;
      case 'Project Related':
        return TicketCategory.projectRelated;
      case 'Technical Problem':
        return TicketCategory.technicalProblem;
      case 'Account Issue':
        return TicketCategory.accountIssue;
      case 'Refund Request':
        return TicketCategory.refundRequest;
      default:
        return TicketCategory.other;
    }
  }
}

/// Quick contact section with flat design contact cards.
class _QuickContactSection extends StatelessWidget {
  final VoidCallback onWhatsAppTap;
  final VoidCallback onEmailTap;
  final VoidCallback onCallTap;

  const _QuickContactSection({
    required this.onWhatsAppTap,
    required this.onEmailTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact horizontal contact buttons
        Row(
          children: [
            Expanded(
              child: _CompactContactButton(
                icon: Icons.message_outlined,
                iconColor: const Color(0xFF25D366),
                label: 'WhatsApp',
                onTap: onWhatsAppTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CompactContactButton(
                icon: Icons.email_outlined,
                iconColor: AppColors.primary,
                label: 'Email',
                onTap: onEmailTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CompactContactButton(
                icon: Icons.phone_outlined,
                iconColor: AppColors.success,
                label: 'Call',
                onTap: onCallTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact contact button for horizontal row layout.
class _CompactContactButton extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _CompactContactButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Raise a ticket section with flat card design.
class _RaiseTicketSection extends StatelessWidget {
  final TextEditingController subjectController;
  final TextEditingController issueController;
  final String? selectedCategory;
  final bool isSubmitting;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onSubmit;

  const _RaiseTicketSection({
    required this.subjectController,
    required this.issueController,
    required this.selectedCategory,
    required this.isSubmitting,
    required this.onCategoryChanged,
    required this.onSubmit,
  });

  static const _categories = [
    'Payment Issue',
    'Project Related',
    'Technical Problem',
    'Account Issue',
    'Refund Request',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Support Ticket',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'We\'ll get back to you within 24 hours',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Category dropdown
          DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Issue Category',
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.category_outlined,
                color: AppColors.textTertiary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
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
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            items: _categories
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 16),

          // Subject field
          TextFormField(
            controller: subjectController,
            maxLines: 1,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Subject',
              hintText: 'Brief summary of your issue',
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              prefixIcon: Icon(
                Icons.subject,
                color: AppColors.textTertiary,
                size: 20,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
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
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Issue description
          TextFormField(
            controller: issueController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Describe your issue',
              hintText: 'Provide as much detail as possible...',
              alignLabelWithHint: true,
              labelStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              hintStyle: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
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
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Submit button - solid primary, no gradient
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withAlpha(120),
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Submit Ticket',
                      style: AppTextStyles.buttonMedium,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FAQ Section with expandable accordion items and flat design.
class _FAQSection extends ConsumerStatefulWidget {
  const _FAQSection();

  @override
  ConsumerState<_FAQSection> createState() => _FAQSectionState();
}

class _FAQSectionState extends ConsumerState<_FAQSection> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(faqFilterProvider);
    final faqsAsync = ref.watch(filteredFAQsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequently Asked Questions',
              style: AppTextStyles.headingSmall,
            ),
            if (filterState.selectedCategory != null ||
                filterState.searchQuery.isNotEmpty)
              TextButton(
                onPressed: () {
                  ref.read(faqFilterProvider.notifier).clearFilters();
                  _searchController.clear();
                },
                child: Text(
                  'Clear',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Search bar
        _FAQSearchBar(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (query) {
            ref.read(faqFilterProvider.notifier).setSearchQuery(query);
          },
        ),
        const SizedBox(height: 12),

        // Category filter chips
        _FAQCategoryChips(
          selectedCategory: filterState.selectedCategory,
          onCategorySelected: (category) {
            ref.read(faqFilterProvider.notifier).setCategory(category);
          },
        ),
        const SizedBox(height: 16),

        // FAQ list
        faqsAsync.when(
          data: (faqs) {
            if (faqs.isEmpty) {
              return _FAQEmptyState(
                hasFilters: filterState.selectedCategory != null ||
                    filterState.searchQuery.isNotEmpty,
                onClearFilters: () {
                  ref.read(faqFilterProvider.notifier).clearFilters();
                  _searchController.clear();
                },
              );
            }
            return _FAQList(faqs: faqs);
          },
          loading: () => const _FAQLoadingSkeleton(),
          error: (error, _) => _FAQErrorState(
            error: error.toString(),
            onRetry: () {
              ref.invalidate(filteredFAQsProvider);
            },
          ),
        ),
      ],
    );
  }
}

/// Search bar for FAQs with flat styling.
class _FAQSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _FAQSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: 'Search FAQs...',
        hintStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textTertiary,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                  focusNode.unfocus();
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

/// Category filter chips for FAQ filtering.
class _FAQCategoryChips extends StatelessWidget {
  final FAQCategory? selectedCategory;
  final ValueChanged<FAQCategory?> onCategorySelected;

  const _FAQCategoryChips({
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CategoryChip(
            label: 'All',
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: 8),
          ...FAQCategory.values.map((category) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _CategoryChip(
                  label: category.label,
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                ),
              )),
        ],
      ),
    );
  }
}

/// Individual category chip with flat design.
class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color:
                isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// FAQ list rendered inside a single white card with dividers.
class _FAQList extends StatelessWidget {
  final List<FAQ> faqs;

  const _FAQList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < faqs.length; i++) ...[
            _FAQItem(faq: faqs[i]),
            if (i < faqs.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }
}

/// Individual FAQ item with animated expand/collapse.
class _FAQItem extends StatefulWidget {
  final FAQ faq;

  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Question header
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.faq.question,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.faq.category.label,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: _isExpanded ? 0.5 : 0,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Animated answer
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.faq.answer,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Loading skeleton for FAQ section.
class _FAQLoadingSkeleton extends StatelessWidget {
  const _FAQLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(
          4,
          (index) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 16,
                      width: 200,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 20,
                      width: 60,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerBase,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              if (index < 3)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.border,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state when no FAQs match the search/filter.
class _FAQEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _FAQEmptyState({
    required this.hasFilters,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No FAQs match your search' : 'No FAQs available',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: onClearFilters,
              child: Text(
                'Clear filters',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state when FAQs fail to load.
class _FAQErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _FAQErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load FAQs',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

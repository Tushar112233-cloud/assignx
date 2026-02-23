import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/faq_model.dart';
import '../../../data/models/support_ticket_model.dart';
import '../../../providers/profile_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/subtle_gradient_scaffold.dart';
import '../widgets/ticket_history_section.dart';

/// Help and support screen with FAQ, contact options, and ticket submission.
///
/// Features:
/// - Gradient background
/// - Glass morphism cards
/// - Quick contact options
/// - Raise support ticket
/// - FAQ with search and filters
/// - Ticket history
/// - Pull to refresh
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
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
            _buildAppBar(),

            // Content
            Expanded(
              child: RefreshIndicator(
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
                        onCategoryChanged: (value) => setState(() => _selectedCategory = value),
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
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the custom app bar.
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Help & Support',
            style: AppTextStyles.headingSmall,
          ),
        ],
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    const phone = '919876543210';
    const message = 'Hi, I need help with AssignX app';
    final url = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

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
    final url = Uri.parse('mailto:support@assignx.com?subject=Support Request');

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
    final url = Uri.parse('tel:+919876543210');

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

/// Quick contact section with glass morphism.
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
        Text(
          'Quick Contact',
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ContactOption(
                icon: Icons.message,
                label: 'WhatsApp',
                gradient: const LinearGradient(
                  colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                ),
                onTap: onWhatsAppTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactOption(
                icon: Icons.email_outlined,
                label: 'Email',
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withAlpha(200)],
                ),
                onTap: onEmailTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ContactOption(
                icon: Icons.phone_outlined,
                label: 'Call',
                gradient: LinearGradient(
                  colors: [AppColors.success, AppColors.success.withAlpha(200)],
                ),
                onTap: onCallTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Contact option button with gradient.
class _ContactOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ContactOption({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Raise a ticket section with glass morphism.
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
    return GlassCard(
      blur: 10,
      opacity: 0.9,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(40),
                      AppColors.primary.withAlpha(20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Raise a Ticket',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category dropdown
          DropdownButtonFormField<String>(
            initialValue: selectedCategory,
            decoration: InputDecoration(
              labelText: 'Issue Category',
              prefixIcon: Icon(Icons.category_outlined, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white.withAlpha(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
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
              prefixIcon: Icon(Icons.subject, color: AppColors.primary),
              filled: true,
              fillColor: Colors.white.withAlpha(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
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
              filled: true,
              fillColor: Colors.white.withAlpha(15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Submit button
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withAlpha(200),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    : const Text('Submit Ticket'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// FAQ Section (keeping existing implementation for brevity, but with glass styling).
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
              style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            if (filterState.selectedCategory != null || filterState.searchQuery.isNotEmpty)
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

        // Search bar (keeping existing implementation)
        _FAQSearchBar(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: (query) {
            ref.read(faqFilterProvider.notifier).setSearchQuery(query);
          },
        ),
        const SizedBox(height: 12),

        // Category filter chips (keeping existing implementation)
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

// Keep existing FAQ helper widgets (_FAQSearchBar, _FAQCategoryChips, _CategoryChip, etc.)
// but update _FAQItem to use GlassCard:

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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
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
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _FAQList extends StatelessWidget {
  final List<FAQ> faqs;

  const _FAQList({required this.faqs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: faqs.map((faq) => _FAQItem(faq: faq)).toList(),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final FAQ faq;

  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> with SingleTickerProviderStateMixin {
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GlassCard(
        blur: 8,
        opacity: 0.9,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(12),
        elevation: 1,
        child: Column(
          children: [
            // Question header
            InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.circular(12),
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
                            style: AppTextStyles.labelMedium,
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
        ),
      ),
    );
  }
}

class _FAQLoadingSkeleton extends StatelessWidget {
  const _FAQLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
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
      ),
    );
  }
}

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Support screen for the Dolancer App.
///
/// Provides a comprehensive help and support interface including
/// quick help cards, a contact form, contact information, and FAQs.
///
/// ## Sections
/// 1. **Quick Help**: 4 cards for common help topics
/// 2. **Contact Support**: Form for submitting support tickets
/// 3. **Contact Information**: Email, response time, availability
/// 4. **FAQ**: Expandable FAQ items from the database
///
/// ## State Management
/// Uses [SupportProvider] for FAQ loading and ticket submission.
///
/// See also:
/// - [SupportProvider] for support state
/// - [ContactForm] for the ticket submission form
/// - [FaqList] for the FAQ section
/// - [QuickHelpCard] for help topic cards
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/support_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../dashboard/widgets/app_header.dart';
import '../widgets/quick_help_card.dart';
import '../widgets/contact_form.dart';
import '../widgets/faq_list.dart';
import '../../../core/translation/translation_extensions.dart';

/// The main support screen widget.
///
/// Displays help resources, a contact form, and FAQs in a
/// scrollable layout with animated entrance.
class SupportScreen extends ConsumerWidget {
  /// Creates a support screen.
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportState = ref.watch(supportProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        colors: MeshColors.defaultColors,
        opacity: 0.5,
        child: Column(
          children: [
            InnerHeader(
              title: 'Help & Support',
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ref.read(supportProvider.notifier).refresh(),
                color: AppColors.accent,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: AppSpacing.paddingMd,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero section in glass container
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: _buildHeroSection(context),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.1, end: 0, duration: 400.ms),

                      const SizedBox(height: AppSpacing.lg),

                      // Quick help section
                      Text(
                        'Quick Help'.tr(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildQuickHelpGrid()
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 100.ms)
                          .slideY(begin: 0.05, end: 0, duration: 400.ms),

                      const SizedBox(height: AppSpacing.lg),

                      // Contact form section
                      ContactForm(
                      onSubmitted: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Support ticket submitted successfully! We\'ll get back to you within 24 hours.'.tr(context),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusSm,
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                    )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.05, end: 0, duration: 400.ms),

                    const SizedBox(height: AppSpacing.lg),

                      // Contact information in glass container
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: _buildContactInfoContent(context),
                      )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: 300.ms)
                          .slideY(begin: 0.05, end: 0, duration: 400.ms),

                      const SizedBox(height: AppSpacing.lg),

                      // FAQ section
                      Text(
                        'Frequently Asked Questions'.tr(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (supportState.isLoadingFaqs)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          ),
                        )
                      else
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: FaqList(faqs: supportState.faqs),
                        )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms)
                            .slideY(begin: 0.05, end: 0, duration: 400.ms),

                      const SizedBox(height: AppSpacing.xl),
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

  /// Builds the hero banner section with gradient background.
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5A7CFF), Color(0xFF49C5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppSpacing.borderRadiusMd,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A7CFF).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppSpacing.borderRadiusSm,
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'How can we help?'.tr(context),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Browse our help topics below or submit a support ticket and our team will get back to you.'.tr(context),
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a 2x2 grid of quick help cards.
  Widget _buildQuickHelpGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.3,
      children: const [
        QuickHelpCard(
          icon: Icons.task_alt,
          title: 'Accepting Tasks',
          description: 'How to find and accept assignments',
          color: Color(0xFF5A7CFF),
        ),
        QuickHelpCard(
          icon: Icons.upload_file,
          title: 'Submit Work',
          description: 'Guide to submitting deliverables',
          color: Color(0xFF22C55E),
        ),
        QuickHelpCard(
          icon: Icons.account_balance_wallet,
          title: 'Payments',
          description: 'Payment processing and history',
          color: Color(0xFFF59E0B),
        ),
        QuickHelpCard(
          icon: Icons.menu_book,
          title: 'Resources',
          description: 'Tools and learning materials',
          color: Color(0xFF8B5CF6),
        ),
      ],
    );
  }

  /// Builds the contact information content (without outer container).
  Widget _buildContactInfoContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Contact Information'.tr(context),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildContactRow(
          Icons.email_outlined,
          'Email',
          'support@assignx.com',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildContactRow(
          Icons.schedule,
          'Response Time',
          'Within 24 hours',
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildContactRow(
          Icons.access_time,
          'Availability',
          'Mon - Sat, 9:00 AM - 6:00 PM IST',
        ),
      ],
    );
  }

  /// Builds a single contact information row.
  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textTertiary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/business_hub_post_model.dart';
import '../providers/business_hub_provider.dart';

/// Colors for firm avatar placeholders.
const List<Color> _avatarColors = [
  Color(0xFF765341),
  Color(0xFF2563EB),
  Color(0xFF059669),
  Color(0xFF7C3AED),
  Color(0xFFDB2777),
  Color(0xFFD97706),
  Color(0xFF0891B2),
  Color(0xFF4F46E5),
];

Color _colorForFirm(String firm) {
  if (firm.isEmpty) return _avatarColors[0];
  return _avatarColors[firm.codeUnitAt(0) % _avatarColors.length];
}

/// Detailed view for an Investor.
class BusinessPostDetailScreen extends ConsumerWidget {
  final String postId;

  const BusinessPostDetailScreen({
    super.key,
    required this.postId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final investorAsync = ref.watch(investorDetailProvider(postId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: investorAsync.when(
        data: (investor) {
          if (investor == null) return _buildNotFound(context);
          return _InvestorDetailBody(investor: investor);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(context, ref, e.toString()),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off,
                  size: 80, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text('Investor not found',
                  style: AppTextStyles.headingMedium),
              const SizedBox(height: 8),
              Text(
                'This investor profile may have been removed',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, String error) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load', style: AppTextStyles.headingSmall),
              const SizedBox(height: 8),
              Text(
                error,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () =>
                    ref.invalidate(investorDetailProvider(postId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Main scrollable body for investor detail.
class _InvestorDetailBody extends StatelessWidget {
  final Investor investor;

  const _InvestorDetailBody({required this.investor});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _colorForFirm(investor.firm);

    return CustomScrollView(
      slivers: [
        // App bar
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          title: Text(
            investor.firm,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                _HeaderCard(investor: investor, avatarColor: avatarColor),
                const SizedBox(height: 20),

                // Description
                if (investor.description != null &&
                    investor.description!.isNotEmpty) ...[
                  _SectionCard(
                    title: 'About',
                    icon: Icons.info_outline,
                    child: Text(
                      investor.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Funding stages
                if (investor.fundingStages.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Funding Stages',
                    icon: Icons.rocket_launch_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: investor.fundingStages.map((stage) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(stage.icon,
                                  size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                stage.label,
                                style: AppTextStyles.labelMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Sectors
                if (investor.sectors.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Sectors',
                    icon: Icons.category_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: investor.sectors.map((sector) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border.withAlpha(77),
                            ),
                          ),
                          child: Text(
                            sector,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Ticket size
                if (investor.ticketSize != null) ...[
                  _SectionCard(
                    title: 'Ticket Size',
                    icon: Icons.account_balance_wallet_outlined,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withAlpha(10),
                            AppColors.primaryLight.withAlpha(8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: AppColors.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            investor.ticketSize!.formatted,
                            style: AppTextStyles.headingSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Portfolio companies
                if (investor.portfolioCompanies.isNotEmpty) ...[
                  _SectionCard(
                    title:
                        'Portfolio (${investor.portfolioCompanies.length})',
                    icon: Icons.business_outlined,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          investor.portfolioCompanies.map((company) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.border.withAlpha(77),
                            ),
                          ),
                          child: Text(
                            company,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Location
                if (investor.location != null &&
                    investor.location!.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Location',
                    icon: Icons.location_on_outlined,
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          investor.location!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Contact buttons
                if (investor.contactEmail != null ||
                    investor.linkedinUrl != null ||
                    investor.websiteUrl != null) ...[
                  Text(
                    'Get in Touch',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (investor.contactEmail != null)
                    _ContactButton(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      subtitle: investor.contactEmail!,
                      color: const Color(0xFFDB2777),
                      onTap: () =>
                          _launchEmail(investor.contactEmail!),
                    ),
                  if (investor.linkedinUrl != null) ...[
                    const SizedBox(height: 8),
                    _ContactButton(
                      icon: Icons.link,
                      label: 'LinkedIn',
                      subtitle: 'View profile',
                      color: const Color(0xFF0077B5),
                      onTap: () =>
                          _launchUrl(investor.linkedinUrl!),
                    ),
                  ],
                  if (investor.websiteUrl != null) ...[
                    const SizedBox(height: 8),
                    _ContactButton(
                      icon: Icons.language,
                      label: 'Website',
                      subtitle: investor.websiteUrl!,
                      color: const Color(0xFF059669),
                      onTap: () =>
                          _launchUrl(investor.websiteUrl!),
                    ),
                  ],
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Header card with firm logo, name, and investor name.
class _HeaderCard extends StatelessWidget {
  final Investor investor;
  final Color avatarColor;

  const _HeaderCard({
    required this.investor,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Firm avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: avatarColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                investor.firmInitial,
                style: AppTextStyles.headingLarge.copyWith(
                  color: avatarColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            investor.firm,
            style: AppTextStyles.headingMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            investor.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (investor.location != null &&
              investor.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(
                  investor.location!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Reusable section card for detail groups.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Contact action button.
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border.withAlpha(77),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

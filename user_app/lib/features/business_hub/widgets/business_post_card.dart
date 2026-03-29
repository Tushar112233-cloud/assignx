library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/models/business_hub_post_model.dart';

/// Colors for firm avatar placeholders based on first letter hash.
const List<Color> _avatarColors = [
  Color(0xFF765341), // primary
  Color(0xFF2563EB), // blue
  Color(0xFF059669), // emerald
  Color(0xFF7C3AED), // violet
  Color(0xFFDB2777), // pink
  Color(0xFFD97706), // amber
  Color(0xFF0891B2), // cyan
  Color(0xFF4F46E5), // indigo
];

/// Get a deterministic color for an investor's firm.
Color _colorForFirm(String firm) {
  if (firm.isEmpty) return _avatarColors[0];
  return _avatarColors[firm.codeUnitAt(0) % _avatarColors.length];
}

/// Investor card widget for the Business Hub list.
class InvestorCard extends StatelessWidget {
  final Investor investor;
  final VoidCallback? onTap;

  const InvestorCard({
    super.key,
    required this.investor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarColor = _colorForFirm(investor.firm);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Ink(
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: logo + firm + name
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: avatarColor.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          investor.firmInitial,
                          style: AppTextStyles.headingSmall.copyWith(
                            color: avatarColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            investor.firm,
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            investor.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Funding stage badges
                if (investor.fundingStages.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: investor.fundingStages.map((stage) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          stage.label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                if (investor.fundingStages.isNotEmpty)
                  const SizedBox(height: 10),

                // Sectors
                if (investor.sectors.isNotEmpty)
                  Text(
                    investor.sectors.join(' \u2022 '),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                if (investor.sectors.isNotEmpty) const SizedBox(height: 10),

                // Bottom row: ticket size + portfolio count
                Row(
                  children: [
                    if (investor.ticketSize != null) ...[
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          investor.ticketSize!.formatted,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (investor.portfolioCompanies.isNotEmpty) ...[
                      Icon(
                        Icons.business_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${investor.portfolioCompanies.length} portfolio',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),

                // Location
                if (investor.location != null &&
                    investor.location!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          investor.location!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

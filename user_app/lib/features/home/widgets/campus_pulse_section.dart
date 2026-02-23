import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Campus Pulse teaser section showing marketplace items.
class CampusPulseSection extends StatelessWidget {
  const CampusPulseSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock items for now - will be replaced with real data
    final items = _mockItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Campus Pulse',
                    style: AppTextStyles.headingSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Trending near you',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.push('/marketplace'),
                child: const Text('View All'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Horizontal list
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _PulseCard(item: items[index]);
            },
          ),
        ),
      ],
    );
  }

  static final _mockItems = [
    _PulseItem(
      id: '1',
      title: 'Engineering Textbooks',
      price: '\u20B9450',
      distance: '800m',
      imageColor: AppColors.primary,
    ),
    _PulseItem(
      id: '2',
      title: 'Scientific Calculator',
      price: '\u20B9800',
      distance: '1.2km',
      imageColor: AppColors.success,
    ),
    _PulseItem(
      id: '3',
      title: 'Room Available',
      price: '\u20B95,000/mo',
      distance: '500m',
      imageColor: AppColors.warning,
    ),
    _PulseItem(
      id: '4',
      title: 'Internship Opening',
      price: 'Paid',
      distance: 'Remote',
      imageColor: const Color(0xFF7C3AED),
    ),
  ];
}

class _PulseItem {
  final String id;
  final String title;
  final String price;
  final String distance;
  final Color imageColor;

  const _PulseItem({
    required this.id,
    required this.title,
    required this.price,
    required this.distance,
    required this.imageColor,
  });
}

class _PulseCard extends StatelessWidget {
  final _PulseItem item;

  const _PulseCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Navigate to marketplace since these are mock items without real database IDs
      onTap: () => context.push('/marketplace'),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: item.imageColor.withAlpha(50),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 40,
                  color: item.imageColor,
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.labelMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.price,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          item.distance,
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

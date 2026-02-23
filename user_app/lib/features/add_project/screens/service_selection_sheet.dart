import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

/// Service type for project creation.
enum ServiceType {
  newProject(
    'New Project',
    'Full project work from scratch',
    Icons.create_new_folder_outlined,
    'Starting from ₹499',
    '/add-project/new',
  ),
  proofreading(
    'Proofreading',
    'Get your document proofread & edited',
    Icons.spellcheck,
    'Starting from ₹199',
    '/add-project/proofread',
  ),
  plagReport(
    'Plag/AI Report',
    'Check plagiarism & AI detection',
    Icons.document_scanner_outlined,
    'Starting from ₹99',
    '/add-project/report',
  ),
  expertOpinion(
    'Ask Expert',
    'Get expert opinion on your work',
    Icons.psychology_outlined,
    'Starting from ₹299',
    '/add-project/expert',
  );

  final String title;
  final String description;
  final IconData icon;
  final String priceHint;
  final String route;

  const ServiceType(
    this.title,
    this.description,
    this.icon,
    this.priceHint,
    this.route,
  );
}

/// Bottom sheet for selecting project service type.
class ServiceSelectionSheet extends StatelessWidget {
  const ServiceSelectionSheet({super.key});

  /// Show the service selection bottom sheet.
  static Future<ServiceType?> show(BuildContext context) {
    return showModalBottomSheet<ServiceType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ServiceSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New',
                            style: AppTextStyles.headingSmall,
                          ),
                          Text(
                            'What would you like help with?',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Service options
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: ServiceType.values.map((service) {
                return _ServiceOption(
                  service: service,
                  onTap: () {
                    Navigator.of(context).pop(service);
                    context.push(service.route);
                  },
                );
              }).toList(),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  final ServiceType service;
  final VoidCallback onTap;

  const _ServiceOption({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getIconColor(service).withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                service.icon,
                color: _getIconColor(service),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: AppTextStyles.labelLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.priceHint,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconColor(ServiceType service) {
    switch (service) {
      case ServiceType.newProject:
        return AppColors.primary;
      case ServiceType.proofreading:
        return Colors.blue;
      case ServiceType.plagReport:
        return Colors.orange;
      case ServiceType.expertOpinion:
        return Colors.purple;
    }
  }
}

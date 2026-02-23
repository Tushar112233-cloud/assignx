import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/deliverable_model.dart';

/// Card widget for displaying a deliverable in QC review.
///
/// Shows file info, version, and approval status.
class QCReviewCard extends StatelessWidget {
  const QCReviewCard({
    super.key,
    required this.deliverable,
    this.onView,
    this.onDownload,
    this.isSelected = false,
  });

  /// Deliverable data
  final DeliverableModel deliverable;

  /// Called when view button is tapped
  final VoidCallback? onView;

  /// Called when download button is tapped
  final VoidCallback? onDownload;

  /// Whether this deliverable is selected
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppColors.primary
              : AppColors.textSecondaryLight.withValues(alpha: 0.1),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // File icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _getFileColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getFileIcon(),
                    color: _getFileColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // File info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deliverable.fileName,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            deliverable.formattedSize,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondaryLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Version ${deliverable.version}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status indicator
                if (deliverable.isApproved != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: deliverable.isApproved!
                          ? AppColors.success.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          deliverable.isApproved!
                              ? Icons.check_circle
                              : Icons.pending,
                          size: 14,
                          color: deliverable.isApproved!
                              ? AppColors.success
                              : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deliverable.isApproved! ? 'Approved' : 'Pending',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: deliverable.isApproved!
                                        ? AppColors.success
                                        : Colors.orange,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            // Uploader info
            if (deliverable.uploaderName != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Uploaded by ${deliverable.uploaderName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(deliverable.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ],
            // Description
            if (deliverable.description != null) ...[
              const SizedBox(height: 8),
              Text(
                deliverable.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Reviewer notes
            if (deliverable.reviewerNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        deliverable.reviewerNotes!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade900,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // Action buttons
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDownload,
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon() {
    if (deliverable.isPdf) return Icons.picture_as_pdf;
    if (deliverable.isImage) return Icons.image;
    if (deliverable.isDocument) return Icons.description;
    return Icons.insert_drive_file;
  }

  Color _getFileColor() {
    if (deliverable.isPdf) return Colors.red;
    if (deliverable.isImage) return Colors.blue;
    if (deliverable.isDocument) return Colors.blue;
    return AppColors.primary;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Compact version of QC review card for lists.
class CompactQCCard extends StatelessWidget {
  const CompactQCCard({
    super.key,
    required this.deliverable,
    required this.onTap,
  });

  final DeliverableModel deliverable;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          deliverable.isPdf
              ? Icons.picture_as_pdf
              : deliverable.isImage
                  ? Icons.image
                  : Icons.description,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        deliverable.fileName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        'v${deliverable.version} • ${deliverable.formattedSize}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
      ),
      trailing: deliverable.isApproved != null
          ? Icon(
              deliverable.isApproved!
                  ? Icons.check_circle
                  : Icons.hourglass_empty,
              color:
                  deliverable.isApproved! ? AppColors.success : Colors.orange,
            )
          : const Icon(Icons.chevron_right),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/project_model.dart';

/// Section displaying project deliverables with download options.
class DeliverablesSection extends StatelessWidget {
  final Project project;
  final VoidCallback? onDownloadAll;

  const DeliverablesSection({
    super.key,
    required this.project,
    this.onDownloadAll,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = project.status == ProjectStatus.delivered ||
        project.status == ProjectStatus.completed ||
        project.status == ProjectStatus.autoApproved;
    final hasDeliverables = project.deliverables.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(
          color: isAvailable && hasDeliverables
              ? AppColors.success.withAlpha(50)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? AppColors.success.withAlpha(20)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_outlined,
                    color: isAvailable ? AppColors.success : AppColors.textTertiary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deliverables',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isAvailable
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasDeliverables
                            ? '${project.deliverables.length} file(s) available'
                            : 'Files will appear here when ready',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDeliverables && isAvailable)
                  TextButton.icon(
                    onPressed: onDownloadAll,
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text('All'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
              ],
            ),
          ),

          // Files list
          if (hasDeliverables && isAvailable) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: project.deliverables
                    .map((file) => _DeliverableItem(file: file))
                    .toList(),
              ),
            ),
          ],

          // Locked state
          if (!isAvailable) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Available when project is ready for review',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliverableItem extends StatelessWidget {
  final ProjectDeliverable file;

  const _DeliverableItem({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getFileColor().withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(),
              color: _getFileColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: AppTextStyles.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (file.formattedSize.isNotEmpty) ...[
                      Text(
                        file.formattedSize,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      _getFileType(),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Download button
          IconButton(
            onPressed: () {
              // Download file
            },
            icon: const Icon(Icons.download_outlined),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon() {
    final mime = file.fileType ?? '';
    final name = file.fileName.toLowerCase();

    if (mime.contains('pdf') || name.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    }
    if (mime.contains('image') || name.endsWith('.png') || name.endsWith('.jpg')) {
      return Icons.image;
    }
    if (mime.contains('word') || name.endsWith('.doc') || name.endsWith('.docx')) {
      return Icons.description;
    }
    if (mime.contains('excel') || name.endsWith('.xls') || name.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    if (mime.contains('zip') || name.endsWith('.zip') || name.endsWith('.rar')) {
      return Icons.folder_zip;
    }

    return Icons.insert_drive_file;
  }

  Color _getFileColor() {
    final mime = file.fileType ?? '';
    final name = file.fileName.toLowerCase();

    if (mime.contains('pdf') || name.endsWith('.pdf')) {
      return const Color(0xFFDC2626); // Red
    }
    if (mime.contains('image')) {
      return const Color(0xFF7C3AED); // Purple
    }
    if (mime.contains('word') || name.endsWith('.doc')) {
      return const Color(0xFF2563EB); // Blue
    }
    if (mime.contains('excel') || name.endsWith('.xls')) {
      return const Color(0xFF059669); // Green
    }
    if (mime.contains('zip')) {
      return const Color(0xFFD97706); // Amber
    }

    return AppColors.textSecondary;
  }

  String _getFileType() {
    final name = file.fileName.toLowerCase();
    if (name.endsWith('.pdf')) return 'PDF';
    if (name.endsWith('.doc') || name.endsWith('.docx')) return 'Word';
    if (name.endsWith('.xls') || name.endsWith('.xlsx')) return 'Excel';
    if (name.endsWith('.png')) return 'PNG';
    if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'JPEG';
    if (name.endsWith('.zip')) return 'ZIP';
    return 'File';
  }
}

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// File upload card widget for CV and documents.
class FileUploadCard extends StatelessWidget {
  const FileUploadCard({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.fileName,
    this.fileSize,
    this.isLoading = false,
    this.isUploaded = false,
    this.onRemove,
    this.acceptedFormats = const ['PDF', 'DOC', 'DOCX'],
    this.maxSizeMB = 5,
  });

  /// Card title
  final String title;

  /// Callback when card is tapped
  final VoidCallback onTap;

  /// Optional subtitle/description
  final String? subtitle;

  /// Uploaded file name
  final String? fileName;

  /// Uploaded file size
  final String? fileSize;

  /// Whether upload is in progress
  final bool isLoading;

  /// Whether a file is uploaded
  final bool isUploaded;

  /// Callback to remove uploaded file
  final VoidCallback? onRemove;

  /// Accepted file formats
  final List<String> acceptedFormats;

  /// Maximum file size in MB
  final int maxSizeMB;

  @override
  Widget build(BuildContext context) {
    if (isUploaded && fileName != null) {
      return _buildUploadedState(context);
    }
    return _buildEmptyState(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.borderLight,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceVariantLight.withValues(alpha: 0.3),
        ),
        child: Column(
          children: [
            if (isLoading)
              const SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '${acceptedFormats.join(', ')} (Max ${maxSizeMB}MB)',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.success,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.success.withValues(alpha: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName ?? 'File uploaded',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (fileSize != null)
                  Text(
                    fileSize!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
              if (onRemove != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onRemove,
                  color: AppColors.textSecondaryLight,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

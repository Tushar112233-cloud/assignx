import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Attachment model for uploaded files.
class AttachmentFile {
  final String name;
  final String path;
  final int size;
  final String? extension;

  const AttachmentFile({
    required this.name,
    required this.path,
    required this.size,
    this.extension,
  });

  /// Format file size to human readable string.
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Get icon based on file type.
  IconData get icon {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get color based on file type.
  Color get color {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }
}

/// File attachment widget with picker and preview.
class FileAttachment extends StatelessWidget {
  final List<AttachmentFile> files;
  final ValueChanged<List<AttachmentFile>> onChanged;
  final int maxFiles;
  final int maxSizeMB;
  final List<String>? allowedExtensions;
  final String? label;
  final String? hint;
  final String? errorText;

  const FileAttachment({
    super.key,
    required this.files,
    required this.onChanged,
    this.maxFiles = 5,
    this.maxSizeMB = 10,
    this.allowedExtensions,
    this.label,
    this.hint,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppTextStyles.labelMedium,
          ),
          const SizedBox(height: 8),
        ],

        // Upload area
        GestureDetector(
          onTap: files.length < maxFiles ? () => _pickFiles(context) : null,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.border,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: files.length < maxFiles
                      ? AppColors.primary
                      : AppColors.textTertiary,
                ),
                const SizedBox(height: 12),
                Text(
                  files.length < maxFiles
                      ? 'Tap to upload files'
                      : 'Maximum files reached',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: files.length < maxFiles
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hint ?? 'Max ${maxSizeMB}MB per file • ${files.length}/$maxFiles files',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Error text
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error,
            ),
          ),
        ],

        // File list
        if (files.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...files.map((file) => _FileItem(
                file: file,
                onRemove: () => _removeFile(file),
              )),
        ],
      ],
    );
  }

  Future<void> _pickFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result == null) return;

      final newFiles = <AttachmentFile>[];

      for (final platformFile in result.files) {
        // Check file size
        if (platformFile.size > maxSizeMB * 1024 * 1024) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${platformFile.name} exceeds ${maxSizeMB}MB limit'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          continue;
        }

        // Check max files
        if (files.length + newFiles.length >= maxFiles) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Maximum $maxFiles files allowed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          break;
        }

        newFiles.add(AttachmentFile(
          name: platformFile.name,
          path: platformFile.path ?? '',
          size: platformFile.size,
          extension: platformFile.extension,
        ));
      }

      if (newFiles.isNotEmpty) {
        onChanged([...files, ...newFiles]);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking files: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeFile(AttachmentFile file) {
    onChanged(files.where((f) => f.path != file.path).toList());
  }
}

class _FileItem extends StatelessWidget {
  final AttachmentFile file;
  final VoidCallback onRemove;

  const _FileItem({
    required this.file,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: file.color.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              file.icon,
              size: 20,
              color: file.color,
            ),
          ),
          const SizedBox(width: 12),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  file.formattedSize,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textTertiary,
            onPressed: onRemove,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}

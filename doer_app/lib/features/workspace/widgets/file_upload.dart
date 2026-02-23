/// File upload widgets for workspace file management.
///
/// This file provides widgets for uploading and managing work files
/// in the workspace, including upload areas, file lists, and file items.
///
/// ## Widgets
/// - [FileUploadArea] - Tappable upload zone with drag-drop styling
/// - [FileList] - List of uploaded files with actions
/// - [FileListItem] - Individual file display with remove/primary actions
///
/// ## Features
/// - Visual upload area with icon and supported formats
/// - File type icons with color coding (PDF=red, DOC=blue, etc.)
/// - Primary file designation for main submission
/// - File size and upload time display
/// - Remove and set-primary actions
///
/// ## File Types
/// Supported formats with color coding:
/// - **PDF** (red): Document files
/// - **DOC/DOCX** (blue): Word documents
/// - **XLS/XLSX** (green): Spreadsheets
/// - **PPT/PPTX** (yellow): Presentations
/// - **ZIP/RAR** (accent): Archives
///
/// ## Example
/// ```dart
/// // Upload area
/// FileUploadArea(
///   onTap: _showFilePicker,
///   isUploading: isUploading,
/// )
///
/// // File list with actions
/// FileList(
///   files: workspaceState.files,
///   onRemove: (id) => workspace.removeFile(id),
///   onSetPrimary: (id) => workspace.setPrimaryFile(id),
/// )
/// ```
///
/// See also:
/// - [WorkspaceScreen] for usage context
/// - [WorkspaceProvider] for file state management
/// - [DeliverableModel] model for file data structure
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/deliverable_model.dart';

/// Tappable file upload area widget.
///
/// Displays a prominent upload zone with cloud icon, instructions,
/// and supported file format information. Shows loading state during upload.
///
/// ## Props
/// - [onTap]: Callback when area is tapped (opens file picker)
/// - [isUploading]: Shows loading indicator when true
class FileUploadArea extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isUploading;

  const FileUploadArea({
    super.key,
    this.onTap,
    this.isUploading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(
            color: AppColors.border,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading)
              const CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              )
            else
              Container(
                padding: AppSpacing.paddingMd,
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
            const SizedBox(height: AppSpacing.md),
            Text(
              isUploading ? 'Uploading...' : 'Tap to upload files',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PDF, DOC, DOCX, ZIP (max 25MB)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget displaying a list of uploaded files.
///
/// Shows all uploaded files with actions for removal and setting
/// the primary submission file. Displays empty state when no files.
///
/// ## Props
/// - [files]: List of [DeliverableModel] objects to display
/// - [onRemove]: Callback when remove button is pressed
/// - [onSetPrimary]: Callback to mark file as primary submission
/// - [editable]: Enable/disable action buttons
class FileList extends StatelessWidget {
  final List<DeliverableModel> files;
  final ValueChanged<String>? onRemove;
  final ValueChanged<String>? onSetPrimary;
  final bool editable;

  const FileList({
    super.key,
    required this.files,
    this.onRemove,
    this.onSetPrimary,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (files.isEmpty) {
      return Container(
        padding: AppSpacing.paddingMd,
        decoration: const BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 20,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: 8),
            Text(
              'No files uploaded yet',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: files.map((file) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: FileListItem(
            file: file,
            onRemove: editable && onRemove != null
                ? () => onRemove!(file.id)
                : null,
            onSetPrimary: editable && onSetPrimary != null
                ? () => onSetPrimary!(file.id)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

/// Individual file item with icon, details, and actions.
///
/// Displays file information including name, size, upload time,
/// and extension-based icon. Primary files show a badge and border.
///
/// ## Visual Elements
/// - Extension-based colored icon
/// - File name with truncation
/// - Size and relative time display
/// - "PRIMARY" badge for main submission file
/// - Star button to set as primary
/// - Remove button for deletion
///
/// ## Props
/// - [file]: The [DeliverableModel] to display
/// - [onRemove]: Remove button callback
/// - [onSetPrimary]: Set-as-primary callback
/// - [onTap]: Optional tap handler for file preview
class FileListItem extends StatelessWidget {
  final DeliverableModel file;
  final VoidCallback? onRemove;
  final VoidCallback? onSetPrimary;
  final VoidCallback? onTap;

  const FileListItem({
    super.key,
    required this.file,
    this.onRemove,
    this.onSetPrimary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
        side: file.isFinal
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: AppSpacing.paddingSm,
          child: Row(
            children: [
              // File icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getFileColor(file.extension).withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: Center(
                  child: Text(
                    file.extension.length > 4
                        ? file.extension.substring(0, 4)
                        : file.extension,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getFileColor(file.extension),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            file.fileName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (file.isFinal)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRIMARY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${file.formattedSize} • ${_formatTime(file.createdAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              if (onSetPrimary != null && !file.isFinal)
                IconButton(
                  onPressed: onSetPrimary,
                  icon: const Icon(Icons.star_border),
                  iconSize: 20,
                  color: AppColors.textSecondary,
                  tooltip: 'Set as primary',
                ),
              if (onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                  color: AppColors.error,
                  tooltip: 'Remove',
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getFileColor(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return AppColors.error;
      case 'doc':
      case 'docx':
        return AppColors.info;
      case 'xls':
      case 'xlsx':
        return AppColors.success;
      case 'ppt':
      case 'pptx':
        return AppColors.warning;
      case 'zip':
      case 'rar':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }
}

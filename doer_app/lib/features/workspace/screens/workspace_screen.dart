/// Main workspace screen for working on projects.
///
/// This screen provides the primary interface for doers to work on
/// their assigned projects, including file management, progress tracking,
/// and session timing.
///
/// ## Features
/// - Work session timer with start/stop controls
/// - Deadline countdown with urgency coloring
/// - Collapsible project info card
/// - Progress slider for manual progress updates
/// - File upload and management section
/// - Submit button for final submission
///
/// ## Navigation
/// - Entry: From [ProjectDetailScreen] via "Open Workspace" button
/// - Chat: Opens [ChatScreen] for project communication
/// - Details: Returns to [ProjectDetailScreen]
/// - Submit: Opens [SubmitWorkScreen] for final submission
///
/// ## State Dependencies
/// - [workspaceProvider]: Manages workspace data and actions
///
/// ## Example Route
/// ```dart
/// context.push('/project/$projectId/workspace');
/// ```
///
/// See also:
/// - [WorkspaceNotifier] for state management
/// - [ProgressTracker] for progress tracking widget
/// - [FileUploadArea] for file upload interface
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/workspace_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../dashboard/widgets/deadline_countdown.dart';
import '../widgets/file_upload.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/project_info_card.dart';

/// Main workspace screen for working on projects.
///
/// Provides the primary work interface with session timing, file upload,
/// progress tracking, and submission controls.
class WorkspaceScreen extends ConsumerStatefulWidget {
  final String projectId;

  const WorkspaceScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends ConsumerState<WorkspaceScreen> {
  bool _showProjectInfo = false;

  @override
  Widget build(BuildContext context) {
    final workspaceNotifier = ref.watch(workspaceProvider(widget.projectId));
    final workspaceState = workspaceNotifier.state;
    final project = workspaceState.project;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: LoadingOverlay(
        isLoading: workspaceState.isLoading,
        child: Column(
          children: [
            // Header
            _buildHeader(context, project),

            // Content
            Expanded(
              child: project == null
                  ? const Center(child: Text('Project not found'))
                  : SingleChildScrollView(
                      padding: AppSpacing.paddingMd,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Timer and deadline
                          Row(
                            children: [
                              Expanded(
                                child: WorkSessionTimer(
                                  totalTime: workspaceState.totalTimeSpent,
                                  isActive: workspaceState.isWorking,
                                  onStart: () => ref
                                      .read(workspaceProvider(widget.projectId))
                                      .startSession(),
                                  onStop: () => ref
                                      .read(workspaceProvider(widget.projectId))
                                      .endSession(),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: AppSpacing.md),

                          // Deadline timer
                          Card(
                            elevation: 2,
                            shape: const RoundedRectangleBorder(
                              borderRadius: AppSpacing.borderRadiusMd,
                            ),
                            child: Padding(
                              padding: AppSpacing.paddingMd,
                              child: LargeDeadlineTimer(
                                deadline: project.deadline,
                              ),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Project info (collapsible)
                          if (_showProjectInfo)
                            ProjectInfoCard(
                              project: project,
                              expanded: true,
                              onToggleExpand: () => setState(() {
                                _showProjectInfo = false;
                              }),
                            )
                          else
                            InkWell(
                              onTap: () => setState(() {
                                _showProjectInfo = true;
                              }),
                              borderRadius: AppSpacing.borderRadiusMd,
                              child: Container(
                                padding: AppSpacing.paddingMd,
                                decoration: const BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: AppSpacing.borderRadiusMd,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Show Project Details',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: AppSpacing.lg),

                          // Progress tracker
                          ProgressTracker(
                            progress: workspaceState.progress / 100.0,
                            onChanged: (value) => ref
                                .read(workspaceProvider(widget.projectId))
                                .updateProgress((value * 100).round()),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Files section
                          _buildFilesSection(workspaceState),

                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
            ),

            // Bottom action bar
            if (project != null)
              _buildBottomBar(context, workspaceState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, project) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: AppColors.textPrimary,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Workspace',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (project != null)
                    Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: () =>
                  context.push('/project/${widget.projectId}/chat'),
              icon: const Icon(Icons.chat_outlined),
              color: AppColors.textSecondary,
              tooltip: 'Chat',
            ),
            IconButton(
              onPressed: () => context.push('/project/${widget.projectId}'),
              icon: const Icon(Icons.info_outline),
              color: AppColors.textSecondary,
              tooltip: 'Project Details',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilesSection(WorkspaceState workspaceState) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Work Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // File upload area
            FileUploadArea(
              onTap: _showFilePickerDialog,
            ),

            const SizedBox(height: AppSpacing.md),

            // File list
            FileList(
              files: workspaceState.deliverables,
              onRemove: (fileId) => ref
                  .read(workspaceProvider(widget.projectId))
                  .removeFile(fileId),
              onSetPrimary: (fileId) => ref
                  .read(workspaceProvider(widget.projectId))
                  .setPrimaryFile(fileId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, WorkspaceState workspaceState) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.trending_up,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${(workspaceState.progress * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Submit button
            Expanded(
              child: AppButton(
                text: 'Submit Work',
                onPressed: workspaceState.canSubmit
                    ? () => context.push('/project/${widget.projectId}/submit')
                    : null,
                icon: Icons.send,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilePickerDialog() {
    // Mock file picker - in production, use file_picker package
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Upload File',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.file_present,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Choose from Files'),
              subtitle: const Text('PDF, DOC, DOCX, ZIP'),
              onTap: () {
                Navigator.pop(context);
                _mockAddFile();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_outlined,
                  color: AppColors.info,
                ),
              ),
              title: const Text('Import from Cloud'),
              subtitle: const Text('Google Drive, Dropbox'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cloud import coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  void _mockAddFile() async {
    // Mock adding a file - in production, use file_picker package
    final fileName = 'document_${DateTime.now().second}.docx';
    final fileSize = 125000 + (DateTime.now().millisecond * 100);

    final success = await ref.read(workspaceProvider(widget.projectId)).addFile(
          filePath: '/mock/path/$fileName', // Mock path
          fileName: fileName,
          fileType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          fileSizeBytes: fileSize,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}

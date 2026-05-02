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

import '../../../core/api/api_client.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/workspace_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../dashboard/widgets/deadline_countdown.dart';
import '../widgets/file_upload.dart';
import '../widgets/progress_tracker.dart';
import '../widgets/project_info_card.dart';
import '../../../core/translation/translation_extensions.dart';

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
  final _liveDocController = TextEditingController();
  bool _isSavingLiveDoc = false;

  @override
  void dispose() {
    _liveDocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceNotifier = ref.watch(workspaceProvider(widget.projectId));
    final workspaceState = workspaceNotifier.state;
    final project = workspaceState.project;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.bottomRight,
        opacity: 0.4,
        child: LoadingOverlay(
          isLoading: workspaceState.isLoading,
          child: Column(
            children: [
              // Header
              _buildHeader(context, project),

              // Content
              Expanded(
                child: project == null
                    ? Center(child: Text('Project not found'.tr(context)))
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

                            // Deadline timer in glass
                            GlassCard(
                              padding: AppSpacing.paddingMd,
                              child: LargeDeadlineTimer(
                                deadline: project.deadline,
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Project info (collapsible) in glass
                            if (_showProjectInfo)
                              ProjectInfoCard(
                                project: project,
                                expanded: true,
                                onToggleExpand: () => setState(() {
                                  _showProjectInfo = false;
                                }),
                              )
                            else
                              GlassContainer(
                                opacity: 0.7,
                                blur: 10,
                                padding: AppSpacing.paddingMd,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                onTap: () => setState(() {
                                  _showProjectInfo = true;
                                }),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Show Project Details'.tr(context),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: AppSpacing.lg),

                            // Progress tracker in glass
                            GlassCard(
                              padding: AppSpacing.paddingMd,
                              child: ProgressTracker(
                                progress: workspaceState.progress / 100.0,
                                onChanged: (value) => ref
                                    .read(workspaceProvider(widget.projectId))
                                    .updateProgress((value * 100).round()),
                              ),
                            ),

                            const SizedBox(height: AppSpacing.lg),

                            // Live Document URL in glass
                            _buildLiveDocSection(project),

                            const SizedBox(height: AppSpacing.lg),

                            // Files section in glass
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context, project) {
    return GlassContainer(
      blur: 20,
      opacity: 0.9,
      borderRadius: BorderRadius.zero,
      borderColor: AppColors.border.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
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
                  Text(
                    'Workspace'.tr(context),
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
              tooltip: 'Chat'.tr(context),
            ),
            IconButton(
              onPressed: () => context.push('/project/${widget.projectId}'),
              icon: const Icon(Icons.info_outline),
              color: AppColors.textSecondary,
              tooltip: 'Project Details'.tr(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveDocSection(dynamic project) {
    // Initialize controller with current URL if not already set
    if (_liveDocController.text.isEmpty && project.liveDocumentUrl != null) {
      _liveDocController.text = project.liveDocumentUrl!;
    }

    return GlassCard(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Google Docs Link'.tr(context),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _liveDocController,
            decoration: InputDecoration(
              hintText: 'https://docs.google.com/...',
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 13),
              prefixIcon: const Icon(Icons.description_outlined, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: _isSavingLiveDoc ? 'Saving...' : 'Save Link',
              onPressed: _isSavingLiveDoc ? null : _saveLiveDocUrl,
              icon: _isSavingLiveDoc ? null : Icons.save,
              isLoading: _isSavingLiveDoc,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLiveDocUrl() async {
    final url = _liveDocController.text.trim();
    if (url.isNotEmpty && !url.startsWith('https://')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('URL must start with https://'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isSavingLiveDoc = true);
    try {
      await ApiClient.put('/projects/${widget.projectId}', {
        'liveDocumentUrl': url.isEmpty ? '' : url,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(url.isEmpty ? 'Google Docs link removed' : 'Google Docs link saved'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save link'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingLiveDoc = false);
    }
  }

  Widget _buildFilesSection(WorkspaceState workspaceState) {
    return GlassCard(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.folder_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                'Work Files'.tr(context),
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
    );
  }

  Widget _buildBottomBar(BuildContext context, WorkspaceState workspaceState) {
    return GlassContainer(
      blur: 20,
      opacity: 0.9,
      borderRadius: BorderRadius.zero,
      padding: AppSpacing.paddingMd,
      borderColor: AppColors.border.withValues(alpha: 0.2),
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
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
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
                    '${workspaceState.progress}%',
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
      useRootNavigator: true,
      useSafeArea: false,
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
            Text(
              'Upload File'.tr(context),
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
              title: Text('Choose from Files'.tr(context)),
              subtitle: Text('PDF, DOC, DOCX, ZIP'.tr(context)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('File picker coming soon'.tr(context)),
                  ),
                );
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
              title: Text('Import from Cloud'.tr(context)),
              subtitle: Text('Google Drive, Dropbox'.tr(context)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cloud import coming soon'.tr(context)),
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

}

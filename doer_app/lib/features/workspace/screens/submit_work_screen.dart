import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../data/models/doer_project_model.dart';
import '../../../data/models/deliverable_model.dart';
import '../../../providers/workspace_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../dashboard/widgets/app_header.dart';
import '../widgets/file_upload.dart';

/// Submit work screen for final project submission.
///
/// Provides the final step interface for submitting completed work,
/// including file verification, notes, and confirmation checkboxes.
///
/// ## Navigation
/// - Entry: From [WorkspaceScreen] via "Submit Work" button
/// - Success: Shows success dialog, then [DashboardScreen]
/// - Back: Returns to [WorkspaceScreen]
///
/// ## Sections
/// 1. **Submission Summary**: Project name, progress, time spent, file count
/// 2. **Submission Files**: List of attached files with primary indicator
/// 3. **Submission Notes**: Optional textarea for reviewer notes
/// 4. **Confirmation**: Required checkboxes before submission
///
/// ## Confirmation Requirements
/// - "I have completed all requirements" checkbox
/// - "This is my original work and plagiarism-free" checkbox
///
/// ## Validation
/// - At least one file must be uploaded
/// - Both confirmation checkboxes must be checked
/// - Shows warning if progress is below 50%
/// - Shows error if no files attached
///
/// ## Features
/// - Disabled reason text when submit button is disabled
/// - Loading state during submission
/// - Success dialog with dashboard navigation
///
/// ## State Variables
/// - [_notesController]: Optional submission notes
/// - [_confirmChecklist]: Requirements confirmation checkbox
/// - [_confirmOriginal]: Originality confirmation checkbox
/// - [_isSubmitting]: Loading state
///
/// ## State Management
/// Uses [WorkspaceProvider] for submission action.
///
/// See also:
/// - [WorkspaceProvider] for workspace state
/// - [WorkspaceScreen] for file management
/// - [DeliverableModel] for file model
class SubmitWorkScreen extends ConsumerStatefulWidget {
  final String projectId;

  const SubmitWorkScreen({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<SubmitWorkScreen> createState() => _SubmitWorkScreenState();
}

class _SubmitWorkScreenState extends ConsumerState<SubmitWorkScreen> {
  final _notesController = TextEditingController();
  bool _confirmChecklist = false;
  bool _confirmOriginal = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workspaceNotifier = ref.watch(workspaceProvider(widget.projectId));
    final workspaceState = workspaceNotifier.state;
    final project = workspaceState.project;
    final files = workspaceState.deliverables;
    final primaryFile = files.where((f) => f.isFinal).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          InnerHeader(
            title: 'Submit Work',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingMd,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Submission summary
                  _buildSummaryCard(project, workspaceState),

                  const SizedBox(height: AppSpacing.lg),

                  // Primary file selection
                  _buildFileSection(files, primaryFile),

                  const SizedBox(height: AppSpacing.lg),

                  // Submission notes
                  Card(
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
                                Icons.note_alt_outlined,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Submission Notes (Optional)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _notesController,
                            hint: 'Add any notes for the reviewer...',
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Confirmation checklist
                  _buildConfirmationSection(),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Submit button
          _buildBottomBar(workspaceState),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(DoerProjectModel? project, WorkspaceState workspaceState) {
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
                  Icons.summarize,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Submission Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // Project title
            if (project != null) ...[
              _buildSummaryRow('Project', project.title),
              const SizedBox(height: AppSpacing.sm),
            ],

            // Progress
            _buildSummaryRow(
              'Progress',
              '${(workspaceState.progress * 100).round()}%',
              valueColor: workspaceState.progress >= 0.75
                  ? AppColors.success
                  : AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Time spent
            _buildSummaryRow(
              'Time Spent',
              _formatDuration(workspaceState.totalTimeSpent),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Files count
            _buildSummaryRow(
              'Files',
              '${workspaceState.deliverables.length} file${workspaceState.deliverables.length != 1 ? 's' : ''}',
            ),

            // Warning if progress is low
            if (workspaceState.progress < 0.5) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Progress is below 50%. Consider adding more work before submitting.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFileSection(List<DeliverableModel> files, DeliverableModel? primaryFile) {
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
            Row(
              children: [
                const Icon(
                  Icons.attach_file,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Submission Files',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (primaryFile != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Primary set',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            if (files.isEmpty)
              Container(
                padding: AppSpacing.paddingMd,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderRadiusSm,
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'No files uploaded. Please add files before submitting.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              )
            else
              FileList(
                files: files,
                editable: false,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationSection() {
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
                  Icons.checklist,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Confirmation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            CheckboxListTile(
              value: _confirmChecklist,
              onChanged: (value) => setState(() {
                _confirmChecklist = value ?? false;
              }),
              title: const Text(
                'I have completed all requirements',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),

            CheckboxListTile(
              value: _confirmOriginal,
              onChanged: (value) => setState(() {
                _confirmOriginal = value ?? false;
              }),
              title: const Text(
                'This is my original work and plagiarism-free',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(WorkspaceState workspaceState) {
    final canSubmit = workspaceState.deliverables.isNotEmpty &&
        _confirmChecklist &&
        _confirmOriginal &&
        !_isSubmitting;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!canSubmit && !_isSubmitting)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  _getDisabledReason(workspaceState),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            AppButton(
              text: _isSubmitting ? 'Submitting...' : 'Submit for Review',
              onPressed: canSubmit ? _submit : null,
              isFullWidth: true,
              isLoading: _isSubmitting,
              icon: Icons.send,
            ),
          ],
        ),
      ),
    );
  }

  String _getDisabledReason(WorkspaceState workspaceState) {
    if (workspaceState.deliverables.isEmpty) {
      return 'Please upload at least one file';
    }
    if (!_confirmChecklist) {
      return 'Please confirm you completed all requirements';
    }
    if (!_confirmOriginal) {
      return 'Please confirm this is original work';
    }
    return '';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    try {
      final success = await ref
          .read(workspaceProvider(widget.projectId))
          .submitWork(notes: _notesController.text);

      if (success && mounted) {
        _showSuccessDialog();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Work Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Your work has been submitted for review. You\'ll be notified once it\'s reviewed.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: AppButton(
              text: 'Back to Dashboard',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.go('/dashboard');
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress tracking and work session timer widgets.
///
/// This file provides widgets for tracking work progress and timing
/// work sessions in the workspace, helping doers monitor their effort
/// and completion status.
///
/// ## Widgets
/// - [ProgressTracker] - Visual progress bar with editable slider
/// - [WorkSessionTimer] - Session timer with start/stop controls
///
/// ## Progress States
/// Progress is color-coded based on completion percentage:
/// - **0-24%** (gray): Just started
/// - **25-49%** (yellow): In progress
/// - **50-74%** (blue): Halfway done
/// - **75-100%** (green): Almost/fully complete
///
/// ## Features
/// - Linear progress bar with percentage display
/// - Slider for manual progress adjustment
/// - Quick-select buttons for 25%, 50%, 75%, 100%
/// - Progress stages visualization (read-only mode)
/// - Work session timer with elapsed time
/// - Start/Stop controls for session tracking
///
/// ## Example
/// ```dart
/// // Editable progress tracker
/// ProgressTracker(
///   progress: 0.65,
///   onChanged: (value) => workspace.updateProgress(value),
/// )
///
/// // Work session timer
/// WorkSessionTimer(
///   totalTime: Duration(hours: 2, minutes: 30),
///   isActive: isWorking,
///   onStart: workspace.startSession,
///   onStop: workspace.endSession,
/// )
/// ```
///
/// See also:
/// - [WorkspaceScreen] for usage context
/// - [WorkspaceProvider] for state management
/// - [WorkspaceState] for progress data model
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Work progress tracker with visual bar and optional slider.
///
/// Displays current work completion percentage with color-coded progress
/// bar. In editable mode, provides slider and quick-select buttons for
/// updating progress. In read-only mode, shows progress stages.
///
/// ## Props
/// - [progress]: Current progress value (0.0 to 1.0)
/// - [onChanged]: Callback when progress is adjusted
/// - [editable]: Enable slider controls (default: true)
class ProgressTracker extends StatelessWidget {
  final double progress;
  final ValueChanged<double>? onChanged;
  final bool editable;

  const ProgressTracker({
    super.key,
    required this.progress,
    this.onChanged,
    this.editable = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();

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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Work Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getProgressColor(progress).withValues(alpha: 0.1),
                    borderRadius: AppSpacing.borderRadiusSm,
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(progress),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: AppSpacing.borderRadiusSm,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(progress),
                ),
                minHeight: 8,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Slider (if editable)
            if (editable && onChanged != null) ...[
              const Row(
                children: [
                  Icon(
                    Icons.tune,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Adjust progress:',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _getProgressColor(progress),
                  inactiveTrackColor: AppColors.border,
                  thumbColor: _getProgressColor(progress),
                  overlayColor: _getProgressColor(progress).withValues(alpha: 0.2),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: progress,
                  onChanged: onChanged,
                  divisions: 20,
                ),
              ),

              // Quick select buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [25, 50, 75, 100].map((value) {
                  final isSelected = percentage == value;
                  return InkWell(
                    onTap: () => onChanged!(value / 100),
                    borderRadius: AppSpacing.borderRadiusSm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _getProgressColor(value / 100)
                            : AppColors.surfaceVariant,
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        '$value%',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ] else ...[
              // Progress stages (read-only view)
              Row(
                children: [
                  _buildProgressStage('Started', progress >= 0.01, 0),
                  _buildProgressConnector(progress >= 0.25),
                  _buildProgressStage('In Progress', progress >= 0.25, 1),
                  _buildProgressConnector(progress >= 0.75),
                  _buildProgressStage('Almost Done', progress >= 0.75, 2),
                  _buildProgressConnector(progress >= 1.0),
                  _buildProgressStage('Complete', progress >= 1.0, 3),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStage(String label, bool isActive, int index) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.border,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isActive ? AppColors.success : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Container(
      height: 2,
      width: 20,
      color: isActive ? AppColors.success : AppColors.border,
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.75) return AppColors.success;
    if (progress >= 0.5) return AppColors.info;
    if (progress >= 0.25) return AppColors.warning;
    return AppColors.textSecondary;
  }
}

/// Work session timer with start/stop controls.
///
/// Displays total time spent working on a project with controls
/// to start and stop timing sessions. The timer icon and colors
/// change based on active state.
///
/// ## Display Format
/// - Hours mode: "2h 30m"
/// - Minutes mode: "15:42" (mm:ss)
///
/// ## Visual States
/// - **Inactive**: Gray icon, "Time Spent" label
/// - **Active**: Primary color, "Session Active" label, pulsing feel
///
/// ## Props
/// - [totalTime]: Total accumulated work time
/// - [isActive]: Whether session timer is running
/// - [onStart]: Callback to start session
/// - [onStop]: Callback to stop session
class WorkSessionTimer extends StatelessWidget {
  final Duration totalTime;
  final bool isActive;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  const WorkSessionTimer({
    super.key,
    required this.totalTime,
    this.isActive = false,
    this.onStart,
    this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      color: isActive
          ? AppColors.primary.withValues(alpha: 0.05)
          : null,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            // Timer icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isActive ? Icons.timer : Icons.timer_outlined,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 24,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Time display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActive ? 'Session Active' : 'Time Spent',
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDuration(totalTime),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),

            // Start/Stop button
            ElevatedButton.icon(
              onPressed: isActive ? onStop : onStart,
              icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
              label: Text(isActive ? 'Stop' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isActive ? AppColors.error : AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

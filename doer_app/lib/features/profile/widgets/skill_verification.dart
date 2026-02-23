/// Skill Verification widget for displaying and managing skill verification status.
///
/// Shows the user's declared skills with their verification status and
/// provides options to request verification for unverified skills.
///
/// ## Features
/// - List of skills with verification status
/// - Verified/Pending/Unverified status badges
/// - Request verification functionality
/// - Verification progress tracking
///
/// ## Usage
/// ```dart
/// SkillVerification(
///   skills: [
///     SkillItem(name: 'Academic Writing', status: VerificationStatus.verified),
///     SkillItem(name: 'Research', status: VerificationStatus.pending),
///   ],
///   onRequestVerification: (skillId) => handleRequest(skillId),
/// )
/// ```
///
/// See also:
/// - [ProfileScreen] for profile display
/// - [EditProfileScreen] for managing skills
library;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

/// Skill verification status.
enum VerificationStatus {
  verified('Verified', Icons.verified, AppColors.success),
  pending('Pending', Icons.pending, AppColors.warning),
  unverified('Unverified', Icons.help_outline, AppColors.textTertiary);

  final String label;
  final IconData icon;
  final Color color;

  const VerificationStatus(this.label, this.icon, this.color);
}

/// Skill item model.
class SkillItem {
  /// Unique identifier.
  final String id;

  /// Skill name.
  final String name;

  /// Verification status.
  final VerificationStatus status;

  /// Date when verified (if applicable).
  final DateTime? verifiedAt;

  /// Date when verification was requested (if pending).
  final DateTime? requestedAt;

  const SkillItem({
    required this.id,
    required this.name,
    required this.status,
    this.verifiedAt,
    this.requestedAt,
  });
}

/// Skill Verification widget.
class SkillVerification extends StatelessWidget {
  /// List of skills to display.
  final List<SkillItem>? skills;

  /// Callback when verification is requested.
  final ValueChanged<String>? onRequestVerification;

  const SkillVerification({
    super.key,
    this.skills,
    this.onRequestVerification,
  });

  /// Mock skills data for demonstration.
  List<SkillItem> get _skills =>
      skills ??
      const [
        SkillItem(
          id: '1',
          name: 'Academic Writing',
          status: VerificationStatus.verified,
          verifiedAt: null,
        ),
        SkillItem(
          id: '2',
          name: 'Research & Analysis',
          status: VerificationStatus.verified,
          verifiedAt: null,
        ),
        SkillItem(
          id: '3',
          name: 'Data Analysis',
          status: VerificationStatus.pending,
          requestedAt: null,
        ),
        SkillItem(
          id: '4',
          name: 'Business Writing',
          status: VerificationStatus.unverified,
        ),
        SkillItem(
          id: '5',
          name: 'Technical Documentation',
          status: VerificationStatus.unverified,
        ),
        SkillItem(
          id: '6',
          name: 'Content Writing',
          status: VerificationStatus.verified,
          verifiedAt: null,
        ),
      ];

  /// Gets verified skills count.
  int get _verifiedCount =>
      _skills.where((s) => s.status == VerificationStatus.verified).length;

  /// Gets pending skills count.
  int get _pendingCount =>
      _skills.where((s) => s.status == VerificationStatus.pending).length;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(),

            const SizedBox(height: AppSpacing.md),

            // Summary stats
            _buildSummary(),

            const SizedBox(height: AppSpacing.lg),

            // Skills list
            ..._skills.map((skill) => _buildSkillItem(context, skill)),

            const SizedBox(height: AppSpacing.md),

            // Info note
            _buildInfoNote(),
          ],
        ),
      ),
    );
  }

  /// Builds the header.
  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(
          Icons.verified_user,
          size: 20,
          color: AppColors.primary,
        ),
        SizedBox(width: 8),
        Text(
          'Skill Verification',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Builds the summary stats.
  Widget _buildSummary() {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryStat(
              'Verified',
              _verifiedCount.toString(),
              AppColors.success,
              Icons.check_circle,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildSummaryStat(
              'Pending',
              _pendingCount.toString(),
              AppColors.warning,
              Icons.pending,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.border,
          ),
          Expanded(
            child: _buildSummaryStat(
              'Total',
              _skills.length.toString(),
              AppColors.primary,
              Icons.psychology,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a summary stat item.
  Widget _buildSummaryStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds a skill item row.
  Widget _buildSkillItem(BuildContext context, SkillItem skill) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: skill.status == VerificationStatus.verified
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: skill.status.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              skill.status.icon,
              size: 18,
              color: skill.status.color,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Skill name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  skill.status.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: skill.status.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Action button
          if (skill.status == VerificationStatus.unverified)
            TextButton(
              onPressed: () => _showVerificationDialog(context, skill),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Verify',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else if (skill.status == VerificationStatus.pending)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.warning,
                    ),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'In Review',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            )
          else
            Icon(
              Icons.verified,
              size: 22,
              color: AppColors.success,
            ),
        ],
      ),
    );
  }

  /// Builds the info note at the bottom.
  Widget _buildInfoNote() {
    return Container(
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.info,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Verified skills increase your chances of getting assigned to relevant projects.',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the verification request dialog.
  void _showVerificationDialog(BuildContext context, SkillItem skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Verification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request verification for "${skill.name}"?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            const Text(
              'Our team will review your profile and work history to verify this skill. This typically takes 2-3 business days.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRequestVerification?.call(skill.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verification requested for ${skill.name}'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../providers/resources_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/section_card.dart';
import '../../dashboard/widgets/app_header.dart';

/// AI content checker screen for detecting AI-generated text.
///
/// Provides a tool for checking text content for AI-generated patterns,
/// helping doers ensure their work is human-written and original.
///
/// ## Navigation
/// - Entry: From [ResourcesHubScreen] via AI Checker tool card
/// - Back: Returns to [ResourcesHubScreen]
///
/// ## Tabs
/// 1. **Check Content**: Input text and run AI detection analysis
/// 2. **History**: View previous check results
///
/// ## Features
/// - Text input area with paste functionality
/// - Word count display
/// - AI score vs human score visualization
/// - Flagged sections highlighting
/// - Verdict summary with recommendations
/// - Result copy and share actions
/// - Check history with tap-to-view details
///
/// ## Score Interpretation
/// - 0-30%: Likely human-written (green)
/// - 30-50%: Mixed signals (blue/info)
/// - 50-70%: Likely AI-generated (yellow/warning)
/// - 70-100%: Highly likely AI-generated (red)
///
/// ## State Variables
/// - [_textController]: Input text controller
/// - [_tabController]: Tab navigation controller
///
/// ## State Management
/// Uses [ResourcesProvider] for AI check operations and history.
///
/// See also:
/// - [ResourcesProvider] for AI check state
/// - [AICheckResult] for result model
/// - [AIHighlight] for flagged sections
class AICheckerScreen extends ConsumerStatefulWidget {
  const AICheckerScreen({super.key});

  @override
  ConsumerState<AICheckerScreen> createState() => _AICheckerScreenState();
}

class _AICheckerScreenState extends ConsumerState<AICheckerScreen>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _textController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resourcesState = ref.watch(resourcesProvider);
    final currentResult = resourcesState.currentAiCheck;
    final history = resourcesState.aiCheckHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          InnerHeader(
            title: 'AI Content Checker',
            onBack: () => Navigator.pop(context),
          ),

          // Tab bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Check Content'),
                Tab(text: 'History'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Check content tab
                _buildCheckTab(resourcesState, currentResult),

                // History tab
                _buildHistoryTab(history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckTab(ResourcesState state, AICheckResult? result) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          _buildInfoCard(),

          const SizedBox(height: AppSpacing.lg),

          // Text input
          _buildInputSection(state.isChecking),

          const SizedBox(height: AppSpacing.lg),

          // Results
          if (result != null) _buildResultCard(result),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: AppColors.info.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(
          color: AppColors.info.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 24,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Detection Tool',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Paste your text below to check for AI-generated content patterns.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(bool isChecking) {
    return SectionCard(
      icon: Icons.edit_note,
      title: 'Your Content',
      trailing: TextButton.icon(
        onPressed: _pasteFromClipboard,
        icon: const Icon(Icons.paste, size: 16),
        label: const Text('Paste'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppTextField(
            controller: _textController,
            hint: 'Enter or paste your text here to check for AI-generated content...',
            maxLines: 8,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                '${_textController.text.split(' ').where((s) => s.isNotEmpty).length} words',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              if (_textController.text.isNotEmpty)
                TextButton(
                  onPressed: () {
                    _textController.clear();
                    ref.read(resourcesProvider.notifier).clearCurrentCheck();
                    setState(() {});
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: isChecking ? 'Analyzing...' : 'Check for AI Content',
            onPressed: isChecking ? null : _checkContent,
            isFullWidth: true,
            isLoading: isChecking,
            icon: Icons.search,
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(AICheckResult result) {
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
                  Icons.analytics,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Analysis Results',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),

            // Score meters
            Row(
              children: [
                Expanded(
                  child: _buildScoreMeter(
                    'AI Generated',
                    result.aiScore,
                    _getScoreColor(result.aiScore),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildScoreMeter(
                    'Human Written',
                    result.humanScore,
                    _getScoreColor(100 - result.aiScore),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Verdict
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: _getVerdictColor(result.aiScore).withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusSm,
                border: Border.all(
                  color: _getVerdictColor(result.aiScore).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getVerdictIcon(result.aiScore),
                        size: 20,
                        color: _getVerdictColor(result.aiScore),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        result.summary,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _getVerdictColor(result.aiScore),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.verdict,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Highlights
            if (result.highlights.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Flagged Sections',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ...result.highlights.map((h) => _buildHighlightItem(h)),
            ],

            const SizedBox(height: AppSpacing.md),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyResults(result),
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copy Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _shareResults(result),
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
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

  Widget _buildScoreMeter(String label, double score, Color color) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              children: [
                Text(
                  '${score.round()}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightItem(AIHighlight highlight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: AppSpacing.paddingSm,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: AppSpacing.borderRadiusSm,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  highlight.reason,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(highlight.probability * 100).round()}% confidence',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<AICheckResult> history) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: AppSpacing.paddingLg,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No checks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Your AI content check history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.paddingMd,
      itemCount: history.length,
      itemBuilder: (context, index) {
        final result = history[index];
        return _buildHistoryItem(result);
      },
    );
  }

  Widget _buildHistoryItem(AICheckResult result) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: InkWell(
        onTap: () => _showHistoryDetail(result),
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Row(
            children: [
              // Score indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getScoreColor(result.aiScore).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${result.aiScore.round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getScoreColor(result.aiScore),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content preview
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.content.length > 60
                          ? '${result.content.substring(0, 60)}...'
                          : result.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(result.checkedAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(result.aiScore).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            result.aiScore > 50 ? 'AI Detected' : 'Human',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getScoreColor(result.aiScore),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score > 70) return AppColors.error;
    if (score > 50) return AppColors.warning;
    if (score > 30) return AppColors.info;
    return AppColors.success;
  }

  Color _getVerdictColor(double aiScore) {
    if (aiScore > 70) return AppColors.error;
    if (aiScore > 50) return AppColors.warning;
    if (aiScore > 30) return AppColors.info;
    return AppColors.success;
  }

  IconData _getVerdictIcon(double aiScore) {
    if (aiScore > 70) return Icons.error;
    if (aiScore > 50) return Icons.warning;
    if (aiScore > 30) return Icons.info;
    return Icons.check_circle;
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _textController.text = data!.text!;
      setState(() {});
    }
  }

  Future<void> _checkContent() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text to check'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await ref.read(resourcesProvider.notifier).checkForAI(_textController.text);
  }

  void _copyResults(AICheckResult result) {
    final report = '''
AI Content Check Report
=======================
AI Score: ${result.aiScore.round()}%
Human Score: ${result.humanScore.round()}%
Verdict: ${result.summary}

Analysis: ${result.verdict}

Checked on: ${_formatDateTime(result.checkedAt)}
''';

    Clipboard.setData(ClipboardData(text: report));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _shareResults(AICheckResult result) {
    // In production, use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHistoryDetail(AICheckResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.paddingMd,
                child: _buildResultCard(result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

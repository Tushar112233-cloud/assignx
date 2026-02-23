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

/// Citation builder screen for generating properly formatted citations.
///
/// Provides a comprehensive tool for creating academic citations in
/// various standard formats based on source type and metadata.
///
/// ## Navigation
/// - Entry: From [ResourcesHubScreen] via Citation Builder tool card
/// - Back: Returns to [ResourcesHubScreen]
///
/// ## Tabs
/// 1. **Create Citation**: Form for entering source details
/// 2. **History**: View and copy previously generated citations
///
/// ## Citation Styles
/// - APA (American Psychological Association)
/// - MLA (Modern Language Association)
/// - Harvard
/// - Chicago
/// - IEEE
///
/// ## Source Types
/// - book: Books and publications
/// - journal: Academic journal articles
/// - website: Online resources
/// - newspaper: News articles
/// - conference: Conference papers
/// - thesis: Dissertations and theses
/// - other: Miscellaneous sources
///
/// ## Form Fields
/// - Author(s): Comma-separated author names
/// - Title: Source title (required)
/// - Publisher/Journal: Publisher name or journal name
/// - Year: Publication year
/// - Volume/Issue: For journals
/// - Pages: Page range
/// - URL: For web sources
/// - DOI: Digital Object Identifier
///
/// ## Features
/// - Dynamic form fields based on source type
/// - Real-time citation preview
/// - Copy to clipboard functionality
/// - Citation history with quick access
///
/// ## State Variables
/// - [_tabController]: Tab navigation
/// - [_selectedStyle]: Current citation style
/// - [_selectedSourceType]: Current source type
/// - Form controllers for each field
/// - [_generatedCitation]: Current result
///
/// ## State Management
/// Uses [ResourcesProvider] for citation generation and history.
///
/// See also:
/// - [ResourcesProvider] for citation state
/// - [Citation] for citation model
/// - [CitationStyle] for style enum
/// - [SourceType] for source type enum
class CitationBuilderScreen extends ConsumerStatefulWidget {
  const CitationBuilderScreen({super.key});

  @override
  ConsumerState<CitationBuilderScreen> createState() => _CitationBuilderScreenState();
}

class _CitationBuilderScreenState extends ConsumerState<CitationBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CitationStyle _selectedStyle = CitationStyle.apa;
  SourceType _selectedSourceType = SourceType.book;

  // Form controllers
  final _authorsController = TextEditingController();
  final _titleController = TextEditingController();
  final _publisherController = TextEditingController();
  final _yearController = TextEditingController();
  final _volumeController = TextEditingController();
  final _issueController = TextEditingController();
  final _pagesController = TextEditingController();
  final _urlController = TextEditingController();
  final _doiController = TextEditingController();

  Citation? _generatedCitation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _authorsController.dispose();
    _titleController.dispose();
    _publisherController.dispose();
    _yearController.dispose();
    _volumeController.dispose();
    _issueController.dispose();
    _pagesController.dispose();
    _urlController.dispose();
    _doiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resourcesState = ref.watch(resourcesProvider);
    final history = resourcesState.citationHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          InnerHeader(
            title: 'Citation Builder',
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
                Tab(text: 'Create Citation'),
                Tab(text: 'History'),
              ],
            ),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Create citation tab
                _buildCreateTab(),

                // History tab
                _buildHistoryTab(history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Style selector
          _buildStyleSelector(),

          const SizedBox(height: AppSpacing.lg),

          // Source type selector
          _buildSourceTypeSelector(),

          const SizedBox(height: AppSpacing.lg),

          // Citation form
          _buildCitationForm(),

          const SizedBox(height: AppSpacing.lg),

          // Generate button
          AppButton(
            text: 'Generate Citation',
            onPressed: _generateCitation,
            isFullWidth: true,
            icon: Icons.auto_fix_high,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Generated citation result
          if (_generatedCitation != null) _buildGeneratedCitation(),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return SectionCard(
      icon: Icons.style,
      title: 'Citation Style',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: CitationStyle.values.map((style) {
              final isSelected = _selectedStyle == style;
              return ChoiceChip(
                label: Text(style.name),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStyle = style;
                    _generatedCitation = null;
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _selectedStyle.fullName,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTypeSelector() {
    return SectionCard(
      icon: Icons.source,
      title: 'Source Type',
      child: DropdownButtonFormField<SourceType>(
        value: _selectedSourceType,
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSm,
            borderSide: BorderSide(color: AppColors.border),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        items: SourceType.values.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Row(
              children: [
                Icon(
                  _getSourceIcon(type),
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(type.displayName),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedSourceType = value!;
            _generatedCitation = null;
          });
        },
      ),
    );
  }

  IconData _getSourceIcon(SourceType type) {
    switch (type) {
      case SourceType.book:
        return Icons.menu_book;
      case SourceType.journal:
        return Icons.article;
      case SourceType.website:
        return Icons.language;
      case SourceType.newspaper:
        return Icons.newspaper;
      case SourceType.conference:
        return Icons.groups;
      case SourceType.thesis:
        return Icons.school;
      case SourceType.other:
        return Icons.description;
    }
  }

  Widget _buildCitationForm() {
    return SectionCard(
      icon: Icons.edit,
      title: 'Source Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Authors
          _buildFormField(
            'Author(s)',
            _authorsController,
            hint: 'e.g., Smith, J. D., & Jones, M.',
            helperText: 'Use format: Last, F. M. for multiple authors',
            isRequired: false,
          ),
          // Title
          _buildFormField(
            'Title',
            _titleController,
            hint: 'Enter the title of the source',
            isRequired: true,
          ),
          // Publisher/Journal
          _buildFormField(
            _selectedSourceType == SourceType.journal
                ? 'Journal Name'
                : 'Publisher',
            _publisherController,
            hint: _selectedSourceType == SourceType.journal
                ? 'e.g., Journal of Psychology'
                : 'e.g., Oxford University Press',
          ),
          // Year
          _buildFormField(
            'Year',
            _yearController,
            hint: 'e.g., 2024',
            keyboardType: TextInputType.number,
          ),
          // Journal-specific fields
          if (_selectedSourceType == SourceType.journal) ...[
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    'Volume',
                    _volumeController,
                    hint: 'e.g., 12',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildFormField(
                    'Issue',
                    _issueController,
                    hint: 'e.g., 3',
                  ),
                ),
              ],
            ),
            _buildFormField(
              'Pages',
              _pagesController,
              hint: 'e.g., 45-67',
            ),
          ],
          // URL (for websites)
          if (_selectedSourceType == SourceType.website ||
              _selectedSourceType == SourceType.newspaper) ...[
            _buildFormField(
              'URL',
              _urlController,
              hint: 'https://example.com/article',
              keyboardType: TextInputType.url,
            ),
          ],
          // DOI (for journals)
          if (_selectedSourceType == SourceType.journal) ...[
            _buildFormField(
              'DOI (optional)',
              _doiController,
              hint: '10.1000/xyz123',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller, {
    String? hint,
    String? helperText,
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          AppTextField(
            controller: controller,
            hint: hint ?? '',
            keyboardType: keyboardType ?? TextInputType.text,
          ),
          if (helperText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                helperText,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGeneratedCitation() {
    return Card(
      elevation: 2,
      color: AppColors.success.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        side: BorderSide(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Generated Citation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _generatedCitation!.style.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: SelectableText(
                _generatedCitation!.formattedCitation,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Copy',
                    onPressed: _copyCitation,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.copy,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'Clear Form',
                    onPressed: _clearForm,
                    variant: AppButtonVariant.outline,
                    icon: Icons.clear,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(List<Citation> history) {
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
                Icons.format_quote,
                size: 48,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'No citations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Your generated citations will appear here',
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
        final citation = history[index];
        return _buildHistoryItem(citation);
      },
    );
  }

  Widget _buildHistoryItem(Citation citation) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      elevation: 1,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
      ),
      child: InkWell(
        onTap: () => _showCitationDetail(citation),
        borderRadius: AppSpacing.borderRadiusSm,
        child: Padding(
          padding: AppSpacing.paddingMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getSourceIcon(citation.sourceType),
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      citation.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      citation.style.name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                citation.formattedCitation,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (citation.authors != null) ...[
                    const Icon(
                      Icons.person,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        citation.authors!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (citation.year != null) ...[
                    const SizedBox(width: 12),
                    Text(
                      citation.year.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateCitation() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    int? year;
    if (_yearController.text.isNotEmpty) {
      year = int.tryParse(_yearController.text);
    }

    final citation = ref.read(resourcesProvider.notifier).generateCitation(
          sourceType: _selectedSourceType,
          title: _titleController.text,
          authors: _authorsController.text.isNotEmpty ? _authorsController.text : null,
          publisherOrJournal:
              _publisherController.text.isNotEmpty ? _publisherController.text : null,
          year: year,
          volume: _volumeController.text.isNotEmpty ? _volumeController.text : null,
          issue: _issueController.text.isNotEmpty ? _issueController.text : null,
          pages: _pagesController.text.isNotEmpty ? _pagesController.text : null,
          url: _urlController.text.isNotEmpty ? _urlController.text : null,
          doi: _doiController.text.isNotEmpty ? _doiController.text : null,
          accessDate: _selectedSourceType == SourceType.website ? DateTime.now() : null,
          style: _selectedStyle,
        );

    setState(() {
      _generatedCitation = citation;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Citation generated!'),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyCitation() {
    if (_generatedCitation != null) {
      Clipboard.setData(ClipboardData(text: _generatedCitation!.formattedCitation));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Citation copied to clipboard'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _authorsController.clear();
      _titleController.clear();
      _publisherController.clear();
      _yearController.clear();
      _volumeController.clear();
      _issueController.clear();
      _pagesController.clear();
      _urlController.clear();
      _doiController.clear();
      _generatedCitation = null;
    });
  }

  void _showCitationDetail(Citation citation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: AppSpacing.paddingMd,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Icon(
                  _getSourceIcon(citation.sourceType),
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    citation.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingMd,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
              child: SelectableText(
                citation.formattedCitation,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              text: 'Copy Citation',
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: citation.formattedCitation),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Citation copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              isFullWidth: true,
              icon: Icons.copy,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

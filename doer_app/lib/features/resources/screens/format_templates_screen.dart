/// Format Templates screen for downloading document templates.
///
/// Provides downloadable Word, PowerPoint, and other format templates
/// for doers to use in their projects.
///
/// ## Features
/// - Template categories (Word, PowerPoint, Excel)
/// - Template preview information
/// - Download functionality with progress
/// - Recently downloaded section
///
/// ## Navigation
/// - Entry: From [ResourcesHubScreen] via "Format Templates"
/// - Back: Returns to resources hub
///
/// ## State Management
/// Uses [ResourcesProvider] for download history tracking.
///
/// See also:
/// - [ResourcesHubScreen] for resources navigation
/// - [ResourcesProvider] for download tracking
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/mesh_gradient_background.dart';
import '../../dashboard/widgets/app_header.dart';
import '../../../core/translation/translation_extensions.dart';

/// Template data model.
class DocumentTemplate {
  /// Unique identifier for the template.
  final String id;

  /// Display name of the template.
  final String name;

  /// Description of the template's purpose.
  final String description;

  /// File format type (Word, PowerPoint, Excel).
  final TemplateFormat format;

  /// File size in bytes.
  final int fileSize;

  /// Download URL for the template.
  final String downloadUrl;

  /// Preview image URL.
  final String? previewUrl;

  /// Number of times downloaded.
  final int downloadCount;

  /// Whether this is a popular template.
  final bool isPopular;

  const DocumentTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.format,
    required this.fileSize,
    required this.downloadUrl,
    this.previewUrl,
    this.downloadCount = 0,
    this.isPopular = false,
  });
}

/// Template format types.
enum TemplateFormat {
  word('Word', Icons.description, Color(0xFF2B579A)),
  powerpoint('PowerPoint', Icons.slideshow, Color(0xFFD24726)),
  excel('Excel', Icons.table_chart, Color(0xFF217346)),
  pdf('PDF', Icons.picture_as_pdf, Color(0xFFE53935));

  /// Display name for the format.
  final String displayName;

  /// Icon for the format.
  final IconData icon;

  /// Brand color for the format.
  final Color color;

  const TemplateFormat(this.displayName, this.icon, this.color);
}

/// Mock templates data.
final List<DocumentTemplate> _mockTemplates = [
  const DocumentTemplate(
    id: '1',
    name: 'Academic Essay Template',
    description: 'Standard academic essay format with proper margins, headers, and citation placeholders.',
    format: TemplateFormat.word,
    fileSize: 45056,
    downloadUrl: 'https://example.com/templates/academic-essay.docx',
    downloadCount: 1250,
    isPopular: true,
  ),
  const DocumentTemplate(
    id: '2',
    name: 'Research Paper Template',
    description: 'Comprehensive research paper template with abstract, methodology, and references sections.',
    format: TemplateFormat.word,
    fileSize: 67584,
    downloadUrl: 'https://example.com/templates/research-paper.docx',
    downloadCount: 980,
    isPopular: true,
  ),
  const DocumentTemplate(
    id: '3',
    name: 'Business Report Template',
    description: 'Professional business report format with executive summary and charts.',
    format: TemplateFormat.word,
    fileSize: 89600,
    downloadUrl: 'https://example.com/templates/business-report.docx',
    downloadCount: 756,
  ),
  const DocumentTemplate(
    id: '4',
    name: 'Case Study Template',
    description: 'Structured case study format with problem statement, analysis, and recommendations.',
    format: TemplateFormat.word,
    fileSize: 52224,
    downloadUrl: 'https://example.com/templates/case-study.docx',
    downloadCount: 623,
  ),
  const DocumentTemplate(
    id: '5',
    name: 'Academic Presentation',
    description: 'Clean academic presentation template with proper slide structure.',
    format: TemplateFormat.powerpoint,
    fileSize: 2097152,
    downloadUrl: 'https://example.com/templates/academic-ppt.pptx',
    downloadCount: 892,
    isPopular: true,
  ),
  const DocumentTemplate(
    id: '6',
    name: 'Project Proposal Slides',
    description: 'Professional project proposal presentation with timeline and budget slides.',
    format: TemplateFormat.powerpoint,
    fileSize: 1572864,
    downloadUrl: 'https://example.com/templates/proposal-ppt.pptx',
    downloadCount: 534,
  ),
  const DocumentTemplate(
    id: '7',
    name: 'Data Analysis Template',
    description: 'Excel template with pre-built formulas for common statistical analysis.',
    format: TemplateFormat.excel,
    fileSize: 131072,
    downloadUrl: 'https://example.com/templates/data-analysis.xlsx',
    downloadCount: 445,
  ),
  const DocumentTemplate(
    id: '8',
    name: 'Literature Review Template',
    description: 'Organized literature review format with source tracking table.',
    format: TemplateFormat.word,
    fileSize: 48128,
    downloadUrl: 'https://example.com/templates/lit-review.docx',
    downloadCount: 678,
  ),
  const DocumentTemplate(
    id: '9',
    name: 'APA Format Guide',
    description: 'Complete APA 7th edition formatting guide with examples.',
    format: TemplateFormat.pdf,
    fileSize: 524288,
    downloadUrl: 'https://example.com/templates/apa-guide.pdf',
    downloadCount: 1456,
    isPopular: true,
  ),
  const DocumentTemplate(
    id: '10',
    name: 'Harvard Referencing Guide',
    description: 'Comprehensive Harvard referencing style guide.',
    format: TemplateFormat.pdf,
    fileSize: 458752,
    downloadUrl: 'https://example.com/templates/harvard-guide.pdf',
    downloadCount: 1123,
  ),
];

/// Format Templates screen widget.
class FormatTemplatesScreen extends ConsumerStatefulWidget {
  const FormatTemplatesScreen({super.key});

  @override
  ConsumerState<FormatTemplatesScreen> createState() =>
      _FormatTemplatesScreenState();
}

class _FormatTemplatesScreenState extends ConsumerState<FormatTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _downloadingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Filters templates by format.
  List<DocumentTemplate> _getTemplatesByFormat(TemplateFormat? format) {
    if (format == null) {
      return _mockTemplates;
    }
    return _mockTemplates.where((t) => t.format == format).toList();
  }

  /// Gets popular templates.
  List<DocumentTemplate> _getPopularTemplates() {
    return _mockTemplates.where((t) => t.isPopular).toList();
  }

  /// Handles template download.
  Future<void> _downloadTemplate(DocumentTemplate template) async {
    setState(() {
      _downloadingId = template.id;
    });

    try {
      // Simulate download delay
      await Future.delayed(const Duration(seconds: 1));

      final uri = Uri.parse(template.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.name} download started'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download: $e'.tr(context)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingId = null;
        });
      }
    }
  }

  /// Formats file size for display.
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: MeshGradientBackground(
        position: MeshPosition.topLeft,
        colors: MeshColors.defaultColors,
        opacity: 0.45,
        child: LoadingOverlay(
          isLoading: _isLoading,
          child: Column(
            children: [
              InnerHeader(
                title: 'Format Templates',
                onBack: () => Navigator.pop(context),
              ),

              // Popular templates section
              _buildPopularSection(),

              // Tab bar
              _buildTabBar(),

              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTemplateGrid(null), // All
                    _buildTemplateGrid(TemplateFormat.word),
                    _buildTemplateGrid(TemplateFormat.powerpoint),
                    _buildTemplateGrid(TemplateFormat.excel),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the popular templates horizontal section.
  Widget _buildPopularSection() {
    final popularTemplates = _getPopularTemplates();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  size: 16,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Popular Templates'.tr(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${popularTemplates.length} templates',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: popularTemplates.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final template = popularTemplates[index];
                return _buildPopularCard(template);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a popular template card with glass effect.
  Widget _buildPopularCard(DocumentTemplate template) {
    final isDownloading = _downloadingId == template.id;

    return GlassCard(
      onTap: isDownloading ? null : () => _downloadTemplate(template),
      blur: 10,
      opacity: 0.7,
      width: 200,
      padding: AppSpacing.paddingMd,
      borderColor: template.format.color.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                template.format.icon,
                size: 24,
                color: template.format.color,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: template.format.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  template.format.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: template.format.color,
                  ),
                ),
              ),
              const Spacer(),
              if (isDownloading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      template.format.color,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.download,
                  size: 18,
                  color: template.format.color,
                ),
            ],
          ),
          const Spacer(),
          Text(
            template.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '${template.downloadCount} downloads',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar with glass styling.
  Widget _buildTabBar() {
    return GlassContainer(
      blur: 10,
      opacity: 0.8,
      borderRadius: BorderRadius.zero,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.accent,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: [
          const Tab(text: 'All'),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description, size: 16),
                const SizedBox(width: 6),
                Text('Word'.tr(context)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.slideshow, size: 16),
                const SizedBox(width: 6),
                Text('PowerPoint'.tr(context)),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.table_chart, size: 16),
                const SizedBox(width: 6),
                Text('Excel'.tr(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the template grid for a specific format.
  Widget _buildTemplateGrid(TemplateFormat? format) {
    final templates = _getTemplatesByFormat(format);

    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              format?.icon ?? Icons.folder_open,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No ${format?.displayName ?? ''} templates available',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: AppSpacing.paddingMd,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.78,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        return _buildTemplateGridCard(templates[index]);
      },
    );
  }

  /// Builds a template grid card with glass effect and category badge.
  Widget _buildTemplateGridCard(DocumentTemplate template) {
    final isDownloading = _downloadingId == template.id;

    return GlassCard(
      onTap: isDownloading ? null : () => _downloadTemplate(template),
      blur: 10,
      opacity: 0.72,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Format icon and badge row
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: template.format.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  template.format.icon,
                  size: 22,
                  color: template.format.color,
                ),
              ),
              const Spacer(),
              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: template.format.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  template.format.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: template.format.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Template name
          Text(
            template.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Description
          Expanded(
            child: Text(
              template.description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Footer row with meta and download
          Row(
            children: [
              Text(
                _formatFileSize(template.fileSize),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 6),
              if (template.isPopular) ...[
                Icon(
                  Icons.star,
                  size: 12,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 2),
              ],
              const Spacer(),
              if (isDownloading)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      template.format.color,
                    ),
                  ),
                )
              else
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: template.format.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download,
                    size: 16,
                    color: template.format.color,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

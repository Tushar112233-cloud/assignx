import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/tool_model.dart';

/// Card widget for displaying a tool.
///
/// Shows tool icon, name, description, and launch action.
class ToolCard extends StatelessWidget {
  const ToolCard({
    super.key,
    required this.tool,
    required this.onTap,
    this.compact = false,
  });

  /// Tool to display.
  final ToolModel tool;

  /// Called when card is tapped.
  final VoidCallback onTap;

  /// Whether to use compact layout.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: tool.color.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon and badge row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: tool.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      tool.icon,
                      color: tool.color,
                      size: 24,
                    ),
                  ),
                  const Spacer(),
                  if (tool.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (tool.isExternal && !tool.isPremium)
                    Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: AppColors.textSecondaryLight,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Name
              Text(
                tool.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Description
              Text(
                tool.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Usage count
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    size: 14,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tool.usageCount} uses',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tool.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          tool.icon,
          color: tool.color,
          size: 20,
        ),
      ),
      title: Text(
        tool.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        tool.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Icon(
        tool.isExternal ? Icons.open_in_new : Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textSecondaryLight,
      ),
    );
  }
}

/// Grid of tool cards.
class ToolGrid extends StatelessWidget {
  const ToolGrid({
    super.key,
    required this.tools,
    required this.onToolTap,
    this.crossAxisCount = 2,
    this.padding = const EdgeInsets.all(16),
  });

  /// List of tools to display.
  final List<ToolModel> tools;

  /// Called when a tool is tapped.
  final void Function(ToolModel tool) onToolTap;

  /// Number of columns.
  final int crossAxisCount;

  /// Padding around the grid.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ToolCard(
          tool: tool,
          onTap: () => onToolTap(tool),
        );
      },
    );
  }
}

/// Horizontal list of tool cards for quick access.
class ToolQuickAccess extends StatelessWidget {
  const ToolQuickAccess({
    super.key,
    required this.tools,
    required this.onToolTap,
    this.title,
  });

  /// List of tools.
  final List<ToolModel> tools;

  /// Called when a tool is tapped.
  final void Function(ToolModel tool) onToolTap;

  /// Optional title.
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: tools.length,
            itemBuilder: (context, index) {
              final tool = tools[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < tools.length - 1 ? 12 : 0,
                ),
                child: _QuickAccessItem(
                  tool: tool,
                  onTap: () => onToolTap(tool),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Quick access item for horizontal list.
class _QuickAccessItem extends StatelessWidget {
  const _QuickAccessItem({
    required this.tool,
    required this.onTap,
  });

  final ToolModel tool;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tool.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: tool.color.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              color: tool.color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              tool.name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

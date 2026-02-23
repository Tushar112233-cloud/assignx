import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/support_ticket_model.dart';
import '../../../providers/profile_provider.dart';

/// Ticket filter options.
enum TicketFilter {
  all('All'),
  open('Open'),
  resolved('Resolved');

  final String label;
  const TicketFilter(this.label);
}

/// Ticket history section widget displaying user's support tickets.
class TicketHistorySection extends ConsumerStatefulWidget {
  const TicketHistorySection({super.key});

  @override
  ConsumerState<TicketHistorySection> createState() => _TicketHistorySectionState();
}

class _TicketHistorySectionState extends ConsumerState<TicketHistorySection> {
  TicketFilter _selectedFilter = TicketFilter.all;
  String? _expandedTicketId;

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(supportTicketsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and filter
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Ticket History',
                  style: AppTextStyles.labelLarge,
                ),
              ],
            ),
            // Filter chips
            _FilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Tickets list
        ticketsAsync.when(
          data: (tickets) {
            final filteredTickets = _filterTickets(tickets);

            if (filteredTickets.isEmpty) {
              return _EmptyState(
                filter: _selectedFilter,
                hasAnyTickets: tickets.isNotEmpty,
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(supportTicketsProvider);
              },
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredTickets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ticket = filteredTickets[index];
                  return _TicketCard(
                    ticket: ticket,
                    isExpanded: _expandedTicketId == ticket.id,
                    onTap: () {
                      setState(() {
                        _expandedTicketId =
                            _expandedTicketId == ticket.id ? null : ticket.id;
                      });
                    },
                  );
                },
              ),
            );
          },
          loading: () => const _LoadingState(),
          error: (error, _) => _ErrorState(
            error: error.toString(),
            onRetry: () => ref.invalidate(supportTicketsProvider),
          ),
        ),
      ],
    );
  }

  List<SupportTicket> _filterTickets(List<SupportTicket> tickets) {
    switch (_selectedFilter) {
      case TicketFilter.all:
        return tickets;
      case TicketFilter.open:
        return tickets
            .where((t) =>
                t.status == TicketStatus.open ||
                t.status == TicketStatus.pending)
            .toList();
      case TicketFilter.resolved:
        return tickets
            .where((t) =>
                t.status == TicketStatus.resolved ||
                t.status == TicketStatus.closed)
            .toList();
    }
  }
}

/// Filter chips for ticket status.
class _FilterChips extends StatelessWidget {
  final TicketFilter selectedFilter;
  final ValueChanged<TicketFilter> onFilterChanged;

  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TicketFilter.values.map((filter) {
        final isSelected = filter == selectedFilter;
        return Padding(
          padding: const EdgeInsets.only(left: 4),
          child: GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                filter.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Individual ticket card widget.
class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final bool isExpanded;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded ? AppColors.primary.withAlpha(50) : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isExpanded ? 10 : 5),
              blurRadius: isExpanded ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with ID and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  ticket.displayId,
                  style: AppTextStyles.caption.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _StatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: 8),

            // Subject
            Text(
              ticket.subject,
              style: AppTextStyles.labelMedium,
              maxLines: isExpanded ? null : 1,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Category and date
            Row(
              children: [
                Icon(
                  _getCategoryIcon(ticket.category),
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  ticket.category.label,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 8),
                Text(
                  '|',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  ticket.createdDateString,
                  style: AppTextStyles.caption,
                ),
              ],
            ),

            // Expanded content
            if (isExpanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Description
              Text(
                'Description',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),

              // Responses if any
              if (ticket.responses.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Responses (${ticket.responses.length})',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ...ticket.responses.map((response) => _ResponseItem(
                      response: response,
                    )),
              ],

              // Last updated
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Updated ${ticket.updatedDateString}',
                    style: AppTextStyles.caption.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],

            // Expand indicator
            if (!isExpanded)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(TicketCategory category) {
    switch (category) {
      case TicketCategory.paymentIssue:
        return Icons.payment;
      case TicketCategory.projectRelated:
        return Icons.folder;
      case TicketCategory.technicalProblem:
        return Icons.bug_report;
      case TicketCategory.accountIssue:
        return Icons.person;
      case TicketCategory.refundRequest:
        return Icons.replay;
      case TicketCategory.other:
        return Icons.help_outline;
    }
  }
}

/// Status badge widget.
class _StatusBadge extends StatelessWidget {
  final TicketStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall.copyWith(
          color: status.color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// Response item widget.
class _ResponseItem extends StatelessWidget {
  final TicketResponse response;

  const _ResponseItem({required this.response});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: response.isStaffResponse
            ? AppColors.primaryLight.withAlpha(15)
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: response.isStaffResponse
            ? Border.all(color: AppColors.primary.withAlpha(30))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                response.isStaffResponse
                    ? Icons.support_agent
                    : Icons.person_outline,
                size: 14,
                color: response.isStaffResponse
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                response.isStaffResponse ? 'Support Team' : 'You',
                style: AppTextStyles.labelSmall.copyWith(
                  color: response.isStaffResponse
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                _formatResponseDate(response.createdAt),
                style: AppTextStyles.caption.copyWith(fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            response.message,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatResponseDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Empty state widget.
class _EmptyState extends StatelessWidget {
  final TicketFilter filter;
  final bool hasAnyTickets;

  const _EmptyState({
    required this.filter,
    required this.hasAnyTickets,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            hasAnyTickets ? Icons.filter_list : Icons.inbox_outlined,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            hasAnyTickets
                ? 'No ${filter.label.toLowerCase()} tickets'
                : 'No tickets yet',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasAnyTickets
                ? 'Try changing the filter to see other tickets'
                : 'Your support tickets will appear here',
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Loading state widget.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(height: 12),
          Text(
            'Loading tickets...',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Error state widget.
class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 36,
            color: AppColors.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Failed to load tickets',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.error.withAlpha(180),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

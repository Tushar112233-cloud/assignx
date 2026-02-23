import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/misc/status_badge.dart';
import '../../data/models/ticket_model.dart';

/// Ticket card widget.
class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  final TicketModel ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Category icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ticket.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      ticket.category.icon,
                      size: 18,
                      color: ticket.status.color,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Ticket number and date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ticket.ticketNumber != null)
                          Text(
                            '#${ticket.ticketNumber}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        Text(
                          ticket.timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  StatusBadge.fromDisplayable(
                    displayName: ticket.status.displayName,
                    color: ticket.status.color,
                    icon: ticket.status.icon,
                    size: StatusBadgeSize.small,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subject
              Text(
                ticket.subject,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  ticket.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      ticket.category.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontSize: 10,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Priority indicator
                  if (ticket.priority != TicketPriority.normal)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ticket.priority.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 10,
                            color: ticket.priority.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ticket.priority.displayName,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ticket.priority.color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),

                  const Spacer(),

                  // Attachments indicator
                  if (ticket.attachments.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.attach_file,
                          size: 14,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${ticket.attachments.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// Ticket list widget.
class TicketList extends StatelessWidget {
  const TicketList({
    super.key,
    required this.tickets,
    required this.onTicketTap,
    this.onLoadMore,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  final List<TicketModel> tickets;
  final void Function(TicketModel) onTicketTap;
  final VoidCallback? onLoadMore;
  final bool isLoadingMore;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 100 &&
            hasMore &&
            !isLoadingMore) {
          onLoadMore?.call();
        }
        return false;
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tickets.length + (isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == tickets.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final ticket = tickets[index];
          return TicketCard(
            ticket: ticket,
            onTap: () => onTicketTap(ticket),
          );
        },
      ),
    );
  }
}

/// Empty tickets state.
class EmptyTickets extends StatelessWidget {
  const EmptyTickets({
    super.key,
    this.onCreateTicket,
  });

  final VoidCallback? onCreateTicket;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent,
              size: 64,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No support tickets',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Need help? Create a support ticket and we\'ll get back to you.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onCreateTicket != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onCreateTicket,
                icon: const Icon(Icons.add),
                label: const Text('Create Ticket'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Ticket status filter chips.
class TicketStatusFilter extends StatelessWidget {
  const TicketStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  final TicketStatus? selectedStatus;
  final void Function(TicketStatus?) onStatusChanged;

  static const _statuses = [
    null, // All
    TicketStatus.open,
    TicketStatus.inProgress,
    TicketStatus.waitingForReply,
    TicketStatus.resolved,
    TicketStatus.closed,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _statuses.map((status) {
          final isSelected = selectedStatus == status;
          final label = status?.displayName ?? 'All';
          final color = status?.color ?? AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onStatusChanged(status),
              selectedColor: color.withValues(alpha: 0.2),
              checkmarkColor: color,
              labelStyle: TextStyle(
                color: isSelected ? color : AppColors.textSecondaryLight,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? color
                      : AppColors.textSecondaryLight.withValues(alpha: 0.3),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

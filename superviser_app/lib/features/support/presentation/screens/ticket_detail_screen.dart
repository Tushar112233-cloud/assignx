import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/ticket_model.dart';
import '../providers/support_provider.dart';
import '../widgets/ticket_form.dart';

/// Ticket detail screen with messages.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ticketDetailProvider.notifier).loadTicket(widget.ticketId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketDetailProvider);

    // Scroll to bottom when messages change
    ref.listen(ticketDetailProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: state.ticket != null
            ? Text('#${state.ticket!.ticketNumber ?? state.ticket!.id.substring(0, 8)}')
            : const Text('Ticket'),
        actions: [
          if (state.ticket != null) ...[
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, state.ticket!),
              itemBuilder: (context) => [
                if (state.ticket!.isActive) ...[
                  const PopupMenuItem(
                    value: 'close',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 12),
                        Text('Close Ticket'),
                      ],
                    ),
                  ),
                ] else ...[
                  const PopupMenuItem(
                    value: 'reopen',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, size: 20),
                        SizedBox(width: 12),
                        Text('Reopen Ticket'),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.error != null
              ? _ErrorState(error: state.error!)
              : state.ticket == null
                  ? const _NotFoundState()
                  : Column(
                      children: [
                        // Ticket header
                        _TicketHeader(ticket: state.ticket!),

                        // Messages
                        Expanded(
                          child: state.isLoadingMessages
                              ? const Center(child: CircularProgressIndicator())
                              : state.messages.isEmpty
                                  ? const _EmptyMessages()
                                  : ListView.builder(
                                      controller: _scrollController,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      itemCount: state.messages.length,
                                      itemBuilder: (context, index) {
                                        final message = state.messages[index];
                                        final isCurrentUser = !message.isSupport;
                                        return TicketMessageBubble(
                                          message: message,
                                          isCurrentUser: isCurrentUser,
                                        );
                                      },
                                    ),
                        ),

                        // Message input
                        if (state.ticket!.isActive)
                          TicketMessageInput(
                            onSend: (message) {
                              ref
                                  .read(ticketDetailProvider.notifier)
                                  .sendMessage(message);
                            },
                            isSending: state.isSending,
                          )
                        else
                          _ClosedTicketBanner(
                            ticket: state.ticket!,
                            onReopen: () => _handleReopen(),
                          ),
                      ],
                    ),
    );
  }

  void _handleMenuAction(String action, TicketModel ticket) {
    switch (action) {
      case 'close':
        _showCloseDialog();
        break;
      case 'reopen':
        _handleReopen();
        break;
    }
  }

  void _showCloseDialog() {
    showDialog(
      context: context,
      builder: (context) => CloseTicketDialog(
        onClose: ({int? rating, String? feedback}) async {
          final success = await ref.read(ticketDetailProvider.notifier).closeTicket(
                rating: rating,
                feedback: feedback,
              );

          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Ticket closed successfully'),
                backgroundColor: Colors.green,
              ),
            );
            // Refresh tickets list
            ref.read(ticketsProvider.notifier).refresh();
          }
        },
      ),
    );
  }

  Future<void> _handleReopen() async {
    final success = await ref.read(ticketDetailProvider.notifier).reopenTicket();

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket reopened'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh tickets list
      ref.read(ticketsProvider.notifier).refresh();
    }
  }
}

/// Ticket header with details.
class _TicketHeader extends StatelessWidget {
  const _TicketHeader({required this.ticket});

  final TicketModel ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and priority row
          Row(
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: ticket.status.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ticket.status.icon,
                      size: 14,
                      color: ticket.status.color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.status.displayName,
                      style: TextStyle(
                        color: ticket.status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Category badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      ticket.category.icon,
                      size: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      ticket.category.displayName,
                      style: const TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Priority
              if (ticket.priority != TicketPriority.normal)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: ticket.priority.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 12,
                        color: ticket.priority.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.priority.displayName,
                        style: TextStyle(
                          color: ticket.priority.color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Subject
          Text(
            ticket.subject,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),

          // Date
          const SizedBox(height: 4),
          Text(
            'Created ${ticket.formattedDate}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
          ),
        ],
      ),
    );
  }
}

/// Empty messages state.
class _EmptyMessages extends StatelessWidget {
  const _EmptyMessages();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_outlined,
              size: 48,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Closed ticket banner.
class _ClosedTicketBanner extends StatelessWidget {
  const _ClosedTicketBanner({
    required this.ticket,
    required this.onReopen,
  });

  final TicketModel ticket;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 32,
      ),
      decoration: BoxDecoration(
        color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          Icon(
            ticket.status == TicketStatus.resolved
                ? Icons.check_circle
                : Icons.archive,
            color: ticket.status.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'This ticket has been ${ticket.status.displayName.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (ticket.rating != null)
                  Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < ticket.rating!
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: onReopen,
            child: const Text('Reopen'),
          ),
        ],
      ),
    );
  }
}

/// Error state.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Not found state.
class _NotFoundState extends StatelessWidget {
  const _NotFoundState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Ticket not found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

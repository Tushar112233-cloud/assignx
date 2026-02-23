import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/ticket_model.dart';
import '../../data/repositories/support_repository.dart';

/// Provider for support repository.
final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository();
});

/// State for tickets list.
class TicketsState {
  const TicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.selectedStatus,
    this.selectedCategory,
  });

  final List<TicketModel> tickets;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final TicketStatus? selectedStatus;
  final TicketCategory? selectedCategory;

  TicketsState copyWith({
    List<TicketModel>? tickets,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    TicketStatus? selectedStatus,
    TicketCategory? selectedCategory,
    bool clearStatus = false,
    bool clearCategory = false,
  }) {
    return TicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }
}

/// Notifier for tickets.
class TicketsNotifier extends StateNotifier<TicketsState> {
  TicketsNotifier(this._repository) : super(const TicketsState());

  final SupportRepository _repository;
  static const _pageSize = 20;

  /// Load tickets.
  Future<void> loadTickets() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final tickets = await _repository.getTickets(
        limit: _pageSize,
        status: state.selectedStatus,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        tickets: tickets,
        isLoading: false,
        hasMore: tickets.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more tickets.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final tickets = await _repository.getTickets(
        limit: _pageSize,
        offset: state.tickets.length,
        status: state.selectedStatus,
        category: state.selectedCategory,
      );

      state = state.copyWith(
        tickets: [...state.tickets, ...tickets],
        isLoadingMore: false,
        hasMore: tickets.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh tickets.
  Future<void> refresh() async {
    await loadTickets();
  }

  /// Filter by status.
  Future<void> setStatusFilter(TicketStatus? status) async {
    state = state.copyWith(
      selectedStatus: status,
      clearStatus: status == null,
    );
    await loadTickets();
  }

  /// Filter by category.
  Future<void> setCategoryFilter(TicketCategory? category) async {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
    await loadTickets();
  }

  /// Add new ticket to list.
  void addTicket(TicketModel ticket) {
    state = state.copyWith(
      tickets: [ticket, ...state.tickets],
    );
  }

  /// Update ticket in list.
  void updateTicket(TicketModel ticket) {
    state = state.copyWith(
      tickets: state.tickets.map((t) => t.id == ticket.id ? ticket : t).toList(),
    );
  }
}

/// Provider for tickets.
final ticketsProvider =
    StateNotifierProvider<TicketsNotifier, TicketsState>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return TicketsNotifier(repository);
});

/// State for ticket detail.
class TicketDetailState {
  const TicketDetailState({
    this.ticket,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMessages = false,
    this.isSending = false,
    this.error,
  });

  final TicketModel? ticket;
  final List<TicketMessage> messages;
  final bool isLoading;
  final bool isLoadingMessages;
  final bool isSending;
  final String? error;

  TicketDetailState copyWith({
    TicketModel? ticket,
    List<TicketMessage>? messages,
    bool? isLoading,
    bool? isLoadingMessages,
    bool? isSending,
    String? error,
  }) {
    return TicketDetailState(
      ticket: ticket ?? this.ticket,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMessages: isLoadingMessages ?? this.isLoadingMessages,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

/// Notifier for ticket detail.
class TicketDetailNotifier extends StateNotifier<TicketDetailState> {
  TicketDetailNotifier(this._repository) : super(const TicketDetailState());

  final SupportRepository _repository;
  StreamSubscription<List<TicketMessage>>? _messagesSubscription;

  /// Load ticket detail.
  Future<void> loadTicket(String ticketId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ticket = await _repository.getTicketById(ticketId);

      if (ticket == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Ticket not found',
        );
        return;
      }

      state = state.copyWith(
        ticket: ticket,
        isLoading: false,
      );

      // Load and subscribe to messages
      await _loadMessages(ticketId);
      _subscribeToMessages(ticketId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadMessages(String ticketId) async {
    state = state.copyWith(isLoadingMessages: true);

    try {
      final messages = await _repository.getMessages(ticketId);
      state = state.copyWith(
        messages: messages,
        isLoadingMessages: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMessages: false,
        error: e.toString(),
      );
    }
  }

  void _subscribeToMessages(String ticketId) {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.watchMessages(ticketId).listen((messages) {
      state = state.copyWith(messages: messages);
    });
  }

  /// Send message.
  Future<bool> sendMessage(String message, {List<String> attachments = const []}) async {
    if (state.ticket == null) return false;

    state = state.copyWith(isSending: true, error: null);

    try {
      final newMessage = await _repository.sendMessage(
        state.ticket!.id,
        message,
        attachments: attachments,
      );

      state = state.copyWith(
        messages: [...state.messages, newMessage],
        isSending: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Close ticket with rating.
  Future<bool> closeTicket({int? rating, String? feedback}) async {
    if (state.ticket == null) return false;

    try {
      await _repository.closeTicket(
        state.ticket!.id,
        rating: rating,
        feedback: feedback,
      );

      state = state.copyWith(
        ticket: state.ticket!.copyWith(
          status: TicketStatus.closed,
          closedAt: DateTime.now(),
          rating: rating,
          feedback: feedback,
        ),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reopen ticket.
  Future<bool> reopenTicket() async {
    if (state.ticket == null) return false;

    try {
      await _repository.reopenTicket(state.ticket!.id);

      state = state.copyWith(
        ticket: state.ticket!.copyWith(
          status: TicketStatus.open,
        ),
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for ticket detail.
final ticketDetailProvider =
    StateNotifierProvider<TicketDetailNotifier, TicketDetailState>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return TicketDetailNotifier(repository);
});

/// State for creating ticket.
class CreateTicketState {
  const CreateTicketState({
    this.isSubmitting = false,
    this.error,
    this.createdTicket,
  });

  final bool isSubmitting;
  final String? error;
  final TicketModel? createdTicket;

  CreateTicketState copyWith({
    bool? isSubmitting,
    String? error,
    TicketModel? createdTicket,
  }) {
    return CreateTicketState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      createdTicket: createdTicket ?? this.createdTicket,
    );
  }
}

/// Notifier for creating tickets.
class CreateTicketNotifier extends StateNotifier<CreateTicketState> {
  CreateTicketNotifier(this._repository) : super(const CreateTicketState());

  final SupportRepository _repository;

  /// Create ticket.
  Future<TicketModel?> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    TicketPriority priority = TicketPriority.normal,
    List<String> attachments = const [],
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final ticket = await _repository.createTicket(
        subject: subject,
        description: description,
        category: category,
        priority: priority,
        attachments: attachments,
      );

      state = state.copyWith(
        isSubmitting: false,
        createdTicket: ticket,
      );

      return ticket;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// Reset state.
  void reset() {
    state = const CreateTicketState();
  }
}

/// Provider for creating tickets.
final createTicketProvider =
    StateNotifierProvider<CreateTicketNotifier, CreateTicketState>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return CreateTicketNotifier(repository);
});

/// State for FAQ.
class FAQState {
  const FAQState({
    this.items = const [],
    this.categories = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.isSearching = false,
    this.searchQuery = '',
    this.error,
  });

  final List<FAQItem> items;
  final List<FAQCategory> categories;
  final List<FAQItem> searchResults;
  final bool isLoading;
  final bool isSearching;
  final String searchQuery;
  final String? error;

  FAQState copyWith({
    List<FAQItem>? items,
    List<FAQCategory>? categories,
    List<FAQItem>? searchResults,
    bool? isLoading,
    bool? isSearching,
    String? searchQuery,
    String? error,
  }) {
    return FAQState(
      items: items ?? this.items,
      categories: categories ?? this.categories,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}

/// Notifier for FAQ.
class FAQNotifier extends StateNotifier<FAQState> {
  FAQNotifier(this._repository) : super(const FAQState());

  final SupportRepository _repository;

  /// Load FAQ items.
  Future<void> loadFAQ() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final items = await _repository.getFAQItems();
      final categories = await _repository.getFAQCategories();

      state = state.copyWith(
        items: items,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Search FAQ.
  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(
        searchResults: [],
        searchQuery: '',
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true, searchQuery: query);

    try {
      final results = await _repository.searchFAQ(query);
      state = state.copyWith(
        searchResults: results,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle FAQ item expansion.
  void toggleItem(String itemId) {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isExpanded: !item.isExpanded);
        }
        return item;
      }).toList(),
    );
  }

  /// Clear search.
  void clearSearch() {
    state = state.copyWith(
      searchResults: [],
      searchQuery: '',
    );
  }
}

/// Provider for FAQ.
final faqProvider = StateNotifierProvider<FAQNotifier, FAQState>((ref) {
  final repository = ref.watch(supportRepositoryProvider);
  return FAQNotifier(repository);
});

/// Provider for open tickets count.
final openTicketsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(supportRepositoryProvider);
  return repository.getOpenTicketsCount();
});

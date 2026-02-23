import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/faq_model.dart';
import '../data/models/support_ticket_model.dart';
import '../data/models/wallet_model.dart';
import '../data/repositories/profile_repository.dart';

/// Provider for profile repository.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Provider for user profile.
final userProfileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile();
});

/// Provider for wallet.
final walletProvider = FutureProvider.autoDispose<Wallet>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getWallet();
});

/// Provider for wallet transactions.
final walletTransactionsProvider =
    FutureProvider.autoDispose<List<WalletTransaction>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getTransactions();
});

/// Provider for payment methods.
final paymentMethodsProvider =
    FutureProvider.autoDispose<List<PaymentMethod>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getPaymentMethods();
});

/// Provider for referral.
final referralProvider = FutureProvider.autoDispose<Referral>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getReferral();
});

/// Provider for completed projects count.
final completedProjectsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCompletedProjectsCount();
});

/// Provider for app version.
final appVersionProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getAppVersion();
});

/// Notifier for profile updates.
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? city,
    String? state_,
    UserType? userType,
  }) async {
    try {
      final updated = await _repository.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
        city: city,
        state: state_,
        userType: userType,
      );
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadProfile();
  }
}

/// Provider for profile notifier.
final profileNotifierProvider =
    StateNotifierProvider.autoDispose<ProfileNotifier, AsyncValue<UserProfile>>(
        (ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

/// Notifier for wallet operations.
class WalletNotifier extends StateNotifier<AsyncValue<Wallet>> {
  final ProfileRepository _repository;

  WalletNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    state = const AsyncValue.loading();
    try {
      final wallet = await _repository.getWallet();
      state = AsyncValue.data(wallet);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> topUp(double amount) async {
    try {
      // ignore: deprecated_member_use_from_same_package
      final updated = await _repository.topUpWallet(amount);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _loadWallet();
  }
}

/// Provider for wallet notifier.
final walletNotifierProvider =
    StateNotifierProvider.autoDispose<WalletNotifier, AsyncValue<Wallet>>(
        (ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return WalletNotifier(repository);
});

// ============================================================
// Support Tickets Providers
// ============================================================

/// Provider for support tickets.
final supportTicketsProvider =
    FutureProvider.autoDispose<List<SupportTicket>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSupportTickets();
});

/// Provider for a single support ticket with responses.
final supportTicketProvider =
    FutureProvider.autoDispose.family<SupportTicket, String>((ref, ticketId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSupportTicket(ticketId);
});

/// Notifier for support ticket operations.
class SupportTicketNotifier extends StateNotifier<AsyncValue<List<SupportTicket>>> {
  final ProfileRepository _repository;

  SupportTicketNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    state = const AsyncValue.loading();
    try {
      final tickets = await _repository.getSupportTickets();
      state = AsyncValue.data(tickets);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Create a new support ticket.
  Future<SupportTicket?> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
  }) async {
    try {
      final ticket = await _repository.createSupportTicket(
        subject: subject,
        description: description,
        category: category,
      );

      // Refresh the list
      await _loadTickets();
      return ticket;
    } catch (e) {
      return null;
    }
  }

  /// Add a response to a ticket.
  Future<bool> addResponse({
    required String ticketId,
    required String message,
  }) async {
    try {
      await _repository.addTicketResponse(
        ticketId: ticketId,
        message: message,
      );

      // Refresh the list
      await _loadTickets();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Refresh tickets list.
  Future<void> refresh() async {
    await _loadTickets();
  }
}

/// Provider for support ticket notifier.
final supportTicketNotifierProvider =
    StateNotifierProvider.autoDispose<SupportTicketNotifier, AsyncValue<List<SupportTicket>>>(
        (ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return SupportTicketNotifier(repository);
});

// ============================================================
// FAQ Providers
// ============================================================

/// Provider for FAQs list.
final faqsProvider = FutureProvider.autoDispose<List<FAQ>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFAQs();
});

/// Provider for FAQs filtered by category.
final faqsByCategoryProvider =
    FutureProvider.autoDispose.family<List<FAQ>, FAQCategory?>((ref, category) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFAQs(category: category);
});

/// Provider for grouped FAQs.
final groupedFAQsProvider =
    FutureProvider.autoDispose<List<GroupedFAQs>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getGroupedFAQs();
});

/// Provider for FAQ search results.
final faqSearchProvider =
    FutureProvider.autoDispose.family<List<FAQ>, String>((ref, query) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchFAQs(query);
});

/// State class for FAQ filter state.
class FAQFilterState {
  /// Currently selected category (null means all).
  final FAQCategory? selectedCategory;

  /// Current search query.
  final String searchQuery;

  const FAQFilterState({
    this.selectedCategory,
    this.searchQuery = '',
  });

  /// Create a copy with modified fields.
  FAQFilterState copyWith({
    FAQCategory? selectedCategory,
    String? searchQuery,
    bool clearCategory = false,
  }) {
    return FAQFilterState(
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Notifier for FAQ filter and search state.
class FAQFilterNotifier extends StateNotifier<FAQFilterState> {
  FAQFilterNotifier() : super(const FAQFilterState());

  /// Set the selected category.
  void setCategory(FAQCategory? category) {
    state = state.copyWith(
      selectedCategory: category,
      clearCategory: category == null,
    );
  }

  /// Set the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clear all filters.
  void clearFilters() {
    state = const FAQFilterState();
  }
}

/// Provider for FAQ filter notifier.
final faqFilterProvider =
    StateNotifierProvider.autoDispose<FAQFilterNotifier, FAQFilterState>((ref) {
  return FAQFilterNotifier();
});

/// Provider for filtered and searched FAQs based on filter state.
final filteredFAQsProvider = FutureProvider.autoDispose<List<FAQ>>((ref) async {
  final filterState = ref.watch(faqFilterProvider);
  final repository = ref.watch(profileRepositoryProvider);

  // Get FAQs based on category filter
  List<FAQ> faqs;
  if (filterState.selectedCategory != null) {
    faqs = await repository.getFAQs(category: filterState.selectedCategory);
  } else {
    faqs = await repository.getFAQs();
  }

  // Apply search filter if query is not empty
  if (filterState.searchQuery.isNotEmpty) {
    faqs = faqs.search(filterState.searchQuery);
  }

  return faqs;
});

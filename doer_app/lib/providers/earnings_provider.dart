/// Provider for the Earnings tab, managing wallet data and transactions.
///
/// Fetches wallet balance, transactions, and monthly summaries from the
/// [DoerWalletRepository] and exposes them via [EarningsState].
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/wallet_model.dart';
import '../data/repositories/wallet_repository.dart';

/// Immutable state for the Earnings screen.
class EarningsState {
  /// The doer's wallet, null until loaded.
  final WalletModel? wallet;

  /// Recent transactions list.
  final List<WalletTransaction> transactions;

  /// Monthly earnings breakdown (most recent first).
  final List<MonthlySummary> monthlySummaries;

  /// Whether data is currently being fetched.
  final bool isLoading;

  /// Error message if the last fetch failed.
  final String? error;

  /// The currently active transaction type filter (null = all).
  final String? activeFilter;

  const EarningsState({
    this.wallet,
    this.transactions = const [],
    this.monthlySummaries = const [],
    this.isLoading = false,
    this.error,
    this.activeFilter,
  });

  EarningsState copyWith({
    WalletModel? wallet,
    List<WalletTransaction>? transactions,
    List<MonthlySummary>? monthlySummaries,
    bool? isLoading,
    String? error,
    String? activeFilter,
    bool clearError = false,
    bool clearFilter = false,
  }) {
    return EarningsState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      monthlySummaries: monthlySummaries ?? this.monthlySummaries,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      activeFilter: clearFilter ? null : (activeFilter ?? this.activeFilter),
    );
  }

  /// Transactions filtered by the active filter.
  List<WalletTransaction> get filteredTransactions {
    if (activeFilter == null) return transactions;
    return transactions
        .where((t) => t.transactionType.value == activeFilter)
        .toList();
  }

  /// Total earned this month from monthly summaries.
  double get thisMonthEarnings {
    if (monthlySummaries.isEmpty) return 0;
    final now = DateTime.now();
    final current = monthlySummaries.where(
      (s) => s.month.year == now.year && s.month.month == now.month,
    );
    return current.isEmpty ? 0 : current.first.totalEarnings;
  }
}

/// Notifier that manages earnings data fetching and state.
class EarningsNotifier extends Notifier<EarningsState> {
  @override
  EarningsState build() {
    // Defer load to avoid circular provider reads.
    Future.microtask(() => _loadAll());
    return const EarningsState(isLoading: true);
  }

  DoerWalletRepository get _repo {
    try {
      return ref.read(doerWalletRepositoryProvider);
    } catch (_) {
      return DoerWalletRepository();
    }
  }

  /// Loads wallet, transactions, and monthly summaries in parallel.
  Future<void> _loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final results = await Future.wait([
        _repo.getWallet(),
        _repo.getTransactions(limit: 50),
        _repo.getMonthlyEarnings(),
      ]);

      state = state.copyWith(
        wallet: results[0] as WalletModel?,
        transactions: results[1] as List<WalletTransaction>,
        monthlySummaries: results[2] as List<MonthlySummary>,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsNotifier._loadAll error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load earnings data',
      );
    }
  }

  /// Refreshes all earnings data.
  Future<void> refresh() => _loadAll();

  /// Sets the transaction type filter.
  void setFilter(String? filter) {
    if (filter == null) {
      state = state.copyWith(clearFilter: true);
    } else {
      state = state.copyWith(activeFilter: filter);
    }
  }
}

/// Global provider for earnings state.
final earningsProvider =
    NotifierProvider<EarningsNotifier, EarningsState>(() {
  return EarningsNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/earnings_model.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/earnings_repository.dart';

/// Provider for earnings repository.
final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  return EarningsRepository();
});

// ==================== EARNINGS STATE ====================

/// State for earnings dashboard.
class EarningsState {
  const EarningsState({
    this.summary,
    this.chartData = const [],
    this.commissionBreakdown = const [],
    this.performanceMetrics,
    this.isLoading = false,
    this.error,
    this.selectedPeriod = EarningsPeriod.monthly,
  });

  final EarningsSummary? summary;
  final List<EarningsDataPoint> chartData;
  final List<CommissionBreakdown> commissionBreakdown;
  final PerformanceMetrics? performanceMetrics;
  final bool isLoading;
  final String? error;
  final EarningsPeriod selectedPeriod;

  EarningsState copyWith({
    EarningsSummary? summary,
    List<EarningsDataPoint>? chartData,
    List<CommissionBreakdown>? commissionBreakdown,
    PerformanceMetrics? performanceMetrics,
    bool? isLoading,
    String? error,
    EarningsPeriod? selectedPeriod,
  }) {
    return EarningsState(
      summary: summary ?? this.summary,
      chartData: chartData ?? this.chartData,
      commissionBreakdown: commissionBreakdown ?? this.commissionBreakdown,
      performanceMetrics: performanceMetrics ?? this.performanceMetrics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

/// Notifier for earnings state.
class EarningsNotifier extends StateNotifier<EarningsState> {
  EarningsNotifier(this._repository) : super(const EarningsState()) {
    loadAllData();
  }

  final EarningsRepository _repository;

  /// Load all earnings data.
  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true);

    try {
      final results = await Future.wait([
        _repository.getEarningsSummary(period: state.selectedPeriod),
        _repository.getEarningsChartData(period: state.selectedPeriod),
        _repository.getCommissionBreakdown(period: state.selectedPeriod),
        _repository.getPerformanceMetrics(),
      ]);

      state = state.copyWith(
        summary: results[0] as EarningsSummary,
        chartData: results[1] as List<EarningsDataPoint>,
        commissionBreakdown: results[2] as List<CommissionBreakdown>,
        performanceMetrics: results[3] as PerformanceMetrics,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load earnings: $e',
      );
    }
  }

  /// Refresh data.
  Future<void> refresh() async {
    await loadAllData();
  }

  /// Change period.
  void changePeriod(EarningsPeriod period) {
    state = state.copyWith(selectedPeriod: period);
    loadAllData();
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for earnings.
final earningsProvider =
    StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  final repository = ref.watch(earningsRepositoryProvider);
  return EarningsNotifier(repository);
});

// ==================== TRANSACTIONS STATE ====================

/// State for transactions.
class TransactionsState {
  const TransactionsState({
    this.transactions = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.filter = const TransactionFilter(),
    this.isWithdrawing = false,
  });

  final List<TransactionModel> transactions;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final TransactionFilter filter;
  final bool isWithdrawing;

  TransactionsState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    bool? hasMore,
    String? error,
    TransactionFilter? filter,
    bool? isWithdrawing,
  }) {
    return TransactionsState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      filter: filter ?? this.filter,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
    );
  }

  /// Get grouped transactions by date.
  Map<String, List<TransactionModel>> get groupedTransactions {
    final grouped = <String, List<TransactionModel>>{};
    for (final tx in transactions) {
      grouped.putIfAbsent(tx.formattedDate, () => []).add(tx);
    }
    return grouped;
  }

  /// Get total earnings.
  double get totalCredits {
    return transactions
        .where((t) => t.type.isCredit && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get total debits.
  double get totalDebits {
    return transactions
        .where((t) => !t.type.isCredit && t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

/// Notifier for transactions.
class TransactionsNotifier extends StateNotifier<TransactionsState> {
  TransactionsNotifier(this._repository) : super(const TransactionsState()) {
    loadTransactions();
  }

  final EarningsRepository _repository;
  static const _pageSize = 20;

  /// Load transactions.
  Future<void> loadTransactions({bool refresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final transactions = await _repository.getTransactions(
        limit: _pageSize,
        offset: refresh ? 0 : state.transactions.length,
        filter: state.filter,
      );

      state = state.copyWith(
        transactions:
            refresh ? transactions : [...state.transactions, ...transactions],
        isLoading: false,
        hasMore: transactions.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load transactions: $e',
      );
    }
  }

  /// Refresh transactions.
  Future<void> refresh() async {
    await loadTransactions(refresh: true);
  }

  /// Load more transactions.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadTransactions();
  }

  /// Update filter.
  void updateFilter(TransactionFilter filter) {
    state = state.copyWith(filter: filter);
    loadTransactions(refresh: true);
  }

  /// Clear filter.
  void clearFilter() {
    state = state.copyWith(filter: const TransactionFilter());
    loadTransactions(refresh: true);
  }

  /// Request withdrawal.
  Future<TransactionModel?> requestWithdrawal({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    state = state.copyWith(isWithdrawing: true);

    try {
      final transaction = await _repository.requestWithdrawal(
        amount: amount,
        paymentMethod: paymentMethod,
        paymentDetails: paymentDetails,
      );

      if (transaction != null) {
        state = state.copyWith(
          transactions: [transaction, ...state.transactions],
          isWithdrawing: false,
        );
      } else {
        state = state.copyWith(isWithdrawing: false);
      }

      return transaction;
    } catch (e) {
      state = state.copyWith(
        isWithdrawing: false,
        error: 'Failed to request withdrawal: $e',
      );
      return null;
    }
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for transactions.
final transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, TransactionsState>((ref) {
  final repository = ref.watch(earningsRepositoryProvider);
  return TransactionsNotifier(repository);
});

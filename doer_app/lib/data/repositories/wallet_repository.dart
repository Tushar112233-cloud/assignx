import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_client.dart';
import '../models/wallet_model.dart';

/// Repository for wallet and earnings operations.
///
/// Handles fetching wallet balance, transactions, earnings history,
/// and withdrawal requests.
class DoerWalletRepository {
  DoerWalletRepository();

  /// Fetches the doer's wallet.
  Future<WalletModel?> getWallet() async {
    try {
      final response = await ApiClient.get('/wallets/me');
      if (response == null) return null;
      final data = response is Map<String, dynamic>
          ? (response['wallet'] as Map<String, dynamic>? ?? response)
          : response as Map<String, dynamic>;
      return WalletModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getWallet error: $e');
      }
      rethrow;
    }
  }

  /// Fetches wallet transactions.
  Future<List<WalletTransaction>> getTransactions({
    int limit = 50,
    int offset = 0,
    String? transactionType,
  }) async {
    try {
      final page = (offset ~/ limit) + 1;
      var path = '/wallets/me/transactions?limit=$limit&page=$page';
      if (transactionType != null) {
        path += '&type=$transactionType';
      }

      final response = await ApiClient.get(path);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['transactions'] as List? ?? [];

      return list
          .map((json) => WalletTransaction.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getTransactions error: $e');
      }
      rethrow;
    }
  }

  /// Fetches earnings history (credits from completed projects).
  Future<List<EarningsRecord>> getEarningsHistory({
    int limit = 50,
  }) async {
    try {
      final response = await ApiClient.get('/wallets/me/earnings?limit=$limit');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['earnings'] as List? ?? [];

      return list
          .map((json) => EarningsRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getEarningsHistory error: $e');
      }
      rethrow;
    }
  }

  /// Fetches pending earnings (projects delivered but not yet paid).
  Future<double> getPendingEarnings() async {
    try {
      final response = await ApiClient.get('/wallets/me/pending-earnings');
      if (response is Map<String, dynamic>) {
        return (response['amount'] as num?)?.toDouble() ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getPendingEarnings error: $e');
      }
      return 0.0;
    }
  }

  /// Requests a withdrawal.
  Future<WithdrawalRequest?> requestWithdrawal({
    required double amount,
    required String withdrawalMethod,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.post('/wallets/me/withdraw', {
        'amount': amount,
        'paymentMethod': withdrawalMethod,
        if (notes != null) 'notes': notes,
      });

      if (response == null) return null;
      return WithdrawalRequest.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.requestWithdrawal error: $e');
      }
      rethrow;
    }
  }

  /// Fetches withdrawal requests.
  Future<List<WithdrawalRequest>> getWithdrawalRequests({
    String? status,
    int limit = 20,
  }) async {
    try {
      var path = '/wallets/me/withdrawals?limit=$limit';
      if (status != null) {
        path += '&status=$status';
      }

      final response = await ApiClient.get(path);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['withdrawals'] as List? ?? [];

      return list
          .map((json) => WithdrawalRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getWithdrawalRequests error: $e');
      }
      rethrow;
    }
  }

  /// Gets monthly earnings summary.
  Future<List<MonthlySummary>> getMonthlyEarnings({int months = 6}) async {
    try {
      final response = await ApiClient.get('/wallets/earnings/monthly');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['earnings'] as List? ?? [];

      return list
          .map((json) => MonthlySummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getMonthlyEarnings error: $e');
      }
      rethrow;
    }
  }
}

/// Provider for the doer wallet repository.
final doerWalletRepositoryProvider = Provider<DoerWalletRepository>((ref) {
  return DoerWalletRepository();
});

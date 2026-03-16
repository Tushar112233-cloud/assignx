import 'package:flutter/foundation.dart';

import '../../../../core/api/api_client.dart';
import '../models/earnings_model.dart';
import '../models/transaction_model.dart';

/// Repository for earnings and transaction operations.
class EarningsRepository {
  EarningsRepository();

  // ==================== EARNINGS ====================

  /// Get earnings summary.
  Future<EarningsSummary> getEarningsSummary({
    EarningsPeriod period = EarningsPeriod.monthly,
  }) async {
    try {
      final response = await ApiClient.get(
        '/supervisor/earnings/summary?period=${period.id}',
      );
      return EarningsSummary.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getEarningsSummary error: $e');
      }
      rethrow;
    }
  }

  /// Get earnings chart data.
  Future<List<EarningsDataPoint>> getEarningsChartData({
    EarningsPeriod period = EarningsPeriod.monthly,
    int limit = 12,
  }) async {
    try {
      final response = await ApiClient.get(
        '/supervisor/earnings/chart?period=${period.id}&limit=$limit',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['data'] as List? ?? [];

      return list
          .map((json) => EarningsDataPoint.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getEarningsChartData error: $e');
      }
      rethrow;
    }
  }

  /// Get commission breakdown.
  Future<List<CommissionBreakdown>> getCommissionBreakdown({
    EarningsPeriod period = EarningsPeriod.monthly,
  }) async {
    try {
      final response = await ApiClient.get(
        '/supervisor/earnings/commissions?period=${period.id}',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['commissions'] as List? ?? [];

      return list
          .map((json) => CommissionBreakdown.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getCommissionBreakdown error: $e');
      }
      rethrow;
    }
  }

  /// Get performance metrics.
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    try {
      final response = await ApiClient.get('/supervisor/earnings/performance');
      return PerformanceMetrics.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getPerformanceMetrics error: $e');
      }
      rethrow;
    }
  }

  // ==================== TRANSACTIONS ====================

  /// Get transactions.
  Future<List<TransactionModel>> getTransactions({
    int limit = 20,
    int offset = 0,
    TransactionFilter? filter,
  }) async {
    try {
      final params = <String, String>{
        'limit': '$limit',
        'page': '${(offset ~/ limit) + 1}',
      };
      if (filter?.types != null && filter!.types!.isNotEmpty) {
        params['type'] = filter.types!.map((t) => t.id).join(',');
      }
      if (filter?.statuses != null && filter!.statuses!.isNotEmpty) {
        params['statuses'] = filter.statuses!.map((s) => s.id).join(',');
      }
      if (filter?.startDate != null) {
        params['startDate'] = filter!.startDate!.toIso8601String();
      }
      if (filter?.endDate != null) {
        params['endDate'] = filter!.endDate!.toIso8601String();
      }

      final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
      final response = await ApiClient.get('/wallets/me/transactions?$query');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['transactions'] as List? ?? [];

      return list
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getTransactions error: $e');
      }
      rethrow;
    }
  }

  /// Get transaction by ID.
  Future<TransactionModel?> getTransaction(String id) async {
    try {
      final response = await ApiClient.get('/wallets/me/transactions/$id');
      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getTransaction error: $e');
      }
      rethrow;
    }
  }

  /// Request withdrawal.
  Future<TransactionModel?> requestWithdrawal({
    required double amount,
    required String paymentMethod,
    Map<String, dynamic>? paymentDetails,
  }) async {
    try {
      final response = await ApiClient.post('/wallets/me/withdraw', {
        'amount': amount,
        'paymentMethod': paymentMethod,
        if (paymentDetails != null) 'paymentDetails': paymentDetails,
      });

      return TransactionModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.requestWithdrawal error: $e');
      }
      rethrow;
    }
  }

}

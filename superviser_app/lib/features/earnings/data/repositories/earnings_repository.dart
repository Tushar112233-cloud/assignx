import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/earnings_model.dart';
import '../models/transaction_model.dart';

/// Repository for earnings and transaction operations.
class EarningsRepository {
  EarningsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  // ==================== EARNINGS ====================

  /// Get earnings summary.
  Future<EarningsSummary> getEarningsSummary({
    EarningsPeriod period = EarningsPeriod.monthly,
  }) async {
    try {
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client.rpc('get_earnings_summary', params: {
        'user_id': userId,
        'period': period.id,
      });

      return EarningsSummary.fromJson(response);
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
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client.rpc('get_earnings_chart', params: {
        'user_id': userId,
        'period': period.id,
        'limit_count': limit,
      });

      return (response as List)
          .map((json) => EarningsDataPoint.fromJson(json))
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
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client.rpc('get_commission_breakdown', params: {
        'user_id': userId,
        'period': period.id,
      });

      return (response as List)
          .map((json) => CommissionBreakdown.fromJson(json))
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
      final userId = getCurrentUserId();
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client.rpc('get_performance_metrics', params: {
        'user_id': userId,
      });

      return PerformanceMetrics.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.getPerformanceMetrics error: $e');
      }
      rethrow;
    }
  }

  // ==================== WALLET ====================

  /// Get wallet ID for current user.
  Future<String?> _getWalletId() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    try {
      final response = await _client
          .from('wallets')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();
      return response?['id'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository._getWalletId error: $e');
      }
      return null;
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
      final walletId = await _getWalletId();
      if (walletId == null) throw Exception('Wallet not found');

      var query = _client
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', walletId);

      if (filter?.types != null && filter!.types!.isNotEmpty) {
        query = query.inFilter(
            'transaction_type', filter.types!.map((t) => t.id).toList());
      }
      if (filter?.statuses != null && filter!.statuses!.isNotEmpty) {
        query = query.inFilter(
            'status', filter.statuses!.map((s) => s.id).toList());
      }
      if (filter?.startDate != null) {
        query = query.gte('created_at', filter!.startDate!.toIso8601String());
      }
      if (filter?.endDate != null) {
        query = query.lte('created_at', filter!.endDate!.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
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
      final response = await _client
          .from('wallet_transactions')
          .select()
          .eq('id', id)
          .single();

      return TransactionModel.fromJson(response);
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
      final walletId = await _getWalletId();
      if (walletId == null) return null;

      final response = await _client
          .from('wallet_transactions')
          .insert({
            'wallet_id': walletId,
            'transaction_type': TransactionType.withdrawal.id,
            'amount': amount,
            'status': TransactionStatus.pending.id,
            'description': 'Withdrawal request',
            'notes': paymentMethod,
          })
          .select()
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('EarningsRepository.requestWithdrawal error: $e');
      }
      rethrow;
    }
  }

}

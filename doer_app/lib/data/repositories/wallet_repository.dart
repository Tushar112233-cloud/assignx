import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/wallet_model.dart';

/// Repository for wallet and earnings operations.
///
/// Handles fetching wallet balance, transactions, earnings history,
/// and withdrawal requests.
class DoerWalletRepository {
  DoerWalletRepository(this._client);

  final SupabaseClient _client;

  /// Gets the current user's ID.
  String? get _userId => _client.auth.currentUser?.id;

  /// Fetches the doer's wallet.
  Future<WalletModel?> getWallet() async {
    try {
      if (_userId == null) return null;
      final response = await _client
          .from('wallets')
          .select()
          .eq('profile_id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return WalletModel.fromJson(response);
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
      // First get the wallet ID
      final wallet = await getWallet();
      if (wallet == null) return [];

      var query = _client
          .from('wallet_transactions')
          .select()
          .eq('wallet_id', wallet.id);

      if (transactionType != null) {
        query = query.eq('transaction_type', transactionType);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
          .map((json) => WalletTransaction.fromJson(json))
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
      final wallet = await getWallet();
      if (wallet == null) return [];

      final response = await _client
          .from('wallet_transactions')
          .select('''
            *,
            project:projects!reference_id(id, title, project_number)
          ''')
          .eq('wallet_id', wallet.id)
          .eq('transaction_type', 'credit')
          .eq('reference_type', 'project_payment')
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => EarningsRecord.fromJson(json))
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
      // Look up doer ID from profile ID
      if (_userId == null) return 0.0;
      final doerResponse = await _client
          .from('doers')
          .select('id')
          .eq('profile_id', _userId!)
          .maybeSingle();
      final doerId = doerResponse?['id'] as String?;
      if (doerId == null) return 0.0;

      final response = await _client
          .from('projects')
          .select('doer_payout')
          .eq('doer_id', doerId)
          .inFilter('status', ['delivered', 'completed', 'auto_approved']);

      double total = 0.0;
      for (final row in response as List) {
        total += (row['doer_payout'] as num?)?.toDouble() ?? 0.0;
      }
      return total;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('DoerWalletRepository.getPendingEarnings error: $e');
      }
      rethrow;
    }
  }

  /// Requests a withdrawal.
  Future<WithdrawalRequest?> requestWithdrawal({
    required double amount,
    required String withdrawalMethod,
    String? notes,
  }) async {
    try {
      final wallet = await getWallet();
      if (wallet == null) throw Exception('Wallet not found');
      if (amount > wallet.availableBalance) {
        throw Exception('Insufficient balance');
      }

      final response = await _client.from('withdrawal_requests').insert({
        'wallet_id': wallet.id,
        'amount': amount,
        'withdrawal_method': withdrawalMethod,
        'status': 'pending',
        'notes': notes,
        'requested_at': DateTime.now().toIso8601String(),
      }).select().single();

      return WithdrawalRequest.fromJson(response);
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
      final wallet = await getWallet();
      if (wallet == null) return [];

      var query = _client
          .from('withdrawal_requests')
          .select()
          .eq('wallet_id', wallet.id);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('requested_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => WithdrawalRequest.fromJson(json))
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
      final wallet = await getWallet();
      if (wallet == null) return [];

      // Get earnings grouped by month
      final response = await _client.rpc('get_monthly_earnings', params: {
        'p_wallet_id': wallet.id,
        'p_months': months,
      });

      return (response as List)
          .map((json) => MonthlySummary.fromJson(json))
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
  return DoerWalletRepository(SupabaseConfig.client);
});

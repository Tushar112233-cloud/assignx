/// Wallet models for the Doer application.
///
/// These models match the Supabase wallets and wallet_transactions tables.
library;

/// Wallet model representing the doer's wallet.
class WalletModel {
  final String id;
  final String profileId;
  final double balance;
  final double pendingBalance;
  final double totalEarned;
  final double totalWithdrawn;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Available balance for withdrawal (balance - pendingBalance).
  double get availableBalance => balance - pendingBalance;

  /// Formatted balance string.
  String get formattedBalance => '₹${balance.toStringAsFixed(2)}';

  /// Formatted available balance string.
  String get formattedAvailable => '₹${availableBalance.toStringAsFixed(2)}';

  /// Formatted pending balance string.
  String get formattedPending => '₹${pendingBalance.toStringAsFixed(2)}';

  /// Formatted total earnings string.
  String get formattedTotalEarned => '₹${totalEarned.toStringAsFixed(0)}';

  const WalletModel({
    required this.id,
    required this.profileId,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalWithdrawn = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      pendingBalance: (json['pending_balance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (json['total_earned'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (json['total_withdrawn'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}

/// Wallet transaction model.
class WalletTransaction {
  final String id;
  final String walletId;
  final TransactionType transactionType;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? referenceType;
  final String? referenceId;
  final String? description;
  final String? notes;
  final String status;
  final DateTime createdAt;

  /// Formatted amount with sign.
  String get formattedAmount {
    final sign = transactionType == TransactionType.credit ? '+' : '-';
    return '$sign₹${amount.toStringAsFixed(2)}';
  }

  /// Whether this is an incoming transaction.
  bool get isCredit => transactionType == TransactionType.credit;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.transactionType,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    this.description,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      transactionType: TransactionType.fromString(
        json['transaction_type'] as String? ?? 'credit',
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balance_before'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0.0,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Transaction type enum.
enum TransactionType {
  credit('credit'),
  debit('debit'),
  hold('hold'),
  release('release');

  final String value;
  const TransactionType(this.value);

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TransactionType.credit,
    );
  }
}

/// Earnings record for a completed project.
class EarningsRecord {
  final String id;
  final String? projectId;
  final String? projectTitle;
  final String? projectNumber;
  final double amount;
  final DateTime earnedAt;

  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  const EarningsRecord({
    required this.id,
    this.projectId,
    this.projectTitle,
    this.projectNumber,
    required this.amount,
    required this.earnedAt,
  });

  factory EarningsRecord.fromJson(Map<String, dynamic> json) {
    // Handle nested project
    String? projectTitle;
    String? projectNumber;
    String? projectId;
    if (json['project'] != null && json['project'] is Map) {
      projectTitle = json['project']['title'] as String?;
      projectNumber = json['project']['project_number'] as String?;
      projectId = json['project']['id'] as String?;
    }

    return EarningsRecord(
      id: json['id'] as String,
      projectId: projectId ?? json['reference_id'] as String?,
      projectTitle: projectTitle,
      projectNumber: projectNumber,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      earnedAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Withdrawal request model.
class WithdrawalRequest {
  final String id;
  final String walletId;
  final double amount;
  final String withdrawalMethod;
  final WithdrawalStatus status;
  final String? notes;
  final String? rejectionReason;
  final DateTime requestedAt;
  final DateTime? processedAt;

  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';

  const WithdrawalRequest({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.withdrawalMethod,
    required this.status,
    this.notes,
    this.rejectionReason,
    required this.requestedAt,
    this.processedAt,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      withdrawalMethod: json['withdrawal_method'] as String? ?? 'bank_transfer',
      status: WithdrawalStatus.fromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      requestedAt: DateTime.parse(json['requested_at'] as String),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
    );
  }
}

/// Withdrawal status enum.
enum WithdrawalStatus {
  pending('pending'),
  processing('processing'),
  completed('completed'),
  rejected('rejected'),
  cancelled('cancelled');

  final String value;
  const WithdrawalStatus(this.value);

  static WithdrawalStatus fromString(String value) {
    return WithdrawalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => WithdrawalStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case WithdrawalStatus.pending:
        return 'Pending';
      case WithdrawalStatus.processing:
        return 'Processing';
      case WithdrawalStatus.completed:
        return 'Completed';
      case WithdrawalStatus.rejected:
        return 'Rejected';
      case WithdrawalStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Monthly earnings summary.
class MonthlySummary {
  final DateTime month;
  final double totalEarnings;
  final int projectCount;

  String get formattedEarnings => '₹${totalEarnings.toStringAsFixed(0)}';

  String get monthName {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month.month - 1];
  }

  const MonthlySummary({
    required this.month,
    required this.totalEarnings,
    required this.projectCount,
  });

  factory MonthlySummary.fromJson(Map<String, dynamic> json) {
    return MonthlySummary(
      month: DateTime.parse(json['month'] as String),
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      projectCount: json['project_count'] as int? ?? 0,
    );
  }
}

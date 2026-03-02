/// Wallet models for the Doer application.
///
/// These models match the Supabase wallets and wallet_transactions tables.
library;

/// Wallet model representing the doer's wallet.
class WalletModel {
  final String id;
  final String profileId;
  final double balance;
  final double lockedAmount;
  final double totalCredited;
  final double totalWithdrawn;
  final DateTime createdAt;
  final DateTime? updatedAt;

  /// Available balance for withdrawal (balance - lockedAmount).
  double get availableBalance => balance - lockedAmount;

  /// Formatted balance string.
  String get formattedBalance => '₹${balance.toStringAsFixed(2)}';

  /// Formatted available balance string.
  String get formattedAvailable => '₹${availableBalance.toStringAsFixed(2)}';

  /// Formatted locked amount string.
  String get formattedLocked => '₹${lockedAmount.toStringAsFixed(2)}';

  /// Formatted total credited string.
  String get formattedTotalCredited => '₹${totalCredited.toStringAsFixed(0)}';

  const WalletModel({
    required this.id,
    required this.profileId,
    this.balance = 0.0,
    this.lockedAmount = 0.0,
    this.totalCredited = 0.0,
    this.totalWithdrawn = 0.0,
    required this.createdAt,
    this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    // Handle profileId which may be a populated Mongoose object.
    String profileId = '';
    final rawProfileId = json['profile_id'] ?? json['profileId'];
    if (rawProfileId is String) {
      profileId = rawProfileId;
    } else if (rawProfileId is Map<String, dynamic>) {
      profileId = (rawProfileId['_id'] ?? rawProfileId['id'] ?? '').toString();
    }

    return WalletModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      profileId: profileId,
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      lockedAmount: ((json['locked_amount'] ?? json['lockedAmount']) as num?)?.toDouble() ?? 0.0,
      totalCredited: ((json['total_credited'] ?? json['totalCredited']) as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: ((json['total_withdrawn'] ?? json['totalWithdrawn']) as num?)?.toDouble() ?? 0.0,
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updated_at'] ?? json['updatedAt']),
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
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      walletId: (json['wallet_id'] ?? json['walletId'] ?? '').toString(),
      transactionType: TransactionType.fromString(
        (json['transaction_type'] ?? json['transactionType'] ?? 'credit').toString(),
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: ((json['balance_before'] ?? json['balanceBefore']) as num?)?.toDouble() ?? 0.0,
      balanceAfter: ((json['balance_after'] ?? json['balanceAfter']) as num?)?.toDouble() ?? 0.0,
      referenceType: json['reference_type'] as String? ?? json['referenceType'] as String?,
      referenceId: json['reference_id'] as String? ?? json['referenceId'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'completed',
      createdAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
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
    // Handle nested project (may be a populated Mongoose object).
    String? projectTitle;
    String? projectNumber;
    String? projectId;
    final project = json['project'];
    if (project != null && project is Map) {
      projectTitle = project['title'] as String?;
      projectNumber = (project['project_number'] ?? project['projectNumber']) as String?;
      projectId = (project['_id'] ?? project['id'])?.toString();
    }

    return EarningsRecord(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      projectId: projectId ?? (json['reference_id'] ?? json['referenceId']) as String?,
      projectTitle: projectTitle,
      projectNumber: projectNumber,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      earnedAt: DateTime.tryParse((json['created_at'] ?? json['createdAt'] ?? '').toString()) ?? DateTime.now(),
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
    DateTime? _parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return WithdrawalRequest(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      walletId: (json['profile_id'] ?? json['profileId'] ?? json['wallet_id'] ?? json['walletId'] ?? '').toString(),
      amount: ((json['requested_amount'] ?? json['requestedAmount']) as num?)?.toDouble() ??
              (json['amount'] as num?)?.toDouble() ?? 0.0,
      withdrawalMethod: (json['withdrawal_method'] ?? json['withdrawalMethod'] ?? 'bank_transfer').toString(),
      status: WithdrawalStatus.fromString((json['status'] ?? 'pending').toString()),
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String? ?? json['rejectionReason'] as String?,
      requestedAt: _parseDate(json['created_at'] ?? json['createdAt'] ?? json['requested_at'] ?? json['requestedAt']) ?? DateTime.now(),
      processedAt: _parseDate(json['processed_at'] ?? json['processedAt']),
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
      month: DateTime.tryParse((json['month'] ?? '').toString()) ?? DateTime.now(),
      totalEarnings: ((json['total_earnings'] ?? json['totalEarnings']) as num?)?.toDouble() ?? 0.0,
      projectCount: (json['project_count'] ?? json['projectCount']) as int? ?? 0,
    );
  }
}

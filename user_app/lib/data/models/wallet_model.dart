import 'package:flutter/material.dart';

/// Transaction type enum matching database wallet_transaction_type.
enum TransactionType {
  credit('Credit', Icons.add_circle_outline, Color(0xFF22C55E)),
  debit('Debit', Icons.remove_circle_outline, Color(0xFFEF4444)),
  refund('Refund', Icons.replay, Color(0xFF3B82F6)),
  withdrawal('Withdrawal', Icons.arrow_downward, Color(0xFFEF4444)),
  topUp('Top Up', Icons.account_balance_wallet, Color(0xFF22C55E)),
  projectPayment('Project Payment', Icons.payment, Color(0xFFEF4444)),
  projectEarning('Project Earning', Icons.monetization_on, Color(0xFF22C55E)),
  commission('Commission', Icons.percent, Color(0xFFF59E0B)),
  bonus('Bonus', Icons.card_giftcard, Color(0xFF22C55E)),
  penalty('Penalty', Icons.warning, Color(0xFFEF4444)),
  reversal('Reversal', Icons.undo, Color(0xFF6B7280));

  final String label;
  final IconData icon;
  final Color color;

  const TransactionType(this.label, this.icon, this.color);

  bool get isCredit =>
      this == TransactionType.credit ||
      this == TransactionType.refund ||
      this == TransactionType.topUp ||
      this == TransactionType.projectEarning ||
      this == TransactionType.bonus ||
      this == TransactionType.reversal;

  String get dbValue {
    switch (this) {
      case TransactionType.topUp:
        return 'top_up';
      case TransactionType.projectPayment:
        return 'project_payment';
      case TransactionType.projectEarning:
        return 'project_earning';
      default:
        return name;
    }
  }

  static TransactionType fromDbValue(String? value) {
    switch (value) {
      case 'credit':
        return TransactionType.credit;
      case 'debit':
        return TransactionType.debit;
      case 'refund':
        return TransactionType.refund;
      case 'withdrawal':
        return TransactionType.withdrawal;
      case 'top_up':
      case 'topUp':
        return TransactionType.topUp;
      case 'project_payment':
      case 'projectPayment':
        return TransactionType.projectPayment;
      case 'project_earning':
      case 'projectEarning':
        return TransactionType.projectEarning;
      case 'commission':
        return TransactionType.commission;
      case 'bonus':
        return TransactionType.bonus;
      case 'penalty':
        return TransactionType.penalty;
      case 'reversal':
        return TransactionType.reversal;
      default:
        return TransactionType.debit;
    }
  }
}


/// Transaction status enum.
enum TransactionStatus {
  pending('Pending'),
  completed('Completed'),
  failed('Failed'),
  cancelled('Cancelled'),
  processing('Processing');

  final String label;
  const TransactionStatus(this.label);

  static TransactionStatus fromDbValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      case 'processing':
        return TransactionStatus.processing;
      default:
        return TransactionStatus.completed;
    }
  }
}

/// Wallet model for user balance and transactions.
class Wallet {
  final String id;
  final String profileId;
  final double balance;
  final String currency;
  final double totalCredited;
  final double totalDebited;
  final double totalWithdrawn;
  final double lockedAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wallet({
    this.id = '',
    required this.profileId,
    this.balance = 0,
    this.currency = 'INR',
    this.totalCredited = 0,
    this.totalDebited = 0,
    this.totalWithdrawn = 0,
    this.lockedAmount = 0,
    DateTime? createdAt,
    required this.updatedAt,
  }) : createdAt = createdAt ?? updatedAt;

  String get formattedBalance => '₹${balance.toStringAsFixed(0)}';
  String get balanceString => '₹${balance.toStringAsFixed(2)}';
  String get lockedAmountString => '₹${lockedAmount.toStringAsFixed(2)}';
  double get availableBalance => balance - lockedAmount;
  String get availableBalanceString => '₹${availableBalance.toStringAsFixed(2)}';
  bool hasSufficientBalance(double amount) => availableBalance >= amount;

  String get currencySymbol {
    switch (currency) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return currency;
    }
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['id'] as String? ?? '',
      profileId: json['profile_id'] as String,
      balance: _parseDouble(json['balance']),
      currency: json['currency'] as String? ?? 'INR',
      totalCredited: _parseDouble(json['total_credited']),
      totalDebited: _parseDouble(json['total_debited']),
      totalWithdrawn: _parseDouble(json['total_withdrawn']),
      lockedAmount: _parseDouble(json['locked_amount']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'balance': balance,
      'currency': currency,
      'total_credited': totalCredited,
      'total_debited': totalDebited,
      'total_withdrawn': totalWithdrawn,
      'locked_amount': lockedAmount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Wallet copyWith({
    String? id,
    String? profileId,
    double? balance,
    String? currency,
    double? totalCredited,
    double? totalDebited,
    double? totalWithdrawn,
    double? lockedAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      totalCredited: totalCredited ?? this.totalCredited,
      totalDebited: totalDebited ?? this.totalDebited,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      lockedAmount: lockedAmount ?? this.lockedAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}


/// Wallet transaction model.
class WalletTransaction {
  final String id;
  final String walletId;
  final TransactionType type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String? referenceType;
  final String? referenceId;
  final String description;
  final String? notes;
  final TransactionStatus status;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    required this.description,
    this.notes,
    this.status = TransactionStatus.completed,
    required this.createdAt,
  });

  String get amountString {
    final sign = type.isCredit ? '+' : '-';
    return '$sign₹${amount.toStringAsFixed(2)}';
  }

  double get balanceChange => balanceAfter - balanceBefore;

  String get balanceChangeString {
    final change = balanceChange;
    final sign = change >= 0 ? '+' : '';
    return '$sign₹${change.toStringAsFixed(2)}';
  }

  String get dateString {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String get timeString {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour12:$minute $period';
  }

  String get dateTimeString => '$dateString at $timeString';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      type: TransactionType.fromDbValue(json['transaction_type'] as String?),
      amount: Wallet._parseDouble(json['amount']),
      balanceBefore: Wallet._parseDouble(json['balance_before']),
      balanceAfter: Wallet._parseDouble(json['balance_after']),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String? ?? '',
      notes: json['notes'] as String?,
      status: TransactionStatus.fromDbValue(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'transaction_type': type.dbValue,
      'amount': amount,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'description': description,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WalletTransaction copyWith({
    String? id,
    String? walletId,
    TransactionType? type,
    double? amount,
    double? balanceBefore,
    double? balanceAfter,
    String? referenceType,
    String? referenceId,
    String? description,
    String? notes,
    TransactionStatus? status,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}


/// Payment method type enum.
enum PaymentMethodType {
  card('Card', Icons.credit_card),
  upi('UPI', Icons.account_balance),
  netBanking('Net Banking', Icons.account_balance_wallet);

  final String label;
  final IconData icon;

  const PaymentMethodType(this.label, this.icon);

  /// Convert to database string value.
  String toDbString() {
    switch (this) {
      case PaymentMethodType.card:
        return 'card';
      case PaymentMethodType.upi:
        return 'upi';
      case PaymentMethodType.netBanking:
        return 'net_banking';
    }
  }

  /// Create from database string value.
  static PaymentMethodType fromDbString(String? value) {
    switch (value?.toLowerCase()) {
      case 'card':
        return PaymentMethodType.card;
      case 'upi':
        return PaymentMethodType.upi;
      case 'net_banking':
      case 'netbanking':
        return PaymentMethodType.netBanking;
      default:
        return PaymentMethodType.card;
    }
  }
}

/// Payment method model.
class PaymentMethod {
  final String id;
  final String userId;
  final PaymentMethodType type;
  final String displayName;
  final String? lastFourDigits;
  final String? upiId;
  final String? bankName;
  final bool isDefault;
  final DateTime createdAt;

  const PaymentMethod({
    required this.id,
    required this.userId,
    required this.type,
    required this.displayName,
    this.lastFourDigits,
    this.upiId,
    this.bankName,
    this.isDefault = false,
    required this.createdAt,
  });

  String get maskedDisplay {
    if (type == PaymentMethodType.card && lastFourDigits != null) {
      return '**** **** **** $lastFourDigits';
    } else if (type == PaymentMethodType.upi && upiId != null) {
      return upiId!;
    }
    return displayName;
  }

  IconData get brandIcon {
    if (displayName.toLowerCase().contains('visa')) {
      return Icons.credit_card;
    } else if (displayName.toLowerCase().contains('master')) {
      return Icons.credit_card;
    }
    return type.icon;
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String,
      userId: (json['profile_id'] ?? json['user_id']) as String,
      type: PaymentMethodType.fromDbString(json['method_type'] as String?),
      displayName: json['display_name'] as String? ?? 'Payment Method',
      lastFourDigits: json['card_last_four'] as String?,
      upiId: json['upi_id'] as String?,
      bankName: json['bank_name'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'display_name': displayName,
      'last_four_digits': lastFourDigits,
      'upi_id': upiId,
      'bank_name': bankName,
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Referral model.
class Referral {
  final String id;
  final String userId;
  final String code;
  final int totalReferrals;
  final double totalEarnings;
  final DateTime createdAt;

  const Referral({
    required this.id,
    required this.userId,
    required this.code,
    this.totalReferrals = 0,
    this.totalEarnings = 0,
    required this.createdAt,
  });

  String get earningsString => '₹${totalEarnings.toStringAsFixed(2)}';

  factory Referral.fromJson(Map<String, dynamic> json) {
    return Referral(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      code: json['code'] as String,
      totalReferrals: json['total_referrals'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'code': code,
      'total_referrals': totalReferrals,
      'total_earnings': totalEarnings,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

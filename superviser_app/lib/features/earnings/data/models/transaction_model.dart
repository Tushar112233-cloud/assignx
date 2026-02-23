import 'package:flutter/material.dart';

/// Types of transactions.
enum TransactionType {
  earning('earning', 'Earning', Icons.arrow_downward),
  withdrawal('withdrawal', 'Withdrawal', Icons.arrow_upward),
  bonus('bonus', 'Bonus', Icons.card_giftcard),
  refund('refund', 'Refund', Icons.undo),
  adjustment('adjustment', 'Adjustment', Icons.tune),
  fee('fee', 'Fee', Icons.receipt);

  const TransactionType(this.id, this.displayName, this.icon);

  final String id;
  final String displayName;
  final IconData icon;

  Color get color {
    switch (this) {
      case TransactionType.earning:
      case TransactionType.bonus:
        return Colors.green;
      case TransactionType.withdrawal:
        return Colors.blue;
      case TransactionType.refund:
        return Colors.orange;
      case TransactionType.adjustment:
        return Colors.purple;
      case TransactionType.fee:
        return Colors.red;
    }
  }

  /// Whether this is a credit (money in).
  bool get isCredit {
    switch (this) {
      case TransactionType.earning:
      case TransactionType.bonus:
      case TransactionType.refund:
        return true;
      case TransactionType.withdrawal:
      case TransactionType.fee:
        return false;
      case TransactionType.adjustment:
        return true; // Can be either, but default to credit
    }
  }

  static TransactionType fromId(String id) {
    return TransactionType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => TransactionType.earning,
    );
  }
}

/// Status of a transaction.
enum TransactionStatus {
  pending('pending', 'Pending'),
  processing('processing', 'Processing'),
  completed('completed', 'Completed'),
  failed('failed', 'Failed'),
  cancelled('cancelled', 'Cancelled');

  const TransactionStatus(this.id, this.displayName);

  final String id;
  final String displayName;

  Color get color {
    switch (this) {
      case TransactionStatus.pending:
        return Colors.orange;
      case TransactionStatus.processing:
        return Colors.blue;
      case TransactionStatus.completed:
        return Colors.green;
      case TransactionStatus.failed:
        return Colors.red;
      case TransactionStatus.cancelled:
        return Colors.grey;
    }
  }

  static TransactionStatus fromId(String id) {
    return TransactionStatus.values.firstWhere(
      (s) => s.id == id,
      orElse: () => TransactionStatus.pending,
    );
  }
}

/// Model for a transaction.
class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.projectId,
    this.projectTitle,
    this.description,
    this.reference,
    this.balanceAfter,
    this.processedAt,
    this.metadata,
  });

  /// Unique identifier.
  final String id;

  /// Type of transaction.
  final TransactionType type;

  /// Transaction amount.
  final double amount;

  /// Current status.
  final TransactionStatus status;

  /// When created.
  final DateTime createdAt;

  /// Related project ID.
  final String? projectId;

  /// Related project title.
  final String? projectTitle;

  /// Description.
  final String? description;

  /// Reference number.
  final String? reference;

  /// Balance after this transaction.
  final double? balanceAfter;

  /// When processed.
  final DateTime? processedAt;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Formatted amount with sign.
  String get formattedAmount {
    final sign = type.isCredit ? '+' : '-';
    return '$sign₹${amount.toStringAsFixed(2)}';
  }

  /// Formatted date.
  String get formattedDate {
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

  /// Formatted time.
  String get formattedTime {
    final hour = createdAt.hour;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      type: TransactionType.fromId(
          json['transaction_type'] as String? ?? json['type'] as String? ?? 'earning'),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: TransactionStatus.fromId(json['status'] as String? ?? 'completed'),
      createdAt: DateTime.parse(
          json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      projectId: json['reference_id'] as String? ?? json['project_id'] as String?,
      projectTitle: json['project_title'] as String?,
      description: json['description'] as String? ?? json['notes'] as String?,
      reference: json['reference_type'] as String? ?? json['reference'] as String?,
      balanceAfter: (json['balance_after'] as num?)?.toDouble(),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.id,
      'amount': amount,
      'status': status.id,
      'created_at': createdAt.toIso8601String(),
      'project_id': projectId,
      'project_title': projectTitle,
      'description': description,
      'reference': reference,
      'balance_after': balanceAfter,
      'processed_at': processedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    double? amount,
    TransactionStatus? status,
    DateTime? createdAt,
    String? projectId,
    String? projectTitle,
    String? description,
    String? reference,
    double? balanceAfter,
    DateTime? processedAt,
    Map<String, dynamic>? metadata,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      description: description ?? this.description,
      reference: reference ?? this.reference,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      processedAt: processedAt ?? this.processedAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Filter options for transactions.
class TransactionFilter {
  const TransactionFilter({
    this.types,
    this.statuses,
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
  });

  final List<TransactionType>? types;
  final List<TransactionStatus>? statuses;
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;

  bool get hasFilters =>
      types != null ||
      statuses != null ||
      startDate != null ||
      endDate != null ||
      minAmount != null ||
      maxAmount != null ||
      (searchQuery?.isNotEmpty ?? false);

  TransactionFilter copyWith({
    List<TransactionType>? types,
    List<TransactionStatus>? statuses,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) {
    return TransactionFilter(
      types: types ?? this.types,
      statuses: statuses ?? this.statuses,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  TransactionFilter clear() {
    return const TransactionFilter();
  }
}

import 'package:flutter/material.dart';

/// Period types for earnings aggregation.
enum EarningsPeriod {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  yearly('yearly', 'Yearly'),
  allTime('all_time', 'All Time');

  const EarningsPeriod(this.id, this.displayName);

  final String id;
  final String displayName;

  static EarningsPeriod fromId(String id) {
    return EarningsPeriod.values.firstWhere(
      (p) => p.id == id,
      orElse: () => EarningsPeriod.monthly,
    );
  }
}

/// Model for earnings summary.
class EarningsSummary {
  const EarningsSummary({
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.withdrawnAmount,
    required this.availableBalance,
    required this.projectsCompleted,
    required this.averagePerProject,
    this.period = EarningsPeriod.monthly,
    this.periodStart,
    this.periodEnd,
    this.growthPercentage,
    this.previousPeriodEarnings,
  });

  /// Total earnings for the period.
  final double totalEarnings;

  /// Pending earnings (not yet processed).
  final double pendingEarnings;

  /// Total withdrawn amount.
  final double withdrawnAmount;

  /// Available balance for withdrawal.
  final double availableBalance;

  /// Number of projects completed.
  final int projectsCompleted;

  /// Average earnings per project.
  final double averagePerProject;

  /// Period type.
  final EarningsPeriod period;

  /// Period start date.
  final DateTime? periodStart;

  /// Period end date.
  final DateTime? periodEnd;

  /// Growth percentage compared to previous period.
  final double? growthPercentage;

  /// Previous period earnings for comparison.
  final double? previousPeriodEarnings;

  /// Whether earnings are growing.
  bool get isGrowing => (growthPercentage ?? 0) > 0;

  factory EarningsSummary.fromJson(Map<String, dynamic> json) {
    return EarningsSummary(
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      pendingEarnings: (json['pending_earnings'] as num?)?.toDouble() ?? 0,
      withdrawnAmount: (json['withdrawn_amount'] as num?)?.toDouble() ?? 0,
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0,
      projectsCompleted: json['projects_completed'] as int? ?? 0,
      averagePerProject: (json['average_per_project'] as num?)?.toDouble() ?? 0,
      period: EarningsPeriod.fromId(json['period'] as String? ?? 'monthly'),
      periodStart: json['period_start'] != null
          ? DateTime.parse(json['period_start'] as String)
          : null,
      periodEnd: json['period_end'] != null
          ? DateTime.parse(json['period_end'] as String)
          : null,
      growthPercentage: (json['growth_percentage'] as num?)?.toDouble(),
      previousPeriodEarnings:
          (json['previous_period_earnings'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_earnings': totalEarnings,
      'pending_earnings': pendingEarnings,
      'withdrawn_amount': withdrawnAmount,
      'available_balance': availableBalance,
      'projects_completed': projectsCompleted,
      'average_per_project': averagePerProject,
      'period': period.id,
      'period_start': periodStart?.toIso8601String(),
      'period_end': periodEnd?.toIso8601String(),
      'growth_percentage': growthPercentage,
      'previous_period_earnings': previousPeriodEarnings,
    };
  }
}

/// Data point for earnings chart.
class EarningsDataPoint {
  const EarningsDataPoint({
    required this.date,
    required this.amount,
    this.projectCount = 0,
    this.labelText,
  });

  /// Date of the data point.
  final DateTime date;

  /// Earnings amount.
  final double amount;

  /// Number of projects.
  final int projectCount;

  /// Optional label text.
  final String? labelText;

  /// Formatted label for the data point.
  String get label => labelText ?? _formatDate(date);

  /// Short label for charts (abbreviated).
  String get shortLabel {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  factory EarningsDataPoint.fromJson(Map<String, dynamic> json) {
    return EarningsDataPoint(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
      labelText: json['label'] as String?,
    );
  }
}

/// Commission breakdown by category.
class CommissionBreakdown {
  const CommissionBreakdown({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.projectCount,
    this.color,
  });

  /// Category name.
  final String category;

  /// Total amount for this category.
  final double amount;

  /// Percentage of total.
  final double percentage;

  /// Number of projects.
  final int projectCount;

  /// Color for charts.
  final Color? color;

  factory CommissionBreakdown.fromJson(Map<String, dynamic> json) {
    return CommissionBreakdown(
      category: json['category'] as String? ?? 'Other',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      projectCount: json['project_count'] as int? ?? 0,
    );
  }
}

/// Performance metrics for supervisor.
class PerformanceMetrics {
  const PerformanceMetrics({
    required this.totalProjects,
    required this.completedProjects,
    required this.approvalRate,
    required this.averageResponseTime,
    required this.clientSatisfaction,
    required this.onTimeDelivery,
    this.revisionRate,
    this.repeatClientRate,
    this.rank,
    this.totalRank,
  });

  /// Total projects assigned.
  final int totalProjects;

  /// Projects completed.
  final int completedProjects;

  /// Approval rate percentage.
  final double approvalRate;

  /// Average response time in hours.
  final double averageResponseTime;

  /// Client satisfaction rating (0-5).
  final double clientSatisfaction;

  /// On-time delivery percentage.
  final double onTimeDelivery;

  /// Revision request rate.
  final double? revisionRate;

  /// Repeat client rate.
  final double? repeatClientRate;

  /// Current rank among supervisors.
  final int? rank;

  /// Total supervisors for ranking.
  final int? totalRank;

  /// Completion rate percentage.
  double get completionRate =>
      totalProjects > 0 ? (completedProjects / totalProjects) * 100 : 0;

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      totalProjects: json['total_projects'] as int? ?? 0,
      completedProjects: json['completed_projects'] as int? ?? 0,
      approvalRate: (json['approval_rate'] as num?)?.toDouble() ?? 0,
      averageResponseTime:
          (json['average_response_time'] as num?)?.toDouble() ?? 0,
      clientSatisfaction:
          (json['client_satisfaction'] as num?)?.toDouble() ?? 0,
      onTimeDelivery: (json['on_time_delivery'] as num?)?.toDouble() ?? 0,
      revisionRate: (json['revision_rate'] as num?)?.toDouble(),
      repeatClientRate: (json['repeat_client_rate'] as num?)?.toDouble(),
      rank: json['rank'] as int?,
      totalRank: json['total_rank'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_projects': totalProjects,
      'completed_projects': completedProjects,
      'approval_rate': approvalRate,
      'average_response_time': averageResponseTime,
      'client_satisfaction': clientSatisfaction,
      'on_time_delivery': onTimeDelivery,
      'revision_rate': revisionRate,
      'repeat_client_rate': repeatClientRate,
      'rank': rank,
      'total_rank': totalRank,
    };
  }
}

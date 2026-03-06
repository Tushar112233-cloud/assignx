/// Statistics data provider for the Doer App.
///
/// Computes statistics from project data and doer profile,
/// including earnings over time, project distributions, subject rankings,
/// and monthly performance data for the statistics screen.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
import '../data/models/doer_project_model.dart';
import 'auth_provider.dart';

/// Time period filter for statistics.
enum StatsPeriod { week, month, year, all }

/// Data point for earnings/projects over time.
class TimeSeriesData {
  final DateTime date;
  final double value;

  const TimeSeriesData({required this.date, required this.value});
}

/// Subject ranking entry.
class SubjectRanking {
  final String subject;
  final int projectCount;
  final double totalEarnings;

  const SubjectRanking({
    required this.subject,
    required this.projectCount,
    required this.totalEarnings,
  });
}

/// Monthly performance entry for heatmap.
class MonthlyPerformance {
  final int year;
  final int month;
  final int projectsCompleted;

  const MonthlyPerformance({
    required this.year,
    required this.month,
    required this.projectsCompleted,
  });
}

/// Project distribution by status.
class ProjectDistribution {
  final int completed;
  final int inProgress;
  final int pending;
  final int revision;

  const ProjectDistribution({
    this.completed = 0,
    this.inProgress = 0,
    this.pending = 0,
    this.revision = 0,
  });

  int get total => completed + inProgress + pending + revision;
}

/// Rating breakdown across categories.
class RatingBreakdown {
  final double quality;
  final double timeliness;
  final double communication;
  final double overall;

  const RatingBreakdown({
    this.quality = 0,
    this.timeliness = 0,
    this.communication = 0,
    this.overall = 0,
  });
}

/// Insight item for the insights panel.
class InsightItem {
  final String message;
  final InsightType type;

  const InsightItem({required this.message, required this.type});
}

enum InsightType { success, info, warning }

/// Goal item for tracking progress.
class GoalItem {
  final String title;
  final int current;
  final int target;

  const GoalItem({
    required this.title,
    required this.current,
    required this.target,
  });

  double get progress => target > 0 ? (current / target).clamp(0.0, 1.0) : 0;
}

/// Complete statistics state.
class StatisticsState {
  final double totalEarnings;
  final double earningsTrend;
  final double averageRating;
  final double ratingTrend;
  final double projectVelocity;
  final StatsPeriod selectedPeriod;
  final List<TimeSeriesData> earningsTimeSeries;
  final List<TimeSeriesData> projectsTimeSeries;
  final ProjectDistribution distribution;
  final RatingBreakdown ratingBreakdown;
  final List<SubjectRanking> topSubjects;
  final List<MonthlyPerformance> monthlyPerformance;
  final List<InsightItem> insights;
  final List<GoalItem> goals;
  final bool isLoading;
  final String? errorMessage;

  const StatisticsState({
    this.totalEarnings = 0,
    this.earningsTrend = 0,
    this.averageRating = 0,
    this.ratingTrend = 0,
    this.projectVelocity = 0,
    this.selectedPeriod = StatsPeriod.month,
    this.earningsTimeSeries = const [],
    this.projectsTimeSeries = const [],
    this.distribution = const ProjectDistribution(),
    this.ratingBreakdown = const RatingBreakdown(),
    this.topSubjects = const [],
    this.monthlyPerformance = const [],
    this.insights = const [],
    this.goals = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  StatisticsState copyWith({
    double? totalEarnings,
    double? earningsTrend,
    double? averageRating,
    double? ratingTrend,
    double? projectVelocity,
    StatsPeriod? selectedPeriod,
    List<TimeSeriesData>? earningsTimeSeries,
    List<TimeSeriesData>? projectsTimeSeries,
    ProjectDistribution? distribution,
    RatingBreakdown? ratingBreakdown,
    List<SubjectRanking>? topSubjects,
    List<MonthlyPerformance>? monthlyPerformance,
    List<InsightItem>? insights,
    List<GoalItem>? goals,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StatisticsState(
      totalEarnings: totalEarnings ?? this.totalEarnings,
      earningsTrend: earningsTrend ?? this.earningsTrend,
      averageRating: averageRating ?? this.averageRating,
      ratingTrend: ratingTrend ?? this.ratingTrend,
      projectVelocity: projectVelocity ?? this.projectVelocity,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      earningsTimeSeries: earningsTimeSeries ?? this.earningsTimeSeries,
      projectsTimeSeries: projectsTimeSeries ?? this.projectsTimeSeries,
      distribution: distribution ?? this.distribution,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
      topSubjects: topSubjects ?? this.topSubjects,
      monthlyPerformance: monthlyPerformance ?? this.monthlyPerformance,
      insights: insights ?? this.insights,
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier managing statistics state and data fetching.
///
/// Computes all statistics client-side from the project list and doer profile.
class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => _loadStatistics());
    }
    return const StatisticsState(isLoading: true);
  }

  /// Changes the selected period and recomputes.
  void setPeriod(StatsPeriod period) {
    state = state.copyWith(selectedPeriod: period);
    _loadStatistics();
  }

  /// Loads all statistics by fetching projects and doer profile, then computing.
  Future<void> _loadStatistics() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Fetch all projects and doer profile in parallel
      final results = await Future.wait([
        ApiClient.get('/projects', queryParams: {'limit': '200'}),
        ApiClient.get('/doers/me'),
      ]);

      final projectsResponse = results[0];
      final doerResponse = results[1];

      // Parse projects
      final projectList = projectsResponse is List
          ? projectsResponse
          : (projectsResponse as Map<String, dynamic>)['projects'] as List? ?? [];

      final projects = projectList
          .map((json) => DoerProjectModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Parse doer profile stats
      double averageRating = 0;
      double totalEarningsFromProfile = 0;
      if (doerResponse is Map<String, dynamic>) {
        averageRating = (doerResponse['average_rating'] as num?)?.toDouble()
            ?? (doerResponse['averageRating'] as num?)?.toDouble() ?? 0;
        totalEarningsFromProfile = (doerResponse['total_earnings'] as num?)?.toDouble()
            ?? (doerResponse['totalEarnings'] as num?)?.toDouble() ?? 0;
      }

      // Compute all stats from projects
      _computeEarningsAndTimeSeries(projects, totalEarningsFromProfile);
      _computeDistribution(projects);
      _computeSubjectRankings(projects);
      _computeMonthlyPerformance(projects);

      state = state.copyWith(
        averageRating: averageRating,
        ratingBreakdown: RatingBreakdown(
          quality: averageRating,
          timeliness: averageRating,
          communication: averageRating,
          overall: averageRating,
        ),
        isLoading: false,
      );

      _generateInsightsAndGoals();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StatisticsNotifier._loadStatistics error: $e');
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load statistics. Pull to refresh.',
      );
    }
  }

  /// Computes earnings time series and totals from project data.
  void _computeEarningsAndTimeSeries(List<DoerProjectModel> projects, double profileEarnings) {
    final period = state.selectedPeriod;
    final now = DateTime.now();

    DateTime startDate;
    switch (period) {
      case StatsPeriod.week:
        startDate = now.subtract(const Duration(days: 7));
      case StatsPeriod.month:
        startDate = DateTime(now.year, now.month - 1, now.day);
      case StatsPeriod.year:
        startDate = DateTime(now.year - 1, now.month, now.day);
      case StatsPeriod.all:
        startDate = DateTime(2020);
    }

    double totalEarnings = 0;
    final Map<String, double> earningsMap = {};
    final Map<String, double> projectsMap = {};
    int periodProjectCount = 0;

    for (final p in projects) {
      final date = p.completedAt ?? p.createdAt;
      final payout = p.doerPayout;
      final status = p.status;

      if (status == DoerProjectStatus.completed ||
          status == DoerProjectStatus.autoApproved) {
        totalEarnings += payout;
      }

      // Only include in time series if within period
      if (date.isAfter(startDate)) {
        periodProjectCount++;
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        if (status == DoerProjectStatus.completed ||
            status == DoerProjectStatus.autoApproved) {
          earningsMap[key] = (earningsMap[key] ?? 0) + payout;
        }
        projectsMap[key] = (projectsMap[key] ?? 0) + 1;
      }
    }

    final earningsList = <TimeSeriesData>[];
    for (final entry in earningsMap.entries) {
      final parts = entry.key.split('-');
      earningsList.add(TimeSeriesData(
        date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
        value: entry.value,
      ));
    }
    earningsList.sort((a, b) => a.date.compareTo(b.date));

    final projectsList = <TimeSeriesData>[];
    for (final entry in projectsMap.entries) {
      final parts = entry.key.split('-');
      projectsList.add(TimeSeriesData(
        date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
        value: entry.value,
      ));
    }
    projectsList.sort((a, b) => a.date.compareTo(b.date));

    final daysInPeriod = now.difference(startDate).inDays;
    final weeksInPeriod = daysInPeriod / 7;
    final velocity = weeksInPeriod > 0 ? periodProjectCount / weeksInPeriod : 0.0;

    // Use profile earnings if higher (it's the source of truth)
    final finalEarnings = profileEarnings > totalEarnings ? profileEarnings : totalEarnings;

    state = state.copyWith(
      totalEarnings: finalEarnings,
      projectVelocity: velocity,
      earningsTimeSeries: earningsList,
      projectsTimeSeries: projectsList,
    );
  }

  /// Computes project distribution by status.
  void _computeDistribution(List<DoerProjectModel> projects) {
    int completed = 0, inProgress = 0, pending = 0, revision = 0;

    for (final p in projects) {
      switch (p.status) {
        case DoerProjectStatus.completed:
        case DoerProjectStatus.autoApproved:
          completed++;
        case DoerProjectStatus.inProgress:
        case DoerProjectStatus.assigned:
          inProgress++;
        case DoerProjectStatus.submitted:
        case DoerProjectStatus.submittedForQc:
        case DoerProjectStatus.qcInProgress:
        case DoerProjectStatus.delivered:
        case DoerProjectStatus.qcApproved:
          pending++;
        case DoerProjectStatus.revisionRequested:
        case DoerProjectStatus.inRevision:
        case DoerProjectStatus.qcRejected:
          revision++;
        default:
          break;
      }
    }

    state = state.copyWith(
      distribution: ProjectDistribution(
        completed: completed,
        inProgress: inProgress,
        pending: pending,
        revision: revision,
      ),
    );
  }

  /// Computes top subjects by project count.
  void _computeSubjectRankings(List<DoerProjectModel> projects) {
    final subjectMap = <String, _SubjectAccumulator>{};

    for (final p in projects) {
      final subject = p.subjectName ?? p.subject ?? 'General';
      final acc = subjectMap.putIfAbsent(subject, () => _SubjectAccumulator());
      acc.count++;
      if (p.status == DoerProjectStatus.completed || p.status == DoerProjectStatus.autoApproved) {
        acc.earnings += p.doerPayout;
      }
    }

    final rankings = subjectMap.entries
        .map((e) => SubjectRanking(
              subject: e.key,
              projectCount: e.value.count,
              totalEarnings: e.value.earnings,
            ))
        .toList()
      ..sort((a, b) => b.projectCount.compareTo(a.projectCount));

    state = state.copyWith(topSubjects: rankings.take(5).toList());
  }

  /// Computes monthly performance from completed projects.
  void _computeMonthlyPerformance(List<DoerProjectModel> projects) {
    final now = DateTime.now();
    final monthMap = <String, int>{};

    // Initialize last 12 months
    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      monthMap['${month.year}-${month.month}'] = 0;
    }

    for (final p in projects) {
      if (p.status == DoerProjectStatus.completed || p.status == DoerProjectStatus.autoApproved) {
        final date = p.completedAt ?? p.createdAt;
        final key = '${date.year}-${date.month}';
        if (monthMap.containsKey(key)) {
          monthMap[key] = monthMap[key]! + 1;
        }
      }
    }

    final performance = monthMap.entries
        .map((e) {
          final parts = e.key.split('-');
          return MonthlyPerformance(
            year: int.parse(parts[0]),
            month: int.parse(parts[1]),
            projectsCompleted: e.value,
          );
        })
        .toList()
      ..sort((a, b) {
        final cmp = a.year.compareTo(b.year);
        return cmp != 0 ? cmp : a.month.compareTo(b.month);
      });

    state = state.copyWith(monthlyPerformance: performance);
  }

  /// Generates insights and goals based on current data.
  void _generateInsightsAndGoals() {
    final insights = <InsightItem>[];
    final goals = <GoalItem>[];

    if (state.averageRating >= 4.5) {
      insights.add(const InsightItem(
        message: 'Outstanding rating! You are in the top 10% of doers.',
        type: InsightType.success,
      ));
    } else if (state.averageRating >= 4.0) {
      insights.add(const InsightItem(
        message: 'Great rating! Keep delivering quality work.',
        type: InsightType.info,
      ));
    }

    if (state.projectVelocity > 3) {
      insights.add(const InsightItem(
        message: 'High productivity! You are completing projects faster than average.',
        type: InsightType.success,
      ));
    }

    if (state.distribution.revision > 0) {
      insights.add(InsightItem(
        message: '${state.distribution.revision} project(s) need revision. Focus on quality to reduce revisions.',
        type: InsightType.warning,
      ));
    }

    if (state.totalEarnings > 10000) {
      insights.add(const InsightItem(
        message: 'You have crossed the 10K earnings milestone!',
        type: InsightType.success,
      ));
    }

    if (insights.isEmpty) {
      insights.add(const InsightItem(
        message: 'Complete more projects to unlock performance insights.',
        type: InsightType.info,
      ));
    }

    final totalProjects = state.distribution.total;
    goals.add(GoalItem(
      title: 'Reach 100 projects',
      current: totalProjects,
      target: 100,
    ));

    goals.add(GoalItem(
      title: 'Earn ₹1,00,000',
      current: state.totalEarnings.toInt(),
      target: 100000,
    ));

    goals.add(GoalItem(
      title: 'Maintain 4.5+ rating',
      current: (state.averageRating * 10).toInt(),
      target: 45,
    ));

    state = state.copyWith(insights: insights, goals: goals);
  }

  /// Refreshes statistics data.
  Future<void> refresh() async {
    await _loadStatistics();
  }
}

class _SubjectAccumulator {
  int count = 0;
  double earnings = 0;
}

/// Main statistics provider.
final statisticsProvider =
    NotifierProvider<StatisticsNotifier, StatisticsState>(() {
  return StatisticsNotifier();
});

/// Convenience provider for the selected period.
final statsPeriodProvider = Provider<StatsPeriod>((ref) {
  return ref.watch(statisticsProvider).selectedPeriod;
});

/// Convenience provider for statistics loading state.
final statsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(statisticsProvider).isLoading;
});

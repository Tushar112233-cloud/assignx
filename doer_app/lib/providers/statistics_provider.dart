/// Statistics data provider for the Doer App.
///
/// Fetches detailed statistics data from Supabase including
/// earnings over time, project distributions, subject rankings,
/// and monthly performance data for the statistics screen.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api_client.dart';
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
class StatisticsNotifier extends Notifier<StatisticsState> {
  @override
  StatisticsState build() {
    final user = ref.watch(currentUserProvider);
    if (user != null) {
      Future.microtask(() => _loadStatistics(user.id));
    }
    return const StatisticsState(isLoading: true);
  }

  /// Changes the selected period and reloads data.
  void setPeriod(StatsPeriod period) {
    state = state.copyWith(selectedPeriod: period);
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _loadStatistics(user.id);
    }
  }

  /// Loads all statistics data from the API.
  Future<void> _loadStatistics(String profileId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await Future.wait([
        _loadEarningsAndProjects(),
        _loadDistribution(),
        _loadSubjectRankings(),
        _loadMonthlyPerformance(),
      ]);

      _generateInsightsAndGoals();
      state = state.copyWith(isLoading: false);
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

  /// Loads earnings time series, total earnings, rating, and velocity.
  Future<void> _loadEarningsAndProjects() async {
    try {
      final period = state.selectedPeriod;

      final response = await ApiClient.get(
        '/doer/statistics/earnings?period=${period.name}',
      );

      if (response is Map<String, dynamic>) {
        final projects = response['projects'] as List? ?? [];
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
        final earningsList = <TimeSeriesData>[];
        final projectsList = <TimeSeriesData>[];
        final Map<String, double> earningsMap = {};
        final Map<String, double> projectsMap = {};

        for (final p in projects) {
          final createdAt = DateTime.tryParse((p['created_at'] ?? p['createdAt'] ?? '').toString()) ?? DateTime.now();
          final payout = (p['doer_payout'] ?? p['doerPayout'] as num?)?.toDouble() ?? 0;
          final status = (p['status'] ?? '').toString();

          if (status == 'completed' || status == 'paid') {
            totalEarnings += payout;
          }

          final key = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
          earningsMap[key] = (earningsMap[key] ?? 0) + payout;
          projectsMap[key] = (projectsMap[key] ?? 0) + 1;
        }

        for (final entry in earningsMap.entries) {
          final parts = entry.key.split('-');
          earningsList.add(TimeSeriesData(
            date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
            value: entry.value,
          ));
        }

        for (final entry in projectsMap.entries) {
          final parts = entry.key.split('-');
          projectsList.add(TimeSeriesData(
            date: DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])),
            value: entry.value,
          ));
        }

        final daysInPeriod = now.difference(startDate).inDays;
        final weeksInPeriod = daysInPeriod / 7;
        final velocity = weeksInPeriod > 0 ? projects.length / weeksInPeriod : 0.0;

        state = state.copyWith(
          totalEarnings: (response['totalEarnings'] as num?)?.toDouble() ?? totalEarnings,
          earningsTrend: (response['earningsTrend'] as num?)?.toDouble() ?? 0,
          averageRating: (response['averageRating'] as num?)?.toDouble() ?? 0,
          ratingTrend: (response['ratingTrend'] as num?)?.toDouble() ?? 0,
          projectVelocity: velocity,
          earningsTimeSeries: earningsList,
          projectsTimeSeries: projectsList,
          ratingBreakdown: const RatingBreakdown(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StatisticsNotifier._loadEarningsAndProjects error: $e');
      }
    }
  }

  /// Loads project distribution by status.
  Future<void> _loadDistribution() async {
    try {
      final response = await ApiClient.get('/doer/statistics/distribution');

      if (response is Map<String, dynamic>) {
        state = state.copyWith(
          distribution: ProjectDistribution(
            completed: response['completed'] as int? ?? 0,
            inProgress: response['inProgress'] as int? ?? 0,
            pending: response['pending'] as int? ?? 0,
            revision: response['revision'] as int? ?? 0,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StatisticsNotifier._loadDistribution error: $e');
      }
    }
  }

  /// Loads top subjects by project count.
  Future<void> _loadSubjectRankings() async {
    try {
      final response = await ApiClient.get('/doer/statistics/subjects');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['subjects'] as List? ?? [];

      final rankings = list
          .map((e) => SubjectRanking(
                subject: (e as Map<String, dynamic>)['subject'] as String? ?? 'General',
                projectCount: e['projectCount'] as int? ?? 0,
                totalEarnings: (e['totalEarnings'] as num?)?.toDouble() ?? 0,
              ))
          .toList();

      state = state.copyWith(
        topSubjects: rankings.take(5).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StatisticsNotifier._loadSubjectRankings error: $e');
      }
    }
  }

  /// Loads monthly performance data for heatmap.
  Future<void> _loadMonthlyPerformance() async {
    try {
      final response = await ApiClient.get('/doer/statistics/monthly-performance');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['performance'] as List? ?? [];

      if (list.isNotEmpty) {
        final performance = list
            .map((e) => MonthlyPerformance(
                  year: (e as Map<String, dynamic>)['year'] as int? ?? 0,
                  month: e['month'] as int? ?? 0,
                  projectsCompleted: e['projectsCompleted'] as int? ?? 0,
                ))
            .toList();

        state = state.copyWith(monthlyPerformance: performance);
      } else {
        // Generate default empty months
        final now = DateTime.now();
        final performance = <MonthlyPerformance>[];
        for (int i = 0; i < 12; i++) {
          final month = DateTime(now.year, now.month - i, 1);
          performance.add(MonthlyPerformance(
            year: month.year,
            month: month.month,
            projectsCompleted: 0,
          ));
        }
        state = state.copyWith(
          monthlyPerformance: performance.reversed.toList(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('StatisticsNotifier._loadMonthlyPerformance error: $e');
      }
    }
  }

  /// Generates insights and goals based on current data.
  void _generateInsightsAndGoals() {
    final insights = <InsightItem>[];
    final goals = <GoalItem>[];

    // Generate insights
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

    // Generate goals
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
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await _loadStatistics(user.id);
    }
  }
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

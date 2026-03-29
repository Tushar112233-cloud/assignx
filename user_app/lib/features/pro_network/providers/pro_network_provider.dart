library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pro_network_post_model.dart';
import '../data/repositories/pro_network_repository.dart';

/// Provider for the job repository singleton.
final proNetworkRepositoryProvider = Provider<ProNetworkRepository>((ref) {
  return ProNetworkRepository();
});

/// Combined filter state used to key the jobs provider.
class JobFilters {
  final JobCategory? category;
  final JobType? type;
  final String searchQuery;
  final bool remoteOnly;

  const JobFilters({
    this.category,
    this.type,
    this.searchQuery = '',
    this.remoteOnly = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobFilters &&
          category == other.category &&
          type == other.type &&
          searchQuery == other.searchQuery &&
          remoteOnly == other.remoteOnly;

  @override
  int get hashCode =>
      category.hashCode ^
      type.hashCode ^
      searchQuery.hashCode ^
      remoteOnly.hashCode;
}

/// Provider that fetches jobs based on the active [JobFilters].
final filteredJobsProvider =
    FutureProvider.autoDispose.family<List<Job>, JobFilters>(
  (ref, filters) async {
    final repository = ref.watch(proNetworkRepositoryProvider);
    return repository.getJobs(
      category: filters.category,
      type: filters.type,
      searchQuery:
          filters.searchQuery.isNotEmpty ? filters.searchQuery : null,
      remoteOnly: filters.remoteOnly ? true : null,
    );
  },
);

/// Provider for fetching a single job by ID (detail screen).
final jobDetailProvider =
    FutureProvider.autoDispose.family<Job?, String>((ref, jobId) async {
  final repository = ref.watch(proNetworkRepositoryProvider);
  return repository.getJobById(jobId);
});

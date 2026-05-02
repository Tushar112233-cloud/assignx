library;

import 'package:logger/logger.dart';

import '../../../../core/api/api_client.dart';
import '../models/pro_network_post_model.dart';

/// Repository for fetching job listings from the /api/jobs endpoint.
class ProNetworkRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ProNetworkRepository();

  /// Fetch a paginated list of jobs with optional filters.
  Future<List<Job>> getJobs({
    JobCategory? category,
    JobType? type,
    String? searchQuery,
    bool? remoteOnly,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (category != null && category != JobCategory.all) {
        queryParams['category'] = category.name;
      }
      if (type != null && type != JobType.all) {
        queryParams['type'] = type.apiValue;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }
      if (remoteOnly == true) {
        queryParams['remote'] = 'true';
      }

      final response =
          await ApiClient.get('/jobs', queryParams: queryParams);
      final data = response is Map<String, dynamic> ? response : {};
      final list = data['jobs'] as List? ?? [];
      return list
          .map((row) => Job.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching jobs: $e');
      return [];
    }
  }

  /// Fetch a single job by its ID.
  Future<Job?> getJobById(String id) async {
    try {
      final response = await ApiClient.get('/jobs/$id');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      final jobData = data['job'] as Map<String, dynamic>? ?? data;
      return Job.fromJson(jobData);
    } catch (e) {
      _logger.e('Error fetching job: $e');
      return null;
    }
  }
}

import '../../../../core/api/api_client.dart';
import '../../../dashboard/data/models/doer_model.dart';

/// Repository for doer operations.
class DoersRepository {
  DoersRepository();

  /// Fetch doers with pagination and filters.
  Future<List<DoerModel>> getDoers({
    int limit = 20,
    int offset = 0,
    String? search,
    String? expertise,
    bool? isAvailable,
    double? minRating,
    String? sortBy,
    bool ascending = false,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (search != null && search.isNotEmpty) 'search': search,
      if (expertise != null) 'expertise': expertise,
      if (isAvailable != null) 'isAvailable': '$isAvailable',
      if (minRating != null) 'minRating': '$minRating',
      if (sortBy != null) 'sortBy': sortBy,
      'ascending': '$ascending',
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await ApiClient.get('/supervisor/doers?$query');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['doers'] as List? ?? [];

    return list
        .map((json) => DoerModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get doer by ID.
  Future<DoerModel?> getDoerById(String doerId) async {
    try {
      final response = await ApiClient.get('/supervisor/doers/$doerId');
      if (response == null) return null;
      return DoerModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Get doer reviews.
  Future<List<DoerReview>> getDoerReviews(
    String doerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await ApiClient.get(
      '/supervisor/doers/$doerId/reviews?limit=$limit&offset=$offset',
    );
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['reviews'] as List? ?? [];

    return list
        .map((json) => DoerReview.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get doer project history.
  Future<List<Map<String, dynamic>>> getDoerProjects(
    String doerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await ApiClient.get(
      '/supervisor/doers/$doerId/projects?limit=$limit&offset=$offset',
    );
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['projects'] as List? ?? [];

    return list.cast<Map<String, dynamic>>();
  }

  /// Search doers by name or email.
  Future<List<DoerModel>> searchDoers(String query) async {
    if (query.isEmpty) return [];

    final response = await ApiClient.get(
      '/supervisor/doers?search=$query&limit=10',
    );
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['doers'] as List? ?? [];

    return list
        .map((json) => DoerModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all expertise areas from subjects.
  Future<List<String>> getExpertiseAreas() async {
    final response = await ApiClient.get('/subjects');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['subjects'] as List? ?? [];

    return list
        .map((row) => (row is Map ? row['name'] as String? : row as String?) ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  /// Get total doers count.
  Future<int> getDoersCount() async {
    final response = await ApiClient.get('/supervisor/doers/count');
    if (response is Map<String, dynamic>) {
      return response['count'] as int? ?? 0;
    }
    return 0;
  }

  /// Get available doers count.
  Future<int> getAvailableDoersCount() async {
    final response = await ApiClient.get('/supervisor/doers/count?isAvailable=true');
    if (response is Map<String, dynamic>) {
      return response['count'] as int? ?? 0;
    }
    return 0;
  }
}

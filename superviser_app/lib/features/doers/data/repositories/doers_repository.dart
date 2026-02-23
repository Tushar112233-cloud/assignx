import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../dashboard/data/models/doer_model.dart';

/// Repository for doer operations.
class DoersRepository {
  DoersRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID.
  String? get _currentUserId => getCurrentUserId();

  /// Cached supervisor ID to avoid repeated lookups.
  String? _cachedSupervisorId;

  /// Gets the supervisor table ID from the supervisors table.
  Future<String?> _getSupervisorId() async {
    if (_cachedSupervisorId != null) return _cachedSupervisorId;
    final userId = getCurrentUserId();
    if (userId == null) return null;
    try {
      final response = await _client
          .from('supervisors')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();
      _cachedSupervisorId = response?['id'] as String?;
      return _cachedSupervisorId;
    } catch (_) {
      return null;
    }
  }

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
    var query = _client.from('doers').select();

    if (search != null && search.isNotEmpty) {
      query = query.or('name.ilike.%$search%,email.ilike.%$search%');
    }

    if (expertise != null && expertise.isNotEmpty) {
      query = query.contains('expertise', [expertise]);
    }

    if (isAvailable != null) {
      query = query.eq('is_available', isAvailable);
    }

    if (minRating != null) {
      query = query.gte('rating', minRating);
    }

    final response = await query
        .order(sortBy ?? 'rating', ascending: ascending)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => DoerModel.fromJson(json))
        .toList();
  }

  /// Get doer by ID.
  Future<DoerModel?> getDoerById(String doerId) async {
    final response = await _client
        .from('doers')
        .select()
        .eq('id', doerId)
        .maybeSingle();

    if (response == null) return null;
    return DoerModel.fromJson(response);
  }

  /// Get doer reviews.
  Future<List<DoerReview>> getDoerReviews(
    String doerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _client
        .from('doer_reviews')
        .select()
        .eq('doer_id', doerId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => DoerReview.fromJson(json))
        .toList();
  }

  /// Get doer project history.
  Future<List<Map<String, dynamic>>> getDoerProjects(
    String doerId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) return [];

    final response = await _client
        .from('projects')
        .select('id, title, status, created_at, completed_at, doer_amount')
        .eq('doer_id', doerId)
        .eq('supervisor_id', supervisorId)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).cast<Map<String, dynamic>>();
  }

  /// Search doers.
  Future<List<DoerModel>> searchDoers(String query) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('doers')
        .select()
        .or('name.ilike.%$query%,email.ilike.%$query%')
        .limit(10);

    return (response as List)
        .map((json) => DoerModel.fromJson(json))
        .toList();
  }

  /// Get all expertise areas.
  Future<List<String>> getExpertiseAreas() async {
    final response = await _client
        .from('doers')
        .select('expertise');

    final expertiseSet = <String>{};
    for (final row in (response as List)) {
      final list = row['expertise'] as List?;
      if (list != null) {
        expertiseSet.addAll(list.cast<String>());
      }
    }

    return expertiseSet.toList()..sort();
  }

  /// Get total doers count.
  Future<int> getDoersCount() async {
    final response = await _client.from('doers').select('id');
    return (response as List).length;
  }

  /// Get available doers count.
  Future<int> getAvailableDoersCount() async {
    final response = await _client
        .from('doers')
        .select('id')
        .eq('is_available', true);
    return (response as List).length;
  }
}

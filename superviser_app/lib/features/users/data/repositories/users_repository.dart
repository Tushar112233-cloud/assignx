import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/client_model.dart';

/// Repository for user/client operations.
class UsersRepository {
  UsersRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID.
  String? get _currentUserId => getCurrentUserId();

  /// Fetch clients with pagination.
  Future<List<ClientModel>> getClients({
    int limit = 20,
    int offset = 0,
    String? search,
    String? sortBy,
    bool ascending = false,
  }) async {
    if (_currentUserId == null) return [];

    // Get unique client IDs from projects assigned to this supervisor
    var query = _client
        .from('projects')
        .select('user_id')
        .eq('supervisor_id', _currentUserId!);

    final projectUsers = await query;
    final userIds = (projectUsers as List)
        .map((p) => p['user_id'] as String)
        .toSet()
        .toList();

    if (userIds.isEmpty) return [];

    // Get profiles for these users
    var profileQuery = _client
        .from('profiles')
        .select()
        .inFilter('id', userIds);

    if (search != null && search.isNotEmpty) {
      profileQuery = profileQuery.or(
        'full_name.ilike.%$search%,email.ilike.%$search%',
      );
    }

    final response = await profileQuery
        .order(sortBy ?? 'created_at', ascending: ascending)
        .range(offset, offset + limit - 1);

    // Fetch additional stats for each client
    final clients = await Future.wait(
      (response as List).map((profile) async {
        final stats = await _getClientStats(profile['id'] as String);
        return ClientModel.fromJson({
          ...profile,
          ...stats,
        });
      }),
    );

    return clients;
  }

  /// Get client stats.
  Future<Map<String, dynamic>> _getClientStats(String clientId) async {
    if (_currentUserId == null) return {};

    final projects = await _client
        .from('projects')
        .select('status, user_quote')
        .eq('user_id', clientId)
        .eq('supervisor_id', _currentUserId!);

    final projectList = projects as List;
    final totalProjects = projectList.length;
    final activeProjects = projectList.where(
      (p) => !['completed', 'delivered', 'cancelled'].contains(p['status']),
    ).length;
    final completedProjects = projectList.where(
      (p) => ['completed', 'delivered'].contains(p['status']),
    ).length;
    final totalSpent = projectList.fold<double>(
      0,
      (sum, p) => sum + ((p['user_quote'] as num?)?.toDouble() ?? 0),
    );

    return {
      'total_projects': totalProjects,
      'active_projects': activeProjects,
      'completed_projects': completedProjects,
      'total_spent': totalSpent,
    };
  }

  /// Get client by ID.
  Future<ClientModel?> getClientById(String clientId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', clientId)
        .maybeSingle();

    if (response == null) return null;

    final stats = await _getClientStats(clientId);
    return ClientModel.fromJson({
      ...response,
      ...stats,
    });
  }

  /// Get client project history.
  Future<List<ClientProjectHistory>> getClientProjects(
    String clientId, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (_currentUserId == null) return [];

    final response = await _client
        .from('projects')
        .select('id, title, status, created_at, completed_at, user_quote')
        .eq('user_id', clientId)
        .eq('supervisor_id', _currentUserId!)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List).map((json) {
      return ClientProjectHistory.fromJson({
        ...json,
        'project_id': json['id'],
        'amount': json['user_quote'],
      });
    }).toList();
  }

  /// Update client notes.
  Future<void> updateClientNotes(String clientId, String notes) async {
    // Store supervisor's notes about client in a separate table
    await _client.from('supervisor_client_notes').upsert({
      'supervisor_id': _currentUserId!,
      'client_id': clientId,
      'notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get client notes.
  Future<String?> getClientNotes(String clientId) async {
    if (_currentUserId == null) return null;

    final response = await _client
        .from('supervisor_client_notes')
        .select('notes')
        .eq('supervisor_id', _currentUserId!)
        .eq('client_id', clientId)
        .maybeSingle();

    return response?['notes'] as String?;
  }

  /// Search clients.
  Future<List<ClientModel>> searchClients(String query) async {
    if (_currentUserId == null) return [];
    if (query.isEmpty) return [];

    // Get user IDs from supervisor's projects
    final projectUsers = await _client
        .from('projects')
        .select('user_id')
        .eq('supervisor_id', _currentUserId!);

    final userIds = (projectUsers as List)
        .map((p) => p['user_id'] as String)
        .toSet()
        .toList();

    if (userIds.isEmpty) return [];

    final response = await _client
        .from('profiles')
        .select()
        .inFilter('id', userIds)
        .or('full_name.ilike.%$query%,email.ilike.%$query%')
        .limit(10);

    return (response as List)
        .map((json) => ClientModel.fromJson(json))
        .toList();
  }

  /// Get total clients count.
  Future<int> getClientsCount() async {
    if (_currentUserId == null) return 0;

    final response = await _client
        .from('projects')
        .select('user_id')
        .eq('supervisor_id', _currentUserId!);

    return (response as List)
        .map((p) => p['user_id'] as String)
        .toSet()
        .length;
  }
}

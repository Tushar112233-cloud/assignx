import '../../../../core/api/api_client.dart';
import '../models/client_model.dart';

/// Repository for user/client operations.
class UsersRepository {
  UsersRepository();

  /// Fetch clients with pagination.
  Future<List<ClientModel>> getClients({
    int limit = 20,
    int offset = 0,
    String? search,
    String? sortBy,
    bool ascending = false,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      'ascending': '$ascending',
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await ApiClient.get('/supervisor/clients?$query');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['clients'] as List? ?? [];

    return list
        .map((json) => ClientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get client by ID.
  Future<ClientModel?> getClientById(String clientId) async {
    try {
      final response = await ApiClient.get('/supervisor/clients/$clientId');
      if (response == null) return null;
      return ClientModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Get client project history.
  Future<List<ClientProjectHistory>> getClientProjects(
    String clientId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await ApiClient.get(
      '/supervisor/clients/$clientId/projects?limit=$limit&offset=$offset',
    );
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['projects'] as List? ?? [];

    return list.map((json) {
      final map = json as Map<String, dynamic>;
      return ClientProjectHistory.fromJson({
        ...map,
        'project_id': map['id'] ?? map['project_id'],
        'amount': map['user_quote'] ?? map['amount'],
      });
    }).toList();
  }

  /// Update client notes.
  Future<void> updateClientNotes(String clientId, String notes) async {
    await ApiClient.put('/supervisor/clients/$clientId/notes', {
      'notes': notes,
    });
  }

  /// Get client notes.
  Future<String?> getClientNotes(String clientId) async {
    try {
      final response = await ApiClient.get('/supervisor/clients/$clientId/notes');
      if (response is Map<String, dynamic>) {
        return response['notes'] as String?;
      }
    } catch (_) {}
    return null;
  }

  /// Search clients.
  Future<List<ClientModel>> searchClients(String query) async {
    if (query.isEmpty) return [];

    final response = await ApiClient.get(
      '/supervisor/clients?search=$query&limit=10',
    );
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['clients'] as List? ?? [];

    return list
        .map((json) => ClientModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get total clients count.
  Future<int> getClientsCount() async {
    final response = await ApiClient.get('/supervisor/clients/count');
    if (response is Map<String, dynamic>) {
      return response['count'] as int? ?? 0;
    }
    return 0;
  }
}

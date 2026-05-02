import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/client_model.dart';
import '../../data/repositories/users_repository.dart';

/// Provider for users repository.
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

/// State for clients list.
class ClientsState {
  const ClientsState({
    this.clients = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.searchQuery = '',
    this.sortBy = 'created_at',
    this.ascending = false,
  });

  final List<ClientModel> clients;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  final String searchQuery;
  final String sortBy;
  final bool ascending;

  ClientsState copyWith({
    List<ClientModel>? clients,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    String? searchQuery,
    String? sortBy,
    bool? ascending,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Notifier for clients list.
class ClientsNotifier extends StateNotifier<ClientsState> {
  ClientsNotifier(this._repository) : super(const ClientsState());

  final UsersRepository _repository;
  static const _pageSize = 20;

  /// Load clients.
  Future<void> loadClients() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final clients = await _repository.getClients(
        limit: _pageSize,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        sortBy: state.sortBy,
        ascending: state.ascending,
      );

      state = state.copyWith(
        clients: clients,
        isLoading: false,
        hasMore: clients.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more clients.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final clients = await _repository.getClients(
        limit: _pageSize,
        offset: state.clients.length,
        search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        sortBy: state.sortBy,
        ascending: state.ascending,
      );

      state = state.copyWith(
        clients: [...state.clients, ...clients],
        isLoadingMore: false,
        hasMore: clients.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh clients.
  Future<void> refresh() async {
    await loadClients();
  }

  /// Search clients.
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadClients();
  }

  /// Sort clients.
  Future<void> sort(String sortBy, {bool ascending = false}) async {
    state = state.copyWith(sortBy: sortBy, ascending: ascending);
    await loadClients();
  }

  /// Clear search.
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
    loadClients();
  }
}

/// Provider for clients list.
final clientsProvider =
    StateNotifierProvider<ClientsNotifier, ClientsState>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return ClientsNotifier(repository);
});

/// State for client detail.
class ClientDetailState {
  const ClientDetailState({
    this.client,
    this.projects = const [],
    this.isLoading = false,
    this.isLoadingProjects = false,
    this.hasMoreProjects = true,
    this.error,
    this.notes,
  });

  final ClientModel? client;
  final List<ClientProjectHistory> projects;
  final bool isLoading;
  final bool isLoadingProjects;
  final bool hasMoreProjects;
  final String? error;
  final String? notes;

  ClientDetailState copyWith({
    ClientModel? client,
    List<ClientProjectHistory>? projects,
    bool? isLoading,
    bool? isLoadingProjects,
    bool? hasMoreProjects,
    String? error,
    String? notes,
  }) {
    return ClientDetailState(
      client: client ?? this.client,
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      isLoadingProjects: isLoadingProjects ?? this.isLoadingProjects,
      hasMoreProjects: hasMoreProjects ?? this.hasMoreProjects,
      error: error,
      notes: notes ?? this.notes,
    );
  }
}

/// Notifier for client detail.
class ClientDetailNotifier extends StateNotifier<ClientDetailState> {
  ClientDetailNotifier(this._repository) : super(const ClientDetailState());

  final UsersRepository _repository;
  static const _pageSize = 20;

  /// Load client detail.
  Future<void> loadClient(String clientId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final client = await _repository.getClientById(clientId);
      final notes = await _repository.getClientNotes(clientId);

      if (client == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Client not found',
        );
        return;
      }

      state = state.copyWith(
        client: client,
        notes: notes,
        isLoading: false,
      );

      // Load projects
      await loadProjects(clientId);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load client projects.
  Future<void> loadProjects(String clientId) async {
    state = state.copyWith(isLoadingProjects: true);

    try {
      final projects = await _repository.getClientProjects(
        clientId,
        limit: _pageSize,
      );

      state = state.copyWith(
        projects: projects,
        isLoadingProjects: false,
        hasMoreProjects: projects.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProjects: false,
        error: e.toString(),
      );
    }
  }

  /// Load more projects.
  Future<void> loadMoreProjects(String clientId) async {
    if (state.isLoadingProjects || !state.hasMoreProjects) return;

    state = state.copyWith(isLoadingProjects: true);

    try {
      final projects = await _repository.getClientProjects(
        clientId,
        limit: _pageSize,
        offset: state.projects.length,
      );

      state = state.copyWith(
        projects: [...state.projects, ...projects],
        isLoadingProjects: false,
        hasMoreProjects: projects.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingProjects: false,
        error: e.toString(),
      );
    }
  }

  /// Update notes.
  Future<bool> updateNotes(String clientId, String notes) async {
    try {
      await _repository.updateClientNotes(clientId, notes);
      state = state.copyWith(notes: notes);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Provider for client detail.
final clientDetailProvider =
    StateNotifierProvider<ClientDetailNotifier, ClientDetailState>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return ClientDetailNotifier(repository);
});

/// Provider for clients count.
final clientsCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getClientsCount();
});

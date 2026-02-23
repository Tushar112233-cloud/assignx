/// State management providers for the dashboard feature.
///
/// This file contains:
/// - [DashboardState] and [DashboardNotifier]: Main dashboard state management
/// - [DoerSelectionState] and [DoerSelectionNotifier]: Doer selection state
/// - [QuoteFormState] and [QuoteFormNotifier]: Quote form state
/// - Provider definitions for dependency injection
///
/// Uses Riverpod for reactive state management with [StateNotifier] pattern.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/models/request_model.dart';
import '../../data/models/doer_model.dart';
import '../../data/models/quote_model.dart';
import '../../data/repositories/dashboard_repository.dart';

/// Immutable state class for the main dashboard.
///
/// Contains all data needed to render the dashboard including
/// request lists, loading state, errors, and filters.
///
/// ## Usage
///
/// ```dart
/// final state = ref.watch(dashboardProvider);
/// if (state.isLoading) {
///   return CircularProgressIndicator();
/// }
/// return ListView(children: state.filteredNewRequests.map(...));
/// ```
///
/// See also:
/// - [DashboardNotifier] for state mutations
/// - [dashboardProvider] for accessing state
class DashboardState {
  /// Creates a new [DashboardState] instance.
  ///
  /// All parameters have sensible defaults for an initial state.
  const DashboardState({
    this.newRequests = const [],
    this.paidRequests = const [],
    this.isLoading = false,
    this.error,
    this.selectedSubject = 'All',
    this.isAvailable = true,
  });

  /// List of new requests awaiting quotes.
  ///
  /// These are projects with status "submitted" assigned to
  /// the current supervisor.
  final List<RequestModel> newRequests;

  /// List of paid requests ready for doer assignment.
  ///
  /// These are projects with status "paid" that need a doer
  /// to be assigned.
  final List<RequestModel> paidRequests;

  /// Whether data is currently being loaded.
  ///
  /// Used to show loading indicators in the UI.
  final bool isLoading;

  /// Error message if the last operation failed.
  ///
  /// Null if no error occurred.
  final String? error;

  /// Currently selected subject filter.
  ///
  /// Defaults to "All" (no filter). Used to filter both
  /// [newRequests] and [paidRequests].
  final String selectedSubject;

  /// Supervisor's current availability status.
  ///
  /// True if accepting new requests, false otherwise.
  final bool isAvailable;

  /// Total count of pending requests (new + paid).
  ///
  /// Useful for displaying badge counts in notifications.
  int get pendingCount => newRequests.length + paidRequests.length;

  /// Filtered list of new requests based on selected subject.
  ///
  /// Returns all [newRequests] if [selectedSubject] is "All",
  /// otherwise returns only requests matching the subject.
  ///
  /// This is a computed property that filters on access.
  List<RequestModel> get filteredNewRequests {
    if (selectedSubject == 'All') return newRequests;
    return newRequests.where((r) => r.subject == selectedSubject).toList();
  }

  /// Filtered list of paid requests based on selected subject.
  ///
  /// Returns all [paidRequests] if [selectedSubject] is "All",
  /// otherwise returns only requests matching the subject.
  ///
  /// This is a computed property that filters on access.
  List<RequestModel> get filteredPaidRequests {
    if (selectedSubject == 'All') return paidRequests;
    return paidRequests.where((r) => r.subject == selectedSubject).toList();
  }

  /// Creates a copy of this state with the specified fields replaced.
  ///
  /// Parameters:
  /// - [clearError]: If true, sets [error] to null regardless of [error] param
  ///
  /// Returns a new [DashboardState] instance with updated values.
  DashboardState copyWith({
    List<RequestModel>? newRequests,
    List<RequestModel>? paidRequests,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? selectedSubject,
    bool? isAvailable,
  }) {
    return DashboardState(
      newRequests: newRequests ?? this.newRequests,
      paidRequests: paidRequests ?? this.paidRequests,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedSubject: selectedSubject ?? this.selectedSubject,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

/// State notifier for the main dashboard.
///
/// Manages [DashboardState] and provides methods for loading data,
/// filtering, and updating supervisor availability.
///
/// ## Usage
///
/// ```dart
/// // Access the notifier
/// final notifier = ref.read(dashboardProvider.notifier);
///
/// // Load dashboard data
/// await notifier.loadDashboard();
///
/// // Filter by subject
/// notifier.filterBySubject('Computer Science');
///
/// // Toggle availability
/// await notifier.toggleAvailability();
/// ```
///
/// See also:
/// - [DashboardState] for the state structure
/// - [DashboardRepository] for data operations
class DashboardNotifier extends StateNotifier<DashboardState> {
  /// Creates a new [DashboardNotifier] instance.
  ///
  /// Automatically loads dashboard data on initialization.
  DashboardNotifier(this._repository) : super(const DashboardState()) {
    loadDashboard();
  }

  /// The repository used for data operations.
  final DashboardRepository _repository;

  /// Loads all dashboard data from the repository.
  ///
  /// Fetches new requests, paid requests, and availability status
  /// in parallel. Updates state with results or error message.
  ///
  /// This method is called automatically on initialization and
  /// can be called manually to refresh data.
  Future<void> loadDashboard() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final results = await Future.wait([
        _repository.getNewRequests(),
        _repository.getPaidRequests(),
        _repository.getAvailability(),
      ]);

      state = state.copyWith(
        newRequests: results[0] as List<RequestModel>,
        paidRequests: results[1] as List<RequestModel>,
        isAvailable: results[2] as bool,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard: $e',
      );
    }
  }

  /// Refreshes dashboard data.
  ///
  /// Convenience method that calls [loadDashboard].
  /// Use with pull-to-refresh widgets.
  Future<void> refresh() async {
    await loadDashboard();
  }

  /// Filters requests by subject.
  ///
  /// Updates [DashboardState.selectedSubject] which affects
  /// [DashboardState.filteredNewRequests] and
  /// [DashboardState.filteredPaidRequests].
  ///
  /// Parameters:
  /// - [subject]: The subject to filter by, or "All" for no filter
  void filterBySubject(String subject) {
    state = state.copyWith(selectedSubject: subject);
  }

  /// Toggles supervisor availability status.
  ///
  /// Uses optimistic UI update pattern:
  /// 1. Immediately updates UI to new value
  /// 2. Persists change to database
  /// 3. Reverts to previous value if persistence fails
  ///
  /// This provides instant feedback while ensuring data consistency.
  Future<void> toggleAvailability() async {
    // Capture the current value BEFORE any state changes
    final previousValue = state.isAvailable;
    final newValue = !previousValue;

    try {
      // Optimistically update the UI
      state = state.copyWith(isAvailable: newValue);

      // Persist to database
      await _repository.updateAvailability(newValue);
    } catch (e) {
      // Revert to the captured previous value on error
      state = state.copyWith(
        isAvailable: previousValue,
        error: 'Failed to update availability',
      );
    }
  }

  /// Clears the current error message.
  ///
  /// Use after displaying or acknowledging an error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Immutable state class for doer selection.
///
/// Contains the list of available doers, filtered results,
/// and search/filter parameters.
///
/// See also:
/// - [DoerSelectionNotifier] for state mutations
/// - [doerSelectionProvider] for accessing state
class DoerSelectionState {
  /// Creates a new [DoerSelectionState] instance.
  const DoerSelectionState({
    this.doers = const [],
    this.filteredDoers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.selectedExpertise = 'All',
  });

  /// Complete list of available doers.
  ///
  /// This is the unfiltered list from the repository.
  final List<DoerModel> doers;

  /// Filtered list of doers based on search and expertise.
  ///
  /// Updated when [searchQuery] or [selectedExpertise] changes.
  final List<DoerModel> filteredDoers;

  /// Whether doers are currently being loaded.
  final bool isLoading;

  /// Error message if the last operation failed.
  final String? error;

  /// Current search query for filtering by name.
  final String searchQuery;

  /// Currently selected expertise/subject filter.
  final String selectedExpertise;

  /// Creates a copy of this state with the specified fields replaced.
  DoerSelectionState copyWith({
    List<DoerModel>? doers,
    List<DoerModel>? filteredDoers,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? searchQuery,
    String? selectedExpertise,
  }) {
    return DoerSelectionState(
      doers: doers ?? this.doers,
      filteredDoers: filteredDoers ?? this.filteredDoers,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
      selectedExpertise: selectedExpertise ?? this.selectedExpertise,
    );
  }
}

/// State notifier for doer selection.
///
/// Manages [DoerSelectionState] and provides methods for loading doers,
/// searching, filtering, and assigning doers to projects.
///
/// ## Usage
///
/// ```dart
/// final notifier = ref.read(doerSelectionProvider.notifier);
///
/// // Load doers for a specific subject
/// await notifier.loadDoers(expertise: 'Computer Science');
///
/// // Search by name
/// notifier.search('John');
///
/// // Assign doer to project
/// final success = await notifier.assignDoer(projectId, doerId);
/// ```
///
/// See also:
/// - [DoerSelectionState] for the state structure
/// - [DashboardRepository.getAvailableDoers] for data fetching
class DoerSelectionNotifier extends StateNotifier<DoerSelectionState> {
  /// Creates a new [DoerSelectionNotifier] instance.
  DoerSelectionNotifier(this._repository) : super(const DoerSelectionState());

  /// The repository used for data operations.
  final DashboardRepository _repository;

  /// Loads available doers from the repository.
  ///
  /// Parameters:
  /// - [expertise]: Optional expertise/subject filter
  ///
  /// Updates state with loaded doers or error message.
  Future<void> loadDoers({String? expertise}) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final doers = await _repository.getAvailableDoers(expertise: expertise);
      state = state.copyWith(
        doers: doers,
        filteredDoers: doers,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load doers: $e',
      );
    }
  }

  /// Searches doers by name.
  ///
  /// Updates [DoerSelectionState.searchQuery] and applies filters.
  ///
  /// Parameters:
  /// - [query]: The search query (case-insensitive substring match)
  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Filters doers by expertise/subject.
  ///
  /// Updates [DoerSelectionState.selectedExpertise] and applies filters.
  ///
  /// Parameters:
  /// - [expertise]: The expertise to filter by, or "All" for no filter
  void filterByExpertise(String expertise) {
    state = state.copyWith(selectedExpertise: expertise);
    _applyFilters();
  }

  /// Applies current search and expertise filters to the doers list.
  ///
  /// Called internally when search query or expertise filter changes.
  /// Updates [DoerSelectionState.filteredDoers] with matching doers.
  void _applyFilters() {
    var filtered = state.doers;

    // Apply search
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((d) =>
              d.name.toLowerCase().contains(state.searchQuery.toLowerCase()))
          .toList();
    }

    // Apply expertise filter
    if (state.selectedExpertise != 'All') {
      filtered = filtered
          .where((d) => d.expertise.contains(state.selectedExpertise))
          .toList();
    }

    state = state.copyWith(filteredDoers: filtered);
  }

  /// Assigns a doer to a project.
  ///
  /// Parameters:
  /// - [requestId]: The ID of the project to assign
  /// - [doerId]: The ID of the doer to assign
  ///
  /// Returns `true` if assignment was successful, `false` otherwise.
  /// Sets error state if the operation fails.
  Future<bool> assignDoer(String requestId, String doerId) async {
    try {
      await _repository.assignDoer(requestId, doerId);
      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to assign doer: $e');
      return false;
    }
  }
}

/// Immutable state class for the quote form.
///
/// Contains quote items, notes, submission state, and errors.
///
/// See also:
/// - [QuoteFormNotifier] for state mutations
/// - [quoteFormProvider] for accessing state
class QuoteFormState {
  /// Creates a new [QuoteFormState] instance.
  const QuoteFormState({
    this.items = const [],
    this.notes = '',
    this.isSubmitting = false,
    this.error,
  });

  /// List of quote line items.
  ///
  /// Each [QuoteItem] represents a component of the total price.
  final List<QuoteItem> items;

  /// Additional notes for the quote.
  ///
  /// Optional text message to include with the quote.
  final String notes;

  /// Whether the quote is currently being submitted.
  final bool isSubmitting;

  /// Error message if the last operation failed.
  final String? error;

  /// Calculates the total price from all items.
  ///
  /// Sums the [QuoteItem.amount] of all items in [items].
  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.amount);

  /// Creates a copy of this state with the specified fields replaced.
  QuoteFormState copyWith({
    List<QuoteItem>? items,
    String? notes,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return QuoteFormState(
      items: items ?? this.items,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// State notifier for the quote form.
///
/// Manages [QuoteFormState] and provides methods for creating
/// and submitting quotes.
///
/// ## Usage
///
/// ```dart
/// final notifier = ref.read(quoteFormProvider.notifier);
///
/// // Initialize with default items based on request
/// notifier.initialize(request);
///
/// // Add custom item
/// notifier.addItem(QuoteItem(description: 'Research', amount: 50.0));
///
/// // Submit the quote
/// final success = await notifier.submit(requestId);
/// ```
///
/// See also:
/// - [QuoteFormState] for the state structure
/// - [QuoteModel] for the quote data model
class QuoteFormNotifier extends StateNotifier<QuoteFormState> {
  /// Creates a new [QuoteFormNotifier] instance.
  QuoteFormNotifier(this._repository) : super(const QuoteFormState());

  /// The repository used for data operations.
  final DashboardRepository _repository;

  /// Initializes the form with default items based on request.
  ///
  /// Creates default quote items based on the request's word count
  /// and page count using [createDefaultQuoteItems].
  ///
  /// Parameters:
  /// - [request]: The request to generate quote items for
  void initialize(RequestModel request) {
    final items = createDefaultQuoteItems(
      wordCount: request.wordCount,
      pageCount: request.pageCount,
    );
    state = state.copyWith(items: items);
  }

  /// Adds a new item to the quote.
  ///
  /// Parameters:
  /// - [item]: The [QuoteItem] to add
  void addItem(QuoteItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  /// Removes an item from the quote by index.
  ///
  /// Parameters:
  /// - [index]: The index of the item to remove
  void removeItem(int index) {
    final items = List<QuoteItem>.from(state.items);
    items.removeAt(index);
    state = state.copyWith(items: items);
  }

  /// Updates the notes field.
  ///
  /// Parameters:
  /// - [notes]: The new notes text
  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  /// Submits the quote to the repository.
  ///
  /// Validates that at least one item exists, creates a [QuoteModel],
  /// and submits it via the repository.
  ///
  /// Parameters:
  /// - [requestId]: The ID of the request to submit the quote for
  ///
  /// Returns `true` if submission was successful, `false` otherwise.
  /// Sets error state if validation fails or submission errors.
  Future<bool> submit(String requestId) async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'Please add at least one item');
      return false;
    }

    try {
      state = state.copyWith(isSubmitting: true, clearError: true);

      final quote = QuoteModel(
        requestId: requestId,
        totalPrice: state.totalPrice,
        breakdown: state.items,
        createdAt: DateTime.now(),
      );

      await _repository.submitQuote(quote);

      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Failed to submit quote: $e',
      );
      return false;
    }
  }

  /// Resets the form to its initial empty state.
  ///
  /// Use when closing the form or starting a new quote.
  void reset() {
    state = const QuoteFormState();
  }
}

// =============================================================================
// Provider Definitions
// =============================================================================

/// Provider for the [DashboardRepository] instance.
///
/// Provides a singleton repository that uses the global Supabase client.
/// Use this to access the repository directly if needed.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(ref.watch(supabaseClientProvider));
});

/// Provider for the main dashboard state.
///
/// Provides access to [DashboardState] and [DashboardNotifier].
///
/// Usage:
/// ```dart
/// // Read state
/// final state = ref.watch(dashboardProvider);
///
/// // Access notifier
/// final notifier = ref.read(dashboardProvider.notifier);
/// ```
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});

/// Provider for doer selection state.
///
/// Provides access to [DoerSelectionState] and [DoerSelectionNotifier].
///
/// Usage:
/// ```dart
/// // Read state
/// final state = ref.watch(doerSelectionProvider);
///
/// // Access notifier
/// final notifier = ref.read(doerSelectionProvider.notifier);
/// ```
final doerSelectionProvider =
    StateNotifierProvider<DoerSelectionNotifier, DoerSelectionState>((ref) {
  return DoerSelectionNotifier(ref.watch(dashboardRepositoryProvider));
});

/// Provider for quote form state.
///
/// Provides access to [QuoteFormState] and [QuoteFormNotifier].
///
/// Usage:
/// ```dart
/// // Read state
/// final state = ref.watch(quoteFormProvider);
///
/// // Access notifier
/// final notifier = ref.read(quoteFormProvider.notifier);
/// ```
final quoteFormProvider =
    StateNotifierProvider<QuoteFormNotifier, QuoteFormState>((ref) {
  return QuoteFormNotifier(ref.watch(dashboardRepositoryProvider));
});

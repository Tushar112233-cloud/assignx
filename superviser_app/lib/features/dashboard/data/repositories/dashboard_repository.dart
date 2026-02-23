/// Repository for dashboard-related database operations.
///
/// This file contains:
/// - [DashboardRepository]: The main repository class for dashboard operations
///
/// The repository provides an abstraction layer between the UI/business logic
/// and the Supabase database, handling all CRUD operations for projects,
/// doers, quotes, and supervisor settings.
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/network/api_exceptions.dart';
import '../models/request_model.dart';
import '../models/doer_model.dart';
import '../models/quote_model.dart';

/// Repository for dashboard-related database operations.
///
/// This repository handles all Supabase interactions for the supervisor
/// dashboard, including fetching requests, managing quotes, assigning doers,
/// and updating supervisor availability.
///
/// ## Usage
///
/// ```dart
/// final repository = DashboardRepository(supabaseClient);
///
/// // Fetch new requests
/// final requests = await repository.getNewRequests();
///
/// // Submit a quote
/// await repository.submitQuote(quote);
///
/// // Assign a doer
/// await repository.assignDoer(projectId, doerId);
/// ```
///
/// ## Error Handling
///
/// All methods may throw:
/// - [AppAuthException]: If the user is not authenticated
/// - [ServerException]: If a database operation fails
///
/// See also:
/// - [RequestModel] for project request data
/// - [DoerModel] for doer data
/// - [QuoteModel] for quote data
class DashboardRepository {
  /// Creates a new [DashboardRepository] instance.
  ///
  /// Requires a [SupabaseClient] instance for database operations.
  DashboardRepository(this._client);

  /// The Supabase client used for database operations.
  final SupabaseClient _client;

  /// SQL select query for projects with joined data.
  ///
  /// This query string fetches project data along with:
  /// - User profile (client info) via `user_id`
  /// - Subject details via `subject_id`
  /// - Doer info with nested profile via `doer_id`
  static const String _projectSelect = '''
    *,
    user:profiles!user_id(id, full_name, email, avatar_url),
    subject:subjects!subject_id(id, name),
    doer:doers!doer_id(
      id,
      profile:profiles!profile_id(full_name, email, avatar_url)
    )
  ''';

  /// Gets the supervisor ID for the currently authenticated user.
  ///
  /// Looks up the supervisor record in the `supervisors` table using
  /// the current user's profile ID.
  ///
  /// Returns the supervisor's UUID if found, or `null` if the user
  /// is not a registered supervisor.
  ///
  /// Throws:
  /// - [AppAuthException]: If no user is currently authenticated
  /// - [ServerException]: If the database query fails
  Future<String?> _getSupervisorId() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final response = await _client
          .from('supervisors')
          .select('id')
          .eq('profile_id', userId)
          .maybeSingle();

      return response?['id'] as String?;
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Fetches new requests (submitted projects pending quotes).
  ///
  /// Retrieves all projects assigned to the current supervisor that
  /// have a status of "submitted" (awaiting quote). Results are
  /// ordered by creation date, newest first.
  ///
  /// Returns a [List] of [RequestModel] objects representing the new requests.
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated or not a supervisor
  /// - [ServerException]: If the database query fails
  ///
  /// Example:
  /// ```dart
  /// final newRequests = await repository.getNewRequests();
  /// print('${newRequests.length} new requests awaiting quotes');
  /// ```
  Future<List<RequestModel>> getNewRequests() async {
    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) {
      throw const AppAuthException('Supervisor not found. Please log in again.');
    }

    try {
      final response = await _client
          .from('projects')
          .select(_projectSelect)
          .eq('supervisor_id', supervisorId)
          .eq('status', 'submitted')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => RequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Fetches paid projects ready for doer assignment.
  ///
  /// Retrieves all projects assigned to the current supervisor that
  /// have a status of "paid" and `is_paid` flag set to true. These
  /// projects are ready to be assigned to a doer. Results are
  /// ordered by deadline, soonest first.
  ///
  /// Returns a [List] of [RequestModel] objects representing paid requests.
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated or not a supervisor
  /// - [ServerException]: If the database query fails
  ///
  /// Example:
  /// ```dart
  /// final paidRequests = await repository.getPaidRequests();
  /// for (final request in paidRequests) {
  ///   print('${request.title} - deadline: ${request.formattedDeadline}');
  /// }
  /// ```
  Future<List<RequestModel>> getPaidRequests() async {
    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) {
      throw const AppAuthException('Supervisor not found. Please log in again.');
    }

    try {
      final response = await _client
          .from('projects')
          .select(_projectSelect)
          .eq('supervisor_id', supervisorId)
          .eq('status', 'paid')
          .eq('is_paid', true)
          .order('deadline', ascending: true);

      return (response as List)
          .map((json) => RequestModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Fetches projects filtered by subject.
  ///
  /// Retrieves all projects assigned to the current supervisor,
  /// optionally filtered by subject name. Results are ordered by
  /// creation date, newest first.
  ///
  /// Parameters:
  /// - [subject]: The subject to filter by. Use "All" for no filter.
  ///
  /// Returns a [List] of [RequestModel] objects matching the filter.
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated or not a supervisor
  /// - [ServerException]: If the database query fails
  ///
  /// Note: Subject filtering is currently done client-side. This should
  /// be moved to database-side filtering for better performance with
  /// large datasets.
  Future<List<RequestModel>> getRequestsBySubject(String subject) async {
    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) {
      throw const AppAuthException('Supervisor not found. Please log in again.');
    }

    try {
      final response = await _client
          .from('projects')
          .select(_projectSelect)
          .eq('supervisor_id', supervisorId)
          .order('created_at', ascending: false);

      var projects = (response as List)
          .map((json) => RequestModel.fromJson(json))
          .toList();

      // Filter by subject name if not 'All'
      // TODO: Move this filter to database-side for better performance
      if (subject != 'All') {
        projects = projects.where((p) => p.subject == subject).toList();
      }

      return projects;
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Submits a price quote for a project.
  ///
  /// Creates a new quote record in the `project_quotes` table and
  /// updates the project status to "quoted" with the quoted amount.
  ///
  /// Parameters:
  /// - [quote]: The [QuoteModel] containing quote details
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated or not a supervisor
  /// - [ServerException]: If the database operation fails
  ///
  /// Example:
  /// ```dart
  /// final quote = QuoteModel(
  ///   requestId: 'project-123',
  ///   totalPrice: 150.00,
  ///   doerAmount: 100.00,
  /// );
  /// await repository.submitQuote(quote);
  /// ```
  Future<void> submitQuote(QuoteModel quote) async {
    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) {
      throw const AppAuthException('Supervisor not found. Please log in again.');
    }

    try {
      // Insert into project_quotes table
      await _client.from('project_quotes').insert({
        'project_id': quote.requestId,
        'user_amount': quote.totalPrice,
        'doer_amount': quote.doerAmount ?? 0,
        'supervisor_amount': quote.supervisorAmount ?? 0,
        'platform_amount': quote.platformAmount ?? 0,
        'base_price': quote.basePrice,
        'urgency_fee': quote.urgencyFee ?? 0,
        'complexity_fee': quote.complexityFee ?? 0,
        'status': 'pending',
        'quoted_by': supervisorId,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update project status and quote amount
      await _client
          .from('projects')
          .update({
            'status': 'quoted',
            'user_quote': quote.totalPrice,
            'status_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', quote.requestId);
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Fetches available doers for project assignment.
  ///
  /// Retrieves all doers who are both available (`is_available = true`)
  /// and activated (`is_activated = true`). Results are ordered by
  /// average rating, highest first.
  ///
  /// Parameters:
  /// - [expertise]: Optional subject/expertise filter. Use "All" or null
  ///   for no filter.
  ///
  /// Returns a [List] of [DoerModel] objects representing available doers.
  ///
  /// Throws:
  /// - [ServerException]: If the database query fails
  ///
  /// Note: Expertise filtering is currently done client-side. This should
  /// be moved to database-side filtering for better performance.
  ///
  /// Example:
  /// ```dart
  /// final doers = await repository.getAvailableDoers(
  ///   expertise: 'Computer Science',
  /// );
  /// ```
  Future<List<DoerModel>> getAvailableDoers({String? expertise}) async {
    try {
      final response = await _client
          .from('doers')
          .select('''
            *,
            profile:profiles!profile_id(id, full_name, email, avatar_url),
            subjects:doer_subjects(subject:subjects(id, name))
          ''')
          .eq('is_available', true)
          .eq('is_activated', true)
          .order('average_rating', ascending: false);

      var doers = (response as List)
          .map((json) => DoerModel.fromJson(json))
          .toList();

      // Filter by expertise/subject if provided
      // TODO: Move this filter to database-side for better performance
      if (expertise != null && expertise != 'All') {
        doers = doers.where((d) => d.expertise.contains(expertise)).toList();
      }

      return doers;
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Assigns a doer to a project.
  ///
  /// Updates the project with the assigned doer and creates an
  /// assignment record in the `project_assignments` table.
  ///
  /// Parameters:
  /// - [projectId]: The ID of the project to assign
  /// - [doerId]: The ID of the doer to assign
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated or not a supervisor
  /// - [ServerException]: If the database operation fails
  ///
  /// Example:
  /// ```dart
  /// await repository.assignDoer('project-123', 'doer-456');
  /// ```
  Future<void> assignDoer(String projectId, String doerId) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    final supervisorId = await _getSupervisorId();
    if (supervisorId == null) {
      throw const AppAuthException('Supervisor not found. Please log in again.');
    }

    try {
      // Update project with doer assignment
      await _client
          .from('projects')
          .update({
            'doer_id': doerId,
            'status': 'assigned',
            'doer_assigned_at': DateTime.now().toIso8601String(),
            'status_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      // Create assignment record
      await _client.from('project_assignments').insert({
        'project_id': projectId,
        'assignment_type': 'doer',
        'assignee_id': doerId,
        'assigned_by': userId,
        'status': 'active',
        'assigned_at': DateTime.now().toIso8601String(),
      });
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Gets reviews for a specific doer.
  ///
  /// Retrieves the most recent reviews for a doer, including
  /// reviewer name and project title from joined tables.
  ///
  /// Parameters:
  /// - [doerId]: The ID of the doer to get reviews for
  ///
  /// Returns a [List] of [DoerReview] objects, limited to 10 most recent.
  ///
  /// Throws:
  /// - [ServerException]: If the database query fails
  ///
  /// Example:
  /// ```dart
  /// final reviews = await repository.getDoerReviews('doer-123');
  /// for (final review in reviews) {
  ///   print('${review.rating}/5 - ${review.comment}');
  /// }
  /// ```
  Future<List<DoerReview>> getDoerReviews(String doerId) async {
    try {
      final response = await _client
          .from('doer_reviews')
          .select('''
            *,
            reviewer:profiles!reviewer_id(full_name),
            project:projects!project_id(title)
          ''')
          .eq('doer_id', doerId)
          .order('created_at', ascending: false)
          .limit(10);

      return (response as List)
          .map((json) => DoerReview.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Updates the supervisor's availability status.
  ///
  /// Sets whether the supervisor is available to receive new project
  /// assignments. This affects whether new projects will be routed
  /// to this supervisor.
  ///
  /// Parameters:
  /// - [isAvailable]: The new availability status
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated
  /// - [ServerException]: If the database operation fails
  ///
  /// Example:
  /// ```dart
  /// // Set supervisor as unavailable
  /// await repository.updateAvailability(false);
  /// ```
  Future<void> updateAvailability(bool isAvailable) async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _client
          .from('supervisors')
          .update({
            'is_available': isAvailable,
            'availability_updated_at': DateTime.now().toIso8601String(),
          })
          .eq('profile_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }

  /// Gets the supervisor's current availability status.
  ///
  /// Returns the current availability setting for the authenticated
  /// supervisor.
  ///
  /// Returns `true` if available, `false` if not, or `true` as default
  /// if no setting is found.
  ///
  /// Throws:
  /// - [AppAuthException]: If not authenticated
  /// - [ServerException]: If the database query fails
  ///
  /// Example:
  /// ```dart
  /// final isAvailable = await repository.getAvailability();
  /// print('Supervisor is ${isAvailable ? 'available' : 'unavailable'}');
  /// ```
  Future<bool> getAvailability() async {
    final userId = getCurrentUserId();
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final response = await _client
          .from('supervisors')
          .select('is_available')
          .eq('profile_id', userId)
          .maybeSingle();

      return response?['is_available'] as bool? ?? true;
    } on PostgrestException catch (e) {
      throw ServerException.fromPostgrest(e);
    }
  }
}

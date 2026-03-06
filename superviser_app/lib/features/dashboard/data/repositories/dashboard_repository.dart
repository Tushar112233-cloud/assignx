/// Repository for dashboard-related database operations.
///
/// This file contains:
/// - [DashboardRepository]: The main repository class for dashboard operations
///
/// The repository provides an abstraction layer between the UI/business logic
/// and the Express API, handling all CRUD operations for projects,
/// doers, quotes, and supervisor settings.
library;

import '../../../../core/api/api_client.dart' hide ApiException;
import '../../../../core/network/api_exceptions.dart';
import '../models/request_model.dart';
import '../models/doer_model.dart';
import '../models/quote_model.dart';

/// Repository for dashboard-related API operations.
class DashboardRepository {
  /// Creates a new [DashboardRepository] instance.
  DashboardRepository();

  /// Fetches new requests (submitted projects pending quotes).
  Future<List<RequestModel>> getNewRequests() async {
    try {
      final response = await ApiClient.get(
        '/supervisor/dashboard/requests?status=submitted',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch new requests: $e', null);
    }
  }

  /// Fetches paid projects ready for doer assignment.
  Future<List<RequestModel>> getPaidRequests() async {
    try {
      final response = await ApiClient.get(
        '/supervisor/dashboard/requests?status=paid',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch paid requests: $e', null);
    }
  }

  /// Fetches projects filtered by subject.
  Future<List<RequestModel>> getRequestsBySubject(String subject) async {
    try {
      final subjectParam = subject != 'All' ? '&subject=$subject' : '';
      final response = await ApiClient.get(
        '/supervisor/dashboard/requests?$subjectParam',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['projects'] as List? ?? [];

      return list
          .map((json) => RequestModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch requests: $e', null);
    }
  }

  /// Submits a price quote for a project.
  Future<void> submitQuote(QuoteModel quote) async {
    try {
      await ApiClient.post('/supervisor/projects/${quote.requestId}/quote', {
        'user_amount': quote.totalPrice,
        'doer_amount': quote.doerAmount ?? 0,
        'supervisor_amount': quote.supervisorAmount ?? 0,
        'platform_amount': quote.platformAmount ?? 0,
        'base_price': quote.basePrice,
        'urgency_fee': quote.urgencyFee ?? 0,
        'complexity_fee': quote.complexityFee ?? 0,
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to submit quote: $e', null);
    }
  }

  /// Fetches available doers for project assignment.
  Future<List<DoerModel>> getAvailableDoers({String? expertise}) async {
    try {
      final expertiseParam = (expertise != null && expertise != 'All')
          ? '?expertise=$expertise'
          : '';
      final response = await ApiClient.get(
        '/supervisor/doers/available$expertiseParam',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['doers'] as List? ?? [];

      return list
          .map((json) => DoerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch available doers: $e', null);
    }
  }

  /// Assigns a doer to a project.
  Future<void> assignDoer(String projectId, String doerId) async {
    try {
      await ApiClient.post('/supervisor/projects/$projectId/assign-doer', {
        'doer_id': doerId,
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to assign doer: $e', null);
    }
  }

  /// Gets reviews for a specific doer.
  Future<List<DoerReview>> getDoerReviews(String doerId) async {
    try {
      final response = await ApiClient.get(
        '/supervisor/doers/$doerId/reviews?limit=10',
      );
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['reviews'] as List? ?? [];

      return list
          .map((json) => DoerReview.fromJson(json as Map<String, dynamic>))
          .toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to fetch doer reviews: $e', null);
    }
  }

  /// Updates the supervisor's availability status.
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      await ApiClient.put('/supervisor/profile/availability', {
        'is_available': isAvailable,
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to update availability: $e', null);
    }
  }

  /// Gets the supervisor's current availability status.
  Future<bool> getAvailability() async {
    try {
      final response = await ApiClient.get('/supervisor/profile/availability');
      if (response is Map<String, dynamic>) {
        return (response['isAvailable'] ?? response['is_available']) as bool? ?? true;
      }
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ServerException('Failed to get availability: $e', null);
    }
  }
}

library;

import 'package:logger/logger.dart';

import '../../../../core/api/api_client.dart';
import '../models/business_hub_post_model.dart';

/// Repository for fetching investors from the API.
class BusinessHubRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  BusinessHubRepository();

  /// Get investors with optional filters.
  Future<List<Investor>> getInvestors({
    FundingStage? stage,
    String? sector,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (stage != null && stage != FundingStage.all) {
        queryParams['stage'] = stage.apiValue;
      }
      if (sector != null && sector.isNotEmpty) {
        queryParams['sector'] = sector;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response =
          await ApiClient.get('/investors', queryParams: queryParams);
      final data = response as Map<String, dynamic>;
      final list = data['investors'] as List? ?? [];
      return list
          .map((row) => Investor.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching investors: $e');
      return [];
    }
  }

  /// Get a single investor by ID.
  Future<Investor?> getInvestorById(String id) async {
    try {
      final response = await ApiClient.get('/investors/$id');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      final investorData =
          data['investor'] as Map<String, dynamic>? ?? data;
      return Investor.fromJson(investorData);
    } catch (e) {
      _logger.e('Error fetching investor: $e');
      return null;
    }
  }
}

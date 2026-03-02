library;

import 'package:logger/logger.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/business_hub_post_model.dart';

/// Repository for Business Hub community operations.
class BusinessHubRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  BusinessHubRepository();

  Future<String?> get _currentUserId async {
    final hasTokens = await TokenStorage.hasTokens();
    if (!hasTokens) return null;
    try {
      final data = await ApiClient.get('/auth/me');
      if (data == null) return null;
      return ((data as Map<String, dynamic>)['_id'] ?? data['id']) as String?;
    } catch (_) {
      return null;
    }
  }

  /// Get business hub posts with optional filters.
  Future<List<BusinessHubPost>> getPosts({
    BusinessCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (category != null && category != BusinessCategory.all) {
        queryParams['category'] = category.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await ApiClient.get('/community/business-hub', queryParams: queryParams);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) =>
              BusinessHubPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching business hub posts: $e');
      return _getMockPosts();
    }
  }

  /// Get a single post by ID.
  Future<BusinessHubPost?> getPostById(String id) async {
    try {
      final response = await ApiClient.get('/community/business-hub/$id');
      if (response == null) return null;
      return BusinessHubPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error fetching business hub post: $e');
      return null;
    }
  }

  /// Create a new business hub post.
  Future<BusinessHubPost> createPost({
    required BusinessCategory category,
    required BusinessPostType postType,
    required String title,
    String? description,
    List<String>? images,
    String? companyName,
    String? industry,
    List<String>? tags,
  }) async {
    try {
      final response = await ApiClient.post('/community/business-hub', {
        'category': category.name,
        'title': title,
        'content': description,
        'images': images,
        'company_name': companyName,
        'industry': industry,
        'tags': tags,
      });

      return BusinessHubPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error creating business hub post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.post('/community/business-hub/$postId/like', {});
      return (response as Map<String, dynamic>)['liked'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.post('/community/business-hub/$postId/save', {});
      return (response as Map<String, dynamic>)['saved'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling save: $e');
      rethrow;
    }
  }

  /// Get saved business hub posts.
  Future<List<BusinessHubPost>> getSavedPosts() async {
    try {
      final response = await ApiClient.get('/community/business-hub/saved');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) =>
              BusinessHubPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching saved posts: $e');
      return [];
    }
  }

  List<BusinessHubPost> _getMockPosts() {
    return [
      BusinessHubPost(
        id: 'biz-1',
        userName: 'Neha Gupta',
        userTitle: 'CEO',
        companyName: 'TechVentures India',
        category: BusinessCategory.recruitment,
        postType: BusinessPostType.recruitment,
        title: 'Hiring: Senior Flutter Developer - Remote',
        description:
            'Looking for experienced Flutter developers to join our growing team. Competitive salary and equity options.',
        tags: ['Hiring', 'Flutter', 'Remote'],
        likeCount: 42,
        commentCount: 15,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      BusinessHubPost(
        id: 'biz-2',
        userName: 'Arjun Mehta',
        userTitle: 'VP Strategy',
        companyName: 'GlobalCorp',
        category: BusinessCategory.industryInsights,
        postType: BusinessPostType.insight,
        title: 'How AI is reshaping the Indian startup ecosystem',
        description:
            'A deep dive into the impact of generative AI on Indian startups. Key trends and opportunities ahead.',
        tags: ['AI', 'Startups', 'India'],
        likeCount: 78,
        commentCount: 22,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      BusinessHubPost(
        id: 'biz-3',
        userName: 'Riya Kapoor',
        userTitle: 'Founder',
        companyName: 'GreenTech Solutions',
        category: BusinessCategory.funding,
        postType: BusinessPostType.funding,
        title: 'Series A: Raised 5M for sustainable tech platform',
        description:
            'Excited to announce our Series A funding! Building the future of sustainable enterprise software.',
        tags: ['Funding', 'SeriesA', 'Sustainability'],
        likeCount: 120,
        commentCount: 35,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      BusinessHubPost(
        id: 'biz-4',
        userName: 'Vikram Reddy',
        userTitle: 'CTO',
        companyName: 'DataSync Labs',
        category: BusinessCategory.innovation,
        postType: BusinessPostType.innovation,
        title: 'Our journey to building a real-time analytics platform',
        description:
            'Lessons learned from scaling our analytics platform to handle 1M events/sec.',
        tags: ['Engineering', 'Scale', 'Analytics'],
        likeCount: 56,
        commentCount: 18,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      BusinessHubPost(
        id: 'biz-5',
        userName: 'Ananya Singh',
        userTitle: 'Director',
        companyName: 'InnoHub',
        category: BusinessCategory.events,
        postType: BusinessPostType.event,
        title: 'Business Leaders Summit 2026 - Registration Open',
        description:
            'Join 500+ business leaders for networking and knowledge sharing. March 20-21, Delhi.',
        tags: ['Summit', 'Networking', 'Leadership'],
        likeCount: 45,
        commentCount: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}

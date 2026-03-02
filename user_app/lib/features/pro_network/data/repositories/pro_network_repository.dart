library;

import 'package:logger/logger.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/storage/token_storage.dart';
import '../models/pro_network_post_model.dart';

/// Repository for Pro Network community operations.
class ProNetworkRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ProNetworkRepository();

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

  /// Get pro network posts with optional filters.
  Future<List<ProNetworkPost>> getPosts({
    ProfessionalCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (category != null && category != ProfessionalCategory.all) {
        queryParams['category'] = category.name;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await ApiClient.get('/community/pro-network', queryParams: queryParams);
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) => ProNetworkPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching pro network posts: $e');
      return _getMockPosts();
    }
  }

  /// Get a single post by ID.
  Future<ProNetworkPost?> getPostById(String id) async {
    try {
      final response = await ApiClient.get('/community/pro-network/$id');
      if (response == null) return null;
      return ProNetworkPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error fetching pro network post: $e');
      return null;
    }
  }

  /// Create a new pro network post.
  Future<ProNetworkPost> createPost({
    required ProfessionalCategory category,
    required ProfessionalPostType postType,
    required String title,
    String? description,
    List<String>? images,
    List<String>? tags,
  }) async {
    try {
      final response = await ApiClient.post('/community/pro-network', {
        'category': category.name,
        'title': title,
        'content': description,
        'images': images,
        'tags': tags,
      });

      return ProNetworkPost.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error creating pro network post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    try {
      final response = await ApiClient.post('/community/pro-network/$postId/like', {});
      return (response as Map<String, dynamic>)['liked'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    try {
      final response = await ApiClient.post('/community/pro-network/$postId/save', {});
      return (response as Map<String, dynamic>)['saved'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling save: $e');
      rethrow;
    }
  }

  /// Get saved pro network posts.
  Future<List<ProNetworkPost>> getSavedPosts() async {
    try {
      final response = await ApiClient.get('/community/pro-network/saved');
      final list = response is List
          ? response
          : (response as Map<String, dynamic>)['posts'] as List? ?? [];
      return list
          .map((row) => ProNetworkPost.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching saved posts: $e');
      return [];
    }
  }

  List<ProNetworkPost> _getMockPosts() {
    return [
      ProNetworkPost(
        id: 'pro-1',
        userName: 'Alex Chen',
        userTitle: 'Full Stack Developer',
        category: ProfessionalCategory.freelanceOpportunities,
        postType: ProfessionalPostType.freelanceGig,
        title: 'Looking for React Native developers for a 3-month project',
        description:
            'We have an exciting mobile app project. Budget: \$5000-8000. Remote friendly.',
        tags: ['React Native', 'Mobile', 'Freelance'],
        likeCount: 24,
        commentCount: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ProNetworkPost(
        id: 'pro-2',
        userName: 'Priya Sharma',
        userTitle: 'UX Designer',
        category: ProfessionalCategory.portfolioShowcase,
        postType: ProfessionalPostType.portfolioItem,
        title: 'Redesigned the entire checkout flow for an e-commerce platform',
        description:
            'Increased conversion by 23%. Check out my case study!',
        tags: ['UX', 'Portfolio', 'E-commerce'],
        likeCount: 56,
        commentCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ProNetworkPost(
        id: 'pro-3',
        userName: 'Rahul Verma',
        userTitle: 'Data Scientist',
        category: ProfessionalCategory.skillExchange,
        postType: ProfessionalPostType.skillOffer,
        title: 'Offering Python/ML mentoring in exchange for Flutter coaching',
        description:
            'I have 3+ years in ML and want to learn Flutter development.',
        tags: ['Python', 'ML', 'Flutter', 'Mentoring'],
        likeCount: 18,
        commentCount: 5,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ProNetworkPost(
        id: 'pro-4',
        userName: 'Sara Patel',
        userTitle: 'Tech Lead',
        category: ProfessionalCategory.industryNews,
        postType: ProfessionalPostType.newsArticle,
        title: 'AI is transforming how we approach code reviews',
        description:
            'A deep dive into AI-powered code review tools and their impact.',
        tags: ['AI', 'Code Review', 'Tech Trends'],
        likeCount: 89,
        commentCount: 23,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ProNetworkPost(
        id: 'pro-5',
        userName: 'Vikram Singh',
        category: ProfessionalCategory.events,
        postType: ProfessionalPostType.event,
        title: 'Tech Meetup: Building Scalable Systems - March 15',
        description: 'Join us for an evening of talks and networking.',
        tags: ['Meetup', 'Scalability', 'Networking'],
        likeCount: 34,
        commentCount: 7,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}

library;

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pro_network_post_model.dart';

/// Repository for Pro Network community operations.
class ProNetworkRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  ProNetworkRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get pro network posts with optional filters.
  Future<List<ProNetworkPost>> getPosts({
    ProfessionalCategory? category,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('user_type', 'doer')
          .or('status.eq.active,status.eq.published,status.is.null');

      if (category != null && category != ProfessionalCategory.all) {
        query = query.eq('category', category.name);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
            'title.ilike.%$searchQuery%,content.ilike.%$searchQuery%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List)
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
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ProNetworkPost.fromJson(response);
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
    String? location,
    List<String>? tags,
  }) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final response = await _supabase
          .from('community_posts')
          .insert({
            'user_id': userId,
            'user_type': 'doer',
            'category': category.name,
            'post_type': postType.name,
            'title': title,
            'content': description,
            'images': images,
            'location': location,
            'tags': tags,
            'status': 'active',
          })
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url)
          ''')
          .single();

      return ProNetworkPost.fromJson(response);
    } catch (e) {
      _logger.e('Error creating pro network post: $e');
      rethrow;
    }
  }

  /// Toggle like on a post.
  Future<bool> toggleLike(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final existing = await _supabase
          .from('community_post_likes')
          .select('id')
          .eq('post_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('community_post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase.from('community_post_likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Toggle save on a post.
  Future<bool> toggleSave(String postId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    try {
      final existing = await _supabase
          .from('saved_listings')
          .select('id')
          .eq('listing_id', postId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        await _supabase
            .from('saved_listings')
            .delete()
            .eq('listing_id', postId)
            .eq('user_id', userId);
        return false;
      } else {
        await _supabase.from('saved_listings').insert({
          'listing_id': postId,
          'user_id': userId,
        });
        return true;
      }
    } catch (e) {
      _logger.e('Error toggling save: $e');
      rethrow;
    }
  }

  /// Get saved pro network posts.
  Future<List<ProNetworkPost>> getSavedPosts() async {
    final userId = _currentUserId;
    if (userId == null) return [];

    try {
      final savedItems = await _supabase
          .from('saved_listings')
          .select('listing_id')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (savedItems.isEmpty) return [];

      final listingIds =
          (savedItems as List).map((s) => s['listing_id']).toList();

      final posts = await _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url)
          ''')
          .inFilter('id', listingIds)
          .eq('user_type', 'doer');

      return (posts as List)
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

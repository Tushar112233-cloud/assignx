library;

import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/business_hub_post_model.dart';

/// Repository for Business Hub community operations.
class BusinessHubRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  BusinessHubRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Get business hub posts with optional filters.
  Future<List<BusinessHubPost>> getPosts({
    BusinessCategory? category,
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
          .eq('user_type', 'superviser')
          .or('status.eq.active,status.eq.published,status.is.null');

      if (category != null && category != BusinessCategory.all) {
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
      final response = await _supabase
          .from('community_posts')
          .select('''
            *,
            author:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return BusinessHubPost.fromJson(response);
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
            'user_type': 'superviser',
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

      return BusinessHubPost.fromJson(response);
    } catch (e) {
      _logger.e('Error creating business hub post: $e');
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

  /// Get saved business hub posts.
  Future<List<BusinessHubPost>> getSavedPosts() async {
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
          .eq('user_type', 'superviser');

      return (posts as List)
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

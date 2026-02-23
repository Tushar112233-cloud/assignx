import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/marketplace_model.dart';
import '../models/project_subject.dart';
import '../models/question_model.dart';
import '../models/tutor_model.dart';

/// Repository for marketplace operations.
class MarketplaceRepository {
  final SupabaseClient _supabase;
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  MarketplaceRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  /// Get current user ID.
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// Map database listing type to model enum.
  static ListingType _mapListingType(String? dbType) {
    switch (dbType?.toLowerCase()) {
      case 'product':
        return ListingType.product;
      case 'housing':
        return ListingType.housing;
      case 'opportunity':
        return ListingType.opportunity;
      case 'community_post':
        return ListingType.communityPost;
      case 'event':
        return ListingType.event;
      case 'poll':
        return ListingType.poll;
      default:
        return ListingType.product;
    }
  }

  /// Map database category to model enum.
  static MarketplaceCategory _mapCategory(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'hard_goods':
      case 'hardgoods':
        return MarketplaceCategory.hardGoods;
      case 'housing':
        return MarketplaceCategory.housing;
      case 'opportunities':
        return MarketplaceCategory.opportunities;
      case 'community':
        return MarketplaceCategory.community;
      default:
        return MarketplaceCategory.hardGoods;
    }
  }

  /// Convert database row to MarketplaceListing.
  MarketplaceListing _fromDbRow(Map<String, dynamic> row) {
    // Extract seller profile info if joined
    final seller = row['seller'] as Map<String, dynamic>?;
    final category = row['category'] as Map<String, dynamic>?;

    return MarketplaceListing(
      id: row['id'] as String,
      userId: row['seller_id'] as String,
      userName: seller?['full_name'] as String? ?? 'Anonymous',
      userAvatar: seller?['avatar_url'] as String?,
      userUniversity: null, // Would need to join with students table
      category: _mapCategory(category?['name'] as String?),
      type: _mapListingType(row['listing_type'] as String?),
      title: row['title'] as String,
      description: row['description'] as String?,
      price: (row['price'] as num?)?.toDouble(),
      isNegotiable: row['price_negotiable'] as bool? ?? false,
      images: [], // Images stored in separate table
      location: row['location_text'] as String?,
      distanceKm: (row['distance_km'] as num?)?.toDouble(),
      status: _mapStatus(row['status'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      expiresAt: row['expires_at'] != null
          ? DateTime.parse(row['expires_at'] as String)
          : null,
      viewCount: row['view_count'] as int? ?? 0,
      likeCount: row['favorites_count'] as int? ?? 0,
      commentCount: row['inquiry_count'] as int? ?? 0,
      metadata: row['poll_options'] != null
          ? {'pollOptions': row['poll_options'], 'totalVotes': row['total_votes']}
          : null,
    );
  }

  /// Map database status to model enum.
  static ListingStatus _mapStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return ListingStatus.active;
      case 'sold':
        return ListingStatus.sold;
      case 'expired':
        return ListingStatus.expired;
      case 'hidden':
        return ListingStatus.hidden;
      default:
        return ListingStatus.active;
    }
  }

  /// Get all listings with optional filters.
  Future<List<MarketplaceListing>> getListings({
    MarketplaceCategory? category,
    String? city,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Build base query with filters first, then transforms
      var query = _supabase
          .from('marketplace_listings')
          .select('''
            *,
            seller:profiles!seller_id(full_name, avatar_url),
            category:marketplace_categories!category_id(name)
          ''')
          .eq('status', 'active');

      // Apply city filter
      if (city != null && city.isNotEmpty) {
        query = query.ilike('city', '%$city%');
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Apply ordering and pagination last
      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((row) => _fromDbRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching listings: $e');
      rethrow;
    }
  }

  /// Get a single listing by ID.
  Future<MarketplaceListing?> getListingById(String id) async {
    try {
      final response = await _supabase
          .from('marketplace_listings')
          .select('''
            *,
            seller:profiles!seller_id(full_name, avatar_url),
            category:marketplace_categories!category_id(name)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      // Increment view count
      await _supabase
          .from('marketplace_listings')
          .update({'view_count': (response['view_count'] as int? ?? 0) + 1})
          .eq('id', id);

      return _fromDbRow(response);
    } catch (e) {
      _logger.e('Error fetching listing: $e');
      rethrow;
    }
  }

  /// Create a new listing.
  Future<MarketplaceListing> createListing({
    required MarketplaceCategory category,
    required ListingType type,
    required String title,
    String? description,
    double? price,
    bool isNegotiable = false,
    List<String> images = const [],
    String? location,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // First, get the category ID
      final categoryResponse = await _supabase
          .from('marketplace_categories')
          .select('id')
          .eq('name', category.name)
          .maybeSingle();

      final categoryId = categoryResponse?['id'] as String?;

      final response = await _supabase
          .from('marketplace_listings')
          .insert({
            'seller_id': userId,
            'listing_type': type.name,
            'category_id': categoryId,
            'title': title,
            'description': description,
            'price': price,
            'price_negotiable': isNegotiable,
            'location_text': location,
            'status': 'active',
          })
          .select('''
            *,
            seller:profiles!seller_id(full_name, avatar_url),
            category:marketplace_categories!category_id(name)
          ''')
          .single();

      return _fromDbRow(response);
    } catch (e) {
      _logger.e('Error creating listing: $e');
      rethrow;
    }
  }

  /// Toggle like/favorite on a listing.
  Future<bool> toggleLike(String listingId) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if already favorited
      final existing = await _supabase
          .from('marketplace_favorites')
          .select('id')
          .eq('listing_id', listingId)
          .eq('profile_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Remove favorite
        await _supabase
            .from('marketplace_favorites')
            .delete()
            .eq('listing_id', listingId)
            .eq('profile_id', userId);

        // Decrement count
        await _supabase.rpc('decrement_favorites_count', params: {
          'listing_id': listingId,
        });

        return false;
      } else {
        // Add favorite
        await _supabase.from('marketplace_favorites').insert({
          'listing_id': listingId,
          'profile_id': userId,
        });

        // Increment count
        await _supabase.rpc('increment_favorites_count', params: {
          'listing_id': listingId,
        });

        return true;
      }
    } catch (e) {
      _logger.e('Error toggling like: $e');
      rethrow;
    }
  }

  /// Get current user's listings.
  Future<List<MarketplaceListing>> getUserListings() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('marketplace_listings')
          .select('''
            *,
            seller:profiles!seller_id(full_name, avatar_url),
            category:marketplace_categories!category_id(name)
          ''')
          .eq('seller_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((row) => _fromDbRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching user listings: $e');
      rethrow;
    }
  }

  /// Report a listing.
  Future<void> reportListing(String listingId, String reason) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase.from('marketplace_reports').insert({
        'listing_id': listingId,
        'reporter_id': userId,
        'reason': reason,
        'status': 'pending',
      });
    } catch (e) {
      _logger.e('Error reporting listing: $e');
      rethrow;
    }
  }

  // ============================================================
  // TUTOR RELATED METHODS
  // ============================================================

  /// Convert database row to Tutor model.
  Tutor _tutorFromDbRow(Map<String, dynamic> row) {
    // Extract profile info if joined
    final profile = row['profile'] as Map<String, dynamic>?;

    return Tutor(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      name: profile?['full_name'] as String? ?? row['name'] as String? ?? 'Anonymous',
      avatar: profile?['avatar_url'] as String? ?? row['avatar'] as String?,
      bio: row['bio'] as String?,
      subjects: (row['subjects'] as List<dynamic>?)?.cast<String>() ?? [],
      qualifications:
          (row['qualifications'] as List<dynamic>?)?.cast<String>() ?? [],
      hourlyRate: (row['hourly_rate'] as num?)?.toDouble() ?? 0,
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: row['review_count'] as int? ?? 0,
      sessionsCompleted: row['sessions_completed'] as int? ?? 0,
      isAvailable: row['is_available'] as bool? ?? true,
      isVerified: row['is_verified'] as bool? ?? false,
      university: row['university'] as String?,
      yearOfStudy: row['year_of_study'] as String?,
      responseTimeMinutes: row['response_time_minutes'] as int?,
      createdAt: row['created_at'] != null
          ? DateTime.parse(row['created_at'] as String)
          : DateTime.now(),
      lastActiveAt: row['last_active_at'] != null
          ? DateTime.parse(row['last_active_at'] as String)
          : null,
    );
  }

  /// Get all available tutors.
  ///
  /// [subjects] - Optional list of subjects to filter by.
  /// [searchQuery] - Optional search query for name or subjects.
  /// [minRating] - Optional minimum rating filter.
  /// [maxRate] - Optional maximum hourly rate filter.
  /// [limit] - Maximum number of results.
  /// [offset] - Offset for pagination.
  Future<List<Tutor>> getTutors({
    List<String>? subjects,
    String? searchQuery,
    double? minRating,
    double? maxRate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('tutors')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('is_available', true);

      // Apply rating filter
      if (minRating != null) {
        query = query.gte('rating', minRating);
      }

      // Apply rate filter
      if (maxRate != null) {
        query = query.lte('hourly_rate', maxRate);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,bio.ilike.%$searchQuery%');
      }

      // Apply ordering and pagination
      final response = await query
          .order('rating', ascending: false)
          .order('sessions_completed', ascending: false)
          .range(offset, offset + limit - 1);

      final tutors = (response as List<dynamic>)
          .map((row) => _tutorFromDbRow(row as Map<String, dynamic>))
          .toList();

      // Filter by subjects if provided (done client-side for array contains)
      if (subjects != null && subjects.isNotEmpty) {
        return tutors.where((tutor) {
          return tutor.subjects.any(
            (subject) => subjects.any(
              (s) => subject.toLowerCase().contains(s.toLowerCase()),
            ),
          );
        }).toList();
      }

      return tutors;
    } catch (e) {
      _logger.e('Error fetching tutors: $e');
      // Return mock data if table doesn't exist yet
      return _getMockTutors();
    }
  }

  /// Get a single tutor by ID.
  Future<Tutor?> getTutorById(String id) async {
    try {
      final response = await _supabase
          .from('tutors')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      return _tutorFromDbRow(response);
    } catch (e) {
      _logger.e('Error fetching tutor: $e');
      // Return mock tutor if not found
      final mockTutors = _getMockTutors();
      return mockTutors.firstWhere(
        (t) => t.id == id,
        orElse: () => mockTutors.first,
      );
    }
  }

  /// Get featured/top rated tutors.
  Future<List<Tutor>> getFeaturedTutors({int limit = 5}) async {
    try {
      final response = await _supabase
          .from('tutors')
          .select('''
            *,
            profile:profiles!user_id(full_name, avatar_url)
          ''')
          .eq('is_available', true)
          .eq('is_verified', true)
          .order('rating', ascending: false)
          .order('sessions_completed', ascending: false)
          .limit(limit);

      return (response as List<dynamic>)
          .map((row) => _tutorFromDbRow(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching featured tutors: $e');
      return _getMockTutors().take(limit).toList();
    }
  }

  /// Book a session with a tutor.
  Future<BookedSession> bookSession({
    required String tutorId,
    required DateTime date,
    required String timeSlot,
    required SessionType sessionType,
    required SessionDuration duration,
    String? topic,
    String? notes,
    required double totalPrice,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('booked_sessions')
          .insert({
            'tutor_id': tutorId,
            'student_id': userId,
            'date': date.toIso8601String().split('T')[0],
            'time_slot': timeSlot,
            'session_type': sessionType.name,
            'duration_minutes': duration.minutes,
            'topic': topic,
            'notes': notes,
            'total_price': totalPrice,
            'status': 'pending',
          })
          .select()
          .single();

      return BookedSession.fromJson(response);
    } catch (e) {
      _logger.e('Error booking session: $e');
      rethrow;
    }
  }

  /// Get user's booked sessions.
  Future<List<BookedSession>> getUserSessions({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      var query = _supabase
          .from('booked_sessions')
          .select()
          .eq('student_id', userId);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query
          .order('date', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((row) => BookedSession.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching user sessions: $e');
      return [];
    }
  }

  /// Get reviews for a tutor.
  Future<List<TutorReview>> getTutorReviews(
    String tutorId, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from('tutor_reviews')
          .select('''
            *,
            student:profiles!student_id(full_name, avatar_url)
          ''')
          .eq('tutor_id', tutorId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>).map((row) {
        final student = row['student'] as Map<String, dynamic>?;
        return TutorReview(
          id: row['id'] as String,
          tutorId: row['tutor_id'] as String,
          studentId: row['student_id'] as String,
          studentName: student?['full_name'] as String? ?? 'Anonymous',
          studentAvatar: student?['avatar_url'] as String?,
          rating: (row['rating'] as num).toDouble(),
          comment: row['comment'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching tutor reviews: $e');
      return [];
    }
  }

  /// Submit a review for a tutor.
  Future<void> submitTutorReview({
    required String tutorId,
    required double rating,
    String? comment,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      await _supabase.from('tutor_reviews').insert({
        'tutor_id': tutorId,
        'student_id': userId,
        'rating': rating,
        'comment': comment,
      });

      // Update tutor's average rating
      await _supabase.rpc('update_tutor_rating', params: {
        'p_tutor_id': tutorId,
      });
    } catch (e) {
      _logger.e('Error submitting review: $e');
      rethrow;
    }
  }

  /// Get mock tutors for development/demo purposes.
  List<Tutor> _getMockTutors() {
    return [
      Tutor(
        id: 'tutor-1',
        userId: 'user-1',
        name: 'Priya Sharma',
        avatar: null,
        bio: 'Experienced math tutor with 5+ years of teaching experience. Specializing in calculus, algebra, and statistics for college students.',
        subjects: ['Mathematics', 'Calculus', 'Statistics', 'Algebra'],
        qualifications: ['M.Sc. Mathematics', 'B.Ed.', 'GATE qualified'],
        hourlyRate: 500,
        rating: 4.8,
        reviewCount: 124,
        sessionsCompleted: 350,
        isAvailable: true,
        isVerified: true,
        university: 'IIT Delhi',
        responseTimeMinutes: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Tutor(
        id: 'tutor-2',
        userId: 'user-2',
        name: 'Rahul Verma',
        avatar: null,
        bio: 'Physics enthusiast helping students understand complex concepts through practical examples and experiments.',
        subjects: ['Physics', 'Mechanics', 'Thermodynamics', 'Electromagnetism'],
        qualifications: ['M.Sc. Physics', 'PhD Candidate'],
        hourlyRate: 450,
        rating: 4.6,
        reviewCount: 89,
        sessionsCompleted: 210,
        isAvailable: true,
        isVerified: true,
        university: 'BITS Pilani',
        responseTimeMinutes: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Tutor(
        id: 'tutor-3',
        userId: 'user-3',
        name: 'Ananya Patel',
        avatar: null,
        bio: 'Programming tutor specializing in Python, Java, and web development. Expert in data structures and algorithms.',
        subjects: ['Programming', 'Python', 'Java', 'Data Structures', 'Algorithms'],
        qualifications: ['B.Tech Computer Science', 'AWS Certified'],
        hourlyRate: 600,
        rating: 4.9,
        reviewCount: 156,
        sessionsCompleted: 420,
        isAvailable: true,
        isVerified: true,
        university: 'NIT Trichy',
        responseTimeMinutes: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
      Tutor(
        id: 'tutor-4',
        userId: 'user-4',
        name: 'Vikram Singh',
        avatar: null,
        bio: 'Chemistry expert with a passion for organic chemistry. Making complex reactions easy to understand.',
        subjects: ['Chemistry', 'Organic Chemistry', 'Biochemistry'],
        qualifications: ['M.Sc. Chemistry', 'CSIR-NET qualified'],
        hourlyRate: 400,
        rating: 4.5,
        reviewCount: 67,
        sessionsCompleted: 145,
        isAvailable: true,
        isVerified: false,
        university: 'Delhi University',
        responseTimeMinutes: 45,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      Tutor(
        id: 'tutor-5',
        userId: 'user-5',
        name: 'Sneha Reddy',
        avatar: null,
        bio: 'English literature and writing coach. Helping students improve their academic writing and communication skills.',
        subjects: ['English', 'Literature', 'Academic Writing', 'IELTS Prep'],
        qualifications: ['M.A. English Literature', 'Cambridge CELTA'],
        hourlyRate: 350,
        rating: 4.7,
        reviewCount: 98,
        sessionsCompleted: 280,
        isAvailable: true,
        isVerified: true,
        university: 'Christ University',
        responseTimeMinutes: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),
    ];
  }

  // ============================================================
  // Q&A RELATED METHODS
  // ============================================================

  /// Convert database row to Question model.
  Question _questionFromDbRow(Map<String, dynamic> row) {
    final author = row['author'] as Map<String, dynamic>?;
    final answersData = row['answers'] as List<dynamic>?;

    return Question(
      id: row['id'] as String,
      title: row['title'] as String,
      content: row['content'] as String?,
      subject: ProjectSubject.fromString(row['subject'] as String?),
      tags: (row['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      author: QuestionAuthor(
        id: row['author_id'] as String? ?? '',
        name: author?['full_name'] as String? ?? 'Anonymous',
        avatarUrl: author?['avatar_url'] as String?,
        isVerified: author?['is_verified'] as bool? ?? false,
      ),
      isAnonymous: row['is_anonymous'] as bool? ?? false,
      upvotes: row['upvotes'] as int? ?? 0,
      downvotes: row['downvotes'] as int? ?? 0,
      answerCount: row['answer_count'] as int? ?? 0,
      viewCount: row['view_count'] as int? ?? 0,
      isAnswered: row['is_answered'] as bool? ?? false,
      isUpvoted: row['is_upvoted'] as bool? ?? false,
      isDownvoted: row['is_downvoted'] as bool? ?? false,
      status: _parseQuestionStatus(row['status'] as String?),
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
      answers: answersData?.map((a) => _answerFromDbRow(a as Map<String, dynamic>)).toList(),
    );
  }

  /// Convert database row to Answer model.
  Answer _answerFromDbRow(Map<String, dynamic> row) {
    final author = row['author'] as Map<String, dynamic>?;

    return Answer(
      id: row['id'] as String,
      questionId: row['question_id'] as String,
      content: row['content'] as String,
      author: QuestionAuthor(
        id: row['author_id'] as String? ?? '',
        name: author?['full_name'] as String? ?? 'Anonymous',
        avatarUrl: author?['avatar_url'] as String?,
        isExpert: author?['is_expert'] as bool? ?? false,
        isVerified: author?['is_verified'] as bool? ?? false,
      ),
      upvotes: row['upvotes'] as int? ?? 0,
      downvotes: row['downvotes'] as int? ?? 0,
      isAccepted: row['is_accepted'] as bool? ?? false,
      isUpvoted: row['is_upvoted'] as bool? ?? false,
      isDownvoted: row['is_downvoted'] as bool? ?? false,
      createdAt: DateTime.parse(row['created_at'] as String),
      updatedAt: row['updated_at'] != null
          ? DateTime.parse(row['updated_at'] as String)
          : null,
    );
  }

  /// Parse question status from string.
  QuestionStatus _parseQuestionStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'answered':
        return QuestionStatus.answered;
      case 'closed':
        return QuestionStatus.closed;
      default:
        return QuestionStatus.open;
    }
  }

  /// Get all questions with optional filters.
  ///
  /// [subject] - Optional subject filter.
  /// [tag] - Optional tag filter.
  /// [searchQuery] - Optional search query for title or content.
  /// [sortBy] - Sort option (latest, popular, unanswered).
  /// [showAnsweredOnly] - Show only answered questions.
  /// [showUnansweredOnly] - Show only unanswered questions.
  /// [limit] - Maximum number of results.
  /// [offset] - Offset for pagination.
  Future<List<Question>> getQuestions({
    ProjectSubject? subject,
    String? tag,
    String? searchQuery,
    QuestionSortOption sortBy = QuestionSortOption.latest,
    bool showAnsweredOnly = false,
    bool showUnansweredOnly = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      var query = _supabase
          .from('connect_questions')
          .select('''
            *,
            author:profiles!author_id(full_name, avatar_url, is_verified)
          ''')
          .neq('status', 'closed');

      // Apply subject filter
      if (subject != null) {
        query = query.eq('subject', subject.toDbString());
      }

      // Apply answered/unanswered filter
      if (showAnsweredOnly) {
        query = query.eq('is_answered', true);
      } else if (showUnansweredOnly) {
        query = query.eq('is_answered', false);
      }

      // Apply search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,content.ilike.%$searchQuery%');
      }

      // For unanswered sort, apply additional filter
      if (sortBy == QuestionSortOption.unanswered) {
        query = query.eq('is_answered', false);
      }

      // Determine sort column and direction
      final String orderColumn;
      final bool ascending;
      switch (sortBy) {
        case QuestionSortOption.latest:
        case QuestionSortOption.unanswered:
          orderColumn = 'created_at';
          ascending = false;
          break;
        case QuestionSortOption.popular:
          orderColumn = 'upvotes';
          ascending = false;
          break;
      }

      // Apply sorting and pagination in one chain
      final response = await query
          .order(orderColumn, ascending: ascending)
          .range(offset, offset + limit - 1);

      final questions = (response as List<dynamic>)
          .map((row) => _questionFromDbRow(row as Map<String, dynamic>))
          .toList();

      // Filter by tag if provided (done client-side for array contains)
      if (tag != null && tag.isNotEmpty) {
        return questions.where((q) => q.tags.any(
          (t) => t.toLowerCase().contains(tag.toLowerCase()),
        )).toList();
      }

      return questions;
    } catch (e) {
      _logger.e('Error fetching questions: $e');
      // Return mock data if table doesn't exist yet
      return _getMockQuestions();
    }
  }

  /// Get a single question by ID with its answers.
  Future<Question?> getQuestionById(String id) async {
    try {
      final response = await _supabase
          .from('connect_questions')
          .select('''
            *,
            author:profiles!author_id(full_name, avatar_url, is_verified),
            answers:connect_answers(
              *,
              author:profiles!author_id(full_name, avatar_url, is_expert, is_verified)
            )
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      // Increment view count
      await _supabase
          .from('connect_questions')
          .update({'view_count': (response['view_count'] as int? ?? 0) + 1})
          .eq('id', id);

      return _questionFromDbRow(response);
    } catch (e) {
      _logger.e('Error fetching question: $e');
      final mockQuestions = _getMockQuestions();
      return mockQuestions.firstWhere(
        (q) => q.id == id,
        orElse: () => mockQuestions.first,
      );
    }
  }

  /// Submit a new question.
  Future<Question> submitQuestion({
    required String title,
    String? content,
    required String subject,
    List<String> tags = const [],
    bool isAnonymous = false,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('connect_questions')
          .insert({
            'author_id': userId,
            'title': title,
            'content': content,
            'subject': subject,
            'tags': tags,
            'is_anonymous': isAnonymous,
            'status': 'open',
          })
          .select('''
            *,
            author:profiles!author_id(full_name, avatar_url, is_verified)
          ''')
          .single();

      return _questionFromDbRow(response);
    } catch (e) {
      _logger.e('Error submitting question: $e');
      rethrow;
    }
  }

  /// Submit an answer to a question.
  Future<Answer> submitAnswer({
    required String questionId,
    required String content,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final response = await _supabase
          .from('connect_answers')
          .insert({
            'question_id': questionId,
            'author_id': userId,
            'content': content,
          })
          .select('''
            *,
            author:profiles!author_id(full_name, avatar_url, is_expert, is_verified)
          ''')
          .single();

      // Update question answer count
      await _supabase.rpc('increment_answer_count', params: {
        'p_question_id': questionId,
      });

      return _answerFromDbRow(response);
    } catch (e) {
      _logger.e('Error submitting answer: $e');
      rethrow;
    }
  }

  /// Vote on a question (upvote or downvote).
  Future<void> voteQuestion({
    required String questionId,
    required bool isUpvote,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Check if user has already voted
      final existingVote = await _supabase
          .from('connect_question_votes')
          .select()
          .eq('question_id', questionId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingVote != null) {
        final wasUpvote = existingVote['is_upvote'] as bool;
        if (wasUpvote == isUpvote) {
          // Remove vote if same type
          await _supabase
              .from('connect_question_votes')
              .delete()
              .eq('question_id', questionId)
              .eq('user_id', userId);

          // Update count
          await _supabase.rpc(
            isUpvote ? 'decrement_question_upvotes' : 'decrement_question_downvotes',
            params: {'p_question_id': questionId},
          );
        } else {
          // Change vote type
          await _supabase
              .from('connect_question_votes')
              .update({'is_upvote': isUpvote})
              .eq('question_id', questionId)
              .eq('user_id', userId);

          // Update both counts
          await _supabase.rpc(
            isUpvote ? 'increment_question_upvotes' : 'decrement_question_upvotes',
            params: {'p_question_id': questionId},
          );
          await _supabase.rpc(
            isUpvote ? 'decrement_question_downvotes' : 'increment_question_downvotes',
            params: {'p_question_id': questionId},
          );
        }
      } else {
        // Create new vote
        await _supabase.from('connect_question_votes').insert({
          'question_id': questionId,
          'user_id': userId,
          'is_upvote': isUpvote,
        });

        // Update count
        await _supabase.rpc(
          isUpvote ? 'increment_question_upvotes' : 'increment_question_downvotes',
          params: {'p_question_id': questionId},
        );
      }
    } catch (e) {
      _logger.e('Error voting on question: $e');
      rethrow;
    }
  }

  /// Vote on an answer (upvote or downvote).
  Future<void> voteAnswer({
    required String answerId,
    required bool isUpvote,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final existingVote = await _supabase
          .from('connect_answer_votes')
          .select()
          .eq('answer_id', answerId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingVote != null) {
        final wasUpvote = existingVote['is_upvote'] as bool;
        if (wasUpvote == isUpvote) {
          await _supabase
              .from('connect_answer_votes')
              .delete()
              .eq('answer_id', answerId)
              .eq('user_id', userId);

          await _supabase.rpc(
            isUpvote ? 'decrement_answer_upvotes' : 'decrement_answer_downvotes',
            params: {'p_answer_id': answerId},
          );
        } else {
          await _supabase
              .from('connect_answer_votes')
              .update({'is_upvote': isUpvote})
              .eq('answer_id', answerId)
              .eq('user_id', userId);

          await _supabase.rpc(
            isUpvote ? 'increment_answer_upvotes' : 'decrement_answer_upvotes',
            params: {'p_answer_id': answerId},
          );
          await _supabase.rpc(
            isUpvote ? 'decrement_answer_downvotes' : 'increment_answer_downvotes',
            params: {'p_answer_id': answerId},
          );
        }
      } else {
        await _supabase.from('connect_answer_votes').insert({
          'answer_id': answerId,
          'user_id': userId,
          'is_upvote': isUpvote,
        });

        await _supabase.rpc(
          isUpvote ? 'increment_answer_upvotes' : 'increment_answer_downvotes',
          params: {'p_answer_id': answerId},
        );
      }
    } catch (e) {
      _logger.e('Error voting on answer: $e');
      rethrow;
    }
  }

  /// Accept an answer as the solution.
  Future<void> acceptAnswer({
    required String questionId,
    required String answerId,
  }) async {
    final userId = _currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Verify user owns the question
      final question = await _supabase
          .from('connect_questions')
          .select('author_id')
          .eq('id', questionId)
          .single();

      if (question['author_id'] != userId) {
        throw Exception('Only the question author can accept answers');
      }

      // Unaccept any previously accepted answer
      await _supabase
          .from('connect_answers')
          .update({'is_accepted': false})
          .eq('question_id', questionId);

      // Accept the new answer
      await _supabase
          .from('connect_answers')
          .update({'is_accepted': true})
          .eq('id', answerId);

      // Mark question as answered
      await _supabase
          .from('connect_questions')
          .update({
            'is_answered': true,
            'status': 'answered',
          })
          .eq('id', questionId);
    } catch (e) {
      _logger.e('Error accepting answer: $e');
      rethrow;
    }
  }

  /// Get mock questions for development/demo purposes.
  List<Question> _getMockQuestions() {
    return [
      Question(
        id: 'q-1',
        title: 'How do I properly cite a website in APA 7 format?',
        content: "I'm working on a research paper and need to cite several websites. Some don't have authors listed. What's the correct format for these citations?",
        subject: ProjectSubject.other,
        tags: ['APA', 'citations', 'research', 'academic writing'],
        author: const QuestionAuthor(
          id: 'user-1',
          name: 'StudentResearcher',
          isVerified: false,
        ),
        upvotes: 23,
        downvotes: 2,
        answerCount: 5,
        viewCount: 156,
        isAnswered: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Question(
        id: 'q-2',
        title: 'Best approach for multiple regression analysis?',
        content: 'Working on a statistics project and trying to determine whether to use stepwise or hierarchical regression. What are the pros and cons of each?',
        subject: ProjectSubject.mathematics,
        tags: ['statistics', 'regression', 'research methods'],
        author: const QuestionAuthor(
          id: 'user-2',
          name: 'DataNerd42',
          isVerified: true,
        ),
        upvotes: 15,
        downvotes: 0,
        answerCount: 3,
        viewCount: 89,
        isAnswered: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Question(
        id: 'q-3',
        title: 'Difference between useEffect and useMemo in React?',
        content: "I'm confused about when to use useEffect vs useMemo. They both seem to do similar things. Can someone explain the key differences?",
        subject: ProjectSubject.computerScience,
        tags: ['React', 'JavaScript', 'hooks', 'frontend'],
        author: const QuestionAuthor(
          id: 'user-3',
          name: 'ReactNewbie',
        ),
        isAnonymous: true,
        upvotes: 45,
        downvotes: 1,
        answerCount: 8,
        viewCount: 342,
        isAnswered: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Question(
        id: 'q-4',
        title: 'Tips for organic chemistry reactions?',
        content: 'I keep getting confused with nucleophilic substitution reactions. Any mnemonics or study tips that helped you remember them?',
        subject: ProjectSubject.chemistry,
        tags: ['organic chemistry', 'study tips', 'reactions'],
        author: const QuestionAuthor(
          id: 'user-4',
          name: 'ChemStruggler',
        ),
        upvotes: 12,
        downvotes: 0,
        answerCount: 0,
        viewCount: 45,
        isAnswered: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      Question(
        id: 'q-5',
        title: 'How to calculate time complexity of recursive algorithms?',
        content: 'I understand Big O notation for iterative algorithms, but recursive ones confuse me. How do you analyze functions like merge sort or fibonacci?',
        subject: ProjectSubject.computerScience,
        tags: ['algorithms', 'time complexity', 'recursion', 'Big O'],
        author: const QuestionAuthor(
          id: 'user-5',
          name: 'AlgoLearner',
          isExpert: false,
        ),
        upvotes: 34,
        downvotes: 2,
        answerCount: 6,
        viewCount: 198,
        isAnswered: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}

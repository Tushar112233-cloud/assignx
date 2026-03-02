import 'package:logger/logger.dart';

import '../../core/api/api_client.dart';
import '../models/marketplace_model.dart';
import '../models/project_subject.dart';
import '../models/question_model.dart';
import '../models/tutor_model.dart';

/// Repository for marketplace operations via the Express API.
class MarketplaceRepository {
  final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

  MarketplaceRepository();

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

  /// Convert API response to MarketplaceListing.
  MarketplaceListing _fromApiResponse(Map<String, dynamic> row) {
    final seller = row['seller'] as Map<String, dynamic>?;
    final category = row['category'] as Map<String, dynamic>?;

    return MarketplaceListing(
      id: (row['_id'] ?? row['id']) as String,
      userId: (row['sellerId'] ?? row['seller_id']) as String,
      userName: seller?['fullName'] ?? seller?['full_name'] as String? ?? 'Anonymous',
      userAvatar: seller?['avatarUrl'] ?? seller?['avatar_url'] as String?,
      userUniversity: null,
      category: _mapCategory(category?['name'] as String? ?? row['categoryName'] as String?),
      type: _mapListingType(row['listingType'] ?? row['listing_type'] as String?),
      title: row['title'] as String,
      description: row['description'] as String?,
      price: (row['price'] as num?)?.toDouble(),
      isNegotiable: row['priceNegotiable'] ?? row['price_negotiable'] as bool? ?? false,
      images: _extractImages(row),
      location: row['locationText'] ?? row['location_text'] as String?,
      distanceKm: (row['distanceKm'] ?? row['distance_km'] as num?)?.toDouble(),
      status: _mapStatus(row['status'] as String?),
      createdAt: DateTime.parse(row['createdAt'] ?? row['created_at'] as String),
      expiresAt: row['expiresAt'] != null || row['expires_at'] != null
          ? DateTime.parse((row['expiresAt'] ?? row['expires_at']) as String)
          : null,
      viewCount: row['viewCount'] ?? row['view_count'] as int? ?? 0,
      likeCount: row['favoritesCount'] ?? row['favorites_count'] as int? ?? 0,
      commentCount: row['inquiryCount'] ?? row['inquiry_count'] as int? ?? 0,
      metadata: row['pollOptions'] != null
          ? {'pollOptions': row['pollOptions'], 'totalVotes': row['totalVotes']}
          : null,
    );
  }

  /// Extract images from API response.
  static List<String> _extractImages(Map<String, dynamic> row) {
    final List<String> result = [];

    final imagesArray = row['images'];
    if (imagesArray is List && imagesArray.isNotEmpty) {
      result.addAll(imagesArray.cast<String>());
    }

    if (result.isEmpty) {
      final imageUrl = (row['imageUrl'] ?? row['image_url']) as String?;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        result.add(imageUrl);
      }
    }

    return result;
  }

  /// Map status string to enum.
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
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'status': 'active',
      };
      if (category != null) queryParams['category'] = category.name;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final response = await ApiClient.get('/marketplace/listings', queryParams: queryParams);
      final list = response is List ? response : (response as Map<String, dynamic>)['listings'] as List? ?? [];
      return list
          .map((row) => _fromApiResponse(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching listings: $e');
      return [];
    }
  }

  /// Get a single listing by ID.
  Future<MarketplaceListing?> getListingById(String id) async {
    try {
      final response = await ApiClient.get('/marketplace/listings/$id');
      if (response == null) return null;
      return _fromApiResponse(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error fetching listing: $e');
      return null;
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
    try {
      final response = await ApiClient.post('/marketplace/listings', {
        'listingType': type.name,
        'categoryName': category.name,
        'title': title,
        'description': description,
        'price': price,
        'priceNegotiable': isNegotiable,
        'images': images,
        'locationText': location,
      });
      return _fromApiResponse(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error creating listing: $e');
      rethrow;
    }
  }

  /// Toggle like/favorite on a listing.
  Future<bool> toggleLike(String listingId) async {
    try {
      final response = await ApiClient.post('/marketplace/listings/$listingId/favorite');
      return (response as Map<String, dynamic>)['favorited'] as bool? ?? false;
    } catch (e) {
      _logger.e('Error toggling like: $e');
      return false;
    }
  }

  /// Get current user's listings.
  Future<List<MarketplaceListing>> getUserListings() async {
    try {
      final response = await ApiClient.get('/marketplace/listings', queryParams: {
        'mine': 'true',
      });
      final list = response is List ? response : (response as Map<String, dynamic>)['listings'] as List? ?? [];
      return list
          .map((row) => _fromApiResponse(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching user listings: $e');
      return [];
    }
  }

  /// Report a listing.
  Future<void> reportListing(String listingId, String reason) async {
    try {
      await ApiClient.post('/marketplace/listings/$listingId/report', {
        'reason': reason,
      });
    } catch (e) {
      _logger.e('Error reporting listing: $e');
      // Don't rethrow - report failure shouldn't crash the UI
    }
  }

  // ============================================================
  // TUTOR RELATED METHODS
  // ============================================================

  /// Convert API response to Tutor model.
  Tutor _tutorFromApiResponse(Map<String, dynamic> row) {
    final profile = row['profile'] as Map<String, dynamic>?;

    return Tutor(
      id: (row['_id'] ?? row['id']) as String,
      userId: (row['userId'] ?? row['user_id']) as String,
      name: profile?['fullName'] ?? profile?['full_name'] as String? ??
          row['headline'] as String? ?? 'Anonymous',
      avatar: profile?['avatarUrl'] ?? profile?['avatar_url'] as String?,
      bio: row['bio'] as String?,
      subjects: (row['specializations'] as List<dynamic>?)?.cast<String>() ?? [],
      qualifications: (row['qualifications'] as List<dynamic>?)?.cast<String>() ?? [],
      hourlyRate: (row['hourlyRate'] ?? row['hourly_rate'] as num?)?.toDouble() ?? 0,
      rating: (row['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: row['totalReviews'] ?? row['total_reviews'] as int? ?? 0,
      sessionsCompleted: row['totalSessions'] ?? row['total_sessions'] as int? ?? 0,
      isAvailable: row['isActive'] ?? row['is_active'] as bool? ?? true,
      isVerified: (row['verificationStatus'] ?? row['verification_status']) == 'verified',
      university: row['organization'] as String?,
      yearOfStudy: null,
      responseTimeMinutes: null,
      createdAt: row['createdAt'] != null || row['created_at'] != null
          ? DateTime.parse((row['createdAt'] ?? row['created_at']) as String)
          : DateTime.now(),
      lastActiveAt: row['updatedAt'] != null || row['updated_at'] != null
          ? DateTime.parse((row['updatedAt'] ?? row['updated_at']) as String)
          : null,
    );
  }

  /// Get all available tutors.
  Future<List<Tutor>> getTutors({
    List<String>? subjects,
    String? searchQuery,
    double? minRating,
    double? maxRate,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'isActive': 'true',
      };
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (minRating != null) queryParams['minRating'] = minRating.toString();
      if (maxRate != null) queryParams['maxRate'] = maxRate.toString();
      if (subjects != null && subjects.isNotEmpty) {
        queryParams['subjects'] = subjects.join(',');
      }

      final response = await ApiClient.get('/marketplace/tutors', queryParams: queryParams);
      final list = response is List ? response : (response as Map<String, dynamic>)['tutors'] as List? ?? [];
      return list
          .map((row) => _tutorFromApiResponse(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching tutors: $e');
      return _getMockTutors();
    }
  }

  /// Get a single tutor by ID.
  Future<Tutor?> getTutorById(String id) async {
    try {
      final response = await ApiClient.get('/marketplace/tutors/$id');
      if (response == null) return null;
      return _tutorFromApiResponse(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error fetching tutor: $e');
      final mockTutors = _getMockTutors();
      return mockTutors.firstWhere((t) => t.id == id, orElse: () => mockTutors.first);
    }
  }

  /// Get featured/top rated tutors.
  Future<List<Tutor>> getFeaturedTutors({int limit = 5}) async {
    try {
      final response = await ApiClient.get('/marketplace/tutors', queryParams: {
        'featured': 'true',
        'limit': limit.toString(),
      });
      final list = response is List ? response : (response as Map<String, dynamic>)['tutors'] as List? ?? [];
      return list
          .map((row) => _tutorFromApiResponse(row as Map<String, dynamic>))
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
    try {
      final response = await ApiClient.post('/marketplace/tutors/$tutorId/book', {
        'scheduledStart': date.toIso8601String(),
        'scheduledEnd': date.add(Duration(minutes: duration.minutes)).toIso8601String(),
        'durationMinutes': duration.minutes,
        'topic': topic,
        'description': notes,
        'totalAmount': totalPrice,
      });
      return BookedSession.fromJson(response as Map<String, dynamic>);
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
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
      };
      if (status != null) queryParams['status'] = status;

      final response = await ApiClient.get('/marketplace/sessions', queryParams: queryParams);
      final list = response is List ? response : (response as Map<String, dynamic>)['sessions'] as List? ?? [];
      return list
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
      final response = await ApiClient.get('/marketplace/tutors/$tutorId/reviews', queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      });
      final list = response is List ? response : (response as Map<String, dynamic>)['reviews'] as List? ?? [];
      return list.map((row) {
        final r = row as Map<String, dynamic>;
        final reviewer = r['reviewer'] as Map<String, dynamic>?;
        return TutorReview(
          id: (r['_id'] ?? r['id']) as String,
          tutorId: (r['expertId'] ?? r['expert_id']) as String,
          studentId: (r['userId'] ?? r['user_id']) as String,
          studentName: reviewer?['fullName'] ?? reviewer?['full_name'] as String? ?? 'Anonymous',
          studentAvatar: reviewer?['avatarUrl'] ?? reviewer?['avatar_url'] as String?,
          rating: (r['overallRating'] ?? r['overall_rating'] as num).toDouble(),
          comment: r['reviewText'] ?? r['review_text'] as String?,
          createdAt: DateTime.parse((r['createdAt'] ?? r['created_at']) as String),
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
    try {
      await ApiClient.post('/marketplace/tutors/$tutorId/reviews', {
        'overallRating': rating.round(),
        'reviewText': comment,
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
        id: 'tutor-1', userId: 'user-1', name: 'Priya Sharma', avatar: null,
        bio: 'Experienced math tutor with 5+ years of teaching experience.',
        subjects: ['Mathematics', 'Calculus', 'Statistics', 'Algebra'],
        qualifications: ['M.Sc. Mathematics', 'B.Ed.', 'GATE qualified'],
        hourlyRate: 500, rating: 4.8, reviewCount: 124, sessionsCompleted: 350,
        isAvailable: true, isVerified: true, university: 'IIT Delhi', responseTimeMinutes: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      Tutor(
        id: 'tutor-2', userId: 'user-2', name: 'Rahul Verma', avatar: null,
        bio: 'Physics enthusiast helping students understand complex concepts.',
        subjects: ['Physics', 'Mechanics', 'Thermodynamics'],
        qualifications: ['M.Sc. Physics', 'PhD Candidate'],
        hourlyRate: 450, rating: 4.6, reviewCount: 89, sessionsCompleted: 210,
        isAvailable: true, isVerified: true, university: 'BITS Pilani', responseTimeMinutes: 30,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      Tutor(
        id: 'tutor-3', userId: 'user-3', name: 'Ananya Patel', avatar: null,
        bio: 'Programming tutor specializing in Python, Java, and web development.',
        subjects: ['Programming', 'Python', 'Java', 'Data Structures'],
        qualifications: ['B.Tech Computer Science', 'AWS Certified'],
        hourlyRate: 600, rating: 4.9, reviewCount: 156, sessionsCompleted: 420,
        isAvailable: true, isVerified: true, university: 'NIT Trichy', responseTimeMinutes: 10,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),
    ];
  }

  // ============================================================
  // Q&A RELATED METHODS
  // ============================================================

  /// Convert API response to Question model.
  Question _questionFromApiResponse(Map<String, dynamic> row) {
    final author = row['author'] as Map<String, dynamic>?;
    final answersData = row['answers'] as List<dynamic>?;

    return Question(
      id: (row['_id'] ?? row['id']) as String,
      title: row['title'] as String,
      content: row['content'] as String?,
      subject: ProjectSubject.fromString(row['subject'] as String?),
      tags: (row['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      author: QuestionAuthor(
        id: (row['authorId'] ?? row['author_id'] ?? '') as String,
        name: author?['fullName'] ?? author?['full_name'] as String? ?? 'Anonymous',
        avatarUrl: author?['avatarUrl'] ?? author?['avatar_url'] as String?,
        isVerified: author?['isVerified'] ?? author?['is_verified'] as bool? ?? false,
      ),
      isAnonymous: row['isAnonymous'] ?? row['is_anonymous'] as bool? ?? false,
      upvotes: row['upvotes'] as int? ?? 0,
      downvotes: row['downvotes'] as int? ?? 0,
      answerCount: row['answerCount'] ?? row['answer_count'] as int? ?? 0,
      viewCount: row['viewCount'] ?? row['view_count'] as int? ?? 0,
      isAnswered: row['isAnswered'] ?? row['is_answered'] as bool? ?? false,
      isUpvoted: row['isUpvoted'] ?? row['is_upvoted'] as bool? ?? false,
      isDownvoted: row['isDownvoted'] ?? row['is_downvoted'] as bool? ?? false,
      status: _parseQuestionStatus(row['status'] as String?),
      createdAt: DateTime.parse((row['createdAt'] ?? row['created_at']) as String),
      updatedAt: row['updatedAt'] != null || row['updated_at'] != null
          ? DateTime.parse((row['updatedAt'] ?? row['updated_at']) as String)
          : null,
      answers: answersData?.map((a) => _answerFromApiResponse(a as Map<String, dynamic>)).toList(),
    );
  }

  /// Convert API response to Answer model.
  Answer _answerFromApiResponse(Map<String, dynamic> row) {
    final author = row['author'] as Map<String, dynamic>?;

    return Answer(
      id: (row['_id'] ?? row['id']) as String,
      questionId: (row['questionId'] ?? row['question_id']) as String,
      content: row['content'] as String,
      author: QuestionAuthor(
        id: (row['authorId'] ?? row['author_id'] ?? '') as String,
        name: author?['fullName'] ?? author?['full_name'] as String? ?? 'Anonymous',
        avatarUrl: author?['avatarUrl'] ?? author?['avatar_url'] as String?,
        isExpert: author?['isExpert'] ?? author?['is_expert'] as bool? ?? false,
        isVerified: author?['isVerified'] ?? author?['is_verified'] as bool? ?? false,
      ),
      upvotes: row['upvotes'] as int? ?? 0,
      downvotes: row['downvotes'] as int? ?? 0,
      isAccepted: row['isAccepted'] ?? row['is_accepted'] as bool? ?? false,
      isUpvoted: row['isUpvoted'] ?? row['is_upvoted'] as bool? ?? false,
      isDownvoted: row['isDownvoted'] ?? row['is_downvoted'] as bool? ?? false,
      createdAt: DateTime.parse((row['createdAt'] ?? row['created_at']) as String),
      updatedAt: row['updatedAt'] != null || row['updated_at'] != null
          ? DateTime.parse((row['updatedAt'] ?? row['updated_at']) as String)
          : null,
    );
  }

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
      final queryParams = <String, String>{
        'limit': limit.toString(),
        'offset': offset.toString(),
        'sortBy': sortBy.name,
      };
      if (subject != null) queryParams['subject'] = subject.toDbString();
      if (tag != null) queryParams['tag'] = tag;
      if (searchQuery != null) queryParams['search'] = searchQuery;
      if (showAnsweredOnly) queryParams['answered'] = 'true';
      if (showUnansweredOnly) queryParams['unanswered'] = 'true';

      final response = await ApiClient.get('/connect/questions', queryParams: queryParams);
      final list = response is List ? response : (response as Map<String, dynamic>)['questions'] as List? ?? [];
      return list
          .map((row) => _questionFromApiResponse(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching questions: $e');
      return _getMockQuestions();
    }
  }

  /// Get a single question by ID with its answers.
  Future<Question?> getQuestionById(String id) async {
    try {
      final response = await ApiClient.get('/connect/questions/$id');
      if (response == null) return null;
      return _questionFromApiResponse(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error fetching question: $e');
      final mockQuestions = _getMockQuestions();
      return mockQuestions.firstWhere((q) => q.id == id, orElse: () => mockQuestions.first);
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
    try {
      final response = await ApiClient.post('/connect/questions', {
        'title': title,
        'content': content,
        'subject': subject,
        'tags': tags,
        'isAnonymous': isAnonymous,
      });
      return _questionFromApiResponse(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error submitting question: $e');
      return Question(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        title: title, content: content,
        subject: ProjectSubject.fromString(subject),
        tags: tags,
        author: const QuestionAuthor(id: '', name: 'You'),
        isAnonymous: isAnonymous,
        upvotes: 0, downvotes: 0, answerCount: 0, viewCount: 0,
        isAnswered: false, createdAt: DateTime.now(),
      );
    }
  }

  /// Submit an answer to a question.
  Future<Answer> submitAnswer({
    required String questionId,
    required String content,
  }) async {
    try {
      final response = await ApiClient.post('/connect/questions/$questionId/answers', {
        'content': content,
      });
      return _answerFromApiResponse(response as Map<String, dynamic>);
    } catch (e) {
      _logger.e('Error submitting answer: $e');
      return Answer(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        questionId: questionId, content: content,
        author: const QuestionAuthor(id: '', name: 'You'),
        upvotes: 0, downvotes: 0, isAccepted: false, createdAt: DateTime.now(),
      );
    }
  }

  /// Vote on a question.
  Future<void> voteQuestion({required String questionId, required bool isUpvote}) async {
    try {
      await ApiClient.post('/connect/questions/$questionId/vote', {'isUpvote': isUpvote});
    } catch (e) {
      _logger.e('Error voting on question: $e');
    }
  }

  /// Vote on an answer.
  Future<void> voteAnswer({required String answerId, required bool isUpvote}) async {
    try {
      await ApiClient.post('/connect/answers/$answerId/vote', {'isUpvote': isUpvote});
    } catch (e) {
      _logger.e('Error voting on answer: $e');
    }
  }

  /// Accept an answer as the solution.
  Future<void> acceptAnswer({required String questionId, required String answerId}) async {
    try {
      await ApiClient.post('/connect/questions/$questionId/accept', {'answerId': answerId});
    } catch (e) {
      _logger.e('Error accepting answer: $e');
    }
  }

  /// Get mock questions for development/demo purposes.
  List<Question> _getMockQuestions() {
    return [
      Question(
        id: 'q-1',
        title: 'How do I properly cite a website in APA 7 format?',
        content: "I'm working on a research paper and need to cite several websites.",
        subject: ProjectSubject.other,
        tags: ['APA', 'citations', 'research'],
        author: const QuestionAuthor(id: 'user-1', name: 'StudentResearcher', isVerified: false),
        upvotes: 23, downvotes: 2, answerCount: 5, viewCount: 156,
        isAnswered: true, createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Question(
        id: 'q-2',
        title: 'Best approach for multiple regression analysis?',
        content: 'Working on a statistics project.',
        subject: ProjectSubject.mathematics,
        tags: ['statistics', 'regression'],
        author: const QuestionAuthor(id: 'user-2', name: 'DataNerd42', isVerified: true),
        upvotes: 15, downvotes: 0, answerCount: 3, viewCount: 89,
        isAnswered: false, createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }
}

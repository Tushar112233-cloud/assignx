import 'package:flutter/material.dart';
import 'project_subject.dart';

/// Status of a question.
enum QuestionStatus {
  open('Open'),
  answered('Answered'),
  closed('Closed');

  final String displayName;
  const QuestionStatus(this.displayName);
}

/// Sort options for questions.
enum QuestionSortOption {
  latest('Latest', Icons.access_time),
  popular('Most Popular', Icons.trending_up),
  unanswered('Unanswered', Icons.help_outline);

  final String displayName;
  final IconData icon;
  const QuestionSortOption(this.displayName, this.icon);
}

/// Author of a question or answer.
class QuestionAuthor {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isExpert;
  final bool isVerified;

  const QuestionAuthor({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isExpert = false,
    this.isVerified = false,
  });

  /// Create from JSON.
  factory QuestionAuthor.fromJson(Map<String, dynamic> json) {
    return QuestionAuthor(
      id: json['id'] as String,
      name: json['full_name'] as String? ?? json['name'] as String? ?? 'Anonymous',
      avatarUrl: json['avatar_url'] as String?,
      isExpert: json['is_expert'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'is_expert': isExpert,
      'is_verified': isVerified,
    };
  }

  /// Get initials for avatar fallback.
  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}

/// Answer to a question.
class Answer {
  final String id;
  final String questionId;
  final String content;
  final QuestionAuthor author;
  final int upvotes;
  final int downvotes;
  final bool isAccepted;
  final bool isUpvoted;
  final bool isDownvoted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Answer({
    required this.id,
    required this.questionId,
    required this.content,
    required this.author,
    this.upvotes = 0,
    this.downvotes = 0,
    this.isAccepted = false,
    this.isUpvoted = false,
    this.isDownvoted = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Net vote score.
  int get voteScore => upvotes - downvotes;

  /// Create from JSON.
  factory Answer.fromJson(Map<String, dynamic> json) {
    final authorData = json['author'] as Map<String, dynamic>?;

    return Answer(
      id: json['id'] as String,
      questionId: json['question_id'] as String,
      content: json['content'] as String,
      author: authorData != null
          ? QuestionAuthor.fromJson(authorData)
          : QuestionAuthor(
              id: json['author_id'] as String? ?? '',
              name: 'Anonymous',
            ),
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      isAccepted: json['is_accepted'] as bool? ?? false,
      isUpvoted: json['is_upvoted'] as bool? ?? false,
      isDownvoted: json['is_downvoted'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content': content,
      'author': author.toJson(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'is_accepted': isAccepted,
      'is_upvoted': isUpvoted,
      'is_downvoted': isDownvoted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  /// Copy with updated fields.
  Answer copyWith({
    String? id,
    String? questionId,
    String? content,
    QuestionAuthor? author,
    int? upvotes,
    int? downvotes,
    bool? isAccepted,
    bool? isUpvoted,
    bool? isDownvoted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Answer(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      content: content ?? this.content,
      author: author ?? this.author,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      isAccepted: isAccepted ?? this.isAccepted,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      isDownvoted: isDownvoted ?? this.isDownvoted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Question model for Q&A section.
class Question {
  final String id;
  final String title;
  final String? content;
  final ProjectSubject subject;
  final List<String> tags;
  final QuestionAuthor author;
  final bool isAnonymous;
  final int upvotes;
  final int downvotes;
  final int answerCount;
  final int viewCount;
  final bool isAnswered;
  final bool isUpvoted;
  final bool isDownvoted;
  final QuestionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Answer? acceptedAnswer;
  final List<Answer>? answers;

  const Question({
    required this.id,
    required this.title,
    this.content,
    required this.subject,
    this.tags = const [],
    required this.author,
    this.isAnonymous = false,
    this.upvotes = 0,
    this.downvotes = 0,
    this.answerCount = 0,
    this.viewCount = 0,
    this.isAnswered = false,
    this.isUpvoted = false,
    this.isDownvoted = false,
    this.status = QuestionStatus.open,
    required this.createdAt,
    this.updatedAt,
    this.acceptedAnswer,
    this.answers,
  });

  /// Net vote score.
  int get voteScore => upvotes - downvotes;

  /// Get time ago string.
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  /// Display author name (respecting anonymous setting).
  String get displayAuthorName {
    if (isAnonymous) return 'Anonymous';
    return author.name;
  }

  /// Display avatar (null if anonymous).
  String? get displayAvatarUrl {
    if (isAnonymous) return null;
    return author.avatarUrl;
  }

  /// Get author initials (or ? if anonymous).
  String get authorInitials {
    if (isAnonymous) return '?';
    return author.initials;
  }

  /// Create from JSON.
  factory Question.fromJson(Map<String, dynamic> json) {
    final authorData = json['author'] as Map<String, dynamic>?;
    final answersData = json['answers'] as List<dynamic>?;
    final acceptedAnswerData = json['accepted_answer'] as Map<String, dynamic>?;

    return Question(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      subject: ProjectSubject.fromString(json['subject'] as String?),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      author: authorData != null
          ? QuestionAuthor.fromJson(authorData)
          : QuestionAuthor(
              id: json['author_id'] as String? ?? '',
              name: 'Anonymous',
            ),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      upvotes: json['upvotes'] as int? ?? 0,
      downvotes: json['downvotes'] as int? ?? 0,
      answerCount: json['answer_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      isAnswered: json['is_answered'] as bool? ?? false,
      isUpvoted: json['is_upvoted'] as bool? ?? false,
      isDownvoted: json['is_downvoted'] as bool? ?? false,
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      acceptedAnswer: acceptedAnswerData != null
          ? Answer.fromJson(acceptedAnswerData)
          : null,
      answers: answersData?.map((a) => Answer.fromJson(a as Map<String, dynamic>)).toList(),
    );
  }

  /// Parse status from string.
  static QuestionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'answered':
        return QuestionStatus.answered;
      case 'closed':
        return QuestionStatus.closed;
      default:
        return QuestionStatus.open;
    }
  }

  /// Convert to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'subject': subject.toDbString(),
      'tags': tags,
      'author': author.toJson(),
      'is_anonymous': isAnonymous,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'answer_count': answerCount,
      'view_count': viewCount,
      'is_answered': isAnswered,
      'is_upvoted': isUpvoted,
      'is_downvoted': isDownvoted,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'accepted_answer': acceptedAnswer?.toJson(),
      'answers': answers?.map((a) => a.toJson()).toList(),
    };
  }

  /// Copy with updated fields.
  Question copyWith({
    String? id,
    String? title,
    String? content,
    ProjectSubject? subject,
    List<String>? tags,
    QuestionAuthor? author,
    bool? isAnonymous,
    int? upvotes,
    int? downvotes,
    int? answerCount,
    int? viewCount,
    bool? isAnswered,
    bool? isUpvoted,
    bool? isDownvoted,
    QuestionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Answer? acceptedAnswer,
    List<Answer>? answers,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      answerCount: answerCount ?? this.answerCount,
      viewCount: viewCount ?? this.viewCount,
      isAnswered: isAnswered ?? this.isAnswered,
      isUpvoted: isUpvoted ?? this.isUpvoted,
      isDownvoted: isDownvoted ?? this.isDownvoted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAnswer: acceptedAnswer ?? this.acceptedAnswer,
      answers: answers ?? this.answers,
    );
  }
}

/// Filter state for Q&A questions.
class QAFilterState {
  final ProjectSubject? subject;
  final String? tag;
  final String? searchQuery;
  final QuestionSortOption sortBy;
  final bool showAnsweredOnly;
  final bool showUnansweredOnly;

  const QAFilterState({
    this.subject,
    this.tag,
    this.searchQuery,
    this.sortBy = QuestionSortOption.latest,
    this.showAnsweredOnly = false,
    this.showUnansweredOnly = false,
  });

  /// Check if any filters are active.
  bool get hasFilters =>
      subject != null ||
      tag != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      showAnsweredOnly ||
      showUnansweredOnly;

  /// Copy with updated fields.
  QAFilterState copyWith({
    ProjectSubject? subject,
    String? tag,
    String? searchQuery,
    QuestionSortOption? sortBy,
    bool? showAnsweredOnly,
    bool? showUnansweredOnly,
    bool clearSubject = false,
    bool clearTag = false,
    bool clearSearch = false,
  }) {
    return QAFilterState(
      subject: clearSubject ? null : (subject ?? this.subject),
      tag: clearTag ? null : (tag ?? this.tag),
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      sortBy: sortBy ?? this.sortBy,
      showAnsweredOnly: showAnsweredOnly ?? this.showAnsweredOnly,
      showUnansweredOnly: showUnansweredOnly ?? this.showUnansweredOnly,
    );
  }
}

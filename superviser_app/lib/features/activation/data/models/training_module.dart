/// Training module model for supervisor activation.
///
/// Represents a training module that supervisors must complete.
class TrainingModule {
  const TrainingModule({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.contentUrl,
    required this.durationMinutes,
    this.thumbnailUrl,
    this.isCompleted = false,
    this.completedAt,
  });

  /// Unique identifier
  final String id;

  /// Module title
  final String title;

  /// Module description
  final String description;

  /// Content type (video, pdf, quiz)
  final ModuleType type;

  /// URL to content (video URL, PDF URL, or quiz ID)
  final String contentUrl;

  /// Estimated duration in minutes
  final int durationMinutes;

  /// Optional thumbnail URL
  final String? thumbnailUrl;

  /// Whether the module is completed
  final bool isCompleted;

  /// Completion timestamp
  final DateTime? completedAt;

  TrainingModule copyWith({
    String? id,
    String? title,
    String? description,
    ModuleType? type,
    String? contentUrl,
    int? durationMinutes,
    String? thumbnailUrl,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return TrainingModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      contentUrl: contentUrl ?? this.contentUrl,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory TrainingModule.fromJson(Map<String, dynamic> json) {
    return TrainingModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: ModuleType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ModuleType.video,
      ),
      contentUrl: json['content_url'] as String,
      durationMinutes: json['duration_minutes'] as int,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'content_url': contentUrl,
      'duration_minutes': durationMinutes,
      'thumbnail_url': thumbnailUrl,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

/// Module content type
enum ModuleType {
  video,
  pdf,
  quiz,
}

/// Quiz model for supervisor test
class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.passingScore,
    required this.timeLimitMinutes,
    this.maxAttempts = 3,
  });

  /// Unique identifier
  final String id;

  /// Quiz title
  final String title;

  /// Quiz description
  final String description;

  /// List of questions
  final List<QuizQuestion> questions;

  /// Minimum score to pass (percentage)
  final int passingScore;

  /// Time limit in minutes
  final int timeLimitMinutes;

  /// Maximum allowed attempts
  final int maxAttempts;

  /// Total number of questions
  int get totalQuestions => questions.length;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      passingScore: json['passing_score'] as int,
      timeLimitMinutes: json['time_limit_minutes'] as int,
      maxAttempts: json['max_attempts'] as int? ?? 3,
    );
  }
}

/// Quiz question model
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
  });

  /// Unique identifier
  final String id;

  /// Question text
  final String question;

  /// List of answer options
  final List<String> options;

  /// Index of the correct answer (0-based)
  final int correctOptionIndex;

  /// Optional explanation for the correct answer
  final String? explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: List<String>.from(json['options'] as List),
      correctOptionIndex: json['correct_option_index'] as int,
      explanation: json['explanation'] as String?,
    );
  }
}

/// Quiz attempt result
class QuizResult {
  const QuizResult({
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.timeTakenSeconds,
    required this.passed,
    required this.attemptNumber,
    this.completedAt,
  });

  /// Quiz ID
  final String quizId;

  /// Score as percentage
  final int score;

  /// Total number of questions
  final int totalQuestions;

  /// Number of correct answers
  final int correctAnswers;

  /// Time taken in seconds
  final int timeTakenSeconds;

  /// Whether the attempt passed
  final bool passed;

  /// Attempt number (1, 2, 3, etc.)
  final int attemptNumber;

  /// Completion timestamp
  final DateTime? completedAt;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      quizId: json['quiz_id'] as String,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      timeTakenSeconds: json['time_taken_seconds'] as int,
      passed: json['passed'] as bool,
      attemptNumber: json['attempt_number'] as int,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'time_taken_seconds': timeTakenSeconds,
      'passed': passed,
      'attempt_number': attemptNumber,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

/// Default training modules for supervisors
List<TrainingModule> get defaultTrainingModules => [
      const TrainingModule(
        id: 'module_1',
        title: 'Welcome to AssignX',
        description: 'Introduction to the platform and your role as a supervisor.',
        type: ModuleType.video,
        contentUrl: 'https://example.com/videos/welcome.mp4',
        durationMinutes: 5,
      ),
      const TrainingModule(
        id: 'module_2',
        title: 'Platform Guidelines',
        description: 'Understanding our quality standards and expectations.',
        type: ModuleType.pdf,
        contentUrl: 'https://example.com/docs/guidelines.pdf',
        durationMinutes: 10,
      ),
      const TrainingModule(
        id: 'module_3',
        title: 'Project Workflow',
        description: 'Learn how to manage and complete assignments effectively.',
        type: ModuleType.video,
        contentUrl: 'https://example.com/videos/workflow.mp4',
        durationMinutes: 8,
      ),
      const TrainingModule(
        id: 'module_4',
        title: 'Communication Best Practices',
        description: 'Guidelines for professional communication with clients.',
        type: ModuleType.pdf,
        contentUrl: 'https://example.com/docs/communication.pdf',
        durationMinutes: 7,
      ),
      const TrainingModule(
        id: 'module_5',
        title: 'Supervisor Assessment',
        description: 'Complete this quiz to demonstrate your understanding.',
        type: ModuleType.quiz,
        contentUrl: 'quiz_supervisor_test',
        durationMinutes: 15,
      ),
    ];

/// Default quiz for supervisor test
Quiz get defaultSupervisorQuiz => const Quiz(
      id: 'quiz_supervisor_test',
      title: 'Supervisor Assessment',
      description: 'Test your knowledge of platform guidelines and workflows.',
      passingScore: 70,
      timeLimitMinutes: 15,
      maxAttempts: 3,
      questions: [
        QuizQuestion(
          id: 'q1',
          question: 'What is the recommended response time for client messages?',
          options: [
            'Within 1 hour',
            'Within 24 hours',
            'Within 48 hours',
            'Whenever convenient',
          ],
          correctOptionIndex: 1,
          explanation: 'We recommend responding to client messages within 24 hours to maintain professional communication.',
        ),
        QuizQuestion(
          id: 'q2',
          question: 'What should you do if you cannot meet a deadline?',
          options: [
            'Wait until the deadline passes',
            'Cancel the assignment',
            'Communicate early and request an extension',
            'Submit incomplete work',
          ],
          correctOptionIndex: 2,
          explanation: 'Always communicate proactively if you anticipate any delays.',
        ),
        QuizQuestion(
          id: 'q3',
          question: 'What is the minimum quality score required for submissions?',
          options: [
            '60%',
            '70%',
            '80%',
            '90%',
          ],
          correctOptionIndex: 2,
          explanation: 'All submissions must maintain a minimum 80% quality score.',
        ),
        QuizQuestion(
          id: 'q4',
          question: 'How are payments processed?',
          options: [
            'Daily',
            'Weekly',
            'Bi-weekly',
            'Monthly',
          ],
          correctOptionIndex: 2,
          explanation: 'Payments are processed bi-weekly for all completed assignments.',
        ),
        QuizQuestion(
          id: 'q5',
          question: 'What should you do if a client requests work outside the original scope?',
          options: [
            'Complete it for free',
            'Ignore the request',
            'Discuss additional charges through proper channels',
            'Refuse immediately',
          ],
          correctOptionIndex: 2,
          explanation: 'Any scope changes should be discussed and properly documented with appropriate compensation.',
        ),
      ],
    );

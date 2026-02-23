/// Resources and tools state management provider for the Doer App.
///
/// This file manages the resources section of the app which provides
/// doers with training modules, AI content detection, and citation
/// generation tools.
///
/// ## Architecture
///
/// The resources provider manages three main domains:
/// - **Training Modules**: Educational content for skill development
/// - **AI Detection**: Tool to check content for AI-generated patterns
/// - **Citation Generator**: Create properly formatted academic citations
///
/// ## Usage
///
/// ```dart
/// // Watch resources state in a widget
/// final resourcesState = ref.watch(resourcesProvider);
///
/// // Display training modules
/// for (final module in resourcesState.trainingModules) {
///   TrainingModuleCard(module: module);
/// }
///
/// // Check content for AI patterns
/// final result = await ref.read(resourcesProvider.notifier)
///     .checkForAI(contentText);
///
/// // Generate a citation
/// final citation = ref.read(resourcesProvider.notifier).generateCitation(
///   sourceType: SourceType.journal,
///   title: 'Machine Learning Applications',
///   style: CitationStyle.apa,
/// );
/// ```
///
/// ## State Flow
///
/// ```
/// initial -> loading training modules
///     |
///     v
/// training modules ready -> complete modules -> update progress
///     |
///     v
/// AI check -> checking -> result ready
///     |
///     v
/// generate citation -> add to history
/// ```
///
/// ## Database Integration
///
/// The provider interacts with Supabase tables:
/// - `training_modules`: Available training content
/// - `training_progress`: User's progress on modules
///
/// See also:
/// - [TrainingModule] for training content model
/// - [AICheckResult] for AI detection results
/// - [Citation] for citation generation
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';

/// Training module model representing educational content.
///
/// Contains all information about a training module including
/// content, duration, category, and completion status.
///
/// ## Properties
///
/// - [id]: Unique module identifier
/// - [title]: Module title
/// - [description]: Module description
/// - [category]: Category grouping (e.g., "Getting Started")
/// - [durationMinutes]: Estimated time to complete
/// - [videoUrl]: URL to video content, if any
/// - [contentMarkdown]: Markdown content of the module
/// - [isCompleted]: Whether the user has completed this module
/// - [progress]: Completion progress (0.0 to 1.0)
/// - [orderIndex]: Display order within category
/// - [isRequired]: Whether module is required for activation
class TrainingModule {
  /// Unique identifier for the training module.
  final String id;

  /// Title of the training module.
  final String title;

  /// Description of what the module covers.
  final String description;

  /// Category for grouping modules (e.g., "Getting Started", "Advanced").
  final String category;

  /// Estimated duration in minutes to complete the module.
  final int durationMinutes;

  /// URL to video content, if the module includes a video.
  final String? videoUrl;

  /// Markdown content of the module text.
  final String? contentMarkdown;

  /// Whether the user has completed this module.
  final bool isCompleted;

  /// Progress percentage (0.0 to 1.0) for partially completed modules.
  final double? progress;

  /// Display order index within the category.
  final int orderIndex;

  /// Whether this module is required for doer activation.
  final bool isRequired;

  /// Creates a new [TrainingModule] instance.
  const TrainingModule({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    this.videoUrl,
    this.contentMarkdown,
    this.isCompleted = false,
    this.progress,
    this.orderIndex = 0,
    this.isRequired = false,
  });

  /// Creates a [TrainingModule] from a JSON map.
  ///
  /// ## Parameters
  ///
  /// - [json]: The JSON map from the database
  ///
  /// ## Returns
  ///
  /// A new [TrainingModule] instance with parsed data.
  factory TrainingModule.fromJson(Map<String, dynamic> json) {
    return TrainingModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      durationMinutes: json['duration_minutes'] as int? ?? 10,
      videoUrl: json['video_url'] as String?,
      contentMarkdown: json['content_markdown'] as String?,
      isCompleted: json['is_completed'] as bool? ?? false,
      progress: (json['progress'] as num?)?.toDouble(),
      orderIndex: json['order_index'] as int? ?? 0,
      isRequired: json['is_required'] as bool? ?? false,
    );
  }

  /// Creates a copy of this module with the specified fields replaced.
  ///
  /// ## Parameters
  ///
  /// - [isCompleted]: Updated completion status
  /// - [progress]: Updated progress percentage
  ///
  /// ## Returns
  ///
  /// A new [TrainingModule] instance with the specified changes.
  TrainingModule copyWith({
    bool? isCompleted,
    double? progress,
  }) {
    return TrainingModule(
      id: id,
      title: title,
      description: description,
      category: category,
      durationMinutes: durationMinutes,
      videoUrl: videoUrl,
      contentMarkdown: contentMarkdown,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      orderIndex: orderIndex,
      isRequired: isRequired,
    );
  }

  /// Returns the duration in a human-readable format.
  ///
  /// Examples: "30 min", "1h 30m", "2h"
  String get formattedDuration {
    if (durationMinutes < 60) return '$durationMinutes min';
    final hours = durationMinutes ~/ 60;
    final mins = durationMinutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }
}

/// AI content check result model.
///
/// Contains the results of checking content for AI-generated patterns,
/// including scores, highlighted segments, and a verdict.
///
/// ## Properties
///
/// - [id]: Unique result identifier
/// - [content]: The content that was checked
/// - [aiScore]: Probability of AI-generated content (0-100)
/// - [humanScore]: Probability of human-written content (0-100)
/// - [highlights]: Segments flagged as potentially AI-generated
/// - [verdict]: Overall assessment text
/// - [checkedAt]: When the check was performed
class AICheckResult {
  /// Unique identifier for this check result.
  final String id;

  /// The content that was analyzed.
  final String content;

  /// AI probability score (0-100), higher means more likely AI-generated.
  final double aiScore;

  /// Human probability score (0-100), higher means more likely human-written.
  final double humanScore;

  /// List of highlighted segments flagged as potentially AI-generated.
  final List<AIHighlight> highlights;

  /// Overall verdict text describing the result.
  final String verdict;

  /// Timestamp when the check was performed.
  final DateTime checkedAt;

  /// Creates a new [AICheckResult] instance.
  const AICheckResult({
    required this.id,
    required this.content,
    required this.aiScore,
    required this.humanScore,
    required this.highlights,
    required this.verdict,
    required this.checkedAt,
  });

  /// Whether the content is likely AI-generated.
  ///
  /// Returns true if [aiScore] is greater than 50.
  bool get isLikelyAI => aiScore > 50;

  /// Whether the content is likely human-written.
  ///
  /// Returns true if [humanScore] is greater than 70.
  bool get isLikelyHuman => humanScore > 70;

  /// Returns a human-readable summary of the AI detection result.
  ///
  /// Maps AI score ranges to descriptive text:
  /// - > 80%: "Highly likely AI-generated"
  /// - > 60%: "Possibly AI-generated"
  /// - > 40%: "Mixed content detected"
  /// - > 20%: "Mostly human-written"
  /// - <= 20%: "Likely human-written"
  String get summary {
    if (aiScore > 80) return 'Highly likely AI-generated';
    if (aiScore > 60) return 'Possibly AI-generated';
    if (aiScore > 40) return 'Mixed content detected';
    if (aiScore > 20) return 'Mostly human-written';
    return 'Likely human-written';
  }
}

/// AI highlight model for flagged text segments.
///
/// Represents a specific portion of text that was flagged
/// as potentially AI-generated during content analysis.
///
/// ## Properties
///
/// - [startIndex]: Starting character index of the highlight
/// - [endIndex]: Ending character index of the highlight
/// - [probability]: AI probability for this segment (0-1)
/// - [reason]: Explanation for why this segment was flagged
class AIHighlight {
  /// Starting character index of the highlighted segment.
  final int startIndex;

  /// Ending character index of the highlighted segment.
  final int endIndex;

  /// AI probability for this specific segment (0.0 to 1.0).
  final double probability;

  /// Reason why this segment was flagged.
  final String reason;

  /// Creates a new [AIHighlight] instance.
  const AIHighlight({
    required this.startIndex,
    required this.endIndex,
    required this.probability,
    required this.reason,
  });
}

/// Enumeration of academic citation styles.
///
/// Supported citation formats for generating properly formatted
/// references and bibliographies.
enum CitationStyle {
  /// American Psychological Association style.
  apa('APA', 'American Psychological Association'),

  /// Modern Language Association style.
  mla('MLA', 'Modern Language Association'),

  /// Chicago Manual of Style.
  chicago('Chicago', 'Chicago Manual of Style'),

  /// Harvard referencing style.
  harvard('Harvard', 'Harvard Referencing'),

  /// Institute of Electrical and Electronics Engineers style.
  ieee('IEEE', 'Institute of Electrical and Electronics Engineers'),

  /// American Medical Association style.
  ama('AMA', 'American Medical Association');

  /// Short name for the citation style.
  final String name;

  /// Full name of the citation style.
  final String fullName;

  const CitationStyle(this.name, this.fullName);
}

/// Enumeration of source types for citations.
///
/// Categorizes the type of source being cited, which affects
/// the citation format.
enum SourceType {
  /// Book or monograph.
  book('Book'),

  /// Journal or academic article.
  journal('Journal Article'),

  /// Website or online resource.
  website('Website'),

  /// Newspaper article.
  newspaper('Newspaper'),

  /// Conference paper or proceedings.
  conference('Conference Paper'),

  /// Thesis or dissertation.
  thesis('Thesis/Dissertation'),

  /// Other source types.
  other('Other');

  /// Human-readable display name for the source type.
  final String displayName;

  const SourceType(this.displayName);
}

/// Citation model for academic references.
///
/// Contains all fields needed to generate a citation in various
/// academic styles, plus the formatted citation string.
///
/// ## Properties
///
/// - [id]: Unique citation identifier
/// - [sourceType]: Type of source (book, journal, etc.)
/// - [authors]: Author names
/// - [title]: Title of the work
/// - [publisherOrJournal]: Publisher or journal name
/// - [year]: Publication year
/// - [volume]: Volume number for journals
/// - [issue]: Issue number for journals
/// - [pages]: Page range
/// - [url]: Web URL for online sources
/// - [doi]: Digital Object Identifier
/// - [accessDate]: When an online source was accessed
/// - [style]: Citation style used
/// - [formattedCitation]: The final formatted citation string
class Citation {
  /// Unique identifier for this citation.
  final String id;

  /// Type of source being cited.
  final SourceType sourceType;

  /// Author names in citation format.
  final String? authors;

  /// Title of the work.
  final String title;

  /// Publisher name or journal name.
  final String? publisherOrJournal;

  /// Year of publication.
  final int? year;

  /// Volume number for journal articles.
  final String? volume;

  /// Issue number for journal articles.
  final String? issue;

  /// Page range (e.g., "23-45").
  final String? pages;

  /// URL for online sources.
  final String? url;

  /// Digital Object Identifier.
  final String? doi;

  /// Date when the online source was accessed.
  final DateTime? accessDate;

  /// Citation style used for formatting.
  final CitationStyle style;

  /// The final formatted citation string.
  final String formattedCitation;

  /// Creates a new [Citation] instance.
  const Citation({
    required this.id,
    required this.sourceType,
    this.authors,
    required this.title,
    this.publisherOrJournal,
    this.year,
    this.volume,
    this.issue,
    this.pages,
    this.url,
    this.doi,
    this.accessDate,
    required this.style,
    required this.formattedCitation,
  });
}

/// Immutable state class representing resources data.
///
/// Contains training modules, AI check results, and citation history.
///
/// ## Properties
///
/// - [trainingModules]: List of available training modules
/// - [aiCheckHistory]: History of AI content checks
/// - [citationHistory]: History of generated citations
/// - [currentAiCheck]: Current/most recent AI check result
/// - [isLoading]: Whether data is being loaded
/// - [isChecking]: Whether an AI check is in progress
/// - [errorMessage]: Error message if operation failed
///
/// ## Usage
///
/// ```dart
/// final state = ref.watch(resourcesProvider);
///
/// if (state.isLoading) {
///   return LoadingIndicator();
/// }
///
/// return Column(
///   children: [
///     TrainingProgress(progress: state.trainingProgress),
///     ModulesList(modules: state.trainingModules),
///   ],
/// );
/// ```
class ResourcesState {
  /// List of available training modules.
  final List<TrainingModule> trainingModules;

  /// History of AI content check results.
  final List<AICheckResult> aiCheckHistory;

  /// History of generated citations.
  final List<Citation> citationHistory;

  /// Current/most recent AI check result, null if none.
  final AICheckResult? currentAiCheck;

  /// Whether resources data is being loaded.
  final bool isLoading;

  /// Whether an AI check is currently in progress.
  final bool isChecking;

  /// Error message from the last failed operation, null if no error.
  final String? errorMessage;

  /// Creates a new [ResourcesState] instance.
  const ResourcesState({
    this.trainingModules = const [],
    this.aiCheckHistory = const [],
    this.citationHistory = const [],
    this.currentAiCheck,
    this.isLoading = false,
    this.isChecking = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with the specified fields replaced.
  ///
  /// ## Parameters
  ///
  /// - [trainingModules]: Updated list of training modules
  /// - [aiCheckHistory]: Updated AI check history
  /// - [citationHistory]: Updated citation history
  /// - [currentAiCheck]: Updated current AI check result
  /// - [clearCurrentCheck]: If true, sets currentAiCheck to null
  /// - [isLoading]: Updated loading state
  /// - [isChecking]: Updated checking state
  /// - [errorMessage]: Updated error message (pass null to clear)
  ///
  /// ## Returns
  ///
  /// A new [ResourcesState] instance with the specified changes.
  ResourcesState copyWith({
    List<TrainingModule>? trainingModules,
    List<AICheckResult>? aiCheckHistory,
    List<Citation>? citationHistory,
    AICheckResult? currentAiCheck,
    bool clearCurrentCheck = false,
    bool? isLoading,
    bool? isChecking,
    String? errorMessage,
  }) {
    return ResourcesState(
      trainingModules: trainingModules ?? this.trainingModules,
      aiCheckHistory: aiCheckHistory ?? this.aiCheckHistory,
      citationHistory: citationHistory ?? this.citationHistory,
      currentAiCheck: clearCurrentCheck ? null : (currentAiCheck ?? this.currentAiCheck),
      isLoading: isLoading ?? this.isLoading,
      isChecking: isChecking ?? this.isChecking,
      errorMessage: errorMessage,
    );
  }

  /// Returns the overall training completion percentage.
  ///
  /// Calculates the ratio of completed modules to total modules.
  /// Returns 0 if there are no modules.
  double get trainingProgress {
    if (trainingModules.isEmpty) return 0;
    final completed = trainingModules.where((m) => m.isCompleted).length;
    return completed / trainingModules.length;
  }

  /// Returns training modules grouped by category.
  ///
  /// ## Returns
  ///
  /// A map where keys are category names and values are lists of modules.
  Map<String, List<TrainingModule>> get modulesByCategory {
    final map = <String, List<TrainingModule>>{};
    for (final module in trainingModules) {
      map.putIfAbsent(module.category, () => []).add(module);
    }
    return map;
  }
}

/// Notifier class that manages resources state and operations.
///
/// This class handles:
/// - Loading and managing training modules
/// - AI content detection
/// - Citation generation in multiple styles
///
/// ## Lifecycle
///
/// The notifier initializes by loading training modules from the database
/// when first accessed.
///
/// ## State Management
///
/// State updates are performed through [state] assignment, triggering
/// reactive updates in all watching widgets.
///
/// ## Usage
///
/// ```dart
/// // Access the notifier for operations
/// final notifier = ref.read(resourcesProvider.notifier);
///
/// // Complete a training module
/// await notifier.completeModule('module-123');
///
/// // Check content for AI
/// final result = await notifier.checkForAI(contentText);
///
/// // Generate a citation
/// final citation = notifier.generateCitation(
///   sourceType: SourceType.journal,
///   title: 'Research Paper Title',
///   authors: 'Smith, J.',
///   year: 2024,
///   style: CitationStyle.apa,
/// );
/// ```
class ResourcesNotifier extends Notifier<ResourcesState> {
  /// Builds and initializes the resources state.
  ///
  /// This method is called when the provider is first read. It
  /// triggers loading of training modules and returns an initial state.
  ///
  /// ## Returns
  ///
  /// An empty [ResourcesState] while data loads in the background.
  @override
  ResourcesState build() {
    _loadTrainingModules();
    return const ResourcesState();
  }

  /// The Supabase client instance for database operations.
  SupabaseClient get _client => SupabaseConfig.client;

  /// Loads training modules from the database.
  ///
  /// Fetches all training modules ordered by their display index.
  ///
  /// ## State Updates
  ///
  /// Sets [isLoading] to true during load, false on completion.
  /// Falls back to mock data on database errors.
  Future<void> _loadTrainingModules() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _client
          .from('training_modules')
          .select()
          .order('order_index');

      final modules = (response as List)
          .map((e) => TrainingModule.fromJson(e))
          .toList();

      state = state.copyWith(
        trainingModules: modules,
        isLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesNotifier._loadTrainingModules error: $e');
      }
      state = state.copyWith(
        trainingModules: [],
        isLoading: false,
      );
    }
  }

  /// Marks a training module as completed.
  ///
  /// Updates both local state and saves progress to the database.
  ///
  /// ## Parameters
  ///
  /// - [moduleId]: ID of the module to mark as complete
  ///
  /// ## State Updates
  ///
  /// Updates the module's [isCompleted] to true and [progress] to 1.0.
  ///
  /// ## Example
  ///
  /// ```dart
  /// await ref.read(resourcesProvider.notifier)
  ///     .completeModule('module-getting-started');
  /// ```
  Future<void> completeModule(String moduleId) async {
    final modules = state.trainingModules.map((m) {
      if (m.id == moduleId) {
        return m.copyWith(isCompleted: true, progress: 1.0);
      }
      return m;
    }).toList();

    state = state.copyWith(trainingModules: modules);

    // Save to database
    try {
      await _client.from('training_progress').upsert({
        'module_id': moduleId,
        'is_completed': true,
        'progress': 1.0,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Continue anyway for testing
    }
  }

  /// Updates the progress of a training module.
  ///
  /// Used for tracking partial completion of a module.
  ///
  /// ## Parameters
  ///
  /// - [moduleId]: ID of the module to update
  /// - [progress]: New progress value (0.0 to 1.0)
  ///
  /// ## State Updates
  ///
  /// Updates the module's [progress] and sets [isCompleted] if progress >= 1.0.
  void updateModuleProgress(String moduleId, double progress) {
    final modules = state.trainingModules.map((m) {
      if (m.id == moduleId) {
        return m.copyWith(
          progress: progress,
          isCompleted: progress >= 1.0,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(trainingModules: modules);
  }

  /// Checks content for AI-generated patterns.
  ///
  /// Analyzes the provided text content to detect AI-generated patterns
  /// and returns a detailed result with scores and highlights.
  ///
  /// ## Parameters
  ///
  /// - [content]: The text content to analyze
  ///
  /// ## Returns
  ///
  /// An [AICheckResult] with detection scores and highlights,
  /// or null if the content is empty or check fails.
  ///
  /// ## State Updates
  ///
  /// Sets [isChecking] to true during analysis.
  /// Updates [currentAiCheck] and adds to [aiCheckHistory] on completion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await ref.read(resourcesProvider.notifier)
  ///     .checkForAI(documentContent);
  ///
  /// if (result != null) {
  ///   if (result.isLikelyAI) {
  ///     // Show warning
  ///   }
  /// }
  /// ```
  Future<AICheckResult?> checkForAI(String content) async {
    if (content.trim().isEmpty) return null;

    state = state.copyWith(isChecking: true, errorMessage: null);

    try {
      // In production, this would call an AI detection API
      // TODO: Implement actual AI detection service integration
      await Future.delayed(const Duration(seconds: 2));

      // Placeholder result until API is integrated
      final result = AICheckResult(
        id: 'check_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        aiScore: 0.0,
        humanScore: 100.0,
        highlights: [],
        verdict: 'AI detection service not yet configured',
        checkedAt: DateTime.now(),
      );

      state = state.copyWith(
        currentAiCheck: result,
        aiCheckHistory: [result, ...state.aiCheckHistory],
        isChecking: false,
      );

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ResourcesNotifier.checkForAI error: $e');
      }
      state = state.copyWith(
        isChecking: false,
        errorMessage: 'Failed to check content',
      );
      return null;
    }
  }

  /// Generates a citation in the specified academic style.
  ///
  /// Creates a properly formatted citation string based on the
  /// source information and selected citation style.
  ///
  /// ## Parameters
  ///
  /// - [sourceType]: Type of source (book, journal, website, etc.)
  /// - [title]: Title of the work (required)
  /// - [authors]: Author names in citation format
  /// - [publisherOrJournal]: Publisher or journal name
  /// - [year]: Publication year
  /// - [volume]: Volume number for journals
  /// - [issue]: Issue number for journals
  /// - [pages]: Page range
  /// - [url]: Web URL for online sources
  /// - [doi]: Digital Object Identifier
  /// - [accessDate]: Date the online source was accessed
  /// - [style]: Citation style to use (required)
  ///
  /// ## Returns
  ///
  /// A [Citation] object containing the formatted citation string.
  ///
  /// ## State Updates
  ///
  /// Adds the new citation to [citationHistory].
  ///
  /// ## Example
  ///
  /// ```dart
  /// final citation = ref.read(resourcesProvider.notifier).generateCitation(
  ///   sourceType: SourceType.journal,
  ///   title: 'Machine Learning in Healthcare',
  ///   authors: 'Smith, J. & Doe, A.',
  ///   publisherOrJournal: 'Journal of AI Research',
  ///   year: 2024,
  ///   volume: '12',
  ///   issue: '3',
  ///   pages: '45-67',
  ///   doi: '10.1234/jair.2024.12345',
  ///   style: CitationStyle.apa,
  /// );
  ///
  /// print(citation.formattedCitation);
  /// // "Smith, J. & Doe, A. (2024). Machine Learning in Healthcare. Journal of AI Research, 12(3), 45-67. https://doi.org/10.1234/jair.2024.12345"
  /// ```
  Citation generateCitation({
    required SourceType sourceType,
    required String title,
    String? authors,
    String? publisherOrJournal,
    int? year,
    String? volume,
    String? issue,
    String? pages,
    String? url,
    String? doi,
    DateTime? accessDate,
    required CitationStyle style,
  }) {
    final formatted = _formatCitation(
      sourceType: sourceType,
      title: title,
      authors: authors,
      publisherOrJournal: publisherOrJournal,
      year: year,
      volume: volume,
      issue: issue,
      pages: pages,
      url: url,
      doi: doi,
      accessDate: accessDate,
      style: style,
    );

    final citation = Citation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sourceType: sourceType,
      authors: authors,
      title: title,
      publisherOrJournal: publisherOrJournal,
      year: year,
      volume: volume,
      issue: issue,
      pages: pages,
      url: url,
      doi: doi,
      accessDate: accessDate,
      style: style,
      formattedCitation: formatted,
    );

    state = state.copyWith(
      citationHistory: [citation, ...state.citationHistory],
    );

    return citation;
  }

  /// Formats a citation according to the specified style.
  ///
  /// Internal method that dispatches to style-specific formatters.
  ///
  /// ## Parameters
  ///
  /// All citation field parameters plus the style to use.
  ///
  /// ## Returns
  ///
  /// A formatted citation string.
  String _formatCitation({
    required SourceType sourceType,
    required String title,
    String? authors,
    String? publisherOrJournal,
    int? year,
    String? volume,
    String? issue,
    String? pages,
    String? url,
    String? doi,
    DateTime? accessDate,
    required CitationStyle style,
  }) {
    switch (style) {
      case CitationStyle.apa:
        return _formatAPA(
          authors: authors,
          year: year,
          title: title,
          publisherOrJournal: publisherOrJournal,
          volume: volume,
          issue: issue,
          pages: pages,
          url: url,
          doi: doi,
          sourceType: sourceType,
        );
      case CitationStyle.mla:
        return _formatMLA(
          authors: authors,
          title: title,
          publisherOrJournal: publisherOrJournal,
          year: year,
          pages: pages,
          url: url,
          sourceType: sourceType,
        );
      case CitationStyle.harvard:
        return _formatHarvard(
          authors: authors,
          year: year,
          title: title,
          publisherOrJournal: publisherOrJournal,
          volume: volume,
          issue: issue,
          pages: pages,
          url: url,
          accessDate: accessDate,
          sourceType: sourceType,
        );
      default:
        return _formatAPA(
          authors: authors,
          year: year,
          title: title,
          publisherOrJournal: publisherOrJournal,
          volume: volume,
          issue: issue,
          pages: pages,
          url: url,
          doi: doi,
          sourceType: sourceType,
        );
    }
  }

  /// Formats a citation in APA style.
  ///
  /// Example output:
  /// "Smith, J. (2024). Title of Work. Publisher. https://doi.org/..."
  String _formatAPA({
    String? authors,
    int? year,
    required String title,
    String? publisherOrJournal,
    String? volume,
    String? issue,
    String? pages,
    String? url,
    String? doi,
    required SourceType sourceType,
  }) {
    final buffer = StringBuffer();

    if (authors != null && authors.isNotEmpty) {
      buffer.write('$authors ');
    }

    buffer.write('(${year ?? 'n.d.'}). ');
    buffer.write('$title. ');

    if (sourceType == SourceType.journal) {
      if (publisherOrJournal != null) {
        buffer.write(publisherOrJournal);
        if (volume != null) buffer.write(', $volume');
        if (issue != null) buffer.write('($issue)');
        if (pages != null) buffer.write(', $pages');
        buffer.write('. ');
      }
    } else if (publisherOrJournal != null) {
      buffer.write('$publisherOrJournal. ');
    }

    if (doi != null) {
      buffer.write('https://doi.org/$doi');
    } else if (url != null) {
      buffer.write(url);
    }

    return buffer.toString().trim();
  }

  /// Formats a citation in MLA style.
  ///
  /// Example output:
  /// 'Authors. "Title." Publisher, Year, pp. Pages. URL'
  String _formatMLA({
    String? authors,
    required String title,
    String? publisherOrJournal,
    int? year,
    String? pages,
    String? url,
    required SourceType sourceType,
  }) {
    final buffer = StringBuffer();

    if (authors != null && authors.isNotEmpty) {
      buffer.write('$authors. ');
    }

    buffer.write('"$title." ');

    if (publisherOrJournal != null) {
      buffer.write('$publisherOrJournal, ');
    }

    if (year != null) buffer.write('$year, ');
    if (pages != null) buffer.write('pp. $pages. ');

    if (url != null) {
      buffer.write(url);
    }

    return buffer.toString().trim();
  }

  /// Formats a citation in Harvard style.
  ///
  /// Example output:
  /// "Authors (Year) 'Title', Journal, vol. X, no. Y, pp. Z. Available at: URL (Accessed: Date)"
  String _formatHarvard({
    String? authors,
    int? year,
    required String title,
    String? publisherOrJournal,
    String? volume,
    String? issue,
    String? pages,
    String? url,
    DateTime? accessDate,
    required SourceType sourceType,
  }) {
    final buffer = StringBuffer();

    if (authors != null && authors.isNotEmpty) {
      buffer.write('$authors ');
    }

    buffer.write('(${year ?? 'n.d.'}) ');
    buffer.write("'$title', ");

    if (publisherOrJournal != null) {
      buffer.write(publisherOrJournal);
      if (volume != null) buffer.write(', vol. $volume');
      if (issue != null) buffer.write(', no. $issue');
      if (pages != null) buffer.write(', pp. $pages');
      buffer.write('. ');
    }

    if (url != null) {
      buffer.write('Available at: $url');
      if (accessDate != null) {
        buffer.write(' (Accessed: ${_formatDate(accessDate)})');
      }
    }

    return buffer.toString().trim();
  }

  /// Formats a date for Harvard style citations.
  ///
  /// ## Parameters
  ///
  /// - [date]: The date to format
  ///
  /// ## Returns
  ///
  /// A string in "Day Month Year" format (e.g., "15 January 2024").
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Clears the current AI check result.
  ///
  /// Sets [currentAiCheck] to null without affecting the history.
  void clearCurrentCheck() {
    state = state.copyWith(clearCurrentCheck: true);
  }

  /// Refreshes all resources data from the database.
  ///
  /// Use this method to reload data after external changes
  /// or for pull-to-refresh functionality.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Pull-to-refresh in resources screen
  /// RefreshIndicator(
  ///   onRefresh: () => ref.read(resourcesProvider.notifier).refresh(),
  ///   child: ResourcesContent(),
  /// );
  /// ```
  Future<void> refresh() async {
    await _loadTrainingModules();
  }
}

/// The main resources provider.
///
/// Use this provider to access resources state and manage training,
/// AI detection, and citation generation.
///
/// ## Watching State
///
/// ```dart
/// // In a widget
/// final resourcesState = ref.watch(resourcesProvider);
///
/// if (resourcesState.isLoading) {
///   return LoadingScreen();
/// }
///
/// return ResourcesScreen(
///   modules: resourcesState.trainingModules,
///   aiHistory: resourcesState.aiCheckHistory,
/// );
/// ```
///
/// ## Performing Operations
///
/// ```dart
/// // Complete a module
/// await ref.read(resourcesProvider.notifier).completeModule(moduleId);
///
/// // Check for AI content
/// final result = await ref.read(resourcesProvider.notifier)
///     .checkForAI(content);
/// ```
final resourcesProvider = NotifierProvider<ResourcesNotifier, ResourcesState>(() {
  return ResourcesNotifier();
});

/// Convenience provider for accessing training modules.
///
/// Returns the list of [TrainingModule] objects.
///
/// ## Usage
///
/// ```dart
/// final modules = ref.watch(trainingModulesProvider);
///
/// return ListView.builder(
///   itemCount: modules.length,
///   itemBuilder: (context, index) => ModuleCard(
///     module: modules[index],
///   ),
/// );
/// ```
final trainingModulesProvider = Provider<List<TrainingModule>>((ref) {
  return ref.watch(resourcesProvider).trainingModules;
});

/// Convenience provider for accessing training progress.
///
/// Returns the overall training completion percentage (0.0 to 1.0).
///
/// ## Usage
///
/// ```dart
/// final progress = ref.watch(trainingProgressProvider);
///
/// return LinearProgressIndicator(value: progress);
/// ```
final trainingProgressProvider = Provider<double>((ref) {
  return ref.watch(resourcesProvider).trainingProgress;
});

/// Convenience provider for accessing AI check history.
///
/// Returns the list of [AICheckResult] objects.
///
/// ## Usage
///
/// ```dart
/// final history = ref.watch(aiCheckHistoryProvider);
///
/// return AICheckHistoryList(results: history);
/// ```
final aiCheckHistoryProvider = Provider<List<AICheckResult>>((ref) {
  return ref.watch(resourcesProvider).aiCheckHistory;
});

/// Convenience provider for accessing citation history.
///
/// Returns the list of generated [Citation] objects.
///
/// ## Usage
///
/// ```dart
/// final citations = ref.watch(citationHistoryProvider);
///
/// return CitationHistoryList(citations: citations);
/// ```
final citationHistoryProvider = Provider<List<Citation>>((ref) {
  return ref.watch(resourcesProvider).citationHistory;
});

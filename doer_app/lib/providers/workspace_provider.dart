/// Workspace state management provider for the Doer App.
///
/// This file manages the project workspace where doers work on their
/// assigned projects. Integrated with Supabase for real-time chat,
/// deliverable management, and progress tracking.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../data/models/chat_model.dart';
import '../data/models/deliverable_model.dart';
import '../data/models/doer_project_model.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/deliverable_repository.dart';
import '../data/repositories/project_repository.dart';

/// Immutable state class representing workspace data for a single project.
class WorkspaceState {
  /// The project being worked on.
  final DoerProjectModel? project;

  /// List of deliverables uploaded to the workspace.
  final List<DeliverableModel> deliverables;

  /// Chat message history with supervisor.
  final List<ChatMessageModel> messages;

  /// The chat room for this project.
  final ChatRoomModel? chatRoom;

  /// Revision requests that need attention.
  final List<RevisionRequest> revisionRequests;

  /// Currently active work session, if any.
  final WorkSession? activeSession;

  /// Total time spent on the project.
  final Duration totalTimeSpent;

  /// Completion progress percentage (0-100).
  final int progress;

  /// Whether workspace data is being loaded.
  final bool isLoading;

  /// Whether work is being submitted.
  final bool isSubmitting;

  /// Error message if operation failed.
  final String? errorMessage;

  const WorkspaceState({
    this.project,
    this.deliverables = const [],
    this.messages = const [],
    this.chatRoom,
    this.revisionRequests = const [],
    this.activeSession,
    this.totalTimeSpent = Duration.zero,
    this.progress = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Whether work can be submitted.
  bool get canSubmit =>
      deliverables.isNotEmpty &&
      progress >= 50 &&
      !isSubmitting &&
      !hasUnresolvedRevisions;

  /// Whether there's an active work session.
  bool get isWorking => activeSession != null;

  /// Whether there are unresolved revision requests.
  bool get hasUnresolvedRevisions =>
      revisionRequests.any((r) => !r.isResolved);

  /// Latest deliverable, if any.
  DeliverableModel? get latestDeliverable =>
      deliverables.isNotEmpty ? deliverables.first : null;

  WorkspaceState copyWith({
    DoerProjectModel? project,
    List<DeliverableModel>? deliverables,
    List<ChatMessageModel>? messages,
    ChatRoomModel? chatRoom,
    List<RevisionRequest>? revisionRequests,
    WorkSession? activeSession,
    bool clearActiveSession = false,
    Duration? totalTimeSpent,
    int? progress,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return WorkspaceState(
      project: project ?? this.project,
      deliverables: deliverables ?? this.deliverables,
      messages: messages ?? this.messages,
      chatRoom: chatRoom ?? this.chatRoom,
      revisionRequests: revisionRequests ?? this.revisionRequests,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      totalTimeSpent: totalTimeSpent ?? this.totalTimeSpent,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

/// Work session model for time tracking.
class WorkSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;

  const WorkSession({
    required this.id,
    required this.startTime,
    this.endTime,
  });

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  bool get isActive => endTime == null;
}

/// Notifier class that manages workspace state and operations.
class WorkspaceNotifier {
  final Ref _ref;
  final String _projectId;

  late DoerProjectRepository _projectRepository;
  late DoerChatRepository _chatRepository;
  late DeliverableRepository _deliverableRepository;

  Timer? _sessionTimer;
  StreamSubscription<ChatMessageModel>? _chatSubscription;

  WorkspaceState _state = const WorkspaceState(isLoading: true);
  void Function(WorkspaceState)? _onStateChanged;

  WorkspaceNotifier(this._ref, this._projectId) {
    _projectRepository = _ref.read(doerProjectRepositoryProvider);
    _chatRepository = _ref.read(doerChatRepositoryProvider);
    _deliverableRepository = _ref.read(deliverableRepositoryProvider);
    _loadWorkspace();
  }

  WorkspaceState get state => _state;

  void setOnStateChanged(void Function(WorkspaceState) callback) {
    _onStateChanged = callback;
  }

  void _updateState(WorkspaceState newState) {
    _state = newState;
    _onStateChanged?.call(newState);
  }

  void dispose() {
    _sessionTimer?.cancel();
    _chatSubscription?.cancel();
  }

  SupabaseClient get _client => SupabaseConfig.client;

  /// Loads all workspace data.
  Future<void> _loadWorkspace() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));

    try {
      await Future.wait([
        _loadProject(),
        _loadDeliverables(),
        _loadChatRoom(),
        _loadRevisionRequests(),
        _loadTimeSpent(),
      ]);

      _updateState(_state.copyWith(isLoading: false));

      // Subscribe to real-time chat updates
      _subscribeToChatUpdates();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier._loadWorkspace error: $e');
      }
      _updateState(_state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load workspace',
      ));
    }
  }

  /// Loads project details.
  Future<void> _loadProject() async {
    try {
      final project = await _projectRepository.getProject(_projectId);
      if (project != null) {
        _updateState(_state.copyWith(
          project: project,
          progress: project.progressPercentage,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier._loadProject error: $e');
      }
    }
  }

  /// Loads deliverables for the project.
  Future<void> _loadDeliverables() async {
    try {
      final deliverables = await _deliverableRepository.getDeliverables(_projectId);
      _updateState(_state.copyWith(deliverables: deliverables));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier._loadDeliverables error: $e');
      }
    }
  }

  /// Loads or creates chat room for supervisor communication.
  Future<void> _loadChatRoom() async {
    try {
      final chatRoom = await _chatRepository.getProjectChatRoom(_projectId);
      if (chatRoom != null) {
        _updateState(_state.copyWith(chatRoom: chatRoom));

        // Load messages
        final messages = await _chatRepository.getMessages(chatRoom.id);
        _updateState(_state.copyWith(messages: messages));
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier._loadChatRoom error: $e');
      }
    }
  }

  /// Loads revision requests.
  Future<void> _loadRevisionRequests() async {
    try {
      final requests = await _deliverableRepository.getRevisionRequests(_projectId);
      _updateState(_state.copyWith(revisionRequests: requests));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier._loadRevisionRequests error: $e');
      }
    }
  }

  /// Loads total time spent from work sessions.
  Future<void> _loadTimeSpent() async {
    try {
      final response = await _client
          .from('work_sessions')
          .select()
          .eq('project_id', _projectId);

      var total = Duration.zero;
      for (final session in response as List) {
        final start = DateTime.parse(session['start_time'] as String);
        final end = session['end_time'] != null
            ? DateTime.parse(session['end_time'] as String)
            : DateTime.now();
        total += end.difference(start);
      }
      _updateState(_state.copyWith(totalTimeSpent: total));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier._loadTimeSpent error: $e');
      }
    }
  }

  /// Subscribes to real-time chat updates.
  void _subscribeToChatUpdates() {
    if (_state.chatRoom == null) return;

    _chatSubscription = _chatRepository
        .subscribeToMessages(_state.chatRoom!.id)
        .listen((message) {
      // Add new message to state if not already present
      if (!_state.messages.any((m) => m.id == message.id)) {
        _updateState(_state.copyWith(
          messages: [..._state.messages, message],
        ));
      }
    });
  }

  /// Starts a work session.
  Future<void> startSession() async {
    if (_state.activeSession != null) return;

    final session = WorkSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
    );

    _updateState(_state.copyWith(activeSession: session));

    // Start timer to update elapsed time
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.activeSession != null) {
        _updateState(_state.copyWith(
          totalTimeSpent: _state.totalTimeSpent + const Duration(seconds: 1),
        ));
      }
    });

    // Save session start to database
    try {
      await _client.from('work_sessions').insert({
        'id': session.id,
        'project_id': _projectId,
        'doer_id': _client.auth.currentUser?.id,
        'start_time': session.startTime.toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.startSession error: $e');
      }
    }
  }

  /// Ends the current work session.
  Future<void> endSession() async {
    _sessionTimer?.cancel();
    _sessionTimer = null;

    if (_state.activeSession == null) return;

    final endTime = DateTime.now();

    // Save session end to database
    try {
      await _client.from('work_sessions').update({
        'end_time': endTime.toIso8601String(),
      }).eq('id', _state.activeSession!.id);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.endSession error: $e');
      }
    }

    _updateState(_state.copyWith(clearActiveSession: true));
  }

  /// Updates work progress.
  Future<void> updateProgress(int percentage) async {
    final clamped = percentage.clamp(0, 100);

    try {
      await _projectRepository.updateProgress(_projectId, clamped);
      _updateState(_state.copyWith(progress: clamped));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.updateProgress error: $e');
        _updateState(_state.copyWith(progress: clamped));
      }
    }
  }

  /// Adds a file to the workspace by uploading and creating a deliverable.
  Future<bool> addFile({
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
    bool isFinal = false,
  }) async {
    try {
      // Upload file to storage
      final fileUrl = await _deliverableRepository.uploadFile(
        projectId: _projectId,
        filePath: filePath,
        fileName: fileName,
      );

      if (fileUrl == null) return false;

      // Create deliverable record
      final deliverable = await _deliverableRepository.createDeliverable(
        projectId: _projectId,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
        isFinal: isFinal,
      );

      if (deliverable != null) {
        _updateState(_state.copyWith(
          deliverables: [deliverable, ..._state.deliverables],
        ));
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.addFile error: $e');
      }
      return false;
    }
  }

  /// Removes a file from the workspace.
  Future<void> removeFile(String deliverableId) async {
    try {
      // Remove from database
      await _client
          .from('deliverables')
          .delete()
          .eq('id', deliverableId);

      // Update state
      _updateState(_state.copyWith(
        deliverables: _state.deliverables
            .where((d) => d.id != deliverableId)
            .toList(),
      ));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.removeFile error: $e');
      }
    }
  }

  /// Sets a file as the primary submission file.
  Future<void> setPrimaryFile(String deliverableId) async {
    try {
      // Update in database - set all to not final, then set target to final
      await _client
          .from('deliverables')
          .update({'is_final': false})
          .eq('project_id', _projectId);

      await _client
          .from('deliverables')
          .update({'is_final': true})
          .eq('id', deliverableId);

      // Update state
      final updatedDeliverables = _state.deliverables.map((d) {
        return d.copyWith(isFinal: d.id == deliverableId);
      }).toList();

      _updateState(_state.copyWith(deliverables: updatedDeliverables));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.setPrimaryFile error: $e');
      }
    }
  }

  /// Sends a chat message to the supervisor.
  Future<bool> sendMessage(String content) async {
    if (_state.chatRoom == null || content.trim().isEmpty) return false;

    try {
      final message = await _chatRepository.sendMessage(
        chatRoomId: _state.chatRoom!.id,
        content: content.trim(),
      );

      if (message != null) {
        _updateState(_state.copyWith(
          messages: [..._state.messages, message],
        ));
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.sendMessage error: $e');
      }
      return false;
    }
  }

  /// Sends a file attachment in chat.
  Future<bool> sendFileMessage({
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
  }) async {
    if (_state.chatRoom == null) return false;

    try {
      // Upload file first to get URL
      final fileUrl = await _deliverableRepository.uploadFile(
        projectId: _projectId,
        filePath: filePath,
        fileName: fileName,
      );

      if (fileUrl == null) return false;

      final message = await _chatRepository.sendFileMessage(
        chatRoomId: _state.chatRoom!.id,
        fileUrl: fileUrl,
        fileName: fileName,
        fileType: fileType,
        fileSize: fileSizeBytes,
      );

      if (message != null) {
        _updateState(_state.copyWith(
          messages: [..._state.messages, message],
        ));
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.sendFileMessage error: $e');
      }
      return false;
    }
  }

  /// Submits work for QC review.
  ///
  /// Submits the project with existing deliverables for review.
  /// Files should already be uploaded via addFile() before calling this.
  Future<bool> submitWork({String? notes}) async {
    if (!_state.canSubmit || _state.deliverables.isEmpty) return false;

    _updateState(_state.copyWith(isSubmitting: true));

    try {
      // Submit project for review
      final success = await _projectRepository.submitForReview(
        _projectId,
        notes: notes,
      );

      // End any active session
      await endSession();

      if (success) {
        _updateState(_state.copyWith(
          isSubmitting: false,
          project: _state.project?.copyWith(
            status: DoerProjectStatus.delivered,
            progressPercentage: 100,
          ),
        ));
        return true;
      }

      _updateState(_state.copyWith(isSubmitting: false));
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.submitWork error: $e');
      }
      _updateState(_state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit work',
      ));
      return false;
    }
  }

  /// Submits a revision addressing feedback.
  Future<bool> submitRevision({
    required String filePath,
    required String fileName,
    required String fileType,
    required int fileSizeBytes,
    String? revisionNotes,
  }) async {
    _updateState(_state.copyWith(isSubmitting: true));

    try {
      final deliverable = await _deliverableRepository.updateDeliverable(
        deliverableId: _state.latestDeliverable?.id ?? '',
        projectId: _projectId,
        filePath: filePath,
        fileName: fileName,
        fileType: fileType,
        fileSizeBytes: fileSizeBytes,
      );

      if (deliverable != null) {
        _updateState(_state.copyWith(
          isSubmitting: false,
          deliverables: [deliverable, ..._state.deliverables],
        ));
        return true;
      }

      _updateState(_state.copyWith(isSubmitting: false));
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WorkspaceNotifier.submitRevision error: $e');
      }
      _updateState(_state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit revision',
      ));
      return false;
    }
  }

  /// Refreshes workspace data.
  Future<void> refresh() async {
    await _loadWorkspace();
  }
}

// ══════════════════════════════════════════════════════════════════════════
// Providers
// ══════════════════════════════════════════════════════════════════════════

/// Internal provider for workspace notifiers.
final _workspaceNotifiersProvider = Provider.family.autoDispose<WorkspaceNotifier, String>((ref, projectId) {
  final notifier = WorkspaceNotifier(ref, projectId);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

/// Main workspace provider.
final workspaceProvider = Provider.family.autoDispose<WorkspaceNotifier, String>((ref, projectId) {
  return ref.watch(_workspaceNotifiersProvider(projectId));
});

/// Convenience provider for current project.
final currentProjectProvider = Provider.family<DoerProjectModel?, String>((ref, projectId) {
  return ref.watch(workspaceProvider(projectId)).state.project;
});

/// Convenience provider for workspace deliverables.
final workspaceDeliverablesProvider = Provider.family<List<DeliverableModel>, String>((ref, projectId) {
  return ref.watch(workspaceProvider(projectId)).state.deliverables;
});

/// Convenience provider for chat messages.
final chatMessagesProvider = Provider.family<List<ChatMessageModel>, String>((ref, projectId) {
  return ref.watch(workspaceProvider(projectId)).state.messages;
});

/// Convenience provider for work session status.
final isWorkingProvider = Provider.family<bool, String>((ref, projectId) {
  return ref.watch(workspaceProvider(projectId)).state.isWorking;
});

/// Convenience provider for submission eligibility.
final canSubmitProvider = Provider.family<bool, String>((ref, projectId) {
  return ref.watch(workspaceProvider(projectId)).state.canSubmit;
});

/// Convenience provider for revision requests.
final revisionRequestsProvider = Provider.family<List<RevisionRequest>, String>((ref, projectId) {
  return ref.watch(workspaceProvider(projectId)).state.revisionRequests;
});

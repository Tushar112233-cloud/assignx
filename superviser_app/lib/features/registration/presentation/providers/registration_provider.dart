import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../data/models/registration_model.dart';

/// Registration wizard state
class RegistrationState {
  const RegistrationState({
    this.currentStep = 0,
    this.data = const RegistrationData(),
    this.isLoading = false,
    this.error,
    this.isSubmitted = false,
    this.applicationStatus = ApplicationStatus.none,
  });

  /// Current step in the wizard (0-3)
  final int currentStep;

  /// Collected registration data
  final RegistrationData data;

  /// Whether an operation is in progress
  final bool isLoading;

  /// Error message from last operation
  final String? error;

  /// Whether application has been submitted
  final bool isSubmitted;

  /// Application review status
  final ApplicationStatus applicationStatus;

  RegistrationState copyWith({
    int? currentStep,
    RegistrationData? data,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSubmitted,
    ApplicationStatus? applicationStatus,
  }) {
    return RegistrationState(
      currentStep: currentStep ?? this.currentStep,
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isSubmitted: isSubmitted ?? this.isSubmitted,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }

  /// Total number of steps
  static const totalSteps = 4;

  /// Step titles
  static const stepTitles = [
    'Personal Info',
    'Experience',
    'Banking',
    'Review',
  ];

  /// Current step title
  String get currentStepTitle => stepTitles[currentStep];

  /// Progress percentage (0.0 - 1.0)
  double get progress => (currentStep + 1) / totalSteps;
}

/// Application review status
enum ApplicationStatus {
  none,
  pending,
  underReview,
  approved,
  rejected,
  needsRevision,
}

/// Registration notifier for state management
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  RegistrationNotifier(this._client) : super(const RegistrationState());

  final SupabaseClient _client;

  /// Updates registration data
  void updateData(RegistrationData Function(RegistrationData) update) {
    state = state.copyWith(
      data: update(state.data),
      clearError: true,
    );
  }

  /// Goes to next step
  void nextStep() {
    if (state.currentStep < RegistrationState.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  /// Goes to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Goes to specific step
  void goToStep(int step) {
    if (step >= 0 && step < RegistrationState.totalSteps) {
      state = state.copyWith(currentStep: step);
    }
  }

  /// Clears error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Submits the registration application
  Future<bool> submitApplication() async {
    if (!state.data.isComplete) {
      state = state.copyWith(
        error: 'Please complete all required fields before submitting.',
      );
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Submit to supervisors table
      await _client.from('supervisors').upsert({
        'user_id': userId,
        ...state.data.toJson(),
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        applicationStatus: ApplicationStatus.pending,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit application: $e',
      );
      return false;
    }
  }

  /// Checks application status from database
  Future<void> checkApplicationStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final userId = getCurrentUserId();
      if (userId == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final response = await _client
          .from('supervisors')
          .select('status')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          applicationStatus: ApplicationStatus.none,
        );
        return;
      }

      final status = response['status'] as String?;
      state = state.copyWith(
        isLoading: false,
        isSubmitted: status != null,
        applicationStatus: _parseStatus(status),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check status: $e',
      );
    }
  }

  ApplicationStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ApplicationStatus.pending;
      case 'under_review':
        return ApplicationStatus.underReview;
      case 'approved':
        return ApplicationStatus.approved;
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'needs_revision':
        return ApplicationStatus.needsRevision;
      default:
        return ApplicationStatus.none;
    }
  }

  /// Uploads CV file to storage
  ///
  /// Takes a file path and file name, uploads to Supabase storage,
  /// and returns the public URL of the uploaded file.
  Future<String?> uploadCV(String filePath, String fileName) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final userId = getCurrentUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Generate unique file name with timestamp to avoid conflicts
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last.toLowerCase();
      final storagePath = '$userId/${timestamp}_cv.$fileExtension';

      // Read file from local path
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      final fileBytes = await file.readAsBytes();

      // Validate file type
      final allowedTypes = ['pdf', 'doc', 'docx'];
      if (!allowedTypes.contains(fileExtension)) {
        throw Exception('Invalid file type. Allowed: PDF, DOC, DOCX');
      }

      // Validate file size (max 10MB)
      const maxSize = 10 * 1024 * 1024; // 10MB
      if (fileBytes.length > maxSize) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Upload to Supabase storage
      await _client.storage.from('supervisor-cvs').uploadBinary(
        storagePath,
        fileBytes,
        fileOptions: FileOptions(
          contentType: _getContentType(fileExtension),
          upsert: true,
        ),
      );

      // Get public URL
      final publicUrl = _client.storage
          .from('supervisor-cvs')
          .getPublicUrl(storagePath);

      state = state.copyWith(isLoading: false);
      return publicUrl;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload CV: $e',
      );
      return null;
    }
  }

  /// Gets the MIME content type for a file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}

/// Provider for registration state
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier(ref.watch(supabaseClientProvider));
});

/// Provider for current registration step
final currentStepProvider = Provider<int>((ref) {
  return ref.watch(registrationProvider).currentStep;
});

/// Provider for registration data
final registrationDataProvider = Provider<RegistrationData>((ref) {
  return ref.watch(registrationProvider).data;
});

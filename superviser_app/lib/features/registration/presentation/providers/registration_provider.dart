import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
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
  RegistrationNotifier() : super(const RegistrationState());

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

      await ApiClient.post('/supervisor/registration', {
        ...state.data.toJson(),
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

  /// Checks application status from API
  Future<void> checkApplicationStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final response = await ApiClient.get('/supervisor/registration/status');

      if (response == null) {
        state = state.copyWith(
          isLoading: false,
          applicationStatus: ApplicationStatus.none,
        );
        return;
      }

      final data = response as Map<String, dynamic>;
      final isActivated = data['is_activated'] as bool? ?? false;
      final isAccessGranted = data['is_access_granted'] as bool? ?? false;

      final appStatus = _deriveStatus(isActivated, isAccessGranted);

      state = state.copyWith(
        isLoading: false,
        isSubmitted: true,
        applicationStatus: appStatus,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check status: $e',
      );
    }
  }

  ApplicationStatus _deriveStatus(bool isActivated, bool isAccessGranted) {
    if (isActivated && isAccessGranted) return ApplicationStatus.approved;
    if (isActivated) return ApplicationStatus.underReview;
    return ApplicationStatus.pending;
  }

  /// Uploads CV file via the API.
  Future<String?> uploadCV(String filePath, String fileName) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File not found at path: $filePath');
      }

      // Validate file type
      final fileExtension = fileName.split('.').last.toLowerCase();
      final allowedTypes = ['pdf', 'doc', 'docx'];
      if (!allowedTypes.contains(fileExtension)) {
        throw Exception('Invalid file type. Allowed: PDF, DOC, DOCX');
      }

      // Validate file size (max 10MB)
      final fileBytes = await file.readAsBytes();
      const maxSize = 10 * 1024 * 1024;
      if (fileBytes.length > maxSize) {
        throw Exception('File size exceeds 10MB limit');
      }

      final response = await ApiClient.uploadFile(
        '/uploads/cv',
        file,
        fieldName: 'file',
        folder: 'supervisor-cvs',
      );

      final url = (response as Map<String, dynamic>?)?['url'] as String?;

      state = state.copyWith(isLoading: false);
      return url;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to upload CV: $e',
      );
      return null;
    }
  }
}

/// Provider for registration state
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier();
});

/// Provider for current registration step
final currentStepProvider = Provider<int>((ref) {
  return ref.watch(registrationProvider).currentStep;
});

/// Provider for registration data
final registrationDataProvider = Provider<RegistrationData>((ref) {
  return ref.watch(registrationProvider).data;
});

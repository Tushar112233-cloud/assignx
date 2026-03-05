import 'package:flutter/foundation.dart';

import '../../core/api/api_client.dart';
import '../../core/api/auth_api.dart';
import '../../core/storage/token_storage.dart';
import '../models/user_model.dart';

/// Repository for authentication operations.
///
/// Handles OTP authentication and profile management
/// via the Express API backend.
class AuthRepository {
  AuthRepository();

  /// Check if user is authenticated (has valid tokens).
  Future<bool> get isAuthenticated => TokenStorage.hasTokens();

  /// Check if account exists.
  Future<bool> checkAccount(String email) async {
    debugPrint('[AUTH] Checking account for: $email');
    return await AuthApi.checkAccount(email);
  }

  /// Send OTP to email.
  Future<void> sendOTP({
    required String email,
    required String purpose,
    String? role,
  }) async {
    debugPrint('[AUTH] Sending OTP to: $email (purpose: $purpose)');
    await AuthApi.sendOTP(email, purpose, role: role);
  }

  /// Verify OTP.
  Future<Map<String, dynamic>?> verifyOtp({
    required String email,
    required String token,
    required String purpose,
    String? role,
  }) async {
    debugPrint('[AUTH] Verifying OTP for: $email');
    try {
      final data = await AuthApi.verifyOTP(email, token, purpose, role: role);
      debugPrint('[AUTH] OTP verification successful');
      return data;
    } catch (e) {
      debugPrint('[AUTH] OTP verification failed: $e');
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await AuthApi.logout();
  }

  /// Get current user from API.
  Future<Map<String, dynamic>?> getCurrentUser() async {
    return await AuthApi.getCurrentUser();
  }

  /// Extract profile data from potentially wrapped response.
  Map<String, dynamic> _extractProfile(Map<String, dynamic> data) {
    // API may return flat profile (GET /me) or wrapped { profile: {...} } (PUT /me)
    if (data.containsKey('email')) return data;
    if (data['profile'] is Map<String, dynamic>) return data['profile'] as Map<String, dynamic>;
    return data;
  }

  /// Get user profile from the API.
  ///
  /// Returns null if profile doesn't exist.
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await ApiClient.get('/profiles/me');
      if (response == null) return null;
      final data = _extractProfile(response as Map<String, dynamic>);
      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[AUTH] Error fetching profile: $e');
      return null;
    }
  }

  /// Create or update user profile.
  Future<UserProfile> upsertProfile({
    required String userId,
    required String email,
    String? fullName,
    UserType? userType,
    String? avatarUrl,
    String? phone,
    String? city,
    String? state,
    OnboardingStep? onboardingStep,
    bool? onboardingCompleted,
  }) async {
    final data = <String, dynamic>{};

    if (fullName != null) data['fullName'] = fullName;
    if (userType != null) data['userType'] = userType.toDbString();
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (phone != null) data['phone'] = phone;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (onboardingStep != null) {
      data['onboardingStep'] = onboardingStep.toDbString();
    }
    if (onboardingCompleted != null) {
      data['onboardingCompleted'] = onboardingCompleted;
    }

    final response = await ApiClient.put('/profiles/me', data);
    final profileData = _extractProfile(response as Map<String, dynamic>);
    return UserProfile.fromJson(profileData);
  }

  /// Save student-specific data.
  Future<StudentData> saveStudentData({
    required String profileId,
    String? universityId,
    String? courseId,
    int? semester,
    int? yearOfStudy,
    String? studentIdNumber,
    int? expectedGraduationYear,
    String? collegeEmail,
    List<String>? preferredSubjects,
  }) async {
    final data = <String, dynamic>{};

    if (universityId != null) data['universityId'] = universityId;
    if (courseId != null) data['courseId'] = courseId;
    if (semester != null) data['semester'] = semester;
    if (yearOfStudy != null) data['yearOfStudy'] = yearOfStudy;
    if (studentIdNumber != null) data['studentIdNumber'] = studentIdNumber;
    if (expectedGraduationYear != null) {
      data['expectedGraduationYear'] = expectedGraduationYear;
    }
    if (collegeEmail != null) data['collegeEmail'] = collegeEmail;
    if (preferredSubjects != null) {
      data['preferredSubjects'] = preferredSubjects;
    }

    final response = await ApiClient.post('/profiles/student', data);
    final respData = response as Map<String, dynamic>;
    final studentData = respData['student'] as Map<String, dynamic>? ?? respData;
    return StudentData.fromJson(studentData);
  }

  /// Save professional-specific data.
  Future<ProfessionalData> saveProfessionalData({
    required String profileId,
    required ProfessionalType professionalType,
    String? industryId,
    String? jobTitle,
    String? companyName,
    String? linkedinUrl,
    String? businessType,
    String? gstNumber,
  }) async {
    final data = <String, dynamic>{
      'professionalType': professionalType.toDbString(),
    };

    if (industryId != null) data['industryId'] = industryId;
    if (jobTitle != null) data['jobTitle'] = jobTitle;
    if (companyName != null) data['companyName'] = companyName;
    if (linkedinUrl != null) data['linkedinUrl'] = linkedinUrl;
    if (businessType != null) data['businessType'] = businessType;
    if (gstNumber != null) data['gstNumber'] = gstNumber;

    final response = await ApiClient.post('/profiles/professional', data);
    final respData = response as Map<String, dynamic>;
    final profData = respData['professional'] as Map<String, dynamic>? ?? respData;
    return ProfessionalData.fromJson(profData);
  }

  /// Get student data for a profile.
  Future<StudentData?> getStudentData(String profileId) async {
    try {
      final response = await ApiClient.get('/profiles/student');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      final studentData = data['student'] as Map<String, dynamic>? ?? data;
      return StudentData.fromJson(studentData);
    } catch (_) {
      return null;
    }
  }

  /// Get professional data for a profile.
  Future<ProfessionalData?> getProfessionalData(String profileId) async {
    try {
      final response = await ApiClient.get('/profiles/professional');
      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      final profData = data['professional'] as Map<String, dynamic>? ?? data;
      return ProfessionalData.fromJson(profData);
    } catch (_) {
      return null;
    }
  }

  /// Get list of universities.
  Future<List<Map<String, dynamic>>> getUniversities() async {
    final response = await ApiClient.get('/universities');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Get courses for a university.
  Future<List<Map<String, dynamic>>> getCourses(String universityId) async {
    final response = await ApiClient.get('/universities/$universityId/courses');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Get list of industries.
  Future<List<Map<String, dynamic>>> getIndustries() async {
    final response = await ApiClient.get('/industries');
    return List<Map<String, dynamic>>.from(response as List);
  }

  /// Update last login timestamp.
  Future<void> updateLastLogin(String userId) async {
    try {
      await ApiClient.put('/profiles/me', {
        'lastLoginAt': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {
      // Non-critical, ignore errors
    }
  }
}

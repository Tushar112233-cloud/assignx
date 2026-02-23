import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../models/user_model.dart';

/// Repository for authentication operations.
///
/// Handles Google OAuth sign-in/sign-out and profile management
/// with Supabase backend.
class AuthRepository {
  final SupabaseClient _client;

  /// Google OAuth Web Client ID (required for Android native sign-in).
  /// This is the WEB client ID from Google Cloud Console, NOT the Android client ID.
  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  AuthRepository({
    SupabaseClient? client,
  }) : _client = client ?? SupabaseConfig.client;

  /// Stream of auth state changes.
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Get current user.
  User? get currentUser => _client.auth.currentUser;

  /// Get current session.
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated.
  bool get isAuthenticated => currentUser != null;

  /// Sign in with Google using native SDK.
  ///
  /// Returns true if sign-in was successful, false if cancelled.
  /// Throws an exception on error.
  Future<bool> signInWithGoogle() async {
    debugPrint('🔐 [AUTH] Starting Google Sign In...');
    debugPrint('🔐 [AUTH] Web Client ID configured: ${_googleWebClientId.isNotEmpty}');

    if (_googleWebClientId.isEmpty) {
      debugPrint('❌ [AUTH] Google Web Client ID not configured');
      throw AuthException(
        'Google Web Client ID not configured. '
        'Build with: --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id',
      );
    }

    final googleSignIn = GoogleSignIn(
      serverClientId: _googleWebClientId,
    );

    debugPrint('🔐 [AUTH] Opening Google Sign In dialog...');
    // Trigger Google sign-in flow
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      debugPrint('⚠️ [AUTH] User cancelled Google Sign In');
      // User cancelled the sign-in
      return false;
    }

    debugPrint('✅ [AUTH] Google user selected: ${googleUser.email}');
    debugPrint('🔐 [AUTH] Getting authentication tokens...');

    // Get authentication details
    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    debugPrint('🔐 [AUTH] ID Token present: ${idToken != null}');
    debugPrint('🔐 [AUTH] Access Token present: ${accessToken != null}');

    if (idToken == null) {
      debugPrint('❌ [AUTH] Failed to get ID token from Google');
      throw AuthException('Failed to get ID token from Google');
    }

    debugPrint('🔐 [AUTH] Signing in to Supabase with Google credentials...');
    // Sign in to Supabase with Google credentials
    final response = await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final success = response.session != null;
    debugPrint('✅ [AUTH] Supabase sign in ${success ? 'successful' : 'failed'}');
    if (success) {
      debugPrint('👤 [AUTH] User ID: ${response.user?.id}');
      debugPrint('📧 [AUTH] Email: ${response.user?.email}');
    }

    return success;
  }

  /// Deep link scheme for auth callback.
  /// Pattern: assignx://auth-callback
  static const String _authCallbackScheme = 'assignx://auth-callback';

  /// Sign in with magic link (passwordless email authentication).
  ///
  /// Sends a magic link to the provided email address.
  /// The magic link will redirect to the app via deep link.
  /// Returns true if the link was sent successfully.
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
    UserType? userType,
  }) async {
    debugPrint('🔐 [AUTH] Sending magic link to: $email');
    debugPrint('🔐 [AUTH] User type: ${userType?.toDbString() ?? 'not set'}');
    debugPrint('🔐 [AUTH] Redirect URL: ${redirectTo ?? _authCallbackScheme}');

    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo ?? _authCallbackScheme,
        data: userType != null ? {'user_type': userType.toDbString()} : null,
      );
      debugPrint('✅ [AUTH] Magic link sent successfully');
      return true;
    } catch (e) {
      debugPrint('❌ [AUTH] Failed to send magic link: $e');
      rethrow;
    }
  }

  /// Verify OTP token from magic link.
  ///
  /// This is called when the user clicks the magic link.
  Future<bool> verifyOtp({
    required String email,
    required String token,
    OtpType type = OtpType.magiclink,
  }) async {
    debugPrint('🔐 [AUTH] Verifying OTP for: $email');

    try {
      final response = await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
      final success = response.session != null;
      debugPrint('✅ [AUTH] OTP verification ${success ? 'successful' : 'failed'}');
      return success;
    } catch (e) {
      debugPrint('❌ [AUTH] OTP verification failed: $e');
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    // Sign out from Google
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Sign out from Supabase
    await _client.auth.signOut();
  }

  /// Get user profile from database.
  ///
  /// Returns null if profile doesn't exist.
  Future<UserProfile?> getUserProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(response);
  }

  /// Create or update user profile in the profiles table.
  ///
  /// Uses user_type instead of role, matching the database schema.
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
    final now = DateTime.now().toUtc().toIso8601String();
    final data = <String, dynamic>{
      'id': userId,
      'email': email,
      'updated_at': now,
    };

    // Add optional fields only if provided
    if (fullName != null) data['full_name'] = fullName;
    if (userType != null) data['user_type'] = userType.toDbString();
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    if (phone != null) data['phone'] = phone;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (onboardingStep != null) {
      data['onboarding_step'] = onboardingStep.toDbString();
    }
    if (onboardingCompleted != null) {
      data['onboarding_completed'] = onboardingCompleted;
      if (onboardingCompleted) {
        data['onboarding_completed_at'] = now;
      }
    }

    final response = await _client
        .from('profiles')
        .upsert(data)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  /// Save student-specific data to the students table.
  ///
  /// Uses profile_id reference pattern matching the database schema.
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
    final now = DateTime.now().toUtc().toIso8601String();
    final data = <String, dynamic>{
      'profile_id': profileId,
      'updated_at': now,
    };

    // Add optional fields only if provided
    if (universityId != null) data['university_id'] = universityId;
    if (courseId != null) data['course_id'] = courseId;
    if (semester != null) data['semester'] = semester;
    if (yearOfStudy != null) data['year_of_study'] = yearOfStudy;
    if (studentIdNumber != null) data['student_id_number'] = studentIdNumber;
    if (expectedGraduationYear != null) {
      data['expected_graduation_year'] = expectedGraduationYear;
    }
    if (collegeEmail != null) data['college_email'] = collegeEmail;
    if (preferredSubjects != null) {
      data['preferred_subjects'] = preferredSubjects;
    }

    final response = await _client
        .from('students')
        .upsert(data, onConflict: 'profile_id')
        .select()
        .single();

    return StudentData.fromJson(response);
  }

  /// Save professional-specific data to the professionals table.
  ///
  /// Uses profile_id reference pattern matching the database schema.
  /// Requires professional_type as it's a required field in the database.
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
    final now = DateTime.now().toUtc().toIso8601String();
    final data = <String, dynamic>{
      'profile_id': profileId,
      'professional_type': professionalType.toDbString(),
      'updated_at': now,
    };

    // Add optional fields only if provided
    if (industryId != null) data['industry_id'] = industryId;
    if (jobTitle != null) data['job_title'] = jobTitle;
    if (companyName != null) data['company_name'] = companyName;
    if (linkedinUrl != null) data['linkedin_url'] = linkedinUrl;
    if (businessType != null) data['business_type'] = businessType;
    if (gstNumber != null) data['gst_number'] = gstNumber;

    final response = await _client
        .from('professionals')
        .upsert(data, onConflict: 'profile_id')
        .select()
        .single();

    return ProfessionalData.fromJson(response);
  }

  /// Get student data for a profile.
  Future<StudentData?> getStudentData(String profileId) async {
    final response = await _client
        .from('students')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (response == null) return null;
    return StudentData.fromJson(response);
  }

  /// Get professional data for a profile.
  Future<ProfessionalData?> getProfessionalData(String profileId) async {
    final response = await _client
        .from('professionals')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();

    if (response == null) return null;
    return ProfessionalData.fromJson(response);
  }

  /// Get list of universities.
  Future<List<Map<String, dynamic>>> getUniversities() async {
    final response = await _client
        .from('universities')
        .select('id, name')
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get courses for a university.
  Future<List<Map<String, dynamic>>> getCourses(String universityId) async {
    final response = await _client
        .from('courses')
        .select('id, name')
        .eq('university_id', universityId)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Get list of industries.
  Future<List<Map<String, dynamic>>> getIndustries() async {
    final response = await _client
        .from('industries')
        .select('id, name')
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  /// Update last login timestamp.
  Future<void> updateLastLogin(String userId) async {
    await _client.from('profiles').update({
      'last_login_at': DateTime.now().toUtc().toIso8601String(),
      'login_count': _client.rpc('increment_login_count', params: {
        'user_id': userId,
      }),
    }).eq('id', userId);
  }
}

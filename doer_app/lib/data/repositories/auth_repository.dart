import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/logger_service.dart';
import '../models/doer_model.dart';
import '../models/profile_model.dart';
import '../models/user_model.dart';

// Re-export models for convenience
export '../models/user_model.dart' show ProfileSetupData, BankDetailsFormData;

/// Abstract interface for authentication repository operations.
///
/// Defines the contract for authentication-related data operations including
/// user registration, login, session management, and profile operations.
/// This interface allows for different implementations (e.g., Supabase, Firebase)
/// and facilitates testing through dependency injection.
///
/// ## Architecture
///
/// ```
/// AuthProvider --> AuthRepository (interface)
///                       |
///                       v
///               SupabaseAuthRepository (implementation)
///                       |
///                       v
///                 SupabaseClient
/// ```
///
/// ## Implementation
///
/// The default implementation is [SupabaseAuthRepository] which uses
/// Supabase for authentication and database operations.
///
/// ## Error Handling
///
/// Methods may throw:
/// - [AuthException] for authentication failures
/// - [PostgrestException] for database operation failures
/// - [Exception] for other errors (e.g., Google Sign-In)
///
/// ## Usage
///
/// ```dart
/// // Using the interface for dependency injection
/// class AuthProvider {
///   final AuthRepository _repo;
///
///   AuthProvider({AuthRepository? repo})
///       : _repo = repo ?? SupabaseAuthRepository();
///
///   Future<void> login(String email, String password) async {
///     final response = await _repo.signInWithPassword(
///       email: email,
///       password: password,
///     );
///     // Handle response...
///   }
/// }
/// ```
///
/// See also:
/// - [SupabaseAuthRepository] for the Supabase implementation
/// - [AuthProvider] for state management
/// - [UserModel] for user data structure
abstract class AuthRepository {
  /// Gets the current authenticated user session.
  ///
  /// Returns the active [Session] if a user is logged in, or `null` if
  /// no session exists. The session contains the access token and refresh
  /// token for API requests.
  ///
  /// Example:
  /// ```dart
  /// final session = authRepo.currentSession;
  /// if (session != null) {
  ///   print('Token expires at: ${session.expiresAt}');
  /// }
  /// ```
  Session? get currentSession;

  /// Gets the current authenticated user.
  ///
  /// Returns the Supabase [User] object if authenticated, or `null` if
  /// no user is logged in. This provides basic user info like ID and email.
  ///
  /// Example:
  /// ```dart
  /// final user = authRepo.currentUser;
  /// if (user != null) {
  ///   print('Logged in as: ${user.email}');
  /// }
  /// ```
  User? get currentUser;

  /// Signs up a new user with email and password.
  ///
  /// Creates a new user account in Supabase Auth and stores additional
  /// metadata (full name, phone) in the user's app_metadata.
  ///
  /// Parameters:
  /// - [email]: Valid email address for the account
  /// - [password]: Password meeting security requirements
  /// - [fullName]: User's full display name
  /// - [phone]: Phone number (with or without country code)
  ///
  /// Returns an [AuthResponse] containing the session and user on success.
  ///
  /// Throws [AuthException] if:
  /// - Email is already registered
  /// - Email format is invalid
  /// - Password doesn't meet requirements
  ///
  /// Example:
  /// ```dart
  /// final response = await authRepo.signUp(
  ///   email: 'user@example.com',
  ///   password: 'SecurePass123!',
  ///   fullName: 'John Doe',
  ///   phone: '9876543210',
  /// );
  /// print('User ID: ${response.user?.id}');
  /// ```
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  });

  /// Signs in an existing user with email and password.
  ///
  /// Authenticates the user against Supabase Auth and establishes a session.
  ///
  /// Parameters:
  /// - [email]: Registered email address
  /// - [password]: Account password
  ///
  /// Returns an [AuthResponse] containing the session and user on success.
  ///
  /// Throws [AuthException] if:
  /// - Email is not registered
  /// - Password is incorrect
  /// - Account is disabled
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   final response = await authRepo.signInWithPassword(
  ///     email: 'user@example.com',
  ///     password: 'SecurePass123!',
  ///   );
  ///   print('Welcome back, ${response.user?.email}');
  /// } on AuthException catch (e) {
  ///   print('Login failed: ${e.message}');
  /// }
  /// ```
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user.
  ///
  /// Ends the user's session and clears local authentication state.
  /// After calling this method, [currentSession] and [currentUser]
  /// will return `null`.
  ///
  /// Example:
  /// ```dart
  /// await authRepo.signOut();
  /// // User is now logged out
  /// ```
  Future<void> signOut();

  /// Sends an OTP to the given phone number.
  ///
  /// Initiates phone-based authentication by sending a one-time password
  /// via SMS to the specified phone number.
  ///
  /// Parameters:
  /// - [phone]: Phone number (country code will be added if missing)
  ///
  /// Throws [AuthException] if:
  /// - Phone number format is invalid
  /// - SMS sending fails
  /// - Rate limit exceeded
  ///
  /// Example:
  /// ```dart
  /// await authRepo.sendOtp('9876543210');
  /// // OTP sent to +919876543210
  /// ```
  Future<void> sendOtp(String phone);

  /// Verifies the OTP for the given phone number.
  ///
  /// Completes phone-based authentication by verifying the OTP code
  /// entered by the user against the code sent via SMS.
  ///
  /// Parameters:
  /// - [phone]: Phone number that received the OTP
  /// - [otp]: The 6-digit OTP code entered by user
  ///
  /// Returns an [AuthResponse] containing the session on success.
  ///
  /// Throws [AuthException] if:
  /// - OTP is incorrect
  /// - OTP has expired
  /// - Too many failed attempts
  ///
  /// Example:
  /// ```dart
  /// final response = await authRepo.verifyOtp('9876543210', '123456');
  /// if (response.session != null) {
  ///   print('Phone verified successfully');
  /// }
  /// ```
  Future<AuthResponse> verifyOtp(String phone, String otp);

  /// Fetches user profile from database.
  ///
  /// Retrieves the complete user profile including nested doer data,
  /// skills, and subjects from the database.
  ///
  /// Parameters:
  /// - [userId]: The user's unique identifier (UUID)
  ///
  /// Returns a [UserModel] with complete profile data, or `null` if
  /// the profile doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final profile = await authRepo.fetchUserProfile(user.id);
  /// if (profile != null) {
  ///   print('Welcome, ${profile.fullName}');
  ///   print('Doer status: ${profile.doer?.activationStatus}');
  /// }
  /// ```
  Future<UserModel?> fetchUserProfile(String userId);

  /// Creates initial profile in database.
  ///
  /// Creates a new profile record in the `profiles` table. This is
  /// typically called after successful signup.
  ///
  /// Parameters:
  /// - [userId]: The user's auth ID (UUID)
  /// - [email]: User's email address
  /// - [fullName]: User's display name
  /// - [phone]: Phone number with country code
  ///
  /// Throws [PostgrestException] if:
  /// - Profile with userId already exists
  /// - Required fields are invalid
  ///
  /// Example:
  /// ```dart
  /// await authRepo.createProfile(
  ///   userId: response.user!.id,
  ///   email: 'user@example.com',
  ///   fullName: 'John Doe',
  ///   phone: '+919876543210',
  /// );
  /// ```
  Future<void> createProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
  });

  /// Creates doer record for the user.
  ///
  /// Creates a new doer profile with professional information and
  /// initializes the activation record. Also adds skills and subjects
  /// if provided in the data.
  ///
  /// Parameters:
  /// - [profileId]: The profile's unique identifier
  /// - [data]: Profile setup data containing professional info
  ///
  /// Returns the newly created doer's ID (UUID).
  ///
  /// Throws [PostgrestException] if:
  /// - Profile ID doesn't exist
  /// - Doer already exists for this profile
  ///
  /// Example:
  /// ```dart
  /// final doerId = await authRepo.createDoerProfile(
  ///   profileId: profile.id,
  ///   data: ProfileSetupData(
  ///     educationLevel: 'masters',
  ///     workStyle: 'part_time',
  ///     skillIds: ['skill-1', 'skill-2'],
  ///     subjectIds: ['subject-1'],
  ///   ),
  /// );
  /// ```
  Future<String> createDoerProfile({
    required String profileId,
    required ProfileSetupData data,
  });

  /// Updates doer profile.
  ///
  /// Updates the doer's professional information. If skills or subjects
  /// are provided, existing ones are replaced with the new set.
  ///
  /// Parameters:
  /// - [doerId]: The doer's unique identifier
  /// - [data]: Updated profile data
  ///
  /// Example:
  /// ```dart
  /// await authRepo.updateDoerProfile(
  ///   doerId,
  ///   ProfileSetupData(
  ///     educationLevel: 'phd',
  ///     skillIds: ['skill-1', 'skill-2', 'skill-3'],
  ///   ),
  /// );
  /// ```
  Future<void> updateDoerProfile(String doerId, ProfileSetupData data);

  /// Adds skills to doer.
  ///
  /// Creates doer_skills records linking the doer to the specified skills.
  ///
  /// Parameters:
  /// - [doerId]: The doer's unique identifier
  /// - [skillIds]: List of skill IDs to add
  ///
  /// Example:
  /// ```dart
  /// await authRepo.addDoerSkills(doerId, ['skill-1', 'skill-2']);
  /// ```
  Future<void> addDoerSkills(String doerId, List<String> skillIds);

  /// Adds subjects to doer.
  ///
  /// Creates doer_subjects records linking the doer to the specified
  /// subjects, marking one as primary if specified.
  ///
  /// Parameters:
  /// - [doerId]: The doer's unique identifier
  /// - [subjectIds]: List of subject IDs to add
  /// - [primarySubjectId]: Optional ID of the primary subject
  ///
  /// Example:
  /// ```dart
  /// await authRepo.addDoerSubjects(
  ///   doerId,
  ///   ['math', 'physics', 'chemistry'],
  ///   'math', // Primary subject
  /// );
  /// ```
  Future<void> addDoerSubjects(String doerId, List<String> subjectIds, String? primarySubjectId);

  /// Updates bank details.
  ///
  /// Saves the doer's bank account information and marks the bank
  /// details step as complete in the activation record.
  ///
  /// Parameters:
  /// - [doerId]: The doer's unique identifier
  /// - [data]: Bank account details
  ///
  /// Example:
  /// ```dart
  /// await authRepo.updateBankDetails(
  ///   doerId,
  ///   BankDetailsFormData(
  ///     accountHolderName: 'John Doe',
  ///     accountNumber: '1234567890',
  ///     ifscCode: 'HDFC0001234',
  ///     bankName: 'HDFC Bank',
  ///   ),
  /// );
  /// ```
  Future<void> updateBankDetails(String doerId, BankDetailsFormData data);

  /// Signs in with Google OAuth.
  ///
  /// Initiates native Google Sign-In flow and exchanges the ID token
  /// with Supabase for a session.
  ///
  /// Returns `true` if sign-in was successful, `false` if cancelled.
  ///
  /// Throws [Exception] if:
  /// - Google Web Client ID is not configured
  /// - Google authentication fails
  /// - Supabase token exchange fails
  ///
  /// Example:
  /// ```dart
  /// final success = await authRepo.signInWithGoogle();
  /// if (success) {
  ///   print('Signed in with Google');
  /// } else {
  ///   print('User cancelled sign-in');
  /// }
  /// ```
  Future<bool> signInWithGoogle();

  /// Gets available skills.
  ///
  /// Fetches all active skills from the database that doers can
  /// select during profile setup.
  ///
  /// Returns a list of [SkillModel] objects sorted by name.
  ///
  /// Example:
  /// ```dart
  /// final skills = await authRepo.getAvailableSkills();
  /// for (final skill in skills) {
  ///   print('${skill.name}: ${skill.description}');
  /// }
  /// ```
  Future<List<SkillModel>> getAvailableSkills();

  /// Gets available subjects.
  ///
  /// Fetches all active subjects from the database that doers can
  /// select during profile setup.
  ///
  /// Returns a list of [SubjectModel] objects sorted by display order.
  ///
  /// Example:
  /// ```dart
  /// final subjects = await authRepo.getAvailableSubjects();
  /// for (final subject in subjects) {
  ///   print('${subject.name} (${subject.category})');
  /// }
  /// ```
  Future<List<SubjectModel>> getAvailableSubjects();

  /// Signs in with magic link (passwordless email authentication).
  ///
  /// Sends a magic link to the provided email address. The user clicks
  /// the link to complete authentication without a password.
  ///
  /// Parameters:
  /// - [email]: Email address to send the magic link to
  /// - [redirectTo]: Optional URL to redirect to after authentication
  ///
  /// Returns `true` if the magic link was sent successfully.
  ///
  /// Throws [AuthException] if:
  /// - Email format is invalid
  /// - Rate limit exceeded
  /// - Email sending fails
  ///
  /// Example:
  /// ```dart
  /// final success = await authRepo.signInWithMagicLink(
  ///   email: 'user@example.com',
  /// );
  /// if (success) {
  ///   print('Check your email for the magic link');
  /// }
  /// ```
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
  });

  /// Sends a password reset email to the specified address.
  ///
  /// Triggers Supabase to send a password reset link via email.
  /// The user can click the link to set a new password.
  ///
  /// ## Parameters
  ///
  /// - [email]: Email address to send the reset link to
  ///
  /// ## Throws
  ///
  /// - [AuthException]: If the email sending fails or rate limit is hit
  ///
  /// ## Example
  ///
  /// ```dart
  /// await repository.resetPasswordForEmail('user@example.com');
  /// // User receives email with reset link
  /// ```
  Future<void> resetPasswordForEmail(String email);
}

/// Supabase implementation of [AuthRepository].
///
/// Provides concrete implementation of authentication operations using
/// Supabase Auth for authentication and Supabase Database for profile
/// management.
///
/// ## Features
///
/// - **Email/Password Auth**: Traditional registration and login
/// - **Phone Auth**: OTP-based phone verification
/// - **Google OAuth**: Native Google Sign-In integration
/// - **Profile Management**: Create and update user profiles
/// - **Doer Setup**: Complete doer onboarding workflow
///
/// ## Database Tables Used
///
/// - `profiles` - User profile information
/// - `doers` - Doer-specific professional data
/// - `doer_skills` - Many-to-many doer-skill relationships
/// - `doer_subjects` - Many-to-many doer-subject relationships
/// - `doer_activation` - Activation progress tracking
/// - `skills` - Available skills catalog
/// - `subjects` - Available subjects catalog
///
/// ## Usage
///
/// ```dart
/// // Create instance with default client
/// final authRepo = SupabaseAuthRepository();
///
/// // Create instance with custom client (for testing)
/// final authRepo = SupabaseAuthRepository(client: mockClient);
///
/// // Use in provider
/// final response = await authRepo.signInWithPassword(
///   email: email,
///   password: password,
/// );
/// ```
///
/// ## Logging
///
/// All operations are logged using [LoggerService] for debugging:
/// - Info logs for operation starts
/// - Warning logs for missing data
/// - Error logs for failures
///
/// See also:
/// - [AuthRepository] for the interface definition
/// - [SupabaseConfig] for client configuration
/// - [LoggerService] for logging details
class SupabaseAuthRepository implements AuthRepository {
  /// The Supabase client used for all operations.
  final SupabaseClient _client;

  /// Creates a SupabaseAuthRepository with an optional custom client.
  ///
  /// If [client] is not provided, uses the default client from
  /// [SupabaseConfig.client].
  ///
  /// Parameters:
  /// - [client]: Optional custom Supabase client (useful for testing)
  ///
  /// Example:
  /// ```dart
  /// // Default client
  /// final repo = SupabaseAuthRepository();
  ///
  /// // Custom client for testing
  /// final repo = SupabaseAuthRepository(client: mockSupabaseClient);
  /// ```
  SupabaseAuthRepository({SupabaseClient? client})
      : _client = client ?? SupabaseConfig.client;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    LoggerService.info('AuthRepository: Signing up user', data: {'email': email});

    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'phone': phone,
      },
    );
  }

  @override
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) async {
    LoggerService.info('AuthRepository: Signing in user', data: {'email': email});

    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    LoggerService.info('AuthRepository: Signing out user');
    await _client.auth.signOut();
  }

  /// Formats phone number with country code.
  ///
  /// Ensures the phone number has a country code prefix. If the number
  /// doesn't start with '+', adds the default country code from
  /// [ApiConstants.defaultCountryCode].
  ///
  /// Parameters:
  /// - [phone]: Phone number to format
  ///
  /// Returns the formatted phone number with country code.
  ///
  /// Example:
  /// ```dart
  /// _formatPhoneNumber('9876543210');  // Returns '+919876543210'
  /// _formatPhoneNumber('+919876543210'); // Returns '+919876543210'
  /// ```
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('+')) {
      return phone;
    }
    return '${ApiConstants.defaultCountryCode}$phone';
  }

  @override
  Future<void> sendOtp(String phone) async {
    LoggerService.info('AuthRepository: Sending OTP', data: {'phone': phone});
    await _client.auth.signInWithOtp(phone: _formatPhoneNumber(phone));
  }

  @override
  Future<AuthResponse> verifyOtp(String phone, String otp) async {
    LoggerService.info('AuthRepository: Verifying OTP');

    return await _client.auth.verifyOTP(
      phone: _formatPhoneNumber(phone),
      token: otp,
      type: OtpType.sms,
    );
  }

  @override
  Future<UserModel?> fetchUserProfile(String userId) async {
    LoggerService.info('AuthRepository: Fetching user profile', data: {'userId': userId});

    try {
      // First, fetch profile with nested doer data
      final response = await _client
          .from('profiles')
          .select('''
            *,
            doer:doers!doers_profile_id_fkey(
              *,
              doer_skills(
                *,
                skill:skills(*)
              ),
              doer_subjects(
                *,
                subject:subjects(*)
              )
            )
          ''')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        LoggerService.warning('AuthRepository: Profile not found', data: {'userId': userId});
        return null;
      }

      // Handle the nested doer array (Supabase returns array for one-to-many)
      final Map<String, dynamic> profileData = Map<String, dynamic>.from(response);

      // Extract doer data from array if present
      if (profileData['doer'] != null && profileData['doer'] is List) {
        final doerList = profileData['doer'] as List;
        if (doerList.isNotEmpty) {
          final doerData = doerList.first as Map<String, dynamic>;
          profileData['doer'] = doerData;

          // Copy nested skills/subjects to top level for UserModel parsing
          profileData['doer_skills'] = doerData['doer_skills'];
          profileData['doer_subjects'] = doerData['doer_subjects'];
        } else {
          profileData['doer'] = null;
        }
      }

      return UserModel.fromJson(profileData);
    } catch (e) {
      LoggerService.error('AuthRepository: Error fetching user profile', e);
      return null;
    }
  }

  @override
  Future<void> createProfile({
    required String userId,
    required String email,
    required String fullName,
    required String phone,
  }) async {
    LoggerService.info('AuthRepository: Creating profile', data: {'userId': userId});

    await _client.from('profiles').insert(
      ProfileModel.createInsertData(
        id: userId,
        email: email,
        fullName: fullName,
        phone: phone.startsWith('+') ? phone : '+91$phone',
        userType: 'doer',
      ),
    );
  }

  @override
  Future<String> createDoerProfile({
    required String profileId,
    required ProfileSetupData data,
  }) async {
    LoggerService.info('AuthRepository: Creating doer profile', data: {'profileId': profileId});

    final response = await _client
        .from('doers')
        .insert(data.toDoerInsertData(profileId))
        .select('id')
        .single();

    final doerId = response['id'] as String;

    // Add skills if provided
    if (data.skillIds.isNotEmpty) {
      await addDoerSkills(doerId, data.skillIds);
    }

    // Add subjects if provided
    if (data.subjectIds.isNotEmpty) {
      await addDoerSubjects(doerId, data.subjectIds, data.primarySubjectId);
    }

    // Create activation record
    await _client.from('doer_activation').insert({
      'doer_id': doerId,
    });

    return doerId;
  }

  @override
  Future<void> updateDoerProfile(String doerId, ProfileSetupData data) async {
    LoggerService.info('AuthRepository: Updating doer profile', data: {'doerId': doerId});

    await _client
        .from('doers')
        .update(data.toDoerUpdateData())
        .eq('id', doerId);

    // Update skills if provided
    if (data.skillIds.isNotEmpty) {
      // Remove existing skills
      await _client.from('doer_skills').delete().eq('doer_id', doerId);
      // Add new skills
      await addDoerSkills(doerId, data.skillIds);
    }

    // Update subjects if provided
    if (data.subjectIds.isNotEmpty) {
      // Remove existing subjects
      await _client.from('doer_subjects').delete().eq('doer_id', doerId);
      // Add new subjects
      await addDoerSubjects(doerId, data.subjectIds, data.primarySubjectId);
    }
  }

  @override
  Future<void> addDoerSkills(String doerId, List<String> skillIds) async {
    LoggerService.info('AuthRepository: Adding doer skills', data: {'doerId': doerId, 'count': skillIds.length});

    final skillRecords = skillIds
        .map((skillId) => DoerSkillModel.createInsertData(
              doerId: doerId,
              skillId: skillId,
            ))
        .toList();

    await _client.from('doer_skills').insert(skillRecords);
  }

  @override
  Future<void> addDoerSubjects(String doerId, List<String> subjectIds, String? primarySubjectId) async {
    LoggerService.info('AuthRepository: Adding doer subjects', data: {'doerId': doerId, 'count': subjectIds.length});

    final subjectRecords = subjectIds
        .map((subjectId) => DoerSubjectModel.createInsertData(
              doerId: doerId,
              subjectId: subjectId,
              isPrimary: subjectId == primarySubjectId,
            ))
        .toList();

    await _client.from('doer_subjects').insert(subjectRecords);
  }

  @override
  Future<void> updateBankDetails(String doerId, BankDetailsFormData data) async {
    LoggerService.info('AuthRepository: Updating bank details', data: {'doerId': doerId});

    await _client
        .from('doers')
        .update(data.toDoerUpdateData())
        .eq('id', doerId);

    // Update activation status
    await _client
        .from('doer_activation')
        .update({
          'bank_details_added': true,
          'bank_details_added_at': DateTime.now().toIso8601String(),
        })
        .eq('doer_id', doerId);
  }

  @override
  Future<List<SkillModel>> getAvailableSkills() async {
    LoggerService.info('AuthRepository: Fetching available skills');

    final response = await _client
        .from('skills')
        .select()
        .eq('is_active', true)
        .order('name');

    return (response as List)
        .map((json) => SkillModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<SubjectModel>> getAvailableSubjects() async {
    LoggerService.info('AuthRepository: Fetching available subjects');

    final response = await _client
        .from('subjects')
        .select()
        .eq('is_active', true)
        .order('display_order');

    return (response as List)
        .map((json) => SubjectModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> signInWithGoogle() async {
    LoggerService.info('🔐 [AUTH] Starting Google Sign In...');
    LoggerService.info('🔐 [AUTH] Web Client ID configured: ${ApiConstants.googleWebClientId.isNotEmpty}');

    try {
      const webClientId = ApiConstants.googleWebClientId;

      if (webClientId.isEmpty) {
        LoggerService.error('❌ [AUTH] Google Web Client ID not configured', Exception('Missing GOOGLE_WEB_CLIENT_ID'));
        throw Exception('Google Web Client ID not configured. Pass GOOGLE_WEB_CLIENT_ID as --dart-define');
      }

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );

      LoggerService.info('🔐 [AUTH] Opening Google Sign In dialog...');
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        LoggerService.info('⚠️ [AUTH] User cancelled Google Sign In');
        return false;
      }

      LoggerService.info('✅ [AUTH] Google user selected: ${googleUser.email}');
      LoggerService.info('🔐 [AUTH] Getting authentication tokens...');

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      LoggerService.info('🔐 [AUTH] ID Token present: ${idToken != null}');
      LoggerService.info('🔐 [AUTH] Access Token present: ${accessToken != null}');

      if (idToken == null) {
        LoggerService.error('❌ [AUTH] Failed to get ID token from Google', Exception('Missing idToken'));
        throw Exception('Missing idToken from Google authentication');
      }

      LoggerService.info('🔐 [AUTH] Signing in to Supabase with Google credentials...');
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final success = response.session != null;
      LoggerService.info('✅ [AUTH] Supabase sign in ${success ? 'successful' : 'failed'}');
      if (success) {
        LoggerService.info('👤 [AUTH] User ID: ${response.user?.id}');
        LoggerService.info('📧 [AUTH] Email: ${response.user?.email}');
      }

      return success;

    } catch (e, stackTrace) {
      LoggerService.error('AuthRepository: Google sign-in failed', e);
      LoggerService.error('AuthRepository: Stack trace', stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> signInWithMagicLink({
    required String email,
    String? redirectTo,
  }) async {
    LoggerService.info('🔐 [AUTH] Sending magic link...', data: {'email': email});

    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );

      LoggerService.info('✅ [AUTH] Magic link sent successfully to $email');
      return true;
    } catch (e, stackTrace) {
      LoggerService.error('AuthRepository: Magic link failed', e);
      LoggerService.error('AuthRepository: Stack trace', stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    LoggerService.info('🔐 [AUTH] Sending password reset email...', data: {'email': email});

    try {
      await _client.auth.resetPasswordForEmail(email);

      LoggerService.info('✅ [AUTH] Password reset email sent successfully to $email');
    } catch (e, stackTrace) {
      LoggerService.error('AuthRepository: Password reset failed', e);
      LoggerService.error('AuthRepository: Stack trace', stackTrace);
      rethrow;
    }
  }
}

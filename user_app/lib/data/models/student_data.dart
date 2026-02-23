/// Extended user data model for student users.
///
/// This model maps to the `students` table in Supabase and contains
/// academic information specific to student accounts. It is linked to
/// [UserProfile] via the [profileId] field.
///
/// ## Database Table: `students`
///
/// ```sql
/// CREATE TABLE students (
///   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   profile_id UUID NOT NULL REFERENCES profiles(id) UNIQUE,
///   university_id UUID REFERENCES universities(id),
///   university_name TEXT,
///   course_id UUID REFERENCES courses(id),
///   course_name TEXT,
///   semester INTEGER CHECK (semester >= 1 AND semester <= 12),
///   student_id_number TEXT,
///   year_of_study INTEGER CHECK (year_of_study >= 1 AND year_of_study <= 5),
///   expected_graduation_year INTEGER,
///   college_email TEXT,
///   college_email_verified BOOLEAN DEFAULT FALSE,
///   student_id_verified BOOLEAN DEFAULT FALSE,
///   preferred_subjects TEXT[],
///   created_at TIMESTAMPTZ DEFAULT NOW(),
///   updated_at TIMESTAMPTZ
/// );
/// ```
///
/// ## Relationship
///
/// ```
/// UserProfile (profiles table)
///      │
///      │ One-to-One (profile_id)
///      ▼
/// StudentData (students table)
/// ```
///
/// ## Usage
///
/// ```dart
/// // Fetch student data
/// final response = await supabase.from('students')
///     .select()
///     .eq('profile_id', profile.id)
///     .maybeSingle();
/// final studentData = response != null
///     ? StudentData.fromJson(response)
///     : null;
///
/// // Display academic info
/// Text('${studentData?.universityName ?? "No university"}');
/// Text('Year ${studentData?.yearOfStudy ?? 1}');
///
/// // Update student data
/// final updated = studentData.copyWith(semester: 4);
/// await supabase.from('students')
///     .update(updated.toJson())
///     .eq('id', studentData.id);
/// ```
///
/// See also:
/// - [UserProfile] for the main user profile
/// - [UserType.student] which indicates this data should exist
/// - [ProfessionalData] for the professional equivalent
class StudentData {
  /// Unique identifier for this student record.
  final String id;

  /// Reference to the associated [UserProfile.id].
  ///
  /// This is a unique foreign key ensuring one-to-one relationship.
  final String profileId;

  /// Reference ID to the universities lookup table.
  ///
  /// Used for standardized university data and validation.
  final String? universityId;

  /// Display name of the user's university or college.
  ///
  /// May be the official name from the lookup table or
  /// user-provided for unlisted institutions.
  final String? universityName;

  /// Reference ID to the courses lookup table.
  ///
  /// Used for standardized course data.
  final String? courseId;

  /// Display name of the user's course or program.
  ///
  /// Examples: "B.Tech Computer Science", "MBA Finance"
  final String? courseName;

  /// Current semester number (1-12).
  ///
  /// Used for context in assignment requirements.
  final int? semester;

  /// Student's official ID number from their institution.
  ///
  /// Used for verification purposes. Not displayed publicly.
  final String? studentIdNumber;

  /// Current year of study (1-5).
  ///
  /// Most undergraduate programs are 3-4 years;
  /// integrated programs may be up to 5 years.
  final int? yearOfStudy;

  /// Expected year of graduation.
  ///
  /// Example: 2025
  final int? expectedGraduationYear;

  /// Student's official college email address.
  ///
  /// Format: student@university.edu
  /// Used for enhanced verification.
  final String? collegeEmail;

  /// Whether the [collegeEmail] has been verified via OTP.
  ///
  /// Verified students may receive additional benefits.
  final bool collegeEmailVerified;

  /// Whether the [studentIdNumber] has been verified.
  ///
  /// Verification may involve ID card upload and manual review.
  final bool studentIdVerified;

  /// List of preferred subject areas for assignments.
  ///
  /// Examples: ['Computer Science', 'Mathematics', 'Physics']
  /// Used for personalized recommendations.
  final List<String>? preferredSubjects;

  /// Timestamp when this student record was created.
  final DateTime createdAt;

  /// Timestamp of the last update to this record.
  final DateTime? updatedAt;

  /// Creates a new [StudentData] instance.
  ///
  /// Required fields: [id], [profileId], [createdAt]
  const StudentData({
    required this.id,
    required this.profileId,
    this.universityId,
    this.universityName,
    this.courseId,
    this.courseName,
    this.semester,
    this.studentIdNumber,
    this.yearOfStudy,
    this.expectedGraduationYear,
    this.collegeEmail,
    this.collegeEmailVerified = false,
    this.studentIdVerified = false,
    this.preferredSubjects,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [StudentData] from a Supabase JSON response.
  ///
  /// Handles null values and type conversions for all fields.
  ///
  /// Example:
  /// ```dart
  /// final response = await supabase.from('students')
  ///     .select()
  ///     .eq('profile_id', profileId)
  ///     .single();
  /// final student = StudentData.fromJson(response);
  /// ```
  factory StudentData.fromJson(Map<String, dynamic> json) {
    return StudentData(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      universityId: json['university_id'] as String?,
      universityName: json['university_name'] as String?,
      courseId: json['course_id'] as String?,
      courseName: json['course_name'] as String?,
      semester: json['semester'] as int?,
      studentIdNumber: json['student_id_number'] as String?,
      yearOfStudy: json['year_of_study'] as int?,
      expectedGraduationYear: json['expected_graduation_year'] as int?,
      collegeEmail: json['college_email'] as String?,
      collegeEmailVerified: json['college_email_verified'] as bool? ?? false,
      studentIdVerified: json['student_id_verified'] as bool? ?? false,
      preferredSubjects: json['preferred_subjects'] != null
          ? List<String>.from(json['preferred_subjects'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this student data to a JSON map for Supabase operations.
  ///
  /// Used for insert and update operations. Does not include [universityName]
  /// and [courseName] as those are typically from joined data.
  ///
  /// Example:
  /// ```dart
  /// await supabase.from('students')
  ///     .upsert(studentData.toJson());
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'university_id': universityId,
      'course_id': courseId,
      'semester': semester,
      'student_id_number': studentIdNumber,
      'year_of_study': yearOfStudy,
      'expected_graduation_year': expectedGraduationYear,
      'college_email': collegeEmail,
      'college_email_verified': collegeEmailVerified,
      'student_id_verified': studentIdVerified,
      'preferred_subjects': preferredSubjects,
    };
  }

  /// Creates a copy of this student data with the specified fields updated.
  ///
  /// All fields are optional. Only provided fields are updated.
  ///
  /// Example:
  /// ```dart
  /// final updated = studentData.copyWith(
  ///   semester: 4,
  ///   yearOfStudy: 2,
  /// );
  /// ```
  StudentData copyWith({
    String? id,
    String? profileId,
    String? universityId,
    String? universityName,
    String? courseId,
    String? courseName,
    int? semester,
    String? studentIdNumber,
    int? yearOfStudy,
    int? expectedGraduationYear,
    String? collegeEmail,
    bool? collegeEmailVerified,
    bool? studentIdVerified,
    List<String>? preferredSubjects,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudentData(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      universityId: universityId ?? this.universityId,
      universityName: universityName ?? this.universityName,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      semester: semester ?? this.semester,
      studentIdNumber: studentIdNumber ?? this.studentIdNumber,
      yearOfStudy: yearOfStudy ?? this.yearOfStudy,
      expectedGraduationYear:
          expectedGraduationYear ?? this.expectedGraduationYear,
      collegeEmail: collegeEmail ?? this.collegeEmail,
      collegeEmailVerified: collegeEmailVerified ?? this.collegeEmailVerified,
      studentIdVerified: studentIdVerified ?? this.studentIdVerified,
      preferredSubjects: preferredSubjects ?? this.preferredSubjects,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

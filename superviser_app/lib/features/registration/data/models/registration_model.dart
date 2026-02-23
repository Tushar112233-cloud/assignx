/// Model for supervisor registration data.
///
/// Collects all information needed for supervisor application.
class RegistrationData {
  const RegistrationData({
    // Basic Info (from auth)
    this.email,
    this.fullName,

    // Professional Profile
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.city,
    this.state,
    this.country,
    this.bio,
    this.linkedInUrl,

    // Education & Experience
    this.highestEducation,
    this.fieldOfStudy,
    this.yearsOfExperience,
    this.expertiseAreas = const [],
    this.cvUrl,

    // Banking Details
    this.accountHolderName,
    this.accountNumber,
    this.bankName,
    this.ifscCode,
    this.panNumber,
  });

  // Basic Info
  final String? email;
  final String? fullName;

  // Professional Profile
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? city;
  final String? state;
  final String? country;
  final String? bio;
  final String? linkedInUrl;

  // Education & Experience
  final String? highestEducation;
  final String? fieldOfStudy;
  final int? yearsOfExperience;
  final List<String> expertiseAreas;
  final String? cvUrl;

  // Banking Details
  final String? accountHolderName;
  final String? accountNumber;
  final String? bankName;
  final String? ifscCode;
  final String? panNumber;

  /// Creates a copy with updated fields
  RegistrationData copyWith({
    String? email,
    String? fullName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? city,
    String? state,
    String? country,
    String? bio,
    String? linkedInUrl,
    String? highestEducation,
    String? fieldOfStudy,
    int? yearsOfExperience,
    List<String>? expertiseAreas,
    String? cvUrl,
    String? accountHolderName,
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? panNumber,
  }) {
    return RegistrationData(
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      bio: bio ?? this.bio,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      highestEducation: highestEducation ?? this.highestEducation,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      expertiseAreas: expertiseAreas ?? this.expertiseAreas,
      cvUrl: cvUrl ?? this.cvUrl,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      panNumber: panNumber ?? this.panNumber,
    );
  }

  /// Converts to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'city': city,
      'state': state,
      'country': country,
      'bio': bio,
      'linkedin_url': linkedInUrl,
      'highest_education': highestEducation,
      'field_of_study': fieldOfStudy,
      'years_of_experience': yearsOfExperience,
      'expertise_areas': expertiseAreas,
      'cv_url': cvUrl,
      'account_holder_name': accountHolderName,
      'account_number': accountNumber,
      'bank_name': bankName,
      'ifsc_code': ifscCode,
      'pan_number': panNumber,
    };
  }

  /// Checks if professional profile step is complete
  bool get isProfileComplete =>
      phone != null &&
      phone!.isNotEmpty &&
      city != null &&
      city!.isNotEmpty;

  /// Checks if education step is complete
  bool get isEducationComplete =>
      highestEducation != null &&
      highestEducation!.isNotEmpty &&
      expertiseAreas.isNotEmpty;

  /// Checks if banking step is complete
  bool get isBankingComplete =>
      accountHolderName != null &&
      accountHolderName!.isNotEmpty &&
      accountNumber != null &&
      accountNumber!.isNotEmpty &&
      bankName != null &&
      bankName!.isNotEmpty &&
      ifscCode != null &&
      ifscCode!.isNotEmpty;

  /// Checks if all required fields are complete
  bool get isComplete =>
      isProfileComplete && isEducationComplete && isBankingComplete;
}

/// Education level options
const List<String> educationLevels = [
  'High School',
  'Associate Degree',
  'Bachelor\'s Degree',
  'Master\'s Degree',
  'Doctorate/PhD',
  'Professional Certification',
  'Other',
];

/// Gender options
const List<String> genderOptions = [
  'Male',
  'Female',
  'Other',
  'Prefer not to say',
];

/// Common expertise areas
const List<String> expertiseAreaOptions = [
  'Academic Writing',
  'Research Papers',
  'Dissertations',
  'Business Studies',
  'Computer Science',
  'Data Analysis',
  'Economics',
  'Engineering',
  'Finance',
  'Healthcare',
  'Law',
  'Marketing',
  'Mathematics',
  'Natural Sciences',
  'Programming',
  'Social Sciences',
  'Statistics',
  'Technical Writing',
];

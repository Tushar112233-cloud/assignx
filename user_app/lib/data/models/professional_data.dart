import 'professional_type.dart';

/// Extended user data model for professional users.
///
/// This model maps to the `professionals` table in Supabase and contains
/// work-related information specific to professional accounts. It is linked
/// to [UserProfile] via the [profileId] field.
///
/// ## Database Table: `professionals`
///
/// ```sql
/// CREATE TABLE professionals (
///   id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
///   profile_id UUID NOT NULL REFERENCES profiles(id) UNIQUE,
///   professional_type TEXT NOT NULL CHECK (
///     professional_type IN ('job_seeker', 'business', 'creator')
///   ),
///   industry_id UUID REFERENCES industries(id),
///   industry_name TEXT,
///   job_title TEXT,
///   company_name TEXT,
///   linkedin_url TEXT,
///   business_type TEXT,
///   gst_number TEXT,
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
/// ProfessionalData (professionals table)
/// ```
///
/// ## Professional Types
///
/// | Type | Use Case | Key Fields |
/// |------|----------|------------|
/// | Job Seeker | Career advancement | job_title, linkedin_url |
/// | Business | Company documents | company_name, gst_number |
/// | Creator | Freelance/content | linkedin_url, business_type |
///
/// ## Usage
///
/// ```dart
/// // Fetch professional data
/// final response = await supabase.from('professionals')
///     .select()
///     .eq('profile_id', profile.id)
///     .maybeSingle();
/// final professionalData = response != null
///     ? ProfessionalData.fromJson(response)
///     : null;
///
/// // Display professional info
/// Text(professionalData?.professionalType.displayName ?? 'Professional');
/// Text('${professionalData?.jobTitle} at ${professionalData?.companyName}');
///
/// // Update professional data
/// final updated = professionalData.copyWith(
///   jobTitle: 'Senior Developer',
/// );
/// await supabase.from('professionals')
///     .update(updated.toJson())
///     .eq('id', professionalData.id);
/// ```
///
/// See also:
/// - [UserProfile] for the main user profile
/// - [UserType.professional] which indicates this data should exist
/// - [ProfessionalType] for the sub-categorization
/// - [StudentData] for the student equivalent
class ProfessionalData {
  /// Unique identifier for this professional record.
  final String id;

  /// Reference to the associated [UserProfile.id].
  ///
  /// This is a unique foreign key ensuring one-to-one relationship.
  final String profileId;

  /// The category of professional user.
  ///
  /// Determines available features and services:
  /// - [ProfessionalType.jobSeeker] - Resume and career services
  /// - [ProfessionalType.business] - Business documentation
  /// - [ProfessionalType.creator] - Content creation services
  final ProfessionalType professionalType;

  /// Reference ID to the industries lookup table.
  ///
  /// Used for standardized industry categorization.
  final String? industryId;

  /// Display name of the user's industry.
  ///
  /// Examples: "Information Technology", "Finance", "Healthcare"
  final String? industryName;

  /// User's current or target job title.
  ///
  /// Examples: "Software Engineer", "Marketing Manager", "Data Analyst"
  final String? jobTitle;

  /// Name of the user's company or organization.
  ///
  /// For job seekers, this is their current or most recent employer.
  /// For business owners, this is their business name.
  final String? companyName;

  /// URL to the user's LinkedIn profile.
  ///
  /// Format: 'https://linkedin.com/in/username'
  /// Used for verification and networking features.
  final String? linkedinUrl;

  /// Type of business for business professionals.
  ///
  /// Examples: "Sole Proprietorship", "Partnership", "Private Limited"
  final String? businessType;

  /// GST registration number for Indian businesses.
  ///
  /// Format: '22AAAAA0000A1Z5' (15 alphanumeric characters)
  /// Used for business verification and invoicing.
  final String? gstNumber;

  /// Timestamp when this professional record was created.
  final DateTime createdAt;

  /// Timestamp of the last update to this record.
  final DateTime? updatedAt;

  /// Creates a new [ProfessionalData] instance.
  ///
  /// Required fields: [id], [profileId], [professionalType], [createdAt]
  const ProfessionalData({
    required this.id,
    required this.profileId,
    required this.professionalType,
    this.industryId,
    this.industryName,
    this.jobTitle,
    this.companyName,
    this.linkedinUrl,
    this.businessType,
    this.gstNumber,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a [ProfessionalData] from a Supabase JSON response.
  ///
  /// Handles null values and type conversions for all fields.
  /// Defaults to [ProfessionalType.jobSeeker] if type is invalid.
  ///
  /// Example:
  /// ```dart
  /// final response = await supabase.from('professionals')
  ///     .select()
  ///     .eq('profile_id', profileId)
  ///     .single();
  /// final professional = ProfessionalData.fromJson(response);
  /// ```
  factory ProfessionalData.fromJson(Map<String, dynamic> json) {
    return ProfessionalData(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      professionalType:
          ProfessionalType.fromString(json['professional_type'] as String?) ??
              ProfessionalType.jobSeeker,
      industryId: json['industry_id'] as String?,
      industryName: json['industry_name'] as String?,
      jobTitle: json['job_title'] as String?,
      companyName: json['company_name'] as String?,
      linkedinUrl: json['linkedin_url'] as String?,
      businessType: json['business_type'] as String?,
      gstNumber: json['gst_number'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this professional data to a JSON map for Supabase operations.
  ///
  /// Used for insert and update operations. Does not include [industryName]
  /// as that is typically from joined data.
  ///
  /// Example:
  /// ```dart
  /// await supabase.from('professionals')
  ///     .upsert(professionalData.toJson());
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'professional_type': professionalType.toDbString(),
      'industry_id': industryId,
      'job_title': jobTitle,
      'company_name': companyName,
      'linkedin_url': linkedinUrl,
      'business_type': businessType,
      'gst_number': gstNumber,
    };
  }

  /// Creates a copy of this professional data with the specified fields updated.
  ///
  /// All fields are optional. Only provided fields are updated.
  ///
  /// Example:
  /// ```dart
  /// final updated = professionalData.copyWith(
  ///   jobTitle: 'Senior Manager',
  ///   companyName: 'Tech Corp',
  /// );
  /// ```
  ProfessionalData copyWith({
    String? id,
    String? profileId,
    ProfessionalType? professionalType,
    String? industryId,
    String? industryName,
    String? jobTitle,
    String? companyName,
    String? linkedinUrl,
    String? businessType,
    String? gstNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfessionalData(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      professionalType: professionalType ?? this.professionalType,
      industryId: industryId ?? this.industryId,
      industryName: industryName ?? this.industryName,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      businessType: businessType ?? this.businessType,
      gstNumber: gstNumber ?? this.gstNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Centralised reference data constants for the doer app.
///
/// These lists are used across registration and onboarding screens.
/// Keeping them in one file makes maintenance and future API migration
/// straightforward — only this file needs to change.
library;

// ---------------------------------------------------------------------------
// Helper classes
// ---------------------------------------------------------------------------

/// A simple label + value pair used in dropdowns and selectors.
class LabelValue {
  final String label;
  final String value;
  const LabelValue(this.label, this.value);
}

/// An experience level option with a human-readable description.
class ExperienceOption {
  final String label;
  final String value;
  final String description;
  const ExperienceOption(this.label, this.value, this.description);
}

// ---------------------------------------------------------------------------
// Qualification options
// ---------------------------------------------------------------------------

/// Qualification options shared by register and profile-setup screens.
///
/// The [LabelValue.value] is sent to the API; the [LabelValue.label] is
/// displayed in the UI.
const List<LabelValue> qualificationOptions = [
  LabelValue('High School', 'high_school'),
  LabelValue('Diploma', 'diploma'),
  LabelValue('Undergraduate', 'undergraduate'),
  LabelValue('Bachelor\'s Degree', 'bachelors'),
  LabelValue('Master\'s Degree', 'masters'),
  LabelValue('Post Graduate', 'postgraduate'),
  LabelValue('PhD', 'phd'),
  LabelValue('Other', 'other'),
];

// ---------------------------------------------------------------------------
// Experience levels
// ---------------------------------------------------------------------------

/// Experience level options with year-range descriptions.
const List<ExperienceOption> experienceLevels = [
  ExperienceOption('Beginner', 'beginner', '0-1 years'),
  ExperienceOption('Intermediate', 'intermediate', '1-3 years'),
  ExperienceOption('Professional', 'pro', '3+ years'),
];

// ---------------------------------------------------------------------------
// Indian banks
// ---------------------------------------------------------------------------

/// Indian banks for the banking details step.
const List<LabelValue> indianBanks = [
  LabelValue('State Bank of India', 'sbi'),
  LabelValue('HDFC Bank', 'hdfc'),
  LabelValue('ICICI Bank', 'icici'),
  LabelValue('Axis Bank', 'axis'),
  LabelValue('Kotak Mahindra Bank', 'kotak'),
  LabelValue('Punjab National Bank', 'pnb'),
  LabelValue('Bank of Baroda', 'bob'),
  LabelValue('Canara Bank', 'canara'),
  LabelValue('Union Bank of India', 'union'),
  LabelValue('IDBI Bank', 'idbi'),
  LabelValue('IndusInd Bank', 'indusind'),
  LabelValue('Yes Bank', 'yes'),
  LabelValue('Other', 'other'),
];

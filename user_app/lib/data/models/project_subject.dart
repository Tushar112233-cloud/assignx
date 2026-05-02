import 'package:flutter/material.dart';

/// Project subject enum for categorizing projects.
///
/// Note: In production, subjects should be fetched from the database.
/// This enum provides a fallback for UI components that need predefined subjects.
enum ProjectSubject {
  computerScience('Computer Science', Icons.computer, Color(0xFF3B82F6)),
  engineering('Engineering', Icons.engineering, Color(0xFFF59E0B)),
  mathematics('Mathematics', Icons.calculate, Color(0xFF10B981)),
  physics('Physics', Icons.science, Color(0xFF8B5CF6)),
  chemistry('Chemistry', Icons.biotech, Color(0xFFEC4899)),
  biology('Biology', Icons.eco, Color(0xFF22C55E)),
  economics('Economics', Icons.trending_up, Color(0xFF6366F1)),
  business('Business', Icons.business_center, Color(0xFFF97316)),
  law('Law', Icons.gavel, Color(0xFF78716C)),
  psychology('Psychology', Icons.psychology, Color(0xFFE879F9)),
  literature('Literature', Icons.menu_book, Color(0xFF14B8A6)),
  history('History', Icons.history_edu, Color(0xFFA78BFA)),
  sociology('Sociology', Icons.groups, Color(0xFF06B6D4)),
  medicine('Medicine', Icons.medical_services, Color(0xFFEF4444)),
  nursing('Nursing', Icons.healing, Color(0xFFF472B6)),
  other('Other', Icons.category, Color(0xFF9CA3AF));

  /// Display name for the subject.
  final String displayName;

  /// Icon representing the subject.
  final IconData icon;

  /// Color associated with the subject.
  final Color color;

  const ProjectSubject(this.displayName, this.icon, this.color);

  /// Get subject from database string value.
  static ProjectSubject fromString(String? value) {
    if (value == null) return ProjectSubject.other;

    final normalized = value.toLowerCase().replaceAll('_', '').replaceAll(' ', '');

    for (final subject in ProjectSubject.values) {
      final subjectNormalized = subject.name.toLowerCase();
      if (subjectNormalized == normalized) {
        return subject;
      }
    }

    return ProjectSubject.other;
  }

  /// Convert to database string value.
  String toDbString() => name;
}

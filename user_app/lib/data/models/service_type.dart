import 'package:flutter/material.dart';

/// Service type enum matching database service_type enum.
/// DB values: new_project, proofreading, plagiarism_check, ai_detection, expert_opinion
enum ServiceType {
  /// New project/assignment.
  newProject,

  /// Proofreading service.
  proofreading,

  /// Plagiarism check service.
  plagiarismCheck,

  /// AI detection service.
  aiDetection,

  /// Expert opinion/consultation.
  expertOpinion,
}

/// Extension to add display properties and DB conversion to ServiceType.
extension ServiceTypeX on ServiceType {
  /// Mapping from DB string to enum.
  static const _fromDbMap = {
    'new_project': ServiceType.newProject,
    'proofreading': ServiceType.proofreading,
    'plagiarism_check': ServiceType.plagiarismCheck,
    'ai_detection': ServiceType.aiDetection,
    'expert_opinion': ServiceType.expertOpinion,
  };

  /// Mapping from enum to DB string.
  static const _toDbMap = {
    ServiceType.newProject: 'new_project',
    ServiceType.proofreading: 'proofreading',
    ServiceType.plagiarismCheck: 'plagiarism_check',
    ServiceType.aiDetection: 'ai_detection',
    ServiceType.expertOpinion: 'expert_opinion',
  };

  /// Display names for each service type.
  static const _displayNames = {
    ServiceType.newProject: 'New Project',
    ServiceType.proofreading: 'Proofreading',
    ServiceType.plagiarismCheck: 'Plagiarism Check',
    ServiceType.aiDetection: 'AI Detection',
    ServiceType.expertOpinion: 'Expert Opinion',
  };

  /// Icons for each service type.
  static const _icons = {
    ServiceType.newProject: Icons.assignment_outlined,
    ServiceType.proofreading: Icons.spellcheck,
    ServiceType.plagiarismCheck: Icons.content_copy_outlined,
    ServiceType.aiDetection: Icons.smart_toy_outlined,
    ServiceType.expertOpinion: Icons.support_agent_outlined,
  };

  /// Convert from database snake_case string to enum.
  static ServiceType fromString(String value) {
    return _fromDbMap[value] ?? ServiceType.newProject;
  }

  /// Convert enum to database snake_case string.
  String toDbString() => _toDbMap[this]!;

  /// Display name for the service type.
  String get displayName => _displayNames[this]!;

  /// Icon for the service type.
  IconData get icon => _icons[this]!;
}

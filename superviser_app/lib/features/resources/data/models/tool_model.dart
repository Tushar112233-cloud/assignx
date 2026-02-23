import 'package:flutter/material.dart';

/// Types of external tools available to supervisors.
enum ToolType {
  plagiarismChecker('plagiarism', 'Plagiarism Checker', Icons.plagiarism),
  aiDetector('ai_detector', 'AI Detector', Icons.smart_toy),
  grammarChecker('grammar', 'Grammar Checker', Icons.spellcheck),
  citationGenerator('citation', 'Citation Generator', Icons.format_quote),
  referenceManager('reference', 'Reference Manager', Icons.library_books),
  calculatorTool('calculator', 'Calculator', Icons.calculate);

  const ToolType(this.id, this.displayName, this.icon);

  final String id;
  final String displayName;
  final IconData icon;

  /// Get color for this tool type.
  Color get color {
    switch (this) {
      case ToolType.plagiarismChecker:
        return Colors.red;
      case ToolType.aiDetector:
        return Colors.purple;
      case ToolType.grammarChecker:
        return Colors.blue;
      case ToolType.citationGenerator:
        return Colors.green;
      case ToolType.referenceManager:
        return Colors.orange;
      case ToolType.calculatorTool:
        return Colors.teal;
    }
  }

  /// Creates a ToolType from a string ID.
  static ToolType fromId(String id) {
    return ToolType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => ToolType.plagiarismChecker,
    );
  }
}

/// Model representing an external tool.
///
/// Tools can be web-based (WebView) or native functionality.
class ToolModel {
  const ToolModel({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    this.url,
    this.iconUrl,
    this.isExternal = true,
    this.isPremium = false,
    this.usageCount = 0,
    this.lastUsed,
    this.metadata,
  });

  /// Unique identifier.
  final String id;

  /// Display name.
  final String name;

  /// Type of tool.
  final ToolType type;

  /// Tool description.
  final String description;

  /// URL for web-based tools.
  final String? url;

  /// Custom icon URL.
  final String? iconUrl;

  /// Whether this opens external content.
  final bool isExternal;

  /// Whether this is a premium feature.
  final bool isPremium;

  /// Number of times used.
  final int usageCount;

  /// Last time this tool was used.
  final DateTime? lastUsed;

  /// Additional metadata.
  final Map<String, dynamic>? metadata;

  /// Get the icon for this tool.
  IconData get icon => type.icon;

  /// Get the color for this tool.
  Color get color => type.color;

  /// Creates a ToolModel from JSON.
  factory ToolModel.fromJson(Map<String, dynamic> json) {
    return ToolModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: ToolType.fromId(json['type'] as String? ?? 'plagiarism'),
      description: json['description'] as String? ?? '',
      url: json['url'] as String?,
      iconUrl: json['icon_url'] as String?,
      isExternal: json['is_external'] as bool? ?? true,
      isPremium: json['is_premium'] as bool? ?? false,
      usageCount: json['usage_count'] as int? ?? 0,
      lastUsed: json['last_used'] != null
          ? DateTime.parse(json['last_used'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.id,
      'description': description,
      'url': url,
      'icon_url': iconUrl,
      'is_external': isExternal,
      'is_premium': isPremium,
      'usage_count': usageCount,
      'last_used': lastUsed?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Creates a copy with updated fields.
  ToolModel copyWith({
    String? id,
    String? name,
    ToolType? type,
    String? description,
    String? url,
    String? iconUrl,
    bool? isExternal,
    bool? isPremium,
    int? usageCount,
    DateTime? lastUsed,
    Map<String, dynamic>? metadata,
  }) {
    return ToolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      url: url ?? this.url,
      iconUrl: iconUrl ?? this.iconUrl,
      isExternal: isExternal ?? this.isExternal,
      isPremium: isPremium ?? this.isPremium,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      metadata: metadata ?? this.metadata,
    );
  }
}

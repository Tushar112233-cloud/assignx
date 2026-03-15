import 'package:flutter/material.dart';

/// Subject model fetched from API.
class Subject {
  final String id;
  final String name;
  final String slug;
  final String category;
  final bool isActive;

  const Subject({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    this.isActive = true,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }

  IconData get icon => _slugIconMap[slug] ?? Icons.category;
  Color get color => _slugColorMap[slug] ?? const Color(0xFF9CA3AF);

  static const Map<String, IconData> _slugIconMap = {
    'engineering': Icons.engineering,
    'computer-science': Icons.computer,
    'mathematics': Icons.calculate,
    'physics': Icons.science,
    'chemistry': Icons.biotech,
    'biology': Icons.eco,
    'data-science': Icons.trending_up,
    'business': Icons.business_center,
    'economics': Icons.trending_up,
    'marketing': Icons.campaign,
    'finance': Icons.attach_money,
    'medicine': Icons.medical_services,
    'nursing': Icons.healing,
    'psychology': Icons.psychology,
    'sociology': Icons.groups,
    'law': Icons.gavel,
    'literature': Icons.menu_book,
    'history': Icons.history_edu,
    'arts': Icons.palette,
    'other': Icons.category,
  };

  static const Map<String, Color> _slugColorMap = {
    'engineering': Color(0xFF3B82F6),
    'computer-science': Color(0xFF0EA5E9),
    'mathematics': Color(0xFF6366F1),
    'physics': Color(0xFF8B5CF6),
    'chemistry': Color(0xFF10B981),
    'biology': Color(0xFF22C55E),
    'data-science': Color(0xFF14B8A6),
    'business': Color(0xFFA855F7),
    'economics': Color(0xFFF59E0B),
    'marketing': Color(0xFFD946EF),
    'finance': Color(0xFF84CC16),
    'medicine': Color(0xFFEF4444),
    'nursing': Color(0xFFF472B6),
    'psychology': Color(0xFFEC4899),
    'sociology': Color(0xFF06B6D4),
    'law': Color(0xFF78716C),
    'literature': Color(0xFF14B8A6),
    'history': Color(0xFFA78BFA),
    'arts': Color(0xFFF97316),
    'other': Color(0xFF9CA3AF),
  };
}

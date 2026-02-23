import 'package:flutter/material.dart';

/// Types of academic work for pricing.
enum WorkType {
  essay('essay', 'Essay', Icons.article),
  researchPaper('research_paper', 'Research Paper', Icons.science),
  thesis('thesis', 'Thesis', Icons.menu_book),
  dissertation('dissertation', 'Dissertation', Icons.auto_stories),
  casestudy('case_study', 'Case Study', Icons.business_center),
  report('report', 'Report', Icons.summarize),
  presentation('presentation', 'Presentation', Icons.slideshow),
  assignment('assignment', 'Assignment', Icons.assignment),
  coursework('coursework', 'Coursework', Icons.school),
  editing('editing', 'Editing/Proofreading', Icons.edit_note);

  const WorkType(this.id, this.displayName, this.icon);

  final String id;
  final String displayName;
  final IconData icon;

  /// Creates a WorkType from a string ID.
  static WorkType fromId(String id) {
    return WorkType.values.firstWhere(
      (t) => t.id == id,
      orElse: () => WorkType.essay,
    );
  }
}

/// Academic levels for pricing tiers.
enum AcademicLevel {
  highSchool('high_school', 'High School'),
  undergraduate('undergraduate', 'Undergraduate'),
  masters('masters', 'Masters'),
  phd('phd', 'PhD/Doctoral');

  const AcademicLevel(this.id, this.displayName);

  final String id;
  final String displayName;

  /// Get multiplier for this level.
  double get priceMultiplier {
    switch (this) {
      case AcademicLevel.highSchool:
        return 1.0;
      case AcademicLevel.undergraduate:
        return 1.2;
      case AcademicLevel.masters:
        return 1.5;
      case AcademicLevel.phd:
        return 2.0;
    }
  }

  static AcademicLevel fromId(String id) {
    return AcademicLevel.values.firstWhere(
      (l) => l.id == id,
      orElse: () => AcademicLevel.undergraduate,
    );
  }
}

/// Urgency levels for pricing.
enum UrgencyLevel {
  standard('standard', '7+ days', 1.0),
  moderate('moderate', '3-6 days', 1.25),
  urgent('urgent', '24-72 hours', 1.5),
  express('express', 'Under 24 hours', 2.0);

  const UrgencyLevel(this.id, this.displayName, this.multiplier);

  final String id;
  final String displayName;
  final double multiplier;

  static UrgencyLevel fromId(String id) {
    return UrgencyLevel.values.firstWhere(
      (u) => u.id == id,
      orElse: () => UrgencyLevel.standard,
    );
  }
}

/// Model representing a pricing entry.
///
/// Contains base prices and modifiers for calculating quotes.
class PricingModel {
  const PricingModel({
    required this.id,
    required this.workType,
    required this.basePrice,
    this.academicLevel = AcademicLevel.undergraduate,
    this.pricePerPage,
    this.pricePerWord,
    this.minimumPages = 1,
    this.minimumWords = 275,
    this.wordsPerPage = 275,
    this.description,
    this.notes,
    this.isActive = true,
    this.updatedAt,
  });

  /// Unique identifier.
  final String id;

  /// Type of work.
  final WorkType workType;

  /// Base price per page.
  final double basePrice;

  /// Academic level.
  final AcademicLevel academicLevel;

  /// Override price per page if different from base.
  final double? pricePerPage;

  /// Price per word (alternative to per page).
  final double? pricePerWord;

  /// Minimum pages for this work type.
  final int minimumPages;

  /// Minimum words (usually 275 per page).
  final int minimumWords;

  /// Words per page standard.
  final int wordsPerPage;

  /// Description of what's included.
  final String? description;

  /// Special notes for this pricing.
  final String? notes;

  /// Whether this pricing is currently active.
  final bool isActive;

  /// When this pricing was last updated.
  final DateTime? updatedAt;

  /// Get the effective price per page.
  double get effectivePricePerPage =>
      (pricePerPage ?? basePrice) * academicLevel.priceMultiplier;

  /// Calculate price for given parameters.
  double calculatePrice({
    required int pages,
    UrgencyLevel urgency = UrgencyLevel.standard,
    bool includeExtras = false,
  }) {
    final baseCost = pages * effectivePricePerPage;
    final withUrgency = baseCost * urgency.multiplier;
    return withUrgency;
  }

  /// Calculate price for given word count.
  double calculatePriceByWords({
    required int wordCount,
    UrgencyLevel urgency = UrgencyLevel.standard,
  }) {
    if (pricePerWord != null) {
      return wordCount * pricePerWord! * urgency.multiplier;
    }
    // Convert to pages
    final pages = (wordCount / wordsPerPage).ceil();
    return calculatePrice(pages: pages, urgency: urgency);
  }

  /// Creates a PricingModel from JSON.
  factory PricingModel.fromJson(Map<String, dynamic> json) {
    return PricingModel(
      id: json['id'] as String,
      workType: WorkType.fromId(json['work_type'] as String? ?? 'essay'),
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      academicLevel: AcademicLevel.fromId(
          json['academic_level'] as String? ?? 'undergraduate'),
      pricePerPage: (json['price_per_page'] as num?)?.toDouble(),
      pricePerWord: (json['price_per_word'] as num?)?.toDouble(),
      minimumPages: json['minimum_pages'] as int? ?? 1,
      minimumWords: json['minimum_words'] as int? ?? 275,
      wordsPerPage: json['words_per_page'] as int? ?? 275,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Converts this model to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_type': workType.id,
      'base_price': basePrice,
      'academic_level': academicLevel.id,
      'price_per_page': pricePerPage,
      'price_per_word': pricePerWord,
      'minimum_pages': minimumPages,
      'minimum_words': minimumWords,
      'words_per_page': wordsPerPage,
      'description': description,
      'notes': notes,
      'is_active': isActive,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy with updated fields.
  PricingModel copyWith({
    String? id,
    WorkType? workType,
    double? basePrice,
    AcademicLevel? academicLevel,
    double? pricePerPage,
    double? pricePerWord,
    int? minimumPages,
    int? minimumWords,
    int? wordsPerPage,
    String? description,
    String? notes,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return PricingModel(
      id: id ?? this.id,
      workType: workType ?? this.workType,
      basePrice: basePrice ?? this.basePrice,
      academicLevel: academicLevel ?? this.academicLevel,
      pricePerPage: pricePerPage ?? this.pricePerPage,
      pricePerWord: pricePerWord ?? this.pricePerWord,
      minimumPages: minimumPages ?? this.minimumPages,
      minimumWords: minimumWords ?? this.minimumWords,
      wordsPerPage: wordsPerPage ?? this.wordsPerPage,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Pricing guide with all pricing entries.
class PricingGuide {
  const PricingGuide({
    required this.pricings,
    this.lastUpdated,
    this.currency = 'INR',
    this.notes,
  });

  /// All pricing entries.
  final List<PricingModel> pricings;

  /// When the guide was last updated.
  final DateTime? lastUpdated;

  /// Currency code.
  final String currency;

  /// General notes about pricing.
  final String? notes;

  /// Get pricing for a specific work type.
  PricingModel? getPricing(WorkType type, {AcademicLevel? level}) {
    return pricings.where((p) {
      if (p.workType != type) return false;
      if (level != null && p.academicLevel != level) return false;
      return p.isActive;
    }).firstOrNull;
  }

  /// Get all pricings for a work type.
  List<PricingModel> getPricingsForType(WorkType type) {
    return pricings.where((p) => p.workType == type && p.isActive).toList();
  }

  /// Creates a PricingGuide from JSON.
  factory PricingGuide.fromJson(Map<String, dynamic> json) {
    return PricingGuide(
      pricings: (json['pricings'] as List?)
              ?.map((e) => PricingModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
      currency: json['currency'] as String? ?? 'INR',
      notes: json['notes'] as String?,
    );
  }
}

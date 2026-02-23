/// FAQ model for Help & Support section.
///
/// Maps to the `faqs` table in Supabase with the following structure:
/// - id: uuid (primary key)
/// - question: text
/// - answer: text
/// - category: text (general, payment, project, account, technical)
/// - order_index: int
/// - is_active: boolean
/// - created_at: timestamp
library;

/// FAQ category enum matching database values.
enum FAQCategory {
  general('general', 'General'),
  payment('payment', 'Payment'),
  project('project', 'Project'),
  account('account', 'Account'),
  technical('technical', 'Technical');

  /// Database value for the category.
  final String dbValue;

  /// Display label for the category.
  final String label;

  const FAQCategory(this.dbValue, this.label);

  /// Create from database string value.
  static FAQCategory fromDbValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'general':
        return FAQCategory.general;
      case 'payment':
        return FAQCategory.payment;
      case 'project':
        return FAQCategory.project;
      case 'account':
        return FAQCategory.account;
      case 'technical':
        return FAQCategory.technical;
      default:
        return FAQCategory.general;
    }
  }
}

/// FAQ model representing a frequently asked question.
class FAQ {
  /// Unique identifier.
  final String id;

  /// The question text.
  final String question;

  /// The answer text.
  final String answer;

  /// Category of the FAQ.
  final FAQCategory category;

  /// Order index for sorting.
  final int orderIndex;

  /// Whether the FAQ is active and should be displayed.
  final bool isActive;

  /// Timestamp when the FAQ was created.
  final DateTime createdAt;

  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.orderIndex = 0,
    this.isActive = true,
    required this.createdAt,
  });

  /// Create FAQ from JSON (Supabase response).
  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] as String,
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: FAQCategory.fromDbValue(json['category'] as String?),
      orderIndex: json['order_index'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Convert FAQ to JSON for storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category.dbValue,
      'order_index': orderIndex,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with modified fields.
  FAQ copyWith({
    String? id,
    String? question,
    String? answer,
    FAQCategory? category,
    int? orderIndex,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return FAQ(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      orderIndex: orderIndex ?? this.orderIndex,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FAQ && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'FAQ(id: $id, question: $question, category: ${category.label})';
  }
}

/// Grouped FAQs by category for display.
class GroupedFAQs {
  /// Category of the group.
  final FAQCategory category;

  /// FAQs in this category.
  final List<FAQ> faqs;

  const GroupedFAQs({
    required this.category,
    required this.faqs,
  });

  /// Whether this group is empty.
  bool get isEmpty => faqs.isEmpty;

  /// Whether this group has FAQs.
  bool get isNotEmpty => faqs.isNotEmpty;

  /// Number of FAQs in this group.
  int get count => faqs.length;
}

/// Extension to group a list of FAQs by category.
extension FAQListExtension on List<FAQ> {
  /// Group FAQs by their category.
  List<GroupedFAQs> groupByCategory() {
    final Map<FAQCategory, List<FAQ>> grouped = {};

    for (final faq in this) {
      grouped.putIfAbsent(faq.category, () => []).add(faq);
    }

    return grouped.entries
        .map((entry) => GroupedFAQs(category: entry.key, faqs: entry.value))
        .toList()
      ..sort((a, b) => a.category.index.compareTo(b.category.index));
  }

  /// Filter FAQs by category.
  List<FAQ> filterByCategory(FAQCategory? category) {
    if (category == null) return this;
    return where((faq) => faq.category == category).toList();
  }

  /// Search FAQs by query string.
  List<FAQ> search(String query) {
    if (query.isEmpty) return this;
    final lowerQuery = query.toLowerCase();
    return where((faq) =>
        faq.question.toLowerCase().contains(lowerQuery) ||
        faq.answer.toLowerCase().contains(lowerQuery)).toList();
  }
}

/// Skill model fetched from API.
class Skill {
  final String id;
  final String name;
  final String category;
  final bool isActive;

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    this.isActive = true,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
    );
  }
}

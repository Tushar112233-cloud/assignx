import '../models/skill.dart';
import '../../core/api/api_client.dart';

/// Repository for fetching skills from the API.
class SkillRepository {
  /// Fetches the list of active skills from the backend.
  Future<List<Skill>> getSkills() async {
    final response = await ApiClient.get('/skills');
    final List<dynamic> skillList = response['skills'] ?? [];
    return skillList.map((json) => Skill.fromJson(json)).toList();
  }
}

import '../models/subject.dart';
import '../../core/api/api_client.dart';

/// Repository for fetching subjects from the API.
class SubjectRepository {
  /// Fetches the list of active subjects from the backend.
  ///
  /// Note: ApiClient.get() already prepends '/api', so we pass just '/subjects'.
  Future<List<Subject>> getSubjects() async {
    final response = await ApiClient.get('/subjects');
    final data = response as Map<String, dynamic>;
    final List<dynamic> subjectList = data['subjects'] ?? [];
    return subjectList.map((json) => Subject.fromJson(json)).toList();
  }
}

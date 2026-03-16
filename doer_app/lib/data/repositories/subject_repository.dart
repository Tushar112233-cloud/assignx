import '../models/subject.dart';
import '../../core/api/api_client.dart';

/// Repository for fetching subjects from the API.
class SubjectRepository {
  /// Fetches the list of active subjects from the backend.
  Future<List<Subject>> getSubjects() async {
    final response = await ApiClient.get('/subjects');
    final List<dynamic> subjectList = response['subjects'] ?? [];
    return subjectList.map((json) => Subject.fromJson(json)).toList();
  }
}

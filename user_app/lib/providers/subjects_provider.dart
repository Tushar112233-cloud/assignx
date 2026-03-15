import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/subject.dart';
import '../data/repositories/subject_repository.dart';

/// Provider for the subject repository instance.
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository();
});

/// Provider that fetches and caches the list of subjects from the API.
final subjectsProvider = FutureProvider<List<Subject>>((ref) async {
  final repository = ref.watch(subjectRepositoryProvider);
  return repository.getSubjects();
});

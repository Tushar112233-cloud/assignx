import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/skill.dart';
import '../data/repositories/skill_repository.dart';

/// Provider for the skill repository instance.
final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return SkillRepository();
});

/// Provider that fetches and caches the list of skills from the API.
final skillsProvider = FutureProvider<List<Skill>>((ref) async {
  final repository = ref.watch(skillRepositoryProvider);
  return repository.getSkills();
});

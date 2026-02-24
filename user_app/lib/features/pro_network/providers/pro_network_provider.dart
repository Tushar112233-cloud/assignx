library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pro_network_post_model.dart';
import '../data/repositories/pro_network_repository.dart';

/// Provider for the pro network repository.
final proNetworkRepositoryProvider = Provider<ProNetworkRepository>((ref) {
  return ProNetworkRepository();
});

/// Provider for pro network posts.
final proNetworkPostsProvider =
    FutureProvider.autoDispose<List<ProNetworkPost>>((ref) async {
  final repository = ref.watch(proNetworkRepositoryProvider);
  return repository.getPosts();
});

/// Provider for filtered pro network posts.
final filteredProNetworkPostsProvider = FutureProvider.autoDispose
    .family<List<ProNetworkPost>, ProfessionalCategory?>((ref, category) async {
  final repository = ref.watch(proNetworkRepositoryProvider);
  return repository.getPosts(category: category);
});

/// Provider for a single pro network post.
final proNetworkPostDetailProvider = FutureProvider.autoDispose
    .family<ProNetworkPost?, String>((ref, postId) async {
  final repository = ref.watch(proNetworkRepositoryProvider);
  return repository.getPostById(postId);
});

/// Provider for saved pro network posts.
final savedProNetworkPostsProvider =
    FutureProvider.autoDispose<List<ProNetworkPost>>((ref) async {
  final repository = ref.watch(proNetworkRepositoryProvider);
  return repository.getSavedPosts();
});

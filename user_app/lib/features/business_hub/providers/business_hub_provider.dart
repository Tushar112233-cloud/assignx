library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/business_hub_post_model.dart';
import '../data/repositories/business_hub_repository.dart';

/// Provider for the business hub repository.
final businessHubRepositoryProvider = Provider<BusinessHubRepository>((ref) {
  return BusinessHubRepository();
});

/// Provider for business hub posts.
final businessHubPostsProvider =
    FutureProvider.autoDispose<List<BusinessHubPost>>((ref) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getPosts();
});

/// Provider for filtered business hub posts.
final filteredBusinessHubPostsProvider = FutureProvider.autoDispose
    .family<List<BusinessHubPost>, BusinessCategory?>((ref, category) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getPosts(category: category);
});

/// Provider for a single business hub post.
final businessHubPostDetailProvider = FutureProvider.autoDispose
    .family<BusinessHubPost?, String>((ref, postId) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getPostById(postId);
});

/// Provider for saved business hub posts.
final savedBusinessHubPostsProvider =
    FutureProvider.autoDispose<List<BusinessHubPost>>((ref) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getSavedPosts();
});

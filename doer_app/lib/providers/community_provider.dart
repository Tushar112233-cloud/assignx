/// Provider for community (Pro Network) state management.
///
/// Provides Riverpod providers for community posts, comments,
/// saved posts, and related operations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/community_post_model.dart';
import '../data/models/community_comment_model.dart';
import '../data/repositories/community_repository.dart';

/// Community repository provider.
final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository();
});

/// Community posts provider with optional category filter.
final communityPostsProvider = FutureProvider.autoDispose
    .family<List<CommunityPost>, ProfessionalCategory?>(
  (ref, category) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getPosts(category: category);
  },
);

/// Community post search provider.
final communitySearchProvider =
    FutureProvider.autoDispose.family<List<CommunityPost>, String>(
  (ref, query) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getPosts(searchQuery: query);
  },
);

/// Single post detail provider.
final communityPostDetailProvider =
    FutureProvider.autoDispose.family<CommunityPost?, String>(
  (ref, postId) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getPostById(postId);
  },
);

/// Post comments provider.
final postCommentsProvider =
    FutureProvider.autoDispose.family<List<CommunityComment>, String>(
  (ref, postId) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getComments(postId);
  },
);

/// Saved posts provider.
final savedCommunityPostsProvider =
    FutureProvider.autoDispose<List<CommunityPost>>(
  (ref) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getSavedPosts();
  },
);

/// Current user's posts provider.
final userCommunityPostsProvider =
    FutureProvider.autoDispose<List<CommunityPost>>(
  (ref) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.getUserPosts();
  },
);

/// Selected category state notifier.
class SelectedCommunityCategoryNotifier extends Notifier<ProfessionalCategory> {
  @override
  ProfessionalCategory build() => ProfessionalCategory.all;

  void select(ProfessionalCategory category) => state = category;
}

/// Selected category state provider.
final selectedCommunityCategory =
    NotifierProvider<SelectedCommunityCategoryNotifier, ProfessionalCategory>(
        SelectedCommunityCategoryNotifier.new);

/// Community search query state notifier.
class CommunitySearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Community search query state provider.
final communitySearchQuery =
    NotifierProvider<CommunitySearchQueryNotifier, String>(
        CommunitySearchQueryNotifier.new);

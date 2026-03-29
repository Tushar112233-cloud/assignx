library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/business_hub_post_model.dart';
import '../data/repositories/business_hub_repository.dart';

/// Provider for the business hub repository.
final businessHubRepositoryProvider = Provider<BusinessHubRepository>((ref) {
  return BusinessHubRepository();
});

/// Provider for all investors (unfiltered).
final investorsProvider =
    FutureProvider.autoDispose<List<Investor>>((ref) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getInvestors();
});

/// Provider for filtered investors by funding stage.
final filteredInvestorsProvider = FutureProvider.autoDispose
    .family<List<Investor>, FundingStage?>((ref, stage) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getInvestors(stage: stage);
});

/// Provider for a single investor by ID.
final investorDetailProvider = FutureProvider.autoDispose
    .family<Investor?, String>((ref, investorId) async {
  final repository = ref.watch(businessHubRepositoryProvider);
  return repository.getInvestorById(investorId);
});

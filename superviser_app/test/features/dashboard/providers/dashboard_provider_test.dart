import 'package:flutter_test/flutter_test.dart';
import 'package:superviser_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:superviser_app/features/dashboard/data/models/request_model.dart';
import 'package:superviser_app/features/dashboard/data/models/doer_model.dart';
import 'package:superviser_app/features/dashboard/data/models/quote_model.dart';

void main() {
  group('DashboardState', () {
    test('default state has correct initial values', () {
      const state = DashboardState();
      expect(state.newRequests, isEmpty);
      expect(state.paidRequests, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.selectedSubject, 'All');
      expect(state.isAvailable, isTrue);
    });

    test('pendingCount returns sum of new and paid requests', () {
      final state = DashboardState(
        newRequests: [
          _createRequest('1'),
          _createRequest('2'),
        ],
        paidRequests: [
          _createRequest('3'),
        ],
      );
      expect(state.pendingCount, 3);
    });

    test('copyWith creates new state with updated values', () {
      const state = DashboardState();
      final newState = state.copyWith(
        isLoading: true,
        selectedSubject: 'Mathematics',
        isAvailable: false,
      );

      expect(newState.isLoading, isTrue);
      expect(newState.selectedSubject, 'Mathematics');
      expect(newState.isAvailable, isFalse);
      // Original values preserved
      expect(newState.newRequests, isEmpty);
      expect(newState.paidRequests, isEmpty);
    });

    test('copyWith with clearError clears the error', () {
      const state = DashboardState(error: 'Some error');
      final newState = state.copyWith(clearError: true);
      expect(newState.error, isNull);
    });

    test('copyWith preserves error when not cleared', () {
      const state = DashboardState(error: 'Some error');
      final newState = state.copyWith(isLoading: true);
      expect(newState.error, 'Some error');
    });

    test('filteredNewRequests returns all when subject is All', () {
      final state = DashboardState(
        newRequests: [
          _createRequest('1'),
          _createRequest('2'),
        ],
        selectedSubject: 'All',
      );
      expect(state.filteredNewRequests.length, 2);
    });

    test('filteredNewRequests filters by subject', () {
      final state = DashboardState(
        newRequests: [
          _createRequest('1'),
          _createRequest('2'),
        ],
        selectedSubject: 'Mathematics',
      );
      expect(state.filteredNewRequests.length, 2);
    });

    test('filteredPaidRequests returns all when subject is All', () {
      final state = DashboardState(
        paidRequests: [
          _createRequest('1'),
        ],
        selectedSubject: 'All',
      );
      expect(state.filteredPaidRequests.length, 1);
    });
  });

  group('DoerSelectionState', () {
    test('default state has correct initial values', () {
      const state = DoerSelectionState();
      expect(state.doers, isEmpty);
      expect(state.filteredDoers, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.searchQuery, isEmpty);
      expect(state.selectedExpertise, 'All');
    });

    test('copyWith creates new state with updated values', () {
      const state = DoerSelectionState();
      final doers = [_createDoer('1'), _createDoer('2')];

      final newState = state.copyWith(
        doers: doers,
        filteredDoers: doers,
        searchQuery: 'John',
        selectedExpertise: 'Essay Writing',
      );

      expect(newState.doers.length, 2);
      expect(newState.filteredDoers.length, 2);
      expect(newState.searchQuery, 'John');
      expect(newState.selectedExpertise, 'Essay Writing');
    });

    test('copyWith with clearError clears the error', () {
      const state = DoerSelectionState(error: 'Load failed');
      final newState = state.copyWith(clearError: true);
      expect(newState.error, isNull);
    });
  });

  group('QuoteFormState', () {
    test('default state has correct initial values', () {
      const state = QuoteFormState();
      expect(state.items, isEmpty);
      expect(state.notes, isEmpty);
      expect(state.isSubmitting, isFalse);
      expect(state.error, isNull);
      expect(state.totalPrice, 0.0);
    });

    test('totalPrice calculates sum of all items', () {
      final state = QuoteFormState(
        items: [
          const QuoteItem(description: 'Writing', amount: 50.0),
          const QuoteItem(description: 'Research', amount: 25.0),
          const QuoteItem(description: 'Editing', amount: 15.0),
        ],
      );
      expect(state.totalPrice, 90.0);
    });

    test('totalPrice returns 0 for empty items', () {
      const state = QuoteFormState();
      expect(state.totalPrice, 0.0);
    });

    test('copyWith creates new state with updated items', () {
      const state = QuoteFormState();
      final items = [
        const QuoteItem(description: 'Writing', amount: 100.0),
      ];

      final newState = state.copyWith(
        items: items,
        notes: 'Rush order',
        isSubmitting: true,
      );

      expect(newState.items.length, 1);
      expect(newState.notes, 'Rush order');
      expect(newState.isSubmitting, isTrue);
      expect(newState.totalPrice, 100.0);
    });

    test('copyWith with clearError clears the error', () {
      const state = QuoteFormState(error: 'Validation error');
      final newState = state.copyWith(clearError: true);
      expect(newState.error, isNull);
    });
  });
}

// Helper functions to create test models
RequestModel _createRequest(String id) {
  return RequestModel(
    id: id,
    projectNumber: 'AX-$id',
    title: 'Test Request $id',
    description: 'Test description for request $id',
    subject: 'Mathematics',
    deadline: DateTime.now().add(const Duration(days: 7)),
    status: ProjectStatus.submitted,
    clientName: 'Test Client',
    createdAt: DateTime.now(),
    userQuote: 100.0,
    userId: 'client_$id',
  );
}

DoerModel _createDoer(String id) {
  return DoerModel(
    id: id,
    profileId: 'profile_$id',
    name: 'Doer $id',
    email: 'doer$id@test.com',
    expertise: ['Essay Writing', 'Research'],
    rating: 4.5,
    completedProjects: 10,
    isAvailable: true,
  );
}

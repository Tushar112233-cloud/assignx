/// Support state management provider for the Doer App.
///
/// This file manages the support section including FAQ loading from
/// Supabase and support ticket submission.
///
/// ## Architecture
///
/// The support provider manages two main domains:
/// - **FAQs**: Frequently asked questions loaded from the `faqs` table
/// - **Support Tickets**: Ticket submission to the `support_tickets` table
///
/// ## Usage
///
/// ```dart
/// final supportState = ref.watch(supportProvider);
///
/// // Display FAQs
/// for (final faq in supportState.faqs) {
///   FaqTile(faq: faq);
/// }
///
/// // Submit a support ticket
/// await ref.read(supportProvider.notifier).submitTicket(
///   subject: 'Payment issue',
///   message: 'I have not received my payment...',
///   category: 'payments',
/// );
/// ```
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';

/// FAQ model representing a frequently asked question.
///
/// Contains the question text, answer text, and optional category.
class FAQ {
  /// Unique identifier for the FAQ.
  final String id;

  /// The question text.
  final String question;

  /// The answer text.
  final String answer;

  /// Category for grouping FAQs (e.g., "General", "Payments").
  final String category;

  /// Creates a new [FAQ] instance.
  const FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
  });

  /// Creates a [FAQ] from a JSON map.
  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id']?.toString() ?? '',
      question: json['question'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
    );
  }
}

/// Immutable state class representing support data.
///
/// Contains FAQs, loading states, and submission status.
class SupportState {
  /// List of FAQs loaded from the database.
  final List<FAQ> faqs;

  /// Whether FAQs are being loaded.
  final bool isLoadingFaqs;

  /// Whether a support ticket is being submitted.
  final bool isSubmitting;

  /// Whether the last ticket was submitted successfully.
  final bool submitSuccess;

  /// Error message from the last failed operation, null if no error.
  final String? errorMessage;

  /// Creates a new [SupportState] instance.
  const SupportState({
    this.faqs = const [],
    this.isLoadingFaqs = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with the specified fields replaced.
  SupportState copyWith({
    List<FAQ>? faqs,
    bool? isLoadingFaqs,
    bool? isSubmitting,
    bool? submitSuccess,
    String? errorMessage,
  }) {
    return SupportState(
      faqs: faqs ?? this.faqs,
      isLoadingFaqs: isLoadingFaqs ?? this.isLoadingFaqs,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier class that manages support state and operations.
///
/// Handles loading FAQs from Supabase and submitting support tickets.
class SupportNotifier extends Notifier<SupportState> {
  @override
  SupportState build() {
    Future.microtask(() => _loadFaqs());
    return const SupportState();
  }

  /// The Supabase client instance for database operations.
  SupabaseClient get _client => SupabaseConfig.client;

  /// Loads FAQs from the database.
  ///
  /// Fetches all FAQs ordered by category. Falls back to default
  /// FAQs if the database call fails.
  Future<void> _loadFaqs() async {
    state = state.copyWith(isLoadingFaqs: true, errorMessage: null);

    try {
      final response = await _client
          .from('faqs')
          .select()
          .order('category');

      final faqs = (response as List)
          .map((e) => FAQ.fromJson(e))
          .toList();

      state = state.copyWith(
        faqs: faqs,
        isLoadingFaqs: false,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SupportNotifier._loadFaqs error: $e');
      }
      state = state.copyWith(
        faqs: const [],
        isLoadingFaqs: false,
        errorMessage: 'Failed to load FAQs. Pull to refresh.',
      );
    }
  }

  /// Submits a support ticket to the database.
  ///
  /// ## Parameters
  ///
  /// - [subject]: The ticket subject line
  /// - [message]: The detailed message/description
  /// - [category]: The ticket category (defaults to 'general')
  ///
  /// ## Returns
  ///
  /// `true` if the ticket was submitted successfully, `false` otherwise.
  Future<bool> submitTicket({
    required String subject,
    required String message,
    String category = 'general',
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      submitSuccess: false,
      errorMessage: null,
    );

    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'You must be logged in to submit a ticket.',
        );
        return false;
      }

      await _client.from('support_tickets').insert({
        'requester_id': user.id,
        'subject': subject,
        'description': message,
        'category': category,
        'priority': 'medium',
        'status': 'open',
      });

      state = state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SupportNotifier.submitTicket error: $e');
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to submit ticket. Please try again.',
      );
      return false;
    }
  }

  /// Resets the submit success flag.
  void resetSubmitStatus() {
    state = state.copyWith(submitSuccess: false);
  }

  /// Refreshes FAQs from the database.
  Future<void> refresh() async {
    await _loadFaqs();
  }

}

/// The main support provider.
///
/// Use this provider to access support state and manage FAQs
/// and ticket submission.
final supportProvider = NotifierProvider<SupportNotifier, SupportState>(() {
  return SupportNotifier();
});

/// Convenience provider for accessing FAQs.
final faqsProvider = Provider<List<FAQ>>((ref) {
  return ref.watch(supportProvider).faqs;
});

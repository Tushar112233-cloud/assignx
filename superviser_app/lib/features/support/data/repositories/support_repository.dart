import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/ticket_model.dart';

/// Repository for support operations.
class SupportRepository {
  SupportRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Get current user ID.
  String? get _currentUserId => getCurrentUserId();

  /// Fetch tickets with pagination.
  Future<List<TicketModel>> getTickets({
    int limit = 20,
    int offset = 0,
    TicketStatus? status,
    TicketCategory? category,
  }) async {
    if (_currentUserId == null) return [];

    var query = _client
        .from('support_tickets')
        .select()
        .eq('requester_id', _currentUserId!);

    if (status != null) {
      query = query.eq('status', _statusToString(status));
    }

    if (category != null) {
      query = query.eq('category', category.name);
    }

    final response = await query
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => TicketModel.fromJson(json))
        .toList();
  }

  /// Get ticket by ID.
  Future<TicketModel?> getTicketById(String ticketId) async {
    final response = await _client
        .from('support_tickets')
        .select()
        .eq('id', ticketId)
        .maybeSingle();

    if (response == null) return null;
    return TicketModel.fromJson(response);
  }

  /// Create new ticket.
  Future<TicketModel> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    TicketPriority priority = TicketPriority.normal,
    List<String> attachments = const [],
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client.from('support_tickets').insert({
      'requester_id': _currentUserId!,
      'subject': subject,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'status': 'open',
      'attachments': attachments,
    }).select().single();

    return TicketModel.fromJson(response);
  }

  /// Update ticket status.
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    final updates = <String, dynamic>{
      'status': _statusToString(status),
    };

    if (status == TicketStatus.resolved) {
      updates['resolved_at'] = DateTime.now().toIso8601String();
    } else if (status == TicketStatus.closed) {
      updates['closed_at'] = DateTime.now().toIso8601String();
    }

    await _client.from('support_tickets').update(updates).eq('id', ticketId);
  }

  /// Close ticket with rating.
  Future<void> closeTicket(
    String ticketId, {
    int? rating,
    String? feedback,
  }) async {
    await _client.from('support_tickets').update({
      'status': 'closed',
      'closed_at': DateTime.now().toIso8601String(),
      if (rating != null) 'rating': rating,
      if (feedback != null) 'feedback': feedback,
    }).eq('id', ticketId);
  }

  /// Reopen ticket.
  Future<void> reopenTicket(String ticketId) async {
    await _client.from('support_tickets').update({
      'status': 'open',
      'resolved_at': null,
      'closed_at': null,
    }).eq('id', ticketId);
  }

  /// Get ticket messages.
  Future<List<TicketMessage>> getMessages(
    String ticketId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await _client
        .from('ticket_messages')
        .select()
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => TicketMessage.fromJson(json))
        .toList();
  }

  /// Send message to ticket.
  Future<TicketMessage> sendMessage(
    String ticketId,
    String message, {
    List<String> attachments = const [],
  }) async {
    if (_currentUserId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _client.from('ticket_messages').insert({
      'ticket_id': ticketId,
      'sender_id': _currentUserId!,
      'message': message,
      'attachments': attachments,
      'is_support': false,
    }).select().single();

    // Update ticket last message time
    await _client.from('support_tickets').update({
      'last_message_at': DateTime.now().toIso8601String(),
      'status': 'open', // Reopen if was waiting for reply
    }).eq('id', ticketId);

    return TicketMessage.fromJson(response);
  }

  /// Stream messages in real-time.
  Stream<List<TicketMessage>> watchMessages(String ticketId) {
    return _client
        .from('ticket_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at', ascending: true)
        .map((data) => data.map(TicketMessage.fromJson).toList());
  }

  /// Get FAQ items.
  Future<List<FAQItem>> getFAQItems({String? category}) async {
    var query = _client.from('faq').select();

    if (category != null) {
      query = query.eq('category', category);
    }

    final response = await query.order('order', ascending: true);

    return (response as List).map((json) => FAQItem.fromJson(json)).toList();
  }

  /// Get FAQ categories with items.
  Future<List<FAQCategory>> getFAQCategories() async {
    final response = await _client
        .from('faq_categories')
        .select('*, items:faq(*)')
        .order('order', ascending: true);

    return (response as List)
        .map((json) => FAQCategory.fromJson(json))
        .toList();
  }

  /// Search FAQ.
  Future<List<FAQItem>> searchFAQ(String query) async {
    final response = await _client
        .from('faq')
        .select()
        .or('question.ilike.%$query%,answer.ilike.%$query%')
        .order('order', ascending: true);

    return (response as List).map((json) => FAQItem.fromJson(json)).toList();
  }

  /// Upload attachment.
  Future<String> uploadAttachment(
    String ticketId,
    String fileName,
    List<int> fileBytes,
  ) async {
    final path = 'support/$ticketId/$fileName';
    await _client.storage.from('attachments').uploadBinary(
          path,
          Uint8List.fromList(fileBytes),
        );
    return _client.storage.from('attachments').getPublicUrl(path);
  }

  /// Get open tickets count.
  Future<int> getOpenTicketsCount() async {
    if (_currentUserId == null) return 0;

    final response = await _client
        .from('support_tickets')
        .select('id')
        .eq('requester_id', _currentUserId!)
        .inFilter('status', ['open', 'in_progress', 'waiting_for_reply']);

    return (response as List).length;
  }

  static String _statusToString(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return 'open';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.waitingForReply:
        return 'waiting_for_reply';
      case TicketStatus.resolved:
        return 'resolved';
      case TicketStatus.closed:
        return 'closed';
    }
  }
}

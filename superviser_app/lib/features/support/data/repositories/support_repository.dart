import '../../../../core/api/api_client.dart';
import '../models/ticket_model.dart';

/// Repository for support operations.
class SupportRepository {
  SupportRepository();

  /// Fetch tickets with pagination.
  Future<List<TicketModel>> getTickets({
    int limit = 20,
    int offset = 0,
    TicketStatus? status,
    TicketCategory? category,
  }) async {
    final params = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
      if (status != null) 'status': _statusToString(status),
      if (category != null) 'category': category.name,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');

    final response = await ApiClient.get('/support/tickets?$query');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['tickets'] as List? ?? [];

    return list
        .map((json) => TicketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get ticket by ID.
  Future<TicketModel?> getTicketById(String ticketId) async {
    try {
      final response = await ApiClient.get('/support/tickets/$ticketId');
      if (response == null) return null;
      return TicketModel.fromJson(response as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Create new ticket.
  Future<TicketModel> createTicket({
    required String subject,
    required String description,
    required TicketCategory category,
    TicketPriority priority = TicketPriority.normal,
    List<String> attachments = const [],
  }) async {
    final response = await ApiClient.post('/support/tickets', {
      'subject': subject,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'source_role': 'supervisor',
      'attachments': attachments,
    });

    return TicketModel.fromJson(response as Map<String, dynamic>);
  }

  /// Update ticket status.
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    await ApiClient.put('/support/tickets/$ticketId/status', {
      'status': _statusToString(status),
    });
  }

  /// Close ticket with rating.
  Future<void> closeTicket(
    String ticketId, {
    int? rating,
    String? feedback,
  }) async {
    await ApiClient.put('/support/tickets/$ticketId/close', {
      if (rating != null) 'satisfaction_rating': rating,
      if (feedback != null) 'satisfaction_feedback': feedback,
    });
  }

  /// Reopen ticket.
  Future<void> reopenTicket(String ticketId) async {
    await ApiClient.put('/support/tickets/$ticketId/reopen', {});
  }

  /// Get ticket messages.
  Future<List<TicketMessage>> getMessages(
    String ticketId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await ApiClient.get(
      '/support/tickets/$ticketId/messages?limit=$limit&offset=$offset',
    );
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['messages'] as List? ?? [];

    return list
        .map((json) => TicketMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Send message to ticket.
  Future<TicketMessage> sendMessage(
    String ticketId,
    String message, {
    List<String> attachments = const [],
  }) async {
    final response = await ApiClient.post(
      '/support/tickets/$ticketId/messages',
      {
        'message': message,
        'attachments': attachments,
        'sender_type': 'supervisor',
      },
    );

    return TicketMessage.fromJson(response as Map<String, dynamic>);
  }

  /// Stream messages in real-time.
  /// Note: Real-time messages handled via Socket.IO at provider level.
  Stream<List<TicketMessage>> watchMessages(String ticketId) {
    return Stream.value([]);
  }

  /// Get FAQ items.
  Future<List<FAQItem>> getFAQItems({String? category}) async {
    final path = category != null
        ? '/support/faqs?category=$category'
        : '/support/faqs';
    final response = await ApiClient.get(path);
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['faqs'] as List? ?? [];

    return list
        .map((json) => FAQItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get FAQ categories.
  Future<List<FAQCategory>> getFAQCategories() async {
    final response = await ApiClient.get('/support/faqs/categories');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['categories'] as List? ?? [];

    return list
        .map((json) => FAQCategory.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Search FAQ.
  Future<List<FAQItem>> searchFAQ(String query) async {
    final response = await ApiClient.get('/support/faqs?search=$query');
    final list = response is List
        ? response
        : (response as Map<String, dynamic>)['faqs'] as List? ?? [];

    return list
        .map((json) => FAQItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Upload attachment.
  Future<String> uploadAttachment(
    String ticketId,
    String fileName,
    List<int> fileBytes,
  ) async {
    // File uploads handled via ApiClient.uploadFile at the provider level
    // Return empty string as placeholder; actual upload uses multipart
    final response = await ApiClient.post('/support/tickets/$ticketId/attachments', {
      'fileName': fileName,
    });
    return (response as Map<String, dynamic>)['url'] as String? ?? '';
  }

  /// Get open tickets count.
  Future<int> getOpenTicketsCount() async {
    final response = await ApiClient.get('/support/tickets/count?status=open');
    if (response is Map<String, dynamic>) {
      return response['count'] as int? ?? 0;
    }
    return 0;
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

/// Quote model and related classes for project pricing.
///
/// This file contains:
/// - [QuoteModel]: The main data model for project price quotes
/// - [QuoteItem]: Individual line items in a quote breakdown
/// - [createDefaultQuoteItems]: Helper function for generating default pricing
///
/// The models map to the `project_quotes` table in Supabase and handle
/// the pricing structure including fees, discounts, and payment splits.
library;

/// A data model representing a price quote for a project.
///
/// This model encapsulates all pricing information for a project quote,
/// including the total price, fee breakdown, and payment distribution
/// between doer, supervisor, and platform. It maps to the `project_quotes`
/// table in Supabase.
///
/// ## Usage
///
/// ```dart
/// final quote = QuoteModel(
///   requestId: 'project-123',
///   totalPrice: 150.00,
///   doerAmount: 100.00,
///   supervisorAmount: 35.00,
///   platformAmount: 15.00,
/// );
/// print(quote.totalPrice); // 150.00
/// ```
///
/// ## Database Mapping
///
/// Field mappings:
/// - `totalPrice` -> `user_amount`
/// - `requestId` -> `project_id`
/// - Other fields map directly with snake_case conversion
///
/// See also:
/// - [QuoteItem] for line item details
/// - [RequestModel] for the project being quoted
/// - [createDefaultQuoteItems] for generating default pricing
class QuoteModel {
  /// Creates a new [QuoteModel] instance.
  ///
  /// Required fields are [requestId] and [totalPrice].
  /// Other fields have sensible defaults for a new quote.
  const QuoteModel({
    this.id,
    required this.requestId,
    required this.totalPrice,
    this.doerAmount,
    this.supervisorAmount,
    this.platformAmount,
    this.basePrice,
    this.urgencyFee,
    this.complexityFee,
    this.discountAmount,
    this.discountCode,
    this.status = 'pending',
    this.validUntil,
    this.createdAt,
    this.breakdown = const [],
  });

  /// Unique identifier for this quote.
  ///
  /// Primary key from `project_quotes.id` (UUID format).
  /// May be null for new quotes not yet saved.
  final String? id;

  /// The ID of the project this quote is for.
  ///
  /// References `projects.id` via `project_quotes.project_id`.
  final String requestId;

  /// Total price quoted to the user/client in USD.
  ///
  /// This is the final amount the client will pay.
  /// Stored in `project_quotes.user_amount`.
  final double totalPrice;

  /// Amount allocated to the doer in USD.
  ///
  /// The doer's payment for completing the project.
  /// Stored in `project_quotes.doer_amount`.
  final double? doerAmount;

  /// Amount allocated to the supervisor in USD.
  ///
  /// The supervisor's commission for managing the project.
  /// Stored in `project_quotes.supervisor_amount`.
  final double? supervisorAmount;

  /// Amount allocated to the platform in USD.
  ///
  /// The platform's service fee.
  /// Stored in `project_quotes.platform_amount`.
  final double? platformAmount;

  /// Base price before any fees or adjustments.
  ///
  /// The starting price before urgency, complexity, or discounts.
  /// Stored in `project_quotes.base_price`.
  final double? basePrice;

  /// Additional fee for urgent delivery.
  ///
  /// Applied when the deadline requires expedited work.
  /// Stored in `project_quotes.urgency_fee`.
  final double? urgencyFee;

  /// Additional fee for complex projects.
  ///
  /// Applied when the project requires specialized skills or extra effort.
  /// Stored in `project_quotes.complexity_fee`.
  final double? complexityFee;

  /// Discount amount applied to the quote.
  ///
  /// Subtracted from the total. Stored in `project_quotes.discount_amount`.
  final double? discountAmount;

  /// Discount code used for this quote.
  ///
  /// The promotional code applied, if any.
  /// Stored in `project_quotes.discount_code`.
  final String? discountCode;

  /// Current status of the quote.
  ///
  /// Possible values: "pending", "sent", "accepted", "rejected", "expired".
  /// Defaults to "pending" for new quotes.
  final String status;

  /// Date/time until which this quote is valid.
  ///
  /// After this date, the quote may need to be revised.
  /// Stored in `project_quotes.valid_until`.
  final DateTime? validUntil;

  /// When this quote was created.
  ///
  /// Stored in `project_quotes.created_at`.
  final DateTime? createdAt;

  /// Itemized breakdown of the quote.
  ///
  /// List of [QuoteItem]s that make up the total price.
  /// Used for display purposes; not stored in database directly.
  final List<QuoteItem> breakdown;

  /// Calculates the total from the breakdown items.
  ///
  /// Sums all [QuoteItem.amount] values in [breakdown].
  /// Useful for verifying the breakdown matches [totalPrice].
  ///
  /// Returns the sum of all item amounts.
  double get calculatedTotal => breakdown.fold(0.0, (sum, item) => sum + item.amount);

  /// Creates a [QuoteModel] from Supabase project_quotes JSON response.
  ///
  /// Maps database fields to model properties:
  /// - `user_amount` -> `totalPrice`
  /// - `project_id` -> `requestId`
  ///
  /// Note: The [breakdown] list is not populated from JSON as it's
  /// typically stored separately or computed.
  ///
  /// Throws [FormatException] if required fields are missing or malformed.
  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: (json['id'] ?? json['_id'])?.toString(),
      requestId: (json['projectId'] ?? json['project_id'] ?? '').toString(),
      totalPrice: ((json['userAmount'] ?? json['user_amount'] ?? json['totalPrice'] ?? 0) as num).toDouble(),
      doerAmount: ((json['doerAmount'] ?? json['doer_amount']) as num?)?.toDouble(),
      supervisorAmount: ((json['supervisorAmount'] ?? json['supervisor_amount']) as num?)?.toDouble(),
      platformAmount: ((json['platformAmount'] ?? json['platform_amount']) as num?)?.toDouble(),
      basePrice: ((json['basePrice'] ?? json['base_price']) as num?)?.toDouble(),
      urgencyFee: ((json['urgencyFee'] ?? json['urgency_fee']) as num?)?.toDouble(),
      complexityFee: ((json['complexityFee'] ?? json['complexity_fee']) as num?)?.toDouble(),
      discountAmount: ((json['discountAmount'] ?? json['discount_amount']) as num?)?.toDouble(),
      discountCode: (json['discountCode'] ?? json['discount_code']) as String?,
      status: json['status'] as String? ?? 'pending',
      validUntil: _tryParseDate(json['validUntil'] ?? json['valid_until']),
      createdAt: _tryParseDate(json['createdAt'] ?? json['created_at']),
    );
  }

  /// Safely parse a DateTime from dynamic value.
  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  /// Converts this [QuoteModel] to a JSON map for Supabase operations.
  ///
  /// Returns a [Map] suitable for INSERT or UPDATE operations on the
  /// `project_quotes` table.
  ///
  /// Note: The [breakdown] list is not included in the JSON output
  /// as it's typically handled separately.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'project_id': requestId,
      'user_amount': totalPrice,
      'doer_amount': doerAmount ?? 0,
      'supervisor_amount': supervisorAmount ?? 0,
      'platform_amount': platformAmount ?? 0,
      'base_price': basePrice,
      'urgency_fee': urgencyFee ?? 0,
      'complexity_fee': complexityFee ?? 0,
      'discount_amount': discountAmount ?? 0,
      'discount_code': discountCode,
      'status': status,
      'valid_until': validUntil?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [QuoteModel] with the specified fields replaced.
  ///
  /// All parameters are optional. If not provided, the current value is retained.
  ///
  /// Returns a new [QuoteModel] instance with the updated values.
  QuoteModel copyWith({
    String? id,
    String? requestId,
    double? totalPrice,
    double? doerAmount,
    double? supervisorAmount,
    double? platformAmount,
    double? basePrice,
    double? urgencyFee,
    double? complexityFee,
    double? discountAmount,
    String? discountCode,
    String? status,
    DateTime? validUntil,
    DateTime? createdAt,
    List<QuoteItem>? breakdown,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      totalPrice: totalPrice ?? this.totalPrice,
      doerAmount: doerAmount ?? this.doerAmount,
      supervisorAmount: supervisorAmount ?? this.supervisorAmount,
      platformAmount: platformAmount ?? this.platformAmount,
      basePrice: basePrice ?? this.basePrice,
      urgencyFee: urgencyFee ?? this.urgencyFee,
      complexityFee: complexityFee ?? this.complexityFee,
      discountAmount: discountAmount ?? this.discountAmount,
      discountCode: discountCode ?? this.discountCode,
      status: status ?? this.status,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
      breakdown: breakdown ?? this.breakdown,
    );
  }
}

/// A single line item in a quote breakdown.
///
/// Represents one component of the total quote price, such as
/// "Writing (2000 words)" or "Platform fee (10%)".
///
/// ## Usage
///
/// ```dart
/// final item = QuoteItem(
///   description: 'Writing (2000 words)',
///   amount: 100.00,
///   quantity: 2000,
///   unitPrice: 0.05,
/// );
/// print(item.description); // "Writing (2000 words)"
/// print(item.amount); // 100.00
/// ```
///
/// See also:
/// - [QuoteModel.breakdown] for the list of items in a quote
/// - [createDefaultQuoteItems] for generating standard items
class QuoteItem {
  /// Creates a new [QuoteItem] instance.
  ///
  /// Required fields are [description] and [amount].
  /// [quantity] defaults to 1, [unitPrice] is optional.
  const QuoteItem({
    required this.description,
    required this.amount,
    this.quantity = 1,
    this.unitPrice,
  });

  /// Description of this line item.
  ///
  /// Human-readable text explaining what this charge is for.
  /// Example: "Writing (2000 words)", "Platform fee (10%)"
  final String description;

  /// Total amount for this line item in USD.
  ///
  /// If [quantity] > 1 and [unitPrice] is set, this should equal
  /// `quantity * unitPrice`.
  final double amount;

  /// Quantity of units for this item.
  ///
  /// Used for per-unit pricing (e.g., words, pages).
  /// Defaults to 1 for flat-rate items.
  final int quantity;

  /// Price per unit in USD.
  ///
  /// Only applicable when [quantity] > 1.
  /// Example: 4.0 for ₹4.00 per word.
  final double? unitPrice;

  /// Creates a [QuoteItem] from JSON.
  ///
  /// Used when deserializing quote breakdowns from storage.
  factory QuoteItem.fromJson(Map<String, dynamic> json) {
    return QuoteItem(
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
    );
  }

  /// Converts this [QuoteItem] to a JSON map.
  ///
  /// Returns a [Map] suitable for JSON serialization.
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'unit_price': unitPrice,
    };
  }
}

/// Creates a list of default quote items based on project requirements.
///
/// Generates standard pricing items including:
/// - Word count charges (if [wordCount] is provided)
/// - Page count charges (if [pageCount] is provided)
/// - Platform fee (10% of subtotal)
///
/// ## Parameters
///
/// - [wordCount]: Number of words required (optional)
/// - [pageCount]: Number of pages required (optional)
/// - [ratePerWord]: Rate per word in INR (default: ₹4.00)
/// - [ratePerPage]: Rate per page in INR (default: ₹4,000.00)
///
/// ## Returns
///
/// A [List] of [QuoteItem]s representing the quote breakdown.
///
/// ## Example
///
/// ```dart
/// final items = createDefaultQuoteItems(
///   wordCount: 2000,
///   ratePerWord: 0.05,
/// );
/// // Returns:
/// // - QuoteItem: "Writing (2000 words)" - $100.00
/// // - QuoteItem: "Platform fee (10%)" - $10.00
/// ```
///
/// See also:
/// - [QuoteItem] for the structure of each item
/// - [QuoteModel.breakdown] for using the items in a quote
List<QuoteItem> createDefaultQuoteItems({
  int? wordCount,
  int? pageCount,
  double ratePerWord = 4.0,
  double ratePerPage = 4000.0,
}) {
  final items = <QuoteItem>[];

  if (wordCount != null && wordCount > 0) {
    items.add(QuoteItem(
      description: 'Writing ($wordCount words)',
      amount: wordCount * ratePerWord,
      quantity: wordCount,
      unitPrice: ratePerWord,
    ));
  }

  if (pageCount != null && pageCount > 0) {
    items.add(QuoteItem(
      description: 'Pages ($pageCount pages)',
      amount: pageCount * ratePerPage,
      quantity: pageCount,
      unitPrice: ratePerPage,
    ));
  }

  // Add platform fee
  final subtotal = items.fold(0.0, (sum, item) => sum + item.amount);
  items.add(QuoteItem(
    description: 'Platform fee (10%)',
    amount: subtotal * 0.10,
  ));

  return items;
}

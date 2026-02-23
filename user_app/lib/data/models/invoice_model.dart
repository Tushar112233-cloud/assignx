import '../models/project.dart';
import '../models/service_type.dart';
import '../models/user_profile.dart';

/// Invoice model for PDF generation.
///
/// This model contains all the data needed to generate an invoice PDF.
/// It can be created from API response or constructed from project and profile data.
///
/// ## Usage
///
/// ```dart
/// // From project and profile
/// final invoice = InvoiceModel.fromProjectAndProfile(project, profile);
///
/// // From API response
/// final invoice = InvoiceModel.fromJson(response);
/// ```
class InvoiceModel {
  /// Unique invoice number (e.g., INV-2024-001234).
  final String invoiceNumber;

  /// Associated project number (e.g., AX-2024-001).
  final String projectNumber;

  /// Project ID for reference.
  final String projectId;

  /// Project title.
  final String projectTitle;

  /// Service type display name.
  final String serviceType;

  /// Subject name if available.
  final String? subjectName;

  /// Word count if applicable.
  final int? wordCount;

  /// Page count if applicable.
  final int? pageCount;

  /// Invoice creation date.
  final DateTime invoiceDate;

  /// Project creation date.
  final DateTime projectDate;

  /// Payment due date.
  final DateTime dueDate;

  /// Date when payment was received.
  final DateTime? paidAt;

  /// Customer full name.
  final String customerName;

  /// Customer email address.
  final String customerEmail;

  /// Customer phone number.
  final String? customerPhone;

  /// Base service amount (before fees and taxes).
  final double subtotal;

  /// Platform fee amount.
  final double? platformFee;

  /// GST amount (18%).
  final double gst;

  /// Total amount including all fees and taxes.
  final double totalAmount;

  /// Payment method used (e.g., UPI, Card, Wallet).
  final String paymentMethod;

  /// Payment transaction ID.
  final String? transactionId;

  /// Payment status (paid, pending, failed).
  final String paymentStatus;

  /// Project description if available.
  final String? description;

  /// Creates a new [InvoiceModel].
  const InvoiceModel({
    required this.invoiceNumber,
    required this.projectNumber,
    required this.projectId,
    required this.projectTitle,
    required this.serviceType,
    this.subjectName,
    this.wordCount,
    this.pageCount,
    required this.invoiceDate,
    required this.projectDate,
    required this.dueDate,
    this.paidAt,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.subtotal,
    this.platformFee,
    required this.gst,
    required this.totalAmount,
    required this.paymentMethod,
    this.transactionId,
    required this.paymentStatus,
    this.description,
  });

  /// Whether the invoice has been paid.
  bool get isPaid => paymentStatus.toLowerCase() == 'paid';

  /// Whether the invoice is pending payment.
  bool get isPending => paymentStatus.toLowerCase() == 'pending';

  /// Formatted subtotal with currency symbol.
  String get formattedSubtotal => _formatCurrency(subtotal);

  /// Formatted GST amount with currency symbol.
  String get formattedGst => _formatCurrency(gst);

  /// Formatted total amount with currency symbol.
  String get formattedTotal => _formatCurrency(totalAmount);

  /// Formatted platform fee with currency symbol.
  String? get formattedPlatformFee =>
      platformFee != null ? _formatCurrency(platformFee!) : null;

  /// Helper method to format currency.
  static String _formatCurrency(double amount) {
    return '\u20B9${amount.toStringAsFixed(2)}';
  }

  /// Creates an [InvoiceModel] from a project and user profile.
  ///
  /// This is the primary way to create an invoice when generating
  /// from local project data.
  factory InvoiceModel.fromProjectAndProfile(
    Project project,
    UserProfile profile,
  ) {
    // Calculate amounts
    final baseAmount = project.userQuote ?? 999.0;
    final platformFeeAmount = project.platformFee;
    final gstAmount = baseAmount * 0.18; // 18% GST
    final totalAmountValue = baseAmount + gstAmount + (platformFeeAmount ?? 0);

    // Generate invoice number from project number
    final invoiceNumber = 'INV-${project.projectNumber.replaceAll('AX-', '')}';

    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      projectNumber: project.projectNumber,
      projectId: project.id,
      projectTitle: project.title,
      serviceType: project.serviceType.displayName,
      subjectName: project.subjectName,
      wordCount: project.wordCount,
      pageCount: project.pageCount,
      invoiceDate: project.paidAt ?? DateTime.now(),
      projectDate: project.createdAt,
      dueDate: project.paidAt ?? project.createdAt.add(const Duration(days: 7)),
      paidAt: project.paidAt,
      customerName: profile.displayName,
      customerEmail: profile.email,
      customerPhone: profile.phone,
      subtotal: baseAmount,
      platformFee: platformFeeAmount,
      gst: gstAmount,
      totalAmount: totalAmountValue,
      paymentMethod: _determinePaymentMethod(project),
      transactionId: project.paymentId,
      paymentStatus: project.isPaid ? 'paid' : 'pending',
      description: project.description,
    );
  }

  /// Determines the payment method from project data.
  static String _determinePaymentMethod(Project project) {
    if (project.paymentId == null) return 'Pending';

    // Try to determine from payment ID prefix
    final paymentId = project.paymentId!.toLowerCase();
    if (paymentId.startsWith('pay_')) return 'Razorpay';
    if (paymentId.contains('upi')) return 'UPI';
    if (paymentId.contains('wallet')) return 'Wallet';

    return 'Online Payment';
  }

  /// Creates an [InvoiceModel] from JSON data.
  ///
  /// Use this when fetching invoice data from an API endpoint.
  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      invoiceNumber: json['invoice_number'] as String? ?? '',
      projectNumber: json['project_number'] as String? ?? '',
      projectId: json['project_id'] as String? ?? '',
      projectTitle: json['project_title'] as String? ?? '',
      serviceType: json['service_type'] as String? ?? 'Project Service',
      subjectName: json['subject_name'] as String?,
      wordCount: json['word_count'] as int?,
      pageCount: json['page_count'] as int?,
      invoiceDate: json['invoice_date'] != null
          ? DateTime.parse(json['invoice_date'] as String)
          : DateTime.now(),
      projectDate: json['project_date'] != null
          ? DateTime.parse(json['project_date'] as String)
          : DateTime.now(),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now(),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      customerName: json['customer_name'] as String? ?? 'Customer',
      customerEmail: json['customer_email'] as String? ?? '',
      customerPhone: json['customer_phone'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble(),
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] as String? ?? 'Unknown',
      transactionId: json['transaction_id'] as String?,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      description: json['description'] as String?,
    );
  }

  /// Converts this invoice to JSON.
  Map<String, dynamic> toJson() {
    return {
      'invoice_number': invoiceNumber,
      'project_number': projectNumber,
      'project_id': projectId,
      'project_title': projectTitle,
      'service_type': serviceType,
      'subject_name': subjectName,
      'word_count': wordCount,
      'page_count': pageCount,
      'invoice_date': invoiceDate.toIso8601String(),
      'project_date': projectDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'subtotal': subtotal,
      'platform_fee': platformFee,
      'gst': gst,
      'total_amount': totalAmount,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'payment_status': paymentStatus,
      'description': description,
    };
  }

  /// Creates a copy with modified fields.
  InvoiceModel copyWith({
    String? invoiceNumber,
    String? projectNumber,
    String? projectId,
    String? projectTitle,
    String? serviceType,
    String? subjectName,
    int? wordCount,
    int? pageCount,
    DateTime? invoiceDate,
    DateTime? projectDate,
    DateTime? dueDate,
    DateTime? paidAt,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    double? subtotal,
    double? platformFee,
    double? gst,
    double? totalAmount,
    String? paymentMethod,
    String? transactionId,
    String? paymentStatus,
    String? description,
  }) {
    return InvoiceModel(
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      projectNumber: projectNumber ?? this.projectNumber,
      projectId: projectId ?? this.projectId,
      projectTitle: projectTitle ?? this.projectTitle,
      serviceType: serviceType ?? this.serviceType,
      subjectName: subjectName ?? this.subjectName,
      wordCount: wordCount ?? this.wordCount,
      pageCount: pageCount ?? this.pageCount,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      projectDate: projectDate ?? this.projectDate,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      subtotal: subtotal ?? this.subtotal,
      platformFee: platformFee ?? this.platformFee,
      gst: gst ?? this.gst,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      transactionId: transactionId ?? this.transactionId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'InvoiceModel(invoiceNumber: $invoiceNumber, '
        'projectNumber: $projectNumber, '
        'totalAmount: $formattedTotal, '
        'status: $paymentStatus)';
  }
}

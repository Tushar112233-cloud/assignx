import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/invoice_model.dart';
import '../../data/models/project.dart';
import '../../data/models/user_profile.dart';

/// Invoice data model for backward compatibility.
///
/// @deprecated Use [InvoiceModel] instead.
class InvoiceData {
  final String invoiceNumber;
  final String projectNumber;
  final String projectTitle;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final double amount;
  final double? platformFee;
  final double? gst;
  final double totalAmount;
  final String paymentMethod;
  final String? transactionId;
  final String status;

  InvoiceData({
    required this.invoiceNumber,
    required this.projectNumber,
    required this.projectTitle,
    required this.createdAt,
    this.paidAt,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.amount,
    this.platformFee,
    this.gst,
    required this.totalAmount,
    required this.paymentMethod,
    this.transactionId,
    required this.status,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceNumber: json['invoice_number'] ?? '',
      projectNumber: json['project_number'] ?? '',
      projectTitle: json['project_title'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'],
      amount: (json['amount'] ?? 0).toDouble(),
      platformFee: json['platform_fee']?.toDouble(),
      gst: json['gst']?.toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      paymentMethod: json['payment_method'] ?? 'Unknown',
      transactionId: json['transaction_id'],
      status: json['status'] ?? 'pending',
    );
  }

  /// Convert to new InvoiceModel format.
  InvoiceModel toInvoiceModel() {
    return InvoiceModel(
      invoiceNumber: invoiceNumber,
      projectNumber: projectNumber,
      projectId: '',
      projectTitle: projectTitle,
      serviceType: 'Project Service',
      invoiceDate: createdAt,
      projectDate: createdAt,
      dueDate: createdAt,
      paidAt: paidAt,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      subtotal: amount,
      platformFee: platformFee,
      gst: gst ?? (amount * 0.18),
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paymentStatus: status,
    );
  }
}

/// Invoice Service for generating and managing PDF invoices.
///
/// This service handles:
/// - Fetching invoice data from project and profile
/// - Generating professional PDF invoices
/// - Downloading PDFs to device storage
/// - Sharing invoices via share_plus
///
/// ## Features
///
/// - Company branding with AssignX logo
/// - Invoice number and dates
/// - Customer details (name, email, phone)
/// - Project details (title, service type, description)
/// - Price breakdown (subtotal, GST 18%, platform fee, total)
/// - Payment status indicator
///
/// Implements U37 from feature specification.
class InvoiceService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Brand colors
  static const PdfColor _primaryColor = PdfColor.fromInt(0xFF4F46E5); // Indigo
  static const PdfColor _successColor = PdfColor.fromInt(0xFF10B981); // Green
  // ignore: unused_field - kept for potential future use
  // static const PdfColor _warningColor = PdfColor.fromInt(0xFFF59E0B); // Amber

  // Date formatter
  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');

  /// Fetches invoice data for a project.
  ///
  /// Combines project data with user profile to create a complete invoice.
  static Future<InvoiceModel?> getInvoiceForProject(String projectId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Fetch project with subject info
      final projectResponse = await _supabase
          .from('projects')
          .select('*, subjects(name)')
          .eq('id', projectId)
          .eq('user_id', userId)
          .single();

      final project = Project.fromJson(projectResponse);

      // Fetch user profile
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      final profile = UserProfile.fromJson(profileResponse);

      // Create invoice from project and profile
      return InvoiceModel.fromProjectAndProfile(project, profile);
    } catch (e) {
      debugPrint('Error fetching invoice data: $e');
      return null;
    }
  }

  /// Generates a PDF invoice document.
  ///
  /// Creates a professional-looking invoice with:
  /// - Company header and branding
  /// - Invoice details (number, dates)
  /// - Customer information
  /// - Project details
  /// - Itemized pricing with GST
  /// - Payment information
  static Future<File> generateInvoicePdf(InvoiceModel invoice) async {
    final pdf = pw.Document(
      title: 'Invoice ${invoice.invoiceNumber}',
      author: 'AssignX',
      subject: 'Invoice for ${invoice.projectTitle}',
      creator: 'AssignX Mobile App',
    );

    // Try to load custom font (fallback to default if not available)
    pw.Font? regularFont;
    pw.Font? boldFont;
    try {
      final regularData = await rootBundle.load('assets/fonts/Inter-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Inter-Bold.ttf');
      regularFont = pw.Font.ttf(regularData);
      boldFont = pw.Font.ttf(boldData);
    } catch (e) {
      debugPrint('Custom fonts not available, using defaults');
    }

    final baseStyle = regularFont != null
        ? pw.TextStyle(font: regularFont)
        : const pw.TextStyle();
    final boldStyle = boldFont != null
        ? pw.TextStyle(font: boldFont, fontWeight: pw.FontWeight.bold)
        : pw.TextStyle(fontWeight: pw.FontWeight.bold);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header with Logo and Invoice title
            _buildHeader(invoice, boldStyle),
            pw.SizedBox(height: 30),

            // Invoice details row
            _buildInvoiceDetailsRow(invoice, baseStyle, boldStyle),
            pw.SizedBox(height: 24),

            // Bill To section
            _buildBillToSection(invoice, baseStyle, boldStyle),
            pw.SizedBox(height: 24),

            // Project Details Table
            _buildProjectDetailsTable(invoice, baseStyle, boldStyle),
            pw.SizedBox(height: 24),

            // Amount breakdown
            _buildAmountBreakdown(invoice, baseStyle, boldStyle),
            pw.SizedBox(height: 24),

            // Payment Information (if paid)
            if (invoice.isPaid) ...[
              _buildPaymentInfoSection(invoice, baseStyle, boldStyle),
              pw.SizedBox(height: 24),
            ],

            // Spacer
            pw.Spacer(),

            // Footer
            _buildFooter(baseStyle),
          ],
        ),
      ),
    );

    // Save to temp directory
    final directory = await getTemporaryDirectory();
    final sanitizedNumber = invoice.invoiceNumber.replaceAll(RegExp(r'[^\w-]'), '_');
    final file = File('${directory.path}/Invoice_$sanitizedNumber.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  /// Builds the header section with logo and status badge.
  static pw.Widget _buildHeader(InvoiceModel invoice, pw.TextStyle boldStyle) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo and Company Name
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'AssignX',
              style: boldStyle.copyWith(
                fontSize: 32,
                color: _primaryColor,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Academic Excellence Platform',
              style: const pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        // Invoice Title and Status
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'INVOICE',
              style: boldStyle.copyWith(fontSize: 24),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              invoice.invoiceNumber,
              style: const pw.TextStyle(
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 8),
            // Status Badge
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                color: invoice.isPaid
                    ? const PdfColor.fromInt(0xFFD1FAE5)
                    : const PdfColor.fromInt(0xFFFEF3C7),
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Text(
                invoice.paymentStatus.toUpperCase(),
                style: boldStyle.copyWith(
                  fontSize: 10,
                  color: invoice.isPaid
                      ? const PdfColor.fromInt(0xFF065F46)
                      : const PdfColor.fromInt(0xFF92400E),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the invoice details row (dates).
  static pw.Widget _buildInvoiceDetailsRow(
    InvoiceModel invoice,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF9FAFB),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _buildDetailColumn(
            'Invoice Date',
            _dateFormat.format(invoice.invoiceDate),
            baseStyle,
            boldStyle,
          ),
          _buildDetailColumn(
            'Project Date',
            _dateFormat.format(invoice.projectDate),
            baseStyle,
            boldStyle,
          ),
          _buildDetailColumn(
            'Due Date',
            _dateFormat.format(invoice.dueDate),
            baseStyle,
            boldStyle,
          ),
        ],
      ),
    );
  }

  /// Builds a detail column for the invoice details row.
  static pw.Widget _buildDetailColumn(
    String label,
    String value,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label.toUpperCase(),
          style: baseStyle.copyWith(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: boldStyle.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  /// Builds the Bill To section.
  static pw.Widget _buildBillToSection(
    InvoiceModel invoice,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'BILL TO',
          style: boldStyle.copyWith(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          invoice.customerName,
          style: boldStyle.copyWith(fontSize: 14),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          invoice.customerEmail,
          style: baseStyle.copyWith(
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
        if (invoice.customerPhone != null) ...[
          pw.SizedBox(height: 2),
          pw.Text(
            invoice.customerPhone!,
            style: baseStyle.copyWith(
              fontSize: 12,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the project details table.
  static pw.Widget _buildProjectDetailsTable(
    InvoiceModel invoice,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Table Header
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF3F4F6),
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    'DESCRIPTION',
                    style: boldStyle.copyWith(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'DETAILS',
                    style: boldStyle.copyWith(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'AMOUNT',
                    style: boldStyle.copyWith(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          // Table Row
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        invoice.projectTitle,
                        style: boldStyle.copyWith(fontSize: 12),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        invoice.serviceType.toUpperCase(),
                        style: baseStyle.copyWith(
                          fontSize: 10,
                          color: _primaryColor,
                        ),
                      ),
                      if (invoice.description != null) ...[
                        pw.SizedBox(height: 4),
                        pw.Text(
                          invoice.description!.length > 100
                              ? '${invoice.description!.substring(0, 100)}...'
                              : invoice.description!,
                          style: baseStyle.copyWith(
                            fontSize: 9,
                            color: PdfColors.grey600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (invoice.wordCount != null)
                        pw.Text(
                          '${invoice.wordCount!.toString()} words',
                          style: baseStyle.copyWith(fontSize: 11),
                        ),
                      if (invoice.pageCount != null)
                        pw.Text(
                          '${invoice.pageCount!.toString()} pages',
                          style: baseStyle.copyWith(fontSize: 11),
                        ),
                      if (invoice.subjectName != null)
                        pw.Text(
                          invoice.subjectName!,
                          style: baseStyle.copyWith(
                            fontSize: 11,
                            color: PdfColors.grey600,
                          ),
                        ),
                      pw.Text(
                        '#${invoice.projectNumber}',
                        style: baseStyle.copyWith(
                          fontSize: 10,
                          color: PdfColors.grey500,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    invoice.formattedSubtotal,
                    style: boldStyle.copyWith(fontSize: 12),
                    textAlign: pw.TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the amount breakdown section.
  static pw.Widget _buildAmountBreakdown(
    InvoiceModel invoice,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        child: pw.Column(
          children: [
            _buildAmountRow('Subtotal', invoice.formattedSubtotal, baseStyle),
            if (invoice.platformFee != null && invoice.platformFee! > 0)
              _buildAmountRow(
                'Platform Fee',
                invoice.formattedPlatformFee!,
                baseStyle,
              ),
            _buildAmountRow('GST (18%)', invoice.formattedGst, baseStyle),
            pw.Divider(color: PdfColors.grey300, thickness: 1),
            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Amount',
                  style: boldStyle.copyWith(fontSize: 14),
                ),
                pw.Text(
                  invoice.formattedTotal,
                  style: boldStyle.copyWith(
                    fontSize: 16,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single amount row.
  static pw.Widget _buildAmountRow(
    String label,
    String amount,
    pw.TextStyle baseStyle,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: baseStyle.copyWith(
              fontSize: 11,
              color: PdfColors.grey600,
            ),
          ),
          pw.Text(
            amount,
            style: baseStyle.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Builds the payment information section.
  static pw.Widget _buildPaymentInfoSection(
    InvoiceModel invoice,
    pw.TextStyle baseStyle,
    pw.TextStyle boldStyle,
  ) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFECFDF5),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFA7F3D0)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 8,
                height: 8,
                decoration: const pw.BoxDecoration(
                  color: _successColor,
                  shape: pw.BoxShape.circle,
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Text(
                'PAYMENT RECEIVED',
                style: boldStyle.copyWith(
                  fontSize: 10,
                  color: _successColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          _buildPaymentDetailRow('Payment Method', invoice.paymentMethod, baseStyle),
          if (invoice.paidAt != null)
            _buildPaymentDetailRow(
              'Paid On',
              _dateTimeFormat.format(invoice.paidAt!),
              baseStyle,
            ),
          if (invoice.transactionId != null)
            _buildPaymentDetailRow(
              'Transaction ID',
              invoice.transactionId!,
              baseStyle,
            ),
        ],
      ),
    );
  }

  /// Builds a payment detail row.
  static pw.Widget _buildPaymentDetailRow(
    String label,
    String value,
    pw.TextStyle baseStyle,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text(
              label,
              style: baseStyle.copyWith(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: baseStyle.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the footer section.
  static pw.Widget _buildFooter(pw.TextStyle baseStyle) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 16),
        pw.Center(
          child: pw.Column(
            children: [
              pw.Text(
                'Thank you for choosing AssignX!',
                style: baseStyle.copyWith(
                  fontSize: 12,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'For queries, contact support@assignx.com',
                style: baseStyle.copyWith(
                  fontSize: 10,
                  color: PdfColors.grey500,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'www.assignx.com',
                style: baseStyle.copyWith(
                  fontSize: 10,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== Public API Methods ====================

  /// Downloads and opens an invoice PDF.
  ///
  /// Generates the PDF and opens it with the default PDF viewer.
  static Future<void> downloadInvoice(
    BuildContext context,
    InvoiceData invoice,
  ) async {
    try {
      final invoiceModel = invoice.toInvoiceModel();
      final file = await generateInvoicePdf(invoiceModel);
      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Downloads and opens an invoice PDF from InvoiceModel.
  static Future<void> downloadInvoiceFromModel(
    BuildContext context,
    InvoiceModel invoice,
  ) async {
    try {
      final file = await generateInvoicePdf(invoice);
      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate invoice: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Shares an invoice PDF.
  ///
  /// Generates the PDF and opens the share dialog.
  static Future<void> shareInvoice(InvoiceData invoice) async {
    try {
      final invoiceModel = invoice.toInvoiceModel();
      final file = await generateInvoicePdf(invoiceModel);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice ${invoice.invoiceNumber} from AssignX',
        subject: 'AssignX Invoice',
      );
    } catch (e) {
      debugPrint('Failed to share invoice: $e');
    }
  }

  /// Shares an invoice PDF from InvoiceModel.
  static Future<void> shareInvoiceFromModel(InvoiceModel invoice) async {
    try {
      final file = await generateInvoicePdf(invoice);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Invoice ${invoice.invoiceNumber} from AssignX',
        subject: 'AssignX Invoice',
      );
    } catch (e) {
      debugPrint('Failed to share invoice: $e');
    }
  }

  /// Saves an invoice PDF to the device's download directory.
  ///
  /// Returns the file path if successful, null otherwise.
  static Future<String?> saveInvoiceToDevice(InvoiceModel invoice) async {
    try {
      final file = await generateInvoicePdf(invoice);

      // Try to get the downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        // On Android, use external storage downloads
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // On iOS, use documents directory
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        debugPrint('Could not find downloads directory');
        return null;
      }

      // Create AssignX folder if it doesn't exist
      final assignxDir = Directory('${downloadsDir.path}/AssignX');
      if (!await assignxDir.exists()) {
        await assignxDir.create(recursive: true);
      }

      // Copy file to downloads
      final sanitizedNumber = invoice.invoiceNumber.replaceAll(RegExp(r'[^\w-]'), '_');
      final destPath = '${assignxDir.path}/Invoice_$sanitizedNumber.pdf';
      final destFile = await file.copy(destPath);

      return destFile.path;
    } catch (e) {
      debugPrint('Failed to save invoice to device: $e');
      return null;
    }
  }

}

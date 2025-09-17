import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/bill.dart';
import '../models/user.dart';

/// Service for generating PDF bills
class PDFService {
  /// Generate and preview a bill PDF
  static Future<void> generateAndPreviewBill(Bill bill, {AppUser? user}) async {
    final pdf = await _generateBillPDF(bill, user: user);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Generate and save a bill PDF
  static Future<void> generateAndSaveBill(Bill bill, {AppUser? user}) async {
    final pdf = await _generateBillPDF(bill, user: user);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bill_${bill.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Generate PDF document for the bill
  static Future<pw.Document> _generateBillPDF(Bill bill, {AppUser? user}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Professional Header
              _buildProfessionalHeader(bill, user),
              pw.SizedBox(height: 20),

              // Bill Details
              _buildBillDetails(bill),
              pw.SizedBox(height: 20),

              // Customer Information
              _buildCustomerSection(bill),
              pw.SizedBox(height: 20),

              // Items Table
              _buildProfessionalItemsTable(bill),
              pw.SizedBox(height: 20),

              // Totals Section
              _buildProfessionalTotals(bill),
              pw.SizedBox(height: 30),

              // Footer
              _buildProfessionalFooter(bill, user),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Build professional header section
  static pw.Widget _buildProfessionalHeader(Bill bill, AppUser? user) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue900,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Shop Name and Logo Area
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                user?.shopName?.toUpperCase() ?? 'INVENTORY MANAGER',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          
          // Shop Details
          if (user != null) ...[
            pw.Text(
              user.displayName,
              style: pw.TextStyle(
                fontSize: 16,
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (user.phoneNumber != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                'Phone: ${user.phoneNumber}',
                style: pw.TextStyle(
                  fontSize: 14,
                  color: PdfColors.white,
                ),
              ),
            ],
            if (user.address != null) ...[
              pw.SizedBox(height: 4),
              pw.Text(
                user.address!,
                style: pw.TextStyle(
                  fontSize: 12,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ],
          
          pw.SizedBox(height: 12),
          
          // Invoice Title
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'TAX INVOICE',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bill details section
  static pw.Widget _buildBillDetails(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice No:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                bill.id,
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'Date:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                _formatDate(bill.createdAt),
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Time:',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                _formatTime(bill.createdAt),
                style: const pw.TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build customer information section
  static pw.Widget _buildCustomerSection(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO:',
            style: pw.TextStyle(
              fontSize: 14, 
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            bill.customerName,
            style: pw.TextStyle(
              fontSize: 16, 
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (bill.customerPhone != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Phone: ${bill.customerPhone}',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  /// Build professional items table
  static pw.Widget _buildProfessionalItemsTable(Bill bill) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Table(
        border: pw.TableBorder.all(color: PdfColors.grey300),
        columnWidths: {
          0: const pw.FlexColumnWidth(0.8),
          1: const pw.FlexColumnWidth(3.5),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(1.5),
        },
        children: [
          // Header row
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blue900),
            children: [
              _buildProfessionalTableCell('S.No', isHeader: true),
              _buildProfessionalTableCell('ITEM DESCRIPTION', isHeader: true),
              _buildProfessionalTableCell('QTY', isHeader: true),
              _buildProfessionalTableCell('RATE (₹)', isHeader: true),
              _buildProfessionalTableCell('AMOUNT (₹)', isHeader: true),
            ],
          ),
          // Item rows
          ...bill.items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value;
            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
              ),
              children: [
                _buildProfessionalTableCell('$index'),
                _buildProfessionalTableCell(item.productName),
                _buildProfessionalTableCell('${item.quantity}'),
                _buildProfessionalTableCell(item.price.toStringAsFixed(2)),
                _buildProfessionalTableCell(item.total.toStringAsFixed(2)),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  /// Build professional totals section
  static pw.Widget _buildProfessionalTotals(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildProfessionalTotalRow('Subtotal:', bill.subtotal),
          if (bill.taxAmount > 0)
            _buildProfessionalTotalRow('Tax:', bill.taxAmount),
          if (bill.discountAmount > 0)
            _buildProfessionalTotalRow('Discount:', -bill.discountAmount),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey400, thickness: 1),
          pw.SizedBox(height: 8),
          _buildProfessionalTotalRow('TOTAL AMOUNT:', bill.totalAmount, isTotal: true),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue900,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'TOTAL AMOUNT:',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  '₹${bill.totalAmount.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build professional footer section
  static pw.Widget _buildProfessionalFooter(Bill bill, AppUser? user) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(
              fontSize: 16, 
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 12),
          
          if (bill.notes != null) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Notes:',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    bill.notes!,
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),
          ],
          
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Generated on: ${_formatDateTime(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Total Items: ${bill.totalItems}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
          
          pw.SizedBox(height: 8),
          
          pw.Text(
            'This is a computer generated invoice.',
            style: pw.TextStyle(
              fontSize: 10,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build professional table cell
  static pw.Widget _buildProfessionalTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(12),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  /// Build professional total row
  static pw.Widget _buildProfessionalTotalRow(
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: pw.FontWeight.bold,
              color: isTotal ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
          pw.Text(
            '₹${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 14 : 12,
              fontWeight: pw.FontWeight.bold,
              color: isTotal ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  /// Format date
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format time
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Format date and time
  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${_formatTime(date)}';
  }
}

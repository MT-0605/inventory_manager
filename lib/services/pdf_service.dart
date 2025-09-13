import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/bill.dart';

/// Service for generating PDF bills
class PDFService {
  /// Generate and preview a bill PDF
  static Future<void> generateAndPreviewBill(Bill bill) async {
    final pdf = await _generateBillPDF(bill);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Generate and save a bill PDF
  static Future<void> generateAndSaveBill(Bill bill) async {
    final pdf = await _generateBillPDF(bill);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bill_${bill.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Generate PDF document for the bill
  static Future<pw.Document> _generateBillPDF(Bill bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(bill),
              pw.SizedBox(height: 20),

              // Customer info
              _buildCustomerInfo(bill),
              pw.SizedBox(height: 20),

              // Items table
              _buildItemsTable(bill),
              pw.SizedBox(height: 20),

              // Totals
              _buildTotals(bill),
              pw.SizedBox(height: 30),

              // Footer
              _buildFooter(bill),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Build header section
  static pw.Widget _buildHeader(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVENTORY MANAGER',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Sales Invoice',
                style: pw.TextStyle(fontSize: 16, color: PdfColors.blue600),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Bill #${bill.id}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Date: ${_formatDate(bill.createdAt)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'Time: ${_formatTime(bill.createdAt)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build customer information section
  static pw.Widget _buildCustomerInfo(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bill To:',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(bill.customerName, style: const pw.TextStyle(fontSize: 12)),
          if (bill.customerPhone != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              'Phone: ${bill.customerPhone}',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  /// Build items table
  static pw.Widget _buildItemsTable(Bill bill) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _buildTableCell('S.No', isHeader: true),
            _buildTableCell('Item', isHeader: true),
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Price', isHeader: true),
            _buildTableCell('Total', isHeader: true),
          ],
        ),
        // Item rows
        ...bill.items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          return pw.TableRow(
            children: [
              _buildTableCell('$index'),
              _buildTableCell(item.productName),
              _buildTableCell('${item.quantity}'),
              _buildTableCell('\$${item.price.toStringAsFixed(2)}'),
              _buildTableCell('\$${item.total.toStringAsFixed(2)}'),
            ],
          );
        }).toList(),
      ],
    );
  }

  /// Build totals section
  static pw.Widget _buildTotals(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('Subtotal:', bill.subtotal),
          _buildTotalRow('Tax:', bill.taxAmount),
          if (bill.discountAmount > 0)
            _buildTotalRow('Discount:', -bill.discountAmount),
          pw.Divider(),
          _buildTotalRow('TOTAL:', bill.totalAmount, isTotal: true),
        ],
      ),
    );
  }

  /// Build footer section
  static pw.Widget _buildFooter(Bill bill) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'Thank you for your business!',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (bill.notes != null) ...[
            pw.Text(
              'Notes: ${bill.notes}',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.SizedBox(height: 8),
          ],
          pw.Text(
            'Generated on ${_formatDateTime(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// Build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  /// Build total row
  static pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            '\$${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontSize: isTotal ? 12 : 10,
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
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

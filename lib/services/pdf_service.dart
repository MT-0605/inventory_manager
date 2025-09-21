import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/bill.dart';
import '../models/user.dart';

/// Service for generating classic-style PDF bills
class PDFService {
  /// Generate and preview a bill PDF
  static Future<void> generateAndPreviewBill(Bill bill, {AppUser? user}) async {
    final pdf = await _generateClassicBillPDF(bill, user: user);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  /// Generate and save a bill PDF
  static Future<void> generateAndSaveBill(Bill bill, {AppUser? user}) async {
    final pdf = await _generateClassicBillPDF(bill, user: user);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Bill_${bill.id}_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Generate a classic PDF document for the bill
  static Future<pw.Document> _generateClassicBillPDF(Bill bill, {AppUser? user}) async {
    final pdf = pw.Document();

    // 1. LOAD FONT DATA
    // This loads the custom font that supports the Rupee symbol from your assets.
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final ttfFont = pw.Font.ttf(fontData);

    // 2. CREATE A PAGE THEME
    // This theme applies your custom font to the entire page, so you don't
    // have to style each Text widget individually.
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      theme: pw.ThemeData.withFont(
        base: ttfFont,
        bold: ttfFont, // You could load a separate bold font if you have one
      ),
    );

    pdf.addPage(
      pw.Page(
        // 3. APPLY THE THEME TO THE PAGE
        pageTheme: pageTheme,
        build: (pw.Context context) {
          // The rest of your build logic remains exactly the same.
          // All pw.Text widgets will now automatically use the custom font.
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Shopkeeper Details (Header)
              _buildHeader(user),
              pw.SizedBox(height: 20),

              // 2. Customer and Bill Details
              _buildCustomerAndBillInfo(bill),
              pw.SizedBox(height: 20),

              // 3. Items Table (Bill Summary)
              pw.Text('Bill Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 5),
              _buildItemsTable(bill),
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 5),

              // 4. Totals Section
              _buildTotals(bill),

              // Spacer to push the footer to the bottom
              pw.Spacer(),

              // 5. Footer
              _buildFooter(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Builds the header with shop details
  static pw.Widget _buildHeader(AppUser? user) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          user?.shopName?.toUpperCase() ?? 'INVENTORY MANAGER',
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 5),
        if (user?.address != null)
          pw.Text(user!.address!, textAlign: pw.TextAlign.center),
        if (user?.phoneNumber != null)
          pw.Text('Contact: ${user!.phoneNumber!}'),
        pw.SizedBox(height: 10),
        pw.Divider(thickness: 1.5),
      ],
    );
  }

  /// Builds the customer info and bill details section
  static pw.Widget _buildCustomerAndBillInfo(Bill bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Customer Details
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(bill.customerName),
            if (bill.customerPhone != null) pw.Text(bill.customerPhone!),
          ],
        ),
        // Bill Details
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Invoice No: ${bill.id}'),
            pw.Text('Date: ${_formatDate(bill.createdAt)}'),
            pw.Text('Time: ${_formatTime(bill.createdAt)}'),
          ],
        ),
      ],
    );
  }

  /// Builds the items table
  static pw.Widget _buildItemsTable(Bill bill) {
    final headers = ['#', 'Item Description', 'Qty', 'Rate (₹)', 'Amount (₹)'];

    final data = bill.items.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final item = entry.value;
      return [
        index.toString(),
        item.productName,
        item.quantity.toString(),
        item.price.toStringAsFixed(2),
        item.total.toStringAsFixed(2),
      ];
    }).toList();

    return pw.Table.fromTextArray(
        headers: headers,
        data: data,
        border: null,
        headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
        cellHeight: 30,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerRight,
          3: pw.Alignment.centerRight,
          4: pw.Alignment.centerRight,
        },
        columnWidths: {
          0: const pw.FlexColumnWidth(0.5),
          1: const pw.FlexColumnWidth(3.5),
          2: const pw.FlexColumnWidth(1),
          3: const pw.FlexColumnWidth(1.5),
          4: const pw.FlexColumnWidth(1.5),
        });
  }

  /// Builds the totals section (Subtotal, Tax, Discount, Grand Total)
  static pw.Widget _buildTotals(Bill bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.SizedBox(
          width: 250,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildTotalRow('Subtotal', bill.subtotal),
              _buildTotalRow('Tax', bill.taxAmount),
              _buildTotalRow('Discount', -bill.discountAmount),
              pw.Divider(),
              _buildTotalRow('Grand Total', bill.totalAmount, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper to build a single row in the totals section
  static pw.Widget _buildTotalRow(String label, double value, {bool isTotal = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: isTotal
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
                : const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            '₹${value.toStringAsFixed(2)}', // This will now render correctly ✅
            style: isTotal
                ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)
                : const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Builds the footer with a thank you message
  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('Thank You For Your Business!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 5),
        pw.Text(
          'This is a computer-generated invoice and does not require a signature.',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
        ),
      ],
    );
  }

  /// Format date as DD/MM/YYYY
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format time as HH:MM
  static String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
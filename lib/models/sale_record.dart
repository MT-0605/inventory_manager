import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';
import 'bill.dart';

/// Sale record model for analytics and reporting
class SaleRecord {
  final String id;
  final String productId;
  final String productName;
  final String category;
  final int quantitySold;
  final double unitPrice;
  final double totalAmount;
  final double costPrice;
  final double profit;
  final DateTime saleDate;
  final String billId;

  SaleRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.quantitySold,
    required this.unitPrice,
    required this.totalAmount,
    required this.costPrice,
    required this.profit,
    required this.saleDate,
    required this.billId,
  });

  /// Create SaleRecord from Firestore document
  factory SaleRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SaleRecord(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      category: data['category'] ?? '',
      quantitySold: data['quantitySold'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      profit: (data['profit'] ?? 0).toDouble(),
      saleDate: (data['saleDate'] as Timestamp).toDate(),
      billId: data['billId'] ?? '',
    );
  }

  /// Convert SaleRecord to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category,
      'quantitySold': quantitySold,
      'unitPrice': unitPrice,
      'totalAmount': totalAmount,
      'costPrice': costPrice,
      'profit': profit,
      'saleDate': Timestamp.fromDate(saleDate),
      'billId': billId,
    };
  }

  /// Create SaleRecord from BillItem and Product
  factory SaleRecord.fromBillItemAndProduct({
    required BillItem billItem,
    required Product product,
    required String billId,
  }) {
    final totalAmount = billItem.total;
    final costPrice = product.costPrice * billItem.quantity;
    final profit = totalAmount - costPrice;

    return SaleRecord(
      id: '', // Will be set when saving to Firestore
      productId: billItem.productId,
      productName: billItem.productName,
      category: product.category,
      quantitySold: billItem.quantity,
      unitPrice: billItem.price,
      totalAmount: totalAmount,
      costPrice: costPrice,
      profit: profit,
      saleDate: DateTime.now(),
      billId: billId,
    );
  }

  /// Calculate profit margin percentage
  double get profitMarginPercentage {
    return totalAmount > 0 ? (profit / totalAmount) * 100 : 0;
  }

  @override
  String toString() {
    return 'SaleRecord(id: $id, productName: $productName, quantitySold: $quantitySold, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaleRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

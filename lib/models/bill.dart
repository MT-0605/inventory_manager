import 'package:cloud_firestore/cloud_firestore.dart';

/// Bill item representing a single product in a bill
class BillItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double total;

  BillItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.total,
  });

  factory BillItem.fromMap(Map<String, dynamic> map) {
    return BillItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
      total: (map['total'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }
}

/// Bill model representing a customer purchase
class Bill {
  final String id;
  final String customerName;
  final String? customerPhone;
  final List<BillItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final DateTime createdAt;
  final String? notes;

  Bill({
    required this.id,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.createdAt,
    this.notes,
  });

  /// Create Bill from Firestore document
  factory Bill.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    List<BillItem> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((item) => BillItem.fromMap(item as Map<String, dynamic>))
          .toList();
    }

    return Bill(
      id: doc.id,
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'],
      items: items,
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      discountAmount: (data['discountAmount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      notes: data['notes'],
    );
  }

  /// Convert Bill to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'notes': notes,
    };
  }

  /// Create a copy of Bill with updated fields
  Bill copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    List<BillItem>? items,
    double? subtotal,
    double? taxAmount,
    double? discountAmount,
    double? totalAmount,
    DateTime? createdAt,
    String? notes,
  }) {
    return Bill(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  /// Get total number of items in the bill
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() {
    return 'Bill(id: $id, customerName: $customerName, totalAmount: $totalAmount, items: ${items.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

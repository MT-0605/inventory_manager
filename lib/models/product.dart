import 'package:cloud_firestore/cloud_firestore.dart';

/// Product model representing items in inventory
class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final String? imageUrl;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    this.imageUrl,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      costPrice: (data['costPrice'] ?? 0).toDouble(),
      stockQuantity: data['stockQuantity'] ?? 0,
      imageUrl: data['imageUrl'],
      description: data['description'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert Product to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy of Product with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    double? costPrice,
    int? stockQuantity,
    String? imageUrl,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if product is low in stock (less than 10 items)
  bool get isLowStock => stockQuantity < 10;

  /// Calculate profit margin
  double get profitMargin => price - costPrice;

  /// Calculate profit percentage
  double get profitPercentage =>
      costPrice > 0 ? (profitMargin / costPrice) * 100 : 0;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, category: $category, price: $price, stockQuantity: $stockQuantity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

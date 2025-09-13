import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for shopkeeper information
class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? shopName;
  final String? address;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.shopName,
    this.address,
    required this.createdAt,
    required this.lastLoginAt,
    required this.isActive,
  });

  /// Create AppUser from Firestore document
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      phoneNumber: data['phoneNumber'],
      shopName: data['shopName'],
      address: data['address'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert AppUser to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'shopName': shopName,
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isActive': isActive,
    };
  }

  /// Create AppUser from Firebase Auth User
  factory AppUser.fromFirebaseUser({
    required String id,
    required String email,
    String? displayName,
    String? phoneNumber,
  }) {
    final now = DateTime.now();
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? email.split('@')[0],
      phoneNumber: phoneNumber,
      createdAt: now,
      lastLoginAt: now,
      isActive: true,
    );
  }

  /// Create a copy of AppUser with updated fields
  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? shopName,
    String? address,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, displayName: $displayName, shopName: $shopName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

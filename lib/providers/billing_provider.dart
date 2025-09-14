import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/bill.dart';
import '../models/product.dart';
import '../models/sale_record.dart';
import '../services/firebase_service.dart';
import 'product_provider.dart';

/// Billing provider for managing billing operations
class BillingProvider with ChangeNotifier {
  List<BillItem> _cartItems = [];
  String _customerName = '';
  String? _customerPhone;
  String? _notes;
  double _taxRate = 0.0;
  double _discountAmount = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<BillItem> get cartItems => _cartItems;
  String get customerName => _customerName;
  String? get customerPhone => _customerPhone;
  String? get notes => _notes;
  double get taxRate => _taxRate;
  double get discountAmount => _discountAmount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Get subtotal of all items in cart
  double get subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Get tax amount
  double get taxAmount {
    return (subtotal * _taxRate) / 100;
  }

  /// Get total amount after tax and discount
  double get totalAmount {
    return subtotal + taxAmount - _discountAmount;
  }

  /// Get total number of items in cart
  int get totalItems {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if cart is empty
  bool get isCartEmpty => _cartItems.isEmpty;

  /// Add product to cart
  void addToCart(Product product, int quantity) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex != -1) {
      // Update existing item
      final existingItem = _cartItems[existingIndex];
      final newQuantity = existingItem.quantity + quantity;
      final newTotal = product.price * newQuantity;

      _cartItems[existingIndex] = BillItem(
        productId: product.id,
        productName: product.name,
        price: product.price,
        quantity: newQuantity,
        total: newTotal,
      );
    } else {
      // Add new item
      _cartItems.add(
        BillItem(
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: quantity,
          total: product.price * quantity,
        ),
      );
    }

    notifyListeners();
  }

  /// Remove product from cart
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Update item quantity in cart
  void updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index != -1) {
      final item = _cartItems[index];
      _cartItems[index] = BillItem(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: quantity,
        total: item.price * quantity,
      );
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Set customer information
  void setCustomerInfo(String name, {String? phone}) {
    _customerName = name;
    _customerPhone = phone;
    notifyListeners();
  }

  /// Set notes
  void setNotes(String? notes) {
    _notes = notes;
    notifyListeners();
  }

  /// Set tax rate
  void setTaxRate(double rate) {
    _taxRate = rate;
    notifyListeners();
  }

  /// Set discount amount
  void setDiscountAmount(double amount) {
    _discountAmount = amount;
    notifyListeners();
  }

  /// Generate bill and process sale
  Future<bool> generateBill(ProductProvider productProvider) async {
    if (_cartItems.isEmpty || _customerName.isEmpty) {
      _setError('Cart is empty or customer name is required');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Check stock availability
      for (final item in _cartItems) {
        final product = productProvider.getProductById(item.productId);
        if (product == null) {
          _setError('Product ${item.productName} not found');
          return false;
        }
        if (product.stockQuantity < item.quantity) {
          _setError('Insufficient stock for ${item.productName}');
          return false;
        }
      }

      // Generate bill ID
      const uuid = Uuid();
      final billId = uuid.v4();

      // Create bill
      final bill = Bill(
        id: billId,
        customerName: _customerName,
        customerPhone: _customerPhone,
        items: List.from(_cartItems),
        subtotal: subtotal,
        taxAmount: taxAmount,
        discountAmount: _discountAmount,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
        notes: _notes,
      );

      // Save bill to Firestore
      await FirebaseService.billsCollection.doc(billId).set(bill.toFirestore());

      // Create sale records and update stock
      final List<SaleRecord> saleRecords = [];
      for (final item in _cartItems) {
        final product = productProvider.getProductById(item.productId)!;

        // Create sale record
        final saleRecord = SaleRecord.fromBillItemAndProduct(
          billItem: item,
          product: product,
          billId: billId,
        );
        saleRecords.add(saleRecord);

        // Update product stock
        await productProvider.reduceStock(item.productId, item.quantity);
      }

      // Save sale records
      final batch = FirebaseService.firestore.batch();
      for (final saleRecord in saleRecords) {
        final docRef = FirebaseService.salesCollection.doc();
        batch.set(docRef, saleRecord.toFirestore());
      }
      await batch.commit();

      // Clear cart and reset form
      clearCart();
      _customerName = '';
      _customerPhone = null;
      _notes = null;
      _taxRate = 0.0;
      _discountAmount = 0.0;

      return true;
    } catch (e) {
      _setError('Failed to generate bill: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Get bill by ID
  Future<Bill?> getBillById(String billId) async {
    try {
      final doc = await FirebaseService.billsCollection.doc(billId).get();
      if (doc.exists) {
        return Bill.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _setError('Failed to load bill: $e');
      return null;
    }
  }

  /// Get recent bills
  Future<List<Bill>> getRecentBills({int limit = 10}) async {
    try {
      final querySnapshot = await FirebaseService.billsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList();
    } catch (e) {
      _setError('Failed to load bills: $e');
      return [];
    }
  }

  /// Get all bills
  Future<List<Bill>> getAllBills() async {
    try {
      final querySnapshot = await FirebaseService.billsCollection
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList();
    } catch (e) {
      _setError('Failed to load bills: $e');
      return [];
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/firebase_service.dart';

/// Product provider for managing product state and operations
class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  /// Get filtered products based on search and category
  List<Product> get filteredProducts {
    List<Product> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (product) =>
                product.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                product.category.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    return filtered;
  }

  /// Get all unique categories
  List<String> get categories {
    final categorySet = <String>{'All'};
    for (final product in _products) {
      categorySet.add(product.category);
    }
    return categorySet.toList()..sort();
  }

  /// Get low stock products
  List<Product> get lowStockProducts {
    return _products.where((product) => product.isLowStock).toList();
  }

  /// Get total stock value
  double get totalStockValue {
    return _products.fold(
      0.0,
      (sum, product) => sum + (product.price * product.stockQuantity),
    );
  }

  /// Get total number of products
  int get totalProducts => _products.length;

  /// Initialize and load products
  Future<void> init() async {
    await loadProducts();
  }

  /// Load products from Firestore
  Future<void> loadProducts() async {
    try {
      _setLoading(true);
      _clearError();

      final currentUid = FirebaseService.currentUser?.uid;
      if (currentUid == null) {
        _setError('User not authenticated');
        return;
      }

      final querySnapshot = await FirebaseService
          .userProductsCollection(currentUid)
          .orderBy('createdAt', descending: true)
          .get();

      _products = querySnapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
    } catch (e) {
      _setError('Failed to load products: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Add a new product
  Future<bool> addProduct(Product product) async {
    try {
      _setLoading(true);
      _clearError();

      final currentUid = FirebaseService.currentUser?.uid;
      if (currentUid == null) {
        _setError('User not authenticated');
        return false;
      }

      final data = {
        ...product.toFirestore(),
        'ownerId': currentUid,
      };

      final docRef = await FirebaseService
          .userProductsCollection(currentUid)
          .add(data);

      // Update the product with the generated ID
      final newProduct = product.copyWith(id: docRef.id);
      _products.insert(0, newProduct);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to add product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update an existing product
  Future<bool> updateProduct(Product product) async {
    try {
      _setLoading(true);
      _clearError();

      final currentUid = FirebaseService.currentUser?.uid;
      if (currentUid == null) {
        _setError('User not authenticated');
        return false;
      }

      await FirebaseService
          .userProductsCollection(currentUid)
          .doc(product.id)
          .update(product.toFirestore());

      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError('Failed to update product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete a product
  Future<bool> deleteProduct(String productId) async {
    try {
      _setLoading(true);
      _clearError();

      final currentUid = FirebaseService.currentUser?.uid;
      if (currentUid == null) {
        _setError('User not authenticated');
        return false;
      }

      await FirebaseService
          .userProductsCollection(currentUid)
          .doc(productId)
          .delete();

      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete product: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update product stock quantity
  Future<bool> updateStock(String productId, int newQuantity) async {
    try {
      _setLoading(true);
      _clearError();

      final product = _products.firstWhere((p) => p.id == productId);
      final updatedProduct = product.copyWith(
        stockQuantity: newQuantity,
        updatedAt: DateTime.now(),
      );

      await updateProduct(updatedProduct);
      return true;
    } catch (e) {
      _setError('Failed to update stock: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Reduce stock for sold items
  Future<bool> reduceStock(String productId, int quantity) async {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      final newQuantity = product.stockQuantity - quantity;

      if (newQuantity < 0) {
        _setError('Insufficient stock for ${product.name}');
        return false;
      }

      return await updateStock(productId, newQuantity);
    } catch (e) {
      _setError('Failed to reduce stock: $e');
      return false;
    }
  }

  /// Search products
  void searchProducts(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  /// Get product by ID
  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
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

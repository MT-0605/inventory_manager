import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/billing_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/ultra_simple_card.dart';
import '../models/product.dart';
import 'billing_cart_screen.dart';

/// Billing screen for creating sales and generating bills
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<BillingProvider>(
            builder: (context, billingProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: billingProvider.isCartEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BillingCartScreen(),
                              ),
                            );
                          },
                  ),
                  if (!billingProvider.isCartEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${billingProvider.totalItems}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          if (productProvider.isLoading) {
            return const LoadingWidget(message: 'Loading products...');
          }

          return Column(
            children: [
              // Search and filter section
              _buildSearchAndFilter(context, productProvider),

              // Products grid
              Expanded(
                child: productProvider.filteredProducts.isEmpty
                    ? _buildEmptyState(context)
                    : _buildProductsGrid(context, productProvider),
              ),
            ],
          );
        },
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget _buildSearchAndFilter(
    BuildContext context,
    ProductProvider productProvider,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        productProvider.searchProducts('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              productProvider.searchProducts(value);
            },
          ),
          const SizedBox(height: 8),

          // Category filter
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: _selectedCategory == 'All',
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                      productProvider.filterByCategory('All');
                    },
                  ),
                  const SizedBox(width: 8),
                  ...productProvider.categories
                      .where((category) => category != 'All')
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: _selectedCategory == category,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                              });
                              productProvider.filterByCategory(category);
                            },
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsGrid(
    BuildContext context,
    ProductProvider productProvider,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if keyboard is open
        final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
        
        // Use smaller aspect ratio when keyboard is open to fit more content
        final aspectRatio = isKeyboardOpen ? 0.6 : 0.7;
        
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: aspectRatio,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: productProvider.filteredProducts.length,
          itemBuilder: (context, index) {
            final product = productProvider.filteredProducts[index];
            return _buildProductCard(context, product);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return UltraSimpleProductCard(
      name: product.name,
      category: product.category,
      price: '₹${product.price.toStringAsFixed(0)}',
      stock: '${product.stockQuantity}',
      imageUrl: product.imageUrl,
      isLowStock: product.isLowStock,
      onTap: () {
        if (product.stockQuantity > 0) {
          _showQuantityDialog(context, product);
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to your inventory first',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, Product product) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available stock: ${product.stockQuantity}'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: quantityController,
              labelText: 'Quantity',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                final quantity = int.tryParse(value);
                if (quantity == null || quantity <= 0) {
                  return 'Invalid quantity';
                }
                if (quantity > product.stockQuantity) {
                  return 'Insufficient stock';
                }
                return null;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null &&
                  quantity > 0 &&
                  quantity <= product.stockQuantity) {
                context.read<BillingProvider>().addToCart(product, quantity);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added $quantity ${product.name}(s) to cart'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/billing_provider.dart';
import '../providers/product_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/loading_widget.dart';
import '../models/bill.dart';
import '../services/pdf_service.dart';

/// Billing cart screen for managing cart items and generating bills
class BillingCartScreen extends StatefulWidget {
  const BillingCartScreen({super.key});

  @override
  State<BillingCartScreen> createState() => _BillingCartScreenState();
}

class _BillingCartScreenState extends State<BillingCartScreen> {
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  final _taxRateController = TextEditingController(text: '0');
  final _discountController = TextEditingController(text: '0');
  int _currentStep = 0; // 0 = Cart, 1 = Details

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _notesController.dispose();
    _taxRateController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Billing Cart'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<BillingProvider>(
            builder: (context, billingProvider, child) {
              return TextButton(
                onPressed: billingProvider.isCartEmpty
                    ? null
                    : () {
                        billingProvider.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Cart cleared'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                child: const Text('Clear All'),
              );
            },
          ),
        ],
      ),
      body: Consumer<BillingProvider>(
        builder: (context, billingProvider, child) {
          if (billingProvider.isLoading) {
            return const LoadingWidget(message: 'Processing...');
          }

          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomInset + 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStepHeader(context, billingProvider),
                const SizedBox(height: 12),

                if (_currentStep == 0) ...[
                  billingProvider.isCartEmpty
                      ? _buildEmptyCart(context)
                      : _buildCartItems(context, billingProvider),
                  const SizedBox(height: 12),
                  _buildStep0Actions(context, billingProvider),
                ] else ...[
                  if (!billingProvider.isCartEmpty)
                    _buildCustomerInfoAndTotals(context, billingProvider),
                  const SizedBox(height: 12),
                  _buildStep1Actions(context, billingProvider),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to start billing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(
    BuildContext context,
    BillingProvider billingProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: billingProvider.cartItems.length,
      itemBuilder: (context, index) {
        final item = billingProvider.cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.price.toStringAsFixed(2)} each',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity controls
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        billingProvider.updateItemQuantity(
                          item.productId,
                          item.quantity - 1,
                        );
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        billingProvider.updateItemQuantity(
                          item.productId,
                          item.quantity + 1,
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),

                // Total and remove
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        billingProvider.removeFromCart(item.productId);
                      },
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerInfoAndTotals(
    BuildContext context,
    BillingProvider billingProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer information
          Text(
            'Customer Information',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _customerNameController,
            labelText: 'Customer Name *',
            prefixIcon: Icons.person_outline,
            onChanged: (value) {
              billingProvider.setCustomerInfo(value);
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _customerPhoneController,
            labelText: 'Phone Number (Optional)',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              billingProvider.setCustomerInfo(
                _customerNameController.text,
                phone: value.isEmpty ? null : value,
              );
            },
          ),
          const SizedBox(height: 16),

          // Tax and discount
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _taxRateController,
                  labelText: 'Tax Rate (%)',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final rate = double.tryParse(value) ?? 0;
                    billingProvider.setTaxRate(rate);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  controller: _discountController,
                  labelText: 'Discount (₹)',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final discount = double.tryParse(value) ?? 0;
                    billingProvider.setDiscountAmount(discount);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _notesController,
            labelText: 'Notes (Optional)',
            prefixIcon: Icons.note_outlined,
            maxLines: 2,
            onChanged: (value) {
              billingProvider.setNotes(value.isEmpty ? null : value);
            },
          ),
          const SizedBox(height: 16),

          // Totals
          _buildTotalsSection(context, billingProvider),
        ],
      ),
    );
  }

  Widget _buildStepHeader(BuildContext context, BillingProvider billingProvider) {
    final tabs = [
      {'label': 'Cart', 'index': 0, 'enabled': true},
      {'label': 'Details', 'index': 1, 'enabled': !billingProvider.isCartEmpty},
    ];
    return Row(
      children: tabs.map((t) {
        final selected = _currentStep == t['index'];
        final enabled = t['enabled'] as bool;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: OutlinedButton(
              onPressed: enabled
                  ? () {
                      setState(() => _currentStep = t['index'] as int);
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    selected ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : null,
              ),
              child: Text(
                t['label'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStep0Actions(BuildContext context, BillingProvider billingProvider) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Next',
            icon: Icons.arrow_forward,
            onPressed: billingProvider.isCartEmpty
                ? null
                : () {
                    setState(() => _currentStep = 1);
                  },
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Actions(BuildContext context, BillingProvider billingProvider) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Submit',
            onPressed: () => _generateBill(context, billingProvider),
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalsSection(
    BuildContext context,
    BillingProvider billingProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildTotalRow(context, 'Subtotal', billingProvider.subtotal),
          _buildTotalRow(context, 'Tax', billingProvider.taxAmount),
          _buildTotalRow(context, 'Discount', -billingProvider.discountAmount),
          const Divider(),
          _buildTotalRow(
            context,
            'Total',
            billingProvider.totalAmount,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    BuildContext context,
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateBill(
    BuildContext context,
    BillingProvider billingProvider,
  ) async {
    if (_customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final productProvider = context.read<ProductProvider>();
    final authProvider = context.read<AuthProvider>();
    try {
      final bill = await billingProvider.generateBill(productProvider);
      if (bill != null && mounted) {
        // Save PDF with unique name and user information
        await PDFService.generateAndSaveBill(bill, user: authProvider.user);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill generated and PDF saved!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
        return;
      }
    } catch (e) {
      // Fall-through to error snackbar below
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            billingProvider.errorMessage ?? 'Failed to generate bill',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _previewBill(
    BuildContext context,
    BillingProvider billingProvider,
  ) async {
    if (_customerNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter customer name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final bill = Bill(
        id: 'preview',
        customerName: _customerNameController.text.trim(),
        customerPhone: _customerPhoneController.text.trim().isEmpty
            ? null
            : _customerPhoneController.text.trim(),
        items: billingProvider.cartItems,
        subtotal: billingProvider.subtotal,
        taxAmount: billingProvider.taxAmount,
        discountAmount: billingProvider.discountAmount,
        totalAmount: billingProvider.totalAmount,
        createdAt: DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await PDFService.generateAndPreviewBill(bill);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to preview bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

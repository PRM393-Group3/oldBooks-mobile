import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';

class CartCheckoutScreen extends StatefulWidget {
  const CartCheckoutScreen({super.key});

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  String _shippingMethod = 'insured'; // 'standard' or 'insured'
  String _paymentMethod = 'escrow'; // 'escrow', 'card', 'applepay'
  bool _couponApplied = false;
  final TextEditingController _couponController = TextEditingController(text: 'BOOKHUB5');

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final subtotal = appState.cartSubtotal;
    final shipping = appState.cartItems.isEmpty ? 0.0 : (_shippingMethod == 'insured' ? 14.50 : 5.00);
    final discount = _couponApplied ? subtotal * 0.05 : 0.0;
    final total = (subtotal - discount + shipping).clamp(0.0, 99999.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => appState.navigateTo(AppScreen.buyerHome),
        ),
        title: const Text('SafeTrade Escrow Checkout'),
        actions: [
          if (appState.cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () => appState.clearCart(),
            ),
        ],
      ),
      body: appState.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 12),
                  const Text(
                    'Your Book Bag is Empty',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Browse rare first editions and verified volumes in our catalog.',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => appState.navigateTo(AppScreen.buyerHome),
                    child: const Text('Explore Volumes'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Escrow Header Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.emeraldGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.lock, color: AppTheme.emeraldGreen, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SafeTrade Protocol: Payment is frozen in neutral escrow until you inspect the delivered volume.',
                            style: TextStyle(fontSize: 11, color: AppTheme.emeraldGreen, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cart Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: appState.cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = appState.cartItems[index];
                      return Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(item.book.coverImage, width: 45, height: 65, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.book.title,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    item.book.author,
                                    style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${item.book.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 18),
                                  onPressed: () => appState.updateCartQuantity(item.book.id, -1),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 18),
                                  onPressed: () => appState.updateCartQuantity(item.book.id, 1),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Shipping Method Options
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certified Carrier & Transit Insurance',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 8),
                        RadioListTile<String>(
                          value: 'insured',
                          groupValue: _shippingMethod,
                          onChanged: (v) => setState(() => _shippingMethod = v!),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Insured Priority Courier with Tamper Seal (\$14.50)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          subtitle: const Text('Signature required • 100% loss/damage escrow guarantee',
                              style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                        ),
                        RadioListTile<String>(
                          value: 'standard',
                          groupValue: _shippingMethod,
                          onChanged: (v) => setState(() => _shippingMethod = v!),
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Standard Media Mail Tracked (\$5.00)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          subtitle: const Text('3-5 business days delivery window',
                              style: TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Order Summary Breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Breakdown',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                        const SizedBox(height: 10),
                        _buildSummaryRow('Items Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildSummaryRow('Insured Shipping', '\$${shipping.toStringAsFixed(2)}'),
                        if (_couponApplied) ...[
                          const SizedBox(height: 6),
                          _buildSummaryRow('Promo (5% Off)', '-\$${discount.toStringAsFixed(2)}', isDiscount: true),
                        ],
                        const Divider(color: AppTheme.outlineVariant, height: 16),
                        _buildSummaryRow('Total Held in Escrow', '\$${total.toStringAsFixed(2)}', isBold: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Checkout Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        appState.clearCart();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment locked in SafeTrade Escrow! Order #ORD-8109 initialized.')),
                        );
                        appState.navigateTo(AppScreen.orderTracking);
                      },
                      icon: const Icon(Icons.verified_user, size: 18),
                      label: Text('Deposit \$${total.toStringAsFixed(2)} to SafeTrade Escrow'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryContainer,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isDiscount ? AppTheme.emeraldGreen : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 14 : 11,
            fontWeight: FontWeight.bold,
            color: isDiscount ? AppTheme.emeraldGreen : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

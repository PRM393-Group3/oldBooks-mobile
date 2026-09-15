import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';

class ScreenSwitcherBar extends StatelessWidget {
  const ScreenSwitcherBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    final screens = [
      {'screen': AppScreen.buyerHome, 'label': '1. Buyer Home', 'icon': Icons.storefront},
      {'screen': AppScreen.auctionDetail, 'label': '2. Live Auction', 'icon': Icons.gavel},
      {'screen': AppScreen.sellerHub, 'label': '3. Seller Hub', 'icon': Icons.inventory_2},
      {'screen': AppScreen.inspectorAudit, 'label': '4. Inspector Audit', 'icon': Icons.fact_check},
      {'screen': AppScreen.adminPortal, 'label': '5. Admin Portal', 'icon': Icons.admin_panel_settings},
      {'screen': AppScreen.newListing, 'label': '6. New Listing', 'icon': Icons.add_circle},
      {'screen': AppScreen.cartCheckout, 'label': '7. Cart Checkout', 'icon': Icons.shopping_cart_checkout},
      {'screen': AppScreen.orderTracking, 'label': '8. Order Tracking', 'icon': Icons.local_shipping},
    ];

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: AppTheme.primary,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.15)),
        ),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemCount: screens.length,
        itemBuilder: (context, index) {
          final item = screens[index];
          final screen = item['screen'] as AppScreen;
          final isSelected = appState.currentScreen == screen;

          return InkWell(
            onTap: () => appState.navigateTo(screen),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.secondaryContainer : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

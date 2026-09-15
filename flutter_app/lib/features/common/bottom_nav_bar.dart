import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/all_models.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    // Different navigation items depending on active role
    List<NavigationDestination> destinations = [];
    int selectedIndex = 0;

    if (appState.currentRole == AppRole.buyer) {
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront, color: AppTheme.secondaryContainer),
          label: 'Market',
        ),
        const NavigationDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel, color: AppTheme.secondaryContainer),
          label: 'Auctions',
        ),
        NavigationDestination(
          icon: Badge(
            label: Text('${appState.cartCount}'),
            isLabelVisible: appState.cartCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          selectedIcon: Badge(
            label: Text('${appState.cartCount}'),
            isLabelVisible: appState.cartCount > 0,
            child: const Icon(Icons.shopping_cart, color: AppTheme.secondaryContainer),
          ),
          label: 'Cart',
        ),
        const NavigationDestination(
          icon: Icon(Icons.local_shipping_outlined),
          selectedIcon: Icon(Icons.local_shipping, color: AppTheme.secondaryContainer),
          label: 'Orders',
        ),
      ];

      if (appState.currentScreen == AppScreen.buyerHome) selectedIndex = 0;
      else if (appState.currentScreen == AppScreen.auctionDetail) selectedIndex = 1;
      else if (appState.currentScreen == AppScreen.cartCheckout) selectedIndex = 2;
      else if (appState.currentScreen == AppScreen.orderTracking) selectedIndex = 3;
    } else if (appState.currentRole == AppRole.seller) {
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2, color: AppTheme.secondaryContainer),
          label: 'Inventory',
        ),
        const NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle, color: AppTheme.secondaryContainer),
          label: 'New Book',
        ),
        const NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics, color: AppTheme.secondaryContainer),
          label: 'Metrics',
        ),
      ];

      if (appState.currentScreen == AppScreen.sellerHub) selectedIndex = 0;
      else if (appState.currentScreen == AppScreen.newListing) selectedIndex = 1;
      else selectedIndex = 2;
    } else if (appState.currentRole == AppRole.inspector) {
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.fact_check_outlined),
          selectedIcon: Icon(Icons.fact_check, color: AppTheme.emeraldGreen),
          label: 'Audit Desk',
        ),
        const NavigationDestination(
          icon: Icon(Icons.history_edu_outlined),
          selectedIcon: Icon(Icons.history_edu, color: AppTheme.emeraldGreen),
          label: 'Ledger',
        ),
      ];
      selectedIndex = 0;
    } else {
      destinations = [
        const NavigationDestination(
          icon: Icon(Icons.gavel_outlined),
          selectedIcon: Icon(Icons.gavel, color: AppTheme.crimsonRed),
          label: 'Disputes',
        ),
        const NavigationDestination(
          icon: Icon(Icons.verified_user_outlined),
          selectedIcon: Icon(Icons.verified_user, color: AppTheme.crimsonRed),
          label: 'Reputation',
        ),
        const NavigationDestination(
          icon: Icon(Icons.security_outlined),
          selectedIcon: Icon(Icons.security, color: AppTheme.crimsonRed),
          label: 'Vault',
        ),
      ];
      selectedIndex = 0;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.6), width: 1),
        ),
      ),
      child: NavigationBar(
        height: 60,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.surfaceContainerLow,
        selectedIndex: selectedIndex,
        destinations: destinations,
        onDestinationSelected: (index) {
          if (appState.currentRole == AppRole.buyer) {
            if (index == 0) appState.navigateTo(AppScreen.buyerHome);
            if (index == 1) appState.navigateTo(AppScreen.auctionDetail);
            if (index == 2) appState.navigateTo(AppScreen.cartCheckout);
            if (index == 3) appState.navigateTo(AppScreen.orderTracking);
          } else if (appState.currentRole == AppRole.seller) {
            if (index == 0) appState.navigateTo(AppScreen.sellerHub);
            if (index == 1) appState.navigateTo(AppScreen.newListing);
          } else if (appState.currentRole == AppRole.inspector) {
            appState.navigateTo(AppScreen.inspectorAudit);
          } else {
            appState.navigateTo(AppScreen.adminPortal);
          }
        },
      ),
    );
  }
}

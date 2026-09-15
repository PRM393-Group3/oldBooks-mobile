import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/models/all_models.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/common/screen_switcher_bar.dart';
import 'features/common/role_switch_drawer.dart';
import 'features/common/bottom_nav_bar.dart';
import 'features/buyer/buyer_home_screen.dart';
import 'features/auction/live_auction_detail_screen.dart';
import 'features/seller/seller_hub_screen.dart';
import 'features/seller/new_book_listing_screen.dart';
import 'features/inspector/inspector_audit_screen.dart';
import 'features/admin/admin_portal_screen.dart';
import 'features/cart/cart_checkout_screen.dart';
import 'features/order/order_tracking_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const BookHubApp(),
    ),
  );
}

class BookHubApp extends StatelessWidget {
  const BookHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHub - Rare & Pre-Owned Marketplace',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BookHubRootScaffold(),
    );
  }
}

class BookHubRootScaffold extends StatelessWidget {
  const BookHubRootScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    Widget currentBody;
    switch (appState.currentScreen) {
      case AppScreen.buyerHome:
        currentBody = const BuyerHomeScreen();
        break;
      case AppScreen.auctionDetail:
        currentBody = const LiveAuctionDetailScreen();
        break;
      case AppScreen.sellerHub:
        currentBody = const SellerHubScreen();
        break;
      case AppScreen.newListing:
        currentBody = const NewBookListingScreen();
        break;
      case AppScreen.inspectorAudit:
        currentBody = const InspectorAuditScreen();
        break;
      case AppScreen.adminPortal:
        currentBody = const AdminPortalScreen();
        break;
      case AppScreen.cartCheckout:
        currentBody = const CartCheckoutScreen();
        break;
      case AppScreen.orderTracking:
        currentBody = const OrderTrackingScreen();
        break;
    }

    return Scaffold(
      drawer: const RoleSwitchDrawer(),
      body: Column(
        children: [
          // Top quick screen switcher bar for quick testing across all 8 flows
          const ScreenSwitcherBar(),
          // Main Active Screen
          Expanded(child: currentBody),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}

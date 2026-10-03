import 'package:flutter/material.dart';

import '../core/l10n/app_localizations.dart';

/// Một tab của thanh điều hướng dưới.
class NavTab {
  const NavTab({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.isAction = false,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l) label;

  /// Tab hành động chính, vẽ thành nút tròn "+" (tab Bán ở giữa).
  final bool isAction;
}

String _navExplore(AppLocalizations l) => l.navExplore;
String _navAuctions(AppLocalizations l) => l.navAuctions;
String _navSell(AppLocalizations l) => l.navSell;
String _navWallet(AppLocalizations l) => l.navWallet;
String _navMe(AppLocalizations l) => l.navMe;

/// Năm tab cố định của mọi người dùng (mua và bán), theo thứ tự thanh dưới.
/// Thứ tự phải khớp thứ tự nhánh trong `StatefulShellRoute` ở `app_router.dart`.
const appTabs = <NavTab>[
  NavTab(
    path: '/home',
    icon: Icons.explore_outlined,
    selectedIcon: Icons.explore,
    label: _navExplore,
  ),
  NavTab(
    path: '/auctions',
    icon: Icons.gavel_outlined,
    selectedIcon: Icons.gavel,
    label: _navAuctions,
  ),
  NavTab(
    path: '/sell',
    icon: Icons.add,
    selectedIcon: Icons.add,
    label: _navSell,
    isAction: true,
  ),
  NavTab(
    path: '/wallet',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
    label: _navWallet,
  ),
  NavTab(
    path: '/me',
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: _navMe,
  ),
];

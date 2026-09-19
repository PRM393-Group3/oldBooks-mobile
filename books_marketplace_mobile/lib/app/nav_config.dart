import 'package:flutter/material.dart';

import '../core/l10n/app_localizations.dart';
import '../features/auth/domain/user_role.dart';

/// Một tab của thanh điều hướng dưới.
class NavTab {
  const NavTab({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.showsUnreadBadge = false,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String Function(AppLocalizations l) label;

  /// Tab thông báo hiện badge số chưa đọc.
  final bool showsUnreadBadge;
}

const _home = NavTab(
  path: '/home',
  icon: Icons.home_outlined,
  selectedIcon: Icons.home,
  label: _navHome,
);
const _myListings = NavTab(
  path: '/listings/mine',
  icon: Icons.inventory_2_outlined,
  selectedIcon: Icons.inventory_2,
  label: _navMyListings,
);
const _notifications = NavTab(
  path: '/notifications',
  icon: Icons.notifications_none,
  selectedIcon: Icons.notifications,
  label: _navNotifications,
  showsUnreadBadge: true,
);
const _profile = NavTab(
  path: '/profile',
  icon: Icons.person_outline,
  selectedIcon: Icons.person,
  label: _navProfile,
);
const _queue = NavTab(
  path: '/inspection/queue',
  icon: Icons.inbox_outlined,
  selectedIcon: Icons.inbox,
  label: _navQueue,
);
const _claimed = NavTab(
  path: '/inspection/mine',
  icon: Icons.assignment_outlined,
  selectedIcon: Icons.assignment,
  label: _navClaimed,
);

String _navHome(AppLocalizations l) => l.navHome;
String _navMyListings(AppLocalizations l) => l.navMyListings;
String _navNotifications(AppLocalizations l) => l.navNotifications;
String _navProfile(AppLocalizations l) => l.navProfile;
String _navQueue(AppLocalizations l) => l.navQueue;
String _navClaimed(AppLocalizations l) => l.navClaimed;

/// Bảng duy nhất ánh xạ vai trò sang các tab (tối đa 5 theo SRS 8.1).
/// Thêm vai trò hoặc tab chỉ cần sửa ở đây.
List<NavTab> tabsFor(UserRole role) => switch (role) {
  UserRole.buyer => const [_home, _notifications, _profile],
  UserRole.seller => const [_home, _myListings, _notifications, _profile],
  UserRole.inspector => const [_queue, _claimed, _notifications, _profile],
  // Admin dùng cổng web; trên mobile chỉ có Hồ sơ (không hiện thanh dưới).
  UserRole.admin || UserRole.unknown => const [_profile],
};

/// Màn hình mặc định sau khi đăng nhập.
String homePathFor(UserRole role) => tabsFor(role).first.path;

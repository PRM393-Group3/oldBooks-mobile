import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/theme_context.dart';

/// Một mục của thanh điều hướng dưới (tối đa 5 mục theo SRS 8.1).
class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// > 0 thì hiện chấm số (ví dụ thông báo chưa đọc).
  final int badgeCount;
}

/// Thanh điều hướng dưới dạng viên thuốc nổi, bóng đổ mềm.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
  }) : assert(items.length >= 2 && items.length <= 5);

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: colors.softShadow,
          ),
          child: Material(
            color: colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: StadiumBorder(side: BorderSide(color: colors.divider)),
            // SafeArea ngoài đã lo vùng an toàn; tránh cộng dồn hai lần.
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: onSelected,
                destinations: [
                  for (final item in items)
                    NavigationDestination(
                      icon: _badged(item, Icon(item.icon)),
                      selectedIcon: _badged(item, Icon(item.selectedIcon)),
                      label: item.label,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badged(AppNavItem item, Widget icon) {
    if (item.badgeCount <= 0) return icon;
    return Badge(
      label: Text(item.badgeCount > 99 ? '99+' : '${item.badgeCount}'),
      child: icon,
    );
  }
}

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
    this.isAction = false,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// > 0 thì hiện chấm số (ví dụ số phiên đấu giá sắp kết thúc).
  final int badgeCount;

  /// Mục hành động chính: vẽ thành nút tròn nổi bật, không có nhãn chữ
  /// (nút "+" Bán ở giữa theo prototype).
  final bool isAction;
}

/// Thanh điều hướng dưới cố định: nền thẻ, viền trên 1px, không bóng đổ.
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
    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.divider)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: AppSizes.navHeight,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primary : colors.textSecondary;

    final Widget content;
    if (item.isAction) {
      content = Container(
        width: AppSizes.minTouchTarget,
        height: AppSizes.minTouchTarget,
        decoration: BoxDecoration(
          color: colors.accent,
          shape: BoxShape.circle,
          boxShadow: colors.popShadow,
        ),
        child: Icon(item.icon, color: colors.onAccent, size: 28),
      );
    } else {
      final icon = Icon(selected ? item.selectedIcon : item.icon, color: color);
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.badgeCount > 0
              ? Badge(
                  label: Text(
                    item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                  ),
                  child: icon,
                )
              : icon,
          const SizedBox(height: AppSpacing.xxs),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Center(child: content),
      ),
    );
  }
}

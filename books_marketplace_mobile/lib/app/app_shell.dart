import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme_context.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../features/notifications/application/notification_providers.dart';
import 'nav_config.dart';

/// Khung có thanh điều hướng dưới 5 tab; mỗi tab giữ stack riêng nhờ
/// [StatefulNavigationShell].
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Quay lại foreground thì làm mới badge thông báo (không polling nền).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(unreadCountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final shell = widget.navigationShell;

    return Scaffold(
      body: shell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: shell.currentIndex,
        // Chạm lại tab đang mở thì về gốc stack của tab đó.
        onSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        items: [
          for (final t in appTabs)
            AppNavItem(
              icon: t.icon,
              selectedIcon: t.selectedIcon,
              label: t.label(l),
              isAction: t.isAction,
            ),
        ],
      ),
    );
  }
}

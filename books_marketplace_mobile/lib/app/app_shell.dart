import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme_context.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/widgets/app_page.dart';
import '../core/widgets/app_state_views.dart';
import '../features/notifications/application/notification_providers.dart';
import '../features/profile/application/profile_controller.dart';
import '../features/profile/application/role_provider.dart';
import 'nav_config.dart';

/// Khung có thanh điều hướng dưới; các tab đổi theo vai trò lấy từ hồ sơ.
class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

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

  /// Quay lại foreground thì làm mới badge (không polling nền).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(unreadCountProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final role = ref.watch(currentRoleProvider);

    return role.when(
      loading: () => const Scaffold(body: AppLoadingView()),
      error: (e, _) => AppPage(
        scrollable: false,
        child: AppErrorView(
          error: e,
          onRetry: () => ref.invalidate(profileControllerProvider),
        ),
      ),
      data: (role) {
        final tabs = tabsFor(role);
        final location = GoRouterState.of(context).uri.path;
        final index = tabs
            .indexWhere((t) => location.startsWith(t.path))
            .clamp(0, tabs.length - 1);
        final unread = tabs.any((t) => t.showsUnreadBadge)
            ? (ref.watch(unreadCountProvider).value ?? 0)
            : 0;

        return Scaffold(
          body: widget.child,
          bottomNavigationBar: tabs.length < 2
              ? null
              : AppBottomNav(
                  currentIndex: index,
                  onSelected: (i) => context.go(tabs[i].path),
                  items: [
                    for (final t in tabs)
                      AppNavItem(
                        icon: t.icon,
                        selectedIcon: t.selectedIcon,
                        label: t.label(l),
                        badgeCount: t.showsUnreadBadge ? unread : 0,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

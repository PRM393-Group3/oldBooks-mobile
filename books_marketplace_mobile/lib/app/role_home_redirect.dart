import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_page.dart';
import '../core/widgets/app_state_views.dart';
import '../features/profile/application/profile_controller.dart';
import '../features/profile/application/role_provider.dart';
import 'nav_config.dart';

/// Điểm vào sau đăng nhập: chờ biết vai trò rồi chuyển tới màn hình chính của
/// vai trò đó (Buyer/Seller: Trang chủ, Inspector: Hàng đợi, Admin: Hồ sơ).
class RoleHomeRedirect extends ConsumerWidget {
  const RoleHomeRedirect({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      data: (r) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(homePathFor(r));
        });
        return const Scaffold(body: AppLoadingView());
      },
    );
  }
}

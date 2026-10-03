import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/theme_context.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/listings/presentation/browse/browse_screen.dart';
import '../features/listings/presentation/seller/listing_detail_screen.dart';
import '../features/listings/presentation/seller/my_listings_screen.dart';
import '../features/listings/presentation/seller/wizard/listing_wizard_screen.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/profile/presentation/change_avatar_screen.dart';
import '../features/profile/presentation/change_password_screen.dart';
import '../features/profile/presentation/edit_profile_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import 'app_shell.dart';
import 'coming_soon_screen.dart';

const _authPaths = {'/login', '/register'};

Page<void> _tab(Widget child) => NoTransitionPage<void>(child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();

  // Router chỉ cần biết khi nào trạng thái đăng nhập đổi để chạy lại redirect.
  final authListenable = ValueNotifier<AuthStatus>(
    ref.read(authControllerProvider),
  );
  ref.listen(authControllerProvider, (_, next) => authListenable.value = next);
  ref.onDispose(authListenable.dispose);

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/home',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authed = authListenable.value == AuthStatus.authenticated;
      final onAuthPage = _authPaths.contains(state.uri.path);
      if (!authed && !onAuthPage) return '/login';
      if (authed && (onAuthPage || state.uri.path == '/')) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      // Thứ tự nhánh khớp `appTabs` trong nav_config.dart.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (_, _) => _tab(const BrowseScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/auctions',
                pageBuilder: (context, _) => _tab(
                  ComingSoonScreen(
                    title: context.l10n.navAuctions,
                    icon: Icons.gavel_outlined,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sell',
                pageBuilder: (_, _) => _tab(const MyListingsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wallet',
                pageBuilder: (context, _) => _tab(
                  ComingSoonScreen(
                    title: context.l10n.navWallet,
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/me',
                pageBuilder: (_, _) => _tab(const ProfileScreen()),
                routes: [
                  // Mở phủ lên thanh điều hướng dưới.
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'avatar',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const ChangeAvatarScreen(),
                  ),
                  GoRoute(
                    path: 'password',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const ChangePasswordScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Các màn hình phủ toàn màn hình, ẩn thanh tab.
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const NotificationsScreen(),
      ),
      // `/listings/new` phải đứng trước `:id`. Đường dẫn giữ nguyên `/listings`
      // tới lát 5 (restyle wizard), khi đó chuyển sang `/sell/...`.
      GoRoute(
        path: '/listings/new',
        parentNavigatorKey: rootKey,
        builder: (_, _) => const ListingWizardScreen(),
      ),
      GoRoute(
        path: '/listings/:id/edit',
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            ListingWizardScreen(listingId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/listings/:id',
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

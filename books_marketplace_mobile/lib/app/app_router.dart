import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/inspection/presentation/my_claims_screen.dart';
import '../features/inspection/presentation/queue_screen.dart';
import '../features/inspection/presentation/review_screen.dart';
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
import 'role_home_redirect.dart';

const _authPaths = {'/login', '/register'};

Page<void> _tab(Widget child) => NoTransitionPage<void>(child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  // Router chỉ cần biết khi nào trạng thái đăng nhập đổi để chạy lại redirect.
  final authListenable = ValueNotifier<AuthStatus>(
    ref.read(authControllerProvider),
  );
  ref.listen(authControllerProvider, (_, next) => authListenable.value = next);
  ref.onDispose(authListenable.dispose);

  final router = GoRouter(
    navigatorKey: rootKey,
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authed = authListenable.value == AuthStatus.authenticated;
      final onAuthPage = _authPaths.contains(state.uri.path);
      if (!authed && !onAuthPage) return '/login';
      if (authed && onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const RoleHomeRedirect()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (_, _, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, _) => _tab(const BrowseScreen()),
          ),
          GoRoute(
            path: '/listings/mine',
            pageBuilder: (_, _) => _tab(const MyListingsScreen()),
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (_, _) => _tab(const NotificationsScreen()),
          ),
          GoRoute(
            path: '/inspection/queue',
            pageBuilder: (_, _) => _tab(const QueueScreen()),
          ),
          GoRoute(
            path: '/inspection/mine',
            pageBuilder: (_, _) => _tab(const MyClaimsScreen()),
          ),
          GoRoute(
            path: '/profile',
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
      // Các màn hình phủ toàn màn hình. `/listings/new` phải đứng trước `:id`.
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
      GoRoute(
        path: '/inspection/:id',
        parentNavigatorKey: rootKey,
        builder: (_, state) =>
            ReviewScreen(listingId: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

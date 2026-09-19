import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/auth_repository.dart';
import '../domain/user_role.dart';

enum AuthStatus { authenticated, unauthenticated }

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStoreProvider),
  ),
);

/// Trạng thái đăng nhập của cả ứng dụng. Router lắng nghe để chuyển màn hình.
class AuthController extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    // Tầng mạng báo phiên đã mất (refresh thất bại, token không hợp lệ).
    final sub = ref.read(sessionEventsProvider).lost.listen((_) {
      state = AuthStatus.unauthenticated;
    });
    ref.onDispose(sub.cancel);

    return ref.read(tokenStoreProvider).hasSession
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
  }

  Future<void> login({required String email, required String password}) async {
    await ref
        .read(authRepositoryProvider)
        .login(email: email, password: password);
    state = AuthStatus.authenticated;
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .register(
          email: email,
          password: password,
          fullName: fullName,
          role: role,
        );
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = AuthStatus.unauthenticated;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthStatus>(
  AuthController.new,
);

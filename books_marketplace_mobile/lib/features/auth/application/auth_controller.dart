import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/auth_repository.dart';

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

  Future<void> sendOtp(String phone) =>
      ref.read(authRepositoryProvider).sendOtp(phone: phone);

  Future<void> login({required String phone, required String password}) async {
    await ref
        .read(authRepositoryProvider)
        .login(phone: phone, password: password);
    state = AuthStatus.authenticated;
  }

  Future<void> register({
    required String phone,
    required String otp,
    required String password,
    required String fullName,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .register(
          phone: phone,
          otp: otp,
          password: password,
          fullName: fullName,
        );
    state = AuthStatus.authenticated;
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) => ref
      .read(authRepositoryProvider)
      .resetPassword(phone: phone, otp: otp, newPassword: newPassword);

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = AuthStatus.unauthenticated;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthStatus>(
  AuthController.new,
);

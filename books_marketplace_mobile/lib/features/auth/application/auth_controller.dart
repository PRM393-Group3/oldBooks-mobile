import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'package:dio/dio.dart';

import '../../../core/config/env.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../../devices/application/device_service.dart';
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

    final hasSession = ref.read(tokenStoreProvider).hasSession;
    // Khởi động: xác nhận phiên bằng refresh. Cho vào app ngay, nếu phiên đã
    // hỏng thì quay về đăng nhập sau.
    if (hasSession && !Env.uiPreview) Future.microtask(_restoreSession);

    return hasSession ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<void> _restoreSession() async {
    try {
      await ref.read(tokenRefresherProvider).refresh();
      unawaited(ref.read(deviceServiceProvider).register());
    } on DioException catch (e) {
      // 401/403: token sai, hết hạn, bị tái sử dụng, tài khoản khóa. Lỗi mạng
      // thì giữ token, lần gọi API sau sẽ tự refresh.
      final status = e.response?.statusCode;
      if (status == 401 || status == 403) {
        await ref.read(tokenStoreProvider).clear();
        state = AuthStatus.unauthenticated;
      }
    }
  }

  /// Trả về số giây OTP còn hiệu lực.
  Future<int> sendOtp(String phone, OtpPurpose purpose) =>
      ref.read(authRepositoryProvider).sendOtp(phone: phone, purpose: purpose);

  Future<void> login({required String phone, required String password}) async {
    await ref
        .read(authRepositoryProvider)
        .login(phone: phone, password: password);
    state = AuthStatus.authenticated;
    unawaited(ref.read(deviceServiceProvider).register());
  }

  Future<void> register({
    required String phone,
    required String otp,
    required String password,
    required String fullName,
    required bool acceptTerms,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .register(
          phone: phone,
          otp: otp,
          password: password,
          fullName: fullName,
          acceptTerms: acceptTerms,
        );
    state = AuthStatus.authenticated;
    unawaited(ref.read(deviceServiceProvider).register());
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) => ref
      .read(authRepositoryProvider)
      .resetPassword(phone: phone, otp: otp, newPassword: newPassword);

  /// Xóa phiên ở máy mà không gọi server: tài khoản đã bị xóa hoặc không còn
  /// tồn tại (`USER_NOT_FOUND`), token không còn dùng được.
  Future<void> clearLocalSession() async {
    await ref.read(tokenStoreProvider).clear();
    state = AuthStatus.unauthenticated;
  }

  Future<void> logout({bool allDevices = false}) async {
    // Gỡ thiết bị trước khi thu hồi phiên để không còn nhận push sau khi thoát.
    await ref.read(deviceServiceProvider).unregister();
    await ref.read(authRepositoryProvider).logout(allDevices: allDevices);
    state = AuthStatus.unauthenticated;
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthStatus>(
  AuthController.new,
);

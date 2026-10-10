import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/otp_sent.dart';
import '../data/profile_repository.dart';
import '../domain/profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    ref.watch(apiClientProvider),
    ref.watch(plainDioProvider),
    ref.watch(tokenStoreProvider),
  ),
);

/// Hồ sơ của người dùng hiện tại. Các thao tác ghi ném [ApiError] để màn hình
/// tự hiển thị; state chỉ đổi khi server xác nhận thành công.
class ProfileController extends AsyncNotifier<Profile> {
  @override
  Future<Profile> build() {
    final authed = ref.watch(
      authControllerProvider.select((s) => s == AuthStatus.authenticated),
    );
    if (!authed) {
      return Future.error(
        const ApiError(status: 401, code: ApiErrorCode.unauthorized),
      );
    }
    return _load();
  }

  Future<Profile> _load() async {
    try {
      return await ref.read(profileRepositoryProvider).getProfile();
    } on ApiError catch (e) {
      // Token hợp lệ nhưng tài khoản không còn: coi như hết phiên.
      if (e.code == ApiErrorCode.userNotFound) {
        Future.microtask(
          () => ref.read(authControllerProvider.notifier).clearLocalSession(),
        );
      }
      rethrow;
    }
  }

  Future<void> save({required String fullName}) async {
    final profile = await ref
        .read(profileRepositoryProvider)
        .updateProfile(fullName: fullName);
    state = AsyncData(profile);
  }

  /// Bước 1 đổi số điện thoại, OTP gửi tới email của tài khoản.
  Future<OtpSent> sendPhoneOtp(String phone) =>
      ref.read(profileRepositoryProvider).sendPhoneOtp(phone: phone);

  Future<void> changePhone({required String phone, required String otp}) async {
    final profile = await ref
        .read(profileRepositoryProvider)
        .changePhone(phone: phone, otp: otp);
    state = AsyncData(profile);
  }

  /// Xóa tài khoản rồi xóa phiên ở máy. Ném [ApiError] nếu bị từ chối.
  Future<void> deleteAccount({required String password}) async {
    await ref.read(profileRepositoryProvider).deleteAccount(password: password);
    await ref.read(authControllerProvider.notifier).clearLocalSession();
  }

  Future<void> changeAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final profile = await ref
        .read(profileRepositoryProvider)
        .changeAvatar(
          bytes: bytes,
          fileName: fileName,
          contentType: contentType,
        );
    state = AsyncData(profile);
  }

  Future<void> removeAvatar() async {
    await ref.read(profileRepositoryProvider).deleteAvatar();
    final current = state.value;
    if (current != null) state = AsyncData(current.withoutAvatar());
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, Profile>(ProfileController.new);

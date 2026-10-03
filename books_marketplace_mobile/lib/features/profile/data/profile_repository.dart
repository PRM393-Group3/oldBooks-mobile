import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/util/server_clock.dart';
import '../../auth/domain/auth_session.dart';
import '../domain/profile.dart';

class ProfileRepository {
  ProfileRepository(this._api, this._plainDio, this._tokens);

  final ApiClient _api;

  /// Dio không interceptor để PUT lên Blob Storage không kèm `Authorization`.
  final Dio _plainDio;
  final TokenStore _tokens;

  Future<Profile> getProfile() => _api.get('/me', parse: Profile.fromJson);

  /// `PATCH /me`: hiện chỉ đổi được họ tên. Số điện thoại đổi bằng OTP.
  Future<Profile> updateProfile({required String fullName}) => _api.patch(
    '/me',
    body: {'fullName': fullName.trim()},
    parse: Profile.fromJson,
  );

  /// Đặt avatar theo 3 bước: xin URL upload, PUT ảnh lên Blob, xác nhận.
  Future<Profile> changeAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final blobName = await BlobUploader(
      _api,
      _plainDio,
    ).upload(bytes: bytes, fileName: fileName, contentType: contentType);

    return _api.put(
      '/me/avatar',
      body: {'blobName': blobName},
      parse: Profile.fromJson,
    );
  }

  Future<void> deleteAvatar() => _api.deleteNoContent('/me/avatar');

  /// Bước 1 đổi số: gửi OTP tới SỐ MỚI. Trả về số giây OTP còn hiệu lực.
  Future<int> sendPhoneOtp({required String phone}) => _api.post(
    '/me/phone/otp',
    body: {'phone': phone},
    parse: (data) => (data as Map)['expiresInSeconds'] as int,
  );

  /// Bước 2 đổi số. Token đang dùng không đổi (định danh theo id).
  Future<Profile> changePhone({required String phone, required String otp}) =>
      _api.post(
        '/me/phone',
        body: {'phone': phone, 'otp': otp},
        parse: Profile.fromJson,
      );

  /// Không hoàn tác. Server ẩn danh dữ liệu và thu hồi mọi phiên; sau khi
  /// thành công caller phải xóa token cục bộ.
  Future<void> deleteAccount({required String password}) =>
      _api.postNoContent('/me/delete-account', body: {'password': password});

  /// Server thu hồi mọi refreshToken cũ và trả phiên mới; phải lưu cặp mới ngay.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final session = await _api.post(
      '/me/password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      parse: AuthSession.fromJson,
    );
    ServerClock.sync(session.serverTime);
    await _tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }
}

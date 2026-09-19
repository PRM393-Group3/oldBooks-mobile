import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/blob_uploader.dart';
import '../../../core/storage/token_store.dart';
import '../../auth/domain/auth_session.dart';
import '../domain/profile.dart';

class ProfileRepository {
  ProfileRepository(this._api, this._plainDio, this._tokens);

  final ApiClient _api;

  /// Dio không interceptor để PUT lên Blob Storage không kèm `Authorization`.
  final Dio _plainDio;
  final TokenStore _tokens;

  Future<Profile> getProfile() => _api.get('/profile', parse: Profile.fromJson);

  /// PUT thay thế toàn bộ: luôn gửi đủ hai trường. [phoneNumber] `null` là xóa số.
  Future<Profile> updateProfile({
    required String fullName,
    required String? phoneNumber,
  }) => _api.put(
    '/profile',
    body: {'fullName': fullName.trim(), 'phoneNumber': phoneNumber},
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
      '/profile/avatar',
      body: {'blobName': blobName},
      parse: Profile.fromJson,
    );
  }

  Future<void> deleteAvatar() => _api.deleteNoContent('/profile/avatar');

  /// Server thu hồi mọi refreshToken cũ và trả phiên mới; phải lưu cặp mới ngay.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final session = await _api.post(
      '/profile/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
      parse: AuthSession.fromJson,
    );
    await _tokens.save(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }
}

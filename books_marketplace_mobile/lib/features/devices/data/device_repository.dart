import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';

enum PushPlatform {
  android('ANDROID'),
  ios('IOS'),
  web('WEB');

  const PushPlatform(this.apiValue);

  final String apiValue;
}

/// Thiết bị nhận push `/me/devices`.
class DeviceRepository {
  DeviceRepository(this._api);

  final ApiClient _api;

  /// Gọi lặp với cùng token là an toàn: server cập nhật `lastSeenAt` và trả
  /// cùng `id`. Một token chỉ thuộc một tài khoản tại một thời điểm.
  Future<String> register({
    required String pushToken,
    required PushPlatform platform,
    String? deviceId,
  }) => _api.post(
    '/me/devices',
    body: {
      'pushToken': pushToken,
      'platform': platform.apiValue,
      'deviceId': ?deviceId,
    },
    parse: (data) => (data as Map)['id'] as String,
  );

  /// `404 DEVICE_NOT_FOUND` nghĩa là thiết bị đã bị gỡ, bỏ qua.
  Future<void> unregister(String id) async {
    try {
      await _api.deleteNoContent('/me/devices/$id');
    } on ApiError catch (e) {
      if (e.code != ApiErrorCode.deviceNotFound) rethrow;
    }
  }
}

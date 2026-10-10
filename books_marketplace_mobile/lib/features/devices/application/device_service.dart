import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_error.dart';
import '../../../core/network/network_providers.dart';
import '../../../core/storage/storage_providers.dart';
import '../data/device_repository.dart';

/// Nguồn push token của nền tảng (FCM/APNs). Chưa gắn Firebase vào app nên
/// mặc định không có token; khi thêm `firebase_messaging` chỉ cần override
/// [pushTokenSourceProvider] bằng bản cài đặt thật.
abstract class PushTokenSource {
  /// `null` nếu chưa có token (chưa cấp quyền, chưa cấu hình nhà cung cấp).
  Future<String?> currentToken();

  /// Phát token mới mỗi khi nhà cung cấp đổi token (`onTokenRefresh`).
  Stream<String> get onTokenRefresh;
}

class NoPushTokenSource implements PushTokenSource {
  const NoPushTokenSource();

  @override
  Future<String?> currentToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}

final pushTokenSourceProvider = Provider<PushTokenSource>(
  (ref) => const NoPushTokenSource(),
);

final deviceRepositoryProvider = Provider<DeviceRepository>(
  (ref) => DeviceRepository(ref.watch(apiClientProvider)),
);

/// Đăng ký thiết bị nhận push với tài khoản đang đăng nhập.
///
/// Gọi [register] sau mỗi lần đăng nhập, đăng ký, khởi động có phiên và khi
/// token đổi; gọi [unregister] TRƯỚC `POST /auth/logout`. Mọi lỗi được nuốt:
/// push không được làm hỏng đăng nhập hay đăng xuất.
class DeviceService {
  DeviceService(this._ref);

  static const _deviceIdKey = 'push_device_id';

  final Ref _ref;
  StreamSubscription<String>? _refreshSub;

  PushPlatform get _platform => switch (defaultTargetPlatform) {
    TargetPlatform.android => PushPlatform.android,
    TargetPlatform.iOS => PushPlatform.ios,
    _ => PushPlatform.web,
  };

  Future<void> register() async {
    try {
      final token = await _ref.read(pushTokenSourceProvider).currentToken();
      if (token != null) await _send(token);
      _refreshSub ??= _ref
          .read(pushTokenSourceProvider)
          .onTokenRefresh
          .listen((t) => _send(t).catchError((Object _) {}));
    } catch (_) {
      // Không có push vẫn dùng app bình thường.
    }
  }

  Future<void> _send(String token) async {
    final id = await _ref
        .read(deviceRepositoryProvider)
        .register(pushToken: token, platform: _platform);
    await _ref.read(sharedPreferencesProvider).setString(_deviceIdKey, id);
  }

  Future<void> unregister() async {
    await _refreshSub?.cancel();
    _refreshSub = null;
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final id = prefs.getString(_deviceIdKey);
      if (id == null) return;
      await _ref.read(deviceRepositoryProvider).unregister(id);
      await prefs.remove(_deviceIdKey);
    } on ApiError {
      // Mất mạng hoặc token hết hạn: vẫn tiếp tục đăng xuất.
    } catch (_) {}
  }
}

final deviceServiceProvider = Provider<DeviceService>((ref) {
  final service = DeviceService(ref);
  return service;
});

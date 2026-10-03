import 'package:flutter/foundation.dart';

/// Cấu hình môi trường.
///
/// Ghi đè khi chạy máy thật: `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5148`
abstract final class Env {
  /// Chế độ xem trước giao diện: bỏ đăng nhập và dùng dữ liệu mẫu trong bộ
  /// nhớ thay cho backend. Mặc định TẮT (đăng nhập và gọi backend thật); bật
  /// khi chỉ muốn xem giao diện: `flutter run --dart-define=UI_PREVIEW=true`
  static const bool uiPreview = bool.fromEnvironment(
    'UI_PREVIEW',
    defaultValue: false,
  );

  static const String _override = String.fromEnvironment('API_BASE_URL');

  /// iOS simulator dùng `localhost`, Android emulator phải dùng `10.0.2.2`.
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    final host = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : 'localhost';
    return 'http://$host:5148';
  }

  /// Mọi route của backend có tiền tố `/api/v1`.
  static String get apiRoot => '$apiBaseUrl/api/v1';
}

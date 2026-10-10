/// Cấu hình môi trường.
///
/// Mặc định gọi server staging. Chạy backend ở máy dev thì ghi đè:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5148` (Android
/// emulator), `http://localhost:5148` (iOS simulator) hoặc IP LAN (máy thật).
abstract final class Env {
  /// Chế độ xem trước giao diện: bỏ đăng nhập và dùng dữ liệu mẫu trong bộ
  /// nhớ thay cho backend. Mặc định TẮT (đăng nhập và gọi backend thật); bật
  /// khi chỉ muốn xem giao diện: `flutter run --dart-define=UI_PREVIEW=true`
  static const bool uiPreview = bool.fromEnvironment(
    'UI_PREVIEW',
    defaultValue: false,
  );

  static const String stagingBaseUrl =
      'https://oldbooks-api.yellowocean-f7cb6092.southeastasia.azurecontainerapps.io';

  /// Không có `/` cuối và không chứa `/api/v1`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: stagingBaseUrl,
  );

  /// Mọi route của backend có tiền tố `/api/v1`.
  static String get apiRoot => '$apiBaseUrl/api/v1';
}

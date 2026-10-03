import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/storage/token_store.dart';
import '../domain/auth_session.dart';

/// Xác thực theo BE-SRS v1.1: số điện thoại + mật khẩu, xác thực bằng OTP SMS.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  /// Gửi OTP tới [phone] (E.164 hoặc số nội địa).
  Future<void> sendOtp({required String phone}) =>
      _api.postNoContent('/auth/otp', body: {'phone': phone});

  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final session = await _api.post(
      '/auth/login',
      body: {'phone': phone, 'password': password},
      parse: AuthSession.fromJson,
    );
    await _persist(session);
    return session;
  }

  Future<AuthSession> register({
    required String phone,
    required String otp,
    required String password,
    required String fullName,
  }) async {
    final session = await _api.post(
      '/auth/register',
      body: {
        'phone': phone,
        'otp': otp,
        'password': password,
        'fullName': fullName,
      },
      parse: AuthSession.fromJson,
    );
    await _persist(session);
    return session;
  }

  /// Đặt lại mật khẩu bằng OTP; server thu hồi mọi refresh token cũ.
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) => _api.postNoContent(
    '/auth/password/reset',
    body: {'phone': phone, 'otp': otp, 'newPassword': newPassword},
  );

  /// Luôn xóa token ở máy, kể cả khi gọi server lỗi.
  Future<void> logout() async {
    final refreshToken = _tokens.refreshToken;
    try {
      if (refreshToken != null) {
        await _api.postNoContent(
          '/auth/logout',
          body: {'refreshToken': refreshToken},
        );
      }
    } on ApiError {
      // Server không đến được hoặc token đã thu hồi: vẫn đăng xuất cục bộ.
    } finally {
      await _tokens.clear();
    }
  }

  Future<void> _persist(AuthSession session) => _tokens.save(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
  );
}

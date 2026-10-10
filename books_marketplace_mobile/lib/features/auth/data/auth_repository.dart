import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/storage/token_store.dart';
import '../../../core/util/server_clock.dart';
import '../domain/auth_session.dart';
import '../domain/otp_sent.dart';

enum OtpPurpose {
  register('REGISTER'),
  resetPassword('RESET_PASSWORD');

  const OtpPurpose(this.apiValue);

  final String apiValue;
}

/// Xác thực theo BE-SRS v1.1: số điện thoại + mật khẩu. OTP gửi qua email:
/// đăng ký tới [email] người dùng nhập, quên mật khẩu tới email của tài khoản.
class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  /// Gửi OTP cho [phone] (E.164 hoặc số nội địa). [email] bắt buộc với
  /// [OtpPurpose.register], server bỏ qua với [OtpPurpose.resetPassword].
  Future<OtpSent> sendOtp({
    required String phone,
    required OtpPurpose purpose,
    String? email,
  }) => _api.post(
    '/auth/otp',
    body: {'phone': phone, 'purpose': purpose.apiValue, 'email': ?email},
    parse: OtpSent.fromJson,
  );

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
    required bool acceptTerms,
    required String email,
  }) async {
    final session = await _api.post(
      '/auth/register',
      body: {
        'phone': phone,
        'otp': otp,
        'password': password,
        'fullName': fullName,
        'acceptTerms': acceptTerms,
        'email': email,
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
  ///
  /// Mặc định thu hồi phiên của thiết bị này; [allDevices] thu hồi mọi thiết bị.
  Future<void> logout({bool allDevices = false}) async {
    final refreshToken = _tokens.refreshToken;
    try {
      if (_tokens.accessToken != null || refreshToken != null) {
        await _api.postNoContent(
          allDevices ? '/auth/logout?all=true' : '/auth/logout',
          body: {'refreshToken': ?refreshToken},
        );
      }
    } on ApiError {
      // Server không đến được hoặc token đã thu hồi: vẫn đăng xuất cục bộ.
    } finally {
      await _tokens.clear();
    }
  }

  Future<void> _persist(AuthSession session) {
    ServerClock.sync(session.serverTime);
    return _save(session);
  }

  Future<void> _save(AuthSession session) => _tokens.save(
    accessToken: session.accessToken,
    refreshToken: session.refreshToken,
  );
}

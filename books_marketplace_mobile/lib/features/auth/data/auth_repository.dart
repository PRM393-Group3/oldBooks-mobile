import '../../../core/network/api_client.dart';
import '../../../core/network/api_error.dart';
import '../../../core/storage/token_store.dart';
import '../domain/auth_session.dart';
import '../domain/user_role.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _api.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      parse: AuthSession.fromJson,
    );
    await _persist(session);
    return session;
  }

  /// [role] chỉ nhận [UserRole.buyer] hoặc [UserRole.seller].
  Future<AuthSession> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) async {
    final session = await _api.post(
      '/auth/register',
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'role': role.apiValue,
      },
      parse: AuthSession.fromJson,
    );
    await _persist(session);
    return session;
  }

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

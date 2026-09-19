import 'user_role.dart';

/// Phiên đăng nhập do login, register, change-password trả về.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory AuthSession.fromJson(dynamic json) {
    final j = json as Map<String, dynamic>;
    return AuthSession(
      accessToken: j['accessToken'] as String,
      accessTokenExpiresAt: DateTime.parse(j['accessTokenExpiresAt'] as String),
      refreshToken: j['refreshToken'] as String,
      refreshTokenExpiresAt: DateTime.parse(
        j['refreshTokenExpiresAt'] as String,
      ),
      user: SessionUser.fromJson(j['user']),
    );
  }

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final SessionUser user;
}

class SessionUser {
  const SessionUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory SessionUser.fromJson(dynamic json) {
    final j = json as Map<String, dynamic>;
    return SessionUser(
      id: j['id'] as String,
      email: j['email'] as String,
      fullName: j['fullName'] as String,
      role: UserRole.fromApi(j['role'] as String?),
    );
  }

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
}

import 'user_role.dart';

/// Phiên đăng nhập do login, register, change-password trả về.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.user,
    this.serverTime,
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
      serverTime: DateTime.tryParse((j['serverTime'] as String?) ?? ''),
    );
  }

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final SessionUser user;

  /// Giờ server lúc trả phiên, dùng để bù lệch đồng hồ máy khi tính hạn token.
  final DateTime? serverTime;
}

class SessionUser {
  const SessionUser({
    required this.id,
    required this.fullName,
    this.phone = '',
    this.avatarUrl,
    required this.role,
    this.status = 'ACTIVE',
    this.createdAt,
  });

  factory SessionUser.fromJson(dynamic json) {
    final j = json as Map<String, dynamic>;
    return SessionUser(
      id: j['id'] as String,
      phone: (j['phone'] as String?) ?? '',
      avatarUrl: j['avatarUrl'] as String?,
      fullName: (j['fullName'] as String?) ?? '',
      role: UserRole.fromApi(j['role'] as String?),
      status: (j['status'] as String?) ?? 'ACTIVE',
      createdAt: DateTime.tryParse((j['createdAt'] as String?) ?? ''),
    );
  }

  final String id;
  final String phone;
  final String fullName;
  final String? avatarUrl;
  final UserRole role;
  final String status;
  final DateTime? createdAt;
}

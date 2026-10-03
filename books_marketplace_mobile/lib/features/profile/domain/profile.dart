import '../../auth/domain/user_role.dart';

class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    this.email = '',
    required this.role,
    required this.createdAt,
    this.phoneNumber,
    this.avatarUrl,
  });

  factory Profile.fromJson(dynamic json) {
    final j = json as Map<String, dynamic>;
    return Profile(
      id: j['id'] as String,
      email: (j['email'] as String?) ?? '',
      fullName: (j['fullName'] as String?) ?? '',
      phoneNumber: (j['phoneNumber'] ?? j['phone']) as String?,
      avatarUrl: j['avatarUrl'] as String?,
      role: UserRole.fromApi(j['role'] as String?),
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }

  final String id;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;

  /// Đã ở UTC, dùng `.toLocal()` khi hiển thị.
  final DateTime createdAt;

  Profile withoutAvatar() => Profile(
    id: id,
    email: email,
    fullName: fullName,
    phoneNumber: phoneNumber,
    avatarUrl: null,
    role: role,
    createdAt: createdAt,
  );
}

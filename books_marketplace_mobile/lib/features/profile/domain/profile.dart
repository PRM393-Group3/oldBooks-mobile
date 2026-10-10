import '../../auth/domain/user_role.dart';

/// `ProfileDto` của `GET /me`.
class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.createdAt,
    this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.status = 'ACTIVE',
  });

  factory Profile.fromJson(dynamic json) {
    final j = json as Map<String, dynamic>;
    return Profile(
      id: j['id'] as String,
      fullName: (j['fullName'] as String?) ?? '',
      phoneNumber: (j['phone'] ?? j['phoneNumber']) as String?,
      email: j['email'] as String?,
      avatarUrl: j['avatarUrl'] as String?,
      role: UserRole.fromApi(j['role'] as String?),
      status: (j['status'] as String?) ?? 'ACTIVE',
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }

  final String id;
  final String fullName;

  /// E.164, ví dụ `+84912345678`.
  final String? phoneNumber;

  /// Đã chuẩn hóa chữ thường. `null` với tài khoản tạo trước khi bật OTP email.
  final String? email;
  final String? avatarUrl;
  final UserRole role;
  final String status;

  /// Đã ở UTC, dùng `.toLocal()` khi hiển thị.
  final DateTime createdAt;

  /// Tài khoản quản trị: giao diện quản trị nằm ở web, không tự xóa được.
  bool get isStaff => role == UserRole.admin || role == UserRole.superAdmin;

  Profile withoutAvatar() => Profile(
    id: id,
    fullName: fullName,
    phoneNumber: phoneNumber,
    email: email,
    avatarUrl: null,
    role: role,
    status: status,
    createdAt: createdAt,
  );
}

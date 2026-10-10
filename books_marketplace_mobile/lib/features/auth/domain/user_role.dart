import '../../../core/l10n/app_localizations.dart';

enum UserRole {
  /// Tài khoản tự đăng ký: vừa mua, bán, đấu giá.
  user('USER'),
  buyer('Buyer'),
  seller('Seller'),
  inspector('Inspector'),
  admin('ADMIN'),
  superAdmin('SUPER_ADMIN'),
  unknown('');

  const UserRole(this.apiValue);

  /// Giá trị chuỗi trong JSON của backend.
  final String apiValue;

  static UserRole fromApi(String? value) => UserRole.values.firstWhere(
    (r) => r.apiValue == value && r != UserRole.unknown,
    orElse: () => UserRole.unknown,
  );

  String label(AppLocalizations l) => switch (this) {
    UserRole.user => l.roleUser,
    UserRole.buyer => l.roleBuyer,
    UserRole.seller => l.roleSeller,
    UserRole.inspector => l.roleInspector,
    UserRole.admin => l.roleAdmin,
    UserRole.superAdmin => l.roleSuperAdmin,
    UserRole.unknown => l.roleUnknown,
  };
}

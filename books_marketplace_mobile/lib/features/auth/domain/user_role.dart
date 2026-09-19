import '../../../core/l10n/app_localizations.dart';

enum UserRole {
  buyer('Buyer'),
  seller('Seller'),
  inspector('Inspector'),
  admin('Admin'),
  unknown('');

  const UserRole(this.apiValue);

  /// Giá trị chuỗi trong JSON của backend.
  final String apiValue;

  static UserRole fromApi(String? value) => UserRole.values.firstWhere(
    (r) => r.apiValue == value && r != UserRole.unknown,
    orElse: () => UserRole.unknown,
  );

  String label(AppLocalizations l) => switch (this) {
    UserRole.buyer => l.roleBuyer,
    UserRole.seller => l.roleSeller,
    UserRole.inspector => l.roleInspector,
    UserRole.admin => l.roleAdmin,
    UserRole.unknown => l.roleUnknown,
  };
}

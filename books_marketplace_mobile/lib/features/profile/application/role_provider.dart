import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/user_role.dart';
import 'profile_controller.dart';

/// Vai trò hiện tại, lấy từ hồ sơ (không parse token). Điều hướng phụ thuộc
/// vào giá trị này.
final currentRoleProvider = Provider<AsyncValue<UserRole>>(
  (ref) => ref.watch(profileControllerProvider).whenData((p) => p.role),
);

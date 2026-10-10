import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../data/address_repository.dart';
import '../domain/address.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(ref.watch(apiClientProvider)),
);

/// Sổ địa chỉ của người dùng. Mỗi thao tác ghi gọi server rồi tải lại cả danh
/// sách, vì server mới là nơi quyết định địa chỉ mặc định (địa chỉ đầu tiên,
/// đổi mặc định, xóa mặc định). Thao tác ghi ném [ApiError] để màn hình hiển thị.
class AddressesNotifier extends AsyncNotifier<List<Address>> {
  AddressRepository get _repo => ref.read(addressRepositoryProvider);

  @override
  Future<List<Address>> build() {
    final authed = ref.watch(
      authControllerProvider.select((s) => s == AuthStatus.authenticated),
    );
    if (!authed) return Future.value(const []);
    return _repo.list();
  }

  Future<void> _refresh() async {
    state = AsyncData(await _repo.list());
  }

  Future<void> create(Address a) async {
    await _repo.create(a);
    await _refresh();
  }

  Future<void> edit(Address a) async {
    await _repo.update(a);
    await _refresh();
  }

  /// Đặt mặc định bằng cách gửi lại đủ trường với `isDefault: true`; server tự
  /// bỏ cờ của địa chỉ mặc định cũ.
  Future<void> setDefault(Address a) => edit(a.copyWith(isDefault: true));

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await _refresh();
  }

  Future<void> reload() async {
    ref.invalidateSelf();
    await future;
  }
}

final addressesProvider =
    AsyncNotifierProvider<AddressesNotifier, List<Address>>(
      AddressesNotifier.new,
    );

final defaultAddressProvider = Provider<Address?>((ref) {
  for (final a in ref.watch(addressesProvider).value ?? const <Address>[]) {
    if (a.isDefault) return a;
  }
  return null;
});

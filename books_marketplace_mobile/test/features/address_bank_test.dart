import 'package:books_marketplace_mobile/core/preview/preview_overrides.dart';
import 'package:books_marketplace_mobile/features/auth/application/auth_controller.dart';
import 'package:books_marketplace_mobile/features/profile/application/address_providers.dart';
import 'package:books_marketplace_mobile/features/profile/domain/address.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Address _addr(String id, {bool isDefault = false}) => Address(
  id: id,
  recipient: 'A',
  phone: '0912345678',
  province: 'HN',
  district: 'TH',
  ward: 'QA',
  detail: '1 Phố',
  isDefault: isDefault,
);

ProviderContainer _container() {
  final c = ProviderContainer(
    overrides: [
      addressRepositoryProvider.overrideWithValue(
        InMemoryAddressRepository(seed: const [sampleAddress]),
      ),
      authControllerProvider.overrideWith(_SignedIn.new),
    ],
  );
  addTearDown(c.dispose);
  return c;
}

class _SignedIn extends AuthController {
  @override
  AuthStatus build() => AuthStatus.authenticated;
}

void main() {
  test(
    'sổ địa chỉ: luôn đúng một địa chỉ mặc định (quy tắc của server)',
    () async {
      final c = _container();
      await c.read(addressesProvider.future);
      final n = c.read(addressesProvider.notifier);
      List<Address> list() => c.read(addressesProvider).requireValue;
      expect(c.read(defaultAddressProvider)!.id, 'seed');

      await n.create(_addr('x'));
      expect(list().where((a) => a.isDefault).length, 1);
      expect(c.read(defaultAddressProvider)!.id, 'seed');

      await n.create(_addr('y', isDefault: true));
      expect(list().where((a) => a.isDefault).length, 1);
      expect(list().first.isDefault, isTrue, reason: 'mặc định lên đầu');

      final defaultId = c.read(defaultAddressProvider)!.id;
      await n.remove(defaultId);
      expect(c.read(defaultAddressProvider), isNotNull);
      expect(list().where((a) => a.isDefault).length, 1);

      for (final a in [...list()]) {
        await n.remove(a.id);
      }
      expect(c.read(defaultAddressProvider), isNull);
    },
  );

  test('địa chỉ đầu tiên luôn mặc định dù gửi isDefault false', () async {
    final c = ProviderContainer(
      overrides: [
        addressRepositoryProvider.overrideWithValue(
          InMemoryAddressRepository(),
        ),
        authControllerProvider.overrideWith(_SignedIn.new),
      ],
    );
    addTearDown(c.dispose);
    await c.read(addressesProvider.future);
    await c.read(addressesProvider.notifier).create(_addr('first'));
    expect(c.read(defaultAddressProvider), isNotNull);
  });

  test('địa chỉ in một dòng từ nhỏ đến lớn, bỏ phần trống', () {
    expect(_addr('z').fullLine, '1 Phố, QA, TH, HN');
    expect(_addr('z').copyWith(ward: ' ').fullLine, '1 Phố, TH, HN');
  });
}

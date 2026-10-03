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

void main() {
  test('sổ địa chỉ: luôn đúng một địa chỉ mặc định', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(addressesProvider.notifier);
    expect(c.read(defaultAddressProvider)!.id, 'a0');

    n.upsert(_addr('x'));
    expect(c.read(addressesProvider).where((a) => a.isDefault).length, 1);
    n.upsert(_addr('y'), makeDefault: true);
    expect(c.read(defaultAddressProvider)!.id, 'y');

    n.remove('y');
    expect(c.read(defaultAddressProvider), isNotNull);
    expect(c.read(addressesProvider).where((a) => a.isDefault).length, 1);

    n.remove('a0');
    n.remove('x');
    expect(c.read(defaultAddressProvider), isNull);
  });

  test('địa chỉ in một dòng từ nhỏ đến lớn, bỏ phần trống', () {
    expect(_addr('z').fullLine, '1 Phố, QA, TH, HN');
    expect(_addr('z').copyWith(ward: ' ').fullLine, '1 Phố, TH, HN');
  });

  test('tài khoản ngân hàng: tối đa 3, che số', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final n = c.read(bankAccountsProvider.notifier);
    BankAccount b(String id) =>
        BankAccount(id: id, bank: 'ACB', number: '123456789', holder: 'A');

    expect(n.add(b('1')), isTrue);
    expect(n.add(b('2')), isTrue);
    expect(c.read(bankAccountsProvider).length, 3);
    expect(n.add(b('3')), isFalse);
    expect(b('1').last4, '6789');
    n.remove('1');
    expect(c.read(bankAccountsProvider).length, 2);
  });
}

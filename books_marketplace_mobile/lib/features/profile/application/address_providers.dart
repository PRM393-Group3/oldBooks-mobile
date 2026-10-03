import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/address.dart';

/// Sổ địa chỉ trong bộ nhớ. Khi có API `/me/addresses` thì thay bằng
/// repository; giao diện chỉ đọc qua provider này. Luôn đúng một địa chỉ mặc định
/// khi sổ không rỗng.
class AddressesNotifier extends Notifier<List<Address>> {
  int _seq = 1;

  @override
  List<Address> build() => const [
    Address(
      id: 'a0',
      recipient: 'Nguyễn Minh Anh',
      phone: '0912345482',
      province: 'Hà Nội',
      district: 'Tây Hồ',
      ward: 'Quảng An',
      detail: '18 Ngõ 52 Tô Ngọc Vân',
      isDefault: true,
    ),
  ];

  List<Address> _normalize(List<Address> list) {
    if (list.isEmpty || list.any((a) => a.isDefault)) return list;
    return [list.first.copyWith(isDefault: true), ...list.skip(1)];
  }

  void upsert(Address a, {bool makeDefault = false}) {
    final exists = state.any((x) => x.id == a.id);
    var list = exists
        ? [for (final x in state) x.id == a.id ? a : x]
        : [...state, a];
    if (makeDefault || (!exists && state.isEmpty)) {
      list = [for (final x in list) x.copyWith(isDefault: x.id == a.id)];
    }
    state = _normalize(list);
  }

  String newId() => 'a${_seq++}-${state.length}';

  void setDefault(String id) =>
      state = [for (final x in state) x.copyWith(isDefault: x.id == id)];

  void remove(String id) => state = _normalize([
    for (final x in state)
      if (x.id != id) x,
  ]);
}

final addressesProvider = NotifierProvider<AddressesNotifier, List<Address>>(
  AddressesNotifier.new,
);

final defaultAddressProvider = Provider<Address?>((ref) {
  for (final a in ref.watch(addressesProvider)) {
    if (a.isDefault) return a;
  }
  return null;
});

class BankAccountsNotifier extends Notifier<List<BankAccount>> {
  @override
  List<BankAccount> build() => const [
    BankAccount(
      id: 'b0',
      bank: 'Vietcombank',
      number: '0071001234821',
      holder: 'NGUYEN MINH ANH',
    ),
  ];

  /// `false` nếu đã đủ [maxBankAccounts].
  bool add(BankAccount a) {
    if (state.length >= maxBankAccounts) return false;
    state = [...state, a];
    return true;
  }

  void remove(String id) => state = [
    for (final x in state)
      if (x.id != id) x,
  ];
}

final bankAccountsProvider =
    NotifierProvider<BankAccountsNotifier, List<BankAccount>>(
      BankAccountsNotifier.new,
    );

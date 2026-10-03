/// Địa chỉ giao hàng (FR-AUTH-07).
class Address {
  const Address({
    required this.id,
    required this.recipient,
    required this.phone,
    required this.province,
    required this.district,
    required this.ward,
    required this.detail,
    this.isDefault = false,
  });

  final String id;
  final String recipient;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String detail;
  final bool isDefault;

  /// Một dòng địa chỉ đầy đủ, từ nhỏ đến lớn.
  String get fullLine => [
    detail,
    ward,
    district,
    province,
  ].where((e) => e.trim().isNotEmpty).join(', ');

  Address copyWith({
    String? recipient,
    String? phone,
    String? province,
    String? district,
    String? ward,
    String? detail,
    bool? isDefault,
  }) => Address(
    id: id,
    recipient: recipient ?? this.recipient,
    phone: phone ?? this.phone,
    province: province ?? this.province,
    district: district ?? this.district,
    ward: ward ?? this.ward,
    detail: detail ?? this.detail,
    isDefault: isDefault ?? this.isDefault,
  );
}

/// Tài khoản ngân hàng nhận tiền khi rút (FR-WAL-08), tối đa [maxBankAccounts].
class BankAccount {
  const BankAccount({
    required this.id,
    required this.bank,
    required this.number,
    required this.holder,
  });

  final String id;
  final String bank;
  final String number;
  final String holder;

  String get last4 =>
      number.length <= 4 ? number : number.substring(number.length - 4);
}

const maxBankAccounts = 3;

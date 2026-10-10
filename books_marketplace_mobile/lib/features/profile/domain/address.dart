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

  /// `AddressDto` của `GET /me/addresses`.
  factory Address.fromJson(dynamic json) {
    final j = json as Map<String, dynamic>;
    return Address(
      id: j['id'] as String,
      recipient: (j['recipientName'] as String?) ?? '',
      phone: (j['phone'] as String?) ?? '',
      province: (j['province'] as String?) ?? '',
      district: (j['district'] as String?) ?? '',
      ward: (j['ward'] as String?) ?? '',
      detail: (j['detail'] as String?) ?? '',
      isDefault: (j['isDefault'] as bool?) ?? false,
    );
  }

  final String id;
  final String recipient;
  final String phone;
  final String province;
  final String district;
  final String ward;
  final String detail;
  final bool isDefault;

  /// Body thêm/sửa. `PATCH` thay toàn bộ nên luôn gửi đủ mọi trường.
  Map<String, dynamic> toJson() => {
    'recipientName': recipient.trim(),
    'phone': phone.trim(),
    'province': province.trim(),
    'district': district.trim(),
    'ward': ward.trim(),
    'detail': detail.trim(),
    'isDefault': isDefault,
  };

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
